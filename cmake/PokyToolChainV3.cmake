# Directory to find poky toolchains.
set(_RootDir "${_InstallDir}/sysroots/i686-poky-linux")
set(_BaseDir "${_InstallDir}/sysroots/x86_64-pokysdk-linux/usr/bin/i686-poky-linux")
set(_CompilerPrefix "i686-poky-linux-")
# Assemble path to tool chain file.
set(_CmakeFile "${CMAKE_CURRENT_BINARY_DIR}/.vialis/V_Poky3ToolChain.cmake")
# Find the cross compiler
find_program(_CrossCompiler "${_BaseDir}/${_CompilerPrefix}gcc")
if (NOT EXISTS "${_CrossCompiler}")
	message(FATAL_ERROR "Poky 3.1.2 cross compiler not found at: ${_BaseDir}/${_CompilerPrefix}gcc")
	return()
endif ()
# Prevent it from getting into the CMakeCache.txt
unset(_CrossCompiler CACHE)
file(WRITE "${_CmakeFile}" "#### Created by function '${CMAKE_CURRENT_FUNCTION}'\n")
file(APPEND "${_CmakeFile}" "

set(CMAKE_SYSTEM_NAME Linux)

# Value passed to '--sysroot' (https://cmake.org/cmake/help/latest/variable/CMAKE_SYSROOT.html)
set(CMAKE_SYSROOT \"${_RootDir}\")

# Use poky compilers.
set(CMAKE_C_COMPILER \"${_BaseDir}/${_CompilerPrefix}gcc\")
set(CMAKE_CXX_COMPILER \"${_BaseDir}/${_CompilerPrefix}g++\")
set(CMAKE_RC_COMPILER \"\")
set(CMAKE_RANLIB \"${_BaseDir}/${_CompilerPrefix}ranlib\")
set(CMAKE_AR \"${_BaseDir}/${_CompilerPrefix}ar\")

# Cache the compiler flags and initialize them using an environment variable.
set(CMAKE_C_FLAGS $ENV{CFLAGS} CACHE STRING \"\" FORCE)
set(CMAKE_CXX_FLAGS $ENV{CXXFLAGS} CACHE STRING \"\" FORCE)

# Additional compiler and linker flags
set(CMAKE_C_FLAGS \"${CMAKE_C_FLAGS} -m32 -march=i686 -mtune=generic -fstack-protector-strong\")
set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -m32 -march=i686 -mtune=generic -fstack-protector-strong\")

set(CMAKE_FIND_ROOT_PATH \"${_BaseDir}\")
# Search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# Adjust the default behavior of the find commands:
#   search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

")
set(CMAKE_TOOLCHAIN_FILE "${_CmakeFile}" PARENT_SCOPE)
