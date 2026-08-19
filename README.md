# DelphiLibSQLite

DelphiLibSQLite is a static Delphi binding for SQLite and SQLCipher on Windows. It is intended for Delphi applications that need SQLite + Cipher API without loading dll's: all dependency compiled into OBJ files and linked through `sqlite3.static.pas`.

## Features

- static SQLCipher builds for Win32 and Win64;
- cryptographic profiles:
  - CNG/bcrypt, with dynamic `bcrypt.dll` loading by default;
  - OpenSSL 3.6.1 through the DelphiLibOpenSSL submodule;
- SQLCipher encryption API: key, rekey, cipher pragmas and encryption error handling;
- SQLite C API Pascal declarations in `sqlite3.common.pas` and `sqlite3.static.pas`;
- extended SQLite API and static SQLite extensions through `sqlite3ext.pas`;
- `SQLITE_ENABLE_NORMALIZE`;
- FTS3/FTS5, RTREE, JSON, Geopoly, DBSTAT, DBPAGE, statement virtual table and other build-profile features;
- static SQLite extensions included directly in the OBJ files;
- SQLite Session/Changeset API;
- FireDAC adapter with QueryInterface-based Session access;
- DUnit tests and console demonstration applications.

## Session API

[`sqlite.session.pas`](sqlite.session.pas) provides a Delphi facade over the SQLite Session Module:

- session creation and deletion;
- table attach and table-filter callbacks;
- capture and indirect-change control;
- object configuration, `diff`, memory usage and changeset size;
- changesets and patchsets, including streaming variants;
- operation iterator, primary-key bitmap, old/new/conflict values and foreign-key conflicts;
- changeset apply v1/v2/v3 with table filters, conflict callbacks and rebase data;
- streaming apply, invert, concat and rebase;
- changegroups: schema, add, patchset mode, output and manual operation building with integer, text, double, NULL and blob values;
- rebaser and streaming rebase.

The low-level functions are declared under `SQLITE_ENABLE_SESSION` (enabled in SQLite). Session builds enable both `SQLITE_ENABLE_SESSION` and `SQLITE_ENABLE_PREUPDATE_HOOK`.

## Extensions Included in OBJ Files

The distributed OBJ files include and register these static SQLite extensions:

- `memvfs`;
- `sqlar`;
- `unionvtab`;
- `csv`;
- `vsv`;
- `zipfile`;
- `fileio`;
- `compress`;
- `closure`;
- `carray`;
- `eval`;
- `dbdump`;
- `zorder`;
- `unicode` (adapted from [nalgeon/sqlean](https://github.com/nalgeon/sqlean/blob/main/docs/unicode.md));
- `uuid`;
- `base64`;
- `base85`.

The corresponding extensions use `SQLITE_*_STATIC` compile-time defines. The static build also defines `SQLITE_OMIT_FILE_IO_EXTENTION=1` for the current file-I/O configuration. The extension ABI and `sqlite3_api_routines` structure are available through [`sqlite3ext.pas`](sqlite3ext.pas).

## FireDAC

[`FireDAC.Phys.SQLiteWrapper.SQLCipher.pas`](FireDAC.Phys.SQLiteWrapper.SQLCipher.pas) contains:

- the static `TSQLiteLibSQLCipherStat` implementation;
- `IFireDACSQLiteSession`;
- `TFireDACSQLiteSession`, bound to an already-open `TFDConnection`;
- regular and streaming apply, v2/v3 apply, changegroup, rebaser and streaming-buffer configuration.

The QueryInterface usage example is available in [`examples/FireDACSQLiteSessionDemo.dpr`](examples/FireDACSQLiteSessionDemo.dpr).

## Requirements

- Windows;
- Embarcadero RAD Studio 23.0 is recommended; RAD Studio 22.0 is supported;
- initialized submodules:
  - `externals/sqlcipher`;
  - `externals/libopenssl` for the OpenSSL profile;
- prepared SQLCipher amalgamation and zlib headers;
- prepared OpenSSL 3.6.1 headers through DelphiLibOpenSSL for the OpenSSL profile.

Initialize external sources with:

```bat
git submodule update --init --recursive
```

## Building OBJ Files

The main build script is [`scripts/build_sqlcipher_obj.bat`](scripts/build_sqlcipher_obj.bat).

By default it builds Win32/Win64 CNG objects with dynamic bcrypt loading:

```bat
scripts\build_sqlcipher_obj.bat
```

Profile examples:

```bat
scripts\build_sqlcipher_obj.bat all cng dynamic
scripts\build_sqlcipher_obj.bat all cng static
scripts\build_sqlcipher_obj.bat all openssl
scripts\build_sqlcipher_obj.bat win64 openssl
```

Final link objects:

```text
sqlite3_win32_cng.obj
sqlite3_win64_cng.obj
sqlite3_win32_ossl.obj
sqlite3_win64_ossl.obj
```

Profile-specific copies are stored under `obj/sqlcipher/<profile>/<platform>/`. OBJ files are part of the repository. Compiler dependency files and other intermediate results are ignored.

## Tests

The test runners use RAD Studio 23.0 and automatically fall back to 22.0 when 23.0 is unavailable.

Core API:

```bat
tests\run_sqlcipher_tests.bat all cng dynamic
tests\run_sqlcipher_tests.bat all openssl dynamic
```

Session API:

```bat
tests\run_sqlite_session_tests.bat all cng dynamic
tests\run_sqlite_session_tests.bat all openssl dynamic
```

FireDAC wrapper:

```bat
tests\run_firedac_wrapper_tests.bat all cng dynamic
tests\run_firedac_wrapper_tests.bat all openssl dynamic
```

Ciphered reference database:

```bat
tests\run_ciphered_reference_tests.bat win32 cng dynamic
```

The `tests/data/perm_krai.sqlite` fixture is used by SpatiaLite, cipher-reference and integration Session tests. If the file is unavailable, dependent tests report `Skipped` instead of failing.

## SQLite API Coverage

Coverage is split into these layers:

1. `sqlite3.common.pas` — common SQLite/SQLCipher types, constants, callback ABI and declarations.
2. `sqlite3.static.pas` — static SQLite, SQLCipher, Session Module and streaming API exports for the configured SQLCipher build.
3. `sqlite3ext.pas` — the SQLite extension ABI and `sqlite3_api_routines` layout.
4. `sqlite.session.pas` — high-level Delphi classes for the complete Session/Changeset workflow.
5. `FireDAC.Phys.SQLiteWrapper.SQLCipher.pas` — FireDAC and QueryInterface integration.

The tests cover database lifecycle, SQL preparation and execution, metadata, error handling, extensions, SpatiaLite, encryption/rekey, Session changesets, filters, merge, rollback, streaming and FireDAC integration. The complete list of enabled SQLite compile-time options is maintained in `scripts/build_sqlcipher_obj.bat`.

## Project Layout

```text
sqlite3.common.pas                         common types and constants
sqlite3.static.pas                         static SQLite/SQLCipher exports
sqlite3ext.pas                             SQLite extension ABI
sqlite.session.pas                         Delphi Session API facade
FireDAC.Phys.SQLiteWrapper.SQLCipher.pas   FireDAC wrapper
scripts/                                   OBJ build scripts
obj/                                       profile-specific OBJ files
tests/                                     DUnit fixtures and runners
examples/                                  console examples
externals/                                 git submodules
```
