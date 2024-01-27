---
comments: true
date: 2015-08-17T20:57:58Z
tags:
  - python
categories:
  - python
title: 파이썬 데코레이터(Python Decorator) 를 이해하고 잘 써보기
url: /python/2015/08/17/python-decorator/
---

파이썬 코드를 보다보면 간혹 정의된 함수 위에 ```@```가 붙은 짧은 문장, 의미상으로는 함수명을 같기도한 것들이 있는 것을 본적이 많을
것이다.

어떻게 보면 문서화를 위한 [Docstring](https://en.wikipedia.org/wiki/Docstring)으로 보일 수도 있는데 이것은 사실 **데코레이터(Decorator)**라고 불리는 함수 표현이다.

이름에서 예상할 수 있듯이 무엇인가 꾸며주는 역할을 할 것 같은데, 정말로 그렇다.

데코레이터는 함수를 꾸며주는(?)는 함수이다. 좀 더 정확하게 말하자면 기존에 정의된 함수의 능력을 확장할 수 있게 해주는 함수이다.

## 파이썬 함수의 특징
파이썬의 함수는 [일급 객체(First class
object)](https://ko.wikipedia.org/wiki/%EC%9D%BC%EA%B8%89_%EA%B0%9D%EC%B2%B4)이다.
파이썬 함수의 특징은 다음과 같다.

#### 1. 변수에 할당할 수 있다.

{{< highlight python >}}
def greet(name):
    return "Hello {}".format(name)

greet_someone = greet
greet_someone("Eunwoo")
{{< / highlight >}}

\> 실행결과

    'Hello Eunwoo'



#### 2. 다른 함수내에서 정의될 수 있다.

{{< highlight python >}}
def greeting(name):
    def greet_message():
        return 'Hello'
    return "{} {}".format(greet_message(), name)

greeting("Eunwoo")
{{< / highlight >}}

\> 실행결과

    'Hello Eunwoo'



#### 3. 함수의 인자로 전달할 수 있다.

{{< highlight python >}}
def change_name_greet(func):
    name = "Narae"
    return func(name)

change_name_greet(greet)
{{< / highlight >}}

\> 실행결과

    'Hello Narae'



#### 4. 함수의 반환값이 될 수 있다.

{{< highlight python >}}
def uppercase(func):
    def wrapper(name):
        result = func(name)
        return result.upper()
    return wrapper

new_greet = uppercase(greet)
new_greet("eunwoo")
{{< / highlight >}}

\> 실행결과

    'HELLO EUNWOO'



## 데코레이터(Decorator)? 언제 써야할까?
* 기존 함수에 기능을 추가하고, 새로운 함수를 만드는 역할
* Python2.2에서 ```@staticmethod```, ```@classmethod``` 로 소개됨
* [PEP 318](https://www.python.org/dev/peps/pep-0318)
* 어떤 동작을 함수의 전/후에 수행해야 하거나, 공통적으로 사용하는 코드를 쉽게 관리하기 위해 사용


## 데코레이터 문법(Syntax)
데코레이터 표현법을 보기전에 먼저 데코레이터와 같은 역할을 하는 함수를 만들어보자.

{{< highlight python >}}
class Greet(object):
    current_user = None
    def set_name(self, name):
        if name == 'admin':
            self.current_user = name
        else:
            raise Exception("권한이 없네요")

    def get_greeting(self, name):
        if name == 'admin':
            return "Hello {}".format(self.current_user)

greet = Greet()
greet.set_name('eunwoo')
{{< / highlight >}}

\> 실행결과

    Exception                                 Traceback (most recent call last)

    <ipython-input-34-04060cea2324> in <module>()
         12
         13 greet = Greet()
    ---> 14 greet.set_name('eunwoo')


    <ipython-input-34-04060cea2324> in set_name(self, name)
          5             self.current_user = name
          6         else:
    ----> 7             raise Exception("권한이 없네요")
          8
          9     def get_greeting(self, name):


    Exception: 권한이 없네요


이 클래스의 메소드들은 전달받은 ```name``` 인자가 admin 일때만 수행하는 부분들을 갖고 있다.

공통적으로 사용하는 부분을 따로 떼어낼 수 있을 것 같다.

{{< highlight python >}}
def is_admin(user_name):
    if user_name != 'admin':
        raise Exception("권한이 없다니까요")

class Greet(object):
    current_user = None
    def set_name(self, name):
        is_admin(name)
        self.current_user = name

    def get_greeting(self, name):
        is_admin(name)
        return "Hello {}".format(self.current_user)

greet = Greet()
greet.set_name('admin')
greet.get_greeting('eunwoo')
{{< / highlight >}}


\> 실행결과

    Exception                                 Traceback (most recent call last)

    <ipython-input-35-3f79f20b3c05> in <module>()
         15 greet = Greet()
         16 greet.set_name('admin')
    ---> 17 greet.get_greeting('eunwoo')


    <ipython-input-35-3f79f20b3c05> in get_greeting(self, name)
         10
         11     def get_greeting(self, name):
    ---> 12         is_admin(name)
         13         return "Hello {}".format(self.current_user)
         14


    <ipython-input-35-3f79f20b3c05> in is_admin(user_name)
          1 def is_admin(user_name):
          2     if user_name != 'admin':
    ----> 3         raise Exception("권한이 없다니까요")
          4
          5 class Greet(object):


    Exception: 권한이 없다니까요


조금 더 좋아졌다. 하지만 데코레이터를 쓰면 더 좋은 코드가 될 수 있다.

{{< highlight python >}}
def is_admin(func):
    def wrapper(*args, **kwargs):
        """
        decorate
        """
        if kwargs.get('username') != 'admin':
            raise Exception("아 진짜 안된다니까 그러네..")
        return func(*args, **kwargs)
    return wrapper

class Greet(object):
    current_user = None

    @is_admin
    def set_name(self, username):
        self.current_user = username

    @is_admin
    def get_greeting(self, username):
        """
        greeting

        :param username: 이름
        :type username: string
        """
        return "Hello {}".format(self.current_user)

greet = Greet()
greet.set_name(username='admin')
greet.get_greeting(username='admin')
{{< / highlight >}}

\> 실행결과

    'Hello admin'

{{< highlight python >}}
    greet.get_greeting(username='eunwoo')
{{< / highlight >}}

\> 실행결과

    Exception                                 Traceback (most recent call last)

    <ipython-input-61-2aed1f705388> in <module>()
    ----> 1 greet.get_greeting(username='eunwoo')


    <ipython-input-60-f1529a570fbc> in wrapper(*args, **kwargs)
          5         """
          6         if kwargs.get('username') != 'admin':
    ----> 7             raise Exception("아 진짜 안된다니까 그러네..")
          8         return func(*args, **kwargs)
          9     return wrapper


    Exception: 아 진짜 안된다니까 그러네..


## 메소드의 속성 유지하기
위와 같이 데코레이터를 만들게 되면 원래 함수의 속성들이 사라지는 문제점이 발생한다.

이것을 보완하기 위해 ```functools``` 모듈에는 데코레이터를 위한 데코레이터 ```@wraps```가 있다.

{{< highlight python >}}
greet.get_greeting.__name__
# 'wrapper'

greet.set_name.__doc__
# '\n        decorate\n        '
{{< / highlight >}}


메소드의 ```__name__``` , ```__doc__``` 속성을 확인해보면, wrapper 함수의 속성이 나오게 된다.


{{< highlight python >}}
from functools import wraps

def is_admin(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if kwargs.get('username') != 'admin':
            raise Exception("아 진짜 안된다니까 그러네..")
        return func(*args, **kwargs)
    return wrapper

class Greet(object):
    current_user = None

    @is_admin
    def set_name(self, username):
        self.current_user = username

    @is_admin
    def get_greeting(self, username):
        """
        greeting

        :param username: 이름
        :type username: string
        """
        return "Hello {}".format(self.current_user)


greet = Greet()

greet.get_greeting.__name__
# 'get_greeting'

greet.get_greeting.__doc__
# '\n        greeting\n        \n        :param username: \xec\x9d\xb4\xeb\xa6\x84 \n        :type username: string\n        '
{{< / highlight >}}


## 데코레이터에게 인자 넘기기
데코레이터에도 추가 인자를 넘겨줄 수 있다.

이때는 데코레이터를 정의하는 것이 아니라 데코레이터를 만들어주는 함수를 정의한다고 볼 수 있다.

{{< highlight python >}}
def add_tags(tag_name):
    print("Gernerate decorator")
    def set_decorator(func):
        def wrapper(username):
            return "<{0}>{1}</{0}>".format(tag_name, func(username))
        return wrapper
    return set_decorator

@add_tags("div")
def greeting(name):
    return "Hello " + name

print greeting("Jonnung")
{{< / highlight >}}

\> 실행결과

    <div>Hello Jonnung</div>


## 클래스(class)로 데코레이터 만들기


{{< highlight python >}}
class Sample(object):
    def __init__(self):
        print("init")
    def __call__(self):
        print("call")


sample = Sample()
# init

sample()
# call
{{< / highlight >}}

클래스의 인스턴스를 함수처럼 호출하기 위해서 클래스에 ```__call__``` 이라는 매직 메소드를 정의했다.

이 원리를 이용해서 클래스를 데코레이터로 구현할 수 있다.

{{< highlight python >}}
from functools import wraps

class OnlyAdmin(object):
    def __init__(self, func):
        self.func = func

    def __call__(self, *args, **kwargs):
        name = kwargs.get('name').upper()
        self.func(name)

@OnlyAdmin
def greet(name):
    print("Hello {}".format(name))


greet(name='Eunwoo')
{{< / highlight >}}

\> 실행결과

    Hello EUNWOO



