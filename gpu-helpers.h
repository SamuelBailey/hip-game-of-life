#pragma once

__device__ __host__
void my_reverse(char str[], int len);

__device__ __host__
char *my_itoa(int num, char* str, int base);

__device__ __host__
int my_min(int a, int b);

__device__ __host__
char *my_strcpy(char *dest, const char *src);
