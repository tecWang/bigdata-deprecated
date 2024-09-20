
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :
表中有2个字段 student_id 和 name。student_id 是该表的主键（唯一值）列, name 表示学生姓名。

编写解决方案：
1. 交换每两个连续的学生的座位号。
2. 如果学生的数量是奇数， 则最后一个学生的student_id不交换。
3. 按 student_id 升序 返回结果表。

-- * input :
-- student_id      name
-- 1       b
-- 2       c
-- 3       d
-- 4       e
-- 5       f

-- * target: 
-- student_id      name
-- 1       c
-- 2       b
-- 3       e
-- 4       d
-- 5       f

-- * ==============================================================

-- * ==============================================================

-- * create base table
create table base as  
select 1 as student_id,'b' as name union all
select 2,'c' union all
select 3,'d' union all
select 4,'e' union all         
select 5,'f'
;

-- * ==============================================================

-- * ==============================================================

-- * solution 1: desc
select
    student_id,
    case 
        -- 偶数，取上一个id的name
        when student_id % 2 = 0 then prev_name
        when student_id % 2 <> 0 and student_id <> last_student_id then next_name
        when student_id % 2 <> 0 and student_id = last_student_id then name
    end as new_name
from (
    select 
        student_id,
        name,
        lag(name, 1) over(order by student_id) as prev_name,
        lead(name, 1) over(order by student_id) as next_name,
        max(student_id) over() as last_student_id
    from base
) t1
order by student_id
;

-- * key points:
-- * desc  :

-- * output:
-- 1       c
-- 2       b
-- 3       e
-- 4       d
-- 5       f
-- * ==============================================================

