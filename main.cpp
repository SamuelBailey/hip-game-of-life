/**
 * Copyright (C) 2022 Samuel Bailey
 */

#include <iostream>
#include <memory>
#include "read-file.h"
#include "process-life.h"
#include "gpu-helpers.h"

int main(int argc, char **argv) {
    // std::cout << "Hello, world!" << std::endl;

    // Read in a file
    int x_len, y_len;
    auto[success, arr] = file::read_into_arr("data/inputs/test1.txt", x_len, y_len);
    if (!success) {
        return 1;
    }

    // print();

    Grid grid(x_len, y_len, arr.get());

    grid.step_forwards(1);
    grid.update_host_grid();
    auto result = grid.get_host_grid();

    file::write_arr_to_file(result.get(), x_len, y_len, "data/outputs/result.txt");

    char value[100] = {0};
    my_itoa(457, value, 10);
    std::cout << "number: " << value << std::endl;
}