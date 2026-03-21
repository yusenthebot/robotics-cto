<p align="center">
  <img src="vector.jpg" width="800" alt="VECTOR" />
</p>

<h1 align="center">Robotics CTO</h1>

<p align="center">
  <strong>你的 AI 工程团队。你做决策，Agent 写代码， 跑测试， 给反馈。</strong>
  <br/>
  <strong>Your AI engineering team for robotics. You lead. Agents build.</strong>
</p>

<p align="center">
  中文 | <a href="#english">English</a>
</p>

---

## 痛点

开发机器人软件需要完整的工程团队：架构师、开发、测试、技术文档。招人慢、成本高、一人全栈实在太行苦。AI 编程助手有帮助，但你仍然需要逐个函数地微管理。

## 解决方案

**Robotics CTO** 在 Claude Code 内部构建了一个完整的 AI 工程组织,高效率利用agent teams：

```
你（产品负责人）
  |  审批 spec、架构、发布
  v
调度器（Opus）-- 任务路由，生成决策摘要
  |
  +-- 架构师（Opus）------------ 编写 spec，系统设计，技术选型
  +-- Alpha（Sonnet）------------ 核心开发，并行 TDD
  +-- Beta（Sonnet）------------- 核心开发，并行 TDD
  +-- Gamma（Sonnet）------------ 核心开发，并行 TDD
  +-- QA（内置 Agent）----------- 代码审查，安全审查，测试验证
  +-- 记录员（Haiku）------------ 文档，进度追踪
```

你描述想要什么。Agent 负责搞清楚怎么做 -- 先写测试、并行实现、互相审查、交付完成报告。你只需要审批或驳回。

---

## 工作原理

### SDD + TDD：规格驱动 + 测试驱动

每个功能都经过严格的流水线：

```
设计（SDD）                                构建（TDD）
spec.md --> plan.md --> task.md    -->    RED --> GREEN --> REFACTOR
（做什么）   （怎么做）   （分步骤）       （写测试）（实现）  （重构）
 [你审批]    [你审批]      [QA]            x3 Agent 并行执行
```

**核心理念**：
- **SDD（Spec-Driven Development）** 是外循环 -- 管理"造什么"
- **TDD（Test-Driven Development）** 是内循环 -- 验证"造对了没"
- 两者结合：spec 变成测试，测试变成代码，全链路可追溯

### 决策边界

不是所有事情都需要你关注。系统知道什么该上报：

| 决策类型 | 谁决定 | 你看到什么 |
|----------|--------|-----------|
| 函数实现、Bug 修复 | Agent 自主完成 | 无 |
| 新增组件 | 架构师决定 | 简短通知 |
| 接口变更、新增依赖 | **你审批** | 决策摘要 |
| 安全策略、硬件接口变更 | **你决定** | 详细报告 |
| 发布到生产环境 | **你审批** | 含测试结果的完成报告 |

### 并行执行

三个完全相同的 Sonnet Agent（Alpha、Beta、Gamma）通过 git worktree 同时处理独立任务。三个任务的工作量，一个任务的时间完成。

### 成本优化的模型分层

| 层级 | 模型 | 角色 | 使用场景 |
|------|------|------|---------|
| 推理层 | Opus | 架构设计，难题升级 | 仅复杂决策 |
| 执行层 | Sonnet | 开发，测试 | 90% 的日常工作 |
| 工具层 | Haiku | 文档，追踪 | 高频运行，几乎零成本 |

---

## 包含内容

```
robotics-cto/
|-- CLAUDE.md                        # 治理模型 -- 放到任何项目根目录
|-- rules/
|   |-- coding-and-patterns.md       # 编码规范，不可变性，ROS2 + Python 模式
|   |-- security.md                  # OWASP，密钥管理，机器人安全
|   |-- testing.md                   # TDD 方法论，80% 覆盖率，ROS2 三层测试
|   +-- workflow.md                  # Git 规范，文档卫生
|-- skills/
|   |-- sdd-workflow.md              # 完整 SDD+TDD 流程（含模板）
|   |-- agent-team.md                # 5 个 Agent 的定义和协作协议
|   +-- ros2-development.md          # 生命周期节点，QoS，安全关键规则，TF2
+-- settings.json.example            # Claude Code 参考配置
```

---

## 快速开始

把这个 repo 链接发给你的 Claude Code，让它自动配置。
或者手动安装：

