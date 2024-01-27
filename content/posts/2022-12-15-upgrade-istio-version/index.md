---
title: "Istio 버전 업그레이드 실습 가이드"
date: 2022-12-15T11:59:39+09:00
author: jonnung
draft: false
toc: false
images:
tags:
  - istio
  - kubernetes
categories:
  - kubernetes
  - tutorial
  - istio
description: Istio 버전 업그레이드하겠다는 마음을 먹었지만, 혹시라도 서비스에 장애가 나지 않을까 걱정이 앞섰습니다. 그래서 필요한 건 연습뿐! 테스트용 Kubernetes 클러스터에서 Istio를 설치하고 업그레이드 해봤습니다. 
url: /istio/2022/12/15/upgrade-istio-version/
---
## 1. 테스트용 EKS 클러스터 생성
마음 편하게 테스트할 수 있는 EKS 클러스터를 하나 준비합니다.  
테스트용 애플리케이션을 실행해서 Sidecar Proxy가 제대로 붙는지 확인할 수 있는 Worker Node도 하나 있으면 좋습니다.  


## 2. Istio Operator init
우선 최초로 설치할 Istio를 낮은 버전으로 설치하도록 합니다.  
그렇게 하기 위해서 원하는 버전에 맞는 `istioctl`가 설치되어야 합니다.   

