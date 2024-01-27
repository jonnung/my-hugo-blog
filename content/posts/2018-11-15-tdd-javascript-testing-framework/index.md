---
comments: true
title: "자바스크립트 테스트 프레임워크 간단 비교"
date: 2018-11-15T11:39:54+09:00
tags:
  - javascript
  - tdd
categories:
  - frontend
url: /javascript/2018/11/15/tdd-javascript-testing-framework/
---

### 테스트 프레임워크 선택 
- [Jest Delightful JavaScript Testing](https://jestjs.io/en/)
    - 페이스북에서 만들었다. (Jasmine 기반)
    - 고통 없는(Painless), 즐거운(Delightful) 자바스크립트 테스트
        - 고통 없는 테스트는 없다
        - 자바스크립트 테스트는 어렵다
        - 웹사이트를 테스트하는 것은 매우 어렵다
        - 테스트 대상이 제한적이고, 구현이 복잡하며 느리고 들어가는 공수가 많다
    - **적절한 전략과 올바른 도구를 조합하면, 거의 모든 범위를 테스트할 수 있다**
    - Sinon.js 와 동일한 Assertion, Mocking, Spying 기능을 제공한다
    - 테스트 커버리지 리포팅 툴인 Istanbul 을 내장하고 있다
- [Mocha](https://mochajs.org/)
    - Jamine과 다르게 서드파티 Assertion, Mocking, Spying 도구를 사용한다
    - 그만큼 유연하고, 확장성이 뛰어남
- [Jasmine](https://jasmine.github.io/)
    - 오랜 시간 사용자와 커뮤니티에 의해 생성된 방대한 자료
    - 거의 모든 버전에서 Angular 지원
        
### 테스팅 도구가 제공하는 것들 
(Jest 와 Sinon을 사용한 예제로 구성)  

- Testing Structure
    - 테스트 할 대상을 테스트할 수 있는 기초적인 구조를 만든다.
    - 보통 JS 테스트 구조들은 *BDD* 형태로 작성된 경우를 많이 볼 수 있다

{{< highlight javascript >}}
// Jasmine 에서 제공하는 샘플 코드
describe("A suite", function() {
  it("contains spec with an expectation", function() {
    expect(true).toBe(true);
  });
});
{{< /highlight >}}

- Assertion Function
    - 테스트 대상이 반환하길 기대하는 값을 검사하는 함수이다
- Spies
    - 얼마나 많이 호출 되었는지 같은 함수에 대한 정보를 제공한다
    - 특정 함수에 인자를 기록 해두고, 호출을 한 후 값을 반환하거나 예외를 발생 시킨다
    - 알 수 없는 함수의 스파이

{{< highlight javascript >}}
const sinon = require('sinon');

test('인사 함수 호출 후 전달한 콜백이 호출된다', () => {
    // arrange
    var callback = sinon.spy();
    // act
    sample.greeting('world', callback);
    // assert
    expect(callback.called).toBeTruthy();
});
{{< /highlight >}}

- 이미 존재하는 함수를 감싸는 스파이

{{< highlight javascript >}}
const sinon = require('sinon');

test('인사 함수는 이름 저장 함수를 호출한다', () => {
      // arrange
    sinon.spy(sample, 'saveName');
    // act
    sample.greeting('jonnung');
    // assert
    expect(sample.saveName.called);
});
{{< /highlight >}}

- Stubbing or Bubbing
    - 선택된 함수를 그 함수가 기대하는 특정 동작(이나 값을 반환)을 하도록 설정된 함수로 교체합니다

{{< highlight javascript >}}
test('인사 함수는 전달된 이름을 로깅하는 함수를 반드시 한번 호출한다', () => {
    // arrange
    sinon.spy(sample, 'logging');
    sinon.stub(console, 'log').returns(true);
    // act
    sample.greeting('Eunwoo');
    // assert
    expect(sample.logging.calledOnce).toBeTruthy();
});
{{< /highlight >}}

- Mock and Fake
    - 테스트 하는 과정에서 특정 모듈이나 행동을 조작합니다
    - 참고 예제: [Fake XHR and server - Sinon.JS](https://sinonjs.org/releases/v7.1.1/fake-xhr-and-server/)

### 그 밖에 더 살펴볼 만한 테스팅 도구
- [jsdom](https://github.com/jsdom/jsdom)
    - 자바스크립트로 WHATWG DOM과 HTML 표준을 구현해서 브라우저 환경을 흉내 낼 수 있다
- [Istanbul](https://github.com/istanbuljs/nyc)
    - 유닛 테스트 커버리지 리포팅 툴
    - 구문, 라인, 브랜치, 함수 단위로 커버리지를 백분율로 제공
- [karma](https://github.com/karma-runner/karma)
    - 브라우저 환경에서 테스트를 실행 해주는 실행기 역할
- [Chai](https://github.com/chaijs/chai)
    - BDD/TDD Assertion Library
- [Sinon.js](https://github.com/sinonjs/sinon)
    - 독립적으로 Test Spy, Stub, Mock 을 제공하는 프레임워크
- [Wallaby](https://wallabyjs.com/)
    - IDE에 코드가 수정될 때마다 실시간으로 테스트 하고, 실패시 옆에 표시 해준다.
    - 유료지만 추천하는 사람이 많다고 함


### 참고한 원문
- [An Overview of JavaScript Testing in 2018 – Welldone Software – Medium](https://medium.com/welldone-software/an-overview-of-javascript-testing-in-2018-f68950900bc3)
