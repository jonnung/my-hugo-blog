---
comments: true
date: 2016-02-16T01:55:32Z
tags:
  - vagrant
categories:
  - system
title: Vagrant 에 ssh로 외부에서 접속하기
url: /vagrant/2016/02/16/vagrant_external_ssh/
---

Vagrant 로 실행한 VM 서버에 ssh key(pub)를 등록하더라도 ssh(vagrant ssh 아님)나 ansible로 접근할 수 없다.

외부 머신에서 접속하기 위해서는 ```vagrant share``` 를 통해 발급 받은 *{이름}* 과 *{비밀번호}* 를 받을 수 있다.
그리고 ```vagrant connect --ssh {이름}``` 와 같이 외부에서 실행하게 되면 원격접속이 가능하다. 

*{이름}*은 Vagrant VM측에서 ```vagrant share```를 실행하고 있는 동안만 유효하다.
