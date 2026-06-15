# spec-* 交付流水线 Skill 套件

一套 spec-driven（规范驱动）的 Claude Code skill，把研发流程「**需求 → 原型 → 设计 → 计划 → 变更**」固化为可复用命令。跨项目通用：每个 skill 优先读取项目自身的流程文档（`docs/engineering/workflow.md`、`prototype/_spec.md`、`docs/README.md`、`CLAUDE.md`）作为单一事实源，新项目则用内置默认规范。

> 🚀 **第一次用？看 [`GUIDE.md`](GUIDE.md) 使用手册**——用一个贯穿例子带你在新项目里从安装、初始化，到需求→原型→设计→计划→开发→评审→测试→合并走一遍。本 README 管「装/更新/维护本套件」，GUIDE 管「在项目里怎么用」。
>
> 演进记录见 [`CHANGELOG.md`](CHANGELOG.md)。

## 六个 skill

| 命令 | 阶段 | 输入 → 输出 | 落点 |
| --- | --- | --- | --- |
| `/spec-prd` | 需求 | 原始需求 → 规范化 PRD（R/F 需求编号 + AE/AC 验收 + 覆盖矩阵） | `docs/product/prd/` |
| `/spec-prototype` | 原型 | PRD → 纯静态可点击原型（仿 Element-UI、零依赖） | `docs/engineering/prototype/` |
| `/spec-design` | 设计 | PRD + 原型 → 技术设计（概要设计 + ER 模型 + 详细设计） | `docs/engineering/design/` |
| `/spec-plan` | 计划 | 设计 → 可执行计划（任务拆分 + migration + 三向覆盖矩阵，单元引用设计） | `docs/engineering/plans/` |
| `/spec-change` | 变更（横切） | 任意改动 → 先回流 PRD→原型→设计→plan，最后改代码 | 沿同一 `NNN` 改各产出物 |
| `/spec-check` | 校验（横切，只读） | 同一 `NNN` 的 PRD/原型/设计/plan → 覆盖矩阵一致性体检报告 | 不改文件，只出报告 |

> 想先看产出长什么样？[`examples/`](examples/) 有一份**完整样例**——会议室预约特性走完 PRD → 设计 → 计划 → 迁移，演示编号验收、覆盖矩阵、ER、权限四级、并发详细设计、字段长度规约等。

## 术语

| 缩写 | 含义 | 例子 |
| --- | --- | --- |
| **R / F** | 功能需求编号（一份 PRD 二选一） | `R8 预约占用名额` |
| **AE / AC** | 验收标准编号，须标注覆盖的需求号 | `AE2（R8）约满后拒绝` |

铁律：**续编不重排**；每条 AE/AC 标注覆盖的 R/F；可追溯链 `R/F → plan 任务 → AE/AC`，并落成**覆盖矩阵**随文档自检。

## 项目宪法（constitution）

项目级**原则的单一来源**：`docs/engineering/constitution.md`。它集中沉淀这套方法的不可妥协原则（单一事实源、先文档后代码、续编不重排、覆盖矩阵、显式非目标/NFR、右尺寸、阶段交接），六个 skill 执行前都读它并以它为准——各 skill 的「核心原则」只是它的精简内置默认。

- **优先级**：`constitution.md`（原则）> `docs/engineering/workflow.md`（流程/阶段标准）> skill 内置默认。
- **初始化**：新项目把**工程宪法 + 流程总纲 + 编码规约（CLAUDE.md）**一次装进项目——在项目根目录运行（skill 已装到用户级时）：
  - **Windows（PowerShell）**：
    ```powershell
    powershell -ExecutionPolicy Bypass -File "$HOME\.claude\skills\spec-init\init-project.ps1"
    ```
    > `-ExecutionPolicy Bypass` 是**临时授权，仅对这一次调用生效**，不改系统设置（规避 `Restricted` 策略禁止跑脚本）。覆盖已存在的加 `-Force`。
  - **macOS / Linux（bash）**：
    ```bash
    "$HOME/.claude/skills/spec-init/init-project.sh"
    ```
    > 覆盖已存在的加 `--force`。

  它把 `spec-init/templates/` 下的 `constitution.md`、`workflow.md` 复制到项目 `docs/engineering/`，`CLAUDE.md`（编码规约，含参阿里规约的命名/注释细则）复制到**项目根**（缺失才建）。也可手动复制这三份模板；跑 `/spec-prd` 时若检测到缺失也会主动提示初始化。

  > 脚手架（宪法 / 流程 / 编码规约 + init 脚本）独立放在 [`spec-init/`](spec-init/) 资源包里——它不是斜杠命令，只是随 `install` 一起装到用户级供初始化用，与 6 个 skill 区分开。
- **演进**：通过 PR/评审修订，提升其 `version`。

## 链路与阶段命令

