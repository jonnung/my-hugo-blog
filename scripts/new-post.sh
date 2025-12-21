#!/bin/bash
#
# 새 블로그 포스트 생성 스크립트
# 사용법: ./scripts/new-post.sh "포스트 제목"
#         ./scripts/new-post.sh "포스트 제목" tech  (카테고리 지정)
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 프로젝트 루트로 이동
cd "$(dirname "$0")/.."

# 제목 입력 확인
if [ -z "$1" ]; then
    echo -e "${YELLOW}사용법: $0 \"포스트 제목\" [카테고리]${NC}"
    echo ""
    read -p "포스트 제목을 입력하세요: " TITLE
    if [ -z "$TITLE" ]; then
        echo -e "${RED}오류: 제목을 입력해주세요.${NC}"
        exit 1
    fi
else
    TITLE="$1"
fi

CATEGORY="${2:-}"

# 날짜 생성
DATE=$(date +%Y-%m-%d)

# 슬러그 생성 (한글 제거, 소문자 변환, 공백을 하이픈으로)
SLUG=$(echo "$TITLE" | \
    sed 's/[가-힣]//g' | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9 -]//g' | \
    sed 's/  */ /g' | \
    sed 's/^ *//;s/ *$//' | \
    sed 's/ /-/g')

# 슬러그가 비어있으면 사용자에게 입력 요청
if [ -z "$SLUG" ]; then
    echo -e "${YELLOW}한글 제목만 입력되어 슬러그를 자동 생성할 수 없습니다.${NC}"
    read -p "영문 슬러그를 입력하세요 (예: my-new-post): " SLUG
    if [ -z "$SLUG" ]; then
        echo -e "${RED}오류: 슬러그를 입력해주세요.${NC}"
        exit 1
    fi
fi

# 디렉토리 및 파일 경로
POST_DIR="content/posts/${DATE}-${SLUG}"
POST_FILE="${POST_DIR}/index.md"

# 이미 존재하는지 확인
if [ -d "$POST_DIR" ]; then
    echo -e "${RED}오류: 이미 같은 이름의 포스트가 존재합니다: ${POST_DIR}${NC}"
    exit 1
fi

# Hugo로 새 포스트 생성
hugo new "posts/${DATE}-${SLUG}/index.md"

# 카테고리가 지정된 경우 front matter 업데이트
if [ -n "$CATEGORY" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/categories:/categories:\n  - ${CATEGORY}/" "$POST_FILE"
    else
        sed -i "s/categories:/categories:\n  - ${CATEGORY}/" "$POST_FILE"
    fi
fi

echo ""
echo -e "${GREEN}✓ 새 포스트가 생성되었습니다!${NC}"
echo -e "  경로: ${POST_FILE}"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  1. 에디터에서 열기: code ${POST_FILE}"
echo "  2. front matter의 tags, categories, description 작성"
echo "  3. 본문 작성"
echo "  4. draft: false 로 변경 후 발행"
echo ""
