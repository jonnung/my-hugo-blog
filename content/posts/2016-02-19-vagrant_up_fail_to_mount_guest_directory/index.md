---
comments: true
date: 2016-02-19T11:12:52Z
tags:
  - vagrant
categories:
  - system
title: Vagrant 실행시 공유 폴더가 마운트 되지 않는 오류
url: /vagrant/2016/02/19/vagrant_up_fail_to_mount_guest_directory/
---

어제까지 잘 되던 ```vagrant up``` 에서 공유 폴더를 마운트하지 못하는 오류가 발생 했다.  
검색을 해보니까 동일한 문제를 겪고 있는 사람들이 꽤 많았는데 Virtualbox 문제인 것 같기도 하고..  
정확히는 모르겠다.

[https://github.com/mitchellh/vagrant/issues/1657](https://github.com/mitchellh/vagrant/issues/1657)

![vagrant_isssue_1657_screenshot](/public/image/github_vagrant_issue_1657_comments.png "vagrant_isssue_1657_screenshot")

아무튼 위에 github issue (closed) 에서 ```vagrant-vbguest``` 라는 Vagrant 플러그인을 설치하면, guest 시스템에 Virtualbox Guest Additions 을 자동으로 설치해준다고 한다.  
사실 이것도 뭔지 모르겠지만 일단은 문제 해결이 우선이라 이 플러그인으로 마운트 문제는 해결 했다.
