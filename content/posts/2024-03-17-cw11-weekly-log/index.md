---
title: "2024 Weekly #11 Log"
date: 2024-03-17T19:12:00+09:00
image: /images/common/weekly-log-cover.webp
tags:
  - weekly-log
categories:
  - weekly log
description: 지난 2024년 2월에 Kafka Streams(ksqlDB)를 활용한 이벤트 기반의 알림 시스템을 개발했는데 다른 회사에서 Kafka를 어떻게 활용하고 있을지 궁금했습니다. 
url: /weekly-log/2024/03/17/2024-cw11/
---

# Pocket Pick
### [리디에서 Kafka를 사용하는 법 (내부 API 활용에서 Kafka 기반으로)](https://ridicorp.com/story/how-to-use-kafka-in-ridi)
- 실시간 랭킹을 집계하기 위해 API 호출 방식을 사용했었는데 Kafka를 통한 이벤트 수집 방식으로 변경
- Kafka Topic에 수집된 감상 데이터(이벤트)는 다른 서비스에서도 활용할 수 있게 됨
- 통계, 메시지큐, 다양한 이벤트(프로모션)의 실시간 처리 등에 활용하고 있음
- Kafka 메시지 포맷으로 [CloudEvents](https://cloudevents.io/) [^1]를 사용하고 있음

### [광고 정산 시스템에 Kafka Streams 도입하기](https://www.bucketplace.com/post/2022-05-20-%EA%B4%91%EA%B3%A0-%EC%A0%95%EC%82%B0-%EC%8B%9C%EC%8A%A4%ED%85%9C%EC%97%90-kafka-streams-%EB%8F%84%EC%9E%85%ED%95%98%EA%B8%B0)
- '오늘의집'이 CPC 광고 시스템을 도입하면서 예산 충전과 클릭당 차감을 실시간으로 처리하고, 중복 처리를 방지하기 위해 Kafka Streams를 도입하게 된 사례
- 문제점: 모든 클릭 요청은 Kafka Topic의 메시지로 들어오게 된다. Kafka와 RDB만으로 설계했을 경우, 정산 처리 단계 중 클릭에 따른 예산 차감이 실패하게 되었을 때 Topic offset이 commit되지 않았다면, 재시도 로직에서 예산 차감이 중복될 수 있다.
- 개선 방향1: RDB 테이블에 예산 차감 히스토리 목적으로 Topic offset을 저장해서 Consumer가 처리할 현재 Offset보다 높은 경우, 처리하지 않고 Offset을 Commit하는 방법
    - 단점1: 정산 처리 비즈니스 로직과 중복 처리 방지 로직이 함께 구현되어 복잡성 증가
    - 단점2: 모든 클릭 로그를 저장해야 하기 때문에 RDB 부하가 발생할 수 있다.
- 개선 방향2: Kafka Streams (클라이언트 라이브러리)로 exactly-once 처리하기
    - 제약 사항: RDB 같은 외부 연동이 포함된 경우, exactly-once를 보장하지 못 한다.
    - 해결: in-memory DB(state store) 활용
        - 정산처리 애플리케이션 안에 Kafka Streams 구현과 in-memory DB를 포함하고 있게 된다. 
        - 애플리케이션이 재시작될 경우 in-memory DB의 데이터가 사라지는 것을 복구하기 위해 in-memory DB에 저장되는 모든 데이터를 Kafka topic으로 전송. 애플리케이션이 재시작될 때 이 Topic에서 메시지를 읽어와 마지막 데이터 상태를 유지
        - in-memory DB에 저장될 데이터를 Topic에 전송하는 것과 클릭 로그 Topic offset을 commit하는 작업이 Atomic함을 보장하기 위해 Kafka Transaction을 활용
    - 예산 차감 처리 내역을 별도 Topic에 저장하고, 이 메시지를 Kafka Connect를 통해 S3로 저장. Apache Spark으로 일별 통계 계산 후 RDB 저장
- 결론
    - 장점
        - Kafka Streams의 exactly-once 기능 덕분에 비즈니스 로직에만 집중할 수 있다.
        - in-memory DB를 활용하기 때문에 빠르다. (예: 예산 조회)
        - 처리량 부하에 따라 스케일 아웃이 용이하다.
    - 단점
        - 새로운 것에 대한 거부감? 
            - (내 생각) Kafka Streams가 어려워서?

[^1]:  `CloudEvents` 는 공통된 방식으로 이벤트 데이터의 구조를 잡기 위한 명세

---
# Tech Video
### INFCON 2023 - EKS 비용 절감 전략 (회사에서 실현한 사이드 프로젝트의 아이디어)
{{< youtube UGT0HHx4Hl4 >}}
- 핵심 아이디어
    - 스팟 인스턴스 사용 + 적절한 노드 선택
    - 적절한 컨테이너 리소스 할당
    - 필요한 시간에만 클러스터 운영
    - 의도하지 않은 실수를 차단할 수 있는 시스템
- 스팟 인스턴스 사용 + 적절한 노드 선택
    - Karpenter
        - 클러스터 오토스케일링 도구
        - 파드의 정의된 리소스에 따라 노드 선택 가능
        - 스팟 / 온디맨드 타입 지정해서 프로비저닝 가능
        - 특정 노드의 모든 파드가 다른 노드로 이동할 수 있다면 특정 노드를 종료 
        - 노드 사용량 볼때 좋은 도구
            - https://github.com/awslabs/eks-node-viewer
- 적절한 컨테이너 리소스 설정
    - Kubecost
        - 적절한 리소스 설정 - kubecost rightsize recommend 사용
        - 비용 예측 방법 - kubecost cost predict 사용
- 필요한 시간에만 클러스터 운영
    - Cronjob
    - Botkube - 클러스터 이벤트를 실시간 모니터링 및 알림 전송?
        - Slack 메시지로 kubectl 명령어를 전송하고, 결과(stdout)을 메시지 창에 표시해줌
- 의도하지 않은 실수를 차단할 수 있는 시스템 - OPA (Open Policy Agent) Gatekeeper
    - PaC (Policy as a Code) : 정책을 코드로 만든다.
        - 예: Replica 개수 제한, POD 리소스 제한, StorageClass를 gp3로 제한
- 그밖에
    - 짧은 시간동안 많은 트래픽이 예상되는 경우, 미리 노드를 프로비저닝
        - Kapenter는 비용, 리소스 최적화 컨셉에는 맞지만, 오버 프로비저닝이 필요한 상황에서는 대응하기 어렵다.
        - KEDA(Kubernetes Event Driven Autoscaler)

### 토스 SLASH23 - Kafka 이중화로 다양한 장애 상황 완벽 대처하기
{{< youtube Pzkioe7Dvo4 >}}
- Producer --> Cluster --> Consumer
    - Produce
        - 한국/미국 체결가, 호가, 거래소 정보
        - 토스 코어, 토스 뱅크
        - 한국, 미국 언론사 뉴스 수신
        - Client, Server, System Log
        - DB CDC
    - Broker
        - --> ksqlDB 적극 활용 중 (오...)
    - Consumer
        - Service Server
        - MySQL
        - Hadoop
        - ES
        - KUDU??
        - Redis
        - 토스 코어, 토스 뱅크
- 장애 상황의 구분
    - 카프카 클러스터 일부 노드 장애
        - 분산 형태라 운영에 심각한 문제가 발생하지 않을 수 있음
    - IDC 전면 장애 
        - 심각한 상황
        - 다른 IDC에 Disaster Recovery(DR) 시스템을 구축해야 한다.
            - 보통 Active - Standby 구성을 하며, Standby는 잘 관리가 안 되면 실제 장애 상황에서 기대한 것처럼 Active가 안 될 수도 있다.
            - Active - Active 구성을 지향!!
- 위 두가지 상황을 이겨내기 위해 이중화를 해야 한다!
    - Kafka는 Stateful한 시스템은 이중화 구성이 어렵다.
    - IDC 두 곳을 유저 트래픽의 50%씩 나눠서 Active-Active 구성을 유지한다.
    - 두 IDC로 반반씩 나눠진 메시지는 Kafka Connect를 사용해서 실시간 미러링
    - Offset Sync라는 데몬으로 Consumer Group Offset을 싱크
        - 단, Consumer 그룹은 한 쪽 IDC의 Broker로만 연결하여 중복처리를 방지한다.
        - Offset은 클러스터가 다르면 번호체계가 달라지기 때문에 중간에 상대쪽 IDC에 맞는 번호로 변경해야 한다는 점이 중요
- 이중화 클러스터 관리하기
    - 클러스터의 모든 메트릭을 Prometheus로 수집하여, Thanos Ruler를 이용해서 정의한 조건이 충족되면 알림
    - 클러스터의 모든 로그는 ElasticSearch로 실시간 수집, ElasticAlert로 알림
    - 시계열 데이터의 이상 징후 탐지하는 ML 모델도 개발 중

---

# Starred Github Repo
- [gum](https://github.com/charmbracelet/gum)
  - 반복적이고 패턴화된 터미널 작업을 하나의 Shell Script로 만들어서 사용할 때 일반적으로 위치/키워드 파라미터 등으로 동작을 분기하게 되는데 Gum을 사용하면 TUI 상에서 Interactive 하게 만들 수 있다. 
  - 블로그의 새 글을 등록할 때 `hugo new ...`부터 시작하여 여러 메타데이터를 수동으로 바꾸는 일이 많은데 gum으로 하나 만들어두면 좋을 것 같다.  
  ![](https://camo.githubusercontent.com/43b2c2e06b97b0ead420caecf4cc2eabb4c586063fabf96435b060919bce6186/68747470733a2f2f73747566662e636861726d2e73682f67756d2f64656d6f2e676966)
- [mise](https://github.com/jdx/mise)
  - [asdf](https://github.com/asdf-vm/asdf) 비슷한 개발 도구(예: Python, Node.js)의 버전 관리할 수 있다. 
  - `make` 또는 `npm script` 같은 Task runner로도 기능도 제공한다. 
  - asdf를 몇 년째 잘 쓰고 있는데 딱히 넘어갈 만한 이유는 없을 것 같다. 

