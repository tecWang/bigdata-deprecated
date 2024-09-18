package base.spark

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.rdd.RDD

object BSparkRDDOperateTransformReduceByKey {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf()
    conf.setMaster("local")
    conf.setAppName("spark")

    val sc = new SparkContext(conf)
    // 定义元组数组
    val rdd: RDD[(String, Int)] = sc.parallelize(Array(("a", 1), ("b", 2), ("a", 3), ("c", 4)))

    //  def reduceByKey(partitioner: Partitioner, func: (V, V) => V): RDD[(K, V)] = self.withScope {
      //  def reduceByKey(func: (Int, Int) => Int) : RDD[(String, Int)]
    val rdd2: RDD[(String, Int)] = rdd.reduceByKey((a,b) => a+b)

//    (a,4)
//    (b,2)
//    (c,4)

    // 输出打印预览
    rdd2.collect().foreach(println)

  }
}
