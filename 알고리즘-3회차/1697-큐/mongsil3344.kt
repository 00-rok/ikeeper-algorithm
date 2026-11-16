import java.util.Scanner

fun main () {
    val sc = java.util.Scanner(java.lang.System.`in`)
    val queue = Queue(100)

    val n = sc.nextInt()

    for(i in 0 until n) {
        val input = sc.next().first()
        when(input) {
            'i' -> {
                val value = sc.nextInt()

                queue.enqueue(value)
            }

            'o' -> {
                queue.dequeue()
            }

            'c' -> {
                queue.size()
            }
        }
    }
}

class Queue(var capacity: Int) {
    private var tail = 0
    private var arr = IntArray(capacity)

    fun enqueue(a: Int): Int {
        if (a > 10000) {
           return -1
        }

        arr[tail] = a
        tail++
        return a
    }

    fun dequeue(): Int {
        if (tail == 0) {
            println("empty")
            return -1
        }

        val value = arr[0]

        for(i in 1 until tail) {
            arr[i-1] = arr[i]
        }

        tail--

        println(value)

        return value
    }

    fun size() {
        println(tail)
    }
}