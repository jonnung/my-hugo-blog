---
comments: true
title: "Django에서 pytest로 테스트하기 위한 기본기"
date: 2018-12-22T11:37:00+09:00
tags:
  - django
  - pytest
  - tdd
categories:
  - python
url: /django/2018/12/30/pytest-django/
description: Django 프로젝트에서 Pytest를 이용해 유닛 테스트를 작성하기 위해 사용하는 pytest-django 플러그인의 기본 사용법
---
**pytest-django** 는 Django 프로젝트에서 **pytest**를 사용하기 위한 플러그인이다.  
pytest 와 pytest-django 는 Standard Django Test suite 와  [Nose](https://nose.readthedocs.io/en/latest/) Test suite 호환 된다.  
단, 테스트 실행은 Django 의 `manage.py test` 를 사용하지 않고, `pytest` 명령어를 사용한다.  
`manage.py`를 사용하지 않는 이유는 `unittest`를 임포트해서 `TestCase` 클래스의 서브 클래스로 선언할 필요가 없고, 단순하게 테스트 함수만 작성하는 것만으로 테스트를 작성할 수 있기 때문이다. 그리고 Fixture 를 관리할 수 있는 편리함과 pytest 의 다양한 플러그인도 사용할 수 있다는 장점이 있다.

<br>

## Pytest 설치 및 설정하기
----
{{< highlight shell >}}
$ pip install pytest-django
{{< /highlight >}}

테스트를 실행할 때 Django 프로젝트의 설정을 사용하기 때문에 `pytest.ini` 파일에 아래와 같이 명시하거나 `--ds=your.settings` 또는 `DJANGO_SETTINGS_MODULE` 환경변수를 설정해야 한다.
{{< highlight ini >}}

[pytest]
DJANGO_SETTINGS_MODULE = yourproject.settings
{{< /highlight >}}

<br>

## Python path 관리
----
pytest-django는 기본적으로 프로젝트의 manage.py 파일을 찾아보고, 그 디렉토리를 [python path](https://docs.python.org/3/library/sys.html#sys.path)에 자동으로 추가한다.

<br>

## 테스트 실행
----
**pytest-django** 는 `manage.py` 또는 `django-admin.py` 를 이용해 테스트를 실행하지 않고, 단독으로 `pytest` 명령어를 실행하는 방식을 사용한다.
아래와 같이 실행 파라미터를 이용해 테스트를 실행할 대상 모듈과 디렉토리를 직접 지정할 수 있다.
{{< highlight shell >}}
$ pytest test_something.py a_directory
{{< /highlight >}}

<br>

## Database 활용
----
**pytest-django**는 테스트할 때 DB를 접근하는 것에 대해 보수적으로 다룬다. 따라서 기본적으로 테스트 과정에서 DB에 접근하려고 한다면 실패하게 될 것 이다.  
테스트 하려는 대상에서 DB에 접근을 하려면, 반드시 정확하게 명시해야만 허용된다. (DB가 필요한 테스트를 최소화하는 것도 좋은 선택)

테스트에서 DB 접근이 필요한 경우 pytset-django는 [pytest mark](https://pytest.org/en/latest/mark.html)를 사용한다.
{{< highlight python >}}
import pytest

@pytest.mark.django_db
def test_my_user():
	me = User.objects.get(username='me')
	assert me.is_superuser
{{< /highlight >}}

클래스와 모듈 단위로 mark를 설정할 경우 모든 테스트에 적용할 수 있다. 
{{< highlight python >}}
import pytest

pytestmark = pytest.mark.django_db

@pytest.mark.django_db
class TestUsers:
    pytestmark = pytest.mark.django_db
    def test_my_user(self):
        me = User.objects.get(username='me')
        assert me.is_superuser
{{< /highlight >}}

<br>

#### 트랜젝션
Django 자체에 `TransactionTestCase` 클래스는 트랜젝션을 통해 격리된 상태에서 테스트를 수행하게 하고, 테스트를 마치면 DB 초기화 해준다. 하지만 이 상태에서 수행되는 테스트는 트랜젝션 중에 생성된 DB 데이터를 비우는 과정 때문에 매우 느리게 수행될 수 있다.  

이와 같은 기능을 사용하려면 django_db mark 에 **Transaction=True** 파라미터를 전달한다.

{{< highlight python >}}
@pytest.mark.django_db(transaction=True)
def test_spam():
    pass
{{< /highlight >}}

<br>

#### 테스트 전용 Database
`--reuse-db` 은 데이터베이스를 재사용하기 위한 실행 옵션이고, `--create-db` 는 데이터베이스를 강제로 다시 생성하는 실행 옵션이다.  

처음 테스트를 실행할 때 `--reuse-db` 를 사용하면 새로운 테스트 전용 DB가 생성되는데 모든 테스트가 종료 되더라도 테스트 DB는 지워지지 않는다. 그리고 다음 테스트를 실행할 때 동일하게 `--reuse-db` 를 사용하면 이전 테스트DB를 다시 사용하게 된다.  
이 옵션은 적은 테스트를 실행할 때나 DB 테이블이 많은 경우 유용한다.  

`--reuse-db` 옵션을 기본 pytest.ini 옵션으로 지정하고, 테이블 스키마가 변경되었거나 했을때 `--create-db` 옵션을 사용하자.
{{< highlight ini >}}
[pytest]
addopts = --reuse-db
{{< /highlight >}}

`--nomigrations` 를 사용할 경우  Django migrations 와 모든 모델 클래스 검사를 위한 DB 생성을 수행하지 않는다. 

<br>

## Django Helper
----
#### Marker
`pytest.marker`를 이용해 테스트 함수나 클래스에 메타 데이터를 쉽게 설정할 수 있다.

- `pytest.mark.django_db` : 테스트 함수에서 DB 사용이 필요하다는 것을 나타낸다. 모든 테스트는 각각의 DB 트랜젝션 안에서 수행되기 때문에 테스트가 종료되면 변경된 데이터도 함께 롤백된다.
- `pytest.mark.urls` : Django 의 `URLCONF`을 직접 지정할 수 있다. (예: myapp.test_urls)

<br>

#### Fixture
- `rf` : [`django.test.RequestFactory`](https://docs.djangoproject.com/en/dev/topics/testing/advanced/#django.test.RequestFactory)인스턴스
- `client` : [`django.test.Client`](https://docs.djangoproject.com/en/dev/topics/testing/tools/#the-test-client) 인스턴스
더 많은 Fixture는 공식 문서를 참고 [Django helpers — pytest-django](https://pytest-django.readthedocs.io/en/latest/helpers.html#fixtures)
