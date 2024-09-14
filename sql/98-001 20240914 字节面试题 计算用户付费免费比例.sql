
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :

-- * input :
-- hive> select * from dm_paid_buy;
-- OK
-- time    server_id role_id cost item_id amount   p_date
-- 1234567 120     10098   2       3       4       2021-01-01
-- 1234567 120     10098   4       3       5       2021-01-01
-- 1234567 123     10098   3       3       2       2021-01-02
-- 1234567 123     10098   2       3       2       2021-01-02
-- Time taken: 1.603 seconds, Fetched: 4 row(s)
-- hive> select * from dm_free_buy;
-- OK
-- 1234567 123     10098   8       3       4       2021-01-01
-- 1234567 123     10098   5       3       5       2021-01-01
-- 1234567 120     10098   6       3       4       2021-01-01
-- 1234567 120     10098   9       3       5       2021-01-01
-- 1234567 123     10098   18      3       2       2021-01-02
-- 1234567 123     10098   7       3       2       2021-01-02

-- * target: 
-- todo: data demo

-- * ==============================================================

-- * ==============================================================

-- * create base table
create table if not exists dm_paid_buy(   
    `time`    bigint comment '#购买的时间戳',
    server_id string comment '#服务器ID',
    role_id   int comment '#角色ID',
    cost      int comment '#购买对应道具消耗的付费元宝数量',
    item_id   int comment '#购买对应道具的id',
    amount    int comment '#购买对应道具的数量',
    p_date    string comment '#登录日期,yyyy-MM-dd'
) 
comment '角色使用付费元宝购买商城道具时候记录一条';
    
insert overwrite table dm_paid_buy values(1234567,120,10098,2,3,4,'2021-01-01'),
    (1234567,120,10098,4,3,5,'2021-01-01'),
    (1234567,123,10098,3,3,2,'2021-01-02'),
    (1234567,123,10098,2,3,2,'2021-01-02'); 

create table if not exists dm_free_buy(    
    `time`    bigint comment '#购买的时间戳',
    server_id string comment '#服务器ID',
    role_id   int comment '#角色ID',
    cost      int comment '#购买对应道具消耗的免费元宝数量',
    item_id   int comment '#购买对应道具的id',
    amount    int comment '#购买对应道具的数量',
    p_date    string comment '#登录日期, yyyy-MM-dd'
) 
comment '角色使用免费元宝购买商城道具时候记录一条';

insert overwrite table dm_free_buy values(1234567,123,10098,8,3,4,'2021-01-01'),
    (1234567,123,10098,5,3,5,'2021-01-01'),
    (1234567,120,10098,6,3,4,'2021-01-01'),
    (1234567,120,10098,9,3,5,'2021-01-01'),
    (1234567,123,10098,18,3,2,'2021-01-02'),
    (1234567,123,10098,7,3,2,'2021-01-02');

-- * ==============================================================

-- * ==============================================================

-- * solution 1: desc
select
    p_date,
    role_id,
    server_id,
    sum(case when c_type = 'cost' then cost else 0.0 end) / sum(case when c_type = 'free' then cost else 0.0 end) as per,
    sum(case when c_type = 'cost' then cost else 0.0 end) as sum_cost,
    sum(case when c_type = 'free' then cost else 0.0 end) as free_cost
from (
    select
        p_date,
        server_id,
        role_id,
        'cost' as c_type,
        cost
    from dm_paid_buy
    union all
    select 
        p_date,
        server_id,
        role_id,
        'free' as c_type,
        cost
    from dm_free_buy
) t1
group by p_date, role_id, server_id;

-- * key points:
-- * desc  :

-- * output:
-- p_date          server_id role_id per                  cost      free
-- 2021-01-01      10098   120     0.400000000000000000    6       15
-- 2021-01-01      10098   123     0.000000000000000000    0       13
-- 2021-01-02      10098   123     0.200000000000000000    5       25
-- * ==============================================================

-- * ==============================================================

-- * solution 2: desc
select 
    nvl(t1.p_date, t2.p_date) as p_date,
    nvl(t1.server_id, t2.server_id) as server_id,
    nvl(t1.role_id, t2.role_id) as role_id,
    round(nvl(t1.cost, 0) / t2.cost, 3) as per
from (
    select p_date, server_id, role_id, sum(Cost) as cost
    from dm_paid_buy t1
    where p_date between '2021-01-01' and '2021-01-07'
    group by p_date, server_id, role_id
) t1
full join (
    select p_date, server_id, role_id, sum(cost) as cost
    from dm_free_buy
    where p_date between '2021-01-01' and '2021-01-07'
    group by p_date, server_id, role_id
) t2
    on t1.p_date = t2.p_date
        and t1.server_id = t2.server_id
        and t1.role_id = t2.role_id


-- * key points:
-- * desc  :

-- * output:
-- 2021-01-01      120     10098   0.4
-- 2021-01-01      123     10098   0.0
-- 2021-01-02      123     10098   0.2
-- * ==============================================================




