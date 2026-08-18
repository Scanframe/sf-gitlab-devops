# //! [all]
# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.29)
# Set the project name.
project("hello-world"
	DESCRIPTION "Hello world application"
	LANGUAGES CXX
)

# Set the actual executable target.
Sf_AddTarget("${PROJECT_NAME}" FLAGS cli pack VERSION EXIF SUFFIX)

# Import the library static or dynamic.
target_link_libraries(${PROJECT_NAME} PRIVATE Sf::Hello)

# RC-files only seem to be compiled when building using MingW.
target_sources(${PROJECT_NAME} PRIVATE main.cpp)
# //! [all]
