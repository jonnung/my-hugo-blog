---
comments: true
title: "분산 비동기 작업 처리를 위한 Celery 첫걸음"
date: 2018-12-22T11:37:00+09:00
tags:
  - python
  - celery
categories:
  - infra
  - how-to
url: /python/2018/12/22/celery-distributed-task-queue/
description: Celery를 이용해 비동기 작업을 처리하기 위한 Celery 개념과 기초 사용법
---


## 뻔한 Celery 소개
![celery-logo](/images/celery_logo.png)  
**Celery** 는 분산 메시지 전달을 기반으로 동작하는 비동기 작업 큐(Asynchronous Task/Job Queue) 이다.  
비동기 작업과 분산 메시지 전달은 어떤 관계가 있을까?

비동기 작업은  즉각적인 결과(응답)를 제공하기 어려운 작업을 수행할 때 활용 될 수 있다.  
예를 들어 대용량 작업을 동시에 처리하거나 사용자 요청(HTTP)에 무거운 연산이 포함되는 경우를 들 수 있다.  
보통 비동기 작업을 요청하고 나면, 즉시 응답을 받지 않아도 계속 다른 일을 수행할 수 있기 때문에 동시 작업이 가능하다.  
하지만 작업마다 소요되는 시간이 다르고, 실행 환경도 달라 중복 작업이 발생하지 않아야 하며 작업이 누락되지 않도록 하는 것도 매우 중요하다.

이렇게 대기중인 `작업(Job)`을 관리하고, `작업자(Worker)`에서 제대로 전달되기 위해서는 중간 단계에서 관장하는 시스템이 필요하다.  
이 때 등장하는 개념이 `브로커(Broker)`이다. 브로커는 작업 메세지를 전달받은 대기열(Queue)에 보관했다가 적절한 작업자(Worker)가 메세지를 가져가서 작업(Job)을 수행하게 된다.  
이 과정에서 Celery는 메세지를 전달하는 역할(Publisher)과 메시지를 가져와 작업을 수행하는 역할(Worker)을 담당하게 된다.

