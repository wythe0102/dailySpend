-- 快速检查数据库状态
USE spend;

-- 检查各表数据量
SELECT 'daily_spend' as table_name, COUNT(*) as record_count FROM daily_spend
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'type', COUNT(*) FROM type
UNION ALL
SELECT 'daily_weight', COUNT(*) FROM daily_weight
UNION ALL
SELECT 'budget', COUNT(*) FROM budget;

-- 检查daily_spend表的最后几条记录
SELECT spendDetailId, amount, date, demo 
FROM daily_spend 
ORDER BY spendDetailId DESC 
LIMIT 10;