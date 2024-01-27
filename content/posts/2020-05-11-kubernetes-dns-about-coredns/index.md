---
title: "Kubernetes의 DNS, CoreDNS를 알아보자"
date: 2020-05-11T00:37:28+09:00
draft: false
toc: false
image: "/images/posts/coredns.jpg"
tags:
  - kubernetes
categories:
  - kubernetes
url: /kubernetes/2020/05/11/kubernetes-dns-about-coredns/
description: 쿠버네티스의 DNS 서버인 CoreDNS에 대해 살펴보고 POD에서 보내는 도메인 요청이 어떤 원리로 목적지 IP를 찾게 되는지 살펴본다. 
---
## CoreDNS 살펴보기

쿠버네티스 클러스터 내 POD에서 어떤 도메인을 찾고자 할 때 `kube-system` 네임스페이스에 실행되고 있는 **CoreDNS**가 네임서버로 사용된다. 
기존에 Kube-DNS가 이 역할을 했는데 `1.12`버전부터 CoreDNS가 표준으로 채택되었다. 그래서 `kubeadm`으로 설치하는 경우 CoreDNS가 설치된다. 

```
$ kubectl get po -n kube-system -l k8s-app=kube-dns

NAME                       READY   STATUS    RESTARTS   AGE
coredns-6955765f44-qmfm4   1/1     Running   0          15h
coredns-6955765f44-svftc   1/1     Running   0          15h
```

CoreDNS도 POD로 실행되기 때문에 외부 요청을 받기 위해 Service 오브젝트가 존재한다. 
```
$ kubectl get svc -n kube-system -l k8s-app=kube-dns

NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP
```
CoreDNS Service 오브젝트의 `metadata.name`이 `kube-dns`으로 되어 있는 이유는 예전부터 이 이름을 사용하던 리소스와의 호환성을 위해 그대로 사용한다고 한다. 

CoreDNS의 여러가지 기능은 `Corefile`설정 파일에 원하는 것들만 플러그인처럼 추가할 수 있다. 이 `Corefile` 파일은 ConfigMap 오브젝트에 저장되어 있다.
```
$ kubectl describe cm -n kube-system coredns

Name:         coredns
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Data
====
Corefile:
----
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
```

간단하게 `Corefile` 구성을 살펴보자.

- `errors` : 에러가 발생하면 stdout으로 보낸다.
- `health` :  `http://localhost:8080/health`를 통해 CoreDNS 상태를 확인할 수 있다.
- `ready` : 준비 요청이 되어 있는지 확인하기 위해 포트 `http://localhost:8181/ready`로 HTTP 요청을 보니면 200 OK가 반환된다. 
- `kubenetes` : 쿠버네티스의 Service 도메인과 POD IP 기반으로 DNS 쿼리를 응답한다. `ttl` 설정으로 타임아웃을 제어할 수 있다.
	- `pods` 옵션은 POD IP를 기반으로 DNS 질의를 제어하기 위한 옵션이다. 기본값은 `disabled`이며, `insecure`값은 `kube-dns` 하위 호환성을 위해서 사용한다. 
	- `pods disabled`옵션을 설정하면 POD IP 기반 DNS 질의가 불가능하다. 예를 들어 `testbed` 네임스페이스에 있는 POD IP가 `10.244.2.16`라고 한다면,  `10-244-2-16.testbed.pod.cluster.local`질의에 A 레코드를 반환하지 않게 된다.
	- `pods insecure` 옵션은 같은 네임스페이스에 일치하는 POD IP가 있는 경우에만 A 레코드를 반환한다고 되어 있다. 하지만 간단하게 테스트 해보기 위해 다른 네임스페이스 상에 POD를 만들고 서로 호출했을 때 계속 통신이 되었다. 제대로 이해를 못했거나 테스트 방식이 잘못된 것인지 잘 모르겠다. ㅠㅠ
- `prometheus` : 지정한 포트(`:9153`)로 프로메테우스 포맷의 메트릭 정보를 확인할 수 있다. 위에서 다룬 `health`의 `:8080`포트나 `ready` 옵션의 `:8181`포트를 포함해서 CoreDNS로 HTTP 요청을 보내려면 CoreDNS Service 오브젝트 설정에 `:9153`, `:8080`, `:8181` 포트를 바인딩을 설정해야 한다. 


<br/>
## POD 안에서 도메인을 찾는 원리
`kubelet`은 POD를 실행할 때 `/etc/resolv.conf` 파일안에 CoreDNS 가리키는 IP 주소를 네임서버로 등록한다. `/etc/resolv.conf` 설정 파일은 DNS를 질의하는 클라이언트가 어디로 요청을 보낼지 판단하기 위한 용도로 사용된다. 

테스트용 POD를 만들어서 `/etc/resolv.conf` 파일을 확인해보자.
```
$ kubectl run -it --rm \
  busybox \
  --image=busybox \
  --restart=Never \
  -- cat /etc/resolv.conf
```

