---
comments: true
title: "앵귤러 두걸음(Angular Two Steps)"
date: 2018-07-06T19:52:03+09:00
tags:
  - angular
categories:
  - frontend
url: /angular/2018/07/06/angular-two-steps/
---
### 앵귤러 ~~첫걸음~~ 두걸음
![앵귤러첫걸음](/images/angular_first_step.jpg)  

> 이 글은 '[앵귤러 첫걸음](http://www.hanbit.co.kr/store/books/look.php?p_code=B3348481708)(저자: 조우진)' 책을 읽고, 초반 부분만 정리한 내용입니다.  
> 개인적으로 앵귤러로 개발하면서 굉장히 도움을 많이 받은 책입니다. 하지만 앵귤러를 처음 시작하는 분들께서는 살짝 어렵게 느껴질 수 있을것 같습니다.   
> 그래도 저는 이 책을 통해서 첫걸음보다는 두걸음 이상 걷게 되었다고 생각합니다.    
> 직접은 아니지만 이렇게라도 저자께 감사하다는 말씀 드리고 싶습니다.  

#### 📖 일단 시작하기
- 타입스크립트
  - 타입은 언제 선언하는가? (철학)
    - 필요한 지점에 타입 정보를 기술하자
    - 타입스크립트를 사용한다고 해서 자바스크립트 코드의 모든 부분에 타입 정보를 일일이 추가할 필요는 없다
  - 타입 선언 정보
    - 타입스크립트는 자바스크립트 언어 명세에 없는 타입 정보를 타입 선언 파일(Typescript Declaration file) 형식으로 타입 정보만 추가로 내포
    - 확장자는 ```d.ts```
    - 타입스크립트의 타입 선언 정보는 기존의 자바스크립트 라이브러리를 사용하는데 반드시 필요한 파일
    - 타입 선언 정보가 없는 라이브러리를 사용할 때는 가능하면 타입 선언 정보를 받아야 한다.
    - 타입스크립트 2.0 에서는 NPM의 types 패키지에 주요 라이브러리의 타입 선언 정보를 모아서 등록하고 있다.

- 앵귤러 설치
{{< highlight bash >}}
$ npm install @angular/cli -g
{{< /highlight >}}
- 프로젝트 시작
{{< highlight bash >}}
$ ng new hello-angular
{{< /highlight >}}

</br>

#### 📐 구조
##### 🔩 모듈
- 앵귤러 안에서 관련된 요소를 하나로 묶어 어플리케이션을 구성하는 단위
- 모든 앵귤러 애플리케이션은 반드시 하나의 모듈을 가지며, 이 모듈을 _root module_ 이라고 하며 관례상 ```AppModule``` 클래스로 정의한다.
- _root module_ 이 필요한 이유는 앵귤러는 모듈 단위로 애플리케이션의 코드를 인식하기 때문이며, 계층적으로 자식 모듈을 가질 수 있다.
- 모듈은 포함된 컴포넌트들에 대해 완전한 컨텍스트를 제공하며, 다른 모듈에 있는 컴포넌트를 import 해서 사용할 수 있다.
- root 모듈에 포함된 root 컴포넌트는 bootstrap 하는 동안 로드 되지만, 자식 컴포넌트들은 router 와 template을 통해 로드 된다.
- 컴포넌트, 서비스, 지시자, 파이프를 모듈에 선언하지 않고는 애플리케이션을 사용할 수 없다.

##### 🔩 컴포넌트와 템플릿
- 컴포넌트: 뷰에서 일어나는 모든 일을 관리
  - 보통 컴포넌트 하나가 화면 전체를 담당하도록 만들지 않고, 기능이나 공통 관심사를 기준으로 화면 하나를 여러 컴포넌트로 나누어 구성
- 템플릿: 뷰를 구성할 마크업을 포함한 앵귤러에서 제공하는 문법으로 화면을 구성
- @Component 데코레이터
  - 클래스가 컴포넌트임을 알리는 표시이자 컴포넌트를 구성하는 정보(메타데이터)를 전달할 때 쓰는 통로
  - 메타데이터는 컴포넌트와 연결된 템플릿, 스타일(stylesheet) 정보 등을 정의
- 컴포넌트 생명 주기
  - https://angular.io/guide/lifecycle-hooks
  - 컴포넌트의 생애를 여러 시점으로 나누어 각 순간마다 고유한 이벤트를 정의하여 인터페이스로 정의
- 데이터 바인딩
  - 뷰와 컴포넌트에서 발생한 데이터의 변경 사항을 자동으로 일치시키는 데이터 바인딩 지원
  - 단방향 바인딩
      - 삽입식: 템플릿에 ```{{useName}}``` 같은 마크업으로 값을 출력
      - 프로퍼티 바인딩: DOM이 소유한 property를 \[ \]로 바인딩
    {{< highlight html >}}
<button type="button" [disabled]="langCode === 'ko'">한국어</button>
<img [src]='someImageUrl' width='128'>
<img [src]='{{someImageUrl}}' width='128'>
{{< /highlight >}}
      - 이벤트 바인딩: DOM의 이벤트 핸들러로 컴포넌트의 메서드를 사용할 수 있음. 이벤트 대상을 ( )로 선언한 후 핸들러로 사용할 메서드를 지정
    {{< highlight html >}}
