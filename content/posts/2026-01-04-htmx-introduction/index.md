---
title: "htmx 입문: JavaScript 없이 동적인 웹 만들기"
date: 2026-01-04T10:00:00+09:00
draft: true
tags:
  - htmx
  - frontend
  - web
categories:
  - web
description: "htmx의 핵심 개념과 기본 사용법을 익히고, 간단한 예제를 통해 서버 주도 웹 애플리케이션을 만드는 방법을 알아봅니다."
---

## 학습 방향성

htmx를 효과적으로 학습하기 위해 다음과 같은 단계별 접근을 권장합니다.

### 1단계: 핵심 개념 이해
- htmx가 해결하려는 문제 이해 (SPA의 복잡성 vs 서버 주도 방식)
- HATEOAS(Hypermedia As The Engine Of Application State) 개념
- HTML을 반환하는 서버 응답의 장점

### 2단계: 기본 속성 학습
- `hx-get`, `hx-post`: HTTP 요청 발생
- `hx-target`: 응답을 삽입할 대상 지정
- `hx-swap`: 응답 삽입 방식 지정
- `hx-trigger`: 요청 발생 조건 설정

### 3단계: 실습 프로젝트
- 간단한 TODO 리스트
- 검색 자동완성
- 무한 스크롤
- 폼 유효성 검사

### 4단계: 심화 학습
- WebSocket, SSE 연동
- CSS 트랜지션 활용
- 기존 백엔드 프레임워크와 통합 (Django, Flask, FastAPI 등)

---

## 아웃라인

### 1. htmx란 무엇인가?

<!-- TODO: 작성 예정
- htmx의 정의와 철학
- 왜 htmx인가? (SPA 피로감, 서버 주도 방식의 회귀)
- 14KB의 가벼운 라이브러리
- 빌드 도구 불필요
-->

### 2. 설치 및 시작하기

<!-- TODO: 작성 예정
- CDN을 통한 설치
```html
<script src="https://unpkg.com/htmx.org@2.0.0"></script>
```
- npm 설치 방법
- 첫 번째 htmx 예제
-->

### 3. 핵심 속성 상세 설명

#### 3.1 hx-get / hx-post
<!-- TODO: 작성 예정
- AJAX 요청을 HTML 속성으로
- 예제 코드와 동작 설명
```html
<button hx-get="/api/data" hx-target="#result">
  데이터 가져오기
</button>
```
-->

#### 3.2 hx-target
<!-- TODO: 작성 예정
- CSS 선택자로 대상 지정
- this, closest, find 키워드
- 예제와 사용 시나리오
-->

#### 3.3 hx-swap
<!-- TODO: 작성 예정
- innerHTML (기본값)
- outerHTML
- beforebegin, afterbegin, beforeend, afterend
- delete, none
- 각 옵션별 사용 사례
-->

#### 3.4 hx-trigger
<!-- TODO: 작성 예정
- 기본 이벤트 (click, submit 등)
- 특수 이벤트 (load, revealed, intersect)
- 이벤트 수정자 (delay, throttle, changed)
- 예제: 검색창 자동완성
```html
<input type="text"
       hx-get="/search"
       hx-trigger="keyup changed delay:500ms"
       hx-target="#search-results">
```
-->

### 4. 실전 예제: 간단한 TODO 리스트

<!-- TODO: 작성 예정
- 서버 측 코드 (Python/Flask 또는 Node.js 예시)
- 클라이언트 측 HTML
- 추가, 삭제, 완료 처리
- 전체 동작 흐름 설명
-->

### 5. htmx와 기존 프레임워크 비교

<!-- TODO: 작성 예정
- React, Vue와의 차이점
- 언제 htmx를 선택해야 하는가?
- htmx가 적합한 프로젝트 유형
-->

### 6. 마무리 및 다음 단계

<!-- TODO: 작성 예정
- 학습 리소스 정리
- 심화 주제 미리보기 (WebSocket, SSE, 확장 기능)
-->

---

## 참고 자료

- [htmx 공식 문서](https://htmx.org/docs/)
- [htmx 공식 사이트](https://htmx.org/)
- [Hypermedia Systems (htmx 저자의 책)](https://hypermedia.systems/)
