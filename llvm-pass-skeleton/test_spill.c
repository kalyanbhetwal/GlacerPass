int complex_function(int a, int b, int c, int d) {
    int x1 = a + b;
    int x2 = c + d;
    int x3 = x1 * x2;
    int x4 = a - b;
    int x5 = c - d;
    int x6 = x4 * x5;
    int x7 = x3 + x6;
    int x8 = x1 - x2;
    int x9 = x7 + x8;
    int x10 = x9 * 2;
    return x10 + x3 + x6;
}
