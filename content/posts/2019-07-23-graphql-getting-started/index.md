---
title: "처음 만나는 GraphQL"
date: 2019-07-23T10:00:00+09:00
draft: false
toc: false
image: "/images/posts/graphql_logo.png"
tags:
  - graphql
categories:
  - graphql
url: /graphql/2019/07/23/graphql-getting-started/
description: GraphQL에 대한 소개와 기본 개념, 특징에 대해 다룬다. RESTful API와 비교해서 GraphQL이 갖는 장점과 어떤 문제를 해결할 수 있는지 살펴본다.
---
조만간 회사에서 새로운 프로젝트를 시작하게 될 예정이라 얼마 전부터 설계에 대해 여러 고민을 하고 있었다.  
가장 신경 쓰는 부분은 증가하는 동시 접속 사용자에게 점점 더 다양한 데이터와 정보를 노출하면서 발생하는 복잡성과 비효율에 대한 문제다.  
한 화면을 렌더링하기 위해 점점 더 많은 API를 호출하고, 그렇게 받아온 응답 데이터의 일부만 사용될 때 발생하는 낭비와 새로운 요구 사항이 생길 때마다 당장 해결에만 집중된 구현들(반복).  
이 모든 것들이 관리 비용 증가로 이어지고, 기술 부채에 따른 생산성 저하와 성능 하락의 원인이 되는 게 아닐까 생각한다.

내가 자주 하는 말 중에 '이런 고민은 우리만 하는 게 아니다'라는 말이 있는데 말 그대로 문제를 해결하기 위한 새로운 기술과 해결책이 이미 나와있을 수 있다고 생각한다. (그 반대의 경우도 있겠지만)  
그래서 새로운 기술 도입을 고려하거나 배우고 싶을 때 먼저 그 기술이 탄생한 배경을 찾아보게 된다.  

**GraphQL**도 처음 들었을 때는 대충 '뭔가 새로운 형태의 API일 것이다'라고만 알고 있었다. 그러다 이번 기회에 문제 해결을 위한 대안이 될 수 있지 않을까 하는 궁금증이 생겼고, 갈 길은 멀겠지만 일단 제대로 알아보려 한다.

