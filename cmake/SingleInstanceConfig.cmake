# FetchContent added in CMake 3.11, downloads during the configure step
include(FetchContent)
# Import SingleInstance library.
FetchContent_Declare(
	SingleInstance
	GIT_REPOSITORY https://github.com/Scanframe/SingleInstance.git
#	GIT_TAG v????
)
# Adds SingleInstance::SingleInstance
FetchContent_MakeAvailable(SingleInstance)
