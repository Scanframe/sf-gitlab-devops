
set(CTEST_PROJECT_NAME "Trial-DevOps")
set(CTEST_NIGHTLY_START_TIME "01:00:00 UTC")

# CDash server to submit results (used by client)

set(CTEST_DROP_METHOD https)
set(CTEST_DROP_SITE "cdash.scanframe.com")
set(CTEST_DROP_LOCATION "/submit.php?project=Trial-DevOps")
set(CTEST_DROP_SITE_CDASH TRUE)
set(CTEST_DROP_SITE_PASSWORD "9c7310ae191c88aebad212f79c2d0b5b")
set(CTEST_DROP_SITE_USER "devops")
set(CTEST_SUBMIT_URL "https://cdash.scanframe.com/submit.php?project=Trial-DevOps")
set(_auth_token "51467a775376e1b85ea24e145f76c932")
set(CTEST_SOURCE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")
set(CTEST_BINARY_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
set(CTEST_COMMAND "${CMAKE_CURRENT_BINARY_DIR}")

#ctest_submit(HTTPHEADER "Authorization: Bearer 51467a775376e1b85ea24e145f76c932")
#[[
ctest_submit(
	SUBMIT_URL "https://cdash.scanframe.com/submit.php?project=Trial-DevOps"
	HTTPHEADER "Authorization: Bearer 51467a775376e1b85ea24e145f76c932"
)
]]



