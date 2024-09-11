
import org.apache.spark.sql.{Dataset, SparkSession}

object ASparkHelloWorld {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("helloWorld")
      // windows 环境运行需要指定，否则会报错。HADOOP_HOME and JAVA_HOME Not Set Correctly on Windows
      .config("hadoop.home.dir", "D:\\Langs\\hadoop-2.8.1\\hadoop-2.8.1")
      .master("local[*]")     // 指定为本地模式，否则会报错, A master URL must be set in your configuration spark
      .getOrCreate()

    // 读取文件
    // 可以看到 textFile 方法的返回值 是 _root_.org.apache.spark.sql.Dataset
    // def textFile(path: _root_.scala.Predef.String): _root_.org.apache.spark.sql.Dataset[_root_.scala.Predef.String] = ???
    // 此处的textFile其实是一个就是一个 Dataset 的实例化对象
    // class Dataset[T](@DeveloperApi @Unstable val queryExecution: QueryExecution, @DeveloperApi @Unstable val encoder: Encoder[T])
    val textFile:Dataset[String] = spark.read.textFile("data/word.csv")

    // 统计 a b 两个字母的数量
    val numAs = textFile.filter(line => line.contains("a")).count()
    val numBs = textFile.filter(line => line.contains("b")).count()

    // 保存文件到本地
    // HADOOP_HOME and JAVA_HOME Not Set Correctly on Windows
    // 解决办法： 搞到 hadoop wintuils二进制文件，配置环境变量。参考：https://cwiki.apache.org/confluence/display/HADOOP2/WindowsProblems
    textFile.javaRDD.saveAsTextFile("output/")

    // 打印对象
    println(s"numAs: ${numAs}, numBs: ${numBs}")    // numAs: 4, numBs: 0

    // 打印
    textFile.collect().foreach(item => println(s"item: ${item}"))
//    item: hello,tom,hello,jack,tec
//    item: hello,method,idea
//    item: ultimate,csv
//    item: try,install,learn,hello

    // 休眠5秒，用来查看spark页面
    Thread.sleep(2000)

    // 停止
    spark.stop()
  }
}
