/**
 * Copyright (c) 2022 Samuel Bailey
 */

#include <fstream>
#include <memory>
#include <tuple>
#include <regex>
#include <iostream>
#include <filesystem>
#include "read-file.h"

/**
 * @brief Tries to read a number from the next line of a currently
 * open file.
 * 
 * @param in_file 
 * @return std::tuple<bool, int> (Success, number)
 */
std::tuple<bool, int> get_number(std::ifstream &in_file) {
    std::string line;

    if (!std::getline(in_file, line))
        return std::make_tuple(false, -1);
    
    // Convert line to x coordinate
    std::regex re("[0-9]+");
    if (!std::regex_match(line, re) || line.length() > 9)
        return std::make_tuple(false, -1);
    
    return std::make_tuple(true, stoi(line));
}

std::tuple<bool, std::unique_ptr<bool[]>>
file::read_into_arr(const std::string &filename, int &x_len, int &y_len) {
    std::ifstream in_file(filename);
    std::string line;

    auto[succ1, x] = get_number(in_file);
    if (!succ1) {
        in_file.close();
        std::cerr << "Unable to read x dimension from input file" << std::endl;
        return std::make_tuple(false, nullptr);
    }
    auto[succ2, y] = get_number(in_file);
    if (!succ2) {
        in_file.close();
        std::cerr << "Unable to read y dimension from input file" << std::endl;
        return std::make_tuple(false, nullptr);
    }

    // Create an array of the desired size
    auto arr = std::make_unique<bool[]>(x * y * sizeof(bool));

    // Loop through lines in the file
    for (int j = 0; j < y; j++) {
        // Make sure there is a line, and that it is at least x characters long
        if (!std::getline(in_file, line) || line.length() < x) {
            in_file.close();
            std::cerr << "Input file line too short" << std::endl;
            return std::make_tuple(false, nullptr);
        }

        for (int i = 0; i < x; i++) {
            switch (line[i]) {
                case EMPTY_CHAR:
                    arr[i + (j*x)] = false;
                    break;
                case FULL_CHAR:
                    arr[i + (j*x)] = true;
                    break;
                default:
                    in_file.close();
                    std::cerr << "Invalid character \"" << line[i] << "\" in input file" << std::endl;
                    return std::make_tuple(false, nullptr);
            }
        }
    }

    in_file.close();

    x_len = x;
    y_len = y;
    return std::make_tuple(true, std::move(arr));
}


bool file::write_arr_to_file(const bool *arr, int x_len, int y_len, const std::string &filepath, bool overwrite) {
    std::filesystem::path file_p = filepath;

    if (!overwrite && std::filesystem::exists(file_p)) {
        std::filesystem::path new_file_p = file_p;
        std::string extension = "";
        if (file_p.has_extension()) {
            extension = file_p.extension();
            file_p = file_p.replace_extension("");
        }

        int suffix_num = 0;
        do {
            new_file_p = file_p.string() + "(" + std::to_string(++suffix_num) + ")" + extension;

        } while (std::filesystem::exists(new_file_p));
        file_p = new_file_p;
    }

    std::ofstream out_file(file_p);
    
    // Write the x and y lengths
    out_file << x_len << std::endl;
    out_file << y_len << std::endl;

    for (int j = 0; j < y_len; j++) {
        std::string line(x_len, EMPTY_CHAR);
        for (int i = 0; i < x_len; i++) {
            if (arr[i + (j * x_len)]) {
                line[i] = FULL_CHAR;
            }
        }
        out_file << line << std::endl;
    }

    std::cout << "Wrote to file: " << file_p << std::endl;
    return true;
}
