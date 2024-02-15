/*
This include-file determines the way the classes and functions in the
library are exported when they are used as a dynamic or as application and static library.
When building this Dynamic Library then _HWL_PKG (package) should be defined.

_list of the declaration modifiers for types:
	classes:  _HWL_CLASS
	Function: _HWL_FUNC
	Data:     _HWL_DATA

Add compiler definition flags:
	* _HWL_PKG when building a dynamic library (package)
	* _HWL_ARC when including in a compile or using it as an archive.
*/

#pragma once

// Import of defines for this target.
#include "target.h"

// When DL target and the misc PKG is not used the shlib is being build.
#if IS_DL_TARGET && defined(_HWL_PKG)
	#define _HWL_DATA TARGET_EXPORT
	#define _HWL_FUNC TARGET_EXPORT
	#define _HWL_CLASS TARGET_EXPORT
// Is used as an archive so no importing is needed.
#elif defined(_HWL_ARC)
	#define _HWL_DATA
	#define _HWL_FUNC
	#define _HWL_CLASS
// When no flags are defined assume the package is imported.
#else
	#define _HWL_DATA TARGET_IMPORT
	#define _HWL_FUNC TARGET_IMPORT
	#define _HWL_CLASS TARGET_IMPORT
#endif
