---
title: "Python으로 CLI 만들 때는 Typer"
date: 2021-01-16T00:45:06+09:00
draft: false
toc: false
image: "/images/posts/typer_logo.png"
tags:
  - python
categories:
  - python
url: /python/2021/01/16/python-cli-typer/
description: CLI 프로그램을 만들 때 반드시 필요한 --help 도움말, 실행 파라미터들과 필수 체크, 기본값 지정, 프로그레스바까지 다 갖췄지만 사용하기 쉬운 라이브러리 
---

#괜찮은오픈소스를소개합니다

간단한 명령어를 모아 놓거나, Crontab을 활용해 주기적으로 실행시킬 목적으로 Bash 스크립트를 작성할 때가 있다.  
하지만 단순한 명령어 조합을 넘어서 HTTP 요청을 보내거나 데이터를 파싱하고 조합하고, 중복 로직들이 많아지면 자연스럽게 Python으로 작성하는 게 장기적으로 낫다고 생각해서 선호한다.  

보통 이렇게 만들어지는 프로그램의 형태를 CLI(Command Line Interface)라고 하는데, 'Python은 배터리를 내장하고 있다'는 말처럼 CLI 프로그램을 만들 때 필요한 다양한 기능들을 이미 갖추고 있다.  
예를 들자면 스크립트를 실행할 때 전달한 Argument를 처리하는 [`argparse`](https://docs.python.org/ko/3/library/argparse.html), 실행 로그를 원하는 곳으로 보낼 수 있는 [`logging`](https://docs.python.org/ko/3/howto/logging.html), [sys](https://docs.python.org/3/library/sys.html) 모듈 안에는 표준 입출력/에러나 종료 처리(exit)를 위한 내장 함수들을 포함하고 있다.  

하지만 이 내장 모듈들을 가져다 사용하는 패턴은 매번 크게 다르지 않기 때문에 반복 작업이 될 수 있고, 정작 중요한 코드보다 차지하는 비중이 높을 때가 있다.  
구구절절 설명이 길었는데 이런 불편함을 해소하기 위해 괜찮은 라이브러리를 소개한다.  

## Typer 소개

**Typer**는 **FastAPI**의 CLI를 만들기 위해 개발된 형제 프로젝트라고 한다.  
만드는 개발자와 사용하는 사람이 모두 좋아하는 CLI 라이브러리가 되는 것이 목표인 것 같다.  

Typer는 Python3.6의 **Type hint**를 기반으로 하고 있기 때문에 IDE에서 지원하는 자동 완성 기능을 적극 활용할 수 있다.  

그리고 Typer 내부에는 Click이라고 하는 또 다른 CLI 라이브러리를 사용하고 있다.  
나는 Typer를 알기 전에 이 라이브러리가 Python으로 CLI를 만들 때 사용하는 가장 유명한 라이브러리로 알고 있었다.   


<br/>

## 바로 사용하기 좋은 기능들
### 프로그램 기본 구조

```python
import typer


def main():
    typer.echo("Hello World")


if __name__ == "__main__":
    typer.run(main)
```

Python으로 CLI 프로그램을 처음 시작할 때 거의 대부분 필요한 구문은 마지막 if 조건이다.   
이 구문의 의미는 이 Python 모듈이 메인으로 실행되는 것을 의미하는데 쉽게 말하자면, 다른 Python 모듈에서 import 되지 않을 때를 의미한다.  

이제 `typer` 모듈을 import 한 뒤 `run()` 메서드를 호출할 때 실행시킬 함수를 전달한다.   


<br/>

### 터미널 화면에 내용 표시하기
보통 터미널에 텍스트를 출력할 때 `print()`를 사용하지만, Typer가 제공하는 `echo()`함수를 사용할 수 있다.   
이 함수를 쓰는 이유는 일부 터미널 설정 차이에 따른 오류를 방지하고, 출력 결과에 색상 효과를 적용할 수 있기 때문이다.  

어떤 텍스트에 색상 효과를 적용하기 위해서는 `typer.style()`함수로 원하는 텍스트를 전달하고, 파라미터로 효과를 줄 수 있다.  

```python
greeting = typer.style(
    "hi",
    fg=typer.colors.RED,
    bg=typer.colors.WHITE
)

friend = typer.style(
    "jonnung",
    bold=True,
    underline=True
)

typer.echo(f"{greeting} {friend}")
```

`typer.echo()`의 결과는 기본적으로 `stdout`으로 전달되지만, `stderr`로 변경하려면 `err=True` 파라미터를 추가하면 된다.  

그밖에 `typer.style()` 과 `typer.echo()`를 합친 `typer.secho()`도 있다.  


<br/>

### 명령어 실행에 전달할 Argument와 Option
CLI 프로그램이 제공할 여러 가지 기능 중 원하는 기능을 선택하고, 세부적인 동작을 제어하기 위해 실행 명령어 다음에 전달하는 값들을 Argument와 Option이라고 부른다.  

보통 Argument와 Option을 구분하는 큰 차이점은 Argument는 필수이고, Option은 선택적이다. 그리고 Option을 전달할 때는 `--`와 Option 이름을 함께 명시하는 관행이 있다. (예: `--size`)  

```python
# sample.py
import typer


def main(name: str, lastname: str, formal: bool = False):
    if formal:
        typer.echo(f"Good day Ms. {name} {lastname}.")
    else:
        typer.echo(f"Hello {name} {lastname}")


if __name__ == "__main__":
    typer.run(main)
```

위 코드에서 `name`, `lastname`은 필수 Argument이고, `formal`은 선택적인 Option이다.   
즉, 함수의 파라미터가 기본값을 갖게 되면 Option을 자동으로 사용할 수 있게 된다.   

```shell
python sample.py eunwoo cho --formal
```

위 실행 명령어에서 Option으로 정의된 `--formal`의 중요한 특징이 있다.  
첫째, Option은 순서와 상관없이 동작한다. 둘째 Option이 `bool`타입으로 선언되면  `--no-formal`과 같은 반대 의미를 갖는 Option이 자동으로 생성된다.  

```shell
python sample.py --no-formal eunwoo cho 
```


<br/>

### 프로그램 종료하기
CLI 프로그램이 실행되는 과정에서 어떤 상황마다 적절하게 종료 처리를 해야 할 경우가 있다. 물론 꼭 에러가 발생하는 상황이 아닐 수 있다.  
`raise typer.Exit()`를 사용하면 에러 없이 프로그램을 종료시킬 수 있다.  
만약 `typer.Exit(1)`과 같이 0이 아닌 숫자 코드를 전달하는 경우 에러 상태로 종료시킬 수 있다.  

`raise typer.Abort()`는 Exit와 거의 같은데 단지 "Aborted!"가 출력되는 차이가 있다.   


<br/>

### 도움말 출력
Typer는 정의된 Argument와 Option의 타입과 기본값을 통해 `--help`만 전달했을 때 출력되는 도움말을 자동으로 생성해준다.   
그 외 CLI 프로그램의 간략한 설명을 표시하려면 메인 함수에 Docstring을 작성하면 된다.  

```python
import typer

def main(name: str):
    """
    너의 이름은?
    """
    typer.echo(f"내 이름은 {name}")

typer.run(main)
```

```shell
python your_name.py --help
Usage: your_name.py [OPTIONS] NAME

  너의 이름은?

Arguments:
  NAME  [required]

Options:
  --install-completion  Install completion for the current shell.
  --show-completion     Show completion for the current shell, to copy it or
                        customize the installation.

  --help                Show this message and exit.
```


<br/>

### 마치며
대표적인 CLI 프로그램인 git이나 쿠버네티스 클라이언트 kubectl 같은 것들을 쓰다 보면 사용법도 이해하기 쉽고, 도움말도 잘 되어 있으며 상당히 많은 기능들을 정교하게 수행한다고 느껴진다.   
**Typer**를 이용하면 이렇게 멋진 CLI 프로그램을 꽤 편하게 만들 수 있다.   
기능이 꽤 많기 때문에 공식 문서에서 양도 많다. 하지만 사용 예시와 예상 출력 결과를 직접 보여주는 구성으로 잘 되어 있고, 설명도 쉽게 되어 있기 때문에 일단 한번 쭉 훑어보고, 실제 개발할 때마다 찾아가며 활용하면 좋을 것 같다.   

