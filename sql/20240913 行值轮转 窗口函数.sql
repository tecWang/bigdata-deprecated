
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :

-- * input :
-- todo: data demo

-- * target: 
ENAME             SAL    FORWARD     REWIND
---------- ---------- ---------- ----------
SMITH             800        950       5000
JAMES             950       1100        800
ADAMS            1100       1250        950
WARD             1250       1250       1100
MARTIN           1250       1300       1250
MILLER           1300       1500       1250
TURNER           1500       1600       1300
ALLEN            1600       2450       1500
CLARK            2450       2850       1600
BLAKE            2850       2975       2450
JONES            2975       3000       2850
SCOTT            3000       3000       2975
FORD             3000       5000       3000
KING             5000        800       3000

-- * ==============================================================

-- * ==============================================================

-- * create base table
create table base (
    ename string,
    salary int
);

insert into base values('SMITH', 800),
('JAMES', 950),
('ADAMS', 1100),
('WARD', 1250),
('MARTIN', 1250),
('MILLER', 1300),
('TURNER', 1500),
('ALLEN', 1600),
('CLARK', 2450),
('BLAKE', 2850),
('JONES', 2975),
('SCOTT', 3000),
('FORD', 3000),
('KING', 5000)

-- * ==============================================================

-- * ==============================================================

-- * solution n: desc
select
    ename,
    salary,
    -- lag == last value
    -- lag  是往前找，找前N个元素，则第一行记录的上一个元素不存在，应该取 max
    nvl(lag(salary, 1) over(order by salary), max(salary) over()) as prev,
    -- lead ==> lead value
    -- lead 是往后找，找后N个元素，则最后一个元素不存在，应该取 min
    nvl(lead(salary, 1) over(order by salary), min(salary) over()) as forward
from base
order by salary;

-- * key points: 
-- * desc  : 窗口函数

-- * Lag和Lead分析函数可以在同一次查询中取出同一字段的 前N行的数据(Lag) 和 后N行的数据(Lead) 作为独立的列。
-- * 这种操作可以代替表的自联接，并且LAG和LEAD有更高的效率，其中over()表示当前查询的结果集对象，括号里面的语句则表示对这个结果集进行处理。

-- * lead(col, n, default) --> 用于统计窗口内往下第n行值
-- * 参数1为列名，
-- * 参数2为往下第n行（可选，默认为1）
-- * 参数3为默认值（当往下第n行为NULL时候，取默认值，如不指定，则为NULL）

-- * lag(col,n,DEFAULT) --> 用于统计窗口内往上第n行值
-- * 参数1为列名
-- * 参数2为往上第n行（可选，默认为1）
-- * 第三个参数为默认值（当往上第n行为NULL时候，取默认值，如不指定，则为NULL）可以用来做一些时间的维护，如上一次登录时间。

-- ! 如果想要取最大最小值的时候，报错提示需要分组统计，可以直接使用窗口函数获取。如：min(salary) over()

-- * output:
-- SMITH   800     950     5000
-- JAMES   950     1100    800
-- ADAMS   1100    1250    950
-- WARD    1250    1250    1100
-- MARTIN  1250    1300    1250
-- MILLER  1300    1500    1250
-- TURNER  1500    1600    1300
-- ALLEN   1600    2450    1500
-- CLARK   2450    2850    1600
-- BLAKE   2850    2975    2450
-- JONES   2975    3000    2850
-- SCOTT   3000    3000    2975
-- FORD    3000    5000    3000
-- KING    5000    800     3000
-- * ==============================================================

