<p align="center">
  <img src="vector.jpg" width="800" alt="VECTOR" />
</p>

<h1 align="center">Robotics CTO</h1>

<p align="center">
  <strong>你的 AI 工程团队。你做决策，Agent 写代码。</strong>
</p>

<p align="center">
  一套生产级 Claude Code 配置，让一个产品负责人拥有完整的机器人开发能力 -- AI Agent 自主完成需求分析、架构设计、并行 TDD 开发、代码审查和文档编写。
</p>

<p align="center">
  <a href="README.md">English</a> | 中文
</p>

---

## 痛点

开发机器人软件需要完整的工程团队：架构师、开发、测试、技术文档。招人慢、成本高、难以扩展。AI 编程助手有帮助，但你仍然需要逐个函数地微管理。

## 解决方案

**Robotics CTO** 在 Claude Code 内部构建了一个完整的 AI 工程组织：

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

### 5. 应用设置（可选）

```bash
# 先查看，再合并到你的 ~/.claude/settings.json
cat settings.json.example
```

### 6. 开始构建

```
/sdd init "添加 LIDAR 避障节点"
```

架构师 Agent 编写 spec。你审阅一段话的决策摘要。审批后，流水线自主运行直到交付。

---

## 命令

| 命令 | 功能 |
|------|------|
| `/sdd init <描述>` | 启动新功能 -- 创建含可测试验收标准的 spec |
| `/sdd spec` | 生成或修订规格说明 |
| `/sdd plan` | 创建含每模块测试策略的技术方案 |
| `/sdd tasks` | 分解为含依赖关系图的 TDD 任务 |
| `/sdd execute` | 启动 Alpha/Beta/Gamma 并行 TDD 执行 |
| `/sdd status` | 当前阶段、进度和测试指标 |
| `/sdd review` | 提交当前阶段供审阅（决策摘要） |
| `/sdd approve` | 审批并进入下一阶段 |

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

治理模型、SDD+TDD 方法论和 Agent 团队架构**与技术栈无关**。适配方法：

1. `CLAUDE.md` -- 替换技术栈部分
2. `rules/` -- 换成你的构建/测试工具链命令
3. `skills/ros2-development.md` -- 替换为你的领域模式
4. 其余部分原样使用

---

## 背景

在 [Vector Robotics](https://github.com/yusenthebot) 实战打磨 -- 开发自主导航栈、机械臂控制（SO-101 + MoveIt2）和感知管线。此配置每天用于真实的 ROS2 开发，Claude Code 就是整个工程团队。

## 许可证

MIT
