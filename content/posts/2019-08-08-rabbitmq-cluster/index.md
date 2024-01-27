---
title: "RabbitMQ 클러스터 구성하기"
date: 2019-08-08T22:30:00+09:00
draft: false
toc: false
image: "/images/posts/rabbitmq_twin.png"
tags:
  - rabbitmq
categories:
  - infra
  - system
url: /rabbitmq/2019/08/08/rabbitmq-cluster/
description: RabbitMQ를 클러스터로 구성하고, HA(고가용성)를 위한 Mirroring(미러링) 설정하는 방법을 설명 합니다.
---

RabbitMQ를 클러스터로 구성하는 방법은 아래 3가지가 존재한다.

1. config file 에 클러스터 노드 목록을 정의
2. `rabbitmqctl` CLI 툴을 이용한 수동 구성
3. 기타 AWS, K8S 기반의 노드 디스커버리 방식 등등

여기서 우리는 2번 방법을 통해 클러스터를 구성할 것이다.

<br/>

## 클러스터 요구 사항

- 클러스터 안에 모든 노드는 `hostname`으로 서로 찾을 수 있어야 한다.
- `hostname`을 찾기 위해서는 OS 표준으로 제공하는 DNS Records 나 `/etc/hosts` 파일을 이용하면 된다.
- 사용할 포트 (적절히 방화벽을 열어둘 것)
    - 4369 : 노드를 찾기 위해 사용됨
    - 25672: inter-node와 CLI 통신을 위해 사용
    - 5672, 5671 : AMQP
    - 15672 : HTTP API, Management UI
    - 그밖에 더...

<br/>

## 클러스터 노드
RabbitMQ가 운영되는데 필요한 모든 데이터와 state는 클러스터 내 모든 노드에 복제된다.  
하지만 **Message Queue** 자체는 복제되지 않는다. 메시지 큐는 각 노드에만 존재하게 되지만 클러스터 내의 어떤 노드로 접근하던 다른 노트의 메시지 큐를 볼 수 있고, 읽을 수 있다.  
만약 모든 노드의 메시지 큐를 복제 하려면 HA 구성을 해야 한다.

<br/>

## Erlang 쿠키 맞추기

모든 노드는 서로 통신하기 위해서 **Erlang cookie**라는 비밀 키를 공유해야 한다.  
Unix 시스템에서는 보통 `/var/lib/rabbitmq/.erlang.cookie` 에 존재한다. 이 Erlang cookie를 클러스터로 구성하려는 노드 중 하나를 기준으로 통일한다. (복붙하면 됨)  
그리고 RabbitMQ 재시작!
```bash
$ systemctl restart rabbitmq-server
```

<br/>

## 클러스터 구성하기

`dev-rabbit001`과 `dev-rabbit002` 2대의 RabbitMQ 노드가 있다고 가정하자.   
그리고 `rabbit@dev-rabbit002` 노드에서 `rabbit@dev-rabbit001` 방향으로 클러스터에 참여하는 형태로 진행한다.
단, 이 때 각 노드들은 4369, 25672 포트로 서로 TCP 연결이 가능한 상태여야 한다.
```bash
# 노드 중지
$ rabbitmqctl stop_app

# 노드 다시 세팅
$ rabbitmqctl reset

# 클러스터 조인
$ rabbitmqctl join_cluster rabbit@dev-rabbit001

# 노드 시작
$ rabbitmqctl start_app

# 클러스터 상태 확인
$ rabbitmqctl cluster_status
```

<br/>

## 클러스터 노드 타입 변경

RabbitMQ 노드는 **RAM**과 **disc**, 2가지 타입을 갖는다.
RAM 타입은 모든 메타 정보를 메모리에 저장한다. disc 보다 성능이 좋지만 해당 노드에 문제가 생겼을 때 데이터가 유실될 수 있다. 
반대로 disc 타입은 데이터를 디스크에 저장한다.

RabbitMQ는 클러스터 내 모든 노드를 RAM 타입을 구성하는 것을 제한한다. 반드시 1개 이상의 disc 타입의 노드를 포함해야 한다.

위에서 이미 클러스터 구성을 마친 노드에 대해 RAM 타입으로 변환하는 과정이다.
```bash
# dev-rabbitmq001 기준
# 노드 중지
$ rabbitmqctl stop_app

# 노드 타입 변경
$ rabbitmqctl change_cluster_node_type ram

# 노드 시작
$ rabbitmqctl start_app
```

클러스터에 들어갈 때 노드 타입을 지정할 수도 있다.
```bash
# dev-rabbitmq002 가 dev-rabbit001 로 클러스터 구성을 요청
# 노드 중지
$ rabbitmqctl stop_app

# 클러스터 조인
$ rabbitmqctl join_cluster --ram rabbit@dev-rabbit001

# 노드 시작
$ rabbitmqctl start_app
```

<br/>

## 미러링(Mirroring) 구성

기본적으로 **Message Queue** 데이터는 클러스터 내 노드에 각각 존재한다. 

즉, 모든 노드에서 다른 노드의 **Exchange**와 **Binding** 같은 내용은 공유 되지만 Queue는 각각 가지고 있는 상태이다. 만약 특정 노드가 다운 되면, 해당 노드의 데이터는 유실 될 수 있다.

고가용성을 위해서 Mirroring 옵션을 통해 Queue가 모든 노드에 서로 복제되어 저장될 수 있도록 구성할 수 있다. 

미러링(Mirroring) 설정은 하나의 마스터와 여러 미러(Mirror) 노드로 구성된다. 모든 요청은 마스터 노드가 우선 처리하고, 미러 노드로 전파된다.  
마스터에 메시지가 전달되면 모든 미러 노드로 복제된다. 그리고 **Consumer**는 마스터 노드와 관계없이 모든 노드를 통해 메시지를 가져올 수 있다. 미러 노드에서 메시지를 가져온 경우에 미러 노드는 마스터에게 이 사실을 전달한다.

미러링은 정책(Policy)을 이용해서 설정할 수 있다.

<br/>

## 미러링 정책 설정

- 클러스터 모든 노드의 Queue를 미러링하기
```bash
$ rabbitmqctl set_policy ha-all "^ha\\." '{"ha-mode":"all"}'
```

- 지정한 개수의 리플리카만 생성
```bash
$ rabbitmqctl set_policy ha-two "^two\\." '{"ha-mode":"exactly", "ha-params": 2, "ha-sync-mode": "automatic"}'
```

- 지정한 이름의 노드만 미러링
```bash
$ rabbitmqctl set_policy ha-nodes "^nodes\\." '{"ha-mode": "nodes", "ha-params": ["rabbit@nodeA", "rabbit@nodeB"]}'
```

<br/>

## 참고 자료
- [Clustering Guide — RabbitMQ](https://www.rabbitmq.com/clustering.html)
- [http://thebluecheese.tistory.com/22](http://thebluecheese.tistory.com/22)
- [RabbitMQ Clustering 구성하기 – nurigo – Medium](https://medium.com/nurigo/rabbitmq-clustering-%EA%B5%AC%EC%84%B1%ED%95%98%EA%B8%B0-d34cc785d742)
- [http://abh0518.net/tok/?p=411](http://abh0518.net/tok/?p=411)
- [rabbitmqctl(8) — RabbitMQ](https://www.rabbitmq.com/rabbitmqctl.8.html)
