# spec-* 使用手册：在新项目里从需求走到合并

> 给团队同事的上手教程。跟着从上往下做一遍，你就能在一个**全新项目**里，用这套 skill 把一个特性从「一句话需求」一路推到「干净合并进主干」。
>
> - 本手册管**怎么用**；安装/更新/维护本套件本身见 [`README.md`](README.md)，演进记录见 [`CHANGELOG.md`](CHANGELOG.md)。
> - 全程用一个**贯穿例子**——「会议室预约」——演示每一步。它的完整真实产物在 [`examples/`](examples/)，看不懂哪一步可以对着 examples 翻。
> - 当前年份 **2026**。

---

## 这套件是什么（30 秒版）

把研发流程「**需求 → 原型 → 设计 → 计划 → 开发 → 评审 → 测试 → 合并**」固化成斜杠命令。前四步产出的是**有独有格式的文档**（PRD/原型/设计/计划），由本套件 6 个 `spec-*` 命令生成；后四步产出代码/PR 这类通用产物，复用 compound-engineering 的 `ce-*` 命令。

```
原始需求 ─/spec-prd─▶ PRD ─/spec-prototype─▶ 原型 ─/spec-design─▶ 设计 ─/spec-plan─▶ 计划
                                                                                  │
   ┌──────────────────────────────────────────────────────────────────────────────┘
   ▼
 /ce-work（开发）─▶ /code-review（评审）─▶ /verify（测试）─▶ /ce-commit-push-pr（合并）

 横切：/spec-check 任意阶段体检覆盖矩阵（只读）；/spec-change 需求变更先回流文档再改代码
```

**三条铁律**（贯穿全程，记住它就懂了一半）：

1. **先文档后代码** —— 改需求/设计永远先改文档，再改代码。代码不是事实源，文档才是。
2. **续编不重排** —— 需求号 `R/F`、验收号 `AE/AC`、任务号 `U`、特性号 `NNN` 只往后接，绝不重新排号。
3. **同一特性同一 `NNN`** —— PRD、设计、计划、迁移用同一个三位序号串起来，一眼对应、可双向追溯。

**术语**（4 个就够）：

| 缩写 | 含义 | 例子 |
| --- | --- | --- |
| `NNN` | 特性序号（三位） | `001` 会议室预约 |
| `R` / `F` | 功能需求编号（一份 PRD 二选一） | `R3 重叠时段拒绝` |
| `AE` / `AC` | 验收标准编号，须标注覆盖的需求号 | `AE1（R2/R3）并发仅一人成功` |
| `U` | 计划里的实现单元（可独立认领的任务） | `U3 后端预约服务` |

可追溯链：**`R/F`（要做什么）→ `U`（怎么做）→ `AE/AC`（怎么算做对了）**，落成**覆盖矩阵**自检。

---

## 第 0 步 · 一次性准备

> 装 skill 是**每台机器一次**；初始化项目是**每个新项目一次**。都做完才进入正式流程。

### 0.1 安装 skill（每台机器一次）

clone 本仓库，在仓库根目录运行：

- **Windows（PowerShell）**：
  ```powershell
  .\install.ps1
  ```
- **macOS / Linux**：
  ```bash
  ./install.sh
  ```

脚本把 6 个 `spec-*` skill + `spec-init` 脚手架装到用户级 `~/.claude/skills/`（本机所有项目可用）。装完**重启 Claude Code**，输入 `/spec-` 能补全出六个命令即成功。

> 想让团队随某个仓库共享、不用各自装，改用「项目级」安装（复制到该仓库 `.claude/skills/` 并提交）——见 README「方式 B」。

### 0.2 （可选）装 compound-engineering，跑完整流水线

6 个 `spec-*` 能独立写文档。但**开发→评审→测试→合并**（阶段 ⑤–⑧）用的是 compound-engineering 的 `ce-*` 命令。要跑完整流水线，在 Claude Code 里：

```
/plugin marketplace add EveryInc/compound-engineering-plugin
/plugin install compound-engineering
```

只用 `spec-*` 写文档、不跑后四步的话可跳过。

