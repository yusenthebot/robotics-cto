# Claude Robotics Toolkit

A complete Claude Code configuration for **AI-driven robotics development** -- designed for product owners who direct strategy while AI agents handle all implementation.

## Who This Is For

- **Non-developer founders/CTOs** building robotics products with Claude Code as the engineering team
- **Solo roboticists** who want structured, parallel AI development with quality gates
- **Teams** adopting ROS2 who want a proven spec-to-code methodology

## Architecture

```
You (Product Owner) -- strategy, architecture approval, release sign-off
  |
  v
Dispatcher (Main Claude / Opus) -- intent parsing, routing, executive summaries
  |
  +-- Architect (Opus agent) -------- spec/plan authoring, architecture decisions
  +-- Engineer x3 (Sonnet agents) --- parallel TDD execution (Alpha/Beta/Gamma)
  +-- QA (built-in review agents) --- code-reviewer, security-reviewer, tdd-guide
  +-- Scribe (Haiku agent) ---------- docs, progress tracking, coordination
```

### Cost-Optimized Model Selection

| Role | Model | Cost | Usage |
|------|-------|------|-------|
| Architect / Escalation | Opus | $$$ | Architecture decisions, complex debugging |
| Engineer (Alpha/Beta/Gamma) | Sonnet | $$ | 90% of all development work |
| Scribe | Haiku | $ | Documentation, run frequently |

## Development Methodology: SDD + TDD

```
     DESIGN (Spec-Driven)                    BUILD (Test-Driven, per task)
spec.md -> plan.md -> task.md    ->    RED -> GREEN -> REFACTOR
 (what)     (how)      (steps)        (test)  (impl)   (clean)
 [approve]  [approve]   [QA]          x N agents in parallel
```

1. **Spec** (what & why) -- Architect writes, you approve
2. **Plan** (how) -- Architect writes, you approve architecture changes
3. **Tasks** (steps) -- decomposed with TDD structure, QA reviews
4. **Execute** -- Alpha/Beta/Gamma run parallel TDD cycles
5. **Verify** -- full test suite, code review, security review
6. **Deliver** -- completion report, you approve release

## What's Included

```
claude-robotics-toolkit/
|-- CLAUDE.md                        # Governance model (install to project root)
|-- rules/
|   |-- coding-and-patterns.md       # Style, immutability, ROS2/Python patterns
|   |-- security.md                  # OWASP, secrets, robotics-specific security
|   |-- testing.md                   # TDD methodology, 80% coverage, ROS2 testing
|   +-- workflow.md                  # Git conventions, docs hygiene
|-- skills/
|   |-- sdd-workflow.md              # Full SDD+TDD workflow (the core methodology)
|   |-- agent-team.md                # 5-agent team definitions (Lead/Alpha/Beta/Gamma/Scribe)
|   +-- ros2-development.md          # ROS2 lifecycle nodes, launch files, safety-critical rules
+-- settings.json.example            # Reference Claude Code settings
```

## Installation

### 1. Copy governance model to your project

```bash
cp CLAUDE.md /path/to/your/ros2_workspace/CLAUDE.md
```

Edit the `CLAUDE.md` to replace placeholder names with your own.

### 2. Install rules (global)

```bash
mkdir -p ~/.claude/rules/
cp rules/*.md ~/.claude/rules/
```

### 3. Install skills

Skills go into `~/.claude/skills/` -- each `.md` file becomes its own skill directory:

```bash
# Create skill directories
for skill in sdd-workflow agent-team ros2-development; do
  mkdir -p ~/.claude/skills/$skill
  cp skills/$skill.md ~/.claude/skills/$skill/SKILL.md
done
```

### 4. Install slash commands

Extract the commands section from `sdd-workflow.md` into a command file:

```bash
mkdir -p ~/.claude/commands/
# The SDD command entry point
cat > ~/.claude/commands/sdd.md << 'EOF'
---
description: "SDD+TDD workflow. spec.md -> plan.md -> task.md -> parallel TDD."
---
# SDD Command
$ARGUMENTS
See skill: sdd-workflow for full workflow.
EOF
```

### 5. Apply settings (optional)

```bash
# Review and merge with your existing settings
cat settings.json.example
```

## Key Concepts

### Decision Boundaries

Not everything needs your approval. The toolkit defines clear boundaries:

| Decision | Who Decides | You See |
|----------|-------------|---------|
| Function implementation | Engineer agents | Nothing |
| Bug fixes | Engineer agents | Nothing |
| New ROS2 nodes | Architect | Notification |
| Interface changes (msg/srv) | **You approve** | Executive Summary |
| New dependencies | **You approve** | Executive Summary |
| Security policy | **You decide** | Security report |
| Release to main | **You approve** | Completion report |

### Executive Summaries

Agents never dump full documents for your review. They provide structured summaries:

```markdown
## Review Request: [Module Name]
### One-liner
### Key Decisions (need your call)
### Impact
### Risks
```

### Parallel Execution

Alpha, Beta, and Gamma are identical Sonnet agents that work on independent tasks simultaneously via git worktrees. A wave of 3 tasks runs 3x faster than serial execution.

## Adapting for Non-ROS2 Projects

The governance model, SDD+TDD methodology, and agent team architecture work for any tech stack. To adapt:

1. In `CLAUDE.md`: replace ROS2 references with your framework
2. In `rules/`: swap `colcon` commands for your build system
3. In `skills/ros2-development.md`: replace with your domain-specific patterns
4. Keep everything else as-is -- the methodology is stack-agnostic

## Slash Commands

| Command | What It Does |
|---------|-------------|
| `/sdd init <desc>` | Start new feature -- create spec with test contracts |
| `/sdd spec` | Generate/revise specification |
| `/sdd plan` | Create technical plan with test strategy |
| `/sdd tasks` | Decompose into TDD-structured tasks |
| `/sdd execute` | Launch parallel TDD execution |
| `/sdd status` | Show phase + progress + test counts |
| `/sdd review` | Submit for owner review (executive summary) |
| `/sdd approve` | Approve current phase, advance |

## License

MIT
