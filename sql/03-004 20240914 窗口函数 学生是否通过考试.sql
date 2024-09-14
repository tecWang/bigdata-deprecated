
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  : 学生在两个学期里共参加了 6 场考试。他通过了其中一场（1 表示“通过”，0 表示“未通过”），因此他第一个学期的学习成绩算是过关了。他在第二个学期（接下来的 3 个月）没有通过任何一场考试，因此 3 场考试的 PASS_FAIL 列都是 0。你希望返回一个结果集表示这个学生某个学期是否通过了考试。
    -- * METREQ（表示是否通过）的值是“+”和“-”，表示学生在一个学期（3 个月）内是否通过了至少一场考试。
    -- * 如果一个学生在一个学期内通过了至少一场考试，则 IN_PROGRESS 值为 0。如果没有通过任何一场考试，那么他参加的最后一场考试对应的 IN_PROGRESS 值应该是 1。

-- * input :
-- * 一个学生在一段时间内会参加若干场考试。假设他每 3 个月会参加 3 场考试。只要他通过了任何一场，将返回一个标志（flag）以表示考试通过。如果 3 场都没有通过，也会返回一个标志以表示考试未通过。
-- s_id    t_id    g_id    p_id    test_date       pass_fail
-- 1       1       2       1       2005-02-01      0
-- 1       2       2       1       2005-03-01      1
-- 1       3       2       1       2005-04-01      0
-- 1       4       2       2       2005-05-01      0
-- 1       5       2       2       2005-06-01      0
-- 1       6       2       2       2005-07-01      0

-- * target: 

-- * ==============================================================

-- * ==============================================================

-- * create base table
create table base as
select 1 student_id,
       1 test_id,
       2 grade_id,
       1 period_id,
       '2005-02-01' test_date,       
       0 pass_fail union all 
       select 1, 2, 2, 1, '2005-03-01', 1 union all 
       select 1, 3, 2, 1, '2005-04-01', 0 union all 
       select 1, 4, 2, 2, '2005-05-01', 0 union all 
       select 1, 5, 2, 2, '2005-06-01', 0 union all 
       select 1, 6, 2, 2, '2005-07-01', 0 
;

-- * ==============================================================

-- * ==============================================================

-- * solution 1: desc
select
    student_id,
    test_date,
    grade_id,
    period_id,
    case when pass_flag = 1 then '+' else '-' end as metreq,
    case 
        when pass_flag = 1 then 0
        when pass_flag = 0 then 
            case when test_date = max_dt then 1 else 0 end 
    end as in_progress
from (
    select 
        student_id,
        test_id,
        test_date,
        grade_id,
        period_id,
        max(pass_fail) over(partition by student_id, grade_id, period_id) as pass_flag,
        max(test_date) over(partition by student_id, grade_id, period_id) as max_dt
    from base
) t1
order by student_id, test_id
;

-- * key points:
-- * desc  :

-- * output:
-- 1       2005-02-01      2       1       +       0
-- 1       2005-03-01      2       1       +       0
-- 1       2005-04-01      2       1       +       0
-- 1       2005-05-01      2       2       -       0
-- 1       2005-06-01      2       2       -       0
-- 1       2005-07-01      2       2       -       1
-- * ==============================================================

