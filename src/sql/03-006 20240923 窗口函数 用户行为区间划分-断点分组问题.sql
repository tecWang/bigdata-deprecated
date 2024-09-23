
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :
现需要进行用户行为分析，如何划分用户不同 WiFi 行为区间

满足:
1. 行为类型分为两种：连接 scan 、扫描 conn
2. 行为区间的定义为：相同行为类型，且相邻两次行为的时间差不超过 30 分钟
3. 不同行为区间在满足定义的情况下应取到最长；

自己的理解：
1. 要从下边的记录中挑选出行为区间的开闭记录
2. 要先用窗口函数排序

-- * input :
-- dt      user_id wifi    status
-- 2024-01-01 10:01:00     101     cmcc-Starbucks  scan
-- 2024-01-01 10:03:00     101     cmcc-Starbucks  scan
-- 2024-01-01 10:04:00     101     cmcc-Starbucks  conn
-- 2024-01-01 10:05:00     101     cmcc-Starbucks  conn
-- 2024-01-01 10:02:00     101     cmcc-Starbucks  scan
-- 2024-01-01 10:06:00     101     cmcc-Starbucks  conn
-- 2024-01-01 11:01:00     101     cmcc-Starbucks  conn
-- 2024-01-01 11:02:00     101     cmcc-Starbucks  conn
-- 2024-01-01 11:03:00     101     cmcc-Starbucks  conn

-- * target: 
-- user_id wifi    status  start_dt        end_dt
-- 101     cmcc-Starbucks  scan    2024-01-01 10:01:00     2024-01-01 10:03:00
-- 101     cmcc-Starbucks  conn    2024-01-01 10:04:00     2024-01-01 10:06:00
-- 101     cmcc-Starbucks  conn    2024-01-01 11:01:00     2024-01-01 11:03:00
-- * ==============================================================

-- * ==============================================================

-- * create base table
-- 字段：时间，用户，WiFi，状态 扫描、连接    
create table base (
    -- dt datetime,    -- ticException [Error 10099]: DATETIME type isn't supported yet. Please use DATE or TIMESTAMP instead
    -- dt date,        -- 如果改成 date 的话，插入之后只能保留日期了 
    dt timestamp,
    user_id string, 
    wifi string, 
    status string
);

insert into base values('2024-01-01 10:01:00', '101', 'cmcc-Starbucks', 'scan'),
('2024-01-01 10:03:00', '101', 'cmcc-Starbucks', 'scan'),
('2024-01-01 10:04:00', '101', 'cmcc-Starbucks', 'conn'),
('2024-01-01 10:05:00', '101', 'cmcc-Starbucks', 'conn'),
('2024-01-01 10:02:00', '101', 'cmcc-Starbucks', 'scan'),
('2024-01-01 10:06:00', '101', 'cmcc-Starbucks', 'conn'),
('2024-01-01 11:01:00', '101', 'cmcc-Starbucks', 'conn'),
('2024-01-01 11:02:00', '101', 'cmcc-Starbucks', 'conn'),
('2024-01-01 11:03:00', '101', 'cmcc-Starbucks', 'conn');

-- * ==============================================================

-- * ==============================================================

-- * solution 1: desc
select
    user_id,
    wifi,
    status,
    min(dt) as start_dt,
    max(dt) as end_dt    
from (
    select 
        user_id,
        wifi,
        dt,
        status,
        lag_dt,
        lag_status,
        sum(
            if(lag_dt is null               -- 没有上一次的日期，说明是客户的第一条记录
                or lag_status is null       -- 没有上一次的状态，说明是客户的第一条记录
                or status <> lag_status     -- 状态变化，说明不是同一区间了
                or unix_timestamp(dt) - unix_timestamp(lag_dt) > 30*60      -- 如果时间间隔大于30分钟
            , 1, 0)
        ) over(order by dt) as grp_flg
    from (
        select 
            user_id,
            wifi,
            dt,
            status,
            lag(dt, 1) over(partition by user_id, wifi order by dt) as lag_dt,
            lag(status, 1) over(partition by user_id, wifi order by dt) as lag_status
        from base
    ) t1
) t2
group by user_id, wifi, status, grp_flg
order by user_id, wifi, start_dt
;

-- * key points:
-- * desc  :

-- * output:
-- user_id wifi    status  start_dt        end_dt
-- 101     cmcc-Starbucks  scan    2024-01-01 10:01:00     2024-01-01 10:03:00
-- 101     cmcc-Starbucks  conn    2024-01-01 10:04:00     2024-01-01 10:06:00
-- 101     cmcc-Starbucks  conn    2024-01-01 11:01:00     2024-01-01 11:03:00
-- * ==============================================================