```
原始需求
   │  /spec-prd                  ① 需求：澄清 → PRD（带编号验收）
   ▼
  PRD ──────────────┐
   │  /spec-prototype           ② 原型：画可点击页面 → 发客户确认
   ▼                │
 原型 ── 客户改需求? ──是──▶ /spec-change （先回流 PRD，再改原型/设计）
   │ 否◀──────────────┘
   │  /spec-design               ③ 设计：PRD+原型 → 概要设计 + ER + 详细设计
   ▼
 设计
   │  /spec-plan                 ④ 计划：设计 → 任务拆分 + migration + 覆盖矩阵
   ▼
 plan
   │  /spec-check                横切：开发/评审/提交前体检覆盖矩阵（只读，找断链与悬空）
   │  /ce-work                   ⑤ 开发：按 plan 实现（规范靠 CLAUDE.md 自动注入）
   │  /code-review               ⑥ 评审：（深度 /ce-code-review；清理 /simplify）
   │  /verify · /ce-test-browser ⑦ 测试：按 AE/AC 逐条验
   │  /ce-commit-push-pr         ⑧ 合并：开 PR；合并后 plan status: done
   ▼
 合并
```

> 规律：**产物是「独有格式的文档」→ 用本套件 `spec-*`；产物是代码/PR/评审这类通用产物 → 复用 compound-engineering 的 `ce-*`**。⑤–⑧ 不需要自建 skill。

## 前置依赖

本套件**核心的六个 `spec-*`**（需求/原型/设计/计划/变更/校验）可**独立运行**，不强依赖任何插件。

但若要跑**完整流水线**，需先安装 [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin) 插件——它提供链路 ⑤–⑧ 调用的 `ce-*` 命令，以及 `/spec-prd` 阶段可选的 `/ce-brainstorm`、`/ce-doc-review`：

| 用到 compound-engineering 的地方 | 涉及命令 | 是否必需 |
| --- | --- | --- |
| ⑤ 开发 | `/ce-work`、`/ce-worktree` | 跑完整流水线时必需 |
| ⑥ 评审（深度） | `/ce-code-review` | 可选（也可只用内置 `/code-review`、`/simplify`） |
| ⑦ 测试（前端） | `/ce-test-browser` | 可选 |
| ⑧ 合并 | `/ce-commit-push-pr` | 跑完整流水线时必需 |
| ① 需求（增强） | `/ce-brainstorm`、`/ce-doc-review` | 可选 |

安装（在 Claude Code 里执行）：

```
/plugin marketplace add EveryInc/compound-engineering-plugin
/plugin install compound-engineering
```

> 若你的 compound-engineering 来自其它市场/仓库，把上面的市场地址换成实际来源即可。只用 `spec-*` 写文档、不跑 ⑤–⑧ 的话，可跳过本节。

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

脚本会把六个 `spec-*` skill 目录 + `spec-init` 脚手架包复制到 `~/.claude/skills/`。

### 方式 B：项目级（团队随仓库共享）

把六个 skill 目录（+ `spec-init` 脚手架包）复制到目标项目的 `.claude/skills/` 下并提交：

- **Windows**：
  ```powershell
  Copy-Item -Recurse -Force .\spec-prd, .\spec-prototype, .\spec-design, .\spec-plan, .\spec-change, .\spec-check, .\spec-init <目标项目>\.claude\skills\
  ```
- **macOS / Linux**：
  ```bash
  mkdir -p <目标项目>/.claude/skills
  cp -R spec-prd spec-prototype spec-design spec-plan spec-change spec-check spec-init <目标项目>/.claude/skills/
  ```

### 方式 C：手动

把 `spec-prd/`、`spec-prototype/`、`spec-design/`、`spec-plan/`、`spec-change/`、`spec-check/` 六个 skill 目录（每个含 `SKILL.md`）+ `spec-init/`（脚手架包，无命令）放到
`~/.claude/skills/`（用户级）或 `<repo>/.claude/skills/`（项目级）即可。

### 生效

安装后 **重启 Claude Code**，斜杠菜单即出现 `/spec-prd` 等命令。验证：在 Claude Code 里输入 `/spec-` 应能补全到六个命令。

## 更新

重新 `git pull` 本仓库后，再跑一次安装脚本（脚本用 `-Force` / 覆盖复制，会更新到最新）。

## 维护者：从本机同步

维护者改完本机 `~/.claude/skills/spec-*` 后，用同步脚本把最新内容回灌到本仓库并提交：

- **Windows**：`.\sync-from-local.ps1 -Message "feat: ..." -Push`
- **macOS / Linux**：`./sync-from-local.sh "feat: ..." --push`

不带参数时只复制+暂存并显示改动（便于先 review 再提交）。

## 安全护栏（Claude Code hooks）

本仓库的 `.claude/` 里随包带了一套 **Claude Code 安全配置**，与 spec-* skill 相互独立——目的是给「让 Claude 跑命令/改文件」加一层护栏，**克隆即用**，不需要单独安装。

```
.claude/
├── settings.json   # permissions 护栏 + hooks 配置（团队共享）
└── hooks/          # 四个 PowerShell 脚本（纯 ASCII）
```

**permissions 护栏**（优先级 `deny > ask > allow`）：

