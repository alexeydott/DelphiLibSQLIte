/*
 * Single translation unit for Delphi static linking.
 *
 * Delphi's linkers do not accept the compiler TLS segments emitted by the
 * Embarcadero C compilers for SQLCipher's xoshiro state. The state is used for
 * memory wiping and diagnostics, not for cryptographic key generation, so the
 * static build uses process-local storage here.
 */
#if defined(__BORLANDC__) || defined(__CODEGEARC__) || defined(__clang__)
#  undef _MSC_VER
#  define __thread
#endif

#include "sqlite3.c"
