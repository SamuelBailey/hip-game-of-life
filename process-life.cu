/**
 * Copyright (C) 2022 Samuel Bailey
 */

#include <iostream>
#include "process-life.h"

#define GRID_VALUE(arr, col, row, pitch) \
    (reinterpret_cast<bool *>(reinterpret_cast<char *>(arr) + row*pitch))[col]

__global__
void GridProc::compute_cell(bool *initial_state, size_t initial_pitch, bool *final_state, size_t final_pitch) {
    // For now, assume there are enough processors to have 1 for each cell    
    int column = (blockIdx.x * blockDim.x) + threadIdx.x;
    int row = (blockIdx.y * blockDim.y) + threadIdx.y;

    unsigned int count = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            // Don't count the middle cell
            if (i == 0 && j == 0) {
                continue;
            }

            count += GRID_VALUE(initial_state, column+i, row+j, initial_pitch);
        }
    }

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

    cudaMallocPitch(reinterpret_cast<void **>(&d_grid), &d_grid_pitch, h_grid_cols * sizeof(bool), h_grid_rows);
    cudaMallocPitch(reinterpret_cast<void **>(&d_next_grid), &d_next_grid_pitch, h_grid_cols * sizeof(bool), h_grid_rows);

    if (initial_state != nullptr) {
        // TODO: Copy data if not nullptr
        std::cout << "copied initial state" << std::endl;
    } else {
        std::cout << "didn't copy initial state" << std::endl;
    }
}

Grid::~Grid() {
    cudaFree(d_grid);
    cudaFree(d_next_grid);
}

