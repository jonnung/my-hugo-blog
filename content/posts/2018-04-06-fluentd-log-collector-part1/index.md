---
comments: true
title: "Fluentd란 무엇인가? 구조와 기능 살펴보기"
date: 2018-04-06T14:00:00+09:00
tags:
  - fluentd
categories:
  - infra
url: /system/2018/04/06/fluentd-log-collector-part1/
---
 서버로 들어오는 요청이나 DB에서 실행되는 SQL, 각종 배치 스크립트가 실행되면서 남기는 로그들을 기본적인 파일 형태로만 남기고, 주기적으로 로테이팅 되기만 하고 버려지고 있었다. 
 
 가끔 서비스에 문제가 생겼거나 디버깅 목적으로 로그를 찾아볼 때는 모든 서버를 돌아다니면서 *find* & *grep* 해야 하는 번거로움이 있었다. (또 그렇게 찾아서 나온 결과가 엄청 많을 때는 터미널을 가득 채웠기 때문에 거북목을 하고서 눈이 빠지라고 모니터를 쳐다봐야 하는 헬게이트가 열리기도 했다)
 
 이렇게 불편하고 활용도가 떨어지는 부분을 보완하기 위해 [ELK](https://www.elastic.co/kr/elk-stack) 구성을 도입했고, 각 노드에서는 [Logstash](https://www.elastic.co/kr/products/logstash)가 로그 파일을 Tail 해서 적절한 가공 후에 Elasticsearch로 적재하게 했다.
하지만 어느 날 서비스 이용자가 몰리면서 서버가 갑자기 바빠지더니 덩달아 Logstash도 바빠졌다. 시스템 자원이 부족한 상황에서 Logstash가 잡아먹는 자원이 매우 아까운 상황이었다. 

힘들었던 고비를 넘기고 나니까 전체적인 로그 수집 프로세스를 재정비해야겠다는 생각이 들었다. 
현재 준비된 ELK 구성에서 가장 신속하게 개선할 수 있는 방향으로는 일단 로그 수집을 중앙화해서 수집 현황을 모니터링하고, 이슈 감지와 대응에 대한 비용을 줄인다. 그리고 각 서버에 배치된 Logstash를 보다 가벼운 대체품으로 교체하는 것으로 판단했다.

Fluentd를 조사하면서 위와 같은 구성이 가능할 것이라 확신했고, 현재는 안정적인 구성을 마친 상태이다. 이 글을 시작으로 앞으로 이어지는 글은 이 프로젝트를 진행하면서 조사했던 내용과 삽질 그리고 노하우에 대한 소개가 될 것이다.

먼저 Fluentd에 대해 알아보자!  
'_이런 개념이구나.. 이런 기능이 있구나.._'하면서 가볍게 살펴보는 것을 추천한다.

----

![fluentd-logo](https://raw.githubusercontent.com/fluent/fluentd-docs/master/public/logo/Fluentd_square.png)

### Fluentd 소개
[Fluentd](https://www.fluentd.org/)는 로그(데이터) 수집기(collector)다. 보통 로그를 수집하는 데 사용하지만, 다양한 데이터 소스(HTTP, TCP 등)로부터 데이터를 받아올 수 있다.  
 Fluentd로 전달된 데이터는 **tag**, **time**, **record(JSON)** 로 구성된 이벤트로 처리되며, 원하는 형태로 가공되어 다양한 목적지(Elasticsearch, S3, HDFS 등)로 전달될 수 있다.

Fluentd는 C와 Ruby로 개발되었다. 더 적은 메모리를 사용해야 하는 환경에서는 Fluentd forwarder의 경량화 버전인 [Fluentd-Bit](http://fluentbit.io/documentation/0.12/about/fluentd_and_fluentbit.html) 와 함께 사용할 수 있다. 
(최초 로그 수집 구조를 설계 할 때는 각 서버에 Fluent-Bit를 배치하려고 했었으나 HA 구성이 안 되는 이유로 모두 Fluentd로 구성했다. Fluent-Bit의 Load Balancing/Failover 기능에 대한 이슈는 [여기](https://github.com/fluent/fluent-bit/issues/203)에서 확인할 수 있다)
 
데이터 유실을 막기 위해 메모리와 파일 기반의 버퍼(Buffer) 시스템을 갖고 있으며, Failover 를 위한 HA(High Availability) 구성도 가능하다.

이 글은 Fluentd v1.0을 기준으로 작성되었다.

### Fluentd가 내부에서 처리하는 데이터의 특징
#### 이벤트 | Event
Fluentd가 읽어들인 데이터는 *tag*, *time*, *record* 로 구성된 **이벤트(Event)** 로 처리된다.  

- tag: 이벤트를 어디로 보낼지 결정하기 위한 구분값
- time: 이벤트가 발생한 시간
- record: 데이터 (JSON)

</br>

#### 태그 | Tag
Fluentd의 특징 중에 가장 핵심은 **태그(Tag)** 이다. 태그는 이벤트가 흘러가면서 적절한 Filter, Parser 그리고 Output 플러그인으로 이동할 수 있는 기준이 된다.  

아래 예시의 경우 *input_tail* 플러그인으로 전달된 이벤트에는 **dev.sample**라는 태그가 붙게 된다.
{{< highlight conf >}}
# tag 사용 예시
<source>
  @type tail
  tag dev.sample
  path /var/log/sample.log
</source>

<match dev.sample>
  @type stdout
<match>
{{< /highlight >}}

</br>

### Fluentd를 어떻게 써야할까?
먼저 Fluentd를 어떻게 쓸 수 있는지 알아보는 것이 이해에 도움이 될 것 같다.  

- 어플리케이션 로그를 한곳으로 모으기 (예: [Python 로그](https://docs.fluentd.org/v1.0/articles/python), [PHP 로그](https://docs.fluentd.org/v1.0/articles/php))
- 서비스 로그 모니터링 (예: Elasticsearch와 Kibana)
- 데이터 분석을 위한 hdfs로 적재하기
- AWS S3로 데이터 저장
- Stream 데이터 처리

_* 참고: [공식 문서 - Use Cases](https://docs.fluentd.org/v1.0/categories/logging-from-apps)_

</br>

### Fluentd 설정하기
Fluentd는 원하는 기능들을 플러그인 방식으로 설정 파일에 추가함으로써 사용할 수 있다.  
전체적인 동작 흐름은 Input -> Filter -> Buffer -> Output 단계로 동작하며, 세부적으로 7개의 플러그인(Input, Parser, Filter, Fomatter, Storage, Buffer, Output)을 목적대로 자유롭게 활용할 수 있다.

Fluentd를 설치하고, 작성한 설정 파일을 환경변수 **FLUENT_CONF**에 명시하거나 **-c** 실행 파라미터 에 전달하면 된다.
{{< highlight bash >}}
# export FLUENT_CONF="/etc/fluent/fluent.conf"

fluentd -c /etc/fluent/fluent.conf
{{< /highlight >}}

(이 글에서는 fleuntd 설치 방법과 실행에 대한 자세한 내용은 다루지 않는다. 하지만 이어지는 다음 글에서는 docker로 구성한 fluentd 실행 환경과 플러그인 설치, 그리고 실행과 배포에 대한 내용을 다룰 예정이다.)

설정 파일을 작성하기 위한 기본적인 문법은 공식 문서에서 가볍게 읽어보는 것을 추천한다. [자세히 보기](https://docs.fluentd.org/v1.0/articles/config-file)

</br>

### Fluentd 플러그인 살펴보기
fluentd로 할 수 있는 것들에 대해 알아보자.  
이 글에서는 모든 플러그인을 다루진 않고, 필자가 로그 수집 프로세스를 구성하면서 사용했던 플러그인 위주로 설명한다.  

#### 🔌 Input 플러그인
다양한 데이터 소스로부터 로그 데이터를 받거나 가져온다.

> in_tail

대표적인 in_tail 플러그인은 파일을 [tail](https://ko.wikipedia.org/wiki/Tail) 해서 데이터를 읽어 들인다.
단 파일의 시작부터 읽지 않으며, 로테이팅 되어 새로운 파일이 생성된 경우에만 처음부터 읽게 된다.  
그리고 해당 파일의 inode를 추적하기 때문에 **pos_file** 파라미터를 사용할 경우 fluentd가 재실행 되었을 때 파일의 마지막에 읽은 부분부터 다시 처리하게 된다.  

\* 참고: [공식 문서 - in tail](https://docs.fluentd.org/v1.0/articles/in_tail)


{{< highlight conf >}}
<source>
  @type tail
  path /var/log/nginx/access.log
  pos_file /var/log/fluent/nginx-access.log.pos
  tag nginx.access
  <parse>
    @type nginx
  </parse>
</source>
{{< /highlight >}}

</br>

> in_forward

forward라는 프로토콜을 사용해 TCP로 데이터를 수신할 수 있다. 보통 다른 Fluentd 노드로부터 데이터를 전달받기 위해 사용한다.  
forward로 전달되는 데이터는 JSON이나 Messagepack 형식으로 되어 있다.
fluentd 인스턴스를 [멀티 프로세스](https://www.fluentd.org/blog/fluentd-v0.14.15-has-been-released)로 실행 했을때는 각각의 프로세스가 동일한 forward 포트를 공유하게 된다.  

\* 참고: [공식 문서 - in_forward](https://docs.fluentd.org/v1.0/articles/in_forward)

{{< highlight conf >}}
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>
{{< /highlight >}}

----

#### 🔌 Parser 플러그인
전달 받은 데이터를 파싱하기 위해 \<parse> 섹션을 정의해서 사용한다.  
\<parse\> 섹션은 Input 플러그인(\<source\>), Output 플러그인(\<match\>), Filter 플러그인(\<filter\>) 안에서 정의하며, **@type** 파라미터로 사용할 Parser 플러그인 이름을 지정한다.  
기본적으로 내장된 Parser 플러그인은 _regexp_, _apache2_, _nginx_, _syslog_, _csv_, _tsv_, _json_, _none_ 등이 있다.

\* 참고: [공식 문서 - Config: Parse Section](https://docs.fluentd.org/v1.0/articles/parse-section)

</br>

> parser_regexp

정규표현식으로 데이터를 파싱할 수 있는 Parser이다.  
정규표현식 패턴은 **expression** 파라미터에 명시하며, 반드시 최소 1개 이상의 [<u>캡쳐 그룹</u>](https://www.regular-expressions.info/named.html)과 **time** 캡쳐 그룹이 필요하다.  
**time** 캡쳐 그룹의 키 이름은 **time_key** 파라미터로 변경할 수 있다.  
시간과 관련된 추가 파라미터로는 시간 포맷을 지정할 수 있는 **time_format**과 타임존을 설정하는 **timezone** 파리미터가 있다.

{{< highlight conf >}}
<parse>
  @type regexp
  expression /^(?<remote_addr>[^ ]+) "(?<http_x_forwarded_for>([^ ]+(, )?)+)" (?<http_x_client>[^ ]+) \[(?<timestamp>(0?[1-9]|[12][0-9]|3[01])/[a-zA-Z]+/\d\d\d\d:(00|0[0-9]|1[0-9]|2[0-3]):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9]) \+[0-9]+)\] "(?<request_method>\S+) (?<request_uri>[^"]+) (?<server_protocol>[^"]+)" (?<status_code>\d{3}) (?<body_byte_sent>\d+) "(?<http_referer>[^"]*)" "(?<http_user_agent>.+)" (?<request_time>[^ ]+)$/
  time_key timestamp
  time_format %d/%b/%Y:%H:%M:%S %z
  timezone +09:00
</parse>
{{< /highlight >}}

</br>

> parser_none

데이터를 행마다 새로운 필드 1개로 다시 담을 때 사용한다. 데이터를 필터/가공하지 않고, 다음 플러그인이나 다른 Fluentd 노드로 전달할 때 사용될 수 있다.

{{< highlight conf >}}
<parse>
  @type none
  message_key log  # JSON 형식의 "log" Key로 데이터가 담긴다
</parse>
{{< /highlight >}}

----
#### 🔌 Filter 플러그인
1. 특정 필드에 대해 필터링 조건을 적용
2. 새로운 필드를 추가
3. 필드의 삭제하거나 값을 숨김

</br>

> filter_grep

명시된 필드값에 정규표현식과 매칭되는 값만 필터링한다.

{{< highlight conf >}}
<filter dev.postgresql.*>
  @type grep
  <regexp>
    key log
    pattern ^statement: .+$
  </regexp>
</filter>
{{< /highlight >}}

- **key**: \<regexp> 섹션에서 정규표현식(pattern)을 적용할 필드명을 지정
- **pattern**: 정규표현식

</br>

> filter_parser

이벤트 레코드를 파싱해서 파싱된 결과를 다시 이벤트에 적용한다. *filter_parser* 플러그인은 데이터를 파싱하기 위해 Parser 플러그인을 함께 사용한다.

{{< highlight conf >}}
<filter dev.django-rest-api.*>
  @type parser
  key_name log
  reserve_data true
  
  <parse>
    @type regexp
    expression /^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<timestamp>\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (00|0[0-9]|1[0-9]|2[0-3]):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])(,[0-9]{3}))\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)$/
    time_key timestamp
    time_format %Y-%m-%d%H:%M:%S,%L
    timezone +09:00
  </parse>
</filter>
{{< /highlight >}}

- **key_name**: 파싱할 필드명 지정
- **reserse_data**: 파싱한 결과의 원본 필드를 유지

</br>

> filter_record_transformer

이벤트 레코드에 새로운 컬럼을 추가하거나 수정, 삭제할때 사용하는 플러그인이다.

{{< highlight conf >}}
<filter dev.django-rest-api.*>
  @type record_transformer
  <record>
    worker_name fluentd_multi
    tag ${tag}
    remove_keys sample
  </record>
</filter>
{{< /highlight >}}

- \<record> 섹션 안에 "NEW_FIELD: NEW_VALUE" 형태로 새로 추가할 컬럼을 명시
- **remove_keys** 파라미터에 배열 형태로 전달된 컬럼들을 삭제

</br>

#### 🔌 Output 플러그인
Output 플러그인은 \<match> 섹션에 정의하며, v1.0부터 Buffering과 Flushing에 대한 설정을 \<match> 섹션안에 \<buffer> 서브 섹션으로 정의한다.  

Buffering과 Flushing에 대해서는 3가지 모드를 제공한다.

1. **Non-Buffered mode**: 데이터를 buffer에 담지않고, 즉시 내보낸다.
2. **Synchronous Buffered mode**: _stage_ 라는 buffer chunk에 담고, 이 chunk를 _queue_ 에 쌓아서 처리한다. 
3. **Asynchronous Buffered mode**: Synchronous buffered mode와 동일하게 _stage_ 와 _queue_ 가 있지만 동기 방식으로 chunk를 만들지 않는다. 

Output 플러그인은 buffer chunk에 key를 지정할 수 있으며, key와 동일한 이름을 갖는 이벤트를 분리해서 chunk에 담도록 설정할 수 있다.
Buffer 설정에 대한 내용은 아래에서 자세히 다룬다.  

_* 참고: [공식 문서 - Output Plugins](https://docs.fluentd.org/v1.0/articles/parse-section)_

</br>

> output_stdout

이벤트를 표준출력(stdout)으로 내보낸다. Fluentd 설정을 만들기 초반에 디버깅용으로 자주 사용한다.
{{< highlight conf >}}
<match **>
  @type stdout
</match>
{{< /highlight >}}

</br>

> output_forward

다른 Fluentd 노드로 이벤트를 전달할때 사용하며, 반드시 1개 이상의 \<server> 섹션을 포함해야 한다.  
이 플러그인은 Load-Balancing, Fail-Over, Replication 기능을 설정하기 위한 파라미터들을 포함하고 있다.

{{< highlight conf >}}
<match **>
  @type forward

  <server>
    name another.fluentd1
    host 127.0.0.1
    port 24224
    weight 60
  </server>
  <server>
    name another.fluentd2
    host 127.0.0.1
    port 24225
    weight 40
  </server>
</match>
{{< /highlight >}}

</br>
**※ Load Balancing / Fail-over, Replication 파라미터 설정**  

- Load balancing
  - **weight**: \<server> 섹션에서 로드 밸런싱 가중치 설정
- Failover
  - **send_timeout**: 이벤트 전송시 타임아웃, 기본 60초
  - **hard_timeout**: 이벤트를 전달할 서버를 찾기 위한 고정 타임아웃, 기본 ```send_timeout```과 동일
  - **heartbeat_interval**: heartbeat 간격, 기본 1초
  - **phi_thresthold**: 대상 서버 탐지 실패시 사용할 임계치. 이 값은 ```heartbeat_interval``` 보다 반드시 커야 한다.
- Replication
  - \<secondary> 섹션: 모든 서버를 사용할 수 없을때 백업 설정
  - [Copy 플러그인](https://docs.fluentd.org/v1.0/articles/out_copy)으로 이벤트를 복사해서 여러 다른 Output 으로 보낼 수 있다.

</br>

> output_elasticsearch

Elascticsearch로 이벤트 레코드를 전송한다. 레코드 전송은 Bulk 단위로 이뤄지기 때문에 최초 전달받은 이벤트가 즉시 ES로 전송되지 않는다.  
[output_elasticsearch](https://github.com/uken/fluent-plugin-elasticsearch) 플러그인은 fluentd에 기본으로 포함되어 있지 않기 때문에 추가 설치가 필요하다.
{{< highlight conf >}}
<match **>
  @type elasticsearch
  hosts 127.0.0.1:9200,127.0.0.1:9201
  index_name django-rest-api
  type_name django-rest-api
  include_timestamp true
  time_key timestamp
  include_tag_key true
  tag_key fluentd_tag
</match>
{{< /highlight >}}
</br>

**※ ES, Index 관련 파라미터 설정**  

- **hosts**: ES 클러스터의 각 노드 IP와 Port를 콤마로 구분해서 지정
- **index_name**: Index 이름
  - ```logstash_format``` 파라미터를 *true* 로 설정하면 ```index_namm``` 파라미터는 무시되며, logstash 에서 사용하는 형태로 *logstash-2018.04.04* 형식으로 자동 부여된다. 
  - 추가로 ```logstash_prefix```, ```logstash_prefix_separator```, ```logstash_dateformat``` 옵션을 지정하면 logstash 스타일 Index 이름 형식을 변경할 수 있다. (ex. #{logstash_prefix}-#{formated_date}) [자세히 보기](https://github.com/uken/fluent-plugin-elasticsearch#logstash_format)
- **type_name**: [Type](https://www.elastic.co/guide/en/elasticsearch/reference/current/_basic_concepts.html#_type) 이름, 이 값을 지정하지 않을 경우 기본값은 'fluentd'
- **include_timestamp**: ```logstash_format``` 파라미터를 사용 했을때 추가되는 @timestamp 필드만 별도로 추가
- **time_key**: 기본적으로 로그가 수집된 시간이 @timestamp 필드의 값이 되지만, 이 파라미터에 지정된 필드가 @timestamp 필드의 값으로 사용된다.
- **include_tag_key**: Fluentd 태그를 포함 시킨다. 
- **tag_key**: Fluentd 태그를 저장할 필드 이름

</br>

**※ Index, Type 이름을 동적으로 생성하기**  

fluentd 태그명에 있는 문자열들을 조합해서 Index, Type 이름이 동적으로 생성되도록 할 수 있다.  
이 기능을 사용하기 위해서는 플러그인 이름을 기존 *@type elasticsearch* 에서 *@type elasticsearch_dynamic* 으로 변경해야 한다.

{{< highlight conf >}}
<match dev.django-rest-api.*>
  @type elasticsearch_dynamic
  hosts 127.0.0.1:9200,127.0.0.1:9201
  index_name ${tag_parts[0]}-${tag_parts[1]}-${Time.at(time).getutc.strftime(@logstash_dateformat)}  # eg. dev-django-rest-api-2018.03.08
  type_name ${tag_parts[1]}  # eg. django-rest-api
</match>
{{< /highlight >}}


----
#### 🔌 Buffer 플러그인
buffer 플러그인은 Output 플러그인에서 사용된다. 
buffer에는 *chunk* 들의 집합을 담고 있으며, 각 *chunk* 에는 이벤트들의 묶음이 저장된 하나의 [Blob](https://ko.wikipedia.org/wiki/%EB%B0%94%EC%9D%B4%EB%84%88%EB%A6%AC_%EB%9D%BC%EC%A7%80_%EC%98%A4%EB%B8%8C%EC%A0%9D%ED%8A%B8) 파일이다.  
이 *chunk* 가 가득차게 되었을때 다음 목적지로 전달된다.  
buffer는 내부적으로는 이벤트가 담긴 *chunk*를 저장하는 "**stage**" 영역과 전달되기 전 대기하는 *chunk* 를 보관하는 "**queue**" 로 나뉜다.
![fluentd-buffer-overview](https://docs.fluentd.org/images/fluentd-v0.14-plugin-api-overview.png)

※ chunk 전달 실패에 대한 재시도 파라미터  

*chunk* 를 목적지로 전달할 수 없는 상황이 발생했을때 fluentd는 기본적으로 재시도 횟수를 배수로 증가 시킨다.  

- **retry_wait**: 최초 재시도를 하게 되는 시간
- **retry_exponential_backoff_base**: 재시도 횟수를 배수로 증가 시키기 위한 기준값 N
- **retry_type**: 기본값은 ```exponential_backoff```, ```periodic```으로 변경하면 주기적으로 재시도 하도록 할 수 있다.
- **retry_randomize**: 재시도 간격은 기본적으로 랜돔한 값으로 정해진다.  이 파라미터를 *false* 로 설정할 경우 이 동작을 끌 수 있다. 
- **retry_max_interval**: 최대 재시도 기간
- **retry_max_times** 와 ```retry_timeout```이 초과하게 되면 ```queue```에 있는 모든 chunk들은 제거된다.
- **retry_timeout**: 재시도 시간 초과
- **retry_forever**: 영원히 재시도
- **retry_secondary_threshold**: Secondary로 재시도하기 위한 임계치, 이 비율을 넘게 되면 chunk는 secondary로 전달된다. 

위 파라미터들은 모두 기본값이 설정되어 있기 때문에 모두 설정할 필요는 없다. [자세히 보기](https://docs.fluentd.org/v1.0/articles/buffer-section#retries-parameters)


### 마치며
지금까지 살펴본 Fluentd의 개념과 기능들을 활용해 다음 글에서는 간단한 샘플 구성을 작성해보고, 직접 실행하는 가이드를 정리할 예정이다.


### 참고
- Fluentd 공식 사이트: [Fluentd | Open Source Data Collector | Unified Logging Layer](https://www.fluentd.org/)
- Fluentd 공식 문서: [Quickstart Guide | Fluentd](https://docs.fluentd.org/v1.0/articles/quickstart)
- 도움 받았고, 함께 보면 좋은 글
  - [조대협의 블로그 :: 분산 로그 & 데이타 수집기 Fluentd](http://bcho.tistory.com/1115)
  - [슭의 개발 블로그: Fluentd - Pluggable log collector](http://blog.seulgi.kim/2014/04/fluentd-pluggable-log-collector.html)
  - [Fluent Bit: Log Forwarding at Scale](https://www.slideshare.net/edsiper/fluent-bit-log-forwarding-at-scale?qid=e77a1d9a-b603-41f9-8e9f-7bf6dbf0c921&v=&b=&from_search=3)
