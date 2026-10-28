int main() {
    int a = 10;

    {
        int a = 20;
        print(a);
    }

    print(a);

    return 0;
}