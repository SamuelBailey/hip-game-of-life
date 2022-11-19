/**
 * Copyright (C) 2022 Samuel Bailey
 */

#include <iostream>
#include <memory>
#include "read-file.h"
#include "process-life.h"


int main(int argc, char **argv) {
    std::cout << "Hello, world!" << std::endl;

    // Read in a file
    int x_len, y_len;
    auto[success, arr] = file::read_into_arr("data/inputs/test1.txt", x_len, y_len);
    if (!success) {
        return 1;
    }

    Grid grid(x_len, y_len, arr.get());

}