Celery는 파이썬으로 작성 되었으며, **Django**와도 잘 호환된다. 기존에 Django에서 사용하기 위한 별도의 라이브러리 형태([django-celery](https://github.com/celery/django-celery))로 있었는데 Celery 3.1 부터 Celery를 설치하는 것만으로 Django에서 Celery를 사용할 수 있게 되었다.

<br>

## 왜 Celery를 생각했을까?
Django로 API 서버를 개발하고 운영하면서 사용자 요청에 포함될 필요가 없는 불필요한 과정이나 매우 무거운 쿼리 실행을 포함하는 경우가 있다.  
예를 들어 `회원 가입 축하 이메일 발송`, `어드민 주문내역 엑셀 다운로드` 같은 기능이 해당된다.  
이 API 에 포함된 외부 연동이나 무거운 작업들은 Celery Task로 정의해서 브로커(RabbitMQ)와 컨슈머(Celery Worker)를 이용해 비동기로 처리함으로써 사용자에게 가능한 빠른 응답 결과를 제공할 수 있을 것이다. 

<br>

## Celery 사용해보기
> Celery 공식 사이트에서 제공하는 첫걸음 과정을 기준으로 실습하는 과정을 설명한다. ([원문 보기](http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html))


### 🛠 Celery 환경 구성
----
#### Broker 선택하기
Celery 는 메시지로 작업(Task)을 주고 받는 시스템이기 때문에 중간에 브로커(Broker) 역할을 하는 분리된 중계 시스템이 필요하다.  
다양한 Broker 들과 호환 되지만 오랜 역사와 안정성을 자랑하는 **RabbitMQ**를 사용하기로 했다.  

[RabbitMQ](https://www.rabbitmq.com/)는 AMQP(Advanced message queuing protocol)을 지원하는 메시지 브로커이다.  
(RabbitMQ에 대한 자세한 설명은 [RabbitMQ 동작 이해하기](https://blog.jonnung.com/rabbitmq/2019/02/06/about-amqp-implementtation-of-rabbitmq/) 참고)  

아래 명령어는 로컬 개발환경에서 쉽고 빠르게 RabbitMQ 서버를 실행하기 위해 도커를 사용했다.  

{{< highlight shell >}}
$ docker run --hostname my-rabbit \
    -p 5672:5672 \
    -p 8080:15672 \
    -e RABBITMQ_DEFAULT_USER=guest \
    -e RABBITMQ_DEFAULT_PASS=guest \
    --name some-rabbit \
    rabbitmq:3-management
{{< /highlight >}}

<br>

#### Celery 설치
Celery 는 파이썬으로 작성된 패키지이다. 
먼저 파이썬 가상 환경을 준비하고, `celery`를 설치한다. 파이썬 가상 환경은 보통 Virtualenv 라고 많이 불려지는데 아래 명령어는 파이썬3 에 내장된 `venv` 모듈을 이용하는 방법을 사용했다.  
{{< highlight shell >}}
$ python3 -m venv venv
$ source ./venv/bin/activate

$ pip install celery
{{< /highlight >}}

<br>

### Celery Worker 와 Task 만들기
----
가장 먼저 할 일은 Celery 인스턴스를 정의하는 것이다.
보통 이것을 **Celery App**이라고 부르며, Task를 만들고 Worker를 관리하는 등의 Celery가 수행하는 모든 것에 대한 시작점이 된다.  

 `Celery` Class의 첫번째 위치 인자로 모듈의 이름을 전달하고, `broker` 키워드 인자로 Broker 연결 정보를 넘긴다.
{{< highlight python >}}
# tasks.py
from celery import Celery

app = Celery('tasks', broker='pyamqp://guest:guest@localhost//')
{{< /highlight >}}
<br>
다음 간단한 Task 함수를 작성 해본다.  
간단하게 연습하는 단계라서 같은 파이썬 모듈(tasks.py) 안에 Celery 인스턴스와 Task 함수를 함께 정의했다.  
{{< highlight python >}}
# tasks.py

@app.task
def add(x, y):
    return x + y
{{< /highlight >}}

<br>

### Celery Woker 실행하기
Celery 를 설치하면 자동으로 `celery` 커맨드를 사용할 수 있게 된다. 그래서 Celery Worker 를 구동하기 위해 `$ celery worker` 같은 형태로 기본 커맨드를 구성하고,  `-A {모듈명}` 또는 `--app={모듈명}` 파라미터로 위에서 정의한 Celery 인스턴스가 포함된 파이썬 모듈을 지정한다.
{{< highlight shell >}}

$ celery -A tasks worker --loglevel=info
{{< /highlight >}}

<br>

### Task 호출하기
Celery Task 도 결국 파이썬 함수이다. 보통 파이썬 함수를 호출할 때 `add()` 같이 하면 되지만, Celery Task 로써 호출하려면 `add.delay()` 같은 형태로 `delay()` 메소드를 호출한다. (이 메소드는 `apply_async()` 메소드의 축소 버전이다.)  
{{< highlight python >}}

from tasks import add
add.delay(1, 2)
{{< /highlight >}}

Task를 호출한 결과로  `AsyncResult` 인스턴스가 반환된다. 이 객체를 이용해서 Task가 완료 되었는지 결과값을 반환했는지 같은 상태를 확인할 수 있다.  
기본적으로 Task 실행 결과값은 저장되지 않는다. 결과를 DB에 저장하거나 RPC 호출을 위해서는 _result backend_ 설정을 추가해야 한다.  

<br>

### 작업 결과 보관하기 (Result Backend)
Celery는 Task 작업 결과를 저장하기 위한 여러가지 _result backend_ 를 내장하고 있다.  
(예: SQLAlchemy, Django, Memcached, Redis, RPC 등등)

_result backend_ 를 지정하려면 `Celery` 인스턴스에  `backend` 키워드 인자를 추가한다.  
 `rpc` 를 _result backend_ 로 지정할 경우 작업 결과를 임시 AMQP 메시지로 다시 돌려보내는 방식으로 동작하고, 작업 결과로 반환된 `AsyncResult` 인스턴스를 유지할 수 있게 된다.
{{< highlight python >}}
app = Celery('tasks', backend='rpc://', broker='pyamqp://')
{{< /highlight >}}
<br>

Task의 완료 상태를 확인하기 위해 `ready()` 메소드를 사용한다.  
{{< highlight python >}}
result = add.delay(4, 4)

result.ready()
# True
{{< /highlight >}}
<br>

`get()` 메소드로 완료된 작업의 결과값을 가져올 수 있다. 만약 호출하는 시점에 작업이 완료되지 않은 경우 완료될때까지 기다리게 된다. (보통 잘 사용하지 않는다고 한다)
{{< highlight python >}}
result.get()
{{< /highlight >}}

Task 실행 중 예외가 발생한 경우 `get()` 메소드를 통해 예외가 전달될 수 있다. `propagate` 인자를 `False`로 전달할 경우에는 이 예외가 전달되지 않는다.
{{< highlight python >}}
result.get(propagate=False)
{{< /highlight >}}
<br>

Task 함수에 `task(ignore_result=True)` 데코레이터를 적용하면 개별 Task 단위로 _result backend_ 사용을 중지할 수 있다. 
{{< highlight python >}}

@app.task(ignore_result=True)
def subtraction(x, y):
    return x - y
{{< /highlight >}}

<br>

### Celery 설정을 분리해서 관리하기
Celery를 운영하는데 많은 설정이 필요하지 않지만, Broker 연결은 필수이며, _result backend_ 는 선택 사항이다.  
위 예제에서 기본 설정들을 Celery 인스턴스에 직접 전달했지만, 별도 전용 모듈(py)로 따로 정의하는 것이 하드 큰 프로젝트에서는 설정을 제어하기 더 수월하다.  
더 많은 설정은 [Configuration and defaults](http://docs.celeryproject.org/en/latest/userguide/configuration.html#configuration) 에서 확인할 수 있다.

설정을 전용 모듈로 분리 했다면  `app.config_from_object()` 메소드를 이용해 설정 모듈을 Celery 인스턴스에 전달 할 수 있다.
{{< highlight python >}}
app.config_from_object('celeryconfig')
{{< /highlight >}}

{{< highlight python >}}
# celeryconfig.py

broker_url = 'pyamqp://'
result_backend = 'rpc://'

task_serializer = 'json'
result_serializer = 'json'
accept_content = ['json']
timezone = 'Asia/Seoul'
enable_utc = True

# 오작동 한 작업을 전용 대기열로 라우팅하는 설정
task_routes = {
    'tasks.add': 'low-priority'
}

# 작업 속도를 제한하는 설정
task_annotations = {
    'tasks.add': {'rate_limit': '10/m'
}
{{< /highlight >}}

<br>

## 참고 자료
- http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html
