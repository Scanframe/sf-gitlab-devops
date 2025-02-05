#include "global.h"
#include <string>

/**
 * @brief Gets the date-time XML formated.
 * @return Formatted string.
 */
_HWL_FUNC std::string utcTimeString();

/**
 * @brief Exported function from a dynamic library.
 * @param how Determines what string is returned.
 * @return Resulting string.
 */
_HWL_FUNC std::string getHello(int how);

/**
 * @brief Gets the GNU compiler version.
 */
_HWL_FUNC std::string getGCCVersion();

/**
 * @brief Gets the C++ standard used when compiling.
 */
_HWL_FUNC std::string getCppStandardVersion();
