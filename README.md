# i-Keeper 개발 알고리즘 과제

i-Keeper 개발 재학생(신입·기존) 알고리즘 과제 제출 레포지토리입니다.
매 회차 과제는 이 레포에 **Pull Request(PR)** 로 제출합니다.

## 과제 목록

| 회차 | 주제 | 문제 (정올) | 기간 | 안내 |
|:---:|---|---|---|:---:|
| 2회차 | 피보나치 | 1047, 1557, 1511 | 10/29(목) ~ 11/5(목) 23:59 | [바로가기](round-02/README.md) |

> 문제는 정올(<http://jungol.co.kr/>)에서 풀고, 이 레포에 제출합니다.

## 폴더 구조

```
round-02/                  ← 회차 폴더
├── README.md              ← 이번 회차 문제 안내
└── <GitHub아이디>/         ← 본인 폴더 (직접 생성)
    ├── README.md          ← 풀이 요약 + AI 사용 여부 (필수)
    ├── 1047.c             ← 정답 코드 (언어 자유: .c .cpp .py .java ...)
    ├── 1557.c
    ├── 1511.c
    └── images/            ← '맞았습니다' 캡처
        ├── 1047.png
        ├── 1557.png
        └── 1511.png
```

- 폴더 이름은 **본인 GitHub 아이디와 똑같이** 만들어 주세요. (대소문자 포함)
- 코드 파일 이름은 **문제 번호**로 합니다.
- `README.md` 는 [`_template/README.md`](_template/README.md) 를 복사해서 채웁니다.

## 제출 방법

### 처음 한 번만

1. 이 레포 오른쪽 위 **Fork** 버튼 → 내 계정으로 복사
2. 내 Fork를 PC로 받기
   ```bash
   git clone https://github.com/<내아이디>/<레포이름>.git
   cd <레포이름>
   git remote add upstream https://github.com/<원본소유자>/<레포이름>.git
   ```

### 매 회차마다

1. 원본 레포의 최신 내용 받아오기 (새 회차 폴더가 생겼을 수 있음)
   ```bash
   git checkout main
   git pull upstream main
   ```
2. 회차 폴더 안에 내 폴더 만들고 코드·캡처·README 넣기
   ```bash
   mkdir -p round-02/<내아이디>/images
   cp _template/README.md round-02/<내아이디>/README.md
   ```
3. 커밋 & 푸시
   ```bash
   git add round-02/<내아이디>
   git commit -m "[2회차] 홍길동"
   git push origin main
   ```
4. GitHub의 내 Fork 페이지 → **Contribute → Open pull request**
   - PR 제목: `[2회차] 이름` (예: `[2회차] 홍길동`)
   - PR 본문의 체크리스트를 채워 주세요.
5. PR 아래 **자동 검사(Check submission)** 가 초록색 ✅ 인지 확인
   - ❌ 이면 메시지를 보고 고친 뒤 다시 push 하면 PR에 자동 반영됩니다.

> git이 처음이라면 GitHub 웹에서 **Add file → Upload files** 로 올려도 됩니다.
> 업로드 화면 경로 칸에 `round-02/<내아이디>/` 를 입력한 뒤 파일을 끌어다 놓으세요.

## 규칙

- **마감:** 각 회차 안내의 마감 시각까지 PR이 열려 있어야 제출로 인정합니다. 마감 후 수정 커밋은 반영하지 않습니다.
- **본인 폴더만** 수정합니다. 다른 사람 폴더나 공용 파일을 건드리면 자동 검사가 실패합니다.
- **AI 활용:** 본인 힘으로 먼저 고민하는 것을 권장합니다. AI의 도움을 받았다면 `README.md` 에
  어떤 고민을 했는지와 **AI에 입력한 프롬프트 원문**을 반드시 적어 주세요.
- 다른 사람의 풀이를 그대로 옮기는 것은 금지합니다. 공개 레포이므로 PR은 서로 볼 수 있습니다.
- 개발 재학생(신입·기존) 평가 대상이며, 총 해결 문제 비율 미달 시 제명/경고 규정이 적용됩니다.

문의는 교육부장에게 카카오톡으로 해 주세요.
