---
comments: true
title: "Elasticsearch 검색(\_search) API 사용법과 Query DSL 요약 정리"
date: 2018-05-08T21:36:00+09:00
tags:
  - elasticsearch
categories:
  - infra
url: /elasticsearch/2018/05/08/elasticsearch-search-api-query-dsl-summary/
---
### 사전 지식
- Elasticsearch는 검색을 위한 REST API를 제공한다.
- 검색은 인덱스(Index) 또는 타입(Type) 단위로 수행할 수 있다.
- 검색 결과는 JSON 형식으로 반환한다.
  
  
#### 💻 터미널에서 curl을 이용해서 검색 요청
{{< highlight bash >}}
# 검색 요청 샘플 살펴보기
$ curl 'http://127.0.0.1:9200/books/_search?q=title:awesome&pretty'
{{< /highlight >}}

{{< highlight json >}}
### 결과
{
  "took": 5,  # 검색에 소요된 시간(ms)
  "_shard": {  # 샤드 정보
    "total": 2,
    "successful": 2,
    "failed": 0
  },
  "hits": {
    "total": 1,  # 결과 개수
    "max_score": 0.3708323,  # 검색 결과 중 가장 높은 스코어
    "hits": {}  # 검색 결과 상세
  }
}
{{< /highlight >}}

### 1. Querystring 으로 검색하기
- 🔍 *GET* /_all/_search?q=title:awesome
  - 모든 인덱스에서 검색을 수행
  - ```q```는 기본 검색 파라미터
  - ```q```의 값으로 ```검색필드:검색어```를 전달
  
  
- 🔍 *GET* /_all/_search?q=title:awesome&size=50
  - 검색된 결과 도큐먼트를 몇 개까지 표시할지 지정
  
  
- 🔍 *GET* /books,videos/_search?q=title:awesome
  - 여러 <u>인덱스</u>를 동시에 검색
  - 검색할 대상 인덱스를 쉼표(,)로 구분
  
  
