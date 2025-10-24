# C++ Workspace Template

This template provides a ready-to-use Ubuntu 24.04 development environment
with:

- GCC, Clang, and GDB
- CMake and Ninja
- VS Code (via code-server)
- clangd and Native Debug extensions preinstalled

## Building and Running

```bash
g++ -std=c++20 -O2 main.cpp -o app && ./app
```

or with CMake:

```bash
cmake -B build
cmake --build build
./build/app
```