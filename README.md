# hip-game-of-life

This has been created to run on AMD graphics cards, and may serve as a fairly simple demonstration of
compiling and running Cuda on AMD.

# Compiling
Requires:
* hipify-clang (a tool for transpiling cuda to hip)
* hipcc (a hip compiler, AMD's closest equivalent to nvcc)
* make

To make the program
```bash
make
```
To make the tests
```bash
make test
```

# Running

Requires an AMD graphics card and ROCm compute drivers installed to run.
You can confirm they are installed correctly with:
```bash
rocminfo
```

hip code can theoretically run on NVidia hardware as well. I don't know
how well this works. It's probably easier to just redo the Makefile with
nvcc instead, and it should run.

To run:
```bash
./life
```

To test:
```bash
./test
```
