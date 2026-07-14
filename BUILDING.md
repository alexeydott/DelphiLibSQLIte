# Building SQLCipher Objects

This repository links SQLCipher into `sqlite3.static.pas` through provider-specific platform objects:

- `sqlite3_win32_cng.obj`
- `sqlite3_win64_cng.obj`
- `sqlite3_win32_ossl.obj`
- `sqlite3_win64_ossl.obj`

External sources are provided as submodules:

- `externals/sqlcipher` from `https://github.com/alexeydott/sqlcipher`
- `externals/libopenssl` from `https://github.com/alexeydott/DelphiLibOpenSSL`

Initialize them after cloning:

```bat
git submodule update --init --recursive
```

## Build

Default build is Win32 + Win64, SQLCipher CNG provider, dynamic `bcrypt.dll` loading:

```bat
scripts\build_sqlcipher_obj.bat
```

Specific profiles:

```bat
scripts\build_sqlcipher_obj.bat win32 cng dynamic
scripts\build_sqlcipher_obj.bat win64 cng static
scripts\build_sqlcipher_obj.bat win64 openssl
```

The scripts use RAD Studio from `RAD_STUDIO_ROOT`. If it is not set, they prefer:

```bat
D:\Embarcadero RAD Studio\23.0
```

and fall back to:

```bat
D:\Embarcadero RAD Studio\22.0
```

Set `RAD_STUDIO_ROOT` explicitly to force either version.

It consumes the prepared SQLCipher amalgamation under:

```text
externals\sqlcipher\build\x86\amalgamation\sqlite3.c
externals\sqlcipher\build\x64\amalgamation\sqlite3.c
```

Use `--rebuild-amalgamation` only when the SQLCipher amalgamation must be regenerated; that delegates to the SQLCipher submodule script and requires its Tcl/Perl/MSVC toolchain.

The actual C translation unit is `scripts\sqlite3_link.c`. It includes the SQLCipher amalgamation, producing one object file per platform and provider. `sqlite3.static.pas` selects the correct `$L sqlite3_win*_cng.obj` or `$L sqlite3_win*_ossl.obj` file based on `SQLITE3_CNG_CIPHER` / `SQLITE3_OpenSSL3_CIPHER`. The SQLCipher submodule's prepared amalgamation already includes `ext\misc\normalize.c`.

The translation unit also disables Embarcadero-generated TLS for SQLCipher's xoshiro state. Delphi's Win32/Win64 linkers do not accept the compiler TLS sections emitted by BCC32/BCC64 in these static objects.

## Compiler Defines

The shared SQLite/SQLCipher C defines are:

```text
NDEBUG
USEPACKAGES
__STDC__=1
__MT__=1
SQLITE_OMIT_AUTOINIT=1
SQLITE_ENABLE_API_ARMOR=1
SQLITE_THREADSAFE=1
SQLITE_THREAD_OVERRIDE_LOCK=-1
SQLITE_HAS_CODEC=1
SQLITE_TEMP_STORE=2
SQLITE_MAX_TRIGGER_DEPTH=100
SQLITE_EXTRA_INIT=sqlcipher_extra_init
SQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown
```

Feature and extension defines are:

