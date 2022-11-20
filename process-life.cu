/**
 * Copyright (C) 2022 Samuel Bailey
 */

#include <iostream>
#include <memory>
#include <stdio.h>
#include "process-life.h"
#include "gpu-helpers.h"


__device__
void my_reverse(char str[], int len)
{
    int start, end;
    char temp;
    for(start=0, end=len-1; start < end; start++, end--) {
        temp = *(str+start);
        *(str+start) = *(str+end);
        *(str+end) = temp;
    }
}


__device__
char *my_itoa(int num, char* str, int base)
{
    int i = 0;
    bool isNegative = false;
  
    /* A zero is same "0" string in all base */
    if (num == 0) {
        str[i] = '0';
        str[i + 1] = '\0';
        return str;
    }
  
    /* negative numbers are only handled if base is 10 
       otherwise considered unsigned number */
    if (num < 0 && base == 10) {
        isNegative = true;
        num = -num;
    }
  
    while (num != 0) {
        int rem = num % base;
        str[i++] = (rem > 9)? (rem-10) + 'A' : rem + '0';
        num = num/base;
    }
  
    /* Append negative sign for negative numbers */
    if (isNegative){
        str[i++] = '-';
    }
  
    str[i] = '\0';
 
    my_reverse(str, i);
  
    return str;
}


__device__
int my_min(int a, int b) {
    if (a < b) {
        return a;
    }
    return b;
}


__device__
char *my_strcpy(char *dest, const char *src) {
    int i = 0;
    do {
        dest[i] = src[i];
    } while (src[i++] != 0);
    return dest;
}


#define GRID_VALUE(arr, col, row, pitch) \
    (reinterpret_cast<bool *>(reinterpret_cast<char *>(arr) + row*pitch))[col]

void print() {
    GridProc::gpu_print<<<1, 1>>>();
}

__global__
void GridProc::gpu_print() {
    printf("Hello, world!\n");
}


__global__
void GridProc::compute_cell(bool *initial_state, size_t initial_pitch, bool *final_state, size_t final_pitch, char *instr, char *outstr) {
    // For now, assume there are enough processors to have 1 for each cell
    // Need to start at [1, 1] instead of [0, 0] because of the boundaries
    int column = (blockIdx.x * blockDim.x) + threadIdx.x + 1;
    int row = (blockIdx.y * blockDim.y) + threadIdx.y + 1;

    if (threadIdx.x == 0 && threadIdx.y == 0 && blockIdx.x == 0 && blockIdx.y == 0) {
        char tmp[] = "It's working!!! NAAAT.";
        my_strcpy(outstr, tmp);
    }
    return;

    unsigned int count = 0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            // Don't count the middle cell
            if (i == 0 && j == 0) {
                continue;
            }
            if (threadIdx.x == 0 && threadIdx.y == 0) {
                // printf("Block: %d, Thread: %d, reading from (%d, %d)\n", (int)threadIdx.x, (int)threadIdx.y, column+i, row+j);
            }

            count += GRID_VALUE(initial_state, column+i, row+j, initial_pitch);
        }
    }
    return;

    // Set the result in the final_state array

    // If there is no item in the cell
    if (GRID_VALUE(initial_state, column, row, initial_pitch) == false) {
        // Spawn a new one
        if (count == 3) {
            GRID_VALUE(final_state, column, row, final_pitch) = true;
        } else { // Else don't
            GRID_VALUE(final_state, column, row, final_pitch) = false;
        }
    } else {
        // There is an item in the cell
        if (count > 1 && count < 4) {
            GRID_VALUE(final_state, column, row, final_pitch) = true;
        } else {
            GRID_VALUE(final_state, column, row, final_pitch) = false;
        }
    }
}

