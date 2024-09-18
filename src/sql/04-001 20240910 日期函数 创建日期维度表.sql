
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  : 根据开始、结束日期生成日期维度表

-- * input :
-- 2021-01-01
-- 2021-01-17

-- * target: 
-- 2021-01-01      53      周五    2020-12-28      2021-01-03      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-02      53      周六    2020-12-28      2021-01-03      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-03      53      周日    2020-12-28      2021-01-03      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-04      1       周一    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-05      1       周二    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-06      1       周三    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-07      1       周四    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-08      1       周五    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-09      1       周六    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-10      1       周日    2021-01-04      2021-01-10      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-11      2       周一    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-12      2       周二    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-13      2       周三    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-14      2       周四    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-15      2       周五    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-16      2       周六    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31
-- 2021-01-17      2       周日    2021-01-11      2021-01-17      1       2021-01-01      2021-01-31      1       2021-1-1        2021-03-31 2021     2021-01-01      2021-12-31

-- * ==============================================================

-- * ==============================================================
-- * create base table

drop table if exists dim_date;

create table if not exists dim_date ( 
    `date` string comment '日期',
    d_week string comment '年内第几周',
    weeks string comment '周几',
    w_start string comment '周开始日',
    w_end string comment '周结束日',
    d_month string comment '第几月',
    m_start string comment '月开始日',
    m_end string comment '月结束日',
    d_quarter int comment '第几季',
    q_start string comment '季开始日',
    q_end string comment '季结束日',
    d_year int comment '年份',
    y_start string comment '年开始日',
    y_end string comment '年结束日'
);

-- * ==============================================================

-- * ==============================================================
-- * solution n: desc

select  
    `date`
    ,d_week --年内第几周 
    ,case weekid 
        when 0 then '周日' 
        when 1 then '周一' 
        when 2 then '周二' 
        when 3 then '周三' 
        when 4 then '周四' 
        when 5 then '周五' 
        when 6 then '周六' 
    end as weeks -- 周 
    ,date_sub(next_day(`date`,'MO'),7) as w_start --周一 
    ,date_sub(next_day(`date`,'MO'),1) as w_end -- 周日_end-- 月份日期 
    ,monthid as d_month
    ,m_start
    ,m_end -- 季节 
    ,quarterid as d_quart
    ,concat_ws('-',cast(d_year as string),cast(quarterid * 3 - 2 as string),'1') as q_start --季开始日 
    ,date_sub(concat_ws('-',cast(d_year as string),cast(quarterid * 3 + 1 as string),'1'),1) as q_end --季结束日 
    ,d_year
    ,y_start
    ,y_end
from (
    select  
        `date`
        ,pmod(datediff(`date`,'2012-01-01'),7) as weekid --获取周几 
        ,month(`date`) as monthid--获取月份 
        ,ceil(month(`date`) / 3) as quarterid--获取季节id 
        ,year(`date`) as d_year-- 获取年份 
        ,trunc(`date`,'yyyy') as y_start--年开始日 
        ,date_sub(trunc(add_months(`date`,12),'yyyy'),1) as y_end --年结束日 
        ,trunc(`date`,'mm') as m_start --当月第一天 
        ,last_day(`date`) as m_end--当月最后一天 
        ,weekofyear(`date`) as d_week--年内第几周
    from ( 
        -- '2021-01-01'是开始日期,'2022-05-31'是截止日期
        select  date_add('2021-01-01',t0.pos) as `date`
        from (
            -- 通过 space函数创建指定长度的空格字符串，并炸开成多行
            select posexplode (split(space(datediff('2022-05-31', '2022-05-15')), ''))
        ) t0
        -- 通过 repeat 函数创建指定长度的字符串，并炸开成多行
        -- from (
        --     select posexplode (split (repeat ('o', datediff ('2022-05-31', '2021-01-01')), 'o'))
        -- ) t0 
    ) t1 
) t2;

-- * key points: 

