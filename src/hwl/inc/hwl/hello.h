#pragma once
#include "global.h"
#include <string>

/**
 * @brief Gets the date-time XML formated.
 * @return Formatted string.
 */
_HWL_FUNC std::string utcTimeString();

/**
 * @brief Checks if QEMU is used to start the application.
 */
_HWL_FUNC bool isQemu();

/**
 * @brief Determines if the application is running using Wine.
 */
_HWL_FUNC bool isWine();

/**
 * @brief Gets the Cpu architecture.
 */
_HWL_FUNC std::string getCpuArchitecture();

/**
 * @brief Exported function from a dynamic library.
 * @param how Determines what string is returned.
 * @return Resulting string.
 */
_HWL_FUNC std::string getHello(int how);

/**
 * @brief Gets the GNU compiler version.
 */
_HWL_FUNC std::string getCompilerVersion();

/**
 * @brief Gets the C++ standard used when compiling.
 */
_HWL_FUNC std::string getCppStandardVersion();

/**
 * Kills/cancels all other thread besides this one.
 * Fixes a problem in the Qt library for Wine.
 */
_HWL_FUNC void killOtherThreads();