### 0.3 初始化新项目（每个新项目一次）

进入你的**目标项目根目录**，运行 `spec-init` 把工程宪法、流程总纲、编码规约、取号登记表一次装进去：

- **Windows**：
  ```powershell
  powershell -ExecutionPolicy Bypass -File "$HOME\.claude\skills\spec-init\init-project.ps1"
  ```
  > `-ExecutionPolicy Bypass` 只对这一次调用临时授权，不改系统设置。覆盖已存在的加 `-Force`。
- **macOS / Linux**：
  ```bash
  "$HOME/.claude/skills/spec-init/init-project.sh"
  ```
  > 覆盖加 `--force`。

它会创建：

```
docs/
├── product/prd/                 PRD 定稿落点（阶段 1）
├── engineering/
│   ├── constitution.md          工程宪法（不可妥协原则 + 编码基线）★装好后填 version/date
│   ├── workflow.md              研发流程总纲（8 阶段 DoR/DoD）★按技术栈补 <占位符>
│   ├── registry.md              NNN 取号登记表（多人协作的单一事实源）
│   ├── prototype/               原型落点（阶段 2）
│   ├── design/                  设计落点（阶段 3）
│   └── plans/                   计划落点（阶段 4）
└── ops/install/                 迁移脚本落点（阶段 4）
CLAUDE.md                        项目编码规约（AI 写代码时自动加载）★按技术栈填 <占位符>
```

**装完务必做一件事**：打开 `CLAUDE.md` 和 `docs/engineering/workflow.md`，把 `<后端栈，如 SpringBoot + MyBatis-Plus>`、`<前端栈，如 Vue + Element-UI>` 这类占位符换成你项目的真实技术栈。这份 `CLAUDE.md` 会在 `/ce-work` 写代码时自动注入，决定生成代码的命名/分层/规约——填准它，后面省很多事。

> 这四份是**项目级的单一事实源**。各 skill 执行前都读它们，优先级 `constitution.md` > `workflow.md` > skill 内置默认。以后规约演进改这几份即可，不用改 skill。

---

## 第 1 步 · 取号（先登记后开工）

> 多人并行时，「现有最大号 + 1」在各自分支里互相看不见，合并才撞号。规矩是把取号挪到**共享的 main 上、且在开工之前**。单人开发也建议照做，养成习惯。

1. 切到最新 main，先看到别人已登记的号：
   ```bash
   git checkout main && git pull
   ```
2. 在 `docs/engineering/registry.md` 表格**追加一行**，`NNN = 当前最大号 + 1`，status 填 `reserved`：
   ```
   | 001 | meeting-room-booking | 张三 | 2026-06-09 | reserved | 会议室预约 |
   ```
3. **只提交这一行**并 push 进 main（仅这一行，可免 PR）：
   ```bash
   git add docs/engineering/registry.md
   git commit -m "chore(registry): 预留 NNN=001 meeting-room-booking"
   git push
   ```
   > 并发抢同号时，后 push 者会被拒（non-fast-forward）或 PR 合并时本表冲突 → **当场暴露** → 改取下一个号重来。
4. 再开特性分支，正式开工：
   ```bash
   git checkout -b feat/001-meeting-room-booking
   ```

**状态约定**：`reserved`（已预留/开发中）→ `done`（已合并交付）；放弃改 `abandoned`。**号一经预留即作废不回收**（回收会打断 design/plan/测试/历史的引用）。

> 老项目还没建 `registry.md`？`/spec-prd` 会退回「max+1」并提示补建——多人协作强烈建议补上。

---

## 第 2 步 · 需求 → PRD（`/spec-prd`）

把模糊想法澄清成「问题 + 关键决策 + 带编号的可验收需求清单」。

**命令**（在特性分支里）：
```
/spec-prd 员工自助预约会议室，同一间同一时段不能被两个人订，管理员能维护会议室
```

**会被问什么**：`/spec-prd` 会一次一问地澄清——目标用户与角色、明确的**非目标**（本期不做什么）、关键决策（如「撞车按时间段重叠判定，不是简单相等」）、边界与并发要求。简单清晰的需求少追问直接定稿；模糊/跨切的才多轮澄清（**右尺寸**）。