| 类别 | 行为 | 覆盖 |
| --- | --- | --- |
| `deny` | 直接拦截 | 不可逆命令：递归强删、`dd`、`mkfs`、force push、`git reset --hard`、`Remove-Item -Recurse/-Force` 等 |
| `ask` | 强制确认 | 对外/高风险：`git push`、`npm publish`、`docker push`、`kubectl delete`、`terraform apply/destroy`、关机/重启 |

**hooks**（事件触发，比静态前缀规则更严密）：

| hook | 事件 | 作用 |
| --- | --- | --- |
| `block-dangerous-commands` | PreToolUse `Bash\|PowerShell` | 正则全文扫描命令并拦截危险写法（含路径在前、复合命令、`curl\|sh`）；扫描前剥离引号内字符串，避免「提交信息/echo 里提到危险字样」被误拦 |
| `protect-sensitive-files` | PreToolUse `Write\|Edit` | 拦截对 `.env`、私钥、`.ssh` 等秘密文件的写改（放过 `.env.example`） |
| `snapshot-baseline` + `summarize-changes` | SessionStart + Stop | 会话结束时汇总本次改动的文件 |

- **生效**：打开并信任目录后自动加载；首次可能需打开一次 `/hooks` 或重启。脚本路径用 `$env:CLAUDE_PROJECT_DIR` 引用，任意克隆都能解析。
- **个人配置**：`.claude/settings.local.json`（本机私有 allow 偏好）已被 `.gitignore` 排除，不随仓库分发。
- **可移植性**：hook 为 PowerShell 脚本（`shell: "powershell"`）。Windows 直接可用；macOS / Linux 协作者需安装 `pwsh`（PowerShell Core），或自行补 bash 版。

## 卸载

删除 `~/.claude/skills/` 下（或项目 `.claude/skills/` 下）的 `spec-prd`、`spec-prototype`、`spec-design`、`spec-plan`、`spec-change`、`spec-check` 六个目录 + `spec-init`，重启 Claude Code。

## 为什么「设计」是一份文档（概要 + ER + 详细，不拆开）

`/spec-design` 把**概要设计、数据 ER、详细设计**放进**同一份 `design.md`**，刻意不拆成多份：

- **拆文档不解决「详细设计白写」问题**——ER 改了，依赖它的详细设计就得改，这是**逻辑依赖**，跟它在同一文件还是另一文件无关，拆开少改不了一个字。
- **拆开反而违背单一事实源**——概要 ↔ ER ↔ 详细一旦分家最容易互相漂移；一份文档顺着读，三者一致与否一眼可见。

真正压低「白写」风险的是**顺序 + 右尺寸**，已固化进 skill：

- **检查点**：先把概要 + ER 回显确认（承重决策锁定）再写详细设计；详细设计每段**标注它依赖的概要/ER 小节**，ER 一旦改，一眼看出哪些详细要跟着动。
- **右尺寸**：详细设计只写 AI 推不出、或推错代价高的决策；CRUD/样板留给 `ce-work` 生成后评审——改也只改那几条，且 AI 重生成很便宜。
- **设计反馈**：详细设计逼出 ER 改动，是在**设计期暴露缺陷**（比编码期/上线后便宜一个数量级），不算白写。

## 设计原则

单一事实源 · 双向可追溯（R/F→任务→AE/AC，落成覆盖矩阵自检）· 非功能约束显式 · 高风险需求用可测句式（EARS 风格）· 模板外置（产出物骨架放各 skill 的 `templates/`，SKILL.md 渐进披露）· **右尺寸**（见下）· 一次一问澄清 · 回流写回（先文档后代码）· 阶段交接（每个 skill 指向下一个）。

### 右尺寸（right-sizing）

**投入的力气与文档的详细程度，要匹配这件事的实际复杂度——既不过度，也不潦草。** 简单的事轻量化，复杂的事才上重流程。它反对两种极端：

- **过度**：给「加个按钮」也走 PRD→原型→设计→计划四份文档、画一堆图、填满表格。
- **不足**：给「占名额并发」这种高风险逻辑只写一句话就开干。

各 skill 的体现：
- `/spec-prd`：简单清晰的需求**少追问、直接定稿**；模糊或跨切的才多轮澄清。
- `/spec-prototype`·`/spec-design`：纯后端小改**可跳过原型**；字段长度、时间戳等规约**「涉及才写」**（没有就如实写「无」，不硬塞空表）。
- `/spec-design` 详细设计：**只写 AI 推不出、或推错代价高的决策**（并发/状态机/权限）；CRUD、样板签名等能可靠生成的**不写**，留给 `ce-work`。

> 一句话：**该详则详，该略则略；按需要给力气，不为流程而流程。** 参见 [`examples/`](examples/)——同一套 skill，复杂逻辑（并发占名额）详细展开，CRUD 直接声明「留给 ce-work」，正是两种尺寸。

> 以上原则的规范来源是项目的 `docs/engineering/constitution.md`（工程宪法，由 `/spec-prd` 初始化）——各 skill 引用它，而非各自硬编码。
