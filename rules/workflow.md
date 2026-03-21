# Git Workflow & Documentation Hygiene

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## Agent Commit Prefixes

- `[alpha]`, `[beta]`, `[gamma]` -- developer agents
- `[lead]` -- architecture decisions
- `[scribe]` -- documentation

Example: `[alpha] feat: add LIDAR scan filtering node`

## Branch Naming

- `feat/alpha-<description>` -- feature branches by agent
- `arch/<topic>` -- architecture branches (Lead only)
- `fix/<description>` -- bug fixes
- `docs/<topic>` -- documentation

## Pull Request Workflow

1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan
5. Run code-review before creating PR

## Git Rules

- Always test locally before committing
- Small, focused commits -- one logical change per commit
- Never commit: secrets, build artifacts, .env files, rosbag data
- Interface changes (msg/srv/action) require Lead/Owner approval

---

## Documentation Hygiene

### Core Principle: ONE doc per purpose, ZERO redundancy

| Type | File | Rule |
|------|------|------|
| Quickstart | `QUICKSTART.md` | Step-by-step launch guide. ONE per repo. |
| Code Guide | `CODEBASE_GUIDE.md` | How to read the codebase. ONE per repo. |
| Project README | `src/README.md` | What the project is. ONE per repo. |
| Status | `agents/devlog/status.md` | Current session progress. OVERWRITE each session. |
| Tasks | `agents/devlog/tasks.md` | What needs doing. OVERWRITE when stale. |

Architecture Decision Records (`docs/ADR-*.md`) are permanent history and don't count toward the limit.

### Rules for Doc-Writing Agents

1. Before creating a new doc: search for existing docs with the same purpose. UPDATE instead of creating.
2. Never create: DOCUMENTATION_INDEX.md, START_HERE.md, SESSION_*.md, CHANGELOG_*.md, FILE_MANIFEST.md
3. status.md is overwritten each session, not appended
4. Root directory should have at most 3 .md files
5. After any doc update session: count .md files. If total exceeds 8 (excluding ADRs), clean up.

### Anti-Patterns (NEVER)

- Creating "documentation about the documentation"
- Duplicating QUICKSTART content into README
- Creating dated session summary files (use status.md overwrite)
- Creating a file manifest or documentation index (the filesystem IS the index)
