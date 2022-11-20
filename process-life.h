/**
 * Copyright (C) 2022 Samuel Bailey
 */

#pragma once

#include <memory>

void print();

namespace GridProc {
__global__
void gpu_print();

__global__
void compute_cell(bool *initial_state, size_t initial_pitch, bool *final_state, size_t final_pitch, char *instr, char *outstr);

} /* namespace GridProc */

class Grid{
public:
    bool *h_grid;

    // For debugging
    char *h_instr;
    char *d_instr;
    char *h_outstr;
    char *d_outstr;
private:
    bool *d_grid;
    size_t d_grid_pitch;

    bool *d_next_grid;
    size_t d_next_grid_pitch;

    int h_grid_cols;
    int h_grid_rows;

public:
    /**
     * @brief Construct a new Grid object. The grid is indexed from top left
     * 
     * @param x_size number of columns
     * @param y_size number of rows
     */
    Grid(int x_size, int y_size, bool *initial_state=nullptr);

    ~Grid();

public:
    void step_forwards(int n_steps);
    /**
     * @brief Get a copy of the host grid. If you want fast access, consider
     * directly accessing h_grid
     * 
     * @param reallign Whether to allign the data to the edge of the array, removing
     * borders, which help during computation (set false for more speed)
     * @return boolean 1D array, which is of length h_cols*h_rows*sizeof(bool)
     * This allocates, and copies into an address pointed to by a smart pointer.
     */
    std::unique_ptr<bool[]> get_host_grid(bool reallign=true);
    /**
     * @brief Updates the host grid with the data stored on the device
     */
    void update_host_grid();
    /**
     * @brief Updates the device grid with the data stored on the host
     */
    void update_device_grid();
};