**产出**：`docs/product/prd/2026-06-09-001-meeting-room-booking.md`，含背景、目标/非目标、角色、关键决策、`R` 功能需求、非功能约束、`AE` 验收、**覆盖矩阵**、成功指标、依赖假设、待解决问题。

**产出长这样**（节选自 [examples](examples/product/prd/2026-06-09-001-meeting-room-booking.md)）：

```
## 5. 功能需求（R）
- R2 员工可预约某会议室的一个时间段（须 开始 < 结束，且填会议主题）。
- R3 当某时间段已被预约时，系统应拒绝与之时间重叠的新预约。
...
## 7. 验收标准（AE，标注覆盖的 R）
- AE1（R2/R3） 两名员工同时预约「301 会议室 14:00–15:00」，仅一人成功，另一人收到「时段已被占用」。
- AE2（R2） 结束时间 ≤ 开始时间，被拒并提示。
## 8. 覆盖矩阵
| 需求 | 覆盖它的验收 | 非功能约束 |
| R3 重叠拒绝 | AE1 | 并发安全 |
```

**完成判据（DoD）**：PRD 含背景与问题、目标/**非目标**、角色、关键决策、**带编号的功能需求**、**非功能约束**、**可验收的验收标准（每条标注覆盖的 R/F）**、**覆盖矩阵**、成功指标、依赖假设。每条 `R/F` 至少有一条 `AE/AC` 覆盖。

> 探讨期想先发散，可先用 `/ce-brainstorm` 聊清楚再 `/spec-prd` 定稿。**已上线/在研特性的增量改动不要用 `/spec-prd`，改用 `/spec-change`**（见第 11 步）。

---

## 第 3 步 · 原型（`/spec-prototype`，按需）

写代码前把交互、信息架构、字段显隐用**可点击页面**表达出来，供内部对齐或发客户演示。

**何时做**：涉及新界面/复杂交互的特性。**纯后端或微调可跳过**这一步。

**命令**：
```
/spec-prototype
```

**产出**：`docs/engineering/prototype/` 下的纯静态 HTML 页面 + `index.html` 导航 + `_spec.md` 规范。**仿 Element-UI、零外部依赖、双击即开**——发给客户也能直接打开点。

**完成判据**：关键页面可点击跑通主流程；PRD 里 UI 相关的 `R/F` 都能在原型找到对应页面。

> 原型是**沟通与验证载体，不是实现**。定稿后它成为后续前端任务的「UI 参考基线」——开发阶段前端**对照原型用真组件还原**，不照抄原型 HTML。
>
> ⚠️ 发客户确认后如果客户要改需求，**不要直接改原型**——走 `/spec-change` 先回流 PRD，再改原型（先文档后代码）。

### 跳过原型后，前端依据从哪来？

链路不断，只是「UI 参考基线」这个角色换人。分两种情况：

- **纯后端 / 无界面特性**（原型本就不需要）：前端链路整条不适用，正常往下走。设计的「前端设计」节如实写「无」；计划里没有「原型页面」那一行；`/spec-check` 的 C9（原型覆盖）只在有原型时才查，**不会因没原型而 FAIL**；`/ce-work` 直接按设计写后端。这是**正常路径**，不缺任何东西。

- **有界面但跳过了原型**（赶时间 / 内部小工具）：原型那道「画出来对齐 + 发客户确认」没了，**UI 真值来源让位给设计文档的「前端设计」节**：

  | 环节 | 有原型时 | 无原型时 |
  | --- | --- | --- |
  | UI 真值来源 | `prototype/` 对应页面 | **设计的「前端设计」节**（页面+路由+字段+调哪些接口） |
  | `/spec-plan` 前端单元 | 引用 `原型页面: prototype/xxx.html` | 省掉该行，**设计依据**指向 design「前端设计」 |
  | `/ce-work` 怎么还原 | 对照原型用真组件还原 | 按设计前端设计 + **`/ce-frontend-design` 实现、收尾截图自检** |

  ⚠️ 代价：少了原型这道「编码前对齐 + 客户确认」，需求理解偏差可能拖到编码期才暴露（比原型期发现贵一个数量级）。所以**涉及客户演示、或交互较复杂的界面仍建议补原型**；只有内部、交互简单的才适合直接靠设计前端设计跑。

---

## 第 4 步 · 设计（`/spec-design`）

以 PRD + 原型为输入，定整体架构、数据模型与关键流程的详细设计——拆任务的前提。

**命令**：
```
/spec-design
```

**产出**：`docs/engineering/design/2026-06-09-001-feat-meeting-room-booking-design.md`，**一份文档**含三部分：

- **概要设计**：架构/模块、技术选型与关键决策、接口清单与契约（含鉴权/校验/**新增错误码**/请求-返回示例）、前端设计（页面+路由+页面间关系）、**权限四级**（菜单/按钮/接口/数据行级）、可观测与审计、NFR 承接、风险。
- **数据 ER 模型**：Mermaid `erDiagram`，带**时间戳规约**与**字段长度规约表**。
- **详细设计**：接口签名、核心逻辑、并发与幂等、代码结构落点；每段标注它依赖的概要/ER 小节。

