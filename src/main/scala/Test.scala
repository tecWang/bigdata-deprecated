package org.example

object t {
  def main(args: Array[String]): Unit = {
    println("hello")
  }
}

object TestMethod {
  private def add(a:Int, b:Int):Int = {
    a + b
  }
  private def sayHello(): Unit = println("Hello")

  private def sayHelloV2(x:String): Unit = {
    if (x != null) {
      println(x)
    } else {
      println("hello")
    }
  }

  def main(args: Array[String]):Unit = {
    println(add(1,2))
    sayHello()
    sayHelloV2("test")
  }
}