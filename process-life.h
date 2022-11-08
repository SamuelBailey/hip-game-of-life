#pragma once

class Grid{
public:
    bool *h_grid;
private:
    bool *d_grid;
    size_t d_grid_pitch;
    int x_dim;
    int y_dim;

public:
    /**
     * @brief Construct a new Grid object. The grid is indexed from top left
     * 
     * @param x_size 
     * @param y_size 
     */
    Grid(int x_size, int y_size);
    Grid(int x_size, int y_size, bool **initial_state);

    ~Grid();

    void step_forwards(int n_steps);
    bool *get_host_grid();
    /**
     * @brief Updates the host grid with the data stored on the device
     */
    void update_host_grid();
    /**
     * @brief Updates the device grid with the data stored on the host
     */
    void update_device_grid();
};