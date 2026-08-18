# Set the target name using the project name as a base name.
set(TEST_TARGET "${SF_TEST_NAME_PREFIX}${PROJECT_NAME}-test-catch")

# Make Catch2::Catch2 library available compatible with v3.5.2.
find_package(SfCatch2 CONFIG REQUIRED)

# Make nlohmann_json::nlohmann_json library available.
find_package(SfJson CONFIG REQUIRED)

# Find the test sources.
file(GLOB TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/test-*")

# Tests need to be added as executables first
Sf_AddTarget("${TEST_TARGET}" FLAGS test cov SUFFIX COVERAGE)

target_sources("${TEST_TARGET}" PRIVATE main.cpp ${TEST_SOURCES})

target_link_libraries("${TEST_TARGET}" PRIVATE Sf::Hello)

target_include_directories("${TEST_TARGET}" PRIVATE "../..")

# Should be linked to the main library, as well as the Catch2 testing and nlohmann_json library.
target_link_libraries(${TEST_TARGET} PRIVATE Catch2::Catch2 nlohmann_json::nlohmann_json)

# Add the as a test application under the label 'Catch2'.
Sf_AddTest("${TEST_TARGET}" "Catch2")
