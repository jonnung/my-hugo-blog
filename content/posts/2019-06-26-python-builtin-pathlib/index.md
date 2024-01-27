---
title: "Python3, pathlib 모듈에 대해서"
date: 2019-06-26T10:30:00+09:00
draft: false
toc: false
images:
tags:
  - python
categories:
  - python
---

**pathlib** 모듈은 파일 시스템을 객체 기반으로 다루기 위해 [PEP428](https://www.python.org/dev/peps/pep-0428/)에서 시작 되었고, Python3.4에서 공식 빌트인 모듈로 추가 되었다. 파일 시스템을 객체 기반으로 다뤘을 때 장점은 `datetime`, `time`, `ipaddress` 모듈처럼 추상화된 인터페이스를 사용했을 때 얻는 이점과 동일하다. 

**pathlib** 모듈은 OS에 상관없이 경로를 나타내고, 다룰 수 있는 클래스들을 정의하고 있다.
이 클래스는 크게 **PurePath**와 **Path**로 나뉠 수 있다.

`PurePath`는 실제 파일 I/O와 관계없이 순수한 경로 연산만 담당하고, `Path`는 *Concret path* 라고도 부르며 시스템 I/O 연산까지 수행할 수 있다. 또한 `Path`는 `Purepath`를 상속해서 구현했기 때문에 PurePath가 제공하는 속성과 메소드도 사용할 수 있다.

보통의 경우 `Path` 클래스만 사용해도 되지만, `PurePath`는 다음과 같은 경우에 유용하게 사용될 수 있다.

1. Unix 시스템에서 Windows 경로를 다룰 때 (또는 그 반대)
2. 실제로 OS 파일 시스템에 접근하지 않고, 오직 코드상에서만 경로를 다룰 때

----
# PurePath

먼저 `PurePath`를 살펴보자.

이 클래스로 새로운 객체를 생성하려면 경로 문자열 또는 `PurePath` 객체를 위치 인자로 전달한다.
```python
from pathlib import PurePath

PurePath('setup.py')
# PurePosixPath('setup.py')

PurePath('/home', 'sample.txt')
# PurePosixPath('/home/sample.txt')

users_path = PurePath('/Users')
sub_path = PurePath('eunwoocho')
PurePath(users_path, sub_path)
# PurePosixPath('/Users/eunwoocho')
```

객체 타입이 `PurePosixPath` 인 이유는 실행 환경이 Windows OS가 아니기 때문이다. Windows 환경에서의 PurePath 클래스의 객체는 `PureWindowsPath`타입이 된다. 

[공식 문서](https://docs.python.org/3.6/library/pathlib.html#general-properties)에서는 이 두가지 타입의 차이를 *different flavour* 라고 표현한다. 무슨 의미인지는 알겠는데 어떻게 해석해야 할 지 몰라서 그냥 속으로만 음미하고 있다. (다..다른 맛?)

`Path` 객체는 불변한(Immutable) 특성이 있기 dict 타입에 키로 사용할 수도 있다.
```python
d = {PurePath('/etc'): 'etc'}
print(d)
# {PurePosixPath('/etc'): 'etc'}
```

그리고 같은 flavour 라면 비교 연산도 가능하다.
```python
PurePosixPath('foo') == PurePosixPath('FOO')
# False

PureWindowsPath('foo') == PureWindowsPath('FOO')
# True

PureWindowsPath('C:') < PureWindowsPath('d:')
# True
```

pathlib의 가장 큰 장점 중 하나는 **슬래시 연산자**를 사용할 수 있는 것이다. 슬래시 연산자를 통해서 Path 객체끼리든 경로 문자열과 함께 섞든 새로운 Path 객체를 만들어 낼 수 있다.
```python
p = PurePath('/etc')
p / 'init.d' / 'apache2'
# PurePosixPath('/etc/init.d/apache2')
```

PurePath 클래스에 정의된 속성과 메소드는 공식 문서를 참고하자. 

[https://docs.python.org/3.7/library/pathlib.html#accessing-individual-parts](https://docs.python.org/3.7/library/pathlib.html#accessing-individual-parts)
[https://docs.python.org/3.7/library/pathlib.html#methods-and-properties](https://docs.python.org/3.7/library/pathlib.html#methods-and-properties)

<br>

----
# Path (Concrete path)

Concrete path 라고 부르는 `Path` 클래스는 `PurePath`의 서브 클래스이다. `PurePath`가 제공하는 속성과 메소드를 모두 사용할 수 있으며, 추가로 실제 경로에 대한 **시스템 호출을 수행**하는 메소드를 정의하고 있다.

Concrete path 객체를 생성하는 방법은 `Path`, `PosixPath`, `WindowsPath` 클래스를 사용할 수 있다. 한가지 주의할 점은 Unix 시스템 상에서 `WindowsPath` 객체를 생성할 수는 없다.
```python
from pathlib import WindowsPath
WindowsPath('setup.py')

# Traceback (most recent call last):
#   File "<stdin>", line 1, in <module>
#   File "/usr/local/Cellar/python/3.7.0/Frameworks/Python.framework/Versions/3.7/lib/python3.7/pathlib.py", line 986, in __new__
#     % (cls.__name__,))
# NotImplementedError: cannot instantiate 'WindowsPath' on your system
```

<br>
위에서 말했듯 Concrete Path의 특징은 시스템 호출이다. 몇가지 대표적인 메소드를 살펴보면 쉽게 이해할 수 있다.


### Path.cwd()

*classmethod*, 현재 경로를 반환한다.
```python
from pathlib import Path
Path.cwd()
# PosixPath('/Users/eunwoocho')
```

<br>
### Path.home()

*classmethod,* 사용자의 홈 디렉터리를 반환한다.
```python
Path.home()
# PosixPath('/Users/eunwoocho')
```

<br>
### Path.exists()

해당 경로에 파일이나 디렉터리가 존재하는지 확인한다.
```python
home = Path('/Users/eunwoocho')
p = home / Path('sample.txt')
p.exists()
# False

p.touch()
p.exists()
# True
```

<br>
### Path.is_dir(), Path.is_file()

디렉터리인지 파일인지 확인한다.
```python
p.is_dir()
# False

p.is_file()
# True
```

<br>
### Path.iterdir()

Path 객체가 디렉터리인 경우 디렉터리 내부 컨텐츠를 순회하며 Path 객체를 반환한다.
```python
generator = home.iterdir()

next(generator)
# PosixPath('/Users/eunwoocho/Music')

next(generator)
# PosixPath('/Users/eunwoocho/Pictures')
```

그 밖에 디렉터리 생성(mkdir)과 삭제(rmdir), 파일 열기(open), 삭제(unlink), 읽기와 쓰기 등 다양한 메소드가 존재한다. 자세한 내용은 공식 문서를 참고하자.
[https://docs.python.org/3.7/library/pathlib.html#methods](https://docs.python.org/3.7/library/pathlib.html#methods)
