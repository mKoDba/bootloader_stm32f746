# no predefined name for bare metal
# setting this will cause CMake to set CROSS_COMPILING flag
set(CMAKE_SYSTEM_NAME Generic)
# as you wish
set(CMAKE_SYSTEM_VERSION ARM)
# define C/C++ compiler variables
set(CMAKE_C_COMPILER arm-none-eabi-gcc CACHE FILEPATH "C Compiler")
set(CMAKE_CXX_COMPILER arm-none-eabi-g++ CACHE FILEPATH "CXX Compiler")
set(ARM_OPTIONS -mcpu=cortex-m7 -mfloat-abi=soft)

add_compile_options(
  ${ARM_OPTIONS}
  -fmessage-length=0
  -funsigned-char
  -ffunction-sections
  -fdata-sections
# following two flags will disable C++ exceptions
  -fno-exceptions
  -fno-unwind-tables
# disable RTTI
  -fno-rtti
  -MMD
  -MP
)

add_compile_definitions(
  STM32F746xx
  USE_FULL_ASSERT
  $<$<CONFIG:DEBUG>:OS_USE_TRACE_SEMIHOSTING_STDOUT>
  $<$<CONFIG:DEBUG>:OS_USE_SEMIHOSTING>
)

add_link_options(
  ${ARM_OPTIONS}
  # TODO[mario.kodba 25.12.21]: remove this when configurations used
  --specs=nosys.specs
  $<$<CONFIG:DEBUG>:--specs=nosys.specs>
  $<$<CONFIG:RELEASE>:--specs=nosys.specs>
  $<$<CONFIG:DEBUG>:-u_printf_float>
  $<$<CONFIG:DEBUG>:-u_scanf_float>
  -nostartfiles
  LINKER:--gc-sections
  LINKER:--build-id
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)