
int main() {
    int a = 10;
    int b = 5;

    int result = a + b * 2;

    print(result);

    if (result > 15) {
        result = result + 10;
    }

    print(result);

    while (result < 35) {
        result = result + 1;
    }

    print(result);

    return 0;
}
