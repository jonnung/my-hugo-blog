---
title: "세 번째 배우는 Go - 파트 2: Tour of Go를 학습하며 남기는 기록과 예제"
date: 2021-12-18T14:45:45+09:00
draft: false
toc: false
image: "/images/posts/gopher.png"
tags:
  - go
  - golang
categories:
  - golang
description: Tour of Go를 하면서 정리한 내용입니다. 
url: /go/2021/12/18/tour-of-go/
---

### 패키지
모든 프로그램은 `main` 패키지에서 실행을 시작한다.  

패키지를 import하고 import한 패키지 이름(경로)의 마지막 부분을 네임스페이스처럼 그 패키지 안에 있는 메서드를 호출할 때 사용된다.  
아래 예제 코드에서 import한 `math/rand` 패키지 이름에서는 `rand` 부분을 사용한다.  

```go
package main

import (
  "fmt"
  "math/rand"
)

func main() {
  rand.Seed(100)
  fmt.Println("내가 제일 좋아하는 숫자는 ", rand.Intn(10))
}
```

import할 때 괄호로 그룹을 짓는 형태를 `factored import`라고 하며, 이 스타일을 사용하는 것을 추천한다.  
import된 패키지에서는 대문자로 시작하는 이름을 가진 함수와 변수만 접근할 수 있다.  


<br/>

### 함수
함수의 매개 변수가 2개 이상이며 같은 Type인 경우 마지막 매개변수 뒤에만 Type을 선언하면 된다.  

```go
func add(x, y int) int {
  return x + y
}
```

그리고 함수는 여러개의 결과를 반환할 수 있다.  

```go
func swap(x, y string) (string, string, string) {
  return y, x, "good"
}
```
<br/>
함수 반환값 Type에 미리 변수명을 지정하면, 함수 안에서 그 변수를 바로 사용할 수 있다.  
그리고 반환할 때 그냥 `return`만 하더라도 반환값으로 선언한 변수가 자동으로 반환된다.  
이런 방식을 `naked return`이라고 하며, 긴 함수에서 사용할 경우 가독성을 떨어뜨릴 수 있다는 점을 주의하자.  

```go
func split(sum int) (x, y int) {
  x = sum * 4 / 9
  y = sum - x
  return
}
```

<br/>

### 변수
변수를 선언할 때는 `var`키워드를 먼저 사용하고, 변수명 다음에 Type을 명시한다.  
초기값을 지정할 경우 Type을 생략할 수 있다.  

```go
var i, j int = 1, 2
var c, python, java = true, false, "no!"
```

<br/>
오직 함수 안에서만 `:=`를 사용할 수 있는데 이렇게 변수를 선언하면 Type을 암시적으로 유추하게 된다.  

```go
func main() {
  var i, j int = 1, 2
  k := 3
  c, python, java := true, false, "no!"
}
```

<br/>
변수에 사용되는 Type은... `bool`, `string`, `int` 등이 있다.  
변수에 초기값을 선언하지 않은 경우 Zero Value가 할당되며, 각 타입의 Zero Value는 다음과 같다.  

- 숫자 Type: 0
- Boolean Type: false
- String Type: ""(빈 문자열)  

기존 Type을 다른 Type으로 변환하려면 변수를 Type의 이름으로 감싸면 된다.  

```go
var i int = 42
var f float64 = float64(i)
```

숫자를 `:=` 또는 지정한 값에 의해 Type이 유추될 경우 그 정확도에 따라 `int`, `float64`, `complex128`이 된다.  

```go
func main() {
  i := 42
  f := 3.142
  g := 0.867 + 0.5i
  
  fmt.Printf("i의 타입은 %T\n", i)
  fmt.Printf("f의 타입은 %T\n", f)
  fmt.Printf("g의 타입은 %T\n", g)
}
```

상수는 `var` 대신 `const` 키워드로 선언하며 `:=`은 사용할 수 없다.   

<br/>

