object DataStruct {

  val arr:Array[Int] = Array[Int](1,2,3,4,5,6)
  val arr2 = Array(1,2,3,4,5,6)
  val arr3 = new Array(5)
  val arr4 = new Array[Int](5)

  def main(args: Array[String]):Unit = {
    println("arr: " + arr)
    println("arr2: " + arr2)
    println("arr3: " + arr3)
    println("arr4: " + arr4)
  }
}
