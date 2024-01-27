---
comments: true
date: 2016-08-07T23:34:04Z
tags:
  - go
categories:
  - golang
title: Golang - nil 비교하기
url: /golang/2016/08/07/go-compare-nil/
---

아래 코드를 실행하면 checkEggOneSet() 함수에서 파라미터 p 와 nil 을 비교할 때 에러가 발생한다.  
_compare_pointer_to_nil_test.go|13| cannot convert nil to type Person_  

```
package main

import "fmt"

type Age int

type Person struct {
    age    Age
    gender string
}

func checkEggOneSet(p Person) bool {
    if p != nil && p.age >= 30 {
        return true
    }
    return false
}

func Example_compare_to_nil() {
    me := Person{age: 32, gender: "man"}
    if checkEggOneSet(me) {
        fmt.Println("계란 한판을 넘으셨군요.")
    }

    // Output:
    // 계란 한판을 넘으셨군요.
}
```
  
변수나 struct 의 인스턴스와 nil 은 서로 다른 타입이다. 따라서 비교 할 수 없는 것이 맞다.  
하지만 pointer는 nil 값을 가질 수 있다.(혹은 nil 일 수 있다)  
  
따라서 checkEggOneSet 함수 선언과 호출시에 me 변수를 포인터로 전달할 수 있도록 해야한다.  

```
func checkEggOneSet(p *Person) bool {
     // ... 생략

checkEggOneSet(&me)
```

## 참고
- http://stackoverflow.com/questions/20240179/nil-detection-in-go(http://stackoverflow.com/questions/20240179/nil-detection-in-go)
- http://stackoverflow.com/questions/24465489/structs-cannot-be-nil-but-this-is-compiling(http://stackoverflow.com/questions/24465489/structs-cannot-be-nil-but-this-is-compiling)