**两个关键机制**（这是设计阶段最省事的地方）：

1. **检查点**：先把**概要 + ER 回显确认**（承重决策锁定）再写详细设计。ER 一改，一眼看出哪些详细设计要跟着动。
2. **右尺寸**：详细设计**只写 AI 推不出、或推错代价高的决策**（如本例的「并发防重订：行锁 + 区间重叠校验」「取消归属」）；CRUD、列表、表单这类**能可靠生成的不写，显式声明「留给 ce-work」**。

> 为什么概要+ER+详细放一份不拆开？因为它们是**逻辑依赖**——ER 改了依赖它的详细设计就得改，拆成多文件也省不了一个字，反而容易互相漂移。顺着一份读，三者一致与否一眼可见。详见 [README「为什么设计是一份文档」](README.md)。

**完成判据**：概要/ER/详细三部分齐全；每段标注覆盖的 `R/F`；涉及界面的有「前端设计」节，高并发写场景有「并发与幂等」节，多角色有「权限」设计。

---

## 第 5 步 · 计划（`/spec-plan`）

据设计把方案拆成**可独立认领的工程任务**（`U`），定依赖顺序、迁移脚本、三向覆盖矩阵。

**命令**：
```
/spec-plan
```

**产出**：`docs/engineering/plans/2026-06-09-001-feat-meeting-room-booking-plan.md` + `docs/ops/install/migration-*.sql`。

每个实现单元 `U` 含：**Files**（落到哪些文件）/ **Dependencies**（依赖哪些 U）/ **Patterns**（跟随的现有模式）/ **设计依据**（指回 design 小节，不重抄）/ **原型页面** / **Execution note** / **覆盖需求** / **Test scenarios**（对应哪些 AE）。

**产出长这样**（节选自 [examples](examples/engineering/plans/2026-06-09-001-feat-meeting-room-booking-plan.md)）：

```
### U3 · 后端预约服务（预约/取消/管理员取消）
- Files：service/impl/BookingServiceImpl.java、controller/BookingController.java
- Dependencies：U2
- 设计依据：design「详细设计 · 并发防重订（行锁 + 重叠校验）」。
  并发兜底严格按 design 实现，勿用唯一键或无锁查改替代。
- Execution note：先写并发/边界失败用例（重叠、并发双订、结束≤开始），再实现。
- 覆盖需求：R2、R3、R4、R6、R7、R8
- Test scenarios：AE1（并发同段仅一成功）、AE2、AE3、AE7

## Requirements 映射 + 覆盖矩阵
| 需求 | 实现单元 | 验收 |
| R3 重叠拒绝 | U3 | AE1 |
```

**迁移脚本规约**（`/spec-plan` 会落 `docs/ops/install/migration-*.sql`）：

