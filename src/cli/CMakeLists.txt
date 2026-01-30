# //! [all]
# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.29)
# Set the project name.
project("hello-world"
	DESCRIPTION "Hello world application"
	LANGUAGES CXX
)

# Set the actual executable target.
Sf_AddExecutable("${PROJECT_NAME}")

# Import the library static or dynamic.
target_link_libraries(${PROJECT_NAME} PRIVATE Sf::Hello)

# Add custom target to report resource stored versions.
Sf_AddExifTarget("${PROJECT_NAME}")

# RC-files only seem to be compiled when building using MingW.
target_sources(${PROJECT_NAME} PRIVATE main.cpp template.h)

# Sets the extension of the generated binary.
Sf_SetTargetSuffix("${PROJECT_NAME}")

# Add version resource to the target.
Sf_AddVersionResource("${PROJECT_NAME}")
# //! [all]
