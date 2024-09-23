
-- 分桶分区的区别：
-- 分区针对的是数据的存储路径；分桶针对的是数据文件。
-- 分区提供一个隔离数据和优化查询的便利方式。不过，并非所有的数据集都可形成合理的分区，特别是要确定合适的划分大小这个疑虑。分桶是将数据集分解成更容易管理的若干部分的另一个技术。

-- 分桶规则：对分桶字段值进行哈希，哈希值除以桶的个数求余，余数决定了该条记录在哪个桶中，也就是余数相同的在一个桶中。

-- 分桶的优势
-- 1. 提高join查询效率
-- 2. 提高抽样效率. 提高join的查询效率

drop table if exists bucket_tbl;

create table bucket_tbl (
    id int comment 'id',
    name string comment '姓名'
)
comment '分桶测试表'
clustered by(id) into 4 buckets
-- clustered by(id) sorted by (id) into 4 buckets       -- 还可以指定按照id升序存放
row format delimited fields terminated by ','
;

-- 准备数据
-- /usr/local/bucket_tbl.txt
-- 1,name1
-- 2,name2
-- 3,name3
-- 4,name4
-- 5,name5
-- 6,name6
-- 7,name7
-- 8,name8
-- 9,name9

-- 先把数据导入到中间表，再从中间表往目标表插入，才能实现分桶效果。如果直接把文件load到表里，则还是一个文件。
drop table if exists bucket_tbl_tmp;
create table bucket_tbl_tmp (
    id int comment 'id',
    name string comment '姓名'
)
comment '分桶插入中间表'
row format delimited fields terminated by ','
;

load data local inpath '/usr/local/bucket_tbl.txt' into table bucket_tbl_tmp;

-- 去hdfs web ui查看文件分布情况
-- url: http: nn2-${port}:50070
-- 文件路径：/user/hive/warehouse/bucket_tbl
    -- 可以看到：
        -- bucket_tbl_tmp 下边有一个文件，文件名为: bucket_tbl.txt
        -- bucket_tbl 下边为空

-- 开始插入数据
insert into bucket_tbl select * from bucket_tbl_tmp;

-- 刷新 hdfs web ui，可以看到 bucket_tbl 下边出现了四个文件。
    -- 000000_0, 000001_0, 000002_0, 000003_0

-- 查看文件内容
hadoop fs -ls /user/hive/warehouse/bucket_tbl/
-- Found 5 items
-- drwxr-xr-x   - root supergroup          0 2024-09-23 10:14 /user/hive/warehouse/bucket_tbl/.hive-staging_hive_2024-09-23_10-11-47_201_7094988570300363497-1
-- -rw-r--r--   3 root supergroup         16 2024-09-23 10:13 /user/hive/warehouse/bucket_tbl/000000_0
-- -rw-r--r--   3 root supergroup         24 2024-09-23 10:13 /user/hive/warehouse/bucket_tbl/000001_0
-- -rw-r--r--   3 root supergroup         16 2024-09-23 10:13 /user/hive/warehouse/bucket_tbl/000002_0
-- -rw-r--r--   3 root supergroup         16 2024-09-23 10:14 /user/hive/warehouse/bucket_tbl/000003_0
-- 查出来五个文件，是因为集群性能不足，作业执行到一半被杀掉了。

hadoop fs -cat /user/hive/warehouse/bucket_tbl/000000_0
-- 8,name8
-- 4,name4

-- 抽样查看
select * from bucket_tbl tablesample (bucket 1 out of 2 on id);
-- id      name
-- 6       name6
-- 2       name2
-- 7       name7
-- 3       name3
-- Time taken: 4.701 seconds, Fetched: 4 row(s)

-- tablesample (bucket x out of y on id)

-- 分桶表后面可以不带on 字段名，不带时默认的是按分桶字段,也可以带，而没有分桶的表则必须带。

-- 按分桶字段取样时，因为分桶表是直接去对应的桶中拿数据，在表比较大时会提高取样效率。

-- x表示从哪个桶(x-1)开始, y代表分几个桶, 也可以理解分x为分子, y为分母, 将表分为y份(桶), 取第x份(桶)。
-- 所以这时对于分桶表是有要求的, y为桶数的倍数或因子, 


-- x=1,y=2, 取2(4/y)个bucket的数据, 分别桶0(x-1)和桶2(0+y)
-- x=1,y=4, 取1(4/y)个bucket的数据, 即桶0
-- x=2,y=8, 取1/2(4/y)个bucket的数据, 即桶0的一半
-- x的范围: [1,y]