</br>
![](graphql_logo.png)</br>
## GraphQL 이란?
나는 보통 어떤 기술에 대해 공부할 때 공식 사이트에서 제공하는 간략한 소개를 주의 깊게 보는 편이다.  
[https://graphql.org/](https://graphql.org/)에 나오는 GraphQL의 핵심은 아래와 같다.

> API를 위한 Query Language

- 이미 존재하는 데이터에 대해 쿼리를 수행하기 위한 런타임
- 클라이언트를 위해 데이터에 대한 완전하고, 이해하기 쉬운 설명과 필요한 것을 구체적이고 정확하게 요청할 수 있는 기능을 제공
- 시간이 지남에 따라 API를 쉽게 진화 시킬 수 있다

아직은 이 내용이 크게 와닿지 않는다. 앞으로 실제 GraphQL을 구현 하면서 더 깊게 과정이 필요할 것이다.

</br>
## GraphQL 특징

GraphQL은 2015년 7월에 처음 발표되었기 때문에 비교적 신생이면서 은근히 나온 지 조금 된 느낌을 받는다.  
이렇게 느끼는 이유는 "graphql" 이라고 검색했을 때 이미 기초적인 내용이 잘 정리된 글들이 꽤 많기 때문이다. (한글이든 영어든)

그렇게 조사한 내용에 바탕으로 다시 한번 GraphQL의 특징에 대해 정리해 보았다.

- **Query**는 일반적인 텍스트가 아닌 객체 구조로 표현되며, <u>어떤 데이터를 요청할지 기술한다.</u>
- Response에는 <u>Query에 정의한 필드와 동일한 형태의 데이터만 포함된다.</u>
- GraphQL 서비스(서버)에서는 <u>정적인 타입 시스템</u>을 사용해서 데이터를 표현하는 **Schema**가 존재하고, 각 타입의 필드에 대한 함수로 구성된다.
- 특정한 DB나 스토리지 엔진에 의존하지 않고, 데이터를 표현하는 위해 타입과 필드를 코드로 구성한다.
- **하나의 Endpoint**(`/graphql/`)를 사용함으로써 RESTful API에서 생기는 많은 Enpoint의 복잡성을 줄여줄 수 있다.
- **한번의 요청**으로 여러 리소스(예: DB)에서 원하는 데이터에서 가져올 수 있다.

</br>
## RESTful API vs GraphQL

GraphQL은 RESTful API와 자주 비교 된다. REST는 이미 많이 알려져 있고, RESTful의 원칙을 완전하게 구현하지 않았더라도 보편적으로 채택되는 API 서비스 형태이다.  
GraphQL이 담당하는 영역 자체가 REST가 차지하는 영역과 대체될 수 있기 때문에 비교 당하는 것이 당연하지 않을까 생각한다.

1. RESTful API
    - Resource마다 Endpoint를 갖게 된다.
    - 클라이언트마다 필요한 데이터를 각 Resource 종류별로 요청해야 한다. (요청 횟수가 늘어날 수 있음)
    - Endpoint가 늘어날 수록 관리하기 힘들어진다. (비슷하면서 다른 것들 생겨난다)
    - 요청과 응답 구조가 미리 정의되어 있다. 때문에 HTTP에 대한 Caching이 가능한 것이 장점이다.
2. GraphQL
    - 보통 단일 Endpoint를 통해 원하는 데이터를 요청할 필드를 Query에 담아서 전송하면, GraphQL 서비스는 해당하는 필드값만 반환한다.
    - 클라이언트에서 발생하는 N+1 문제를 해소할 수 있다.

</br>
## 마무리
지금까지 GraphQL에 대한 소개와 특징을 살펴봤다.  
GraphQL이 실제로 어떻게 사용 되는지는 공식 사이트 "[소개](https://graphql-kr.github.io/learn/)" 페이지를 가볍게 읽어보고, 이미 잘 정리된 글들도 많기 때문에 아래 참고한 글들을 살펴보는 것도 추천한다.

앞으로 GraphQL 서버나 클라이언트에서 Query하는 과정을 학습하고, 실습 하면서 조금씩 더 GraphQL을 이해하는 과정을 진행할 예정이다.

</br>
## 도움 받은 글 링크

[GraphQL과 RESTful API](https://www.holaxprogramming.com/2018/01/20/graphql-vs-restful-api/)  
<sub><sup>GraphQL과 RESTful API 비교</sup></sub>

[All about GraphQL #2, GraphQL은 무엇이고 왜 계속 어디선가 들리는 걸까?](https://velog.io/@jakeseo_me/2019-04-28-0904-%EC%9E%91%EC%84%B1%EB%90%A8-qgjv086kyi)  
<sub><sup>GraphQL 탄생 배경 및 Query와 Resolver에 대한 기본 설명</sup></sub>

[All about GraphQL #1, GraphQL(그래프QL) 이란 무엇일까?](https://velog.io/@jakeseo_me/GraphQL%EA%B7%B8%EB%9E%98%ED%94%84QL-%EC%9D%B4%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%BC%EA%B9%8C-jijuqs32wo)  
<sub><sup>다양한 디자인 패턴에 대해 GraphQL로 구현할 수 있는 부분에 대해 설명</sup></sub>

[The Anatomy of a GraphQL Query](https://blog.apollographql.com/the-anatomy-of-a-graphql-query-6dffa9e9e747)  
<sub><sup>GraphQL 파헤치기, 핵심 컨셉과 용어들 그리고 예제</sup></sub>

[(번역) Thinking in GraphQL](https://blog.cometkim.kr/posts/thinking-in-graphql-ko/)  
<sub><sup>GraphQL 캐싱에 대해 생각 해 볼만한 글</sup></sub>

[GraphQL과 Relay: 웹 애플리케이션 개발의 미래](https://blog.sapzil.org/2015/05/15/graphql-and-relay/)  
<sub><sup>조금 옛날 글이지만 GraphQL이 필요하게 된 배경에 대해 공감 가는 부분</sub></sup>