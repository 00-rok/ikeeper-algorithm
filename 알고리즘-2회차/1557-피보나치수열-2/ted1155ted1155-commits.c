#include <stdio.h>

int main(void)
{
    int n;
    long long a = 1, b = 3, next;
    long long sum = 0;

    scanf("%d", &n);

    while (a <= n)
    {
        if (a % 2 == 0)
            sum += a;

        next = a + b;
        a = b;
        b = next;
    }

    printf("%lld\n", sum);

    return 0;
}
