int pressure(int a, int b, int c, int d) {
    int x1 = a * 2;
    int x2 = b * 3;
    int x3 = c * 4;  
    int x4 = d * 5;
    int x5 = a * b;
    int x6 = c * d;
    // All variables needed at same time
    return x1 + x2 + x3 + x4 + x5 + x6 + a + b + c + d;
}
