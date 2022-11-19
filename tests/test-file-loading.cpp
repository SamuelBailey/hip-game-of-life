#include "catch_amalgamated.hpp"
#include "../read-file.h"

struct Position{
    int x;
    int y;
};

bool pos_in_arr(Position pos, Position* pos_arr, int pos_arr_len) {
    for (int i = 0; i < pos_arr_len; i++) {
        if (pos.x == pos_arr[i].x && pos.y == pos_arr[i].y) {
            return true;
        }
    }
    return false;
}

TEST_CASE("load file") {
    const int X_LEN = 10;
    const int Y_LEN = 10;
    const int ARR_LEN = 5;
    Position pos_arr[ARR_LEN] = {
        {2, 2},
        {3, 3},
        {1, 4},
        {2, 4},
        {3, 4}
    };

    int x, y;
    auto[succ, arr] = file::read_into_arr("tests/data/test1.txt", x, y);

    REQUIRE(succ);
    REQUIRE(x == X_LEN);
    REQUIRE(y == Y_LEN);

    for (int j = 0; j < Y_LEN; j++) {
        for (int i = 0; i < X_LEN; i++) {
            if (pos_in_arr({i, j}, pos_arr, ARR_LEN)) {
                REQUIRE(arr[i + (j * X_LEN)]);
            } else {
                REQUIRE_FALSE(arr[i + (j * X_LEN)]);
            }
        }
    }
}