---
title: "2024 Weekly #12 Log"
date: 2024-03-25T17:40:00+09:00
image: /images/common/weekly-log-cover.webp
tags:
  - weekly-log
categories:
  - weekly log
description: 종종 Stacked Changes라는 말과 Graphite가 좋다는 이야기는 들어본 적이 있었는데, 구체적으로 어떤 것일지 찾아보진 않았습니다. 우연히 올라온 글을 읽고 비슷한 고민과 불편함을 느꼈었기 때문에 흥미를 갖고 알아보게 되었습니다. 
url: /weekly-log/2024/03/24/2024-cw12/
draft: true
---

# Pocket Pick
## [Stacked Diffs(Stacked PR)](https://sungjk.github.io/2024/03/17/stacked-diffs.html)
- 더 나은 코드 리뷰 프로세스와 기능 개발에 속도를 올려주는 방법론. **Stacked Diffs** 또는 **Stacked PR**
- Stacked Diffs라는 말의 개별 단어적 의미만으로는 단순히 PR을 쪼개서 여러 번 요청하는 것 같지만(사실 맞음), 구체적으로는 PR을 쌓아가는 것 
- (Github) Pull Request
    - Main Branch에서 Feature Branch를 생성하고 작업한 내역의 최종 결과물을 나타낸다. 
    - 리뷰 요청자는 리뷰가 완료될 때까지 기다려야 해당 Feature Branch에서 개발을 이어갈 수도 있다.
    - 물론 안 그래도 되겠지만 리뷰 결과에 변경 요청(Change Request)이 생기면 이어서 개발 중인 내용에도 반영해야 하는 번거로움이 생길 수 있다. 
        - 하는 일이 많은 개발자라면 잠시 다른 기능 개발하고 와도 된다.ㅋ;;;
    - 변경 사항이 거대한 PR은 리뷰어를 돕기 위해 커밋을 잘개 쪼개 놓는다거나 여기저기 코멘트를 남길 수도 있지만, 리뷰어 입장에서 오히려 집중력이 분산된다. 결국 PR이 큰 것 자체가 문제가 있다.
- Stacked Diffs (Stacked Changes)
    - 결론 먼저 말하자면 PR 리뷰를 요청할 때 매번 현재 Feature Branch에서 만드는 것뿐이다.
    - 같은 Feature Branch에서 PR을 Stack처럼 쌓아가는 모습
    - Diffs(Changes)가 의미하는 것은 변경 사항 자체. 즉, 하나의 커밋을 의미. 그리고 그 변경(커밋)은 하나의 PR이 된다.
    -  Squash Merge 전략을 사용하고 있을 때 단점: Diffs를 쌓고 PR을 요청했지만, 이전 PR에서 변경 사항(Change Request)이 생기면 다음 Diffs(이후 PR)에서 이 내용이 없을 수 있다. 이 경우 Rebase를 통해 다음 Diff에 변경 사항을 직접 넣어줘야 할 수도 있다. 충돌을 피할 수 없지만 Diffs 간의 변경이 워낙 적기(를 기대) 때문에 부담도 적어진다.

---
# Tech Video
## 인프콘 2022 - 코드 리뷰의 또 다른 접근 방법 Pull Requests vs Stacked Changes
{{< youtube XRZPkYnWa48 >}}
- 좋은 코드 리뷰는 적당한 크기의 변경, 작업 내용이 명확하게 드러나야 하며 빠른 리뷰 속도와 연관성이 있다. 
- 즉, 작고 명확한 변경은 빠른 코드 리뷰가 가능하게 한다.
- Github의 **Pull Request**는 최종 결과를 나타내기 때문에 많은 변경되거나 다소 복잡해 보일 수 있다. 그래서 리뷰어가 효율적으로? 심리적 안정감?을 갖고 리뷰를 하기 어려울 수 있다.
    - (내 피셜) 보통 이런 생각을 할 수도 있다. '내 일도 많은데 이걸 언제, 어디서부터 봐야하는거야!'
- 작은 변경은 리뷰 속도를 개선하면서 충돌(conflict) 가능성도 낮춰주어 결국 빠른 배포가 가능하게 돕는다.
- **Stacked Changes**는 작은 단위의 코드 변경을 스택(Stack)처럼 쌓아가며 리뷰를 받고, 진행 중인 개발을 지속해서 병행할 수 있게 하는 방식
- Github이 **Stacked Changes** 기능을 지원하지 않는 (예상컨데) 이유는 본질적인 가치가 다르기 때문이다. Github은 오픈소스 호스팅과 개발 문화를 주도하기 때문에 대규모 작업을 수반하는 경우가 많다. **Stacked Changes**로 얻을 수 있는 장점은 실질적으로 특정 조직(회사) 안에서의 협업에 효율적일 수 있기 때문이다. 
- 쌩으로 **Stacked Changes** 방식의 PR을 만들 수도 있지만, 확실히 손이 많이 간다. 적절한 도구 활용이 필요한데 **Graphite**가 가장 대표적인 CLI/GUI 도구
- Graphite CLI는 Git을 Wrapping 하고 있기 때문에 코드 변경에 대한 Stack을 쉽고 간결하게 만들수 있다. 
- Graphite GUI로 이 Stack에 대한 순서를 쉽게 확인할 수 있게 해준다.
- 코드 리뷰는 개인 취향이 아닌 팀원들의 성향과 목표를 고려하여 진행하는 것이 중요하다.


