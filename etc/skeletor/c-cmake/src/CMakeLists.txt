cmake_minimum_required(VERSION 3.2)
project(__MAIN__)

set(SOURCE_FILES __MAIN__.cc)

add_executable(__PROJECT-NAME__ ${SOURCE_FILES})
install(TARGETS __PROJECT-NAME__ DESTINATION ${BIN_DIR})

add_custom_target(run
    COMMAND "${CMAKE_CURRENT_BINARY_DIR}/__MAIN__"
    COMMENT "Running ${CMAKE_CURRENT_BINARY_DIR}/__MAIN__"
    DEPENDS __MAIN__)
