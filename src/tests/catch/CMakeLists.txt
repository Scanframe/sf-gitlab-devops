# Set the target name using the project name as a base name.
set(TEST_TARGET "${SF_TEST_NAME_PREFIX}${PROJECT_NAME}-test-catch")

# Make Catch2::Catch2 library available compatible with v3.5.2.
find_package(SfCatch2 3.5.2 CONFIG REQUIRED)

# Make nlohmann_json::nlohmann_json library available.
find_package(SfJson CONFIG REQUIRED)

# Find the test sources.
file(GLOB TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/test-*")

# Tests need to be added as executables first
Sf_AddExecutable("${TEST_TARGET}")

# Adds the compiler and linker options for coverage.
# Normally not for a test application but now for demo purposes.
Sf_AddTargetForCoverage("${TEST_TARGET}")

target_sources("${TEST_TARGET}" PRIVATE main.cpp ${TEST_SOURCES})

target_link_libraries("${TEST_TARGET}" PRIVATE Sf::Hello)

target_include_directories("${TEST_TARGET}" PRIVATE "../..")

# Sets the extension of the generated binary.
Sf_SetTargetSuffix("${TEST_TARGET}")

# Explicitly tell the compiled code the QT libraries are included.
#target_compile_definitions(${TEST_TARGET} PRIVATE TARGET_QT)

# Should be linked to the main library, as well as the Catch2 testing and nlohmann_json library.
target_link_libraries(${TEST_TARGET} PRIVATE Catch2::Catch2 nlohmann_json::nlohmann_json)

# Add the ctest application.
Sf_AddTest("${TEST_TARGET}" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/..")

# Make sure this test is executed before coverage test.
Sf_AddAsCoverageTest("${TEST_TARGET}")


