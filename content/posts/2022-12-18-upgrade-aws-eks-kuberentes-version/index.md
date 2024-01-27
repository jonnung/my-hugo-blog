---
title: "AWS EKS 버전 업그레이드 실습 가이드"
date: 2022-12-18T12:33:00+09:00
draft: false
toc: false
image: "/images/posts/tcard/2022-12-18-upgrade-aws-eks-kuberentes-version.png"
tags:
  - kubernetes
  - aws
  - eks
categories:
  - kubernetes
  - tutorial
description: 미뤄왔던 AWS EKS의 버전 업그레이드를 진행했습니다. v1.19에서 v1.23까지 4단계를 올라갔기 때문에 손이 많이 갔고, 신중할 수밖에 없는 작업이었습니다. 하지만 엄청나게 어렵지는 않아요. 쉽지 않을 뿐?
url: /kubernetes/2022/12/18/upgrade-aws-eks-kubernetes-version
---

## 1. Control Plane 업그레이드
AWS EKS에서 Control Plane은 AWS에서 직접 관리하기 때문에 업그레이드하는 방법은 의외로 간단합니다.  

가장 기본적인 방법으로는 AWS Management Console(web) 상에서 "upgrade now"을 클릭하면 끝입니다.  

>하지만 저는 IaC 도구인 AWS CDK를 사용했기 때문에 `Cluster` 객체의 `version`을 `KubernetesVersion.V1_21` 같은 형태로 수정한 후 `cdk deploy` 를 실행 했습니다.


### 1-2. ⚠️ Cluster Autoscaler를 사용하고 있는 경우
EKS 클러스터에서 **Cluster Autoscaler**를 사용하고 있는 경우, 업그레이드할 Kubernetes의 Major 버전과 Minor 버전이 일치하는 Cluster Autoscaler 버전으로 업데이트해야 합니다.  

