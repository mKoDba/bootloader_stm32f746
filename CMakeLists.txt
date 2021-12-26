cmake_minimum_required(VERSION 3.17)
# project name
project(bootloader LANGUAGES C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# define target name for .elf which will be generated
set(TARGET_NAME Application)

message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")

add_compile_options(
  -Wall
  -Wextra
  -Wconversion
  -Wsign-conversion
# -nostdinc ignores standard C include directories
# -nostdinc++ ignores standard C++ include directories
  $<$<CONFIG:DEBUG>:-g3>
  $<$<CONFIG:DEBUG>:-Og>
  $<$<CONFIG:RELEASE>:-O3>
)

add_compile_definitions(
  DEBUG
)

# need to build "Application" first before setting its properties
add_executable(${TARGET_NAME}
    src/startup/startup.c
    src/main.cpp
)
# <target> PROPERTIES <prop> <value> ...
set_target_properties(${TARGET_NAME} PROPERTIES
  SUFFIX .elf
)

target_link_options(${TARGET_NAME} PRIVATE
  -T${CMAKE_SOURCE_DIR}/ld/stm32f746ngh.ld
  LINKER:--print-memory-usage
  LINKER:-Map,${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}.map
)

target_include_directories(${TARGET_NAME} PRIVATE
  src
)

#---------------------- POST BUILD -----------------------------#
add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} ARGS -O binary "$<TARGET_FILE:${TARGET_NAME}>" ${PROJECT_NAME}.bin
        COMMENT "Generating .bin file")
