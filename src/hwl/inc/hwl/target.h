/*
Making it easier to build libraries for the various targets and platforms.
Defines these with true (1) or false (0):
 * IS_GCC > GNU compiler detected.
 * IS_QT > QT compile target is detected.
 * IS_WIN > Windows compile target is detected.

 * IS_AB_TARGET > An application binary is the current target.
 * IS_DL_TARGET > A dynamic library is the current target.
 * IS_SL_TARGET > A static library is the current target.
*/

#pragma once

// Detect usage of the GCC GNU compiler.
#if defined(__GNUC__)
	#define IS_GNU 1
//#pragma GCC visibility
#else
	#define IS_GNU 0
#endif

// Check when the MSVC compiler is active for a Windows target.
#if defined(_MSC_VER)
	#define IS_MSVC 1
#else
	#define IS_MSVC 0
#endif

// Check when a compiler is active for a Windows target.
#if defined(WIN32)
	#define IS_WIN 1
#else
	#define IS_WIN 0
#endif

// Determine if the build target a dynamically shared library.
#if defined(TARGET_DYNAMIC_LIB)
	#define IS_DL_TARGET 1
#else
	#define IS_DL_TARGET 0
#endif

// Determine if the build target a dynamically shared library.
#if defined(TARGET_STATIC_LIB)
	#define IS_SL_TARGET 1
#else
	#define IS_SL_TARGET 0
#endif

// CHeck if an application binary is targeted
#if IS_DL_TARGET || IS_SL_TARGET
	#define IS_AB_TARGET 0
#else
	#define IS_AB_TARGET 1
#endif

// Determine if QT is used in the target.
#if defined(TARGET_QT) || defined(QT_VERSION)
	#define IS_QT 1
#else
	#define IS_QT 0
#endif

#if IS_WIN
	#if IS_GNU
		#define TARGET_EXPORT __attribute__ ((dllexport))
		#define TARGET_IMPORT __attribute__ ((dllimport))
		#define TARGET_HIDDEN __attribute__((visibility("hidden")))
	#elif IS_MSVC
		#define TARGET_EXPORT __declspec(dllexport)
		#define TARGET_IMPORT __declspec(dllimport)
		#define TARGET_HIDDEN
	#else
		#error "Failed to detect compiler."
	#endif
#else
	#define TARGET_EXPORT __attribute__((visibility("default")))
	#define TARGET_IMPORT
	#define TARGET_HIDDEN __attribute__((visibility("hidden")))
#endif

// Report current targeted result.
#if defined(REPORT_TARGET)
// Report when GNU GCC is used.
	#if IS_GNU
		#pragma message ("GNU compiler")
	#endif
// Report the Windows target.
	#if IS_WIN
		#pragma message ("Windows build")
	#endif
// Report the GNU C++ compiler.
	#if IS_GNU
		#pragma message ("GNU C++ Compiler")
	#endif
// Report the Visual C++ compiler.
	#if IS_MSVC
		#pragma message ("Visual C++ Compiler")
	#endif
// Report the QT is linked.
	#if IS_QT
		#pragma message ("Target: QT")
	#endif
// Report the target is a dynamically library.
	#if IS_DL_TARGET
		#pragma message ("Target: Shared Library")
	#endif
// Report the target is a static library (archive).
	#if IS_SL_TARGET
		#pragma message ("Target: Static Library")
	#endif
#endif // REPORT_TARGET