```
# /etc/resolv.conf

nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

`/etc/resolv.conf` 파일 내 구성 요소들의 의미는 아래와 같다.  

- `nameserver` : DNS 쿼리를 보낼 곳. CoreDNS Service 오브젝트의 IP 주소
- `search` : DNS에 질의할 부분 도메인 주소 경로들을 표시
- `ndots` : FQDN으로 취급될 도메인에 포함될 .(점)의 최소 개수

<br/>
## FQDN과 POD의 IP 알아내기
**FQDN** 이란 전체 도메인 이름을 의미한다. (예: 호스트명이 `www`, 도메인이 `jonnund.dev`일 때 FQDN은 `www.jonnung.dev`이 된다)   
DNS 서버는 보통 도메인 주소 마지막에 점(.)으로 끝나는 경우 FQDN으로 취급한다고 한다.

FQDN은 위에서 살펴 본 `/etc/resolv.conf` 설정에서 `options` 값에 있는 `ndots`과 관련이 있다. `ndots:5` 라는 의미는 도메인에 포함된 점(.)의 개수가 5개부터 FQDN으로 취급한다는 의미이다. 

만약 어떤 POD에서 `test.good.nice.awesome.jonnund.dev` 같은 도메인을 찾으려고 한다면, 이 도메인은 FQDN이기 때문에 클라이언트는`test.good.nice.awesome.jonnung.dev.`형태로 DNS 서버에 질의를 하게 된다.

하지만 `/etc/resolv.conf` 에서 중 한가지 더 고려해야 중요한 옵션이 있다.   
바로 `search` 옵션이다. 이 옵션에는 부분적인 도메인 목록들을 지정한다. 즉, 클라이언트가 DNS 서버로부터 결과가 없다는 응답을 받으면, 이 부분 도메인 목록을 차례대로 붙여가며 추가로 DNS 서버를 호출한다. 

예를 들어 `test.jonnung.dev`라는 실제로 존재하지 않는 도메인을 DNS 서버에 조회하면 총 4번의 요청이 전달될 수 있다.   
아래 결과는 실제 CoreDNS 서버에 남은 로그이다. (가독성을 위해 중간에 공백을 추가했음)
```
[INFO] 10.244.1.18:36652 - 7 "A IN test.jonnung.dev. udp 34 false 512" NXDOMAIN qr,rd,ra 118 0.198687028s
                   
[INFO] 10.244.1.18:47210 - 8 "A IN test.jonnung.dev.testbed.svc.cluster.local. udp 60 false 512" NXDOMAIN qr,aa,rd 153 0.000158582s

[INFO] 10.244.1.18:33116 - 9 "A IN test.jonnung.dev.svc.cluster.local.
 udp 52 false 512" NXDOMAIN qr,aa,rd 145 0.00014892s

[INFO] 10.244.1.18:59109 - 10 "A IN test.jonnung.dev.cluster.local. ud
p 48 false 512" NXDOMAIN qr,aa,rd 141 0.000122777s
```

이제야 제대로 이해되는 부분은 쿠버네티스 클러스터 상에서 `test-pod`라는 POD와 Service가 있을 때 `http://test-pod:8080/` 같이 HTTP 요청을 보냈을 때 목적지 IP를 찾을 수 있었던 원리는 바로 `search` 옵션 때문이라고 할 수 있다.

<br/>
## DNS 조회 요청을 줄여서 CoreDNS 부하를 줄이기
전 단락에서 알아본 것처럼 FQDN, `ndots`, `search` 옵션에 따라 클라이언트(또는 POD)에서 요청하는 DNS 조회 횟수가 달라질 수 있다.

이 원리를 이용해서 정확하게 FQDN을 조회할 수 있다면 DNS 조회 횟수를 줄일 수 있다.

예를 들어 `test.jonnun.dev` 같은 도메인을 찾는다고 한다면, 도메인 끝에 점(.)을 붙이지 않았더라도 요청하는 클라이언트가 자동으로 점(.)을 붙인 뒤 `test.jonnun.dev.`형태로 요청을 할 것 이다.   
하지만 실제로 저 도메인이 존재하지 않기 때문에 `search` 목록에 해당하는 `default.svc.cluster.local`, `svc.cluster.local`, `cluster.local`을 모두 붙여가며 추가로 DNS를 질의하게 된다.    

따라서 만약 조금이라도 CoreDNS 서버에 부하를 줄이고 싶다면, 외부 도메인을 호출할 때 마지막 점(.)을 추가하면 딱 1번만 DNS 서버에 질의할 수 있게 된다.   

<br/>
## 참고 자료
- [Customizing DNS Service - Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
- [DNS for Services and Pods - Kubernetes](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [DNS Lookups in Kubernetes - Karan Sharma](https://mrkaran.dev/posts/ndots-kubernetes/?utm_sq=gcoxtn2gb5)

