cmake_minimum_required(VERSION 3.2)
project(__MAIN__)

set(SOURCE_FILES __MAIN__.cc)

add_executable(__PROJECT-NAME__ ${SOURCE_FILES})
install(TARGETS __PROJECT-NAME__ DESTINATION ${BIN_DIR})

add_custom_target(run
    COMMAND "${CMAKE_CURRENT_BINARY_DIR}/__PROJECT-NAME__"
    COMMENT "Running ${CMAKE_CURRENT_BINARY_DIR}/__PROJECT-NAME__"
    DEPENDS __PROJECT-NAME__)
add_dependencies(run __PROJECT-NAME__)
