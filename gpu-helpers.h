#pragma once

__device__
void my_reverse(char str[], int len);

__device__
char *my_itoa(int num, char* str, int base);

__device__
int my_min(int a, int b);

__device__
char *my_strcpy(char *dest, const char *src);