-- * trunc(string date,string format)
-- * desc  : 返回日期的最开始日期。目前格式支持：MM（月）YYYY（年）Hive3.0后支持Q表示季度
select trunc('2024-07-15', 'MM')        -- 2024-07-01
select trunc('2024-07-15', 'YY')        -- 2024-01-01
    -- * 进阶
    -- * 求上月末
    select date_sub(trunc('2024-09-10', 'MM'), 1)           -- 2024-08-31
    -- * 求上月初
    select trunc(add_months('2024-09-10', -1), 'MM')        -- 2024-08-01

-- * datediff(string enddate, string startdate)
-- * 返回指定两个日期的天数。注意第一个参数是结束日期
select datediff('2024-09-10', '2024-09-01')     -- 9

-- * date_add(date/timestamp/string startdate, tinyint/smallint/int days)       -- 返回开始日期startdate增加天数days后的日期
-- * date_add(date/timestamp/string startdate, tinyint/smallint/int days)       -- 返回开始日期startdate减去天数days后的日期
-- * 2.1.0版本前返回string，2.1.0版本后返回date
select date_add('2024-09-15', 5);       -- 2024-09-20
select date_sub('2024-09-15', 5)        -- 2024-09-10

-- * add_months(string start_date, int num_months)
-- * add_months(string start_date, int num_months, output_date_format)          -- hive 4.0 后可用
select add_months('2024-09-10', 3);     -- 2024-12-10

-- * months_between(date1, date2)
-- * 返回值是 double !!!
select months_between('2024-09-15', '2024-09-01');          -- 0.4516129
select months_between('2024-09-15', '2024-08-01')           -- 1.4516129

-- * last_day(string date) 
-- * 返回该月最后一天的日期
select last_day('2024-07-15')           -- 2024-07-31

-- * next_day(string date,string dayOfWeek)
-- * 求当前日期下周一的日期。
    -- 按理说没必要多传一个参数，不知道啥含义。
select next_day('2024-09-10', 'MO');    -- 2024-09-16
    -- * 进阶
    -- * 求本周一
    select date_sub(next_day(current_date, 'MO'), 7)        -- 2024-09-09
    -- * 求本周末
    select date_sub(next_day(current_date, 'MO'), 1)        -- 2024-09-15

-- * add_months(string date,int months)
-- * 返回months月之后的date,months可以是负数
select add_months('2024-07-15', 2)      -- 2024-09-15
select add_months('2024-07-15', -2)     -- 2024-05-15

-- * date_format(string timestamp, string dateformat)
select date_format('2022-05-29 20:21:22', 'yyyy-MM-dd')     -- 2022-05-29

-- * current_date() / current_date
-- * 返回当前日期
select current_date                     -- 2024-09-10

-- * pmod(int a, int b)
-- * pmod(double a, double b)
-- * 返回a除以b的余数的绝对值
select pmod(10, 4)                      -- 2
select pmod(4, 10);                     -- 4
select pmod(10.2, 2)                    -- 0.2
select pmod(10.2, -2);                  -- -1.8
select pmod(-10.2, 2)                   -- 1.8

-- * year(string date)
-- * month(string date)
-- * hour(string date)
-- * quarter(string date)
    -- * 进阶
    -- * 求季度初
    select case quarter(current_date)
        when 1 then concat(year(current_date), '-01-01')
        when 2 then concat(year(current_date), '-04-01')
        when 3 then concat(year(current_date), '-07-01')
        when 4 then concat(year(current_date), '-10-01')
    end;        
    -- current date 20240910, result 2024-07-01
    -- * 求季度末
        -- * 先求出来四季度初，然后天数减一
    select date_sub(
            concat_ws('-', cast(year(current_date) as string), cast(quarter(current_date)*3+1 as string), '01'), 
            1);
    -- current date 20240910, result 2024-09-30

-- * dayofweek(string date)             -- 返回指定日期处于当周的第几天，注意周末是第一天
-- * weekofyear(string date)            -- 返回指定日期处于当年的第几周

-- * output:
-- * ==============================================================

