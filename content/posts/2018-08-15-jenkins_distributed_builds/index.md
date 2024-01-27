---
comments: true
title: "젠킨스 Master/Slave 분산 빌드 환경 구축하기"
date: 2018-08-15T14:49:03+09:00
tags:
  - devops
  - jenkins
categories:
  - devops
url: /devops/2018/08/15/jenkins-distributed-builds/
---

### **1. Master + (Slave) Agent**
- Jenkins 는 보통 모든 작업을 수행할 수 있는 단일 Master로 구성한다.
- 작업 부하를 분산하기 위해 Master + (Slave) Agent 구성도 가능하다.
- Master 는 프로젝트(작업)을 등록하고, 관리하기 위한 GUI와 API를 제공하고, Agent는 작업 실행만 담당하게 된다.
- Agent를 사용하는 이유에는 Master가 실행중이지 않은 다른 보안 환경에서 작업을 수행하거나 배포하기 위함도 있다.

</br>

### **2. Master/Agent 구성 방법**
#### Master 에서 Agent 연결하기
- 먼저 Master가 Agent가 실행되고 있는 네트워크상에 접근할 수 있어야 한다.
- 일반적으로 SSH를 통해 접근하는 방식을 많이 사용한다.

#### Agent 에서 Master 연결하기
- Master에서 Agent 가 있는 네트워크에 접근할 수 없는 경우  `JNLP` 라는 agent 구성을 사용할 수 있다.
- Agent가 방화벽 뒤에 있거나 Master가 접근할 수 없는 안전한 보안 환경에 배포해야 되는 경우에 유용하다.

#### Agent 의 Label 로 Pipeline과 선택 빌드에서 활용
- Agent 에 Label을 붙이면, 용도와 실행 환경을 명시적으로 구분할 수 있고, pipeline 이나 build 실행시 Label을 이용해서 지정한 Agent 로 작업을 실행 시킬 수 있다.

</br>

### **3. Agent 실행하는 방법**
#### Master 노드에서 Agent로 원격 접속
1. SSH
	- Master 에서 SSH를 이용해 Agent 노드로 접속 후 필요한 바이너리를 복사하고, Agent 실행과 중단 및 작업을 수행한다.
2. Windows Agent
	- Windows 환경의 Agent 경우 Windows에 내장된 원격 관리 기능([WMI](https://ko.wikipedia.org/wiki/%EC%9C%88%EB%8F%84%EC%9A%B0_%EA%B4%80%EB%A6%AC_%EB%8F%84%EA%B5%AC) + [DCOM](https://ko.wikipedia.org/wiki/%EB%B6%84%EC%82%B0_%EC%BB%B4%ED%8F%AC%EB%84%8C%ED%8A%B8_%EC%98%A4%EB%B8%8C%EC%A0%9D%ED%8A%B8_%EB%AA%A8%EB%8D%B8)) 을 사용해서 Windows Agent 노드를 원격 제어한다.
3. 스크립트 작성
	- Agent 를 연결해야 할 때마다 Master 에 작성해 둔 스크립트를 실행한다. 
	- 스크립트에서는 원격으로 Agent를 연결하기 위한 다양한 도구를 사용할 수 있다.(예: SSH)
	- 스크립트를 통해 원격에 있는 `agent.jar`를 실행하고, 스크립트의 stdin/stdout 을 Agent의 stdin/stdout 과 연결해야 한다.

#### JNLP를 이용해 Agent 실행
> Agent를 실행하기 전에 Jenkins Master 노드 [Jenkins 관리]에서 JNLP 로 TCP 통신을 위한 포트를 지정한다.  
> (_Jenkins -> Global Security -> TCP port for JNLP agents_)  

![jenkins_distributed_builds_jnlp_settings](/images/jenkins_distributed_builds_jnlp_settings.png)

1. Browser
	- Agent 노드의 브라우저를 통해 Jenkins(Master)에 접속한 뒤 Agent 노드 설정 페이지에 접근해서 JNLP 실행을 위한 `Launch` 버튼을 클릭 후 다운로드 된 JNLP 파일을 실행
	- 이 방법은 Master 가 보안 환경의 Agent 로 접근할 수 없을 때 유용하다.
2. Headless
	- 위 Browser 를 통해 실행하는 방식과 거의 유사하다.
	- CLI 환경에서 데몬으로 Agent 를 JNLP 모드로 실행한다.

	```
	$ java -jar agent.jar -jnlpUrl http://yourserver:port/computer/agent-name/slave-agent.jnlp
	```

![jenkins_distributed_builds_slave01](/images/jenkins_distributed_builds_slave01.png)

</br>

### 참고
- [Distributed builds](https://wiki.jenkins.io/display/JENKINS/Distributed+builds)
