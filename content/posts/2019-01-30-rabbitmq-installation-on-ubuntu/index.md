---
comments: true
title: "Ubuntu 에서 RabbitMQ 설치하기"
date: 2019-01-30T11:50:00+09:00
tags:
  - rabbitmq
categories:
  - how-to
  - infra
url: /rabbitmq/2019/01/30/rabbitmq-installation-on-ubuntu/
description: RabbitMQ 서버를 설치하는 가이드 이며, 공식 사이트를 바탕으로 Ubutu 16.04 환경에서 설치
---
**RabbitMQ** 서버를 설치하는 가이드 이며, 공식 사이트를 바탕으로 Ubutu 16.04 환경에서 설치한다.

### Signing key
----
신뢰할 수 있는 최신 RabbitMQ 패키지를 설치하기 위해 repository에  signing key를 apt-key로 추가한다.

{{< highlight shell >}}
$ apt-key adv --keyserver "hkps.pool.sks-keyservers.net" --recv-keys "0x6B73A36E6026DFCA"
{{< /highlight >}}

<br>

### Source List File
----
RabbitMQ는 Erlang(얼랭)으로 개발 되었기 때문에 Erlang Package에 의존성을 갖는다.  
Erlang package와 RabbitMQ repository 위치를 `/etc/apt/sources.list.d` 폴더 하위에 저장한다.

{{< highlight shell >}}
$ sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
deb <https://dl.bintray.com/rabbitmq-erlang/debian> xenial erlang
deb <https://dl.bintray.com/rabbitmq/debian> xenial main
EOF
{{< /highlight >}}

<br>

### ⭑ Erlang Packages, RabbitMQ Server 설치하기
----
{{< highlight shell >}}
$ sudo apt-get update
$ sudo apt-get install rabbitmq-server
{{< /highlight >}}

<br>

### RabbitMQ Server 시작
----
{{< highlight shell >}}
$ service rabbitmq-server start
{{< /highlight >}}

<br>

### Management UI 플러그인 활성화
----
RabbitMQ는 Management 라는 UI 관리 도구를 제공한다. 
이 기능을 사용하기 위해서는 RabbitMQ Plugin을 활성화 시켜야 한다.

{{< highlight shell >}}
$ rabbitmq-plugins enable rabbitmq_management
{{< /highlight >}}

<br>

### Management UI 사용자 추가
----
Management UI를 사용하려면 로그인을 해야 하기 때문에 사용자를 추가해야 한다.

기본적으로 guest(비번도 guest) 라는 사용자를 제공하지만 localhost에서만 접속할 수 있다는 제한이 있다.

사용자를 추가한 후 `Tag`라는 것을 이용해서 Management 기능 사용에 대한 권한을 부여할 수 있다. Tag를 지정하지 않으면 Management를 사용할 수 없다.

Tag 종류는 공식 가이드([Management Plugin - Access and Permissions](https://www.rabbitmq.com/management.html#permissions))에서 더 확인 할 수 있고, 아래에서는 관리자('administrator') 권한을 사용했다.

{{< highlight shell >}}
# 사용자 목록
$ rabbitmqctl list_users
    
# 사용자 추가
$ rabbitmqctl add_user ewcho 'ewchorabbit'
    
# 사용자 태그 추가
$ rabbitmqctl set_user_tags ewcho administrator
{{< /highlight >}}


<br>

### 포트 설정
----
RabbitMQ는 클라이언트와 CLI Tool 연결을 위해 몇가지 포트를 사용한다.

따라서 방화벽을 사용하고 있다면 아래 포트를 열어줘야 한다.

- 4369 : [epmd](http://erlang.org/doc/man/epmd.html), 여러 rabbitmq 서버끼리 서로를 찾을 수 있는 네임 서버 역할을 하는 데몬에서 사용
- 5672, 5671 : [AMQP](https://ko.wikipedia.org/wiki/AMQP) 를 사용한 메시지 전달
- 25672 : inter-node 와 CLI Tool 연결
- 15672 : HTTP API, Management UI

<br>

### Virtual Hosts
----
RabbitMQ 는 connection, exchange, queue, binding, user, policy 들을 **virtual hosts** 를 통해 논리적인 그룹으로 분리해서 운영할 수 있다. Apache의 virtual hosts 와 Nginx의 server 블록과 유사한 개념이다.

RabbitMQ 는 vhost 단위로 자원에 대한 권한을 갖는다. 따라서 사용자는 전체 권한을 갖을 수 없고 하나 이상의 vhost 단위로 권한을 부여 받는다.

vhost 마다 이름이 지정되고, 클라이언트는 지정한 vhost 에 대한 연결을 맺는다. 이 연결을 통해 오직 해당 vhost의 exchange, queue, binding 만 접근할 수 있게 된다.

<br>

### vhost 만들기
----
CLI 또는 HTTP API를 통해 만들 수 있다.

{{< highlight shell >}}
# CLI Tool 사용
$ rabbitmqctl add_vhost dev1
{{< /highlight >}}

<br>

### 사용자에게 vhost 에 접근할 수 있도록 권한 주기
----
새로운 vhost는 기본 exchange가 설정되지만 다른 구성 요소나 사용자는 없는 상태이다.
특정 사용자가 새로운 vhost 에 접속하기 위해서는 권한을 설정해야 한다.

{{< highlight shell >}}
# set_permissions [-p vhost] user conf write read
$ rabbitmqctl set_permissions -p dev1 admin29cm ".*" ".*" ".*"
{{< /highlight >}}


<br>

### 로그 관리
----
보통 `/var/log/rabbitmq` 경로에 로그가 남는다. 

그리고 로그 파일 로테이션을 위해 `logrotate` 를 사용해서 일주일 단위로 로테이션 되도록 설정된다. 이 설정은 `/etc/logrotate.d/rabbitmq-server` 에서 확인하고 변경할 수 있다. 

<br>

### 참고
----
- [Installing on Debian and Ubuntu — RabbitMQ](https://www.rabbitmq.com/install-debian.html#package-dependencies)
- [Management Plugin](https://www.rabbitmq.com/management.html)
- [Virtual Hosts](https://www.rabbitmq.com/vhosts.html)
- [rabbitmqctl](https://www.rabbitmq.com/rabbitmqctl.8.html)
