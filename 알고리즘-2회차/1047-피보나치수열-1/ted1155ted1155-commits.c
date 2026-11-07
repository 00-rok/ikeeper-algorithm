#include <stdio.h>

int main(void)
{
    int n;
    int a = 0, b = 1, next;

    scanf("%d", &n);

    for (int i = 0; i < n; i++)
    {
        next = a + b;
        a = b;
        b = next;
    }

    printf("%d\n", a);
    return 0;
}
