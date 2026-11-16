import java.util.Scanner

fun main() {
    val sc = java.util.Scanner(java.lang.System.`in`);
    val stack = Stack(100)

    val n = sc.nextInt();

    for(i in 0 until n) {
        val command = sc.next().toCharArray()[0]

        when(command) {
            'i' -> {
                stack.push(sc.nextInt())
            }

            'o' -> {
                val value = stack.pop()
                if (value != -1)
                    println(value)
            }

            'c' -> {
                stack.count()
            }
        }
    }
}


class Stack(var capacity: Int) {
    private var top = 0;
    private var arr = IntArray(capacity)

    fun push(a: Int): Int {
        if (top == capacity || a > 10000) {
            return -1
        }
        arr[top] = a
        top++

        return a
    }

    fun pop(): Int {
        if (top == 0) {
            println("empty")
            return -1;
        }

        val value = arr[top-1]
        arr[top-1] = 0
        top--

        return value
    }

    fun count() {
        println(top)
    }
}