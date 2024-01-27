---
comments: true
date: 2016-10-28T11:00:00Z
tags:
  - jenkins
categories:
  - devops
title: Jenkins 프로젝트(jobs) 설정이 사라지는 오류 및 일단위 백업하기
url: /jenkins/2016/10/28/jenkins-jobs-backup/
---

Jenkins 에서 실행되는 프로젝트(job)들은 ```${JENKINS_HOME}/jobs``` 경로에 프로젝트 이름마다 디렉토리가 존재하며, 안에는 ```config.xml``` 과 빌드 히스토리 관련 파일들이 있다.  
만약 Jenkins를 다른 서버로 이전하게 된다면 jobs 디렉토리를 백업해서 이전할 서버로 복구하면 된다.  
  
최근에 Jenkins 를 재실행 한 후 일부 프로젝트들의 config.xml 이 삭제되는 이슈가 발생했다. OTL  
  
한참동안 원인 파악이 안되는 상태가 계속되자 수동 복구를 하기로 했고, 기존과 동일한 이름으로 **"새로운 Item > Freestyle Project"** 를 생성했다. 이렇게 하면 설정은 없지만 빌드 기록은 볼 수 있다.  
그리고 각 프로젝트(job) 별로 마지막 빌드 Output 에서 실행된 Command 를 확인한 후 이번에는 다른 이름으로 Freestyle Project 를 생성했다. ㅠㅠ  
   
이미 소는 잃었지만 다음부터는 좀 더 편리하고 빠르게 Jenkins 를 복구하기 위해 아래 명령어를 Jenkins에 새로운 프로젝트로 등록해서 매일 0시에 실행 되도록 했다.  

```
/usr/bin/find "/var/lib/jenkins/jobs" -type f -name "config.xml" -exec python3 -c "import os, sys, shutil, datetime; src=sys.argv[1]; src_arr=src.split('/'); dest_dir=os.path.join('/tmp/jenkins_jobs', datetime.datetime.now().strftime('%Y%m%d'), src_arr[5]); os.makedirs(dest_dir); shutil.copy(src, os.path.join(dest_dir, src_arr[6]))" {} \;
```

그리고 회사 개발자 한분께서 ```git``` 으로 ```config.xml``` 을 관리하고 있다고 하셨다.  
그때는 생각을 못했는데 듣고보니 ```git``` 으로 하는게 훨씬 심플하고, 사이즈도 적게 차지하는 백업 플랜 같다!!  
