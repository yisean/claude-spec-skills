# spec-* 交付流水线 Skill 套件

一套 spec-driven（规范驱动）的 Claude Code skill，把研发流程「**需求 → 原型 → 计划+设计 → 变更**」固化为可复用命令。跨项目通用：每个 skill 优先读取项目自身的流程文档（`docs/engineering/workflow.md`、`prototype/_spec.md`、`docs/README.md`、`CLAUDE.md`）作为单一事实源，新项目则用内置默认规范。

## 四个 skill

| 命令 | 阶段 | 输入 → 输出 | 落点 |
| --- | --- | --- | --- |
| `/spec-prd` | 需求 | 原始需求 → 规范化 PRD（R/F 需求编号 + AE/AC 验收） | `docs/product/prd/` |
| `/spec-prototype` | 原型 | PRD → 纯静态可点击原型（仿 Element-UI、零依赖） | `docs/engineering/prototype/` |
| `/spec-plan` | 计划+设计 | PRD + 原型 → 含设计的实现计划（概要设计 + ER 模型 + 详细设计 + 任务 + migration） | `docs/engineering/plans/` |
| `/spec-change` | 变更（横切） | 任意改动 → 先回流 PRD→原型→plan，最后改代码 | 沿同一 `NNN` 改各产出物 |

## 术语

| 缩写 | 含义 | 例子 |
| --- | --- | --- |
| **R / F** | 功能需求编号（一份 PRD 二选一） | `R8 预约占用名额` |
| **AE / AC** | 验收标准编号，须标注覆盖的需求号 | `AE2（R8）约满后拒绝` |

铁律：**续编不重排**；每条 AE/AC 标注覆盖的 R/F；可追溯链 `R/F → plan 任务 → AE/AC`。

## 链路与阶段命令

```
原始需求
   │  /spec-prd                  ① 需求：澄清 → PRD（带编号验收）
   ▼
  PRD ──────────────┐
   │  /spec-prototype           ② 原型：画可点击页面 → 发客户确认
   ▼                │
 原型 ── 客户改需求? ──是──▶ /spec-change （先回流 PRD，再改原型）
   │ 否◀──────────────┘
   │  /spec-plan                 ③ 计划+设计：PRD+原型 → 概要设计+ER+详细设计+任务
   ▼
 plan
   │  /ce-work                   ④ 开发：按 plan 实现（规范靠 CLAUDE.md 自动注入）
   │  /code-review               ⑤ 评审：（深度 /ce-code-review；清理 /simplify）
   │  /verify · /ce-test-browser ⑥ 测试：按 AE/AC 逐条验
   │  /ce-commit-push-pr         ⑦ 合并：开 PR；合并后 plan status: done
   ▼
 合并
```

> 规律：**产物是「独有格式的文档」→ 用本套件 `spec-*`；产物是代码/PR/评审这类通用产物 → 复用 compound-engineering 的 `ce-*`**。④–⑦ 不需要自建 skill。

## 安装

skill 装到 **用户级**（`~/.claude/skills/`，本机所有项目可用）或**项目级**（`<repo>/.claude/skills/`，随该仓库共享给团队）。二选一。

### 方式 A：用户级，一键脚本（推荐）

clone 本仓库后，在仓库根目录运行：

- **Windows（PowerShell）**：
  ```powershell
  .\install.ps1
  ```
- **macOS / Linux（bash）**：
  ```bash
  ./install.sh
  ```

脚本会把四个 `spec-*` 目录复制到 `~/.claude/skills/`。

### 方式 B：项目级（团队随仓库共享）

把四个 skill 目录复制到目标项目的 `.claude/skills/` 下并提交：

- **Windows**：
  ```powershell
  Copy-Item -Recurse -Force .\spec-prd, .\spec-prototype, .\spec-plan, .\spec-change <目标项目>\.claude\skills\
  ```
- **macOS / Linux**：
  ```bash
  mkdir -p <目标项目>/.claude/skills
  cp -R spec-prd spec-prototype spec-plan spec-change <目标项目>/.claude/skills/
  ```

### 方式 C：手动

把 `spec-prd/`、`spec-prototype/`、`spec-plan/`、`spec-change/` 四个目录（每个含 `SKILL.md`）放到
`~/.claude/skills/`（用户级）或 `<repo>/.claude/skills/`（项目级）即可。

### 生效

安装后 **重启 Claude Code**，斜杠菜单即出现 `/spec-prd` 等命令。验证：在 Claude Code 里输入 `/spec-` 应能补全到四个命令。

## 更新

重新 `git pull` 本仓库后，再跑一次安装脚本（脚本用 `-Force` / 覆盖复制，会更新到最新）。

## 卸载

删除 `~/.claude/skills/` 下（或项目 `.claude/skills/` 下）的 `spec-prd`、`spec-prototype`、`spec-plan`、`spec-change` 四个目录，重启 Claude Code。

## 设计原则

单一事实源 · 双向可追溯（R/F→任务→AE/AC）· 右尺寸（简单需求少追问）· 一次一问澄清 · 回流写回（先文档后代码）· 阶段交接（每个 skill 指向下一个）。
