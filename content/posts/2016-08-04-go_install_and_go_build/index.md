---
comments: true
date: 2016-08-04T23:01:26Z
tags:
  - go
categories:
  - golang
title: Golang - go install 과 go build 의 차이
url: /golang/2016/08/04/go_install_and_go_build/
---

# go install
- main.go 은 Compile 되어 (OS 에 맞는) 실행 파일이 ```$GOBIN ($GOPATH/bin)``` 위치에 생성된다.
- 라이브러리 파일(non-main)일 경우 ```$GOPATH/pkg``` 디렉토리에 _파일명.a_ 형태로 Complie 된 결과가 생성되며, 다음 Build 시 Cache로 사용되어 변경된 부분만 Complie 된다.

# go build
- main.go 을 Compile 하여 실행 가능한 파일을 현재 Build 명령을 실행한 디렉토리 위치에 생성한다.

## 참고
[https://www.quora.com/What-is-the-difference-between-build-and-install-in-Go](https://www.quora.com/What-is-the-difference-between-build-and-install-in-Go)
