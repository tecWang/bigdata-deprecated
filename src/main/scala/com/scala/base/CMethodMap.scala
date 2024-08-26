package com.scala.base

object CMethodMap {
  def main(args: Array[String]): Unit = {

    val arr = List(1,2,3,4,5,6,7)

    // map 跟 foreach的区别在于，foreach方法没有返回值，只能打印，map可以处理并返回完全类型的数据类型，可以连续不断的进行处理
//    scala> arr.map(item => item * 2)
//    res0: Array[Int] = Array(2, 4, 6, 8, 10, 12, 14)

    println("arr print: " + arr)
    val arr2 = arr.map(item => if(item < 5) item + 1 else item)
      .map(item => if(item % 2 == 0) item else item * 2)
    println("arr2 print: " + arr2)

    val arr3 = arr.map(item => {
      if (item % 2 == 0) (item, "even")
      else (item, "odd")
    })
    println("arr3 print: " + arr3)
  }
}
