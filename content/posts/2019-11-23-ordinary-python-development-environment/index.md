---
title: "가장 보통의 파이썬 개발 환경 (Pyenv + Pipenv + Black + Flit)"
date: 2019-11-23T22:49:36+09:00
draft: false
toc: false
images:
tags:
  - python
categories:
  - python
url: /python/2019/11/23/ordinary-python-development-environment/
description: 파이썬 개발을 시작하면서 만나게 되는 여러 가지 선택과 궁금증에 대한 가장 보통의 선택을 할 수 있는 가이드다. 파이썬 버전을 여러 개 설치하는 방법, Virtualenv는 무엇이며 어떻게 쓰는 것인가, 코드 스타일 가이드(PEP8) 지키기 위해 유용한 도구들과 다른 파이썬 라이브러리를 설치하고 관리하는 방법, 마지막으로 직접 파이썬 패키지를 만들어서 배포하는 가장 쉬운 방법에 대해 알 수 있다.
---
## 개요
이 글은 파이썬 개발을 시작하면서 만나게 되는 여러 가지 선택과 궁금증에 대한 가장 보통의 선택을 할 수 있는 가이드다.  

파이썬 버전을 여러 개 설치하는 방법, Virtualenv는 무엇이며 어떻게 쓰는 것인가, 코드 스타일 가이드(PEP8) 지키기 위해 유용한 도구들과 다른 파이썬 라이브러리를 설치하고 관리하는 방법, 마지막으로 직접 파이썬 패키지를 만들어서 배포하는 가장 쉬운 방법에 대해 알 수 있다.  

IDE와 에디터는 파이썬 개발 환경에 직접적인 영향을 준다고 볼 수 없고, 개인의 취향이기 때문에 다루지 않는다.

<br/>
## 이 주제를 선택하게 된 이유

백엔드 개발팀에서 주력 언어로 파이썬을 사용하고 있다.  
회사 메인 서비스를 구성하는 API가 Django 프레임워크로 되어 있기 때문이 아닐까 생각하지만 무조건 파이썬으로 개발해야 하는 규칙은 없다.  

우리는 다양한 문제를 해결하기 위해 파이썬을 사용 해왔고, 만들어 낸 결과물과 동작하는 방식은 서로 달랐지만 파이썬을 개발하고, 실행하는 환경은 비슷하다.  
숙련된 파이썬 개발자이거나 아직 그렇지 않은 사람도 매번 개발 환경을 설정하는 부분은 다소 번거롭고, 불필요한 리소스 낭비라고 생각한다.  

하지만 파이썬 생태계에는 개발 환경에 도움을 줄 수 있는 좋은 도구가 많다. 지금부터 몇 가지 유용한 도구들을 소개하고, 어떤 경우에 어떻게 조합해서 쓸 수 있는지 알아보자.

<br/>
## 함께 살펴볼 여정
1. 파이썬 버전과 설치 
2. 파이썬 패키지 관리자
3. 파이썬 가상 환경 
4. 파이썬 코드 스타일
5. 파이썬 코드 포맷터
6. 파이썬 패키징과 배포