- **回滚段必填**（UP / DOWN 两段，不能只有建表没有撤回）。
- 业务表带 `create_time` + `update_time` 时间戳。
- `varchar(N)` 的 N **按字符数**定义，与设计 ER 标注的字段长度逐字段一致。
- 生成 SQL 前先确定数据库语义（MySQL `varchar(N)` 按字符 / Oracle `varchar2(N CHAR)` / 达梦…），未记录则会问你。

**完成判据**：每个 `U` 可独立认领；DB 变更落 migration（回滚段+时间戳+字段长度对齐设计）；**三向覆盖矩阵 `R/F → U → AE/AC` 无空格**——每条需求都落到某个 U 且被某条 AE 验证。

---

## 第 6 步 · 体检（`/spec-check`，只读，随时可跑）

> 这是**横切**命令，不产出新文档、不改任何东西，只把同一 `NNN` 的 PRD/原型/设计/计划摆一起，沿可追溯链逐项核对，输出**带定位与修法**的报告。**开发前、评审前、提交前、变更回流后**都建议跑一次。

**命令**（留空则取最近一份 `active` 的）：
```
/spec-check 001
```

**它查什么**（每项判 PASS / WARN / FAIL）：

| 类别 | 检查项（节选） |
| --- | --- |
| 编号 | `R/F`·`AE/AC`·`U` 无重复无重排（重复/重排=FAIL）；取号在 `registry.md` 已登记且未被重复占用 |
| 覆盖 | 每条 `R/F` 都有 `AE/AC` 覆盖、都落到某个 `U`；每条 `AE/AC` 不悬空（指向真实需求号） |
| 一致 | 同一 `NNN` 跨 prd/design/plan/migration 对得上；frontmatter `status`/`origin` 链合理 |
| 数据 | 设计 ER 与 migration 表/字段对得上；回滚段在位；时间戳在位；字段长度一致 |
| 完整 | NFR 节在位；涉及界面的设计有「前端设计」节、高并发有「并发与幂等」节 |
| 跨特性 | 本特性对外暴露/依赖的接口/表，去全 `docs/` 查别的 `NNN` 有没有悬空引用 |

**报告结构**：一行总判定（`✅ 通过` / `⚠️ N 项提示` / `❌ N 项必修`）→ 覆盖矩阵总表（断链行标 `⚠️/❌`）→ 问题清单（每条给「在哪→为什么是问题→怎么修→跑哪个 skill」）。

> spec-check **只报告不修**。需求层问题回 `/spec-prd` 或 `/spec-change`，设计层回 `/spec-design`，实现层回 `/spec-plan`，原型层回 `/spec-prototype`。
>
> 它**不查代码规约**（命名/注释/分层）——那是编码期的事，归 `/code-review`。

---

## 第 7 步 · 开发（`/ce-work`）

按 plan 的 `U` 实现功能，遵循 `constitution.md` 编码基线与项目 `CLAUDE.md`。

**命令**：
```
/ce-work
```

`/ce-work` 会按计划单元推进。写代码时**项目根的 `CLAUDE.md` 自动注入**——命名/注释/分层/前后端规约不用你每次叮嘱。复杂或并行特性可先 `/ce-worktree` 开隔离工作区。

**几条约定**：

- **前端 UI 以原型为准**：对照 `docs/engineering/prototype/` 对应页面用真组件还原，偏离先走 `/spec-change` 改原型再改代码。
- **关键决策按设计走**：plan 里 U3 那种「并发兜底严格按 design 实现，勿自行简化」的约束要遵守。
- 不在默认分支直接开发；改动到需求范围**先回流文档**（`/spec-change`）再写码。

**完成判据**：功能本地可跑；遵循 `constitution.md` 编码基线（安全合规、零魔法值、字段长度全链路一致等）与 `CLAUDE.md`；自测主流程通过。

---

## 第 8 步 · 评审（`/code-review`）

合并前发现正确性 bug、安全/可靠性问题，并做简化清理。

- 本地：`/code-review`（可带 `--fix` 自动改、`--comment` 发 PR 评论）。
- 深度：`/ce-code-review`，或云端 `/code-review ultra <PR#>`。
- 纯质量清理（不找 bug）：`/simplify`。

