#include <iostream>
#include "process-life.h"

__global__
void GridProc::compute_cell(bool *initial_state, bool *final_state);

Grid::Grid(int x_size, int y_size, bool *initial_state) {
    void *d_grid_tmp;
    cudaMallocPitch(&d_grid_tmp, &d_grid_pitch, x_size * sizeof(bool), y_size);
    d_grid = static_cast<bool *>(d_grid_tmp);

    cudaMallocPitch(&d_grid_tmp, &d_next_grid_pitch, x_size * sizeof(bool), y_size);
    d_next_grid = static_cast<bool *>(d_grid_tmp);

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

