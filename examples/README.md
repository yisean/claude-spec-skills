# 样例：一个特性走完 spec-* 全链路

这里是一份**完整的产出文档样例**，让你在装 skill 前就能看到「跑完每个阶段会生成什么」。
特性是一个自包含的小系统——**会议室预约**（员工查看/预约/取消、管理员维护会议室、防并发双订），刻意选它是因为能压满几乎所有规约。

> 这些是**示例产物**，不是 skill 的一部分；真实项目里它们会落在 `docs/product/`、`docs/engineering/`、`docs/ops/`。这里用 `examples/` 平移演示。

## 文档清单（按流水线顺序）

| 阶段 | 文档 | 由哪个 skill 生成 |
| --- | --- | --- |
| ① 需求 | [`product/prd/2026-06-09-001-meeting-room-booking.md`](product/prd/2026-06-09-001-meeting-room-booking.md) | `/spec-prd` |
| ② 原型 | （HTML 页面，本样例略——`/spec-prototype` 产出 `prototype/*.html`） | `/spec-prototype` |
| ③ 设计 | [`engineering/design/2026-06-09-001-feat-meeting-room-booking-design.md`](engineering/design/2026-06-09-001-feat-meeting-room-booking-design.md) | `/spec-design` |
| ④ 计划 | [`engineering/plans/2026-06-09-001-feat-meeting-room-booking-plan.md`](engineering/plans/2026-06-09-001-feat-meeting-room-booking-plan.md) | `/spec-plan` |
| ④ 迁移 | [`ops/install/migration-2026-meeting-room-booking.sql`](ops/install/migration-2026-meeting-room-booking.sql) | `/spec-plan` |

同一特性用同一序号 `001` 串起来；`origin` 链：plan → design → prd。

## 看点（这套样例演示了哪些规约）

**PRD（`/spec-prd`）**
- `R1–R8` 功能需求编号、`AE1–AE7` 验收（每条标注覆盖的 R）、显式**非目标**与**非功能约束**、落盘**覆盖矩阵**。

**设计（`/spec-design`）—— 一份文档含概要 + ER + 详细设计**
- **核心业务流程图**（预约 flowchart）。
- **接口契约表**：鉴权 / 校验 / **新增错误码**（`ERR_OVERLAP` 等）/ 请求-返回示例。
- **前端设计**：页面 + 路由 + **页面间关系** + 每页调哪些接口。
- **权限四级**：菜单 / 按钮 / 接口 / **数据（行级归属）** + 角色矩阵。
- **可观测与审计设计**。
- **数据 ER** + **时间戳规约** + **字段长度规约表**（会议室名 `varchar(20)`、主题 `varchar(30)`——演示「DB 字符数=唯一真值，前后端对齐」）。
- **检查点**：概要 + ER 锁定后才写详细设计。
- **右尺寸详细设计** ⭐：只展开**并发防重订**（行锁 + 区间重叠校验，唯一键挡不住的硬决策）与取消归属；**显式声明** CRUD/列表/表单等「能可靠生成的不写，留给 ce-work」。每段标注**依赖的概要/ER 小节**。

**计划（`/spec-plan`）—— 瘦身、引用设计**
- 单元只留 Files / Dependencies / Patterns / **设计依据（指回 design 小节）** / 原型页面 / Execution note / 覆盖需求 / Test scenarios——**详细设计不重抄**。
- **三向覆盖矩阵** `R → U → AE`。
- DB 迁移段写明**回滚**、时间戳、字段长度。
- 前端单元带 `Execution note: 用 /ce-frontend-design 收尾截图自检`；U3 设计依据特意写「并发兜底严格按 design 实现，勿自行简化」——把关键决策**约束**给 ce-work。

**迁移（`/spec-plan`）**
- `utf8mb4` / `InnoDB` / 列注释 / 幂等 DDL；**UP / DOWN 两段**（回滚段必填）；`varchar(N)` 按字符数定义；占用查询索引。

## 怎么自己跑出这套

1. 在项目里初始化骨架：`init-project.ps1` / `init-project.sh`（见仓库根 README「项目宪法」节）。
2. `/spec-prd` 写需求 → `/spec-prototype` 画原型 → `/spec-design` 出设计 → `/spec-plan` 拆任务。
3. `/spec-check` 体检覆盖矩阵是否闭合。
