---
comments: true
title: "Python3 Formatted String Literals (aka f-string)"
date: 2018-10-02T11:39:54+09:00
tags:
  - python
categories:
  - python
url: /python/2018/10/02/python3-formatted-string-literals/
---

- [PEP 498 -- Literal String Interpolation | Python.org](https://www.python.org/dev/peps/pep-0498/) in Python 3.6
-  'f' 또는 'F' 를 앞에 붙인 문자열 리터럴
{{< highlight python >}}
bar = 'World'

f'Hello {bar}'
# 'Hello World'
{{< /highlight >}}

- _Formatted String Literals_ 또는 _f-sting_ 이라고 부른다
- 중괄호 `{}`로 감싸진 필드 안에 변수가 치환되며, 일반적인 파이썬 표현식도 실행된다. 심지어 Lambda 도 사용할 수 있다
{{< highlight python >}}
bar = ['a', 'b', 'c']

# 파이썬 표현식 실행
f'{(",".join(bar))}'
# 'a,b,c'

# Lambda 표현식
f'{(lambda x: x*2)(3)}'

# '6'
{{< /highlight >}}

- _triple-quoted_ 을 통해 줄바꿈 문자열도 사용할 수 있다
{{< highlight python >}}
f'''안녕하세요
저는 조은우입니다.
반갑습니다.'''

# '안녕하세요\n저는 조은우입니다.\n반갑습니다.'
{{< /highlight >}}

- `f-string` 표현식를 제외한 나머지는 보통 문자열이고, 이중 중괄호  `{{`, `}}`는 하나의 중괄호로 취급된다
{{< highlight python >}}
bar = 'Awesome Python'

f'{{ {bar} }}'
# '{ Awesome Python }'
{{< /highlight >}}

- 문자열 부분에서는 `\n`  같은 이스케이프 된 문자들도 사용할 수 있지만,  `f-string` 표현식 안에서는 백슬래시를 사용할 수 없을 수도 있다
{{< highlight python >}}
##### 잘못된 방법 #####
f'{\'quoted string\'}'

# 에러 출력 결과
# File "<stdin>", line 1
# SyntaxError: f-string expression part cannot include a backslash

##### 올바른 방법 #####
# 다른 타입의 quote를 사용한다
f'{"quoted string"}'
# 'quoted string'

# quote 를 출력하기 위해서는 따로 변수에서 선언한 후 치환 필드에서 사용한다
bar = '\'quoted string\''

f'{bar}'
# "'quoted string'"
{{< /highlight >}}

- `f-string` 표현식 내 _conversion flag_와 _format specifier_ 를 추가 할 수 있다.
    - [Conversion Flag](https://www.python.org/dev/peps/pep-3101/?#explicit-conversion-flag)
        - !r - `repr()` 사용해서 변환
        - !s - `str()` 사용해서 변환
{{< highlight python >}}
import datetime
bar = datetime.datetime.now()

str(bar)
# '2018-10-02 11:25:09.189744'

f'{bar}'
# '2018-10-02 11:25:09.189744'

f'{bar!s}'
# '2018-10-02 11:25:09.189744'

repr(bar)
# 'datetime.datetime(2018, 10, 2, 11, 25, 9, 189744)'

f'{bar!r}'
# 'datetime.datetime(2018, 10, 2, 11, 25, 9, 189744)'
{{< /highlight >}}
    - [Format Specifier](https://docs.python.org/3.6/library/string.html#format-specification-mini-language)
{{< highlight python >}}
bar = 2

f'{bar:10.2f}'
# '      2.00'


import datetime
bar = datetime.datetime.now()

f'{bar: %Y-%m-%d %H:%M:%S}'
# ' 2018-10-02 11:25:09'
{{< /highlight >}}

- Raw F-String 으로 선언하려면 'fr' 접두사를 붙인다
{{< highlight python >}}
fr'안녕하세요\n저는 조은우입니다.\n반갑습니다.'
# '안녕하세요\\n저는 조은우입니다.\\n반갑습니다.'
{{< /highlight >}}

- _f-string_ 은 % 포맷팅과 `.format()` 메소드보다 빠르다

- 참고 자료
    - [PEP 498 -- Literal String Interpolation | Python.org](https://www.python.org/dev/peps/pep-0498/)
    - [lexical_analysis | python.org](https://docs.python.org/3.6/reference/lexical_analysis.html)
    - [realpython.com | python-f-strings](https://realpython.com/python-f-strings/)
    - [https://cito.github.io/blog/f-strings/](https://cito.github.io/blog/f-strings/)

