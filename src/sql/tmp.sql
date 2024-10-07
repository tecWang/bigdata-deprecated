
-- ! env: hadoop 3.1.4 + hive 3.1.3

-- * ==============================================================
-- * data requirement
-- * ==============================================================

-- * desc  :

-- * input :
-- todo: data demo

-- * target: 
-- todo: data demo

-- * ==============================================================

-- * ==============================================================

-- * create base table
create table base as
    select '2018-01-01 10:00:00' as time_id,'001' as user_id UNION ALL
    select '2018-01-01 11:03:00' as time_id,'002' as user_id UNION ALL
    select '2018-01-01 13:18:00' as time_id,'001' as user_id UNION ALL
    select '2018-01-02 08:34:00' as time_id,'004' as user_id UNION ALL
    select '2018-01-02 10:08:00' as time_id,'002' as user_id UNION ALL
    select '2018-01-02 10:40:00' as time_id,'003' as user_id UNION ALL
    select '2018-01-02 14:21:00' as time_id,'002' as user_id UNION ALL
    select '2018-01-02 15:39:00' as time_id,'004' as user_id UNION ALL
    select '2018-01-03 08:34:00' as time_id,'005' as user_id UNION ALL
    select '2018-01-03 10:08:00' as time_id,'003' as user_id UNION ALL
    select '2018-01-03 10:40:00' as time_id,'001' as user_id UNION ALL
    select '2018-01-03 14:21:00' as time_id,'005' as user_id

-- * ==============================================================

-- * ==============================================================

-- * solution 1: desc
-- todo: sql here

-- * key points:
-- * desc  :

-- * output:
-- * ==============================================================