Cluster Autoscaler 버전은 [여기](https://github.com/kubernetes/autoscaler/releases) 릴리즈 목록에서 해당되는 버전을 찾을 수 있습니다. 

▼ Cluster Autoscaler 컨테이너 이미지 교체하기
```shell
kubectl set image deployment.apps/cluster-autoscaler \
  -n kube-system \
  cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:{버전}
```


### 1-3 ⚠️ v1.22으로 업그레이드할 때 점검 사항
Kubernetes `v1.22`에서 여러 베타 API(`v1beta1`)가 GA(`v1`)되어 제거되었다고 합니다.
먼저 [AWS 공식 문서](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/update-cluster.html#update-1.22)를 확인해서 각 리소스에서 사용된 API 버전을 한번 확인하는 것이 좋습니다. 

그리고 **AWS Load Balancer Controller를 사용한 경우**, 클러스터를 `v1.22`로 업그레이드하기 전에 AWS Load Balancer Controller를 `2.4.x`으로 업데이트해야 합니다!

[AWS Load Balancer Controller 설치 및 업그레이드 문서](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html)


----

## 2. Worker Node 업그레이드
이제 애플리케이션 POD가 실행되고 있는 Worker Node의 버전을 업그레이드합니다.  

여기서 중요하게 기억해야 할 내용은 만약 **관리형 NodeGroup**를 사용하고 있다면, NodeGroup 마다 직접 업그레이드 해줘야 한다는 것입니다.  

이 작업도 AWS Management Console(web)에서 할 수 있지만, 기록을 남기는 취지에서  `eksctl` 명령어를 사용하도록 하겠습니다.  
(사실 AWS CDK에서 Node 버전 업그레이드하는 방법은 도저히 찾지 못했습니다. ㅠㅠ)  


### 2-1. 관리형 NodeGroup을 업데이트하면 수행되는 절차 알아두기
1. NodeGroup과 연결된 새로운 버전의 EC2 시작 템플릿 생성
2. 새로운 EC2 시작 템플릿으로 Auto Scaling 그룹 업데이트
3. NodeGroup의 최대 업그레이드 노드 수 결정
4. 업그레이드된 노드는 업그레이드 중인 노드와 동일한 가용 영역(AZ)에서 시작

[공식 AWS 문서 참고](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managed-node-update-behavior.html)


### 2-2. NodeGroup 업그레이드 
아래 eksctl 명령어는 Kubernetes 버전(`--kubernetes-version`)과 NodeGroup 이름(`--name`), EKS 클러스 이름(`--cluster`)을 명시한 후 실행합니다.  

완료 되기까지 15분 이상 소요될 수 있으니 느긋한 마음으로 기다립니다.  

```shell
eksctl upgrade nodegroup \
  --name=DevEksSampleNodeGroup \
  --cluster=dev-eks-cluster \
  --kubernetes-version=1.23
```


### 2-3. ⚠️ NodeGroup 업그레이드가 실패하는 이유
Node 업그레이드가 진행되는 과정에서 이전 Worker Node에서 실행되고 있는 POD는 모두 쫒겨나게 됩니다.    
이때 `PodEvictionFailure`가 발생하며, Node 업그레이드가 실패하는 경우가 있습니다.   

1. **Aggressive? PodDisruptionBudget(PDB)**  
PDB의 `minAvailable`필드 값이 0보다 큰 경우처럼 Healthy한 POD 개수가 반드시 보장되어야 하기 때문에 Eviction이 실패할 수 있게 됩니다.  

2. **모든 Taint를 허용하는 Deployment**  
이전 Worker Node는 Taint 되었기 때문에 POD가 스케줄링 될 수 없습니다.  
하지만 어떤 Deployment의 Tolerations이 모든 Taint를 허용하는 경우, 이전 Worker Node에 스케줄링 되어 버릴 수도 있습니다.  



## 3. Add On 기능 업그레이드
업그레이드할 Kubernetes 버전에 맞게 다음 항목들도 함께 업그레이드 해줘야 합니다. 😅   
(하다 보니 은근히 손이 많이 가네요.)  

1. Amazon VPC CNI Plugin
2. CoreDNS
3. KubeProxy
4. AWS Load Balancer Contorller

한 가지 참고해야 할 사항은 Kubernetes 1.18 버전 이상의 EKS 클러스터를 **AWS Console에서 직접 생성한 경우**, 위 플러그인 중 일부는 **EKS add-on**으로서 자동으로 설치된 상태로 되어 있습니다.  

하지만 그밖에 도구(예: AWS CDK)를 이용해서 설치한 경우, 자체 관리형(Self-managed) add-on으로 설치됩니다.   
이 경우 AWS Management Console 화면에서 "Add-ons"가 텅 비어 있는 것처럼 보이게 됩니다.  

![](https://user-images.githubusercontent.com/1030290/208280193-023dd61b-f680-4200-b936-feba5f9bce01.png)

이 차이가 중요한 이유는 버전 업그레이드하는 방법이 다르기 때문입니다.  
장기적인 관점에서 생각해봤을 때 EKS 버전을 정기적으로 업그레이드한다면, 자체 관리형 add-on 방식보다 **EKS Add-On**으로 등록된 편이 나을 것 같습니다.  

그럼 아래 내용에서는 자체 관리형 Add-On에서 EKS add-on으로 마이그레이션 하는 방법도 함께 다루도록 하겠습니다.  


### 3-1. (잠깐만) Amazon  VPC CNI Plugin에 대해 알고 넘어가기
Amazon VPC CNI Plugin은 Kubernetes 노드에 VPC IP주소를 할당하고, 각 POD에 대한 필수 네트워킹을 구성하는 역할을 합니다.  
ENI(Elastic Network Interface)를 생성해서 EC2 노드에 연결하고, Private IPv4, IPv6 주소를 VPC에서 각 POD에 할당하게 됩니다.  

Amazon VPC CNI Plugin에 대한 내용은 아래 링크를 한번 읽어보는 것이 좋을 것 같습니다.  
[Proposal: CNI plugin for Kubernetes networking over AWS VPC](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/cni-proposal.md)


### 3-2. VPC CNI Plugin 버전 확인
```shell
kubectl describe daemonset aws-node \
  --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3
```


### 3-3. VPC CNI Plugin을 ESK Add-On으로 마이그레이션
아마도 이미 `aws-node`라는 Service Account가 존재할 수도 있습니다.  
이 Service Account에 `AmazonEKS_CNI_Policy`가 연결된 IAM Role이 부여되어야 합니다.   

IAM Role이 없다는 가정하에 아래 명령어로 `AmazoneEKS_CNI_Policy`가 연결된 IAM Role을 생성합니다.   
```shell
eksctl create iamserviceaccount \
    --name aws-node \
    --namespace kube-system \
    --cluster dev-eks-cluster \
    --role-name "DevAmazonEKSVPCCNIRole" \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve
```

그다음 위 IAM Role의 ARN과 함께 EKS Add-on을 추가하는 명령어를 실행합니다.  
아래 `1.11.4-eksbuild.1`라고 되어 있는 버전은 각 클러스터 버전에 대한 [Amazon VPC CNI Add-On 권장 버전](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-vpc-cni.html#manage-vpc-cni-recommended-versions)을 확인해서 적절한 버전을 명시합니다. 
```shell
eksctl create addon \
  --name vpc-cni \
  1.11.4-eksbuild.1 \
  --cluster dev-eks-cluster \
    --service-account-role-arn arn:aws:iam::************:role/DevAmazonEKSVPCCNIRole \
  --force
```

[공식 AWS 문서 참고](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-vpc-cni.html)  

▼ EKS Add-On으로 마이그레이션한 결과  
![](https://user-images.githubusercontent.com/1030290/208280198-1c6f8291-62d9-4194-a7e7-f502569980ac.png)

### 3-4. VPC CNI Plugin 업그레이드
현재 버전과 업그레이드 가능한 버전을 확인합니다.   
```
eksctl get addon --name vpc-cni --cluster
```

`UPDATE AVAILABLE` 항목에 표시된 버전 중 권장 버전으로 업그레이드를 진행합니다.  
```shell
eksctl update addon \
  --name vpc-cni \
  --version 1.11.4-eksbuild.1 \
  --cluster dev-eks-cluster \
  --force
```


### 3-5. CoreDNS를 EKS Add-On으로 마이그레이션

CoreDNS도 Amazon VPC CNI Plugin과 같이 EKS add-on으로 설치하고 관리할 수 있습니다.  
하지만 만약 위 경우처럼 자체 관리형(Self-managed) add-on인 경우 EKS add-on으로 마이그레이션을 진행한 후 버전 업그레이드를 진행합니다.  

```shell
eksctl create addon --name coredns --cluster dev-eks-cluster --force
```

[공식 AWS 문서 참고](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-coredns.html)


### 3-6. CoreDNS 업그레이드
EKS add-on으로 추가된 CoreDNS를 확인해봅니다.   

```shell
eksctl get addon --name coredns --cluster dev-eks-cluster

NAME  VERSION     STATUS  ISSUES  IAMROLE UPDATE AVAILABLE
coredns v1.8.4-eksbuild.1 ACTIVE  0   v1.8.7-eksbuild.3,v1.8.7-eksbuild.2,v1.8.7-eksbuild.1
```

출력되는 결과에 현재 버전(`VERSION`)과 업그레이드 가능한 버전(`UPDATE AVAILABLE`)이 나옵니다.  
현재 EKS 버전에서 지원하는 적절한 버전으로 업그레이드를 진행합니다.  

```shell
eksctl update addon \
  --name coredns \
  --version v1.8.7-eksbuild.3 \
  --cluster dev-eks-cluster \
  --force
```


### 3-7. kube-proxy를 EKS Add-On으로 마이그레이션
kube-proxy는 각 EC2 노드에서 네트워크 규칙을 관리하고, POD와의 네트워크 통신을 가능하게 합니다.  

kube-proxy도 이미 위에서 업그레이드한 Amazon VPC CNI Plugin, CoreDNS처럼 EKS add-on으로 관리할 수 있습니다.  

```shell
eksctl create addon --name kube-proxy --cluster dev-eks-cluster --force
```

[공식 AWS 문서 참고](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-kube-proxy.html)


### 3-8. kube-proxy 업그레이드
CoreDNS 업그레이드와 마찬가지로 현재 업그레이드 가능한 버전을 확인하고, EKS 버전에 적합한 버전으로 업그레이드를 진행합니다.  

```shell
eksctl get addon --name kube-proxy --cluster dev-eks-cluster
```

```shell
eksctl update addon \
  --name kube-proxy \
  --version v1.23.13-eksbuild.2 \
  --cluster dev-eks-cluster \
  --force
```


## 마치며
솔직히 고백하자면 2021년 3월에 만든 Kubernetes `1.19` 버전의 EKS 클러스터로 현재(2022년 12월)까지 운영하고 있었습니다.  
그리고 버전 업그레이드를 처음 계획한 건 2022년 7월이었으니 5개월만에 행동으로 옮겼습니다.  
당연한 핑계는 "좀 바빴다." 입니다.  
그래도 어쨌든 올해 안에 완료했으니 자책보단 칭찬으로 마무리해 봅니다. 하하핳... 