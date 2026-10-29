#!/usr/bin/env bash
# PR 제출 형식 검사. PR의 파일은 실행하지 않고, 파일 이름과 위치만 확인합니다.
# 구조: 알고리즘-N회차/<문제폴더>/<GitHub아이디>.<확장자>
# 필요한 환경변수: AUTHOR, BASE_SHA, HEAD_SHA, (선택) PR_TITLE
set -uo pipefail
export LC_ALL=C.UTF-8
git config core.quotepath false

errors=0
fail() { echo "::error::$1"; errors=$((errors + 1)); }
warn() { echo "::warning::$1"; }

: "${AUTHOR:?}" "${BASE_SHA:?}" "${HEAD_SHA:?}"
author_lc="${AUTHOR,,}"

mapfile -t changed < <(git diff --name-only "${BASE_SHA}...${HEAD_SHA}")

if [ "${#changed[@]}" -eq 0 ]; then
  fail "변경된 파일이 없습니다."
  exit 1
fi

echo "제출자: ${AUTHOR}"
echo "변경된 파일:"
printf '  %s\n' "${changed[@]}"

round_re='^(알고리즘-[0-9]+회차)/([^/]+)/([^/]+)$'
rounds=()
problems=()

# 1) 위치와 파일 이름 검사
for f in "${changed[@]}"; do
  if [[ "$f" =~ $round_re ]]; then
    round="${BASH_REMATCH[1]}"
    problem="${BASH_REMATCH[2]}"
    name="${BASH_REMATCH[3]}"
    stem="${name%.*}"

    if ! git cat-file -e "${BASE_SHA}:${round}/${problem}/README.md" 2>/dev/null; then
      fail "'$f' — '${round}/${problem}' 은(는) 없는 문제 폴더입니다. 이미 있는 문제 폴더 안에 올려 주세요."
      continue
    fi
    if [ "$name" = "$stem" ]; then
      fail "'$f' — 확장자가 없습니다. (예: ${AUTHOR}.c)"
      continue
    fi
    if [ "${stem,,}" != "$author_lc" ]; then
      fail "'$f' — 파일 이름은 본인 GitHub 아이디(${AUTHOR})여야 합니다. (예: ${AUTHOR}.c, ${AUTHOR}.png, ${AUTHOR}.md)"
      continue
    fi
    rounds+=("$round")
    problems+=("${round}/${problem}")
  else
    fail "'$f' — 문제 폴더(알고리즘-N회차/문제폴더/) 밖의 파일은 수정할 수 없습니다."
  fi
done

mapfile -t rounds < <(printf '%s\n' "${rounds[@]}" | sed '/^$/d' | sort -u)
mapfile -t problems < <(printf '%s\n' "${problems[@]}" | sed '/^$/d' | sort -u)

if [ "${#rounds[@]}" -gt 1 ]; then
  fail "한 PR에는 한 회차만 제출해 주세요. (현재: ${rounds[*]})"
fi

# 2) 문제별 필수 파일: 코드가 있으면 캡처·풀이(md)도 있어야 함
for p in "${problems[@]}"; do
  mapfile -t mine < <(git ls-tree --name-only "${HEAD_SHA}" -- "${p}/" \
    | awk -F/ -v a="$author_lc" '{ n=$NF; s=n; sub(/\.[^.]*$/, "", s); if (tolower(s) == a) print n }')

  has_md=0; has_img=0; has_code=0
  for n in "${mine[@]}"; do
    ext="${n##*.}"; ext="${ext,,}"
    case "$ext" in
      md) has_md=1 ;;
      png|jpg|jpeg|gif|webp) has_img=1 ;;
      *) has_code=1 ;;
    esac
  done

  label="${p#*/}"
  if [ "$has_md" -eq 0 ]; then
    fail "[${label}] 풀이 요약 ${AUTHOR}.md 가 없습니다. _template/풀이템플릿.md 를 참고해 작성해 주세요."
  fi
  if [ "$has_code" -eq 1 ] && [ "$has_img" -eq 0 ]; then
    fail "[${label}] '맞았습니다' 캡처(${AUTHOR}.png)가 없습니다."
  fi
  if [ "$has_code" -eq 0 ] && [ "$has_md" -eq 1 ]; then
    warn "[${label}] 코드 없이 풀이만 올렸습니다. (미해결 문제로 처리됩니다)"
  fi
  [ "$has_md" -eq 1 ] && [ "$has_code" -eq 1 ] && [ "$has_img" -eq 1 ] && echo "[${label}] 코드·캡처·풀이 확인"
done

# 3) 마감 시각 (경고만)
for round in "${rounds[@]}"; do
  deadline=$(awk -v r="$round" '$1 == r { print $2 }' .github/deadlines.txt 2>/dev/null || true)
  if [ -n "$deadline" ]; then
    due=$(date -d "$deadline" +%s 2>/dev/null || echo "")
    if [ -n "$due" ] && [ "$(date +%s)" -gt "$due" ]; then
      warn "${round} 마감(${deadline})이 지난 뒤의 제출/수정입니다."
    fi
  fi
done

# 4) PR 제목 (경고만)
if [ -n "${PR_TITLE:-}" ] && ! [[ "$PR_TITLE" =~ ^\[[0-9]+회차\]\ .+ ]]; then
  warn "PR 제목을 '[N회차] 이름' 형식으로 맞춰 주세요. (예: [2회차] 홍길동)"
fi

if [ "$errors" -gt 0 ]; then
  echo
  echo "❌ 문제 ${errors}건. 위 메시지를 보고 고친 뒤 다시 올려 주세요."
  exit 1
fi

echo
echo "✅ 제출 형식 OK"
