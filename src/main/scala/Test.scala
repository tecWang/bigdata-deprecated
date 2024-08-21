
import java.io.File

object t {
  def main(args: Array[String]): Unit = {
    println("hello")
  }
}

object TestMethod {

  //  自定义方法
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

  def listFiles (path:String): Unit = {
    val file = new File(path)
    if (file.isFile) {
      println(file.getPath)
    } else {
      println(file.getPath)
      val fs = file.list()
      for (f <- fs) {
        listFiles(path + "/" + f)
      }
    }
  }

  def main(args: Array[String]):Unit = {
    println(add(1,2))
    sayHello()
    sayHelloV2("test")
    listFiles("C:\\Users\\tecwang\\IdeaProjects\\scala\\src")
  }
}