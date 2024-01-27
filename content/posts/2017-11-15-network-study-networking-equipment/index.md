---
comments: true
title: "[네트워킹 기초 공부] 네트워크 장비들 - 허브(Hub), 브릿지(Bridge), 스위치(Switch), 라우터(Router)"
date: 2017-11-15T06:00:17+09:00
tags:
  - network
categories:
  - system
url: /network/2017/11/15/network-study-networking-equipments/
---
![network equipment](/images/network-cable-ethernet-computer.jpeg)
## 허브 (Hub)
* 여러개의 포트를 갖고 있으며, 들어온 데이터를 그대로 재전송 하는 단순한 역할
* UTP 케이블의 경우 최대 전송거리가 약 100미터, 멀리 떨어진 장비간의 통신을 전달할 수 있음
* 이더넷 허브는 [CSMA/CD](https://ko.wikipedia.org/wiki/%EB%B0%98%EC%86%A1%ED%8C%8C_%EA%B0%90%EC%A7%80_%EB%8B%A4%EC%A4%91_%EC%A0%91%EC%86%8D_%EB%B0%8F_%EC%B6%A9%EB%8F%8C_%ED%83%90%EC%A7%80)(Carrier Sense Multiple Access / Collision Detection) 을 적용 받기 때문에 하나의 콜리진 도메인(Collision Domain) 안에 있게 된다. 따라서 어느 한순간 한 PC만이 데이터를 전송할 수 있음
* 여러대의 허브를 서로 연결하면 콜리전 도메인이 더욱 커지게 된다. 콜리전 도메인을 나누어 줄 수 있는 장비로는 브릿지와 스위치가 있음

## 브릿지 (Bridge)
* 스위치가 나오기 전까지는 브릿지가 주로 사용됨
* 허브로 만들어진 콜리전 도메인 중간에서 다리 역할을 함
* 브릿지로 나누어진 콜리전 도메인(세그먼트)마다 속해 있는 PC들끼리는 각각 통신이 가능(물론 CSMA/CD도 적용)
* 브릿지(스위치) 세부 기능
	* *Learning*: 브릿지(스위치)로 전송된 통신 프레임의 맥(MAC) 어드레스를 맥 어드레스 테이블(브릿지 테이블)에 저장
	* *Flooding*:  맥 어드레스 테이블에 없는 주소라면 들어온 포트를 제외한 나머지를 모든 포트로 전송
	*  *Forwarding*: 브릿지가 목적지 맥 어드레스를 자신의 맥 어드레스 테이블에 가지고 있고, 이 목적지가 출발지 맥 어드레이스와 다른 세그먼트에 있는 경우. Flooding 과 다르게 오직 해당 포트로만 프레임을 전송
	* *Filtering*: 브릿지가 목적지 맥 어드레스를 알고 있고, 출발지와 목적지가 같은 세그먼트 상에 있다면 다른 세그먼트로 프레임을 전송하지 못하도록 막는 기능. _이 기능 덕분에 콜리전 도메인을 나눌 수 있음_
	* *Aging*: 맥 어드레스 테이블에 저장하는 기간

## 스위치 (Switch)
* 브릿지와 동일하게 데이터 링크 레이어(Data Link Layer)에 해당
* 처리 방식이 하드웨어로 이루어지기 때문에 소프트웨어적으로 프레임을 처리하는 브릿지에 비해 빠름
* 처리 절차를 미리 칩에 구워서 하드웨어 방식으로 만드는 [ASIC](https://ko.wikipedia.org/wiki/%EC%A3%BC%EB%AC%B8%ED%98%95_%EB%B0%98%EB%8F%84%EC%B2%B4)(Application Specific Integrated Circuit) 방식
* 스패닝 트리 알고리즘(Spanning Tree Algorithm)이 적용되어 루핑을 예방

## 라우터 (Router)
* 스위치보다...
	* 고가의 장비
	* 처리하는 일이 많아 상대적으로 느림
	* 라우팅 프로토콜이나 네트워크 설정을 해야하는 등등 구성이 복잡함
* 브로드캐스트 도메인을 나누기 위한 목적
* 한 브로드캐스트 도메인 안에 있는 노드들은 라우터 없이도 통신이 가능
* IP 주소 중에 네트워크 부분만이 라우터가 라우팅을 할 때 참고
