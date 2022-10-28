# Notify that this file was loaded.
message(STATUS "Configuring Linux for compiler version 12")

# Use gcc-12 and g++-12 compilers.
set(CMAKE_C_COMPILER /usr/bin/gcc-12)
set(CMAKE_CXX_COMPILER /usr/bin/g++-12)