### For
Go에서 반복문은 오직 `for` 하나만 존재한다.  
`for`문의 구조는 `;`으로 구분되는 세 가지 구성 요소를 갖는다.  

1. 초기화 구문;  
2. ;반복 조건 표현식;  
3. ;반복 후 구문  

'초기화 구문'에는 짧은 변수 형태로 선언할 수 있는데 이 변수는 `for`문안에서만 사용할 수 있다.  
'반복 조건 표현식'의 평가 결과가 `false`가 되면 반복은 종료된다.   

```go
func main() {
  sum := 0
  for i := 0; i < 10; i++ {
    sum += i
  }
  fmt.Println(sum)
}
```

for문의 각 구성 요소는 필수가 아니다.   
그래서 '반복 조건 표현식'만 사용한다면, `while`처럼 사용될 수 있고 전부 생략할 경우 무한 루프를 의미한다.  

```go
for sum < 1000 {
  sum += sum
}

for {
  fmt.Println("무한도전")
}
```

<br/>

### If
Go의 `if`는 소괄호를 사용하지 않는다는 점에서  `for`와 비슷하다.  
그리고 `if`문 조건식에도 짧은 변수를 선언할 수 있고, `for`문과 마찬가지로 이 변수도 `if`문안에서만 사용할 수 있다.    

```go
func pow(x, n, lim float64) float64 {
  if v := math.Pow(x, n); v < lim {
    return v
  }
  return lim
}
```

<br/>

### Switch
`if-else` 구문을 반복해서 사용할 경우, `switch` 구문을 사용할 수 있다.  
Go의 `switch`는 다른 언어와 다르게 마지막 case까지 실행하지 않고, 먼저 선택된 case 조건만 실행하고 멈춘다. (자동 break)  
즉, `switch`는 위에서 아래로 case를 평가해서 성공하는 case에서 바로 멈추는 방식이다.  

```go
today := time.Now().Weekday()

switch time.Saturday {
case today + 0:
  fmt.Println("오늘")
case today + 1:
  fmt.Println("내일")
case today + 2:
  fmt.Println("이틀 후")
default:
  fmt.Println("너무 나중이네")
}
```

`switch`의 조건문에 꼭 상수만 쓸 수 있는 것은 아니다. 아래와 같이 짧은 변수를 선언하고, 즉시 사용할 수 있다.  

```go
switch os := runtime.GOOS; os {
case "darwin":
  fmt.Println("MAC OS")
case "linux":
  fmt.Println("Linux")
default:
  fmt.Printf("%s \n", os)
}
```

`switch`의 조건문은 생략할 수도 있다.    

```go
switch {
case today + 0 == time.Saturday:
  fmt.Println("오늘")
case today + 1 == time.Saturday:
  fmt.Println("내일")
default:
  fmt.Println("너무 나중이네")
}
```

<br/>

### Defer
`defer`문은 자신이 선언된 함수가 종료할 때까지 실행을 연기한다.  
함수 안에서 `defer`를 여러번 사용하면 스택에 쌓이고, 함수가 종료될 때 LIFO(Last In, First Out) 순서로 실행된다.  

```go
func main() {
  fmt.Println("counting")
  for i := 0; i < 10; i++ {
    defer fmt.Println(i)
  }
  fmt.Println("done")
}
```

<br/>

### Pointers
Go는 변수의 메모리 주소를 가리키는 포인터를 지원한다.  
`*T` 라는 타입으로 변수를 선언하면 `T` 타입의 값을 가리키는 포인터가 된다.  
포인터의 Zero value는 `nil`이다.  

```go
var p *int
```

기존 변수명에 `&`연산자를 앞에 붙이면 이 값에 대한 포인터를 생성한다.  

```go
i := 100
p = &i
```

반대로 포인터 변수에 대해 `*`연산자를 앞에 붙이면 이 포인터가 가리키는 실제 값을 나타낸다.  

```go
fmt.Println(*p)
*p = 101
```

<br/>