### 1. 将治理模型放入项目

```bash
cp CLAUDE.md /path/to/your/ros2_workspace/CLAUDE.md
```

### 2. 全局安装规则

```bash
mkdir -p ~/.claude/rules/
cp rules/*.md ~/.claude/rules/
```

### 3. 安装技能

```bash
for skill in sdd-workflow agent-team ros2-development; do
  mkdir -p ~/.claude/skills/$skill
  cp skills/$skill.md ~/.claude/skills/$skill/SKILL.md
done
```

### 4. 设置斜杠命令

```bash
mkdir -p ~/.claude/commands/
cat > ~/.claude/commands/sdd.md << 'EOF'
---
description: "SDD+TDD workflow. spec.md -> plan.md -> task.md -> parallel TDD."
---
# SDD Command
$ARGUMENTS
See skill: sdd-workflow for full workflow.
EOF
```

### 5. 开始构建

```
/sdd init "添加 LIDAR 避障节点"
```

架构师 Agent 编写 spec。你审阅一段话的决策摘要。审批后，流水线自主运行直到交付。

---

## ROS2 原生支持

开箱即用的 ROS2 Humble 生产级模式：

- **生命周期节点** -- 所有硬件接口的确定性启动/关闭
- **QoS 策略矩阵** -- 命令用 RELIABLE，高频传感器用 BEST_EFFORT
- **Launch 文件模式** -- 参数化的仿真/实机切换
- **安全关键规则** -- 实时路径零动态分配，看门狗定时器，急停独立性
- **三层测试** -- 单元（pytest/gtest）、集成（launch_testing）、系统（仿真）
- **TF2 坐标系规范** -- 标准变换树管理
- **组件容器** -- 零拷贝进程内通信

---

## 适配其他技术栈

治理模型、SDD+TDD 方法论和 Agent 团队架构与技术栈无关。适配方法：

1. `CLAUDE.md` -- 替换技术栈部分
2. `rules/` -- 换成你的构建/测试工具链命令
3. `skills/ros2-development.md` -- 替换为你的领域模式
4. 其余部分原样使用

---

## 背景

