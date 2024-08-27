package com.learn.base

import java.sql.{Connection, DriverManager}
import scala.collection.mutable.ListBuffer

// 静态类/常量类，更适合存放工具，常量等内容
// 类加载的时候优先加载静态内容，且只加载一次
// object中的属性，方法都可以直接调用，不需要通过new来加载
// object声明的全部都是静态类
// object没有构造器，不需要实例化
//

object Test {
  println("init")
}

// 单例对象的常量使用方式
object Constant {
  val ip = "192.0.0.1"
  val user = "tecwang"
  val pass = "mm"
  val url = s"jdbc://${ip}:3306/hainiu"

}

// 单例对象先加载，并且只加载一次
// 因此可以考虑自己创建一个mysql连接池
object MysqlConnectUtil {

  val n_conn = 3
  val conn_list:ListBuffer[Connection] = ListBuffer[Connection]()
  // 连接数据库
  for (i <- 1 to n_conn) {
    conn_list.append(DriverManager.getConnection(Constant.url, Constant.user, Constant.pass))
  }
  println(conn_list)

  def getConn() = {
    if( conn_list.size > 0) conn_list.remove(0)
    else {
      println("connection pool hss no more connections !!! ")
      null
    }
  }

  def returnConn(conn:Connection) = {
    if (conn == null) {
      println("connection is invalid")
      null
    } else {
      this.conn_list.append(conn)
    }
  }
}

object DObject {
  def main(args: Array[String]): Unit = {
    // 三个对象都是同一个实例，说明只初始化了一次
    // init也只打印了一次
    println(Test)   // com.learn.base.Test$@7ce6a65d
    println(Test)   // com.learn.base.Test$@7ce6a65d
    println(Test)   // com.learn.base.Test$@7ce6a65d

    // 测试conn
    val conn1 = MysqlConnectUtil.getConn()
    val conn2 = MysqlConnectUtil.getConn()
    val conn3 = MysqlConnectUtil.getConn()
    val conn4 = MysqlConnectUtil.getConn()
    println(conn1)
    println(conn2)
    println(conn3)
    println(conn4)
    MysqlConnectUtil.returnConn(conn1)
    MysqlConnectUtil.returnConn(conn2)
    MysqlConnectUtil.returnConn(conn3)
    MysqlConnectUtil.returnConn(conn4)
  }
}
