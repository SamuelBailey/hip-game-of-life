#include "process-life.h"

Grid::Grid(int x_size, int y_size) {

}

Grid::Grid(int x_size, int y_size, bool **initial_state) {
    cudaChannelFormatDesc desc = {
        .x = x_size,
        .y = y_size,
        .z = 0,
        .w = 0,
        .f = cudaChannelFormatKind::cudaChannelFormatKindUnsigned
    };
    // cudaMalloc3D()
}