package com.learn.base

object FFunctionImplicit {
  def main(args: Array[String]): Unit = {
    for (i <- 1 to 10) println(i)
    println(1.to(10))

    // implicit关键字修饰的方法可以自动调用，并且将一个类型的数据转换为另一个类型的数据
    // implicit -v 可以查看scala提供了多少个隐式方法
    // 比如，当想要使用RichInt的to方法时，会自动将Int转换为RichInt，并调用to方法
//    def to(end: Int): Range.Inclusive = Range.inclusive(self, end)

  }
}