### Structs
**Struct**는 필드의 집합이며, 필드는 .(dot)으로 접근할 수 있다.  
<br/>
struct 타입을 선언할 때 필드의 이름을 직접 명시해서 값을 할당할 수 있다. 값을 지정하지 않은 필드는 Zero value로 초기화된다.  
struct을 선언할 때부터 접두사 `&`을 붙이면 자동으로 struct 값의 포인터가 반환된다.  

```go
type Vertex struct {
  X, Y int
}

var (
  v1 = Vertex{1, 2}
  v1 = Vertex{X: 1}
  v3 = Vertex{}
  p = &Vertex{1, 2}
)
```
<br/>
만약 어떤 struct 타입의 포인터 변수가 `p`라면,  `*p`는 이 포인터가 가리키는 실제 값에 대한 접근이고, `X`라는 필드에 접근하려면 `*p.X` 라고 쓴다.   
하지만 이 표기에서 `*`은 다소 번거롭기 때문에 단순하게 `p.X`라고 작성할 수 있다.  

<br/>

### Array
배열을 선언할 때 `[n]T` 형태로 Type을 지정한다.  이것은 `T`라는 타입의 값이 n개 있는 배열이라는 의미를 갖는다.  
배열 길이(length)는 그 타입의 일부라서 한번 선언된 배열의 길이는 조정할 수 없다.  

```go
var a [10]int
```

<br/>

### Slice
배열의 길이(length)는 선언할 때 고정되지만, 이 배열에 대한 슬라이스를 만들어서 배열의 요소와 길이를 가변적으로 다룰 수 있다.  
`[]T` 타입같이 슬라이스를 선언하면, `T`라는 타입의 슬라이스를 의미한다.  

슬라이스 표현식은 아래와 같은 형태를 가지는데, 첫번째 요소(`low`)는 슬라이스의 시작 요소이며, 두번째 요소(`high`)를 제외하는 범위에 해당한다.  
만약 `low`, `high`를 생략하게 되면 `low`의 기본값은 0이고, `high`의 기본값은 배열의 길이가 된다.   

```go
a[low : high]
```

```go
primes := [6]int{1, 2, 3, 4, 5, 6}
var s []int = primes[1:]
```
<br/>
슬라이스의 특정 요소를 수정하면 원본 배열의 요소도 수정된다.  
그래서 동일한 배열로부터 만들어진 슬라이스는 변경이 생길 경우 함께 반영된다.  

```go
names := [4]string{
  "john",
  "paul",
  "george",
  "ringo",
}

a := names[0:2]
b := names[1:3]
fmt.Println(names)  // [john paul] [paul george]

b[0] = "jonnung"
fmt.Println(names)  // [john jonnung george ringo]
```

당연히(?) 슬라이스에 슬라이스를 포함 시킬 수 있다. (2차원 배열처럼)  

```go
board := [][]string{
  []string{"_", "_", "_"},
  []string{"_", "_", "_"},
  []string{"_", "_", "_"),
}
```

<br/>

### Slice literals
슬라이스 리터럴 표현식은 배열 리터럴과 거의 같고, 단지 길이를 지정하지 않는다.  

```go
[]bool{true, true, false}
```

<br/>

### Slice length & capacity
슬라이스는 길이(length)와 용량(capacity)를 갖는다.  
슬라이스의 길이는 슬라이스가 가리키는 범위에 해당되는 요소의 개수이다.  
슬라이스의 용량은 슬라이스가 가리키는 원본 배열 요소의 개수이다.  

```go
s := []int{1, 2, 3, 4, 5}

fmt.Printf("Length: %d\n", len(s))  // 5
fmt.Printf("Capacity: %d", cap(s))  // 5
```

슬라이스의 Zero Value는 `nil`이며, nil 슬라이스의 길이와 용량은 0이다.  

<br/>

