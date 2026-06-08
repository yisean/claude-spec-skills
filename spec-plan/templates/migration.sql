-- migration-<YYYY>-<特性名>.sql
-- 落点：docs/ops/install/migration-<YYYY>-<特性名>.sql
-- 对应设计文档（docs/engineering/design/…-NNN-*）的「数据 ER 模型」，与之逐字段一致。
-- 安全性：<能否重复执行幂等 / 加字段是否阻塞大表 / 索引是否在线创建>
-- 回滚：<对应的 down 操作或回滚说明>

-- 示例：新增预约名额表（与 ER 的 EXAM_BOOKING 对应）
CREATE TABLE IF NOT EXISTS exam_booking (
  id         BIGINT       PRIMARY KEY AUTO_INCREMENT,
  slot_id    BIGINT       NOT NULL,
  depart_id  BIGINT       NOT NULL,
  booker     VARCHAR(64),
  booked_at  DATETIME     NOT NULL,
  UNIQUE KEY uk_slot_depart (slot_id, depart_id)   -- 防同部门重复占名额
);

-- 示例：给已有表加字段
-- ALTER TABLE exam_time_slot ADD COLUMN open_type INT NOT NULL DEFAULT 0;
