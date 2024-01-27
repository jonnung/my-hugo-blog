---
title: "세 번째 배우는 Go - 파트 1: 설치와 패키지 관리"
date: 2021-12-12T17:51:15+09:00
draft: false
toc: false
image: "/images/posts/gopher.png"
tags:
  - go
  - golang
categories:
  - golang
description: Go 컴파일러를 설치하는 평범하지? 않은 방법을 소개하고, Go의 패키지 의존성 관리 방법과 원리를 알아본다. 
url: /go/2021/12/12/go-installation-package-management/
---

Go 언어를 다시 공부하는 게 벌써 세 번째다. 2017년, 2019년 그리고 2021년...(왜 2년마다?)  
내가 새로운 언어를 배워야겠다고 결심하게 된 첫 번째 이유은 익숙해진 것에서 벗어나 다른 관점으로 생각하는 힘을 기르기 위함이고, 두 번째는 지금보다 더 나은 대안이 될 수 있다는 기대감. 마지막 이유는 재미다.(재밌다고 믿고 싶을 때도 있지만...)   
아무튼 세 번째 만나는 Go가 내 손에 익은 도구가 되길 바라며 시작해본다.  

<br/>

## Go 컴파일러 설치하기
보통 Go를 설치하는 방법은 미리 컴파일된 바이너리 패키지를 다운받는 것이다.  
특별한 이유가 없는 한 굳이 소스 코드로 Go를 컴파일할 필요는 없으니까...  

<br/>

### MacOS에서 Go 설치하기
Homebrew는 MacOS의 패키지 매니저로 잘 알려져 있다.  
https://go.dev 웹 사이트에서는 pkg installer를 직접 다운로드받는 식으로 안내하고 있지만,  MacOS를 쓴다면 여러 가지 프로그램들은 Homebrew로 설치하고 통합 관리하는 것이 맘 편하다고 생각한다. (지울 때 생각하면 이해됨)  

Homebrew로 Go를 설치하는 명령어는 다음과 같다. (참고: [go — Homebrew Formulae](https://formulae.brew.sh/formula/go))  

```bash
brew install go
```

하지만 난 좀 특이하게(?) 개발 환경과 관련된 프로그램들은 **[asdf](https://github.com/asdf-vm/asdf)** 라는 패키지 관리 도구로 설치하고 있다.  
근본적인 이유는 위에서 Homebrew를 설명할 때와 같다. 즉, 관리의 용이성.  
또 다른 이유는 asdf 사용법이 간단하고 직관적이라는 것도 장점이 될 수 있겠다.  
물론 asdf에서 지원하지 않는 프로그램도 존재하지만, 그래도 대부분은 asdf로 설치하고 없는 경우에만 Homebrew로 설치한다.  

<br/>

### [취향에 따라] asdf로 Go 설치하기
> [asdf를 설치](http://asdf-vm.com/)하는 과정은 생략한다.  

asdf에서 go(golang)를 지원하는지 확인한다.  

```bash
asdf plugin list all |grep golang
```

위 명령어 결과에서 `golang`이라는 이름으로 Go 플러그인이 존재하는 것을 확인할 수 있다.
그럼 asdf에 `golang` 플러그인을 추가해보자.  
하지만 이때 바로 설치되는 것은 아니다. 설치할 플러그인의 저장소를 추가 해 놓는 정도라고 볼 수 있다.  

```bash
asdf plugin add golang
```

이제 `golang` 플러그인에서 설치할 수 있는 모든 버전 목록을 확인한다.  

```bash
asdf list all golang
```

현재 가장 최신 버전(1.17.3)을 설치한다. (2021년 11월을 기준)  

```bash
asdf install golang 1.17.3
```

설치가 끝났다고 해서 모두 끝난 것이 아니다.  
현재 터미널에서 `go version`을 쳐보면 아마 _'go 커맨드를 사용하기 위한 버전이 명시되지 않았다(No version set for command go)'_ 는 메시지가 보일 것이다.   
즉, 어떤 명령어를 실행할 때 `$PATH` 변수에 실제 바이너리 파일 위치가 참조되어 있어야 하는 원리랑 같은 것이다.  
아래 명령어를 통해 터미널 세션 전체(global)에서 go 커맨드를 실행할 수 있도록 설정한다.  

```bash
asdf global golang 1.17.3
```

<br/>

## 다른 Go 패키지 갖다 쓰기
Go는 `go.mod` 파일을 이용해서 다른 패키지와의 의존성을 관리할 수 있다.  
내가 처음 Go를 접했던 2017년에는 `go.mod`같은 게 없었던 것 같은데 대충 찾아보니 Go 1.12(2019년)에 등장한 것 같다. 아무튼...  
이 파일은 `go mod init {모듈 경로}` 명령어를 실행하면 자동으로 생성된다.  

실제 모듈을 개발할 때 `{모듈 경로}`는 실제 그 모듈이 존재하는 저장소 위치를 가리켜야 Go Tools에서 모듈을 다운로드할 수 있게 된다.  

```bash
go mod init example/hello
```

다른 패키지를 찾아보려면 [pkg.go.dev](https://pkg.go.dev/) 사이트를 방문하자.  
만약 'quote'라는 패키지를 설치할 경우 아래와 같이 `import` 구문을 추가한다.  

```go
import "rsc.io/quote"
```

이제 이 프로그램은 `rsc.io/quote` 모듈이 반드시 필요하게 되었다.  
이러한 의존성 관계를 정리하기 위해 `go mod tidy` 명령어를 실행해줘야 한다.  
이 명령어는 `go.mod`파일에 의존성 요구사항을 명시하고, `go.sum`파일에 의존성 모듈의 체크섬을 기록한다.  

`go.sum` 파일에 기록되는 체크섬은 다운로드한 모듈의 암호화 해시를 계산하고, 프로젝트를 다시 실행할 때 기존에 계산한 값과 비교하여 파일이 처음 다운로드된 이후 변경되지 않았는지 확인해서 다시 설치하지 않도록 한다.  

<br/>

## 내 로컬에 있는 Go 모듈 갖다 쓰기
로컬 환경에 내가 작성한 Go 모듈에 직접 의존하는 경우 해당 경로를 임의로 명시해줘야 한다.  
`go mod edit` 명령어는 명시한 모듈을 내 로컬 환경에 존재하는 실제 경로로 치환시켜 준다.  

```bash
go mod edit -replace example.com/greetings=../greetings
```

이제 다시 `go mod tidy`를 실행해서 의존성 관계를 업데이트한다.  
결과를 확인하기 위해 `go.mod` 파일을 열어보면 다음과 같이 `replace`, `require` 지시자가 추가된 것을 볼 수 있다.  

```
module example.com/hello

go 1.17

replace example.com/greetings => ../greetings

require example.com/greetings v0.0.0-00010101000000-000000000000
```

모듈 경로에 붙은 `v0.0.0-00010101000000-000000000000` 버전은 *pseudo-version number* 이라고 부르는데 임시로 생성된 버전이다.  

> 참고: `go.mod`파일에 있는 패키지의 버전이 업그레이드될 경우, `go mod tidy` 명령어를 실행해서 `go.sum`파일에 체크섬을 업데이트해야 한다.
