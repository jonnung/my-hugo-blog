---
comments: true
date: 2016-10-25T00:46:00Z
tags:
  - deview
categories:
  - conference
title: DEVIEW2016 첫째날(DAY 1) 참석 후기 - Part2
url: /review/2016/10/25/deview2016-day1-review-part2/
---

## 첫번째 세션 "Web payments API의 미래와 현재"
이 세션은 작년에 파이썬 스터디 모임에서 하면서 알게된 친구가 발표를 한다는 사실을 행사장 와서 알게 되었는데 엄청 반갑기도 했지만, 한편으로 대단하고 멋져보였다.
주제는 [W3C Web Payments API](https://www.w3.org/Payments/WG/) 표준에 대한 소개와 샘플 코드를 보고, API 의 상세 스펙을 살펴보는 순서로 진행 되었다. 발표는 이해하기 쉽도록 작은 소주제로 잘 분리하면서 각각은 짜임새 있게 구성 되었다고 느꼈다.

![Session-WebPaymentApi](/images/deview2016/IMG_6003.jpg)
![Session-WebPaymentApi-2](/images/deview2016/IMG_6009.jpg)  

1. 동기
  - 고객이 장바구니에서 이탈되는 비율 68%!!
  - 모바일에서 장바구니에서 PC보다 이탈율이 66% 더 높음
  - 이유는 form 을 입력하기 귀찮아서;; 컥
    (키보드 화면 많이 차지함, 계정도 만들어야되고..)

2. 기본 신용카드 결제
  - 브라우저 지원 현황: 크롬(ready), 삼성인터넷(almost), 파폭, 오페라(곧), 사파리(나중에)
  - 목적 "복잡한 폼을 없애고, 버튼 하나로 바꾸자!"
  - 해외 쇼핑몰 사이트는 국내 사이트와 달리 상품 페이지에서 장바구니 또는 결제까지 모든 단계가 현재 페이지에서 처리되는 UI 가 일반적임(복잡함)
  - 이미 브라우저는 사용자의 주소나 신용카드 정보등을 저장하고 있기 때문에 이를 활용해서 다음번 결제부터는 더욱 빠르고 쉽게 진행할 수 있음 (상점 입장에서도 사용자 카드 정보를 별도 보관함으로써 발생할 수 있는 높은 보안 유지 비용을 절감할 수 있다.)
  - 상점(merchant)가 지원하는 결제수단(카드사)과 브라우저가 지원하는 결제수단의 교집합의 결과를 UI 에서 표시하고 사용자는 이중에 원하는 결제수단을 선택할 수 있다.

3. Payment Apps (미래)
  - 사용자 디바이스에 설치된 payment app 목록을 보여준다.
  - 그 payment app UI로 이동해서 진행한다.
  - 브라우저에 등록된 payment app 목록과도 비교해서 가능한 결제수단의 교집합을 찾게 된다.
  - payment app 등록?
    - native payment apps (ios, 안드로이드, 타이젠 등)
    - web-based payment apps (https://sampay.com)
    - Install **Service Worker** 방식을 이용해서 payment app 을 등록하고, 정보를 업데이트 할 수 있다.
    - web page 변경없이 지원하는 payment app 을 추가할 수 있다.

4. Service worker
  - 특정 이벤트를 수신하는 daemon
  - document 와 별개의 생명 주기를 가지며, 브라우저가 종료되도 살이있다.
  - 제공하는 사이트에 의해 브라우저에 설치되고, 이벤트를 받은 브라우저에 의해서 필요에 따라 활성화 될 수 있다.
  - 적용 사례) 페이스북: 브라우저를 완전히 닫아도 페북 푸시가 온다.
  - payment app이 곧 service worker 이다.

참고:  
[http://www.slideshare.net/deview/121-web-payment-api](http://www.slideshare.net/deview/121-web-payment-api)  
[http://techhtml.github.io/2015/09/](http://techhtml.github.io/2015/09/)  

----

## 두번째 세션 "챗봇 개발을 위한 네이버 랩스 api"
원래 두번째 세션은 "REST에서 GraphQL과 Relay로 갈아타기" 를 들으려고 했었는데 키노트에서 들은 **AMICA** 에 대해서 더 알아보고 싶어서 계획을 변경했다.  
GraphQL 관련 세션은 나중에 녹화 동영상 올라오면 꼭 봐야겠다.  

![AMICA](/images/deview2016/IMG_6012.jpg)  

- AMICA
  - 의식하지 못하는 상황에서 적시적소에 적절한 서비스를 제공하기 위함
- 자연어를 이용한 인터페이스
- 왜? 제한된 인터페이스 환경과 복잡한 UX
- 메신저는 서비스 플랫폼이 되고 있다.
- 자연어 처리가 필요하다. (당연히)
- 자연어 처리 관련된 공부를 해야되는건가? 어렵다. 귀찮다.
- NLU API 동향:
  - 구글이 새로 출시한 '알로'라는 메신저앱을 출시, 그리고 api.ai 라는 회사를 인수함
  - 페북은 wit.ai 회사 인수
  - 삼성에서도 siri 를 만들었다는 viv 라는 회사를 인수
- 한국어 처리는?
  - 위에 나온 회사들 모두 한국어 지원을 하지만 잘은 못함
  - 교착어 (조사, 어미, 어간에 따라 단어마다 의미가 달라질 수 있다.)
  - 형태소 분석이 중요하다.
- AMICA.ai 라는 NLU API 서비스(10/24 부터 베타 테스트 신청)
  - 대화형 인터페이스를 만들 수 있는 엔진
  - 단어에 이름을 붙여주는 N(amed) E(ntity) R(ecognition)
  - 한국어를 잘 처리 하고자하여 한국어 먼저 시작했다.
  - AMICA.ai 가 자연어 분석에 대한 처리를 대신한다.
  - 많은 개발자가 AMICA 를 써줬으면 하는 이유는 많은 디바이스들로 플랫폼을 확장하고자함
- AMICA Developer Console
  - 25 개의 빌트인(Built-in) Entity(장소, 인명, 시간) 과 7개의 intent(yes, no, cancel) 지원
  - 모든걸 entity 들을 Built-in 할 수 없는 이유는 서비스 디펜던시 한 것들은 서비스 개발자들이 추가해야되는 것이 맞다.
- Dialogue management(DM)은 제공하지 않음
  - DM? 예를 들면 대화의 히스토리를 기반으로 변경된 정보를 처리하는 로직(이건 서비스 개발자의 몫)
  - AMICA는 한문장의 대화만 처리한다. (향후 대화 히스토리를 처리할 수 있도록 개선될 것이다.)

참고:  
[http://www.slideshare.net/deview/api-67563048](http://www.slideshare.net/deview/api-67563048)  

세션을 듣고 바로 AMICA.ai API 베타를 신청했다.   
최근에 와이프랑 챗봇 얘기 하면서 여러가지 아이디어를 생각 했었는데 자연어 처리 부분은 AMICA를 사용해서 좀 더 편하게 챗복을 개발할 수 있을 것 같다. 

----

## 세번째 세션 "Apache zeppelin과 오픈소스 비지니스"
Zeppelin에 대해서는 이름만 들어봤었고, 이번에 처음 실체를 알게 되었는데 [Jupyter](http://jupyter.org/) notebook 과 비슷한 개념의 툴 이였다.  

![ZEPPELIN-1](/images/deview2016/IMG_6017.jpg)  

- 사내 사이드 프로젝트로 시작됨
- 인터렉티브한 분석이 가능한 소프트웨어(웹 기반 노트북)
- 처음에는 주위 반응이 아예 없었음
- 유명해지고 싶어서 생각해낸 방법이 spark 메일링 하다가 관련있을만한 질문이 나오면 제플린 추천해버림ㅋㅋㅋ
- 스택오버플로에서도 답변으로 제플린 홍보를 많이 해봤으나 효과는 Spark 메일링이 훨씬 좋았음
- 홍보 한달만에 제플린으로 서비스를 만드는 회사가 발생
- 아파치 재단 프로젝트가 되기로 결심!
  -  아파치 재단 프로젝트가 된다는건?
   - 소스코드 소유권, 트레이드마크, 브랜드, 커뮤니티를 모두 아파치 재단으로 이전하게 된다.
   - 아파치 재단에서 모토는? 좋은 커뮤니티를 만드는게 목표
- 오픈소스?
  - 소스코드만 공개? vs 소스코드와 의사결정이 공개
- 아파치 프로젝트가 되기 전부터 모든 리뷰/토론을 온라인에서 하려고 노력
- 제플린을 통해 어떤 비지니스를 만들고자 했냐면..
  - 선순환 구조: 다양한 비지니스 허용 -> 사용자 증가 -> 시장 크기 증가
- 다양한 프로젝트와 integration 할 수 있도록 노력했다.
  예) hive, 구글 빅쿼리, 스팍, R, Python 등등
- 성공적인 오픈소스 프로젝트를 만들기 위해
  - 프로젝트가 주는 가치
  - 열린 사용자/개발자 커뮤니티
  - 서드파티 프로젝트/비지니스와의 integration
- 오픈소스로 비지니스를 하는 회사 => zeppelinX
- 제플린은 현재 아파치 프로젝트 중 Github star 12위!
![ZEPPELIN-2](/images/deview2016/IMG_6021.jpg)  
![ZEPPELIN-3](/images/deview2016/IMG_6022.jpg)  

참고:  
[http://www.slideshare.net/deview/api-67563048](http://www.slideshare.net/deview/api-67563048)  

----

## 네번째 세션 "Angular2 vs React"
6개월 전에 지인 몇분과 React 스터디를 했던적이 있고, 최근에 나온 Angular2도 학습해서 사용해 볼 계획이기 때문에 이 두가지 프레임워크에 대한 비교 발표는 오늘 진행되는 세션중에 가장 기대가 되는 세션이였다.  
발표는 네이버 다니시는 개발자 두분이 만담(?)형식으로 진행 했는데 중간에 티격태격하는 모습이 재밌기도 했다. (사전에 연습을 많이 하신듯 하다.)  
의외로 45분이라는 발표시간이 짧은지라 발표 속도가 좀 빠른편이긴 했다. 그래서 React 나 Angular2 둘중에 하나 정도는 잘 알거나 두가지 모두 적당한 개념과 특징 정도는 알고있는 상태여야 발표를 이해하는데 도움이 되겠구나 하는 생각이 들었다.  

![REACT-VS-ANGULAR2-1](/images/deview2016/IMG_6026.jpg)  

### 컴포넌트
- Angular2 : CSS 캡슐화도 됨~!! react는 webpack 같은걸로 css 를 지역화 할 수는 있으나 번거로움더 정이 안가는건 JSX!!!
- React: syntax sugar, 구조와 기능(행위)을 함께 자연스럽게 표현하고자 하는 의도가 있다.
- Angular2: react 는 항상 루트 element가 하나여야한다. 그리고 표준 HTML에 벗어나는 것들을 왜 사용하는가? className 속성같은거...
- React & Angular2: 이미 구조에 행위를 넣는순간 마크업은 순수하지 않게 된다. 이부분은 a2나 rt 모두 해결하지 못한 문제라고 할 수 있다.

### 데이터 동기화
- 뷰와 모델의 분리
- Angular2
  - 컴포넌트당 상태를 확인할 수 있는 Change detector 가 생겼다. ㅋㅋ(react의 virtual DOM 이 동작하는 원리와 거~~의 유사해보임)
- dom 이 아닌 모델에 집중

### 결론
- 프레임워크를 써야할지 말아야할지가 판단하는 것이 우선이다.
- Angular2
  - 문제에 대한 솔루션을 제안하고 있다.
  - 구글이 만드다보니 웹표준을 지키려는 노력이 많다.
  - 어떤 트랜드의 흔들리지 않는 표준이 필요하다!
- React
  - 선택은 개발자가 해야할 일
  - 처한 상황을 먼저 들여다보라

![REACT-VS-ANGULAR2-1](/images/deview2016/IMG_6027.jpg)  

참고:  
[http://www.slideshare.net/deview/114angularvs-react](http://www.slideshare.net/deview/114angularvs-react)  

----

## 다섯번째 세션 "Clean Front-end Development"
이 세션은 정리한 내용이 많지 않아 간략하게 후기만 남긴다.  
전체적인 내용의 핵심은 프론트엔드 개발에 대한 자신의 노하우를 중심으로 라이브러리나 프레임워크의 도움을 받지 않더라도 순수 javascript 또는 ES2015(아니면 그 미래)와 Babel 로 많은 것을 할 수 있다는 것에 대한 내용이였다.  
전체적인 내용에 대부분 공감 하는 편이다. 특히 jQuery를 더이상 쓰지 않고도 순수 JS로 Dom Selector역할을 아주 편리하게 할 수 있다는 의견에는 나 또한 긍정적으로 생각해보게 되는 계기가 되었다.  

참고:  
[http://www.slideshare.net/deview/115-clean-fe-development](http://www.slideshare.net/deview/115-clean-fe-development)

----

# 마치며
개인적으로 가장 기억에 남는 컨퍼런스는 한국에서는 최초로 열렸던 [Pycon2014](https://www.pycon.kr/2014/) 였는데 그때도 별로 남겨둔 내용이 없는것이 아쉬웠다.  
처음으로 컨퍼런스 참석 후기를 써보면서 느낀점은 하루동안 내가 보고 들은 것들을 글로 남기는데도 상당한 시간이 소요된다는 것과 들은 내용이 정확한지 다시 한번 확인 해보는 과정을 통해서 한번 듣고 잊혀질 수 있는 내용들을 좀 더 기억에 오래 남게 될 수 있게 되었다는 것이다.  
그리고 또한 지금까지 살아왔던 수많은 날 중에 어쩌면 오늘 하루만큼은 좀 더 의미있는 하루가 아니였을까 하는 생각도 들었다.   
앞으로 컨퍼런스를 참석이나 독서 후에는 짧게라도 후기를 남기는 습관을 만들어야겠다.  




