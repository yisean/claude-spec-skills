---
title: 会议室预约 · 实现计划
type: feat
status: active
date: 2026-06-09
origin: examples/engineering/design/2026-06-09-001-feat-meeting-room-booking-design.md
---

# Plan 001 · 会议室预约

## Summary

新增会议室与预约能力：员工查看/预约/取消，管理员维护会议室与取消任意预约。覆盖 PRD 001 的 R1–R8 / AE1–AE7。

## Problem Frame

会议室口头协调导致撞车。承接设计：撞车=时间段重叠，靠事务 + 行锁防并发双订。

## 设计依据

架构、核心流程、接口契约、前端设计、权限四级、数据 ER、详细设计（并发防重订 / 取消归属）见
[`examples/engineering/design/2026-06-09-001-feat-meeting-room-booking-design.md`](../design/2026-06-09-001-feat-meeting-room-booking-design.md)。本计划只做任务拆分与追溯；各单元「设计依据」指回 design 小节，不重抄。

## DB 迁移

落点 [`examples/ops/install/migration-2026-meeting-room-booking.sql`](../../ops/install/migration-2026-meeting-room-booking.sql)：建 `meeting_room`、`room_booking` 两表，与设计 ER 逐字段一致。

- **回滚**：`DROP TABLE room_booking; DROP TABLE meeting_room;`（DROP 连数据一起删，生产回滚前先备份）。脚本含 UP/DOWN 两段。
- **时间戳**：两表均带 `create_time` + `update_time`。
- **字段长度**：`name varchar(20)` / `location varchar(50)` / `title varchar(30)`，按设计标注的字符数，前后端校验对齐。

## Requirements 映射 + 覆盖矩阵

| 需求 | 实现单元 | 验收 |
| --- | --- | --- |
| R1 查看会议室/占用 | U1、U2、U5 | AE4 |
| R2 预约时段 | U3、U5 | AE1、AE2 |
| R3 重叠拒绝 | U3 | AE1 |
| R4 取消（本人，开始前） | U3、U5 | AE3 |
| R5 维护会议室 | U2、U4 | AE4、AE6 |
| R6 记录预约人/时间 | U3 | AE1（间接） |
| R7 停用 | U2、U3 | AE5 |
| R8 管理员取消 | U3、U4 | AE7 |

> 每条 R 至少落到一个 U 且被一条 AE 验证，无空格。

## Implementation Units

### U1 · 数据库迁移
- **Files**：`examples/ops/install/migration-2026-meeting-room-booking.sql`。
- **Dependencies**：无。
- **Patterns to follow**：项目既有建表脚本风格（utf8mb4/InnoDB、列注释、幂等 DDL）。
- **设计依据**：design「数据 ER 模型」。
- **Execution note**：DDL，无行为逻辑；含 down 段。
- **覆盖需求**：R1–R8 的存储基础。
- **Test scenarios**：脚本可执行，两表 + 索引创建成功。

### U2 · 后端会议室实体/服务（CRUD + 停用）
- **Files**：`modules/meeting/entity/{MeetingRoom,RoomBooking}.java`、`mapper/*`、`dto/*`、`service/impl/RoomServiceImpl.java`、`controller/RoomController.java`（`@RequiresRoles("admin")`）。
- **Dependencies**：U1。
- **Patterns to follow**：项目现有 entity/mapper/service/controller 分层与 `BaseController` 返回。
- **设计依据**：design「接口契约 · room/list、room/save、room/disable」。CRUD 为标准实现，设计未细写。
- **Execution note**：test-first（名称长度校验、停用）。
- **覆盖需求**：R1、R5、R7。
- **Test scenarios**：AE4（新增即可见可约）、AE6（名称>20 字符被拒）、AE5（停用后不可约、历史保留）。

### U3 · 后端预约服务（预约/取消/管理员取消）
- **Files**：`service/impl/BookingServiceImpl.java`、`controller/BookingController.java`。
- **Dependencies**：U2。
- **Patterns to follow**：项目 `ServiceImpl` 事务写法；Shiro 主体取当前用户。
- **设计依据**：design「详细设计 · 并发防重订（行锁 + 重叠校验）」「取消与归属」「接口契约 · booking/*」。**并发兜底严格按 design 的行锁 + 重叠 SQL 实现，勿用唯一键或无锁查改替代。**
- **Execution note**：先写并发/边界失败用例（重叠、并发双订、结束≤开始、取消非本人/已开始），再实现。
- **覆盖需求**：R2、R3、R4、R6、R7、R8。
- **Test scenarios**：AE1（并发同段仅一成功）、AE2（结束≤开始被拒）、AE3（取消后可再约）、AE7（管理员取消、含已开始）。

### U4 · 前端：会议室管理页
- **Files**：`views/room/index.vue`、`api/room.js`（save/disable）。
- **Dependencies**：U2；原型 `prototype/room-admin.html`。
- **Patterns to follow**：项目现有表格 + 表单页。
- **设计依据**：design「前端设计 · /admin/room」「权限四级 · 按钮」。
- **Execution note**：用 `/ce-frontend-design` 方法论实现，收尾前截图自检；名称输入框 `maxlength=20` 对齐 DB。
- **覆盖需求**：R5、R8。
- **Test scenarios**：增/改/停用就地刷新；名称>20 前端拦截（AE6 前端侧）。

### U5 · 前端：员工预约页
- **Files**：`views/booking/index.vue`、`api/booking.js`（roomList/book/cancel）。
- **Dependencies**：U2、U3；原型 `prototype/room-booking.html`。
- **Patterns to follow**：项目现有列表页 + `post()` 封装。
- **设计依据**：design「前端设计 · /booking」「接口契约 · booking/*」。
- **Execution note**：用 `/ce-frontend-design` 方法论实现，收尾前截图自检；标题 `maxlength=30`。
- **覆盖需求**：R1、R2、R4。
- **Test scenarios**：选室看当日占用；预约/取消就地刷新；时段冲突提示已占用（AE1 前端侧）。

## Scope Boundaries

继承 PRD 非目标：周期预约、审批流、通知提醒、跨资源预约——均不做。
