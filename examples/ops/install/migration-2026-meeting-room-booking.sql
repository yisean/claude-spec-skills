-- migration-2026-meeting-room-booking.sql
-- 落点：docs/ops/install/migration-2026-meeting-room-booking.sql
-- 对应设计文档（examples/engineering/design/2026-06-09-001-...-design.md）的「数据 ER 模型」，逐字段一致。
-- 安全性：CREATE TABLE IF NOT EXISTS 幂等可重跑；新增表不影响存量。
-- 字段长度规约：varchar(N) 的 N=字符数（utf8mb4 下 N 个汉字），按业务最大汉字数定义，
--             与设计标注、后端校验、前端 maxlength 一致。

-- ========== UP（正向） ==========

CREATE TABLE IF NOT EXISTS meeting_room (
  id           VARCHAR(64)  NOT NULL COMMENT '会议室ID',
  name         VARCHAR(20)  NOT NULL COMMENT '会议室名称，最多 20 字符',
  capacity     INT          NOT NULL DEFAULT 0 COMMENT '容量（人）',
  location     VARCHAR(50)  NULL     COMMENT '位置，最多 50 字符',
  status       INT          NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
  create_time  DATETIME     NOT NULL COMMENT '创建时间',
  update_time  DATETIME     NULL     COMMENT '更新时间',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会议室';

CREATE TABLE IF NOT EXISTS room_booking (
  id           VARCHAR(64)  NOT NULL COMMENT '预约ID',
  room_id      VARCHAR(64)  NOT NULL COMMENT '会议室ID',
  booker_id    VARCHAR(64)  NOT NULL COMMENT '预约人ID（取自登录态）',
  title        VARCHAR(30)  NOT NULL COMMENT '会议主题，最多 30 字符',
  start_time   DATETIME     NOT NULL COMMENT '开始时间',
  end_time     DATETIME     NOT NULL COMMENT '结束时间',
  create_time  DATETIME     NOT NULL COMMENT '预约时间',
  update_time  DATETIME     NULL     COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_room_time (room_id, start_time, end_time)   -- 占用查询 + 重叠校验走索引
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会议室预约';

-- ========== DOWN（回滚） ==========
-- up 建了两张表，down 逆序删（先删子表 room_booking 再删 meeting_room）。
-- 注意：DROP 连数据一起删，生产回滚前先备份这两张表。
DROP TABLE IF EXISTS room_booking;
DROP TABLE IF EXISTS meeting_room;