<br/>
## 1. 파이썬 버전과 설치
새로운 파이썬 프로젝트를 시작할 때 특별한 이유가 없다면 당연히 파이썬3를 선택할 것이다.  
[파이썬 공식 사이트](https://www.python.org/downloads/)에서 소스 코드를 직접 다운로드하여 빌드 하거나 OS에 맞는 인스톨러를 다운로드하여 설치할 수 있다.  
하지만 여러 프로젝트를 하다보면 프로젝트마다 파이썬 버전이 조금씩 다를 수 있다. 그럴 때마다 각각 다른 파이썬 버전을 다운로드하여 설치하고 관리하는 것은 생각보다 귀찮고, 복잡하다.


#### 👍 Pyenv
[Pyenv](https://github.com/pyenv/pyenv)는 여러 파이썬 버전을 설치하고, 쉽게 선택해서 사용할 수 있도록 해준다. 주요 특징은 아래와 같다.

- 사용자 컴퓨터 환경의 글로벌 파이썬 버전을 교체하고, 관리할 수 있다.
- 프로젝트 단위로 파이썬 버전을 다르게 설정할 수 있다.
- 환경변수(`PYENV_VERSION`)를 통해 파이썬 버전을 지정할 수 있다.
- 다양한 파이썬 버전을 쉽게 검색할 수 있고,  [tox](https://pypi.org/project/tox/)를 통해 다양한 파이썬 버전에서 테스트 할 수 있도록 도와준다.

MacOS에서 pyenv를 설치하는 방법은  `brew install pyenv`가 가장 편리하고 안전하다. 그밖에 소스 코드를 직접 clone 받아 설치하는 방법과 자동 설치 도구([pyenv-installer](https://github.com/pyenv/pyenv-installer))도 있다.

이제 터미널에서  `$ pyenv install 3.7.3` 명령어를 실행하면 pyenv가 알아서 파이썬 3.7.3 소스코드를 내려받아 빌드하고 설치한다.  

 `$ pyenv versions`를 실행하면 현재 내 컴퓨터에 설치된 파이썬 버전이 나온다. 'system'이라고 표시된 것을 제외한 나머지 버전이 모두 pyenv로 설치된 파이썬들이다.

![](pyenv_versions.svg)

pyenv로 파이썬 버전을 선택하는 방법은 2가지가 있다. 
```shell
$ export PYENV_VERSION="3.7.3"
$ python
Python 3.7.3 (default, Apr 19 2019, 20:00:46)
[Clang 8.1.0 (clang-802.0.42)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> exit()
```

1. `PYENV_VERSION` 환경변수에 파이썬 버전을 저장하고, `$ pyenv shell` 명령어를 실행하면 환경변수에 지정된 파이썬 버전이 실행된다. 
2. 현재 작업 디렉터리에 `.python-version` 이라는 파일을 만들고, 내용에 파이썬 버전을 작성하면 된다. 이 파일은 `$ pyenv local 3.7.3` 을 실행해도 생성된다.
3. 글로벌 파이썬 버전은 `$ (pyenv root)/version` 파일에 저장되어 있다. 이 파일의 내용은 `$ pyenv global 3.6.6`같이 실행해서 변경할 수 있다. 


중요한 내용은 아니지만 pyenv가 동작하는 원리는 먼저 사용자 OS환경의 `PATH` 변수에 지정된 경로에 shim라는 디렉터리가 추가된다. shim 디렉터리 안에는 설치된 파이썬 버전들과 그밖에 여러 명령어(예를 들자면 pip)가 있다.  
그래서  `$ python` 또는 `$ pip`같은 명령어를 실행하면 shim 디렉터리 안에 일치하는 경우 그 명령어 전체가 다시 pyenv에게  전달된다. 


<br/>
## 2. 파이썬 패키지 관리자
#### ◆ pip 안 좋은 점
pip는 공식 파이썬 패키지 관리자다. pip는 [PyPI](https://pypi.org/)라는 온라인 저장소를 통해 파이썬 패키지를 검색하고, 설치할 수 있도록 해준다. 
하지만 pip는 몇 가지 단점을 가지고 있다. 

첫째, 하위 의존성을 보장하기 어렵다.  
간다한 예를 들자면 만약 `$ pip install flask`를 설치하고, `requirements.txt` 파일에 `flask`라고 명시했다고 하자. 그다음 프로덕션 환경을 위해 이 프로젝트의 파이썬 환경이 다시 설치될 때 해당 시점에서 가장 최신 버전의 Flask가 설치될 가능성이 있다. 즉, 개발 환경과 프로덕션 환경의 패키지 버전이 달라질 수 있다는 것이다.  

만약 `flask==1.1.1`이라고 버전을 명시하더라도 Flask가 의존하고 있는 다른 라이브러리의 버전이 최신으로 업그레이드될 수 있는 위험성이 있다.  

이 문제점을 해결하는 가장 쉬운 방법은 `$ pip freeze > requirements.txt` 명령어로 현재 파이썬 환경에 설치된 모든 패키지와 버전 정보를 `requirements.txt`에 남기는 것이다.  
하지만 이 방법을 사용하더라도 `requirements.txt`에 있는 모든 패키지들의 버전 관리를 직접 해야 하는 책임이 늘어날 뿐이다.

둘째, Dependency Resolution 이라고 하는 것이 깨질 수 있다는 점이다.  
유명한 예제로 `oslo.utils==1.4.0` 을 설치 해보면 쉽게 이해할 수 있다. 
```shell
(venv) ➜  pip install oslo.utils==1.4.0
Collecting oslo.utils==1.4.0
Collecting iso8601>=0.1.9 (from oslo.utils==1.4.0)
Collecting six>=1.9.0 (from oslo.utils==1.4.0)
Collecting netifaces>=0.10.4 (from oslo.utils==1.4.0)
Collecting oslo.i18n>=1.3.0 (from oslo.utils==1.4.0)
Collecting netaddr>=0.7.12 (from oslo.utils==1.4.0)
Collecting pbr!=0.7,<1.0,>=0.6 (from oslo.utils==1.4.0)
Collecting Babel>=1.3 (from oslo.utils==1.4.0)
Collecting pytz>=2015.7 (from Babel>=1.3->oslo.utils==1.4.0)

oslo-i18n 3.24.0 has requirement pbr!=2.1.0,>=2.0.0, but you'll have pbr 0.11.1 which is incompatible.
```
`oslo.utils`는 `pbr==0.11.1`을 요구 하지만 또 다른 의존성 패키지인 `oslo.i18n`은 `pbr >=2.0.0` 이상을 요구한다.  
이와 같이 하위 의존성 패키지가 서로 양립할 수 없는 상황이 바로 Dependency Resolution이 깨진 것이다.

<br/>
![](pipenv_logo.png)#### 👍 Pipenv
**[Pipenv](https://pipenv.kennethreitz.org/en/latest/)**는 위에서 다룬 pip의 문제점을 해결할 수 있는 새로운 파이썬 패키지 관리자이다.  

`Pipfile`로 `requirements.txt`를 대체할 수 있으며, `Pipfile.lock` 파일을 생성해서 개발 환경과 프로덕션 환경에 동일한 패키지가 설치될 수 있도록 보장한다.  
그리고 보통 `Virtualenv`라고 하는 파이썬 가상 환경을 구성하는 기능도 포함하고 있기 때문에 그동안 `pip`와 `virtualenv`를 따로 사용했던 불편함도 개선할 수 있다.  

이전 챕터에서 다룬 Pyenv와 마찬가지로 MacOS 환경에서는 `$ brew install pipenv`로 설치하는 게 가장 좋다. Pipenv는 파이썬 패키지이기 때문에 `$ pip install pipenv`로도 설치할 수 있다.


#### ◆ Pipenv 사용법
새로운 파이썬 프로젝트를 시작할 때는 습관처럼 파이썬 가상 환경(virtualenv)부터 생성하자. 
```shell
$ pipenv --python 3.7.5
```
만약 pyenv를 사용하고 있고, 파이썬 3.7.x 버전이 설치되어 있다면 자동으로 연동된다.  

![](pipenv_python.svg)

아래 명령어는 `source ./venv/bin/activate`로 파이썬 가상 환경에 대한 터미널 세션을 활성화하는 것과 동일한 역할을 한다. 만약 현재 위치에 파이썬 가상 환경이 없다면 시스템 기본 파이썬 버전을 기준으로 가상 환경을 자동 생성한다.  
```shell
$ pipenv shell
```

파이썬 패키지를 설치하는 명령어는 pip를 사용할 때와 차이가 없다. 하지만 설치 후 패키지와 버전 정보가 담긴 `Pipfile`과 `Pipfile.lock`이 생성된다.  
프로젝트를 재설치할 때 이미 `Pipfile`이 있다면 그저 `$ pipenv install`을 수행하면 된다.  
```shell
$ pipenv install flask==1.1.1
```

<br/>
#### ◆ Pipenv가 좋은 점
만약 Pipfile에 패키지 버전을 정확하게 명시하지 않는다면 어떨까?  

Pipfile의 패키지 중 특정 패키지가 최신 버전이 나왔을 때 `$ pipenv install`을 실행하면 해당 패키지는 최신 버전으로 자동 업그레이드될 것이다.  
이 동작을 유닛 테스트가 충분한 커버리지를 확보한 개발 환경에서 수행한다면, 해당 패키지의 안정성을 검증할 수 있게 된다.   
이렇게 갱신된 `Pipfile.lock`을 개발 환경 및 프로덕션 환경에 동일하게 적용할 수 있게 됨으로써 더 이상 낮은 버전의 패키지를 오랜 기간 방치하게 될 위험성을 줄일 수 있게 된다. 


<br/>
## 3. 파이썬 가상 환경
Virtualenv로 알려진 파이썬 가상 환경은 시스템에 설치된 파이썬에 영향을 주지 않고, 격리된 환경에서 독립적으로 파이썬을 실행할 수 있고, 파이썬 라이브러리를 따로 설치될 수 있도록 해준다.  

파이썬 2와  파이썬 3 초반에는 Virtualenv가 표준 라이브러리에 포함되어 있지 않았기 때문에 [Virtualenv](https://virtualenv.pypa.io/en/latest/)라를 패키지는 직접 pip로 설치해서 사용했다. 
하지만 파이썬 3.3부터 `venv`라는 이름의 가상 환경 모듈이 표준 라이브러리로 들어왔다.
```shell
$ python3 -m venv venv
```

만약 Pipenv를 사용한다면, 이마저도 필요없게 된다. Pipenv는 파이썬 가상환경 기능도 제공하기 때문이다.  (위 내용 참고)


<br/>
## 4. 파이썬 코드 스타일
파이썬의 자랑거리 중 하나는 흔히 **PEP8**이라고 불리는 *파이썬 코드 스타일 가이드* 이다.  
PEP는 언어에 수용되었으면 하는 것들을 제안할 수 있는 제도이다. 그중 PEP8은 파이썬 코드 스타일 가이드에 대한 제안이 담겨 있다. 

PEP8의 내용을 몇가지 소개하면...

- 들여쓰기는 공백 4개를 사용한다. 
- 한 줄의 최대 길이는 79자를 넘지 않는다.
- 클래스와 함수 선언 전에 2개의 빈 줄을 넣어야 한다. (클래스의 메서드인 경우는 1개)
- 1개의 요소만 갖는 튜플(tuple)은 반드시 마지막 콤마를 붙인다. (ex. `bar = ("foo",)`)
- 모듈과 패키지 이름은 최대한 짧게 하되 소문자만 사용한다.
- 클래스 이름은 카멜케이스 규칙을 따른다.
- 함수와 변수명은 소문자와 언더스코어만을 사용한 조합을 사용한다. 
- 예외(Exception) 클래스 이름은 항상 "Error"를 접미사로 갖는다.
- 인스턴스 메서드의 첫번째 인자 이름은 `self`, 클래스 메서드의 첫번째 인자는 `cls`를 사용한다.
- (이하 생략)

파이썬 개발자라면 누구나 PEP8을 지키려고 노력할 것이다. 하지만 숙련된 파이썬 개발자라고 하더라도 가끔은 PEP8에 위배되는 코드를 작성할 가능성은 충분하다.   

그래서 보통 코드 스타일을 자동으로 검사해주는 도구를 사용해서 Git Commit 전이나 Git Push 전에 확인하는 과정을 수행하기도 한다.   
대표적인 코드 스타일 검사 도구로는 [Flake8](http://flake8.pycqa.org/en/latest/)과 [pycodestyle](https://github.com/PyCQA/pycodestyle)이 있다. 이 도구들은 모두 커맨드 라인 인터페이스(CLI)를 이용해서 사용할 수 있다. 

```shell
# Flake8
$ flake8 {path/to/code/to/check.py}

# Pycodestyle
$ pycodestyle --first optparse.py
```

![](flake8_foobar.svg)
<br/>
## 5. 파이썬 코드 포맷터
전 챕터에서 살펴본 **Flake8**이나 **Pycodestyle**은 PEP8을 기반으로 **코드 스타일 가이드를 검사해주는 역할만** 수행하기 때문에 검사 결과는 개발자 스스로 고쳐야 한다.   

처음 파이썬을 배우는 사람에게는 이 과정이 많은 도움이 될 수 있겠지만, 많은 양의 코드를 수정하거나 협업 프로젝트에서 실수로 Commit 될 위험이 있다.  
그러면 코드 스타일을 자동으로 검사하고, 교정해주는 도구는 없을까?

<br/>
#### 👍 Black - 타협하지 않는 코드 포맷터
[Black](https://github.com/psf/black)은 PEP8을 기반으로 코드 스타일을 검사하고, 자동으로 고쳐주는 포맷터이다.  
비슷한 기능을 가진 [autopep8](https://github.com/hhatto/autopep8), [yapf](https://github.com/google/yapf) 보다 더 강력하고 적극적으로 교정하는 편이다.  
그래서인지 Black의 공식 사이트에는 Black을 **Uncompromising Code Formatter** 이라고 소개하고 있다.

Black도 CLI를 이용한 명령어와 다양한 옵션을 제공한다. 
```shell
$ black {소스코드 파일 경로 또는 디렉터리}
```

![](black_foobar.svg)
Black에 대한 자세한 설명은 얼마전에 작성한 [파이썬 코드 스타일(pep8)을 Black으로 자동 포맷팅하기](https://jonnung.dev/python/2019/11/10/python-black-uncompromising-code-formatter/)를 참고하는 것을 추천한다. 


<br/>
## 6. 파이썬 모듈 패키징과 배포
#### ◆ 파이썬 패키징의 표준?
우리는 이미 파이썬 패키지를 설치하기 위한 도구로 pip와 좀 더 나은 Pipenv를 살펴봤다. 하지만 파이썬 패키징 역사는 이것보다 더 이전부터 표준화를 위한 노력이 존재했다. 아마 많이 봤을 법한 `setup.py` 가 그것이다. 

`setup.py`를 통한 파이썬 패키지 빌드와 설치는 표준 라이브러리에 포함되어 있는 **distutils** 모듈을 통해서 가능하다.
```python
from distutils.core import setup

setup(
    name="jonnung_py_pkg_by_distutils",
    version="0.1",
    description="Sample Python Package",
    author="Eunwoo Cho",
    author_email="jonnung@python.org",
    url="https://github.com/jonnung/",
    packages=["example"],
)
```

아래 명령어는 `setup.py`를 이용해서 패키지를 빌드하는 명령어이다. 
```shell
$ python setup.py sdist
```

distutils 개발은 2000년에 중단되었고, 다른 개발자들이 **[setuptools](https://pypi.org/project/setuptools/)** 라는 새로운 라이브러리를 개발하기 시작했다.  setuptools는 에그(Egg) 배포 포맷을 지원했고, `easy_install` 명령어를 제공했다.  

setuptools가 제공하는 `setup()`함수는 distutils의 `setup()`함수를 대체할 수 있고, 더 다양한 옵션들을 제공한다. 
```python
from setuptools import setup, find_packages

setup(
    name="jonnung_py_pkg_by_setuptools",
    version="0.1"
    description="Sample Python Package",
    author="Eunwoo Cho",
    author_email="jonnung@python.org",
    url="https://github.com/jonnung/",
    packages=find_packages(),
    setup_requires=[],
    dependency_links=[
        "git+https://github.com/django/django.git@stable/1.6.x#egg=Django-1.6b4",
    ],
    scripts=["main.py"],
    entry_points={}
)
```

setuptools는 Wheel 타입이라는 새로운 포맷을 지원하게 되었다. 
```shell
$ python setup.py bdist_wheel
```
<br/>
그러다가 setuptools 개발이 느려지자 개발자들은 setuptools 보다 장점이 더 많고, Python3를 지원하는 **distribute** 를 만들기 시작했다. 하지만 결국 distribute는 setuptools와 통합되었다.

이러한 일이 일어나는 동안 파이썬 표준 라이브러리 distutils를 대체하기 위한 **distutils2** 프로젝트가 시작되었고, 파이썬 3.3 표준 라이브러리에 'packaging' 이라는 이름으로 들어가려고 했으나 결국 프로젝트는 중단되었다.
지금은 **setuptools** 이 사실상 표준이며, 그나마 다시 개발이 활발하게 진행 중이라고 한다. 

살펴 보았듯 파이썬 패키징의 역사는 순탄하지 않았다. 그만큼 프로그래밍 언어의 패키징과 의존성 관리는 어려운 것이라는 것을 알 수 있다.

최근 [PEP 518](https://www.python.org/dev/peps/pep-0518/)을 통해 새로운 파이썬 패키지 명세가 제안 되었다. 이 제안은 `pyproject.toml`을 이용해서 파이썬 빌드 시스템에 필요한 최소 정보만 명시하고자 하는 내용이며, [TOML](https://en.wikipedia.org/wiki/TOML) 파일 형식을 사용해서 좀 더 읽기 쉬운 파이썬 패키지 명세를 작성하는 내용이다.  
`pyproject.toml`에는 선언적인 방법으로 패키지 종속성을 나열하고, 사전에 필요한 빌드 시스템을 지정할 수 있다.

<br/>
#### 👍 Flit으로 파이썬 패키지 빌드
[Flit](https://flit.readthedocs.io/en/latest/index.html)은 위에서 살펴본  PEP 518을 구현한 파이썬 패키징 빌드, 배포 도구다.  
`$ flit init` 명령어로 `pyproject.toml`파일을 쉽게 생성할 수 있다.
```
[build-system]
requires = ["flit_core >=2,<3"]
build-backend = "flit_core.buildapi"

[tool.flit.metadata]
module = "foobar"
author = "Jonnung"
author-email = "jonnung@hotmail.com"
home-page = "https://github.com/jonnung/foobar"
```

`[build-system]` 영역은 빌드와 관련된 데이터를 나타내며, 이 파일에서 필수로 존재해야 하는 부분이다. 이 내용이 생략된다면 pip는 `requires = ["setuptools", "wheel"]`로 간주한다.  
`build-backend`에 지정한 문자열은 빌드 동작을 수행할 파이썬 객체를 나타낸다.  

`[tool.flit.metadata]` 영역은 이 파이썬 프로젝트에 관련된 정보들을 명시한다.   

더 많은 Flit의`pyproejct.toml`작성 방법은 [Flit 공식 문서](https://flit.readthedocs.io/en/latest/pyproject_toml.html)을 참고하자.

<br/>
#### 👍 Flit으로 PyPI에 배포하기
`$ flit publish` 명령어는 파이썬 패키지를 wheel이나 sdist(tarball) 형태로 빌드하고, PyPI에 배포까지 가능하다.  
Flit은 파이썬 패키지를 배포할 때 공식 PyPI 서버를 기본으로 한다. 하지만 다른 패키지 인덱스 서버나 다른 계정으로 업로드를 하려면 몇 가지 설정이 더 필요하다.  

첫째, 사용자 OS 홈 디렉터리에 `.pypirc`파일을 생성한 뒤 아래와 같이 여러 파이썬 인덱스 서버를 저장해두고, Flit에서 `--repository`파라미터로 직접 지정해서 배포할 수 있게 한다.
```
[distutils]
index-servers =
   pypi
   testpypi

[pypi]
repository = https://upload.pypi.org/legacy/
username = jonnung

[testpypi]
repository = https://test.pypi.org/legacy/
username = jonnung
```

```
$ flit --repository testpypi publish
```

두번째 방법은 `FLIT_INDEX_URL` 환경변수에 패키지 인덱스 서버 URL을 저장 해둔다.  
하지만 `--repository` 파라미터를 사용하는 경우에는 무시된다. 

<br/>
## 마치며
지금까지 파이썬 개발 환경을 구성하기 위해 유용한 도구들과 사용법을 알아봤다.  
"가장 보통의"라고 한 이유는 그나마 보편적으로 많이 쓰이고 있는 것들과 나에겐 나름 익숙한 파이썬 개발 환경에서 많은 도움이 되었던 것들을 소개하고 싶었다.  
앞으로도 파이썬은 많이 변화하고, 더 좋아질 것이다. 그 과정에서 지금 최선이라고 생각했던 것들도 변하고 없어질 수 있다.  
하지만 계속 더 나은 도구를 만들고 공유하면서 서로 도움이 될 수 있는 문화가 계속되었으면 좋겠다.

![](ordinary_python_development_environment.jpg)