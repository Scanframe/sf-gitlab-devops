# Notify that this file was loaded.
message(STATUS "Configuring Linux for latest compiler version")

# When passed here for the first time safe the directory location.
if (DEFINED SfMacros_DIR)
	set(Sf_FindLatestCompilerDir "${SfMacros_DIR}")
endif()

function(Sf_FindLatestCompiler VarOut Prefix)
	execute_process(COMMAND "bash" "${Sf_FindLatestCompilerDir}/LinuxCompiler.sh" "${Prefix}" OUTPUT_VARIABLE _Result RESULT_VARIABLE _ExitCode)
	message(STATUS "(${Prefix}): ${_Result}")
	# Validate the exit code.
	if (_ExitCode GREATER "0")
		message(FATAL_ERROR "Failed execution EitCode(${_ExitCode}) ... ")
	endif ()
	set(${VarOut} "${_Result}" PARENT_SCOPE)
endfunction()

Sf_FindLatestCompiler(CMAKE_C_COMPILER "gcc")
Sf_FindLatestCompiler(CMAKE_CXX_COMPILER "g++")