<button type="button" (click)="setLangCode('ko')">한국어</button>
<div (mousemove)="printPosition($event)"></div>
<input type="text" (keyup)="myStr = $event.target.value" />
{{< /highlight >}}
      - $event는 앵귤러에서 이벤트 발생 시 전달하는 표준 이벤트 객체
  - 양방향 바인딩: 바인딩할 요소의 속성에 ```[(ngModel)]``` 과 함께 바인딩할 대상을 선언
      - ```NgModel``` 지시자를 사용하기 위해서는 ```FormsModule``` 을 Import
    {{< highlight html >}}
<input type="text" [(ngModel)]="myData" />
<select [(ngModel)]="mySelection">
  <option value="A">A value</option>
</select>
{{< /highlight >}}
      - 양방향 바인딩된 값이 변경되었을 때 실행되는 ```ngModelChange``` 이벤트를 이벤트 바인딩 방식으로 메서드를 지정할 수 있음

##### 🔩 서비스
- 서비스는 애플리케이션의 순수한 비지니스 로직이나 값을 담는 클래스
- 컴포넌트에서 비지니스 로직을 분리하기 위함
{{< highlight javascript >}}
import { I18nSupportService } from '../i18n-support.service';
{{< /highlight >}}
{{< highlight typescript >}}
construct(public i18nSupporter: I18nSupportService) {}
{{< /highlight >}}
- 컴포넌트와 달리 필수로 붙여하는 데코레이터가 없으나 ```injectable``` 이라는 데코레이터를 붙이는 것을 권장
  - 앵귤러의 의존성 주입기는 *Injectable* 데코레이터 여부로 인스턴스를 생성할때 서비스 클래스의 생성자에 의존성을 주입해 줄 필요가 있는지 결정
  - ```Inject``` 는 주입할 대상의 정보를 선언할 때 사용
  - 보통 주입할 대상 타입이 클래스인 경우에는 앵귤러가 타입 정보를 추론하여 자동으로 추론하여 주입하기 때문에 ```Inject``` 를 붙일 필요가 없음
    {{< highlight typescript >}}
import { Injectable, Inject } from '@angular/core';

@Injectable()
export class MySpecialLoggerService {
  constructor(@Inject('logLevel') logLevel: LogLevel) {
    this.logLevel = logLevel;
  }
}
{{< /highlight >}}
- 의존성 주입
  - 서비스를 임포트한 후 생성자(constructor)의 인자로 서비스 클래스를 추가
    - 생성자의 매개 변수에 접근 제어자(public 또는 private)을 붙이면 클래스의 속성으로 선언됨
    - 예를 들어 앵귤러는 생성자의 매개 변수로 선언한 ```I18nSupportService```를 ```new I18nSupportService()``` 자동 생성 해준다.
    - 의존성 주입기가 의존성을 주입해 주는 통로가 클래스의 매개 변수이다.
  - 컴포넌트 클래스에서 ```I18nSupportService``` 클래스(샘플)를 주입받기 위한 설정이 필요한데 의존성으로 주입할 것이라는 정보를 앵귤러 모듈에 선언한다.
    - ```@NgModule``` 데코레이터에 ```providers``` 값으로 배열에 담은 서비스 클래스들을 전달한다.
    - **providers**
      - 의존성 주입기가 클래스를 생성할 때 참고하는 공급자 타입의 값을 배열로 전달
      {{< highlight typescript >}}
@NgModule({
  declarations: [...],
  imports: [...],
  providers: [MySpecialLoggerService, {provide: 'logLevel', useValue: Loglevel.INFO}],
  bootstrap: [AppComponent]
})
{{< /highlight >}}

##### 🔩 지시자
- 앵귤러에서 의미하는 지시자는 "DOM을 다루기 위한 모든것"
- 컴포넌트도 지시자를 상속받는 인터페이스
{{< highlight typescript >}}
export interface Component extends Directive
{{< /highlight >}}
- 지시자는 템플릿을 동적으로 만들어주는 요소
- 구조 지시자(Structural Directive): DOM의 구조를 동적으로 처리할 때 사용
  - DOM 트리에 불필요하게 요소를 추가하지 않으면서 구조 지시자를 사용하기 위하여 *ng-container* 를 사용할 수 있다.
- 속성 지시자(Attribute Directive): DOM의 속성을 앵귤러 방식으로 관리할 때 사용

##### 🔩 파이프
- 파이프는 템플릿에 데이터를 보여 줄 때 가공이 필요한 경우 사용

</br>

#### 🎯 테스트
- 앵귤러 CLI 덕분에 테스팅 환경을 구축할 필요가 없음
- 카르마(karma) + 자스민(jasmine) + 앵귤러가 제공하는 테스팅 API
- 앵귤러가 제공하는 테스팅 환경
  - TestBed: 앵귤러 안에서 코드가 동작할 수 있는 테스트 전용 실행 환경
  - Fixture: 테스트를 위해 컴포넌트를 감싼 프록시와 같은 객체, 컴포넌트를 테스트할 때 이벤트의 실행 및 앵귤러의 실행 과정을 모의해 주는 기능

