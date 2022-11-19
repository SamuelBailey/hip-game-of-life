/**
 * Copyright (c) 2022 Samuel Bailey
 */

#pragma once

#include <string>
#include <memory>
#include <tuple>

#define EMPTY_CHAR '-'
#define FULL_CHAR 'X'

namespace file{

/**
 * @brief Read a file into a boolean array. This is a 1D array
 * of size width*height*sizeof(bool). The x dimension should be
 * specified on the first line of the file, and the y dimension
 * should be specified on the second line of the file.
 * 
 * @param filename The file to open
 * @param[out] x_len The length of the x dimension of the array
 * @param[out] y_len The length of the y dimension of the array
 * @return std::unique_ptr<bool[]> A unique pointer is passed out
 * since the array doesn't require resizing, however the size is not
 * known at compile time
 */
std::tuple<bool, std::unique_ptr<bool[]>>
read_into_arr(const std::string &filename, int &x_len, int &y_len);

/**
 * @brief Writes array to file
 * 
 * @param arr 
 * @param x_len 
 * @param y_len 
 * @param filename 
 * @param overwrite Whether or not to overwrite an existing file. If false
 * will increment a counter at the end of the filename
 * @return true 
 * @return false 
 */
bool write_arr_to_file(const bool *arr, int x_len, int y_len, const std::string &filename, bool overwrite=false);

} /* namespace file */