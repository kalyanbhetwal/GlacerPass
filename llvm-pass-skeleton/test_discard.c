// Test file for discard attribute register allocation

__attribute__((annotate("discard"))) int discard_func(int a, int b) {
    int x = a + b;
    int y = x * 2;
    int z = y - a;
    int w = z + x;
    return w + b;
}

int normal_func(int a, int b) {
    int x = a + b;
    int y = x * 2;
    int z = y - a;
    int w = z + x;
    return w + b;
}

__attribute__((annotate("discard"))) int discard_func2(int a, int b, int c) {
    int result = 0;
    for (int i = 0; i < a; i++) {
        result += b * c;
    }
    return result;
}

int normal_func2(int a, int b, int c) {
    int result = 0;
    for (int i = 0; i < a; i++) {
        result += b * c;
    }
    return result;
}
