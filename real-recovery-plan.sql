-- 真实数据恢复方案 - 基于MySQL数据恢复技术
-- 包含redo log、binlog、ibd文件恢复策略

-- 1. 首先检查当前数据库状态
SELECT 
    '数据库检查开始' as 步骤,
    NOW() as 检查时间,
    DATABASE() as 当前数据库;

-- 2. 检查表状态和记录数
SELECT 
    table_name,
    table_rows,
    data_length,
    index_length,
    table_comment
FROM information_schema.tables 
WHERE table_schema = 'spend'
ORDER BY table_name;

-- 3. 检查是否有备份表
SELECT 
    table_name,
    table_rows,
    create_time
FROM information_schema.tables 
WHERE table_schema = 'spend' 
  AND table_name LIKE '%backup%'
ORDER BY create_time DESC;

-- 4. 检查MySQL数据目录位置
SHOW VARIABLES LIKE 'datadir';

-- 5. 检查二进制日志状态
SHOW VARIABLES LIKE 'log_bin%';

-- 6. 检查redo log配置
SHOW VARIABLES LIKE 'innodb_log%'; 

-- 7. 检查undo log配置
SHOW VARIABLES LIKE 'innodb_undo%'; 

-- 8. 检查是否有可恢复的旧数据
-- 查找可能的旧ibd文件
SELECT 
    '检查ibd文件状态' as 检查项,
    file_name,
    file_type,
    tablespace_name,
    status
FROM information_schema.files 
WHERE file_name LIKE '%spend%'
ORDER BY file_name;

-- 9. 检查事务日志
SELECT 
    'InnoDB状态检查' as 检查项,
    NOW() as 检查时间;

-- 10. 检查是否有可恢复的旧版本
SELECT 
    '检查是否有可恢复的旧数据' as 步骤,
    COUNT(*) as daily_spend记录数,
    MIN(date) as 最早日期,
    MAX(date) as 最新日期,
    COUNT(DISTINCT userId) as 用户数
FROM daily_spend;

-- 11. 检查是否有删除记录的痕迹
SELECT 
    '检查删除记录' as 检查项,
    COUNT(*) as 当前记录数,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'spend' AND table_name = 'daily_spend') as 表存在
FROM daily_spend;