cmake_minimum_required(VERSION 3.2)

project(__PROJECT-NAME__)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O3")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR})

set(BIN_DIR ${PROJECT_SOURCE_DIR}/bin)
set(INC_DIR ${PROJECT_SOURCE_DIR}/include)

include_directories(
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/__PROJECT-NAME__>
    $<INSTALL_INTERFACE:include/__PROJECT-NAME__>
)

include_directories(${INC_DIR})

if(NOT MSVC)
    add_compile_options(-Wall -Wextra -Werror -Wpointer-arith -Wcast-qual
        -Wno-missing-braces -Wempty-body -Wno-error=uninitialized -Wunused-function
        -Wno-error=deprecated-declarations -pedantic-errors -pedantic)
endif()

add_subdirectory(src)