> 참고로 저는 `istioctl`을 설치하기 위해 [asdf](https://asdf-vm.com/)를 사용합니다. 

```shell
$ istioctl version

no running Istio pods in "istio-system"
1.12.9
```

그럼 다음 명령어로 Istio Operator 컨트롤러 구성을 설치합니다. 
```shell
$ istioctl operator init
```

위 결과로 다음 4가지 구성 요소가 생성됩니다. 
1. Isito Operator CRD
2. Isito Operator Controller Deployment
3. Istio Operator Metric에 접근할 수 있는 Service
4. Istio Operator에 필요한 RBAC (Clsuterrole)


## 3. Operator CRD를 생성해서 Isito 설치하기
Istio Operator 리소스를 생성해서 Istio Control Plane이 구성되도록 합니다.  

```shell
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  profile: demo
EOF
```

> 여기까지 최초 버전(구) Istio 설치가 완료 되었습니다. 
----

## 4. Istio Control Plane Canaray Upgrade

[참고 자료 - Istio Canary Upgrade](https://istio.io/latest/docs/setup/install/operator/#canary-upgrade)

업그레이드할 Istio 버전의 `istioctl`을 설치합니다.  
전 단계에서 설치한 버전은 `1.12.9`이고, 새로운 버전은 `1.13.8`라고 가정합니다.  

```shell
$ istioctl version

client version: 1.13.8
control plane version: 1.12.9
data plane version: 1.12.9 (3 proxies)
```

`--revision` 파라미터를 붙여서 Isito Operator을 초기화 합니다.

```shell
$ istioctl operator init --revision 1-13-8
```


### 4-1. Istio Operator CRD를 생성해서 새로운 Istio 설치하기

```shell
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane-1-13-8
spec:
  revision: 1-13-8
  profile: demo
EOF
```

위 Operator가 추가되면 새로운 Control Plane(`istiod`)가 추가되는 걸 확인할 수 있습니다. 

```shell
$ kubectl get pod -n istio-system -l app=istiod

NAME                             READY   STATUS    RESTARTS   AGE
istiod-1-13-8-67ffb49666-q5jdn   1/1     Running   0          2m10s
istiod-d89fbd76c-vxnlg           1/1     Running   0          142m

```

### 4-2. 새로운 Istio 버전으로 Data Plane 업그레이드하기
이제 애플리케이션 POD가 실행되고 있는 Namespace에 `istio.io/rev=1-13-9` label을 추가하고, 모든 Deployment를 재실행해야 합니다.  

[참고 자료 - Istio Data Plane 업그레이드](https://istio.io/latest/docs/setup/upgrade/canary/#data-plane)

istiod와 달리 Istio Ingress/Egress Gateway는 버전마다 인스턴스를 추가 실행하지 않지만, 새로운 Istio Control Plane 버전을 사용하도록 내부에서 업그레이드됩니다.  

▼ 확인하기
```shell
$ istioctl proxy-status | grep $(kubectl -n istio-system get pod -l app=istio-ingressgateway -o jsonpath='{.items..metadata.name}') | awk '{print $7}'

istiod-1-13-9-67ffb49666-q5jdn
```

하지만 아직 워크로드 상에 동작하는 POD에는 새로운 버전의 Sidecar Proxy가 적용되어 있지 않습니다.  
그래서 Namespace의 label을 기반으로 새로운 버전의 Sidecar proxy가 주입될 수 있도록 변경해야 합니다.  
워크로드가 동작하는 Namespace에 `istio-injection` label을 제거하고, `istio.io/rev=1-13-9` label을 추가합니다.  

```shell
$ kubectl label namespace test-apps istio-injection- istio.io/rev=1-13-8
```

그 다음 해당 Namespace의 모든 POD에 새로운 버전의 Sidecar Proxy가 재주입될 수 있도록 재실행 합니다.  
```shell
kubectl rollout restart deployment -n test-apps
```

## 5. 이상합니다. POD의 Sidecar Proxy 버전이 여전히 그대로...
새로운 버전의 `istioctl`로 Operator 구성 요소를 추가했고 새로운 Control Plane을 배포했지만, 워크로드에 POD의 Sidecar Proxy는 여전히 이전 버전(`1.12.9`)으로 되어 있습니다.   

확인해보니 `istiod` 까지 이전 버전이네요. 이상합니다...  

우선 가장 의심이 되는 `Mutatingwebhookconfigurations`리소스를 확인해보니 `istio-sidecar-injector-1-13-9`에 `operator.istio.io/version=1.12.9`라는 label이 붙어 있습니다.  
`istio.io/rev=1-13-9` label 처럼 `1.13.9` 버전으로 지정되지 않은 게 문제로 보입니다.  

아마 최초 `istioctl operator init`할 때 여전히 `1.12.9` 버전이 지정되어 있었는지 의심이 됩니다.  

우선 임시 조치로 `Mutatingwebhookconfigurations`리소스인 `istio-sidecar-injector-1-13-9`에 `operator.istio.io/version=1.13.9`로 변경 후 저장 했습니다.  

그리고 좀 위험하지만 새로운 버전으로 실행된 `istiod` Deployment를 삭제 했습니다.  
어차피 Istio Operator가 Deployment를 다시 생성할 것으로 기대하기 때문이죠.  

재실행 된 Deployment에는 정상적으로 `1.13.9` 버전의 Istio가 실행되고 있었습니다....  


## 6. 이상합니다. Istio Operator의 상태가 ERROR...
새로운 버전의 Istio Operator 상태가 `ERROR`로 표시되어 메시지를 확인해보니 아래 내용과 연관된 내용이 포함되어 있었습니다.  

```
service “istiod” not found
```

확실한 건 새로운 버전에는 `istio.io/rev` label을 추가했기 때문에 `istiod`라는 이름을 갖는 Service는 존재하지 않는 것이 맞습니다.  
왜냐하면 Service 이름에도 `istio.io/rev` label로 지정한 이름이 Suffix로 붙기 때문입니다.  
(예: `istiod-1-13-8`)  

[이 문제에 대한 질문](https://discuss.istio.io/t/service-istiod-not-found-during-canary-upgrade-1-5-1-6-1-7/9272) 의 답변으로 `validatingwebhookconfiguration` 리소스에 isitod에 대한 Webhook Validator를 (새로운 버전의) 하나만 유지하는 것입니다.  

> 아마도 `istiod`라는 이름의 Service를 찾으려고 했던 원인은 완전 최초로 설치된 istio가 `istio.io/rev` label 없이 설치되었기 때문인 것으로 예상됩니다.  



## 7. 구 버전 Istio Operator 제거하기
업그레이드가 완료 됐기 때문에 구 버전의 Istio를 제거하도록 합니다.  
구 버전의 IstioOperator CRD를 삭제하면, 구 버전 Istio가 자동으로 제거 됩니다.  

```shell
$ kubectl delete istiooperators.install.istio.io \
  -n istio-system \
  example-istiocontrolplane
```

위 명령어 실행 후 IstioOperator 가 삭제되지 않고, 대기하는 이유는 `Finalizers: istio-finalizer.install.istio.io`가 등록되어 있기 때문입니다.  
`Finalizers` 필드를 제거하면 IstioOperator의 삭제가 완료됩니다.  

그 다음 Isito Operator Controller 관련된 리소스를 삭제하기 위해 다음 명령어를 실행합니다. 
```shell
$ istioctl operator remove --revision default --force
```


## 8. 마치며
EKS 버전 업그레이드를 하면서 Istio 버전 업그레이드가 계속 마음의 짐이었습니다.  
그런데 연습을 좀 해보면서 그렇게 어렵진 않다고 느꼈고, 특히 Operator를 사용해서 설치하고 업그레이드 하는 과정이 훨씬 쉬웠고, 직관적으로 이해된다고 생각했습니다.  
이번 (업그레이드를) 계기로 Istio를 더 잘 써보고 싶다는 의욕이 뿜뿜...ㅎㅎ  
