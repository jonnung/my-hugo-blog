---
comments: true
date: 2016-10-27T11:00:00Z
tags:
  - hive
categories:
  - database
title: Hive UDF - ngrams
url: /hive/2016/10/27/hive-udf-ngrams/
---

# N-gram 이란?
- 전체 문자열을 N개의 기준 단위만큼 절단해서 사용하는 방법
- N개는 문자 단위가 될 수도 있고, 단어 단위가 될 수도 있다.
- 만들어진 N-gram 은 나오는 빈도를 분석하거나, 키워드를 뽑아내는 용도로도 사용될 수 있다.
- 예를들어 "hive" 에 대한 2-gram의 결과는 다음과 같다.

```
["hi", "iv", "ve"]
```

# ngrams(array<array>, int N, int K, int pf)
- 당연히 N-gram 을 계산하기 위함
- 3개의 입력 파라미터 (Input)
  - 첫번째, String 타입의 Array of Array 형태, 각 element 는 word (ex. [["hadoop", "hdfs", "hive"]]
    - 하나의 문장을 Array of Array 형태의 단어 단위로 분리하기 위해 ```sentences()``` 함수와 함께 쓰는 경우가 많다.
  - 두번째, N-gram 에서의 N 값
  - 세번째, 결과 값의 출력 개수(top-N)
- 실행 결과 (Output)
  - 2개의 속성을 가진 Struct 구조의 Array
  - 첫번째 속성 ```ngram```, N-gram 값 자체
  - 두번째 속성 ```estfrequency```, N-gram 의 각 값들이 몇번 나타났는지에 대한 count (빈도)

# 예제

## 예문

```
The Apache Hive data warehouse software facilitates reading, writing, and managing large datasets residing in distributed storage using SQL. Hive provides standard SQL functionality, including many of the later 2003 and 2011 features for analytics. Hive's SQL can also be extended with user code via user defined functions (UDFs), user defined aggregates (UDAFs), and user defined table functions (UDTFs).
```

## Hive SQL
```
SELECT
  ngrams(
    sentences("The Apache Hive data warehouse software facilitates reading, writing, and managing large datasets residing in distributed storage using SQL. Hive provides standard SQL functionality, including many of the later 2003 and 2011 features for analytics. Hive's SQL can also be extended with user code via user defined functions (UDFs), user defined aggregates (UDAFs), and user defined table functions (UDTFs)."),
    2,
    3
);
```

## SQL 설명
주어진 문장을 ```sentences()``` 함수를 이용해 단어 단위로 분리된 Array 로 변환되어 ```ngrams()``` 함수의 첫번째 파라미터로 전달 됩니다.  
단어로 구성된 Array 에 대해 두번째 파라미터 값을 N 으로 하여 N-gram 을 계산합니다.  (2-Gram)  
세번째 파라미터의 값은 전체 결과중에 출력하고자 하는 Top - K 의 개수를 지정합니다. (Top 3)  

## 결과
```
--------------------------------------------------------------------------------
        VERTICES      STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
--------------------------------------------------------------------------------
Map 1 ..........   SUCCEEDED      1          1        0        0       0       0
Reducer 2 ......   SUCCEEDED      1          1        0        0       0       0
--------------------------------------------------------------------------------
VERTICES: 02/02  [==========================>>] 100%  ELAPSED TIME: 9.88 s
--------------------------------------------------------------------------------
OK
[{"ngram":["user","defined"],"estfrequency":3.0},{"ngram":["and","user"],"estfrequency":1.0},{"ngram":["with","user"],"estfrequency":1.0}]
Time taken: 10.326 seconds, Fetched: 1 row(s)
```

참고: [https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF)  