- 🔍 *GET* /books/_search?q=title:awesome%20AND%20elastic
  - 여러 <u>검색어</u>를 동시에 검색
  - 검색어를 ```AND``` 또는 ```OR```로 구분
  - 공백으로 구분하면 기본 ```OR```로 취급, 공백은 [URL Encode](https://en.wikipedia.org/wiki/Percent-encoding) 처리 필요 (%20)
  
  
- 🔍 *GET* /books/_search?q=title:awesome&_source=false
  - 검색 결과에서 도큐먼트 내용을 표시하지 않음
  - hit 수와 score 등의 메타 정보만 출력
  
  
- 🔍 *GET* /books/_search?q=title:awesome&fields=title,author
  - 검색 결과에 표시할 필드를 지정
  
  
- 🔍 *GET* /books/_search?q=author:jonnung&sort=title:desc
  - 검색 결과를 ```sort```로 지정한 필드를 기준으로 정렬
  - 주의할 점은 정렬 기준 필드에 포함된 단어들을 기준으로 오름차순/내림차순에 따라 가장 높은 순위를 가진 단어를 선택하고, 선택된 단어로 다시 도큐먼트를 정렬
  - 정렬 필드 전체를 기준으로 결과 도큐먼트를 정렬하고자 한다면 해당 필드가 _not_analyzed_ 로 매핑 설정이 되어 있어야 함
    (즉 해당 필드의 값 전체가 하나의 Term이 된다. Term이 무엇이냐? 계속...)
  
  
### 2. QueryDSL로 검색하기
  

#### Query context, Filter context
  

- query context
  - 이 문서가 얼마나 잘 일치하는가?
  - 스코어 계산
  - 쿼리 어디서나 ```query``` 파라미터를 전달하는 경우
  
   
- filter context
  - 이 문서가 일치하는가? Yes or No
  - 스코어 계산 안함
  - 메모리에 캐싱됨
  - 쿼리 어디서나 ```filter``` 파라미터를 사용하는 경우
  - ```bool``` 쿼리 안에서 ```filter```나 ```must_not``` 파라미터를 사용하는 경우
  - ```constant_score``` 쿼리나 ```filter``` 어그리게이션 안에서 ```filter``` 파라미터를 사용하는 경우
  
  
#### 🔍 Term Query
##### 📝 term
형태소 분석이 적용된 컬럼의 값들은 형태소 분석기에 따라 토큰으로 분리되는데 이것을 **텀(term)** 이라 한다.  
모든 대문자는 소문자로 변형되고, 중복된 단어는 삭제된다.  
Term query는 주어진 질의문이 저장된 텀과 완전히 일치한 내용만 찾는다.  
{{< highlight json >}}
{
  "query": {
    "term": {
      "title": "awesome"
    }
  }
}
{{< /highlight >}}
<br> 
##### 📝 terms
2개 이상의 term을 같이 검색하려면 terms 쿼리를 이용한다.  
필드의 값은 항상 배열로 전달해야 한다.  
{{< highlight json >}}
{
  "query": {
    "terms": {
      "title": ["awsome", "elastic", "jonnung"],
      "minium_should_match": 2
    }
  }
}
{{< /highlight >}}

- **minium_should_match**: 몇 개 이상의 term과 일치해야 검색 결과에 시킬지 설정
  
  
##### 📝 prefix
**term** 쿼리와 마찬가지로 질의어에 형태소 분석이 적용되지 않기 때문에 정확한 term값으로 검색해야 한다.  
주어진 질의어로 term의 접두어를 검색하므로 term의 일부만으로도 검색할 수 있다.  
{{< highlight json >}}
{
  "query": {
    "prefix": {
      "title": "awe"
    }
  }
}
{{< /highlight >}}

<br>
##### 📝 range
주어진 범위에 해당하는 필드값이 있는 도큐먼트를 검색할 수 있다.  

- gte(greater than or equal): 주어진 값보다 크거나 같다.
- ge(greater than): 주어진 값보다 크다.
- lte(less than or equal): 주어진 값보다 작거나 같다.
- lt(less than): 주어진 값보다 작다.

비교할 수 있는 필드는 숫자 또는 날짜/시간 형식이어야 한다.
{{< highlight json >}}
{
  "query": {
    "range": {
      "pages": {"gte": 50, "lt": 150}
    }
  }
}
{{< /highlight >}}

----
#### 🔍 Full text Query
##### 📝 match
Term Query와 거의 동일하다. 색인된 term과 비교해서 일치하는 도큐먼트만 검색한다.  
하지만 term query와 다른점은 주어진 질의문 자체를 형태소 분석을 거친 후 그 결과로 검색을 수행한다.  
아래 질의문 결과는 이전 term의 예제와 동일한 결과가 나온다.  
{{< highlight json >}}
{
  "query": {
    "match": {
      "title": "Awesome"
    }
  }
}
{{< /highlight >}}

여러 검색어에 대한 조건식을 변경하려면 ```operator```을 사용한다.
{{< highlight json >}}
{
  "query": {
    "match": {
      "title": {
        "query": "Awesome Elastic",
        "operator": "and"  # default 'and'
      }
    }
  }
}
{{< /highlight >}}

```analyzer```를 지정해 검색 쿼리의 어떤 형태소 분석을 적용할지 결정할 수 있다.
{{< highlight json >}}
{
  "query": {
    "match": {
      "title": {
        "query": "Awesome Elastic",
        "analyzer": "whitespace"
      }
    }
  }
}
{{< /highlight >}} 

<br>
##### 📝 match_phrase
구문 전체와 일치하는 도큐먼트를 검색한다.
{{< highlight json >}}
{
  "query": {
    "match_phrase": {
      "title": "Awesome elasticsearch"
    }
  }
}
{{< /highlight >}}

<br>
##### 📝 match_phrase_prefix
**match_phrase**와 동일한 동작을 하지만 검색어의 마지막 term을 접두어로 일치하는 도큐먼트를 검색한다.
{{< highlight json >}}
{
  "query": {
    "match_phrase_prefix": {
      "title": "Awesome elasticsearch fe"
    }
  }
}
{{< /highlight >}}

<br>
##### 📝 multi_match
**match** query를 여러 필드에 적용할 때 사용한다.
{{< highlight json >}}
{
  "query": {
    "multi_match": {
      "title": "Awesome Elastic",
      "fields": ["title", "contents"]
    }
  }
}
{{< /highlight >}}

<br>
##### 📝 query_string
URI 검색에서 사용했던 형식의 질의문과 같은 방식으로 사용할 수 있는 쿼리.  
질의문에 <필드명>: <질의문> 형식으로 필드를 지정할 수 있고 AND, OR 값을 이용해 조건문을 사용할 수 있다.  
{{< highlight json >}}
{
  "query": {
    "query_string": {
      "query": "title:awesome"
    }
  }
}
{{< /highlight >}}


----
#### 🔍 Bool Query
여러 쿼리를 boolean 조건으로 결합해서 도큐먼트를 검색한다.
  
- `must` : 반드시 매칭되는 조건, score에 영향을 준다.
- `filter` : ```must```와 동일한 동작하지만, score에 영향을 주지 않는다.
- `should` : bool 쿼리가 query context에 있고 ```must``` 또는 ```filter``` 절이 있다면, ```should``` 쿼리와 일치하는 결과가 없더라도 매치가 된다. bool 쿼리가 filter context 안에 있거나, ```must``` 또는 ```filter``` 중에 하나라도 있는 경우에만 매칭된다. ```minimum_should_match``` 이 값을 지정해서 컨트롤할 수 있다.
- `must_not` : 이 쿼리와 매칭되지 않아야 한다.
{{< highlight json >}}
{
  "query": {
    "bool": {
      "must": {
        "term": {"title": "the"}
      },
      "must_not": {
        "term": {"contents": "world"}
      },
      "should": [
        {"term": {"title": "awesome"}},
        {"term": {"title": "elastic"}}
      ]
    }
  }
}
{{< /highlight >}} 

