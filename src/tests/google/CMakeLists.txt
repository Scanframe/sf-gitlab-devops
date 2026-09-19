# Set the target name using the project name as a base name.
set(TEST_TARGET "${PROJECT_NAME}-test-google")

# Make GoogleTest::GoogleTest library available compatible with 1.15.2.
find_package(SfGoogleTest 1.17.0 CONFIG REQUIRED)

# Find the test sources.
file(GLOB TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/test-*")

# Tests need to be added as executables first
Sf_AddTarget("${TEST_TARGET}" FLAGS test cov SUFFIX COVERAGE)

target_sources("${TEST_TARGET}" PRIVATE main.cpp ${TEST_SOURCES})

target_link_libraries("${TEST_TARGET}" PRIVATE Sf::Hello)

# Should be linked to the main library.
target_link_libraries(${TEST_TARGET} PRIVATE gtest)

# Add the ctest application.
Sf_AddTest("${TEST_TARGET}" "GoogleTest")
