
int main() {
    int a = 10;
    int b = 5;
    int result = 0;

    if (a > b && b != 0) {
        result = a + b * 2;
    } else {
        result = a - b;
    }

    while (result < 30) {
        result = result + 1;
    }

    if (result >= 30) {
        result = result % 7;
    }

    return result;
}