Grid::Grid(int x_size, int y_size, bool *initial_state) {
    h_grid_cols = x_size + 2;
    h_grid_rows = y_size + 2;

    cudaMalloc(reinterpret_cast<void **>(&d_instr), 100 * sizeof(char));
    cudaMallocHost(reinterpret_cast<void **>(&h_instr), 100 * sizeof(char));
    cudaMalloc(reinterpret_cast<void **>(&d_outstr), 100 * sizeof(char));
    cudaMallocHost(reinterpret_cast<void **>(&h_outstr), 100 * sizeof(char));

    // Malloc grids
    cudaMallocPitch(reinterpret_cast<void **>(&d_grid), &d_grid_pitch, h_grid_cols * sizeof(bool), h_grid_rows);
    cudaMallocPitch(reinterpret_cast<void **>(&d_next_grid), &d_next_grid_pitch, h_grid_cols * sizeof(bool), h_grid_rows);
    cudaMallocHost(&h_grid, h_grid_rows * h_grid_cols * sizeof(bool));

    // Clear grids
    cudaMemset2D(d_grid, d_grid_pitch, false, h_grid_cols * sizeof(bool), h_grid_rows);
    cudaMemset2D(d_next_grid, d_grid_pitch, false, h_grid_cols * sizeof(bool), h_grid_rows);
    cudaMemset(h_grid, false, h_grid_rows * h_grid_cols * sizeof(bool));

    // Populate grids
    if (initial_state != nullptr) {
        
        // First copy into h_grid, which has the same dimensions as d_grid
        for (int j = 0; j < y_size; j++) {
            // Copy each row using memcpy
            memcpy(&h_grid[1 + (j+1)*h_grid_cols], &initial_state[j * x_size], x_size);
        }

        // Copy host grid to the device
        cudaMemcpy2D(d_grid, d_grid_pitch, initial_state, h_grid_cols * sizeof(bool), h_grid_cols, h_grid_rows, cudaMemcpyHostToDevice);

        std::cout << "copied initial state" << std::endl;
    } else {
        std::cout << "didn't copy initial state" << std::endl;
    }
}

Grid::~Grid() {
    cudaFree(d_outstr);
    cudaFreeHost(h_outstr);

    cudaFree(d_grid);
    cudaFree(d_next_grid);
    cudaFreeHost(h_grid);
    std::cout << "Freed grid" << std::endl;
    std::cout << "Sizeof bool = " << sizeof(bool) << std::endl;
}

void Grid::step_forwards(int n_steps) {
    auto thread_dims = dim3(h_grid_cols, h_grid_rows);

    for (int i = 0; i < n_steps; i++) {
        // Perform a step
        GridProc::compute_cell<<<1, thread_dims>>>(d_grid, d_grid_pitch, d_next_grid, d_next_grid_pitch, d_instr, d_outstr);
        cudaMemcpy(h_outstr, d_outstr, 100, cudaMemcpyDeviceToHost);

        std::cout << "OUTSTR: " << h_outstr << std::endl;
        // TODO: copy boundaries

        // swap pointers
        bool *tmp_ptr = d_grid;
        d_grid = d_next_grid;
        d_next_grid = tmp_ptr;
    }
}

void Grid::update_host_grid() {
    cudaMemcpy2D(h_grid, h_grid_cols * sizeof(bool), d_grid, d_grid_pitch, h_grid_cols * sizeof(bool), h_grid_rows, cudaMemcpyDeviceToHost);
}

std::unique_ptr<bool[]> Grid::get_host_grid(bool reallign) {
    if (!reallign) {
        auto result_grid = std::make_unique<bool[]>(h_grid_cols*h_grid_rows);
        memcpy(result_grid.get(), h_grid, h_grid_cols*h_grid_rows*sizeof(bool));
        return std::move(result_grid);
    }

    // Reallign
    auto result_grid = std::make_unique<bool[]>((h_grid_cols-2) * (h_grid_rows-2));
    for (int j = 1; j < h_grid_rows-1; j++) {
        memcpy(&result_grid[(j-1) * (h_grid_cols-2)], &h_grid[1 + (j * h_grid_cols)], (h_grid_cols-2)*sizeof(bool));
    }
    return std::move(result_grid);
}