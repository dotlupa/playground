# Project Coding Conventions

## General Rules

- **Trailing newline**: Every file must end with a single trailing
  newline (POSIX convention).
- **Line length**:
  - Markdown / documentation: **72 characters** max
  - Python: **88 characters** max (Black default)
  - Shell scripts: **80 characters** max (Google Shell Style Guide)
  - JavaScript / TypeScript / JSON: **100 characters** max
  - Dockerfile: **120 characters** max (RUN instructions can be longer)
- **Indentation**:
  - Python: 4 spaces
  - JavaScript / TypeScript / JSON: 2 spaces
  - YAML: 2 spaces
  - Dockerfile: 4 spaces for continuation lines
- **No trailing whitespace** on any line.
- **UTF-8 encoding** for all text files.

## File-Specific Conventions

### README.md

- Use ATX-style headings (`#`, `##`, `###`) with space after `#`.
- Blank line after every heading.
- Code blocks must specify language (`python, `bash, etc.).
- Line wrap at 72 characters for readability.
- Use `-` for unordered lists, `1.` for ordered lists.

### Dockerfile

- `FROM` lines should pin a specific digest (`sha256:...`) or at minimum
  a minor version tag (`ubuntu:24.04`, not `ubuntu:latest`).
- Group related `RUN` instructions into logical sections with comment
  headers.
- Use `&&` to chain commands in a single `RUN` to minimize layers.
- End each `RUN` chain with `&& rm -rf /var/lib/apt/lists/*` (apt) or
  equivalent cleanup.
- Use `--no-install-recommends` with `apt-get install`.
- Prefer `COPY` over `ADD` unless URL/tar extraction is needed.
- Use `ARG` for build-time variables, `ENV` for runtime environment.
- Each logical section separated by a blank line and a comment block.

### Python

- Follow **PEP 8** (ruff/flake8 defaults).
- Use `pathlib.Path` over `os.path`.
- Type hints on all public functions and methods.
- Docstrings: Google style or PEP 257.
- Imports: standard library -> third-party -> local
  (alphabetical within each group).
- No `print()` in production code — use `logging` or `structlog`.

### Shell Scripts (bash)

- Start with `#!/usr/bin/env bash` (not `/bin/bash`).
- Set `set -euo pipefail` at the top.
- Use `[[ ]]` for conditionals, not `[ ]`.
- Quote all variable expansions: `"$var"`.
- Prefer `$()` over backticks for command substitution.
- Functions: lowercase with underscores.

### YAML / YML

- 2-space indentation.
- No tab characters.
- Use `---` at the top of standalone files.
- String values: quotes only when required (contains `:`, `#`, or
  special chars).

### JSON

- 2-space indentation.
- Trailing comma: never.
- Trailing newline: yes (same as all files).

## Verification

Before declaring a change complete:

1. Check trailing newline:
   `find . -type f -name '*.py' -o -name '*.md' -o -name '*.sh' |`
   `xargs -I{} sh -c 'test "$(tail -c 1 "{}")'`
   `&& echo "NO NEWLINE: {}"`
2. Check line length violations:
   `awk 'length > 100' $(find . -name '*.py' -o -name '*.js'`
   `-o -name '*.ts')`
3. Run project linter if configured.
