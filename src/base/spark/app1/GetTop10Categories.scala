package base.spark.app1

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

import scala.collection.mutable.ArrayBuffer

/*
* user_visit_action.txt数据说明
* 0. 字段之间采用 "_" 分割。
*   字段包括：
*     0,   1,     2,        , 3,   , 4,       5,        6,        7,     8,          9,      10,        11,     12
*     日期，用户id，session id，页面id，动作时间点，搜索关键字，点击品类id, 产品id，下单品类ids, 产品ids，支付品类ids, 产品ids，城市id
* 样例：
*   搜索：2019-07-17_95_26070e87-1ad7-49a3-8fb3-cc741facaddf_37_2019-07-17 00:00:02_手机_-1_-1_null_null_null_null_3
*   点击：2019-07-17_95_26070e87-1ad7-49a3-8fb3-cc741facaddf_48_2019-07-17 00:00:10_null_16_98_null_null_null_null_19
*   下单：2019-07-17_38_6502cdc9-cf95-4b08-8854-f03a25baa917_24_2019-07-17 00:00:38_null_-1_-1_15,13,5,11,8_99,2_null_null_10
*   支付：2019-07-17_38_6502cdc9-cf95-4b08-8854-f03a25baa917_22_2019-07-17 00:00:28_null_-1_-1_null_null_15,1,20,6,4_15,88,75_9
* 1. 每一行表示用户的一个行为，每行只会是四种行为的其中一个。四种行为包括：搜索，点击，下单，支付。
* 2. 如果点击的品类id和产品id是-1，说明不是点击行为。
* 3. 一次可以下单多个商品，所以品类id，产品id可能是多个，id之间逗号分割。
* 4. 搜索关键字为null说明不是搜索动作。
* 5.
* */
object GetTop10Categories {
  def main(args: Array[String]): Unit = {

    // create spark context
    val conf = new SparkConf()
    conf.setMaster("local[*]")
    conf.setAppName("getTop10Categories")

    val sc = new SparkContext(conf)
    val rdd: RDD[String] = sc.textFile("data/user_visit_action.txt")

    // 开始计算
      // 计算热门品类top10（按照点击、下单、支付进行排序）
    // 过滤掉搜索类型的数据，搜索的不需要纳入统计，只需要点击，下单，支付的数据
    val filteredNonSearchRDD:RDD[String] = rdd.filter(item => {
        val attrs = item.split('_')
        "null".equals(attrs(5))
      })

//    println(filteredSearchRDD.count())   // 140338

    // 低版本写法
//    val filteredClickRDD: RDD[(String, Int, Int, Int)] = filteredNonSearchRDD
//      .map(item => item.split('_'))     // RDD[Array[String]]
//      .filter(attrs => {                // RDD[Array[String]]
//        !"-1".equals(attrs(6))
//      })    // 19819
//      .map(attrs => (attrs(7), 1, 0, 0))
//      .reduceByKey((a,b) => a+b)      // 为了避免多次使用 reduceByKey，将其最后合并后再进行计算
    // 2019-07-22_20_63dc160f-80ff-4caa-b5f9-a0ff96fde9db_43_2019-07-22 09:55:56_null_-1_-1_null_null_2_100,82_26

//    println(filteredClickRDD.take(10).mkString("Array(", ", ", ")"))
    // Array((88,1204), (4,1218), (82,1183), (80,1234), (19,1153), (42,1272), (53,1241), (62,1163), (6,1164), (37,1237))

    // 优化后写法
    val transformedRDD:RDD[Iterator[(String, SparkApp1HotCategory)]] = filteredNonSearchRDD.map(line => {
        val cols = line.split('_')
        // 点击数据
        if (!"-1".equals(cols(6))) ArrayBuffer[(String, SparkApp1HotCategory)]((cols(6), new SparkApp1HotCategory(cols(6), 1, 0, 0))).iterator
        // 下单数据
        else if (!"null".equals(cols(8))) {
          // 此处需要拆分内容
          val ids = cols(8).split('_')
          // 需要用数组接收内容，并返回迭代器
          val hcList = ArrayBuffer[(String, SparkApp1HotCategory)]()
          for (id <- ids)
            hcList.append((id, new SparkApp1HotCategory(id, 0, 1, 0)))
          hcList.iterator
        }
        // 支付数据
        else {
          val ids = cols(10).split('_')
          val hcList = ArrayBuffer[(String, SparkApp1HotCategory)]()
          for (id <- ids)
            hcList.append((id, new SparkApp1HotCategory(id, 0, 0, 1)))
          hcList.iterator
        }
      })

    // TODO: 迭代器遍历
//    transformedRDD.foreach(println)



  }
}

case class SparkApp1HotCategory(
                          val id:String,
                          val clickCnt: Int,
                          val orderCnt: Int,
                          val paymentCnt: Int
                          )
  extends Serializable {}