### make로 슬라이스 만들기
내장 함수 `make`로 동적 크기의 슬라이스를 만들 수 있다.  
`make`함수의 첫번째 인자는 슬라이스, 두번째 인자는 길이(length), 세번째 인자는 용량(capacity)을 지정할 수 있다.  

```go
a := make([]int, 5, 5) // len(a)=5, cap(a)=5
```

`make`는 슬라이스 리터럴이나 원본 배열에서 슬라이스를 생성하는 경우가 아닌 길이(length)와 용량(capacity)을 예상하거나 결정된 상태에서 슬라이스를 만들어야 하는 경우 사용하면 좋을 것 같다.  

<br/>

### 슬라이스에 요소 추가하기
내장 함수 `append`로 슬라이스에 새로운 요소를 추가할 수 있다.  
`append`의 첫번째 인자는 대상 슬라이스 변수, 두번째 인자부터 추가할 값이다.  
`append`의 호출 결과는 주어진 슬라이스의 모든 요소와 추가한 값을 포함하는 새로운 슬라이스가 된다.  

```go
var s []int  // len(s)=0, cap(s)=0

s = append(s, 0)  // [0], len(s)=1, cap(s)=1
```

<br/>

### Map
맵은 Key와 Value의 쌍이다.  
Map으로 선언된 변수는 nil 이고,  Nil Map에는 값을 넣을 수 없다.   
그래서 Nil Map을 쓰기 위해 make라는 내장함수로 초기화를 해야한다. 그래야 Empty Map 된다.  

```go
var m map[string]string
fmt.Println(m)  // map[]
// m["jonnung"] = "zzang" // panic: assignment to entry in nil map

m = make(map[string]string)
m["jonnung"] = "zzang"

fmt.Println(m)  // map[jonnung:zzang]
```

좀 더 간편하게 Map을 사용하기 위해 리터럴을 이용할 수 있다.  
Map 리터럴은 Struct 리터럴과 비슷하지만 Key를 갖는다.  

```go
var m = map[string]string{
  "foo": "bar"
}  // map[foo:bar]
```

<br/>

### Map 다루기

```go
// Map에 요소를 추가하거나 업데이트하기
m[key] = elem

// 요소 찾기
elem = m[key]

// 요소 제거하기
delete(m, key)

// 두 개의 변수에 Map 값을 할당해서 Key가 존재하는지 확인할 수 있다.
// Map에 key가 없다면, ok는 false이며, elem은 Map요소의 타입의 Zero value가 된다.
elem, ok = m[key]
```

<br/>

### Range
`for`문에 `range`를 붙이면 슬라이스와 맵을 순회할 수 있다.  
`range`를 사용하면, 각 반복할 때마다 두 개의 값이 반환되는 데 첫 번째는 인덱스, 두 번째는 그 순서의 값이 복사된다.  

```go
var pow = []int{1, 2, 3, 4, 5}

for i, v := range pow {
  fmt.Printf("Index: %d, Value: %d \n", i, v)
}

// Index: 0, Value: 1 
// Index: 1, Value: 2 
// Index: 2, Value: 3 
// Index: 3, Value: 4 
// Index: 4, Value: 5 
```

`range`가 반환하는 인덱스와 값 중에 사용하지 않으려면 `_`에 할당해서 생략할 수 있다.  


<br/>

### Closure
Go 함수는 함수의 인자가 될 수 있고, 함수의 반환값이 될 수 있다.  
이 특징 때문에 함수 안에서 선언된 함수는 클로저가 될 수 있다.  

<br/>

### Method
Go는 클래스가 없다. 하지만 Type(Struct 포함)에 메소드를 정의할 수 있다.
메소드는 단지  **receiver** 라는 인자가 있는 함수일 뿐이다.  
이 receiver는 `func`키워드와 메소드명 사이에 추가된다.  

```go
type Vertex struct {
  X, Y float64
}

func (v Vertex) Abs() float64 {
  return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
```

```go
type MyFloat float64

func (f MyFloat) Abs() float64 {
  if f < 0 {
    return float64(-f)
  }
  return float64(f)
}
```

