# Playground

> dotlupa 개발 환경 Docker 이미지입니다.

---

## 주요 기능

| 구분 | 상세 내용 |
| - | - |
| **OS** | Ubuntu 24.04 (Noble Numbat) |
| **기본 유틸리티** | `curl`, `git`, `wget`, `ca-certificates`, `htop`, `build-essential` (gcc, g++, make) |
| **Rust** | `rustup`을 통한 최신 안정 버전 설치 |
| **Python** | `uv` 기반 3.10 & 3.12 지원 (기본: 3.12) |
| **Node.js** | `nvm` 기반 18 & 22 LTS 지원 (기본: 22) |
| **AI 에이전트 도구** | `opencode-ai` (코드 수정 및 자동화), `hermes-agent` (자율 작업 수행) |

## AI 모델 구성

[Ollama Cloud](https://ollama.com)를 프로바이더로 사용하며, 5개 모델을
용도별로 구성했습니다.

### 모델 소개

| 모델 | 컨텍스트 | 비전 | 용도 |
| - | - | - | - |
| **GLM 5.1** (`glm-5.1`) | 198K | X | 기본 코딩, 에이전트 작업. 장시간 작업에서 지속적으로 성능이 개선되는 특징 |
| **DeepSeek V4 Flash** (`deepseek-v4-flash`) | 1M | X | 고속 에이전트 루프. MoE 구조로 낮은 지연과 높은 효율, 자율 루프 유지에 최적 |
| **Kimi K2.7 Code** (`kimi-k2.7-code`) | 256K | O | 프로그래밍 특화. 코딩 워크플로우 최적화, K2.6 대비 토큰 30% 절감 |
| **Qwen 3.5** (`qwen3.5`) | 256K | O | 멀티모달 비전 및 한국어 특화. 201개 언어 지원, 비전·요약·한국어 작업에 적합 |
| **GLM 5.2** (`glm-5.2`) | 976K | X | 대형 프로젝트. 1M 컨텍스트로 프로젝트 전체를 한 번에 처리 |

### opencode 에이전트 매핑

| 에이전트 | 모델 | 설명 |
| - | - | - |
| `build` (기본) | `ollama-cloud/glm-5.1` | 메인 코딩 에이전트. SWE-Bench 오픈소스 1위, 자율 디버깅 및 에러 수정에 탁월 |
| `plan` | `ollama-cloud/glm-5.1` | 계획 수립 에이전트 |
| `explore` | `ollama-cloud/kimi-k2.7-code` | 코드 베이스 탐색 에이전트. 심층 추론 및 아키텍처 분석에 최적 |
| `general` | `ollama-cloud/qwen3.5:397b` | 경량 범용 에이전트 (요약, 제목 생성 등). 한국어 소통 및 멀티모달 지원 |
| `vision` (서브에이전트) | `ollama-cloud/qwen3.5:397b` | 이미지 분석 및 비전 작업 (`@vision`으로 호출). 멀티모달 지원 |
| `code` (서브에이전트) | `ollama-cloud/kimi-k2.7-code` | 프로그래밍 특화 (`@code`로 호출) |
| `large_project` (서브에이전트) | `ollama-cloud/glm-5.2` | 대형 프로젝트 1M 컨텍스트 (`@large_project`으로 호출) |

### Hermes 에이전트 구성

| 항목 | 모델 | 설명 |
| - | - | - |
| 기본 모델 | `deepseek-v4-flash` | `/model` 명령으로 전환 가능. 고속 토큰 출력과 안정적 JSON Tool Call로 자율 루프 유지에 최적 |
| 폴백 체인 | `deepseek-v4-flash` -> `qwen3.5:cloud` | 기본 모델 실패 시 자동 전환 |
| 비전 보조 | `qwen3.5:cloud` | 이미지 분석, 브라우저 스크린샷. 한국어 시각 이해에 우수 |
| 웹 추출 | `qwen3.5:cloud` | 웹 페이지 요약 및 한국어 정리 |
| 컨텍스트 압축 | `qwen3.5:cloud` | 대화 요약 (멀티모달·한국어 특화 모델 사용) |

## 초기 설정

### 환경 변수 파일 구성

`.env.example`을 복사하여 `.env` 파일을 생성합니다.

```bash
cp .env.example .env
```

`.env` 파일은 다음 변수로 구성됩니다.

| 변수 | 필수 | 설명 |
| - | - | - |
| `OLLAMA_API_KEY` | O | Ollama Cloud API 키. opencode와 hermes가 공통으로 사용합니다. |

> `.env.example`은 Git에 추적되는 템플릿 파일이며, `.env`는 실제 키가
> 저장되어 `.gitignore`에 의해 커밋되지 않습니다. 컨테이너 내부에서는
> `/dev/null:/workspace/.env:ro` 볼륨 마운트로 `.env` 내용이 노출되지
> 않도록 보호됩니다.

## 빌드 방법

### 로컬 빌드

```bash
chmod +x scripts/build.sh
./scripts/build.sh
```

### 크로스 플랫폼 빌드

```bash
./scripts/build.sh linux/arm64   # Apple Silicon (ARM64)
./scripts/build.sh linux/amd64   # Intel/AMD (AMD64)
```

> **참고:** 여러 플랫폼을 반복해서 빌드하면 `<none>` 이미지가 생성될 수
> 있습니다. 이 경우 `docker image prune -f` 명령어로 정리해 주세요.

## 실행 방법

### 1. 이미지 빌드 및 컨테이너 실행 (백그라운드)

```bash
docker compose up -d --build
```

- `--build`: Dockerfile 변경 사항이 있을 경우 이미지를 다시 빌드합니다.
- `-d`: 컨테이너를 백그라운드에서 실행합니다.

### 2. 컨테이너 셸 접속

```bash
docker compose exec -it playground /bin/bash
```

- `-it`: 터미널을 통해 대화형으로 접속합니다.
- `playground`: `docker-compose.yml`에 정의된 서비스 이름입니다.
- 종료하려면 `exit`를 입력하세요.

### 3. AI 에이전트 사용

컨테이너 접속 후 별도 설정 없이 바로 사용할 수 있습니다.

```bash
# opencode (TUI 코드 에이전트)
opencode

# hermes (CLI 자율 에이전트)
hermes

# hermes 모델 전환
hermes    # 대화형 시작 후 /model -> qwen3.5:397b
```

### 4. 컨테이너 상태 확인

```bash
docker compose ps
```

### 5. 실시간 로그 확인

```bash
docker compose logs -f
```

### 6. 컨테이너 중지 및 제거

```bash
docker compose down
```

- 실행 중인 컨테이너를 중지하고 생성된 네트워크를 삭제합니다.
- 마운트된 볼륨 데이터는 삭제되지 않고 유지됩니다.

## 코드 컨벤션

AI 에이전트(Hermes, OpenCode, Claude Code 등)가 코드를 수정할 때
[`AGENTS.md`](./AGENTS.md)에 정의된 규칙을 자동으로 따릅니다.

### 일반 규칙

| 규칙 | 기준 |
| - | - |
| Trailing newline | 모든 파일은 개행 문자로 종료 (POSIX) |
| Trailing whitespace | 모든 줄 끝 공백 금지 |
| 인코딩 | UTF-8 |
| Python line length | 88자 (Black 기본값) |
| Shell line length | 80자 (Google Shell Style Guide) |
| JS/TS/JSON line length | 100자 |
| Dockerfile line length | 120자 (RUN 명령어는 예외) |
| Markdown line length | 72자 (표는 예외) |
| Python indent | 4칸 |
| JS/TS/JSON/YAML/Shell indent | 2칸 |

### 파일별 규칙

파일 유형별 세부 규칙(Dockerfile, Python, Shell, YAML, JSON 등)은
[`AGENTS.md`](./AGENTS.md)를 참고하세요.

### 에디터 자동 적용

[`.editorconfig`](./.editorconfig)가 프로젝트 루트에 있어 VS Code,
JetBrains 등 주요 에디터에서 들여쓰기와 줄바꿈 규칙이 자동 적용됩니다.

## 프로젝트 구조

```
.
├── .editorconfig         # 에디터 코드 스타일 설정
├── .env.example          # API 키 템플릿 (복사해서 .env로 사용)
├── .gitignore
├── AGENTS.md             # AI 에이전트 코드 컨벤션 (Hermes, OpenCode, Claude Code 등 공용)
├── CHANGELOG.md          # 변경 이력
├── config/
│   ├── opencode.json     # opencode 에이전트 설정
│   └── hermes.yml        # hermes 에이전트 설정
├── Dockerfile
├── docker-compose.yml
├── scripts/
│   └── build.sh          # 빌드 스크립트
└── README.md
```
