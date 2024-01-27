---
title: "ASGI와 Uvicorn 그리고 Gunicorn과 함께 사용하기"
date: 2021-10-24T14:45:30+09:00
draft: false
toc: false
image: "/images/posts/unicorn.jpg"
tags:
  - python
categories:
  - python
description: ASGI와 Uvicorn의 관계, 그리고 왜 Uvicorn을 사용하는 지, 실제 운영환경에서 Uvicorn을 어떻게 실행하면 좋은 지 알아봅니다. 
url: /python/2021/10/24/asgi-uvicorn-with-guicorn/
---

최근 **FastAPI** 프레임워크의 인기가 높아지는 이유에 대해 개인적으로 생각으로 2가지 정도 꼽을 수 있을 것 같다.  

첫번째는 빠른 속도이다. FastAPI는 ASGI 서버인 [Uvicorn](https://www.uvicorn.org/)과 [Starlette](https://www.starlette.io/) 프레임워크를 기반으로 더 많은 기능을 제공하도록 개발 되었다.  
이번 글에서는 여기서 등장한 **ASGI**와 **Uvicorn**에 대해 다뤄볼 예정이다.

두 번째 이유는 공식 문서이다. FastAPI를 처음 배우고 애플리케이션을 작성할 때 오직 공식 문서만 보고도 모든 것을 해결할 수 있다.  
하지만 개발을 하다 보면 공식 문서만 보고 뚝딱 할 수 있는 경우가 많지 않다.  


그럼 본격적으로 ASGI와 Uvicorn에 대해 알아보자. 그리고 마지막에는 **Gunicorn**으로 Uvicorn 서버의 성능을 더 올릴 수 있는 방법을 소개한다.

<br/>

### ASGI
Python으로 웹 애플리케이션을 개발하고 있다면 **WSGI**에 대해 들어봤을 것이다.
WSGI는 웹서버와 Python 애플리케이션 사이에 통신하기 위한 인터페이스이다. 

간단하게 설명하자면, 보통의 웹 서버가 Python 애플리케이션을 실행하기 위해서는 WSGI 구현이 필요하다. 마찬가지로 Python 웹 애플리케이션도 WSGI 구현이 필요하다.  
결국 WSGI를 구현한 웹 서버는 WSGI를 구현한 Python 애플리케이션을 실행할 수 있게 된다.

그럼 ASGI는 무엇인가? 우선 ASGI는 WSGI보다 나중에 나온 신작(?)으로 WSGI를 계승하여 단점을 보완하고 Python의 AsyncIO 라이브러리를 이용한 비동기 코드를 처리할 수 있다는 장점이 있다.

여기 말하는 WSGI의 단점은 요청을 받고 응답을 반환하는 동작이 단일 동기 호출 방식으로 처리된다는 점이다. 오랜 시간 연결을 유지하는 Websocket 이나 긴 HTTP 요청을 처리하기에 적합하지 않다. 

ASGI는 이 부분이 단일 비동기 호출이 가능하도록 설계되었다. 
따라서 클라이언트로부터 여러 이벤트를 주고받을 수 있으며, 백그라운드 코루틴을 실행할 수 있게 된다.

<br/>

### Uvicorn
uvloop와 httptools 라는 것들을 이용해서 ASGI를 구현한 서버이다.  
uvloop는 NodeJS V8 엔진에서 사용하는 libuv를 기반으로 Cython으로 작성되었다고 한다.  
실제 성능 면에서 NodeJS와 다른 Python 비동기 프레임워크보다 훨씬 빠르다고 한다.  

<br/>

### Uvicorn을 Gunicorn과 함께 실행하기
Uvicorn은 단일 프로세스로 비동기 처리가 가능하지만, 결국 단일 프로세스라는 한계가 있기 때문에 처리량을 더 늘리기 위해서는 멀티 프로세스를 활용해야 한다.

Gunicorn 은 WSGI 서버이자 프로세스 관리자 역할을 수행한다.  
위에서 설명한 대로 Gunicorn은 WSGI 애플리케이션을 실행할 수 있다는 것이다.  
따라서 Django 애플리케이션을 Gunicorn 서버로 실행하는 것이 가능하다. ([참고](https://docs.djangoproject.com/ko/3.2/howto/deployment/wsgi/gunicorn/))

비슷한 원리로 Uvicorn이 Gunicorn의 워커(프로세스)로서 동작하게 할 수 있다.  
Uvicorn은 자체적으로 Gunicorn Worker Class(`uvicorn.workers.UvicornWorker`)를 포함하고 있는데 이 클래스 경로를 Gunicorn 실행 명령어(`-k 파라미터`)에 전달하면 된다.  

만약 Kubernetes 같은 컨테이너 오케스트레이션 시스템을 사용하고 있다면 굳이 Gunicorn 같은 프로세스 매니저가 필요하지 않을 수도 있다.   
그 이유는 도커 이미지를 구성할 때 메인 프로세스로 Uvicorn을 단일 프로세스로 지정한다고 해도 Kubernetes의 ReplicaSet을 이용해 컨테이너 복제를 조절할 수 있으며, 좀 더 정확하고 단순하게 도커 컨테이너를 관리, 관측할 수 있다는 장점이 있다.

<br/>

### 참고 자료
- [Introduction — ASGI 3.0 documentation](https://asgi.readthedocs.io/en/latest/introduction.html)
- [Uvicorn 소개](https://chacha95.github.io/2021-01-16-python6/)
- [Python REST API 개발로 알아보는 WSGI, ASGI](https://blog.neonkid.xyz/249)
- [WSGI를 사용하여 배포하는 방법 | Django 문서 | Django](https://docs.djangoproject.com/ko/3.2/howto/deployment/wsgi/)
- [Deployment - Uvicorn](https://www.uvicorn.org/deployment/#gunicorn)
- [Server Workers - Gunicorn with Uvicorn - FastAPI](https://fastapi.tiangolo.com/deployment/server-workers/)



