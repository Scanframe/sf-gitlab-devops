# Test configuration
include(${CTEST_SCRIPT_DIRECTORY}/CTestConfig.cmake)

# General settings
site_name(CTEST_SITE)
set(CTEST_BUILD_NAME "linux-x86_64-gcc")
set(CTEST_SOURCE_DIRECTORY "${CTEST_SCRIPT_DIRECTORY}/src")
set(CTEST_BINARY_DIRECTORY "${CTEST_SCRIPT_DIRECTORY}/ctest")
#set(CTEST_BINARY_DIRECTORY "${CTEST_SCRIPT_DIRECTORY}/bin/lnx64")

# Build settings
set(CTEST_CMAKE_GENERATOR Ninja)
set(CTEST_CONFIGURATION_TYPE RelWithDebInfo)
set(configureOpts
	"-DCMAKE_CXX_FLAGS_INIT=--coverage"
	#"-DCMAKE_PREFIX_PATH=/public/Qt/host-qt6.2.4"
	)

# Coverage settings
set(CTEST_COVERAGE_COMMAND gcov)
set(CTEST_COVERAGE_EXTRA_FLAGS "--demangled-names")
set(CTEST_CUSTOM_COVERAGE_EXCLUDE "_autogen;machine/tests")

# Step 1 - Clean previous pipeline run
ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

# Step 2 - Configure
#ctest_start(Experimental)
ctest_start(Nightly)
ctest_configure(OPTIONS "${configureOpts}")
ctest_submit(PARTS Start Configure)

# Step 3 - Build
ctest_build(PARALLEL_LEVEL 16)
ctest_submit(PARTS Build)

# Step 4 - Run unit tests
ctest_test(PARALLEL_LEVEL 16)
ctest_submit(PARTS Test)

# Step 5 - Collect coverage information
ctest_coverage()
ctest_submit(PARTS Coverage Done)