<br/>

### Pointer Receiver
포인터를 리시버로 사용할 수도 있다.  
만약 리시버를 포인터로 선언하면 `*Vertex`같은 형식이 된다.  

포인터 리시버가 있는 메소드는 리시버가 가리키는 값을 수정할 수 있다.  
그렇기 때문에 포인터 리시버가 (그냥) 값 리시버보다 더 자주 쓰이는 편이다.   
(값 리시버는 메소드 안에서 원본의 복사본이기 때문이다.)  

```go
type Vertex struct {
  X, Y float64
}

func (v *Vertex) Scale(f float64) {
  v.X = v.X * f
  v.Y = v.Y * f
}
```
<br/>
포인터 리시버가 있는 메소드는 (포인터 변수가 아닌) 값 변수에 의해 메소드가 호출 되더라도 자동으로 포인터의 메소드로 호출된다.  
아래 예제 코드에서 `v`가 값 변수이고, `p`변수가 포인터 변수이다.  

```go
var v Vertex
v.Scale(5)  // (&v).Scale(5) 하는 것과 같다.

p := &v
p.Scale(5)
```

포인터 리시버를 사용하는 이유는 두 가지가 있다.   

1. 메소드 안에서 리시버가 가리키는 값을 수정하기 위해 
2. 각 메소드가 호출될 때마다 값이 복사되는 문제를 피하기 위해

<br/>

### Interface
인터페이스는 메소드의 집합이다.  
인터페이스의 메소드를 구현하는 모든 것들은 인터페이스 Type이 될 수 있다.  
인터페이스 Type을 사용한다는 것은 명시적인 `implementation` 같은 키워드를 사용하지 않더라도 인터페이스 Type이 가진 메소드를 구현함으로써 이 인터페이스를 구현했다는 것을 의미한다.  

인터페이스 Type의 값이 `nil`인 경우, 그 메소드는 `nil` 리시버로 호출된다.  
아래 경우 변수`i`는 `nil`이 아니지만, `t`는 `nil`이다.  

```go
type I interface {
  M()
}

type T struct {
  S string
}

func (t *T) M() {
  if t == nil {
    fmt.Println("<nil>")
    return
  }
  fmt.Println(t.S)
}

func main() {
	var i I  // 인터페이스 값
	// i.M()  // 런타임 에러

	t := &T{"It works"}
	i = t
	i.M()
}
```

Go에서 `nil` 리시버로 메소드가 호출되는 것은 예외를 발생시키지 않지만, 인터페이스의 값이 `nil`인 변수의 메소드를 호출하면 런타임 에러가 발생한다. (당연히 구현되지 않은 메소드이므로 호출할 수는 없음)  

<br/>

### 빈 인터페이스
메소드가 없는 인터페이스 유형을 empty interface라고 한다.  

```go
interface{}
```

빈 인터페이스는 모든 Type의 값을 받을 수 있어서 알 수 없는 값을 처리하는데 이용된다.  

<br/>

### 타입 체크
빈 인터페이스로 선언된 값의 타입을 체크할 때 아래와 같은 방법을 사용할 수 있다.  

```go
var i interface{} = "hello"

s1 := i.(string)
fmt.Println(s1)  // hello

s2, ok := i.(float64)
if ok == true {
  fmt.Println(s2)
} else {
  fmt.Println("errrr")  // errrr
}
```

<br/>

### 타입 Switch 문
Type Switch문은 일반 Switch문에 Type을 명시해서 빈 인터페이스로 전달된 인자의 Type을 비교할 때 사용한다.  

```go
func do(i interface{}) {
  switch v := i.(type) {
  case int:
    fmt.Println("Int")
  case string:
    fmt.Println("String")
  default:
    fmt.Println("I don't know")
  }
}
```

<br/>

### Errors
`error` Type은 `fmt.Stringer`와 유사한 내장 인터페이스이다.  

```go
type error interface {
  Error() string
}
```
