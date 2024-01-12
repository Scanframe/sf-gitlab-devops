# Directory to find poky toolchains.
set(_RootDir "${_InstallDir}/sysroots/cortexa9hf-neon-poky-linux-gnueabi")
set(_BaseDir "${_InstallDir}/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi")
set(_CompilerPrefix "arm-poky-linux-gnueabi-")
# Assemble path to tool chain file.
set(_CmakeFile "${CMAKE_CURRENT_BINARY_DIR}/.vialis/V_Poky2ToolChain.cmake")
# Find the Windows cross compiler
find_program(_CrossCompiler "${_BaseDir}/${_CompilerPrefix}gcc")
if (NOT EXISTS "${_CrossCompiler}")
	message(FATAL_ERROR "Poky 2.1.2 cross compiler not found at: ${_BaseDir}/${_CompilerPrefix}gcc")
	return()
endif ()
# Prevent it from getting into the CMakeCache.txt
unset(_CrossCompiler CACHE)
file(WRITE "${_CmakeFile}" "#### Created by function '${CMAKE_CURRENT_FUNCTION}'\n")
file(APPEND "${_CmakeFile}" "# CMake toolchain file for Poky 2.1.2 ARM cross-compilation
# CMake toolchain file for Poky 2.1.2 ARM cross-compilation
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Set the cross-compiler and toolchain path
set(CMAKE_C_COMPILER \"${_BaseDir}/${_CompilerPrefix}gcc\")
set(CMAKE_CXX_COMPILER \"${_BaseDir}/${_CompilerPrefix}g++\")
set(CMAKE_RC_COMPILER \"\")
set(CMAKE_RANLIB \"${_BaseDir}/${_CompilerPrefix}ranlib\")
set(CMAKE_AR \"${_BaseDir}/${_CompilerPrefix}ar\")

# Set the sysroot path
set(CMAKE_SYSROOT \"${_RootDir}\")

# Set the default search paths for libraries and headers
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Cache the compiler flags and initialize them using an environment variable.
set(CMAKE_C_FLAGS $ENV{CFLAGS} CACHE STRING \"\" FORCE)
set(CMAKE_CXX_FLAGS $ENV{CXXFLAGS} CACHE STRING \"\" FORCE)

# Additional compiler and linker flags
set(CMAKE_C_FLAGS \"${CMAKE_C_FLAGS} -march=armv7-a -marm -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9\")
set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -march=armv7-a -marm -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9\")
")
set(CMAKE_TOOLCHAIN_FILE "${_CmakeFile}" PARENT_SCOPE)
