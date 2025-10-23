int add(int a, int b) {
    int x = a + b;
    int y = x * 2;
    int z = y - a;
    return z + b;
}

int main() {
    return add(5, 10);
}
