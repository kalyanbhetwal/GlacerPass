cmake_minimum_required(VERSION 3.12)
project(Skeleton)

# LLVM uses C++17.
set(CMAKE_CXX_STANDARD 17)

set(LLVM_DIR "/Users/kb/Documents/myllvmfor-msp430/llvm-install/lib/cmake/llvm" CACHE PATH "LLVM CMake path" FORCE)



# Load LLVMConfig.cmake. If this fails, consider setting `LLVM_DIR` to point
# to your LLVM installation's `lib/cmake/llvm` directory.
find_package(LLVM REQUIRED CONFIG)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

# Include the part of LLVM's CMake libraries that defines
# `add_llvm_pass_plugin`.
include(AddLLVM)

# Use LLVM's preprocessor definitions, include directories, and library search
# paths.
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

# Our pass lives in this subdirectory.
add_subdirectory(skeleton)
