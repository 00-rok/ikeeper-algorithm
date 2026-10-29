#!/usr/bin/env bash
# PR 제출 형식 검사. PR의 파일은 실행하지 않고, 파일 이름과 위치만 확인합니다.
# 필요한 환경변수: AUTHOR, BASE_SHA, HEAD_SHA, (선택) PR_TITLE
set -uo pipefail

errors=0
fail() { echo "::error::$1"; errors=$((errors + 1)); }
warn() { echo "::warning::$1"; }

: "${AUTHOR:?}" "${BASE_SHA:?}" "${HEAD_SHA:?}"

mapfile -t changed < <(git diff --name-only "${BASE_SHA}...${HEAD_SHA}")

if [ "${#changed[@]}" -eq 0 ]; then
  fail "변경된 파일이 없습니다."
  exit 1
fi

echo "제출자: ${AUTHOR}"
echo "변경된 파일:"
printf '  %s\n' "${changed[@]}"

# 1) 모든 파일이 round-XX/<본인아이디>/ 안에 있어야 함
rounds=()
for f in "${changed[@]}"; do
  if [[ "$f" =~ ^(round-[0-9]{2})/([^/]+)/.+ ]]; then
    round="${BASH_REMATCH[1]}"
    who="${BASH_REMATCH[2]}"
    if [ "$who" != "$AUTHOR" ]; then
      fail "'$f' — 폴더 이름이 GitHub 아이디(${AUTHOR})와 다릅니다. round-XX/${AUTHOR}/ 안에 넣어 주세요."
    fi
    rounds+=("$round")
  else
    fail "'$f' — 본인 폴더(round-XX/${AUTHOR}/) 밖의 파일은 수정할 수 없습니다."
  fi
done

mapfile -t rounds < <(printf '%s\n' "${rounds[@]}" | sort -u | sed '/^$/d')

if [ "${#rounds[@]}" -gt 1 ]; then
  fail "한 PR에는 한 회차만 제출해 주세요. (현재: ${rounds[*]})"
fi

# 2) 회차 폴더가 실제로 열려 있는 회차인지, 필수 파일이 있는지
for round in "${rounds[@]}"; do
  dir="${round}/${AUTHOR}"

  if ! git cat-file -e "${BASE_SHA}:${round}/README.md" 2>/dev/null; then
    fail "'${round}' 은(는) 아직 열리지 않은 회차입니다. 회차 번호를 확인해 주세요."
    continue
  fi

  mapfile -t files < <(git ls-tree -r --name-only "${HEAD_SHA}" -- "${dir}/")

  if ! printf '%s\n' "${files[@]}" | grep -qx "${dir}/README.md"; then
    fail "${dir}/README.md 가 없습니다. _template/README.md 를 복사해서 작성해 주세요."
  fi

  if ! printf '%s\n' "${files[@]}" | grep -Eiq "^${dir}/images/.+\.(png|jpe?g|gif|webp)$"; then
    fail "${dir}/images/ 에 '맞았습니다' 캡처 이미지가 없습니다."
  fi

  code_count=$(printf '%s\n' "${files[@]}" | grep -Ec "^${dir}/[0-9]+\.[A-Za-z0-9]+$" || true)
  if [ "$code_count" -eq 0 ]; then
    fail "${dir}/ 에 코드 파일이 없습니다. 파일 이름은 문제 번호로 해 주세요. (예: 1047.c)"
  else
    echo "코드 파일 ${code_count}개 확인"
  fi

  # 3) 마감 시각 (경고만)
  deadline=$(awk -v r="$round" '$1 == r { print $2 }' .github/deadlines.txt 2>/dev/null || true)
  if [ -n "$deadline" ]; then
    now=$(date +%s)
    due=$(date -d "$deadline" +%s 2>/dev/null || echo "")
    if [ -n "$due" ] && [ "$now" -gt "$due" ]; then
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
  echo "❌ 문제 ${errors}건. 위 메시지를 보고 고친 뒤 다시 push 해 주세요."
  exit 1
fi

echo
echo "✅ 제출 형식 OK"