在 [Vector Robotics](https://github.com/yusenthebot) 实战打磨 -- 开发自主导航栈、机械臂控制（SO-101 + MoveIt2）和感知管线。此配置每天用于真实的 ROS2 开发，Claude Code 就是整个工程团队。

---

<a name="english"></a>

# English

<p align="center">
  <a href="#robotics-cto">中文</a> | English
</p>

## The Problem

Building robotics software requires a full engineering team: architects, developers, QA, technical writers. Hiring is slow, expensive, and hard to scale. AI coding assistants help, but they still need you to micromanage every function.

## The Solution

**Robotics CTO** gives you a complete AI engineering organization inside Claude Code:

```
You (Product Owner)
  |  approve specs, architecture, releases
  v
Dispatcher (Opus) -- routes tasks, prepares executive summaries
  |
  +-- Architect (Opus) ---------- writes specs, designs systems, makes tech decisions
  +-- Alpha (Sonnet) ------------ core developer, parallel TDD execution
  +-- Beta (Sonnet) ------------- core developer, parallel TDD execution
  +-- Gamma (Sonnet) ------------ core developer, parallel TDD execution
  +-- QA (built-in agents) ------ code review, security review, test enforcement
  +-- Scribe (Haiku) ------------ documentation, progress tracking
```

You describe what you want. The agents figure out how, write tests first, implement in parallel, review each other's code, and deliver a completion report. You approve or reject.

---

## How It Works

### Spec-Driven Development + Test-Driven Development

Every feature flows through a disciplined pipeline:

```
DESIGN                                    BUILD
spec.md --> plan.md --> task.md    -->    RED --> GREEN --> REFACTOR
 (what)      (how)      (steps)          (test)   (impl)    (clean)
 [you]       [you]       [QA]            x3 agents in parallel
```

### Decision Boundaries

Not everything needs your attention. The system knows what to escalate:

| Decision | Who Decides | What You See |
|----------|-------------|--------------|
| Function implementation, bug fixes | Agents autonomously | Nothing |
| New components | Architect decides | Brief notification |
| Interface changes, new dependencies | **You approve** | Executive summary |
| Security policy, hardware changes | **You decide** | Detailed report |
| Release to production | **You approve** | Completion report with test results |

### Parallel Execution

Three identical Sonnet agents (Alpha, Beta, Gamma) work on independent tasks simultaneously via git worktrees. A wave of 3 tasks completes in the time of 1.

### Cost-Optimized Model Tiers

| Tier | Model | Role | When |
|------|-------|------|------|
| Reasoning | Opus | Architecture, escalation | Complex decisions only |
| Execution | Sonnet | Development, testing | 90% of all work |
| Utility | Haiku | Documentation, tracking | Run frequently, nearly free |

---

## What's Included

```
robotics-cto/
|-- CLAUDE.md                        # Governance model -- drop into any project root
|-- rules/
|   |-- coding-and-patterns.md       # Style guide, immutability, ROS2 + Python patterns
|   |-- security.md                  # OWASP, secrets management, robotics-specific security
|   |-- testing.md                   # TDD methodology, 80% coverage, 3-layer ROS2 testing
|   +-- workflow.md                  # Git conventions, documentation hygiene
|-- skills/
|   |-- sdd-workflow.md              # Complete SDD+TDD pipeline with templates
|   |-- agent-team.md                # 5-agent team definitions and coordination protocol
|   +-- ros2-development.md          # Lifecycle nodes, QoS, safety-critical patterns, TF2
+-- settings.json.example            # Reference Claude Code configuration
```

---

## Quick Start

Give the link to your agent and let it set up for you.
Or install manually:

### 1. Drop the governance model into your project

```bash
cp CLAUDE.md /path/to/your/ros2_workspace/CLAUDE.md
```

### 2. Install rules globally

```bash
mkdir -p ~/.claude/rules/
cp rules/*.md ~/.claude/rules/
```

### 3. Install skills

```bash
for skill in sdd-workflow agent-team ros2-development; do
  mkdir -p ~/.claude/skills/$skill
  cp skills/$skill.md ~/.claude/skills/$skill/SKILL.md
done
```

### 4. Set up the SDD slash command

```bash
mkdir -p ~/.claude/commands/
cat > ~/.claude/commands/sdd.md << 'EOF'
---
description: "SDD+TDD workflow. spec.md -> plan.md -> task.md -> parallel TDD."
---
# SDD Command
$ARGUMENTS
See skill: sdd-workflow for full workflow.
EOF
```

### 5. Start building

```
/sdd init "Add LIDAR obstacle avoidance node"
```

The Architect agent writes a spec. You review a one-paragraph executive summary. Approve, and the pipeline runs autonomously until delivery.

---

## Commands

| Command | Action |
|---------|--------|
| `/sdd init <description>` | Start a new feature -- creates spec with testable acceptance criteria |
| `/sdd spec` | Generate or revise the specification |
| `/sdd plan` | Create technical plan with test strategy per module |
| `/sdd tasks` | Decompose into TDD-structured tasks with dependency graph |
| `/sdd execute` | Launch parallel TDD execution across Alpha/Beta/Gamma |
| `/sdd status` | Current phase, progress, and test metrics |
| `/sdd review` | Submit current phase for your review (executive summary) |
| `/sdd approve` | Approve and advance to next phase |

---

## ROS2-Native

The toolkit ships with production patterns for ROS2 Humble:

- **Lifecycle nodes** -- deterministic startup/shutdown for all hardware interfaces
- **QoS strategy matrix** -- RELIABLE for commands, BEST_EFFORT for high-frequency sensors
- **Launch file patterns** -- parameterized sim/real switching
- **Safety-critical rules** -- no dynamic allocation in RT paths, watchdog timers, E-stop independence
- **3-layer testing** -- unit (pytest/gtest), integration (launch_testing), system (simulation)
- **TF2 frame conventions** -- standard transform tree management
- **Component containers** -- zero-copy intra-process communication

---

## Adapting to Other Stacks

The governance model, SDD+TDD methodology, and agent team architecture are **stack-agnostic**. To use with a different framework:

1. `CLAUDE.md` -- replace the tech stack section
2. `rules/` -- swap build/test commands for your toolchain
3. `skills/ros2-development.md` -- replace with your domain patterns
4. Everything else works as-is

---

## Background

Built and battle-tested at [Vector Robotics](https://github.com/yusenthebot) -- developing autonomous navigation stacks, robotic arm control (SO-101 + MoveIt2), and perception pipelines. This configuration runs real ROS2 development daily with Claude Code as the entire engineering team.

## License

MIT
