package base.utils.test

import base.utils.ActorPerson

object TestActorPerson {
  def main(args: Array[String]): Unit = {
    val a  = new ActorPerson(20, "zhang san")

    // original: hi, i am zhang san, my age is 20
    // override: override by UtilAction. i am zhang san, my age is 20
    a.sayHi()

    a.jump()    // i can jump 2 meters away.


  }
}
