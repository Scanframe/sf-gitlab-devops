#include "global.h"
#include <string>

/**
 * Exported function from a dynamic library.
 * @param how Determines what string is returned.
 * @return Resulting string.
 */
_HWL_FUNC std::string getHello(int how);
