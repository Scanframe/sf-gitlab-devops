# Set the target name using the project name as a base name.
set(TEST_TARGET "${PROJECT_NAME}-test")

# Make Catch2::Catch2 library available.
find_package(SfCatch2 CONFIG REQUIRED)

# Make nlohmann_json::nlohmann_json library available.
find_package(SfJson CONFIG REQUIRED)

# Find the test sources.
file(GLOB TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/test-*")

# Tests need to be added as executables first
Sf_AddExecutable(${TEST_TARGET})

target_sources(${TEST_TARGET} PRIVATE main.cpp ${TEST_SOURCES})

# Sets the extension of the generated binary.
Sf_SetTargetSuffix("${TEST_TARGET}")

# Explicitly tell the compiled code the QT libraries are included.
#target_compile_definitions(${TEST_TARGET} PRIVATE TARGET_QT)

# Should be linked to the main library, as well as the Catch2 testing and nlohmann_json library.
target_link_libraries(${TEST_TARGET} PRIVATE Catch2::Catch2 nlohmann_json::nlohmann_json)

# If you register a test, then ctest and cmake test will run it.
# You can also run examples and check the output, as well.
add_test(NAME "con-${TEST_TARGET}" COMMAND "${TEST_TARGET}")