**完成判据**：高置信问题已修复或记录；鉴权/输入/权限等安全敏感改动专门过一遍；评审意见全部 resolve。

---

## 第 9 步 · 测试（`/verify`）

验证实现**真的满足 PRD 的验收标准**，不只是「编译通过」。

- 拿着 PRD 的 `AE/AC` **逐条手工验证**（这是核心——验收标准在需求阶段就写好了，测试就是逐条打勾）。
- `/verify` 跑应用观察真实行为；前端受影响页面用 `/ce-test-browser`；关键逻辑补单测。

**完成判据**：PRD 全部 `AE/AC` 通过；回归无新增问题；失败项要么修复、要么明确记录为已知限制。

---

## 第 10 步 · 合并（`/ce-commit-push-pr`）

把验证过的改动以清晰历史并入主干。

**命令**：
```
/ce-commit-push-pr
```

提交+推送+开 PR；也可只 `/ce-commit` 写提交信息。合入主干前 squash 成干净可回滚的提交。

**收尾两件事**：

1. plan 的 frontmatter `status: active` → `done`。
2. `docs/engineering/registry.md` 里本特性那行 `reserved` → `done`。

**完成判据**：CI 绿；评审通过；PR 描述说清「做了什么、为什么、怎么验证」；plan/registry 状态已更新。

---

## 第 11 步 · 需求变更怎么回流（`/spec-change`）

> 特性已经有 PRD（甚至已上线）后，客户/内部又要改——**永远不要直接改代码或单独改某一份文档**。用 `/spec-change` 按「先文档后代码」的铁律把改动**同步回流** PRD → 原型 → 设计 → plan，最后才改代码。

**命令**：
```
/spec-change 会议室预约要加「预约成功发站内信通知」
```

**它怎么做**：

- **复用原 `NNN`**（不取新号），续编 `R/F` 与 `AE/AC`（接着往后排，**不重排**）。
- 按波及面**回流到每一份受影响的产出物**：PRD 加需求/验收 → 原型加页面 → 设计加接口/流程 → plan 加实现单元。
- 跨特性影响扫描：改动若动了别人引用的接口/表，会提示受影响的其他 `NNN`。
- 文档都同步好了，再进入开发。

**回流后**：跑 `/spec-check 001` 确认覆盖矩阵仍闭合，再继续开发→评审→测试→合并。

> 判断用哪个命令：**全新特性**（取新号）→ `/spec-prd`；**已有特性的改动**（复用原号）→ `/spec-change`。

---

## 多人协作要点（速记）

| 场景 | 怎么办 |
| --- | --- |
| 取**特性号 `NNN`** | 先登记后开工：在 main 上往 `registry.md` 追一行 `reserved` 并 push，再开分支（第 1 步） |
| 同一特性多人并发改、续编 `R/F`·`AE/AC`·`U` 子编号 | 续编前先 `git pull --rebase` 到最新，从真实最大号往后接，绝不重排 |
| 万一还是撞了号 | `/spec-check` 的 C1（编号重复=FAIL）在合并/评审前兜底拦住 |
| 改了别人引用的接口/表 | `/spec-change` 的波及面扫描 + `/spec-check` 的 C16 跨特性引用检查 |
| 号取错了/放弃 | 改 `abandoned`，**不回收号**（回收会打断引用） |

---

## 附录 A · 命令速查表

