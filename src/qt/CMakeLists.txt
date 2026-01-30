# //! [all]
# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.29)
# Set the project name.
project("hello-world-qt" LANGUAGES CXX)

# Enable automatic compiling of Qt related source and resource files.
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(QT NAMES Qt6 Qt5 COMPONENTS Core REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets REQUIRED)

# Set the actual executable target.
Sf_AddExecutable("${PROJECT_NAME}")

# Add custom target to report resource stored versions.
Sf_AddExifTarget("${PROJECT_NAME}")

# Explicitly tell the compiled code the QT libraries are included.
target_compile_definitions(${PROJECT_NAME} PRIVATE TARGET_QT)

# Import static and or dynamic libraries.
target_link_libraries(${PROJECT_NAME} PRIVATE	Sf::Hello Qt::Widgets)

# RC-files only seem to be compiled when building using MingW.
target_sources(${PROJECT_NAME} PRIVATE main.cpp)

# Add this for the headers in the autogen directory made by the *.ui files.
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Sets the extension of the generated binary.
Sf_SetTargetSuffix("${PROJECT_NAME}")

# Add version resource to the target.
Sf_AddVersionResource("${PROJECT_NAME}")
# //! [all]
