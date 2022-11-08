#include "process-life.h"

Grid::Grid(int x_size, int y_size) {

}

Grid::Grid(int x_size, int y_size, bool **initial_state) {
    void *d_grid_tmp;
    cudaMallocPitch(&d_grid_tmp, &d_grid_pitch, x_size, y_size);
    d_grid = static_cast<bool *>(d_grid_tmp);
}

Grid::~Grid() {
    cudaFree(d_grid);
}