```text
SQLITE_ENABLE_FTS3=1
SQLITE_ENABLE_RTREE=1
SQLITE_ENABLE_GEOPOLY=1
SQLITE_ENABLE_JSON1=1
SQLITE_ENABLE_STMTVTAB=1
SQLITE_ENABLE_DBPAGE_VTAB=1
SQLITE_ENABLE_DBSTAT_VTAB=1
SQLITE_INTROSPECTION_PRAGMAS=1
SQLITE_ENABLE_COLUMN_METADATA=1
SQLITE_ENABLE_FTS5=1
SQLITE_ENABLE_SESSION=1
SQLITE_ENABLE_PREUPDATE_HOOK=1
SQLITE_MEMVFS_STATIC=1
SQLITE_SQLAR_STATIC=1
SQLITE_UNIONVTAB_STATIC=1
SQLITE_CSV_STATIC=1
SQLITE_VSV_STATIC=1
SQLITE_ZIPFILE_STATIC=1
SQLITE_FILEIO_STATIC=1
SQLITE_COMPRESS_STATIC=1
SQLITE_CLOSURE_STATIC=1
SQLITE_ENABLE_CARRAY=1
SQLITE_CARRAY_STATIC=1
SQLITE_EVAL_STATIC=1
SQLITE_DB_DUMP_STATIC=1
SQLITE_ZORDER_STATIC=1
SQLITE_ENABLE_UNICODE=1
SQLITE_ENABLE_UNICODE_STATIC=1
SQLITE_UUID_STATIC=1
SQLITE_OMIT_FILE_IO_EXTENTION=1
SQLITE_SOUNDEX=1
SQLITE_BASE64_STATIC=1
SQLITE_BASE85_STATIC=1
```

Because `SQLITE_OMIT_AUTOINIT=1` is enabled, Delphi callers and tests must call `sqlite3_initialize` before normal SQLite use and `sqlite3_shutdown` at teardown.

## Crypto Providers

`cng dynamic` is the default and compiles with:

```text
SQLCIPHER_CRYPTO_CNG
SQLCIPHER_CRYPTO_CNG_DYNAMIC
```

It produces:

```text
sqlite3_win32_cng.obj
sqlite3_win64_cng.obj
```

All build profiles also omit SQLCipher's default C-runtime logging and DLL entry point:

```text
SQLCIPHER_OMIT_LOG
SQLCIPHER_OMIT_LOG_DEVICE
SQLCIPHER_OMIT_DEFAULT_LOGGING
SQLCIPHER_OMIT_DLLMAIN
```

This keeps the statically linked Delphi unit away from `stderr`/`vfprintf` C-runtime logging paths and from DLL lifecycle callbacks that do not apply to `sqlite3.static.pas`.

`cng static` compiles with:

```text
SQLCIPHER_CRYPTO_CNG
```

`openssl` compiles SQLCipher with:

```text
SQLCIPHER_CRYPTO_OPENSSL
```

It produces:

```text
sqlite3_win32_ossl.obj
sqlite3_win64_ossl.obj
```

For Delphi linking, `sqlite3.static.pas` must see `SQLITE3_OpenSSL3_CIPHER` and must not see `SQLITE3_CNG_CIPHER`. The test runner does this through `tests\defines\openssl3\user_defines.inc`.

`DelphiLibOpenSSL` contains OpenSSL 3.6.1 objects and `libOpenSSL3.pas`. If building the OpenSSL profile, ensure that `libOpenSSL3.pas` is configured for `OPENSSL_3X` and for the object format you want to link.

The SQLCipher OpenSSL OBJ build also needs generated OpenSSL public headers such as `crypto.h`, `configuration.h`, and `opensslv.h`. The raw `openssl-3.6.1.zip` contains `.h.in` templates, so run the DelphiLibOpenSSL OpenSSL 3.x preparation/build step before `scripts\build_sqlcipher_obj.bat ... openssl`.

## Tests

Build and run default tests:

```bat
tests\run_sqlcipher_tests.bat
```

The test runners use the same RAD Studio selection as the object builder: `RAD_STUDIO_ROOT`, then RAD Studio 23.0, then RAD Studio 22.0. This applies to the Delphi compiler, DUnit sources, and FireDAC sources used by the wrapper fixture.

Run one platform/profile:

```bat
tests\run_sqlcipher_tests.bat win32 cng dynamic
tests\run_sqlcipher_tests.bat win64 openssl
```

The tests compile a small console runner and verify:

- SQLCipher codec compile options
- SQLite in-memory CRUD
- `pragma cipher_version`
- `sqlite3_normalize`
- encrypted database write/read/reopen behavior
- encrypted database is not readable without `sqlite3_key`
