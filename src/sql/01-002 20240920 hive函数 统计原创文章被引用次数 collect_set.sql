
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :
id表示文章id, oid表示引用的文章id。

当oid为0时表示当前文章为原创文章

求原创文章被引用的次数。

注意本题不能用关联的形式求解

-- * input :
-- id      oid
-- 1       0
-- 2       0
-- 3       1
-- 4       1
-- 5       2
-- 6       0
-- 7       3

-- * target: 
-- id cnt
-- 1 2
-- 2 1
-- 6 0

-- * ==============================================================

-- * ==============================================================

-- * create base table
with base as(
    select 1 as id, 0 as oid union all 
    select 2 as id, 0 as oid union all 
    select 3 as id, 1 as oid union all 
    select 4 as id, 1 as oid union all 
    select 5 as id, 2 as oid union all 
    select 6 as id, 0 as oid union all 
    select 7 as id, 3 as oid
)
select * from base;

-- * ==============================================================

-- * ==============================================================

-- * solution 1: desc
with base as (
    select 1 as id, 0 as oid union all 
    select 2 as id, 0 as oid union all 
    select 3 as id, 1 as oid union all 
    select 4 as id, 1 as oid union all 
    select 5 as id, 2 as oid union all 
    select 6 as id, 0 as oid union all 
    select 7 as id, 3 as oid
)
select
    id, 
    count(1)
from (
    select 
        -- 补充原创文章 id
            -- 如果确实引用了原创文章，则 oid 作为原创文章 id 传入。
            -- 如果不是原创文章，则 id 直接传入
        if(array_contains(contains, oid), oid, if(oid = 0, id, null)) as id,
        -- 判断 被引用的id 是否在原创文章id的list中
        if(array_contains(contains, oid), 1, 0) as flg
    from (
        select
            id,
            oid,
            -- 返回原创文章id的list
            collect_set(if(oid=0,id,null)) over() as contains
        from base
    ) t1
) t2
where t2.id is not null
group by id
order by id
;

-- * key points:
-- * desc  :


-- * output:
-- id      _c1
-- 1       3
-- 2       2
-- 6       1
-- * ==============================================================



-- * ==============================================================

-- * solution 2: desc
-- hive环境执行内存过高被杀了。
    -- Execution failed with exit status: 137
    -- Exit code 137 is a signal that occurs when a container's memory exceeds the memory limit provided in the pod specification. When a container consumes too much memory, Kubernetes kills it to protect it from consuming too many resources on the node.
with base as (
    select 1 as id, 0 as oid union all 
    select 2 as id, 0 as oid union all 
    select 3 as id, 1 as oid union all 
    select 4 as id, 1 as oid union all 
    select 5 as id, 2 as oid union all 
    select 6 as id, 0 as oid union all 
    select 7 as id, 3 as oid
)
select 
    id,
    cnt
from (
    select 
        case when oid = 0 then id else oid end as id, 
        count(case when oid > 0 then 1 end) as cnt
    from base
    group by case when oid = 0 then id else oid end
) t
where id in (select id from base where oid = 0)
;

-- * key points:
-- * desc  :

-- * output:
-- * ==============================================================
