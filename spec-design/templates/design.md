---
title: <特性名> · 技术设计
type: feat            # feat / fix / refactor
status: active
date: <YYYY-MM-DD，如 2026-06-04>
origin: <对应 PRD 路径，如 docs/product/prd/2026-06-04-NNN-xxx.md>
---

# <NNN> <特性名> · Design

## Summary
〔一段话：整体技术方案是什么〕

## Problem Frame
〔要解决的问题与约束，承接 PRD 的目标/非目标〕

## 概要设计
- **架构与模块**：〔后端模块 / 前端页面 / 外部依赖，及它们的协作关系〕
- **技术选型与关键决策**：〔选了什么、为什么、放弃的备选（可追溯）〕
- **接口清单**：〔path / 方法 / 入参出参概述，对应覆盖的 R/F〕
- **非功能约束承接**：〔PRD 的每条 NFR → 对应的设计手段或校验点〕
- **风险与回滚**：〔高风险点、并发/权限/性能注意项〕

## 数据 ER 模型
```mermaid
erDiagram
    EXAM ||--o{ EXAM_TIME_SLOT : has
    EXAM_TIME_SLOT ||--o{ EXAM_BOOKING : booked_by
    DEPART ||--o{ EXAM_BOOKING : makes
    EXAM_TIME_SLOT {
        bigint id PK
        bigint exam_id FK
        datetime start_time
        datetime end_time
        int open_type
    }
    EXAM_BOOKING {
        bigint id PK
        bigint slot_id FK
        bigint depart_id FK
        string booker
        datetime create_time
        datetime update_time
    }
```
> ER 是逻辑视图，是 `/spec-plan` 物理 migration（建表脚本）的唯一逻辑来源，二者逐字段一致。
>
> **时间戳规约**：业务实体默认带创建/更新时间戳两列（命名沿用项目惯例，如 `create_time`/`update_time`）；纯字典/只读/中间表可豁免，但要注明原因（如 `EXAM_SLOT_DEPART：纯关联表，无需时间戳`）。

## 详细设计
〔按模块 / 接口 / 关键流程组织，不按实现单元——拆单元在 /spec-plan，那里反向引用本节〕

### <模块/接口名>（覆盖 R8、R9）
- **接口签名**：〔入参出参类型、错误码/异常约定〕
- **核心逻辑**：〔关键算法 / 判定规则 / 状态机〕
- **必要时序**：〔复杂交互的调用顺序与边界条件，如资格判定、并发占名额、回滚补偿〕

### <模块/接口名>（覆盖 R10）
…
