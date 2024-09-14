
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :
对于goods_type列, 假设26代表是广告, 获取每个用户每次搜索下非广告类型的商品位置自然排序.

-- * input :
-- base.txt
user_id,goods_name,goods_type,rk
1,hadoop,10,1
1,hive,12,2
1,sqoop,26,3
1,hbase,10,4
1,spark,13,5
1,flink,26,6
1,kafka,14,7
1,oozie,10,8

-- * target: 
-- todo: data demo

-- * ==============================================================

-- * ==============================================================

-- * create base table
create table base (
    user_id int,
    goods_name string,
    goods_type int,
    rk int
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;     -- 不加这一行导入时，所有的数据都被读取为null

-- 导入数据
-- 导入数据时，需要指定数据库名，否则导入时可能会导致元数据库崩溃，需重新初始化 derby 元数据库。
load data local inpath "/usr/local/base.txt" into table test.base;

-- 导入时，多导入了一行表头行，但是 hive 不支持 删除操作，需要创建新表存储。
-- create table test.base2 as select * from base where user_id is not NULL;

-- * ==============================================================

-- * ==============================================================

-- * solution n: desc

select
    user_id,
    goods_name,
    goods_type,
    rk,
    row_number() over(partition by user_id order by rk) as natural_rk
from base
where goods_type <> 26
union all
select 
    user_id,
    goods_name,
    goods_type,
    rk,
    null as natural_rk
from base
where goods_type = 26
order by rk
;

-- * key points: row_number 与 case when 的执行顺序
-- * desc  : row_number 对应下边执行计划的 window 窗口函数，case when 对应下边的 project 映射。可见，窗口函数是早于 case when执行的。

select 
    user_id,
    goods_name,
    goods_type,
    rk,
    case when goods_type <> 26 then row_number() over(partition by user_id order by rk) else NULL end as natural_rk
from base
;

-- 可以看到顺序没有变化，只是 26 的地方被置为 null 了，不满足需求。
-- 1       hadoop  10      1       1
-- 1       hive    12      2       2
-- 1       sqoop   26      3       NULL
-- 1       hbase   10      4       4
-- 1       spark   13      5       5
-- 1       flink   26      6       NULL
-- 1       kafka   14      7       7
-- 1       oozie   10      8       8

-- hive的执行计划太长了，贴一个spark的物理执行计划
-- == Physical Plan 
-- ==*Project [user_id#67, goods_name#68, goods_type#69, rk#70, CASE WHEN NOT (goods_type#69 = 26) THEN _we0#72 ELSE null END AS naturl_rank#64]
-- +- Window [row_number() windowspecdefinition(user_id#67, rk#70 ASC NULLS FIRST, ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS _we0#72], [user_id#67], [rk#70 ASC NULLS FIRST]   
--     +- *Sort [user_id#67 ASC NULLS FIRST, rk#70 ASC NULLS FIRST], false, 0      
--         +- Exchange hashpartitioning(user_id#67, 200)         
--             +- HiveTableScan [user_id#67, goods_name#68, goods_type#69, rk#70], MetastoreRelation default, window_goods_test
-- Time taken: 0.238 seconds, Fetched 1 row(s)

-- * output:
-- 1       hadoop  10      1       1
-- 1       hive    12      2       2
-- 1       sqoop   26      3       NULL
-- 1       hbase   10      4       3
-- 1       spark   13      5       4
-- 1       flink   26      6       NULL
-- 1       kafka   14      7       5
-- 1       oozie   10      8       6
-- * ==============================================================

