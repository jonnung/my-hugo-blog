---
comments: true
date: 2016-02-17T02:05:09Z
tags:
  - vagrant
categories:
  - system
title: 통합 개발환경 구축을 위한 Vagrant와 프로비저닝 (1)
url: /vagrant/2016/02/17/vagrant_provisioning_1/
---

__Vagrant__ 를 이용해 개발자간의 로컬 개발환경 차이를 극복하는 통합 개발환경을 만드는 것이 목표이다.  

이런 고민은 Windows와 Mac 환경에서의 __APM(Apache, PHP, MySQL)__ 세팅에서 비롯 되었는데 통합 개발환경 구축은 프로덕션 환경과 개발환경의 차이를 최소화해서 발생할 수 있는 위험요소를 최소화하는 것이 목적인 것이다. 

여기서 고민하게 된 것은 각각의 로컬환경에서 구동되는 Vagrant의 프로비저닝이다.  
shell 보다 __Ansible__ 을 이용해서 Vagrant 가상 머신의 프로비저닝을 진행하는 것이 당연히 좋겠지만 Windows 환경에서는 불편한 부분이 있다. (Ansible은 1.7 버전부터 Windows 환경을 지원하게 되었다.)  

당연히 Windows 에서도 파이썬을 설치하고, pip를 이용해서 Ansible도 설치 할 수 있다. 하지만 Ansible은 SSH를 기반으로 각 서버에 접근하기 때문에 이것을 대신해서 __Powershell__ 을 사용 해야하고, 추가적인 모듈들도 필요할 수 있다.(ex: winrm)  

위와 같이 하는 것은 어렵다기보다 2중으로 관리 해야한다는 측면에서 비효율적으로 느껴진다. 
