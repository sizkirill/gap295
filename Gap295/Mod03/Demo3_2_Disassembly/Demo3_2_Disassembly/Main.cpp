// Main.cpp
#include <stdio.h>

int ReadNumber();
int Square(int val);

int main()
{
	int val = ReadNumber();
	printf("Value: %d", val);

	printf("Value: %d", Square(val));

	return 0;
}

int ReadNumber()
{
	int val;
	scanf_s("%d", &val);
	return val;
}

int Square(int val)
{
	return val * val;
}