| 阶段 | 命令 | 干什么 | 产出落点 |
| --- | --- | --- | --- |
| 准备 | `install.ps1`/`.sh` | 装 6 个 skill 到用户级 | `~/.claude/skills/` |
| 准备 | `init-project.ps1`/`.sh` | 初始化项目骨架（宪法/流程/规约/登记表） | `docs/`、`CLAUDE.md` |
| ① 需求 | `/spec-prd` | 原始需求 → 规范化 PRD（R/F + AE/AC + 覆盖矩阵） | `docs/product/prd/` |
| ② 原型 | `/spec-prototype` | PRD → 可点击静态原型（按需） | `docs/engineering/prototype/` |
| ③ 设计 | `/spec-design` | PRD+原型 → 概要+ER+详细设计 | `docs/engineering/design/` |
| ④ 计划 | `/spec-plan` | 设计 → 任务 U + migration + 三向矩阵 | `docs/engineering/plans/`、`docs/ops/install/` |
| 横切 | `/spec-check` | 同一 NNN 一致性体检（只读，不改） | 只出报告 |
| 横切 | `/spec-change` | 需求变更回流（复用 NNN，先文档后代码） | 沿原 NNN 改各产出物 |
| ⑤ 开发 | `/ce-work`（`/ce-worktree`） | 按 plan 实现 | 代码仓 |
| ⑥ 评审 | `/code-review`（`/ce-code-review`、`/simplify`） | 挑 bug + 清理 | PR |
| ⑦ 测试 | `/verify`（`/ce-test-browser`） | 按 AE/AC 逐条验 | PR / 代码仓 |
| ⑧ 合并 | `/ce-commit-push-pr`（`/ce-commit`） | 提交+推送+开 PR | git |

> 规律：**产物是「独有格式的文档」→ 用 `spec-*`；产物是代码/PR/评审 → 用 `ce-*`。**

---

## 附录 B · 常见问题

**Q：纯后端小改，要走完四份文档吗？**
不用。**右尺寸**原则：简单清晰的需求 `/spec-prd` 少追问直接定稿，纯后端可**跳过原型**；设计的详细设计只写 AI 推不出/推错代价高的决策，CRUD 直接声明「留给 ce-work」。该详则详，该略则略，不为流程而流程。

**Q：`/spec-prd` 和 `/spec-change` 怎么选？**
全新特性、要取新号 → `/spec-prd`；已有特性（已有 PRD/已上线）的增量改动、复用原号 → `/spec-change`。

**Q：设计为什么不拆成「概要/详细」多份文档？**
概要↔ER↔详细是逻辑依赖，拆开也省不了改动、反而易漂移。压低「白写」风险的是顺序（先锁概要+ER 再写详细）和右尺寸，已固化进 skill。

**Q：`/spec-check` 会帮我改文档吗？**
不会，它**只读**。只报告问题 + 指出该跑哪个 skill 修。

**Q：命名/注释/分层这些代码规约谁来管？**
编码期的事，由 `/code-review` 对照 `constitution.md` 工程基线与项目 `CLAUDE.md` 把关，**不在 `spec-check` 范围**。把 `CLAUDE.md` 的技术栈占位符填准，`/ce-work` 生成时就遵循。

**Q：装了 skill 但 `/spec-` 出不来？**
重启 Claude Code。仍不行检查 `~/.claude/skills/` 下是否有 `spec-prd` 等目录（用户级），或目标仓库 `.claude/skills/` 下（项目级）。

**Q：想先看产出长什么样？**
翻 [`examples/`](examples/)——会议室预约特性走完 PRD→设计→计划→迁移的**完整真实产物**，含阅读导引。

---

## 附录 C · 产物落点速查

```
docs/
├── product/prd/                  ① PRD 定稿        ← /spec-prd
├── engineering/
│   ├── registry.md               NNN 取号登记表     ← 手动追加（第 1 步）
│   ├── prototype/                 ② 可点击原型       ← /spec-prototype
│   ├── design/                    ③ 技术设计         ← /spec-design
│   └── plans/                     ④ 实现计划         ← /spec-plan
└── ops/install/                   ④ migration SQL    ← /spec-plan
CLAUDE.md                          编码规约（自动加载）← init-project
```

文档统一命名 `YYYY-MM-DD-NNN-<type>-<slug>.md`；同一特性用同一 `NNN` 串起来，`origin` 链 plan → design → prd 逐级回指。

---

> **一句话**：需求写清楚（PRD 带编号验收）→ 界面先画（原型）→ 系统怎么搭（设计）→ 任务拆明白（计划）→ 照着实现（开发）→ 合并前挑刺（评审）→ 拿验收标准逐条验（测试）→ 历史干净地并入（PR）。**每一步的产出物就是下一步的入场券，全程单一事实源、可双向追溯。**
