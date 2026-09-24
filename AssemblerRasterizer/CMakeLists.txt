cmake_minimum_required(VERSION 3.20)
project(AssemblerRasterizer)

enable_language(ASM_MASM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(AssemblerRasterizer src/main.cpp src/asm_rast.asm src/asm_math.asm)
