---
title: "세 번째 배우는 Go - 파트 3: 고루틴과 채널로 동시성 다루기"
date: 2021-12-21T20:36:49+09:00
draft: false
toc: false
image: "/images/posts/gopher.png"
tags:
  - go
  - golang
categories:
  - golang
description: 고루틴(goroutine)과 채널(channel)을 이용한 동시성을 배웁니다.
url: /go/2021/12/21/concurrency-goroutine-and-channel/
---

### Goroutines
**goroutine**은 Go 런타임이 자체적으로 관리하는 경량 스레드로서 다른 함수를 동시에 실행할 수 있다.  
새로운 goroutine을 시작하려면 단순히 함수를 호출할 때 앞에 `go`라는 키워드만 붙이면 된다.  

아래 코드에서 `main()`함수는 암시적으로 첫번째 goroutine이며, `go f(i)`를 호출할 때 두번째 goroutine이 생성된다.  

```go
package main

import "fmt"
import "time"

func f(n int) {
  for i := 0; i < 10; i++ {
    fmt.Println(n, ":", i)
    time.Sleep(100)
  }
}

func main() {
  for i := 0; i < 10; i++ {
    go f(i)
  }

  fmt.Println("Waiting...")
  var input string
  result, err := fmt.Scanln(&input)
  if err != nil {
    fmt.Println("Something wrong...")
  }

  fmt.Println(result)
}
```

위 샘플 코드의 출력된 결과를 통해 알 수 있는 사실은 goroutine은 순서대로 실행되는 것이 아니라 동시에 실행되는 것을 알 수 있다.  

goroutine은 익명함수로 실행될 수도 있다.  

```go
func main() {
  go func() {
    fmt.Println("Hello")
  }

  go func(name string) {
    fmt.Println(name)
  }("jonnung")

  var input string
  fmt.Scanln(&input)
}
```

<br/>

### Channel
채널은 goroutine간의 데이터를 주고 받는 통로라고 할 수 있으며, 슬라이스와 맵처럼 `make()`함수를 통해 미리 생성되어야 한다.  

채널은 `<-` 연산자를 통해 값을 주고 받을 수 있는데 상대편이 준비될 때까지 채널에서 대기하게 된다.  
만약 `c`라는 채널이 있다면,  `c <- "ping"`으로 데이터를 보내면, `msg := <- c`와 같이 데이터를 받을 때까지 대기하게 된다.  

```go
package main

import "fmt"
import "time"

func pinger(c chan string) {
  for i := 0; i < 10; i++ {
    c <- "ping"
  }
}

func ponger(c chan string) {
  for i := 0; i < 10; i++ {
    c <- "pong"
  }
}

func printer(c chan string) {
  for i := 0; i < 10; i++ {
    msg := <-c
    fmt.Println(msg)
    time.Sleep(time.Second * 1)
  }
}

func main() {
  var c chan string = make(chan string)

  go pinger(c)
  go ponger(c)
  go printer(c)

  var s string
  fmt.Scanln(&s)
}

/* 출력 예상 (1초 간격)
ping
pong
ping
ping
ping
pong
ping
pong
ping
pong
*/
```

이렇게 채널에 데이터를 보내고 받을 때 기다리게 되는 특징을 활용해서 goroutine이 끝날 때까지 기다리는 기능을 구현할 수 있다.  

```go
package main

import "fmt"
import "time"

func main() {
  var done chan string = make(chan string)

  go func() {
    for i := 0; i < 10; i++ {
      fmt.Println(i)
      time.Sleep(time.Second * 1)
    }
    done <- "success"
  }()

  <-done  
}
```

<br/>

### 채널 버퍼링
지금까지 살펴본 채널은 'Unbuffered channel'이라고 해서 하나의 수신자가 데이터를 받을 때까지 송신자는 기다리게 된다.   
하지만 송신자가 채널에 데이터를 보냈으나 수신자가 없는 경우 `deadlock!`에러가 발생한다.  

```go
package main

import "fmt"

func main() {
  ch := make(chan int)
  ch <- 1
  go func() {
    fmt.Println(<-ch)
  }()
}

// 출력 예상
// fatal error: all goroutines are asleep - deadlock!
```

이 문제를 해결하기 위해 채널에 버퍼를 두어 수신자가 아직 데이터를 가져가지 않더라도 송신자는 버퍼의 크기만큼 데이터를 보낼 수 있게 된다.  
'Buffered Channel'은 `make()`함수의 두번째 파라미터로 버퍼의 길이를 제공할 수 있다.  

```go
ch := make(chan int, 100)
```

<br/>

### 채널을 함수의 파라미터로 전달할 때 송수신 방향 지정
채널을 함수의 파라미터로 전달할 때 송수신 방향을 한 가지로 제한할 수 있다.  

```go
package main

import "fmt"

func sendToChannel(ch chan<- string) {
  ch <- "It works"
}

func receiveFromChannel(ch <-chan string, done chan<- bool) {
  msg := <-ch
  fmt.Println(msg)
  done <- true
}

func main() {
  done := make(chan bool)
  ch := make(chan string)

  go sendToChannel(ch)
  go receiveFromChannel(ch, done)

  <-done
}
```

<br/>

### 채널 닫기 
채널에 더 이상 보낼 데이터가 없다는 것을 알리기 위해 채널을  `close`할 수 있다.  
채널에서 데이터를 받아와서 변수에 할당할 때 두번째 변수를 지정하면 채널이 닫혔는지 여부가 할당된다.  

```go
result, ok := <-ch
```

보통 채널을 직접 닫을 일은 많지 않지만,  `range`문을 사용할 때 더 이상 수신할 값이 없다는 것을 알아야할 때만 필요하다.  

<br/>

### 채널에서 계속 데이터 받아오기 (Range)
채널의 수신자가 채널이 닫히기 전까지 계속 데이터를 수신 하려면 `range`문을 사용하면 된다.  
`for`문에 `range`를 이용해서 채널을 순회하다가 채널이 닫히게 되면 자동으로 감지해서 `for`루프가 중단된다.  

```go
package main

import "fmt"

func main() {
  ch := make(chan int, 2)
  ch <- 1
  ch <- 2

  close(ch)

  for i := range ch {
    fmt.Println(i)
  }
}
```

<br/>

### 채널 전용 Switch문
`select`는 `switch`문과 비슷하지만 채널에 대해서만 동작하는 특별한 구문이다.  
`select`문의 `case`에는 서로 다른 채널의 수신자가 지정되며, 가장 먼저 도착한 채널의 `case`문이 실행된다.   
만약 정말 동시에 여러 채널에 데이터가 들오더라도 Go 런타임은 무작위로 한 개를 선택한다.  
`default`문을 추가하면 `case`문의 채널이 준비되지 않더라도 계속 대기하지 않고 바로 `default`문을 실행한다.   

```go
package main

import "fmt"

func main() {
  ch1 := make(chan int)
  ch2 := make(chan int)

  go func(c1 chan int) {
    c1 <- 1
  }(ch1)

  go func(c2 chan int) {
    c2 <- 2
  }(ch2)

  go func(c1, c2 chan int) {
    for {
      fmt.Println("Loop!")
      select {
      case msg1 := <- c1:
        fmt.Println(msg1)
      case msg2 := <- c2:
        fmt.Println(msg2)
      }
    }
  }(ch1, ch2)

  var input string
  fmt.Scanln(&input)
}
```
