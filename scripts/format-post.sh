#!/bin/bash
#
# 마크다운 포스트 포맷팅 스크립트
# Obsidian 등에서 복사한 마크다운을 Hugo 형식으로 변환
#
# 기능:
#   1. 문장 끝에 공백 2개 추가 (마크다운 줄바꿈)
#   2. ![alt](src) → <img src="src" alt="alt"> 변환
#
# 사용법: ./scripts/format-post.sh content/posts/YYYY-MM-DD-slug/index.md
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 프로젝트 루트로 이동
cd "$(dirname "$0")/.."

# 파일 경로 확인
if [ -z "$1" ]; then
    echo -e "${YELLOW}사용법: $0 <마크다운 파일 경로>${NC}"
    echo ""
    echo "예시:"
    echo "  $0 content/posts/2024-12-31-my-post/index.md"
    echo ""

    # 최근 수정된 포스트 목록 표시
    echo -e "${CYAN}최근 수정된 포스트:${NC}"
    find content/posts -name "index.md" -mtime -7 -print 2>/dev/null | head -5
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo -e "${RED}오류: 파일을 찾을 수 없습니다: ${FILE}${NC}"
    exit 1
fi

# 백업 생성
BACKUP="${FILE}.bak"
cp "$FILE" "$BACKUP"

echo -e "${CYAN}포맷팅 시작: ${FILE}${NC}"
echo ""

# 임시 파일 생성
TEMP_FILE=$(mktemp)

# front matter와 본문 분리 처리
awk '
BEGIN { in_frontmatter = 0; frontmatter_count = 0; in_codeblock = 0; }
/^---$/ {
    frontmatter_count++
    if (frontmatter_count == 1) {
        in_frontmatter = 1
        print
        next
    } else if (frontmatter_count == 2) {
        in_frontmatter = 0
        print
        next
    }
}
/^```/ {
    # 코드 블록 토글
    in_codeblock = !in_codeblock
    print
    next
}
{
    if (in_frontmatter || in_codeblock) {
        # front matter와 코드 블록은 그대로 출력
        print
    } else {
        line = $0

        # 1. 마크다운 이미지를 img 태그로 변환
        # ![alt text](image.png) → <img src="image.png" alt="alt text">
        # ![](image.png) → <img src="image.png">
        while (match(line, /!\[([^\]]*)\]\(([^)]+)\)/)) {
            before = substr(line, 1, RSTART - 1)
            full_match = substr(line, RSTART, RLENGTH)
            after = substr(line, RSTART + RLENGTH)

            # alt와 src 추출
            if (match(full_match, /!\[([^\]]*)\]\(([^)]+)\)/)) {
                # awk에서 캡처 그룹 추출
                gsub(/!\[/, "", full_match)
                gsub(/\].*/, "", full_match)
                alt = full_match
            }

            # 원본에서 다시 src 추출
            temp = substr(line, RSTART, RLENGTH)
            gsub(/.*\]\(/, "", temp)
            gsub(/\)$/, "", temp)
            src = temp

            # img 태그 생성
            if (alt == "") {
                img_tag = "<img src=\"" src "\">"
            } else {
                img_tag = "<img src=\"" src "\" alt=\"" alt "\">"
            }

            line = before img_tag after
        }

        # 2. 줄 끝에 공백 2개 추가 (마크다운 줄바꿈)
        # 단, 다음 경우는 제외:
        #   - 빈 줄
        #   - 헤더 (#으로 시작)
        #   - 리스트 아이템 (-, *, 숫자.으로 시작)
        #   - 인용문 (>으로 시작)
        #   - 이미 공백 2개로 끝나는 줄
        #   - HTML 태그로 끝나는 줄
        #   - front matter 구분자

        if (line != "" && \
            line !~ /^#/ && \
            line !~ /^[[:space:]]*[-*]/ && \
            line !~ /^[[:space:]]*[0-9]+\./ && \
            line !~ /^>/ && \
            line !~ /  $/ && \
            line !~ />$/ && \
            line !~ /^---$/ && \
            line !~ /^[[:space:]]*$/) {
            line = line "  "
        }

        print line
    }
}
' "$FILE" > "$TEMP_FILE"

# 결과 적용
mv "$TEMP_FILE" "$FILE"

# 변경사항 요약
echo -e "${GREEN}✓ 포맷팅 완료!${NC}"
echo ""

# diff로 변경사항 표시
if command -v diff &> /dev/null; then
    CHANGES=$(diff "$BACKUP" "$FILE" 2>/dev/null | head -30 || true)
    if [ -n "$CHANGES" ]; then
        echo -e "${YELLOW}변경사항 (처음 30줄):${NC}"
        echo "$CHANGES"
        echo ""
    else
        echo -e "${YELLOW}변경된 내용이 없습니다.${NC}"
    fi
fi

echo -e "${CYAN}백업 파일: ${BACKUP}${NC}"
echo ""
echo -e "${YELLOW}확인 후 백업 삭제:${NC}"
echo "  rm ${BACKUP}"
