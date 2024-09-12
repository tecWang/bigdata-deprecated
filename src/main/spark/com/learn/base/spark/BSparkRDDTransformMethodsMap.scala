package com.learn.base.spark

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

/*
* spark 方法 ==>
*   1. 将数据向下流转，转换算子     Transformation
*   2. 控制数据流转，行动算子。     Action
* rdd 处理数据的分类 ==>
*   1. 单值类型
*   2. 键值类型
* */

object BSparkRDDTransformMethodsMap {
  def main(args: Array[String]): Unit = {
    // 创建一个 conf 对象
    val conf = new SparkConf()
    conf.setMaster("local[*]")      // 指定为本地模式，否则会报错, A master URL must be set in your configuration spark
    conf.setAppName("HelloWorld")
    conf.set("spark.default.parallelism", "10")

    // 保存文件到本地
    val sc = new SparkContext(conf)

    // 从对象加载数据，并落本地文件
    val pathFromObj = "output/from_obj/"

    // parallelize 用以指定并行度
    val rdd: RDD[String] = sc.parallelize(Array("1", "2", "3", "4", "5", "6"), numSlices = 3)

    // map 的作用就是对每个元素做处理，可以拆分成 list，也可以对单个元素做处理
    rdd.map(item => {item.toInt + 1})
//      .collect()      // 启用 collect 之后，打印的顺序会变成有序的
      .foreach(item => println(s"item: ${item}"))   // 遍历rdd： 2 3 4 5 6 7 (乱序)

  }
}
