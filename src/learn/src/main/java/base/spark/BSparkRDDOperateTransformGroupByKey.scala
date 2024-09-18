package base.spark

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.rdd.RDD

object BSparkRDDOperateTransformGroupByKey {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf()
    conf.setMaster("local")
    conf.setAppName("spark")

    val sc = new SparkContext(conf)
    // 定义元组数组
    val rdd: RDD[(String, Int)] = sc.parallelize(Array(("a", 1), ("b", 2), ("a", 3), ("c", 4)))

    // groupByKey 与 groupBy 相比，其实只是节省了传key的过程，其他没啥区别

    //    def groupByKey(numPartitions: Int): RDD[(K, Iterable[V])] = self.withScope {
    val rdd2:RDD[(String, Iterable[Int])] = rdd.groupByKey(numPartitions = 5)
      //    (a,CompactBuffer(1, 3))
      //    (b,CompactBuffer(2))
      //    (c,CompactBuffer(4))
        //  private[spark] class CompactBuffer[T: ClassTag] extends Seq[T] with Serializable {

    // 将 value 值相加
    val rdd3: RDD[(String, Int)] = rdd2.mapValues(itar => {
        var res = 0
        for (value <- itar) res += value
        res
      })
      //    (a,4)
      //    (b,2)
      //    (c,4)

    rdd3
      .collect()
      .foreach(println)



  }
}
