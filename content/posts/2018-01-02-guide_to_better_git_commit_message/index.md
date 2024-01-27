---
comments: true
title: "Guide to better Git - 좋은 커밋 메시지 작성하기 "
date: 2018-01-02T03:14:17+09:00
tags:
  - git
categories:
  - git
url: /git/2018/01/02/guide-to-better-git-commit-message/
---

# Guide to better Git
*Commit Message*

## 좋은 커밋 메시지를 작성해야 하는 이유?
- 커밋 로그 가독성
- 동료에 대한 배려
  - 협업
  - 코드 리뷰
- 오류 출처 찾기

### 커밋 로그 가독성
- 간결하고 일관성 있는 커밋 메시지는 가독성을 높여준다
  - 제한된 어휘와 단순화된 언어를 사용한다
- 읽지 않아도 되는 불필요한 정보와 중복을 제거한다
  - 꼭 읽어야 하는 내용만 기록한다

### 동료에 대한 배려
- 동료 개발자(미래의 나)와 변경사항에 대한 _맥락_ 을 공유할 수 있는 최고의 수단은 잘 다듬어진 커밋 메시지
- Pull Request(또는 Merge Request)를 리뷰할 때 코드 조각의 앞뒤 _맥락_ 을 살피는 노력을 줄일 수 있다

### 오류 출처 찾기
- 오류 메시지에서 표시되는 파일명과 오류가 발생한 줄 번호를 활용해서 해당하는 부분의 마지막 커밋의 출처를 찾을 수 있다

{{< highlight bash >}}
django-rest-framework git:(65791d8) $ git blame MANIFEST.in

04084c96 (Matthias Runge 2015-05-05 13:03:06 +0200 1) include README.md
04084c96 (Matthias Runge 2015-05-05 13:03:06 +0200 2) include LICENSE.md
65791d8c (Tom Christie 2017-12-21 10:17:59 +0000 3) recursive-include rest_framework/static *.js *.css *.png *.ico *.eot *.svg *.ttf *.woff *.woff2
abef84fb (Ryan P Kilby 2017-11-27 05:28:25 -0500 4) recursive-include rest_framework/templates *.html schema.js
37cfe903 (Matthias Runge 2017-12-21 11:00:43 +0100 5) recursice-include rest_framework/locale *.mo ff2fa7a8 (Benedek Kiss 2017-08-29 22:22:00 +0200 6) global-exclude __pycache__
ff2fa7a8 (Benedek Kiss 2017-08-29 22:22:00 +0200 7) global-exclude *.py[co]
{{< /highlight >}}

## 좋은 커밋 메시지 작성을 위한 약속
1. 제목과 본문을 한 줄 띄워 분리한다
2. 제목은 가급적 50자로 제한하며, 최대 69자를 넘지 않는다
3. 제목은 명령조로 작성한다
4. 제목 끝에 마침표(.)는 찍지 않는다
5. 본문은 적당한 위치에서 개행을 한다
6. 본문은 _어떻게_ 보다는 _무엇_ 과 _왜_ 를 설명한다 (코드는 보통 따로 설명될 필요가 없다)


## Tip. 제목은 명령조로 작성한다
- 좋은 제목
    - 가독성을 위해 서브시스템 X를 리팩토링한다 (Refactor subsystem X for readability)
    - Getting Started 문서를 갱신한다 (Update getting started documentation)
    - Deprecated된 메소드를 삭제한다 (Remove deprecated methods)
    - 버전 1.0.0으로 판올림한다 (Release version 1.0.0)

- 나쁜 제목
    - Y로 버그가 고쳐짐 (Fixed bug with Y)
    - X의 동작 변화 (Changing behavior of X)
    - 망가진 것을 좀 더 고친 것들 (More fixes for broken stuff)
    - 좋은 새 API 메소드 (Sweet new API methods)

## Tip. 적절한 제목인지 판단하는 규칙
```text
"만약 이 커밋이 적용되면 이커밋은 {커밋 제목행을 여기에}”
```
- _만약 이 커밋이 적용되면 이 커밋은_ **가독성을 위해 서브시스템X를 리팩토링한다**
- _만약 이 커밋이 적용되면 이 커밋은_ **Getting Started 문서를 갱신한다**
- _만약 이 커밋이 적용되면 이 커밋은_ **Deprecated된 메소드를 삭제한다**
- _만약 이 커밋이 적용되면 이 커밋은_ **버전 1.0.0으로 판올림한다**

## 좋은 커밋 메시지 샘플
{{< highlight bash >}}
$ git commit -m "가독성을 위해 회원가입 API 뷰셋 클래스를 리펙토링 한다"
{{< /highlight >}}

{{< highlight bash >}}
$ git commit -m "회원정보 수정 내역 API 뷰셋이 RetrieveViewSet 클래스를 상속하도록 수정한다

회원정보 수정 내역 조회 API URI를 설계를 /audit/user/{user_no} 형태로 변경한다.
그리고 외부에 제공되지 않기 때문에 기본 퍼미션 클래스를 적용한다.
"
{{< /highlight >}}

## 29CM 개발팀 커밋 메시지 스타일
1. 제목 앞에 앱(Django or Angular) 이름을 적는다
2. 제목 앞 또는 끝에 이슈 트래킹 아이디를 적는다

{{< highlight bash >}}
git commit -m "audit: 회원정보 수정 내역 API 뷰셋이 RetrieveViewSet 클래스를 상속 하도록 수정한다 (#NEXT29CM-1858)"
{{< /highlight >}}

## 참고
- https://item4.github.io/2016-11-01/How-to-Write-a-Git-Commit-Message/
- http://meetup.toast.com/posts/106

