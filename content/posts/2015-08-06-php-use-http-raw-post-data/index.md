---
comments: true
date: 2015-08-06T23:16:07Z
tags:
- php
- http
categories:
  - php
title: PHP 로 HTTP raw post data를 다루는 방법
url: /php/2015/08/06/php-use-http-raw-post-data/
---

HTTP request는 header 와 body로 나눌 수 있다.
body 에는 데이터가 있을 수도 있고, 없을 수도 있다.

POST 요청도 body에 담겨서 오게 되는데 HTML form 으로부터 전달되는 데이터를 PHP가 파싱해서 ```$_POST```에 담는다.

만약에 body의 데이터가 json 이거나 PHP가 해석할 수 없는 형태더라도 직접 접근해야만 하는 경우가 있을 수 있다.
이때 사용되는 변수가 ```$HTTP_RAW_POST_DATA``` 이다. 하지만 이 변수는 PHP 5.6 부터 Deprecated 이기 때문에 사용하면 안된다.

일반적으로 ```php://input``` 을 사용해서 HTTP body의 raw data를 읽기 전용으로 가져올 수 있다. 하지만 ```enctype=“multipart/form-data”``` 는 다룰 수 없다는 점을 유의 해야한다.

{{< highlight php >}}
<?php

$post_data = file_get_contents("php://input");

{{< / highlight >}}

만약 ```$HTTP_RAW_POST_DATA``` 는 사용해야 한다면 **php.ini** 의 **[always_populate_raw_post_data](http://php.net/manual/kr/ini.core.php#ini.always-populate-raw-post-data)** 를 **TRUE** 로 변경하면 가능하지만, 사용하지 않는 것이 잠재적으로 메모리를 절약할 수 있는 방안이 될 수 있다.
