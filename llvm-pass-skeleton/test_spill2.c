int test(int a, int b, int c, int d, int e) {
    int x1 = a + b;
    int x2 = c + d;
    int x3 = e + a;
    int x4 = x1 + x2;
    int x5 = x3 + x4;
    return x5 + b + c + d + e;
}
