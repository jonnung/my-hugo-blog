---
title: "파이썬 코드 스타일(pep8)을 Black으로 자동 포맷팅하기"
date: 2019-11-10T14:35:04+09:00
draft: false
toc: false
images:
tags:
  - python
categories:
  - python
url: /python/2019/11/10/python-black-uncompromising-code-formatter/
description: Black은 파이썬 소프트웨어 재단(PSF)에서 개발하고, PEP8을 기반으로 가독성이 더 좋은 코드 스타일로 고쳐 주는 자동 포맷터이다.
---
## PEP8
파이썬을 배우고 있거나 사용하는 개발자라면 대부분  [PEP8](https://www.python.org/dev/peps/pep-0008/) 에 대해 들어 봤거나 한두 번씩은 읽어 봤을 것이다. PEP8은 파이썬 코드 스타일에 대한 가이드이다.

파이썬 개발자라면 대부분 이 PEP8을 준수하려고 노력할 것이다. 하지만 오랜 시간 파이썬으로 개발해 온 개발자라도 PEP8의 내용을 전부 기억하고, 지키는 것은 힘들 수 있다.

그래서 보통 코드 스타일을 자동으로 검사해주는  [flake8](http://flake8.pycqa.org/en/latest/) 이나  [pycodestyle](https://github.com/PyCQA/pycodestyle)  같은 도구들을 함께 사용한다.  하지만 이 도구들은 코드 스타일을 체크해주는 역할만 하기 때문에 코드를 고쳐야 하는 것은 개발자 스스로 수행해야 한다.

처음 파이썬을 배울 때는 이런 식으로 직접 검사하고, 교정하는 것이 학습에 도움이 될 수 있지만, 코드량이 많거나 다른 개발자들과 협업하는 프로젝트에서 실수로 수정되지 않은 스타일의 코드가 커밋될 위험이 있다.

아래에서는 파이썬 코드 스타일을 자동으로 검사하고, 교정해주는 포맷터(formatter)에 대해 알아볼 것이다.

<br/>
## Black
![](https://raw.githubusercontent.com/psf/black/master/docs/_static/logo2-readme.png)
**[Black](https://github.com/psf/black)**은 파이썬 소프트웨어 재단(PSF)에서 개발하고, PEP8을 기반으로 가독성이 더 좋은 코드 스타일로 고쳐 주는 자동 포맷터이다.  
Black 말고도 비슷한 기능을 가진 코드 포맷터로는  [autopep8](https://github.com/hhatto/autopep8)과 구글에서 개발한  [yapf](https://github.com/google/yapf)도 있다. 하지만 Black은 다른 코드 포맷터보다 좀 더 적극적으로 코드 스타일을 교정하는 편이다.

Black 공식 Github에는 "*타협하지 않는*", "*단호한*" 의미를 풍기는 **Uncompromising Code Formatter**라고 소개하고 있으며, 개발자가 코드 스타일을 고치기 위해 고민하고 결정하는 시간을 절약할 수 있고 코드 스타일로 생기는 사소한 갈등을 방지해서 더 중요한 문제 해결에 집중할 수 있게 해준다.

<br/>
## 설치와 실행하기
파이썬 패키지 관리 도구(ex. PIP)로 `pip install black`  명령을 실행해서 설치할 수 있다. 
Black은 커맨드 라인 도구(CLI)이기 때문에 아래와 같이 `black` 명령어와 대상 파일 또는 디렉터리를 지정해서 코드 스타일 검사와 교정 대상을 지정할 수 있다. 

```shell
black {소스코드 파일 경로 또는 디렉터리}
```

본인의 파이썬 개발 환경에서 사용하는 IDE나 Editor에 Black을 바로 실행할 수 있도록 설정 해두면 더 편하고 빠르게 코드 스타일을 보정할 수 있다. 

<br/>
## Black의 코드 스타일 알아보기
### (1) 라인을 다루는 규칙
문장 끝에 남아 있는 공백은 제거 해주고, 한 줄에 완전한 표현식이나 문장을 간단하게 만들려고 한다. 
하지만 한 줄이 88자를 초과하게 되면 줄로 내린 뒤 들여쓰기로 처리한다.
```python
# 원본
def sample_function(template, file_path, header, debug=None, db_sync=False, *args, **kwargs):
    pass
```

```python
def sample_function(
    template, file_path, header, debug=None, db_sync=False, *args, **kwargs
):
    pass
```

만약 그래도 88자가 넘으면 콤마로 구분된 실행 파라미터들을 하나씩 분해해서 위와 동일한 규칙을 적용한다 
```python
def sample_function(
    template,
    file_path,
    title,
    contents,
    header,
    debug=None,
    db_sync=False,
    *args,
    **kwargs
):
    pass
```

<br/>
### (2) 라인 길이
위에서 라인을 다룰 때도 적용되었지만 Black은 기본적으로 **라인당 88자를 규칙**을 사용한다. 이 숫자는 PEP8의 80(또는 79)자에서 10%를 더한 숫자이다.
88자를 사용하는 이유는 80자 또는 79자를 고집하는 경우보다 더 짧은 파일(.py)을 만들어 낸다고 한다.

나도 예전부터 PEP8의 80자 제안은 잘 지키지 않는 편이었다. 한 줄에 완전한 문장이 다 들어올 때 가독성이 더 높은 것도 있고, 요즘 같이 고해상도 모니터에서 굳이 80자만 볼 필요가 있을까 싶었다. 
하지만 Black의 88자 규칙도 나쁘지 않다고 생각하는 이유는 한 줄의 길이가 길면 Diff를 할 때 확실히 비효율적이긴 하기 때문이다. 

만약 Flake8을 사용한다면 `max-line-length` 설정을 88자로 설정하거나 E501 에러를 제외시키고, [flake8-bugbear](https://github.com/PyCQA/flake8-bugbear)를 함께 사용해서 B950을 추가하는 것을 추천한다.

아래 `.flake8` 설정을 참고하자.
```yaml
[flake8]
max-line-length = 80
...
select = C,E,F,W,B,B950
ignore = E203, E501, W503
```

<br/>
### (3) 빈 줄(Empty Line)
PEP8에는 자주 빈 줄을 추가하는 것을 권장하지 않는다. 
클래스 레벨 Docstring 다음에 처음 나오는 속성이나 메서드 사이에는 1개의 빈 줄을 추가한다.

<br/>
### (4) Trailing Comma
라인 끝마다 콤마를 추가하는 것이 기본이다. 하지만 한 줄에 딱 맞는 표현식인 경우에는 콤마를 붙이지 않는다. 
이렇게 하면 88자로 제한된 길이를 초과하지 않을 가능성이 1% 증가 된다고 한다. 

튜플(tuple)의 경우 단 1개의 요소만 갖고 있다면 마지막 콤마를 제거하지 않는다. 그 이유는 데이터 타입이 변경될 위험이 있기 때문이다.  
```python
bar = (1,)
foo = (1)

print(type(bar))  # <class 'tuple'>
print(type(foo))  # <class 'int'>
```

<br/>
### (5) 문자열
작은따옴표(')보다 큰 따옴표(")를 사용한다.
큰 따옴표로 빈 문자열을 표현하면 글꼴이나 코드 하이라이팅에 관계없이 큰 따옴표 1개와 혼동되지 않는다.

기존에 작은따옴표를 컨벤션으로 정했는데 Black을 사용하려고 하면 어쩔 수 없이 큰 따옴표로 규칙으로 바꿔야 한다. 이 과정에서 의견이 분분할 수 있는데 이때는 다음과 같이 해보는 것을 제안하는 것도 좋을 것 같다.  

키보드에서 작은따옴표를 입력하는 게 큰 따옴표를 입력하기 위해 Shift키를 함께 누르는 것보다 편하고 빠르기 때문에 코딩할 때는 작은따옴표를 사용하자. 그리고 IDE에 Black을 자동 실행하도록 설정하거나 Commit 전에 Black으로 자동 교정하는 것이다.

<br/>
### (6) 줄 바꿈과 이항 연산자
Black은 이항 연산자 전에 줄 바꿈을 추가한다. 개정된 PEP8에 따르면 이항 연산자 전에 줄 바꿈 하는 것이 가독성이 더 좋다고 한다.  
하지만 Flake8을 사용한다면 `W503 line break before binary operator` 경고가 발생할 수 있는데 `W503`은 PEP8에 맞지 않기 때문에 flake8에 `W503`을 무시하도록 설정해야 한다.

```python
# 원본
income = (gross_wages +
          taxable_interest +
          (dividends - qualified_dividends) -
          ira_deduction -
          student_loan_interest)
```

```python
# Black 실행 결과
income = (
    gross_wages
    + taxable_interest
    + (dividends - qualified_dividends)
    - ira_deduction
    - student_loan_interest
)
```

<br/>
### (7) 슬라이스
문자열이나 리스트를 슬라이스 할 때 사용하는 콜론(`:`)은 이항 연산자와 동일하게 양쪽에 동일한 양의 공백이 있어야 한다. 하지만 슬라이스에 매개변수가 없는 경우에는 공백이 생략된다. 

```python
bar = [1, 2, 3, 4, 5]

foo = bar[2 - 1 : -1]
```

<br/>
### (8) 괄호
파이썬 문법은 선택적으로 괄호를 사용할 수 있다.
Black은 기본적으로 한 줄에 완전한 문장이 들어올 수 있거나 내부 표현식이 구분자로 더 쪼개질 수 없다면 괄호를 생략한다.

<br/>
### (9) 호출 체인
ORM 같은 API들은 호출 체인을 활용할 수 있다. 보통 이러한 코드 스타일을 Fluent Pattern이라고 한다.
Black은 호출 체인에서 각 메서드 호출 앞에 붙는 점(.)을 기준으로 코드 스타일을 교정한다.

```python
# 원본
manage = OrderManage.objects.select_related(
    'order_item_no', 'order_item_no__brand_no',
    'order_delivery_no', 'order_delivery_no__order_no', 'order_delivery_no__order_no__user_grade',
    'order_item_no__item_no', 'order_item_no__option_no', 'order_no'
).prefetch_related(
    Prefetch(
        'order_delivery_no__details',
        queryset=OrderDeliveryDetail.objects.select_related(
            'delivery_company_no'
        ).filter(is_deleted=const.FALSE, is_cancel=const.FALSE).all()
    )
).filter(is_deleted=False).order_by('-order_item_no__brand_no')
```

```python
# Black 실행 결과
manage = (
    OrderManage.objects.select_related(
        "order_item_no",
        "order_item_no__brand_no",
        "order_delivery_no",
        "order_delivery_no__order_no",
        "order_delivery_no__order_no__user_grade",
        "order_item_no__item_no",
        "order_item_no__option_no",
        "order_no",
    )
    .prefetch_related(
        Prefetch(
            "order_delivery_no__details",
            queryset=OrderDeliveryDetail.objects.select_related("delivery_company_no")
            .filter(is_deleted=const.FALSE, is_cancel=const.FALSE)
            .all(),
        )
    )
    .filter(is_deleted=False)
    .order_by("-order_item_no__brand_no")
)
```

<br/>
## 맺으며
코드 스타일 가이드는 어떤 프로그래밍 언어이던지 중요하다. 왜냐하면 대부분의 코드는 여러 개발자들에게 공유되고 전파되기 때문에 마치 같은 사람이 작성한 것 같이 일관성 있게 관리하는 것이 가독성과 생산성에 중요한 역할을 줄 수 있다.  

자신이 속한 그룹이나 개인마다 선호하는 코드 스타일 가이드를 정하는 것도 좋지만, 가장 중요하게 생각하는 가치는 **"가독성"**이다. 그렇기 때문에 보편적으로 따르는 관행적인 코드 스타일 규칙을 채택하는 것이 고민과 갈등을 줄이는 방법이 될 수 있다.
