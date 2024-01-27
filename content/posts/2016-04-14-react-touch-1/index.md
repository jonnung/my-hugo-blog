---
comments: true
date: 2016-04-14T01:49:50Z
tags:
  - react
categories:
  - frontend
title: React 건드리기 1일차
url: /react/2016/04/14/react-touch-1/
---

## React, 일단 빠르게 이해하기
* 오직 **View** 만을 담당하는 **javascript** 라이브러리 (찔끔찔끔 조사할때마다 지겹게 봤던 내용)  
* View를 컴포넌트 단위로 구성하고, 이리저리 섞을 수도 있고, 재사용도 가능
* React가 빠른 이유는 내부에서 **Virtual DOM** 이라는 것이 변경된 부분에 대해서만 실제 DOM을 다시 랜더링 하기 때문
* **JSX** 는 React 개발의 편의성을 위한 문법
* JSX 는 브라우저 해석되지 않기 때문에 변환하는 과정이 필요. Just in time 방식으로 JSXTrasformer 라이브러리가 있었으나 **Babel** 에 흡수 되면서 사라짐(그런데 Babel 에서도 사라진듯?). 하지만 실제 Production 환경에서는 이 방식을 사용하는 것은 추천하지 않고, Babel 을 이용한 Pre compile 후 서비스 되는 것을 권장
* React 에는 ```props``` 와 ```state``` 라는 것이 있는데, ```props``` 는 읽기 전용 속성이고, ```state``` 는 변경될 수 있음  
* React 에서 데이터는 *한방향(One way)* 으로 흐른다

## Hello world 해보기
[https://facebook.github.io/react/docs/getting-started.html](https://facebook.github.io/react/docs/getting-started.html)

## 참고 자료
* [https://github.com/enaqx/awesome-react](https://github.com/enaqx/awesome-react)
* [https://github.com/koistya/react-static-boilerplate](https://github.com/koistya/react-static-boilerplate)
* [https://github.com/jarsbe/react-webpack-boilerplate](https://github.com/jarsbe/react-webpack-boilerplate)
* [https://github.com/facebook/react/issues/5497](https://github.com/facebook/react/issues/5497)

