unit sqlite3ext;

{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

interface

const
  SQLITE_MIN_API_VERSION  = 3007000;
  SQLITE_VERSION_NUMBER = 3053003;

  {$region ' Text Encodings codes'}
  /// <summary>UTF-8 text encoding code used by SQLite APIs.</summary>
  SQLITE_UTF8 = 1;
  /// <summary>UTF-16 little-endian encoding code.</summary>
  SQLITE_UTF16LE = 2;
  /// <summary>UTF-16 big-endian encoding code.</summary>
  SQLITE_UTF16BE = 3;
  /// <summary>UTF-16 in native byte order.</summary>
  SQLITE_UTF16 = 4;
  /// <summary>“Any encoding”; deprecated.</summary>
  SQLITE_ANY = 5;
  /// <summary>UTF-16 aligned (valid for sqlite3_create_collation only).</summary>
  SQLITE_UTF16_ALIGNED = 8;
  /// <summary>Zero-terminated UTF-8 marker used by internal APIs.</summary>
  SQLITE_UTF8_ZT = 16;
  {$endregion}

  {$region ' Function Flags'}
  /// <summary>The function always returns the same result for the same inputs; enables extra optimizations and use in contexts like partial indexes or generated columns.</summary>
  SQLITE_DETERMINISTIC = $000000800;
  /// <summary>May be invoked only from top-level SQL (not from VIEWs/TRIGGERs nor schema elements like CHECK/DEFAULT/index expressions/partial indexes/generated columns); recommended for functions with side-effects or possible data leaks.</summary>
  SQLITE_DIRECTONLY    = $000080000;
  /// <summary>Function may call sqlite3_value_subtype() on its arguments; disables corner-case optimizations that could otherwise break subtype retrieval.</summary>
  SQLITE_SUBTYPE       = $000100000;
  /// <summary>Function is unlikely to cause problems even if misused (no side-effects, depends only on its inputs); used to allow functions under heightened security settings (trusted_schema=OFF).</summary>
  SQLITE_INNOCUOUS     = $000200000;
  /// <summary>Function may call sqlite3_result_subtype() to associate a subtype with its result; required to ensure subtype is preserved (e.g., in expression indexes).</summary>
  SQLITE_RESULT_SUBTYPE = $001000000;
  /// <summary>Aggregate internally orders the values of its first argument; ordered-set aggregate syntax with a single ORDER BY term may be used (requires -DSQLITE_ENABLE_ORDERED_SET_AGGREGATES).</summary>
  SQLITE_SELFORDER1     = $002000000;
  {$endregion}

  {$region ' Value types codes'}
  /// <summary>64-bit signed integer type code.</summary>
  SQLITE_INTEGER = 1;
  /// <summary>64-bit IEEE floating-point number type code.</summary>
  SQLITE_FLOAT   = 2;
  /// <summary>Text string type code (UTF-8/UTF-16).</summary>
  SQLITE_TEXT    = 3;
  /// <summary>Binary Large Object (BLOB) type code.</summary>
  SQLITE_BLOB    = 4;
  /// <summary>NULL type code.</summary>
  SQLITE_NULL    = 5;
  {$endregion}

  {$region ' Prepare Flags (sqlite3_prepare_v3)'}
  /// <summary>Hint that the prepared statement will be retained and reused many times; enables planner/memory behaviors appropriate for long-lived statements.</summary>
  SQLITE_PREPARE_PERSISTENT = $01;
  /// <summary>No-op; sqlite3_normalized_sql() is available for all prepared statements regardless of this flag since 3.27.0.</summary>
  SQLITE_PREPARE_NORMALIZE  = $02;
  /// <summary>Cause compilation to fail with SQLITE_ERROR if the statement uses any virtual tables.</summary>
  SQLITE_PREPARE_NO_VTAB    = $04;
  /// <summary>Suppress warning/error messages from being sent to the global error log when compiling SQL; useful for "test compile" without polluting logs.</summary>
  SQLITE_PREPARE_DONT_LOG   = $10;
  /// <summary>Treat the SQL text as schema-derived DDL for trusted-schema security checks.</summary>
  SQLITE_PREPARE_FROM_DDL   = $20; // since 3.52.0
  {$endregion}

  {$region ' Destructor flags'}
  /// <summary>Special “no-destructor” sentinel for result_/bind_*: buffer is static and will not be freed by SQLite.</summary>
  SQLITE_STATIC: Pointer = nil;
  /// <summary>Special “make-a-copy” sentinel for result_/bind_*: SQLite copies the buffer immediately and manages its own copy.</summary>
  SQLITE_TRANSIENT: Pointer = Pointer(-1);
  {$endregion}

  {$region ' Serialize / Deserialize flags'}
  /// <summary>Return a direct pointer to the in-memory database without making a copy; only if the database is currently a contiguous in-memory DB created by sqlite3_deserialize().</summary>
  SQLITE_SERIALIZE_NOCOPY = $001;
  /// <summary>Buffer P was allocated with sqlite3_malloc64(); SQLite takes ownership and frees it automatically when done, including on failure.</summary>
  SQLITE_DESERIALIZE_FREEONCLOSE = $01;
  /// <summary>Allow SQLite to grow the database using sqlite3_realloc64(); should be used only together with FREEONCLOSE.</summary>
  SQLITE_DESERIALIZE_RESIZEABLE  = $02;
  /// <summary>Mount the deserialized database read-only.</summary>
  SQLITE_DESERIALIZE_READONLY    = $04;
  {$endregion}

  {$region ' setlk timeout flags'}
  /// <summary>Request blocking on WAL connect until an exclusive-lock checkpoint completes.</summary>
  SQLITE_SETLK_BLOCK_ON_CONNECT = $01; // since 3.50.0
  {$endregion}

  {$region ' CARRAY datatypes'}
  /// <summary>carray() data is 32-bit signed integers.</summary>
  SQLITE_CARRAY_INT32 = 0; // since 3.51.0
  /// <summary>carray() data is 64-bit signed integers.</summary>
  SQLITE_CARRAY_INT64 = 1; // since 3.51.0
  /// <summary>carray() data is doubles.</summary>
  SQLITE_CARRAY_DOUBLE = 2; // since 3.51.0
  /// <summary>carray() data is char* text pointers.</summary>
  SQLITE_CARRAY_TEXT = 3; // since 3.51.0
  /// <summary>carray() data is struct iovec blobs.</summary>
  SQLITE_CARRAY_BLOB = 4; // since 3.51.0
  {$endregion}

  {$region ' Virtual Table Configuration (sqlite3_vtab_config)'}
  /// <summary>Enable/disable constraint support. Called as sqlite3_vtab_config(db, SQLITE_VTAB_CONSTRAINT_SUPPORT, X) where X is non-zero to indicate that the virtual table will return SQLITE_CONSTRAINT from xUpdate when appropriate so that the core can handle conflicts.</summary>
  SQLITE_VTAB_CONSTRAINT_SUPPORT = 1;
  /// <summary>Mark the virtual table implementation as safe for use inside triggers and views; indicates the module has no harmful side-effects and depends only on its inputs.</summary>
  SQLITE_VTAB_INNOCUOUS = 2;
  /// <summary>Disallow use of the virtual table from triggers or views; only top-level SQL may reference it. Recommended for modules that might leak information or have side-effects.</summary>
  SQLITE_VTAB_DIRECTONLY = 3;
  /// <summary>Instruct the query planner to begin at least a read transaction on all schemas ("main", "temp", and any ATTACHed) when the virtual table is used.</summary>
  SQLITE_VTAB_USES_ALL_SCHEMAS = 4;
  {$endregion}

  {$region ' Session / Changeset flags (sqlite3changeset_apply_v2)'}
  /// <summary>Omit the SAVEPOINT wrapper used by apply_v2(); caller may rollback to revert a partially applied changeset.</summary>
  SQLITE_CHANGESETAPPLY_NOSAVEPOINT = $0001;
  /// <summary>Invert the changeset before applying (equivalent to sqlite3changeset_invert()); not valid for patchsets.</summary>
  SQLITE_CHANGESETAPPLY_INVERT      = $0002;
  /// <summary>Do not invoke the conflict handler for changes that would be no-ops (e.g. UPDATE sets values already present).</summary>
  SQLITE_CHANGESETAPPLY_IGNORENOOP  = $0004;
  /// <summary>Treat all FK constraints as NO ACTION while applying the changeset (overrides CASCADE/RESTRICT/SET NULL/SET DEFAULT).</summary>
  SQLITE_CHANGESETAPPLY_FKNOACTION  = $0008;
  /// <summary>Abort if applying a changeset would encounter an update loop.</summary>
  SQLITE_CHANGESETAPPLY_NOUPDATELOOP = $0010; // since 3.51.0

  SQLITE_SESSION_OBJCONFIG_SIZE = 1;
  SQLITE_SESSION_OBJCONFIG_ROWID = 2;
  SQLITE_CHANGESETSTART_INVERT = $0002;
  SQLITE_CHANGESET_DATA = 1;
  SQLITE_CHANGESET_NOTFOUND = 2;
  SQLITE_CHANGESET_CONFLICT = 3;
  SQLITE_CHANGESET_CONSTRAINT = 4;
  SQLITE_CHANGESET_FOREIGN_KEY = 5;
  SQLITE_CHANGESET_OMIT = 0;
  SQLITE_CHANGESET_REPLACE = 1;
  SQLITE_CHANGESET_ABORT = 2;
  SQLITE_SESSION_CONFIG_STRMSIZE = 1;
  SQLITE_CHANGEGROUP_CONFIG_PATCHSET = 1;
  {$endregion}

  {$region ' Result Codes'} // https://www.sqlite.org/c3ref/c_abort.html
  /// <summary>Successful result.</summary>
  SQLITE_OK = 0;
  /// <summary>Generic error.</summary>
  SQLITE_ERROR = 1;
  /// <summary>Internal logic error in SQLite.</summary>
  SQLITE_INTERNAL = 2;  // :contentReference[oaicite:2]{index=2}
  /// <summary>Access permission denied.</summary>
  SQLITE_PERM = 3;
  /// <summary>Callback routine requested an abort.</summary>
  SQLITE_ABORT = 4;
  /// <summary>The database file is locked.</summary>
  SQLITE_BUSY = 5;
  /// <summary>A table in the database is locked.</summary>
  SQLITE_LOCKED = 6;
  /// <summary>A malloc() failed.</summary>
  SQLITE_NOMEM = 7;
  /// <summary>Attempt to write a readonly database.</summary>
  SQLITE_READONLY = 8;
  /// <summary>Operation terminated by sqlite3_interrupt().</summary>
  SQLITE_INTERRUPT = 9;
  /// <summary>Some kind of disk I/O error occurred.</summary>
  SQLITE_IOERR = 10;
  /// <summary>The database disk image is malformed.</summary>
  SQLITE_CORRUPT = 11;
  /// <summary>Unknown opcode in sqlite3_file_control().</summary>
  SQLITE_NOTFOUND = 12;
  /// <summary>Insertion failed because database is full.</summary>
  SQLITE_FULL = 13;
  /// <summary>Unable to open the database file.</summary>
  SQLITE_CANTOPEN = 14;
  /// <summary>Database lock protocol error.</summary>
  SQLITE_PROTOCOL = 15;
  /// <summary>Database is empty.</summary>
  SQLITE_EMPTY = 16;
  /// <summary>The database schema changed.</summary>
  SQLITE_SCHEMA = 17;
  /// <summary>String or BLOB exceeds size limit.</summary>
  SQLITE_TOOBIG = 18;
  /// <summary>Abort due to constraint violation.</summary>
  SQLITE_CONSTRAINT = 19;
  /// <summary>Data type mismatch.</summary>
  SQLITE_MISMATCH = 20;
  /// <summary>Library used incorrectly.</summary>
  SQLITE_MISUSE = 21;
  /// <summary>Uses OS features not supported on host.</summary>
  SQLITE_NOLFS = 22;
  /// <summary>Authorization denied.</summary>
  SQLITE_AUTH = 23;
  /// <summary>Auxiliary database format error.</summary>
  SQLITE_FORMAT = 24;
  /// <summary>2nd parameter to sqlite3_bind out of range.</summary>
  SQLITE_RANGE = 25;
  /// <summary>File opened that is not a database file.</summary>
  SQLITE_NOTADB = 26;
  /// <summary>Notifications from sqlite3_log().</summary>
  SQLITE_NOTICE = 27;
  /// <summary>Warnings from sqlite3_log().</summary>
  SQLITE_WARNING = 28;
  /// <summary>sqlite3_step() has another row ready; call column accessors to read it, then call sqlite3_step() again for the next row.</summary>
  SQLITE_ROW  = 100;
  /// <summary>sqlite3_step() has finished executing successfully; reset the statement before reusing it.</summary>
  SQLITE_DONE = 101;
  {$endregion}

  {$region ' Extended result codes'} // https://www.sqlite.org/c3ref/c_abort_rollback.html

  // SQLITE_ABORT (4)
  /// <summary>Statement aborted due to ROLLBACK on the same connection.</summary>
  SQLITE_ABORT_ROLLBACK = SQLITE_ABORT or (2 shl 8);

  // SQLITE_AUTH (23)
  /// <summary>User authorization failed.</summary>
  SQLITE_AUTH_USER = SQLITE_AUTH or (1 shl 8);

  // SQLITE_BUSY (5)
  /// <summary>Database is busy due to recovery.</summary>
  SQLITE_BUSY_RECOVERY = SQLITE_BUSY or (1 shl 8);
  /// <summary>Busy because of a conflicting snapshot.</summary>
  SQLITE_BUSY_SNAPSHOT = SQLITE_BUSY or (2 shl 8);
  /// <summary>Busy because the timeout expired.</summary>
  SQLITE_BUSY_TIMEOUT = SQLITE_BUSY or (3 shl 8);

  // SQLITE_CANTOPEN (14)
  /// <summary>Failed path conversion (e.g., on Cygwin).</summary>
  SQLITE_CANTOPEN_CONVPATH = SQLITE_CANTOPEN or (4 shl 8);
  /// <summary>Cannot open due to dirty WAL.</summary>
  SQLITE_CANTOPEN_DIRTYWAL = SQLITE_CANTOPEN or (5 shl 8);
  /// <summary>Full path required.</summary>
  SQLITE_CANTOPEN_FULLPATH = SQLITE_CANTOPEN or (3 shl 8);
  /// <summary>Path refers to a directory.</summary>
  SQLITE_CANTOPEN_ISDIR = SQLITE_CANTOPEN or (2 shl 8);
  /// <summary>Missing temporary directory.</summary>
  SQLITE_CANTOPEN_NOTEMPDIR = SQLITE_CANTOPEN or (1 shl 8);
  /// <summary>Refused because SQLITE_OPEN_NOFOLLOW met a symlink.</summary>
  SQLITE_CANTOPEN_SYMLINK = SQLITE_CANTOPEN or (6 shl 8);

  // SQLITE_CONSTRAINT (19)
  /// <summary>CHECK constraint failed.</summary>
  SQLITE_CONSTRAINT_CHECK = SQLITE_CONSTRAINT or (1 shl 8);
  /// <summary>Commit hook returned non-zero.</summary>
  SQLITE_CONSTRAINT_COMMITHOOK = SQLITE_CONSTRAINT or (2 shl 8);
  /// <summary>STRICT table type-affinity violation.</summary>
  SQLITE_CONSTRAINT_DATATYPE = SQLITE_CONSTRAINT or (12 shl 8);
  /// <summary>FOREIGN KEY constraint failed.</summary>
  SQLITE_CONSTRAINT_FOREIGNKEY = SQLITE_CONSTRAINT or (3 shl 8);
  /// <summary>Failure reported by an SQL function.</summary>
  SQLITE_CONSTRAINT_FUNCTION = SQLITE_CONSTRAINT or (4 shl 8);
  /// <summary>NOT NULL constraint failed.</summary>
  SQLITE_CONSTRAINT_NOTNULL = SQLITE_CONSTRAINT or (5 shl 8);
  /// <summary>Row pinned by trigger behavior.</summary>
  SQLITE_CONSTRAINT_PINNED = SQLITE_CONSTRAINT or (11 shl 8);
  /// <summary>PRIMARY KEY constraint failed.</summary>
  SQLITE_CONSTRAINT_PRIMARYKEY = SQLITE_CONSTRAINT or (6 shl 8);
  /// <summary>ROWID constraint failed.</summary>
  SQLITE_CONSTRAINT_ROWID = SQLITE_CONSTRAINT or (10 shl 8);
  /// <summary>RAISE() in trigger aborted the statement.</summary>
  SQLITE_CONSTRAINT_TRIGGER = SQLITE_CONSTRAINT or (7 shl 8);
  /// <summary>UNIQUE constraint failed.</summary>
  SQLITE_CONSTRAINT_UNIQUE = SQLITE_CONSTRAINT or (8 shl 8);
  /// <summary>Virtual table reported a constraint violation.</summary>
  SQLITE_CONSTRAINT_VTAB = SQLITE_CONSTRAINT or (9 shl 8);

  // SQLITE_CORRUPT (11)
  /// <summary>Index corruption detected.</summary>
  SQLITE_CORRUPT_INDEX = SQLITE_CORRUPT or (3 shl 8);
  /// <summary>Corruption related to a sequence object.</summary>
  SQLITE_CORRUPT_SEQUENCE = SQLITE_CORRUPT or (2 shl 8);
  /// <summary>Virtual table reports corruption.</summary>
  SQLITE_CORRUPT_VTAB = SQLITE_CORRUPT or (1 shl 8);

  // SQLITE_ERROR (1)
  /// <summary>Required collation sequence is missing.</summary>
  SQLITE_ERROR_MISSING_COLLSEQ = SQLITE_ERROR or (1 shl 8);
  /// <summary>Retry the operation.</summary>
  SQLITE_ERROR_RETRY = SQLITE_ERROR or (2 shl 8);
  /// <summary>Error related to snapshot handling.</summary>
  SQLITE_ERROR_SNAPSHOT = SQLITE_ERROR or (3 shl 8);
  /// <summary>SQLCipher reserve-size error.</summary>
  SQLITE_ERROR_RESERVESIZE = SQLITE_ERROR or (4 shl 8);
  /// <summary>SQLCipher key error.</summary>
  SQLITE_ERROR_KEY = SQLITE_ERROR or (5 shl 8);
  /// <summary>SQLCipher unable-to-process error.</summary>
  SQLITE_ERROR_UNABLE = SQLITE_ERROR or (6 shl 8);

  // SQLITE_IOERR (10)
  /// <summary>I/O error on access check.</summary>
  SQLITE_IOERR_ACCESS = SQLITE_IOERR or (13 shl 8);
  /// <summary>I/O error due to authorization failure.</summary>
  SQLITE_IOERR_AUTH = SQLITE_IOERR or (28 shl 8);
  /// <summary>I/O error beginning an atomic write.</summary>
  SQLITE_IOERR_BEGIN_ATOMIC = SQLITE_IOERR or (29 shl 8);
  /// <summary>I/O operation blocked.</summary>
  SQLITE_IOERR_BLOCKED = SQLITE_IOERR or (11 shl 8);
  /// <summary>I/O error in checkReservedLock.</summary>
  SQLITE_IOERR_CHECKRESERVEDLOCK = SQLITE_IOERR or (14 shl 8);
  /// <summary>I/O error on file close.</summary>
  SQLITE_IOERR_CLOSE = SQLITE_IOERR or (16 shl 8);
  /// <summary>I/O error committing an atomic write.</summary>
  SQLITE_IOERR_COMMIT_ATOMIC = SQLITE_IOERR or (30 shl 8);
  /// <summary>I/O path conversion failure.</summary>
  SQLITE_IOERR_CONVPATH = SQLITE_IOERR or (26 shl 8);
  /// <summary>I/O error due to corrupt filesystem behavior.</summary>
  SQLITE_IOERR_CORRUPTFS = SQLITE_IOERR or (33 shl 8);
  /// <summary>I/O error while loading an individual page.</summary>
  SQLITE_IOERR_IN_PAGE = SQLITE_IOERR or (34 shl 8);
  /// <summary>SQLCipher bad-key I/O error.</summary>
  SQLITE_IOERR_BADKEY = SQLITE_IOERR or (35 shl 8);
  /// <summary>SQLCipher codec I/O error.</summary>
  SQLITE_IOERR_CODEC = SQLITE_IOERR or (36 shl 8);
  /// <summary>I/O data integrity error.</summary>
  SQLITE_IOERR_DATA = SQLITE_IOERR or (32 shl 8);
  /// <summary>I/O error on delete.</summary>
  SQLITE_IOERR_DELETE = SQLITE_IOERR or (10 shl 8);
  /// <summary>I/O error: delete target does not exist.</summary>
  SQLITE_IOERR_DELETE_NOENT = SQLITE_IOERR or (23 shl 8);
  /// <summary>I/O error on directory close. (no longer used in core)</summary>
  SQLITE_IOERR_DIR_CLOSE = SQLITE_IOERR or (17 shl 8);
  /// <summary>I/O error on directory fsync.</summary>
  SQLITE_IOERR_DIR_FSYNC = SQLITE_IOERR or (5 shl 8);
  /// <summary>I/O error on fstat.</summary>
  SQLITE_IOERR_FSTAT = SQLITE_IOERR or (7 shl 8);
  /// <summary>I/O error on fsync.</summary>
  SQLITE_IOERR_FSYNC = SQLITE_IOERR or (4 shl 8);
  /// <summary>I/O error fetching temp path.</summary>
  SQLITE_IOERR_GETTEMPPATH = SQLITE_IOERR or (25 shl 8);
  /// <summary>I/O error on locking.</summary>
  SQLITE_IOERR_LOCK = SQLITE_IOERR or (15 shl 8);
  /// <summary>I/O error on mmap fetch/unfetch.</summary>
  SQLITE_IOERR_MMAP = SQLITE_IOERR or (24 shl 8);
  /// <summary>I/O error due to OOM.</summary>
  SQLITE_IOERR_NOMEM = SQLITE_IOERR or (12 shl 8);
  /// <summary>I/O error obtaining a read lock.</summary>
  SQLITE_IOERR_RDLOCK = SQLITE_IOERR or (9 shl 8);
  /// <summary>I/O error on read.</summary>
  SQLITE_IOERR_READ = SQLITE_IOERR or (1 shl 8);
  /// <summary>I/O error rolling back an atomic write.</summary>
  SQLITE_IOERR_ROLLBACK_ATOMIC = SQLITE_IOERR or (31 shl 8);
  /// <summary>I/O error while seeking.</summary>
  SQLITE_IOERR_SEEK = SQLITE_IOERR or (22 shl 8);
  /// <summary>I/O error acquiring a shared-memory lock.</summary>
  SQLITE_IOERR_SHMLOCK = SQLITE_IOERR or (20 shl 8);
  /// <summary>I/O error mapping a shared-memory segment.</summary>
  SQLITE_IOERR_SHMMAP = SQLITE_IOERR or (21 shl 8);
  /// <summary>I/O error opening a shared-memory segment.</summary>
  SQLITE_IOERR_SHMOPEN = SQLITE_IOERR or (18 shl 8);
  /// <summary>I/O error changing size of a shared-memory segment.</summary>
  SQLITE_IOERR_SHMSIZE = SQLITE_IOERR or (19 shl 8);
  /// <summary>I/O error on short read.</summary>
  SQLITE_IOERR_SHORT_READ = SQLITE_IOERR or (2 shl 8);
  /// <summary>I/O error on truncate.</summary>
  SQLITE_IOERR_TRUNCATE = SQLITE_IOERR or (6 shl 8);
  /// <summary>I/O error on unlock.</summary>
  SQLITE_IOERR_UNLOCK = SQLITE_IOERR or (8 shl 8);
  /// <summary>I/O error from Apple vnode invalidation.</summary>
  SQLITE_IOERR_VNODE = SQLITE_IOERR or (27 shl 8);
  /// <summary>I/O error on write.</summary>
  SQLITE_IOERR_WRITE = SQLITE_IOERR or (3 shl 8);

  // SQLITE_LOCKED (6)
  /// <summary>Locked by shared-cache.</summary>
  SQLITE_LOCKED_SHAREDCACHE = SQLITE_LOCKED or (1 shl 8);
  /// <summary>Locked due to virtual table usage.</summary>
  SQLITE_LOCKED_VTAB = SQLITE_LOCKED or (2 shl 8);

  // SQLITE_NOTICE (27)
  /// <summary>Notice about rollback recovery.</summary>
  SQLITE_NOTICE_RECOVER_ROLLBACK = SQLITE_NOTICE or (2 shl 8);
  /// <summary>Notice about WAL recovery.</summary>
  SQLITE_NOTICE_RECOVER_WAL = SQLITE_NOTICE or (1 shl 8);
  /// <summary>Notice emitted by RBU processing.</summary>
  SQLITE_NOTICE_RBU = SQLITE_NOTICE or (3 shl 8);

  // SQLITE_OK (0)
  /// <summary>Load extension permanently (non-UNIX only).</summary>
  SQLITE_OK_LOAD_PERMANENTLY = SQLITE_OK or (1 shl 8);
  /// <summary>Internal success code for symlink handling.</summary>
  SQLITE_OK_SYMLINK = SQLITE_OK or (2 shl 8);

  // SQLITE_READONLY (8)
  /// <summary>Read-only due to recovery.</summary>
  SQLITE_READONLY_RECOVERY = SQLITE_READONLY or (1 shl 8);
  /// <summary>Read-only because a write lock cannot be obtained.</summary>
  SQLITE_READONLY_CANTLOCK = SQLITE_READONLY or (2 shl 8);
  /// <summary>Read-only due to rollback mode.</summary>
  SQLITE_READONLY_ROLLBACK = SQLITE_READONLY or (3 shl 8);
  /// <summary>Read-only because the database file moved.</summary>
  SQLITE_READONLY_DBMOVED = SQLITE_READONLY or (4 shl 8);
  /// <summary>Read-only: initialization cannot proceed.</summary>
  SQLITE_READONLY_CANTINIT = SQLITE_READONLY or (5 shl 8);
  /// <summary>Read-only due to directory path.</summary>
  SQLITE_READONLY_DIRECTORY = SQLITE_READONLY or (6 shl 8);

  // SQLITE_WARNING (28)
  /// <summary>Automatic index creation advisory.</summary>
  SQLITE_WARNING_AUTOINDEX = SQLITE_WARNING or (1 shl 8);
  {$endregion}

  {$region ' Flags For File Open Operations (sqlite3_open_v2 / VFS)'}
  // https://sqlite.org/c3ref/c_open_autoproxy.html
  /// <summary>Open the database in read-only mode. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_READONLY = $00000001;
  /// <summary>Open the database for reading and writing. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_READWRITE = $00000002;
  /// <summary>Create the database file if it does not already exist. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_CREATE = $00000004;
  /// <summary>Delete the file when the database connection closes. (VFS only)</summary>
  SQLITE_OPEN_DELETEONCLOSE = $00000008;
  /// <summary>Open the file in exclusive-access mode. (VFS only)</summary>
  SQLITE_OPEN_EXCLUSIVE        = $00000010;
  /// <summary>Auto-proxy opening behavior for VFS shim layers. (VFS only)</summary>
  SQLITE_OPEN_AUTOPROXY        = $00000020;
  /// <summary>Interpret the filename as a URI. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_URI              = $00000040;
  /// <summary>Open an in-memory database. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_MEMORY           = $00000080;
  /// <summary>Main database file. (VFS only)</summary>
  SQLITE_OPEN_MAIN_DB          = $00000100;
  /// <summary>Temporary database file. (VFS only)</summary>
  SQLITE_OPEN_TEMP_DB          = $00000200;
  /// <summary>Transient DB file (lifetime bound to connection). (VFS only)</summary>
  SQLITE_OPEN_TRANSIENT_DB     = $00000400;
  /// <summary>Main rollback-journal file. (VFS only)</summary>
  SQLITE_OPEN_MAIN_JOURNAL     = $00000800;
  /// <summary>Temporary rollback-journal file. (VFS only)</summary>
  SQLITE_OPEN_TEMP_JOURNAL     = $00001000;
  /// <summary>Subjournal file. (VFS only)</summary>
  SQLITE_OPEN_SUBJOURNAL       = $00002000;
  /// <summary>Super-journal file. (VFS only)</summary>
  SQLITE_OPEN_SUPER_JOURNAL    = $00004000;
  /// <summary>Use “multi-thread” mode for this connection. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_NOMUTEX          = $00008000;
  /// <summary>Use “serialized” mode for this connection. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_FULLMUTEX        = $00010000;
  /// <summary>Enable shared-cache mode for this DB connection. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_SHAREDCACHE      = $00020000;
  /// <summary>Disable shared-cache mode for this DB connection. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_PRIVATECACHE     = $00040000;
  /// <summary>Open the write-ahead log (WAL) file. (VFS only)</summary>
  SQLITE_OPEN_WAL              = $00080000;
  /// <summary>Do not follow symbolic links when opening. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_NOFOLLOW         = $01000000;
  /// <summary>Start the connection with extended result codes enabled. (sqlite3_open_v2())</summary>
  SQLITE_OPEN_EXRESCODE        = $02000000;
  /// <summary>Legacy alias for SUPER_JOURNAL (VFS only).</summary>
  SQLITE_OPEN_MASTER_JOURNAL   = $00004000;  // :contentReference[oaicite:22]{index=22}
  {$endregion}

  {$region ' Device Characteristics (xDeviceCharacteristics)'}
  SQLITE_IOCAP_ATOMIC                = $00000001;
  SQLITE_IOCAP_ATOMIC512             = $00000002;
  SQLITE_IOCAP_ATOMIC1K              = $00000004;
  SQLITE_IOCAP_ATOMIC2K              = $00000008;
  SQLITE_IOCAP_ATOMIC4K              = $00000010;
  SQLITE_IOCAP_ATOMIC8K              = $00000020;
  SQLITE_IOCAP_ATOMIC16K             = $00000040;
  SQLITE_IOCAP_ATOMIC32K             = $00000080;
  SQLITE_IOCAP_ATOMIC64K             = $00000100;
  SQLITE_IOCAP_SAFE_APPEND           = $00000200;
  SQLITE_IOCAP_SEQUENTIAL            = $00000400;
  SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN = $00000800;
  SQLITE_IOCAP_POWERSAFE_OVERWRITE   = $00001000;
  SQLITE_IOCAP_IMMUTABLE             = $00002000;
  SQLITE_IOCAP_BATCH_ATOMIC          = $00004000;
  SQLITE_IOCAP_SUBPAGE_READ          = $00008000;
  {$endregion}

  {$region ' File Locking Levels (xLock/xUnlock)'}
  SQLITE_LOCK_NONE      = 0;
  SQLITE_LOCK_SHARED    = 1;
  SQLITE_LOCK_RESERVED  = 2;
  SQLITE_LOCK_PENDING   = 3;
  SQLITE_LOCK_EXCLUSIVE = 4;
  {$endregion}

  {$region ' Synchronization Type Flags (xSync flags)'}
  // https://sqlite.org/c3ref/c_sync_dataonly.html
  SQLITE_SYNC_NORMAL   = $00002;
  SQLITE_SYNC_FULL     = $00003;
  SQLITE_SYNC_DATAONLY = $00010;
  {$endregion}

  {$region ' Standard File Control Opcodes'}
  /// <summary>Debug: write current lock state (SQLITE_LOCK_*) into *(int*)pArg; only with SQLITE_TEST.</summary>
  SQLITE_FCNTL_LOCKSTATE         = 1;
  /// <summary>Deprecated/legacy: get lock-proxy file (old proxy-locking APIs).</summary>
  SQLITE_FCNTL_GET_LOCKPROXYFILE = 2;
  /// <summary>Deprecated/legacy: set lock-proxy file (old proxy-locking APIs).</summary>
  SQLITE_FCNTL_SET_LOCKPROXYFILE = 3;
  /// <summary>Return last system errno from the VFS.</summary>
  SQLITE_FCNTL_LAST_ERRNO        = 4;
  /// <summary>Advise expected DB growth this transaction (may preallocate space); (sqlite3_int64*)pArg.</summary>
  SQLITE_FCNTL_SIZE_HINT         = 5;
  /// <summary>Request DB grow/shrink in fixed chunks; (int*)pArg is new chunk size.</summary>
  SQLITE_FCNTL_CHUNK_SIZE        = 6;
  /// <summary>Obtain sqlite3_file* for the main DB file; (sqlite3_file**)pArg.</summary>
  SQLITE_FCNTL_FILE_POINTER      = 7;
  /// <summary>Advisory: a sync was omitted (or signal before xSync); used internally.</summary>
  SQLITE_FCNTL_SYNC_OMITTED      = 8;
  /// <summary>Windows VFS: configure AV-retry count/interval; pArg=[2]int array.</summary>
  SQLITE_FCNTL_WIN32_AV_RETRY    = 9;
  /// <summary>Get/set persistent WAL files flag (0/1, or -1 to query); (int*)pArg.</summary>
  SQLITE_FCNTL_PERSIST_WAL       = 10;
  /// <summary>Signal that current write txn will overwrite the entire DB (e.g., VACUUM).</summary>
  SQLITE_FCNTL_OVERWRITE         = 11;
  /// <summary>Return names of VFS stack (malloc’ed char*); (char**)pArg, caller frees.</summary>
  SQLITE_FCNTL_VFSNAME           = 12;
  /// <summary>Get/set persistent powersafe-overwrite (PSOW) flag (0/1 or -1 to query); (int*)pArg.</summary>
  SQLITE_FCNTL_POWERSAFE_OVERWRITE = 13;
  /// <summary>Intercept PRAGMA handling at parse-time; (char**)pArg vector [outRes, name, arg].</summary>
  SQLITE_FCNTL_PRAGMA            = 14;
  /// <summary>Expose the connection’s busy-handler to a custom VFS; pArg is (void*[2]).</summary>
  SQLITE_FCNTL_BUSYHANDLER       = 15;
  /// <summary>Request SQLite to generate a TEMP filename (malloc’ed); (char**)pArg, caller frees.</summary>
  SQLITE_FCNTL_TEMPFILENAME      = 16;
  { 17 unused }
  /// <summary>Get/set maximum bytes for memory-mapped I/O (also PRAGMA mmap_size); (sqlite3_int64*)pArg (negative to query).</summary>
  SQLITE_FCNTL_MMAP_SIZE         = 18;
  /// <summary>Advisory trace string to VFS shims (if SQLITE_USE_FCNTL_TRACE enabled); (char*)pArg.</summary>
  SQLITE_FCNTL_TRACE             = 19;
  /// <summary>Write *(int*)pArg=1 if file has moved/renamed/deleted since open, else 0.</summary>
  SQLITE_FCNTL_HAS_MOVED         = 20;
  /// <summary>Internal: signal to VFS immediately before/after xSync or when PRAGMA synchronous=OFF.</summary>
  SQLITE_FCNTL_SYNC              = 21;
  /// <summary>Internal: after commit, before unlock (two-phase commit advisory).</summary>
  SQLITE_FCNTL_COMMIT_PHASETWO   = 22;
  /// <summary>Windows VFS: swap underlying OS handle with *(HANDLE*)pArg; debug/test only.</summary>
  SQLITE_FCNTL_WIN32_SET_HANDLE  = 23;
  /// <summary>Advisory: may block on next WAL lock to avoid priority inversion.</summary>
  SQLITE_FCNTL_WAL_BLOCK         = 24;
  /// <summary>zipvfs-specific control (other VFS should return SQLITE_NOTFOUND).</summary>
  SQLITE_FCNTL_ZIPVFS            = 25;
  /// <summary>RBU extension VFS-specific control (others return SQLITE_NOTFOUND).</summary>
  SQLITE_FCNTL_RBU               = 26;
  /// <summary>Return top-level sqlite3_vfs* in the stack via *(sqlite3_vfs**)pArg.</summary>
  SQLITE_FCNTL_VFS_POINTER       = 27;
  /// <summary>Obtain sqlite3_file* for the journal (rollback/WAL) via *(sqlite3_file**)pArg.</summary>
  SQLITE_FCNTL_JOURNAL_POINTER   = 28;
  /// <summary>Windows VFS: get underlying OS handle into *(HANDLE*)pArg.</summary>
  SQLITE_FCNTL_WIN32_GET_HANDLE  = 29;
  /// <summary>Deprecated alias for SQLITE_FCNTL_GET_LOCKPROXYFILE.</summary>
  SQLITE_GET_LOCKPROXYFILE = SQLITE_FCNTL_GET_LOCKPROXYFILE;
  /// <summary>Deprecated alias for SQLITE_FCNTL_SET_LOCKPROXYFILE.</summary>
  SQLITE_SET_LOCKPROXYFILE = SQLITE_FCNTL_SET_LOCKPROXYFILE;
  /// <summary>Deprecated alias for SQLITE_FCNTL_LAST_ERRNO.</summary>
  SQLITE_LAST_ERRNO = SQLITE_FCNTL_LAST_ERRNO;
  /// <summary>Provide DB connection pointer to VFS (implementation detail; for some VFS).</summary>
  SQLITE_FCNTL_PDB               = 30;
  /// <summary>Begin an atomic write sequence. Must be followed by COMMIT_ATOMIC_WRITE or ROLLBACK_ATOMIC_WRITE.</summary>
  SQLITE_FCNTL_BEGIN_ATOMIC_WRITE     = 31;
  /// <summary>Commit a sequence started by BEGIN_ATOMIC_WRITE.</summary>
  SQLITE_FCNTL_COMMIT_ATOMIC_WRITE    = 32;
  /// <summary>Rollback a sequence started by BEGIN_ATOMIC_WRITE.</summary>
  SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE  = 33;
  /// <summary>Set a blocking lock timeout for WAL-mode connections (VFS support required / ENABLE_SETLK_TIMEOUT).</summary>
  SQLITE_FCNTL_LOCK_TIMEOUT           = 34;
  /// <summary>Return a counter that changes when the database file (incl. external changes) is modified.</summary>
  SQLITE_FCNTL_DATA_VERSION           = 35;
  /// <summary>For deserialize VFS: set or query an upper bound on in-memory DB size (sqlite3_int64* argument).</summary>
  SQLITE_FCNTL_SIZE_LIMIT             = 36;
  /// <summary>Internal: invoked after copying pages from WAL to db during a checkpoint, before shm update.</summary>
  SQLITE_FCNTL_CKPT_DONE              = 37;
  /// <summary>Set/Query the number of bytes reserved at the end of each database page.</summary>
  SQLITE_FCNTL_RESERVE_BYTES          = 38;
  /// <summary>Internal: invoked before copying pages from WAL to db during a checkpoint.</summary>
  SQLITE_FCNTL_CKPT_START             = 39;
  /// <summary>EXPERIMENTAL (unix): detect if another process has a WAL-mode SQL transaction open (int* out).</summary>
  SQLITE_FCNTL_EXTERNAL_READER        = 40;
  /// <summary>Internal: for checksum VFS shim only.</summary>
  SQLITE_FCNTL_CKSM_FILE              = 41;
  /// <summary>Purge the page cache if no txn is open and db is not temp; otherwise no-op.</summary>
  SQLITE_FCNTL_RESET_CACHE            = 42;
  /// <summary>Direct I/O null driver toggle for testing (no real I/O).</summary>
  SQLITE_FCNTL_NULL_IO                = 43;
  /// <summary>Request blocking on connect until exclusive-lock checkpoint completes (see sqlite3_setlk_timeout flags).</summary>
  SQLITE_FCNTL_BLOCK_ON_CONNECT       = 44;
  /// <summary>Append JSON diagnostics about sqlite3_file objects to a sqlite3_str* (requires build options to enable).</summary>
  SQLITE_FCNTL_FILESTAT               = 45;
  {$endregion}

  {$region ' Checkpoint Mode Values'}
  SQLITE_CHECKPOINT_NOOP = -1;
  SQLITE_CHECKPOINT_PASSIVE = 0;
  SQLITE_CHECKPOINT_FULL = 1;
  SQLITE_CHECKPOINT_RESTART = 2;
  SQLITE_CHECKPOINT_TRUNCATE = 3;
  {$endregion}

  {$region ' Virtual Table Scan Flags'}
  SQLITE_INDEX_SCAN_UNIQUE = $00000001;
  SQLITE_INDEX_SCAN_HEX = $00000002;
  {$endregion}

  {$region ' Allowed operator codes for sqlite3_index_info.aConstraint[].op.'}
  /// <summary>= (equals)</summary>
  SQLITE_INDEX_CONSTRAINT_EQ: Integer = 2;
  /// <summary>&gt; (greater than)</summary>
  SQLITE_INDEX_CONSTRAINT_GT: Integer = 4;
  /// <summary>&le; (less than or equal)</summary>
  SQLITE_INDEX_CONSTRAINT_LE: Integer = 8;
  /// <summary>&lt; (less than)</summary>
  SQLITE_INDEX_CONSTRAINT_LT: Integer = 16;
  /// <summary>&ge; (greater than or equal)</summary>
  SQLITE_INDEX_CONSTRAINT_GE: Integer = 32;
  /// <summary>MATCH (full-text style match)</summary>
  SQLITE_INDEX_CONSTRAINT_MATCH: Integer = 64;
  /// <summary>LIKE (pattern match)</summary>
  SQLITE_INDEX_CONSTRAINT_LIKE: Integer = 65;
  /// <summary>GLOB (Unix-shell style pattern match)</summary>
  SQLITE_INDEX_CONSTRAINT_GLOB: Integer = 66;
  /// <summary>REGEXP (regular expression match)</summary>
  SQLITE_INDEX_CONSTRAINT_REGEXP: Integer = 67;
  /// <summary>&ne; (not equal)</summary>
  SQLITE_INDEX_CONSTRAINT_NE: Integer = 68;
  /// <summary>IS NOT (identity inequality)</summary>
  SQLITE_INDEX_CONSTRAINT_ISNOT: Integer = 69;
  /// <summary>IS NOT NULL (null-test)</summary>
  SQLITE_INDEX_CONSTRAINT_ISNOTNULL: Integer = 70;
  /// <summary>IS NULL (null-test)</summary>
  SQLITE_INDEX_CONSTRAINT_ISNULL: Integer = 71;
  /// <summary>IS (identity equality)</summary>
  SQLITE_INDEX_CONSTRAINT_IS: Integer = 72;
  /// <summary>LIMIT (query limit pseudo-constraint)</summary>
  SQLITE_INDEX_CONSTRAINT_LIMIT: Integer = 73;
  /// <summary>OFFSET (query offset pseudo-constraint)</summary>
  SQLITE_INDEX_CONSTRAINT_OFFSET: Integer = 74;
  /// <summary>Function overload code range marker for xFindFunction (150..255 reserved)</summary>
  SQLITE_INDEX_CONSTRAINT_FUNCTION: Integer = 150;
  {$endregion}

  {$region ' Additional SQLite Core Constants'}
  SQLITE_ACCESS_EXISTS = 0;
  SQLITE_ACCESS_READWRITE = 1;
  SQLITE_ACCESS_READ = 2;
  SQLITE_SHM_UNLOCK = 1;
  SQLITE_SHM_LOCK = 2;
  SQLITE_SHM_SHARED = 4;
  SQLITE_SHM_EXCLUSIVE = 8;
  SQLITE_SHM_NLOCK = 8;
  SQLITE_CONFIG_SINGLETHREAD = 1;
  SQLITE_CONFIG_MULTITHREAD = 2;
  SQLITE_CONFIG_SERIALIZED = 3;
  SQLITE_CONFIG_MALLOC = 4;
  SQLITE_CONFIG_GETMALLOC = 5;
  SQLITE_CONFIG_SCRATCH = 6;
  SQLITE_CONFIG_PAGECACHE = 7;
  SQLITE_CONFIG_HEAP = 8;
  SQLITE_CONFIG_MEMSTATUS = 9;
  SQLITE_CONFIG_MUTEX = 10;
  SQLITE_CONFIG_GETMUTEX = 11;
  SQLITE_CONFIG_LOOKASIDE = 13;
  SQLITE_CONFIG_PCACHE = 14;
  SQLITE_CONFIG_GETPCACHE = 15;
  SQLITE_CONFIG_LOG = 16;
  SQLITE_CONFIG_URI = 17;
  SQLITE_CONFIG_PCACHE2 = 18;
  SQLITE_CONFIG_GETPCACHE2 = 19;
  SQLITE_CONFIG_COVERING_INDEX_SCAN = 20;
  SQLITE_CONFIG_SQLLOG = 21;
  SQLITE_CONFIG_MMAP_SIZE = 22;
  SQLITE_CONFIG_WIN32_HEAPSIZE = 23;
  SQLITE_CONFIG_PCACHE_HDRSZ = 24;
  SQLITE_CONFIG_PMASZ = 25;
  SQLITE_CONFIG_STMTJRNL_SPILL = 26;
  SQLITE_CONFIG_SMALL_MALLOC = 27;
  SQLITE_CONFIG_SORTERREF_SIZE = 28;
  SQLITE_CONFIG_MEMDB_MAXSIZE = 29;
  SQLITE_CONFIG_ROWID_IN_VIEW = 30;
  SQLITE_DBCONFIG_MAINDBNAME = 1000;
  SQLITE_DBCONFIG_LOOKASIDE = 1001;
  SQLITE_DBCONFIG_ENABLE_FKEY = 1002;
  SQLITE_DBCONFIG_ENABLE_TRIGGER = 1003;
  SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER = 1004;
  SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION = 1005;
  SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE = 1006;
  SQLITE_DBCONFIG_ENABLE_QPSG = 1007;
  SQLITE_DBCONFIG_TRIGGER_EQP = 1008;
  SQLITE_DBCONFIG_RESET_DATABASE = 1009;
  SQLITE_DBCONFIG_DEFENSIVE = 1010;
  SQLITE_DBCONFIG_WRITABLE_SCHEMA = 1011;
  SQLITE_DBCONFIG_LEGACY_ALTER_TABLE = 1012;
  SQLITE_DBCONFIG_DQS_DML = 1013;
  SQLITE_DBCONFIG_DQS_DDL = 1014;
  SQLITE_DBCONFIG_ENABLE_VIEW = 1015;
  SQLITE_DBCONFIG_LEGACY_FILE_FORMAT = 1016;
  SQLITE_DBCONFIG_TRUSTED_SCHEMA = 1017;
  SQLITE_DBCONFIG_STMT_SCANSTATUS = 1018;
  SQLITE_DBCONFIG_REVERSE_SCANORDER = 1019;
  SQLITE_DBCONFIG_ENABLE_ATTACH_CREATE = 1020;
  SQLITE_DBCONFIG_ENABLE_ATTACH_WRITE = 1021;
  SQLITE_DBCONFIG_ENABLE_COMMENTS = 1022;
  SQLITE_DBCONFIG_FP_DIGITS = 1023;
  SQLITE_DBCONFIG_MAX = 1023;
  SQLITE_DENY = 1;
  SQLITE_IGNORE = 2;
  SQLITE_CREATE_INDEX = 1;
  SQLITE_CREATE_TABLE = 2;
  SQLITE_CREATE_TEMP_INDEX = 3;
  SQLITE_CREATE_TEMP_TABLE = 4;
  SQLITE_CREATE_TEMP_TRIGGER = 5;
  SQLITE_CREATE_TEMP_VIEW = 6;
  SQLITE_CREATE_TRIGGER = 7;
  SQLITE_CREATE_VIEW = 8;
  SQLITE_DELETE = 9;
  SQLITE_DROP_INDEX = 10;
  SQLITE_DROP_TABLE = 11;
  SQLITE_DROP_TEMP_INDEX = 12;
  SQLITE_DROP_TEMP_TABLE = 13;
  SQLITE_DROP_TEMP_TRIGGER = 14;
  SQLITE_DROP_TEMP_VIEW = 15;
  SQLITE_DROP_TRIGGER = 16;
  SQLITE_DROP_VIEW = 17;
  SQLITE_INSERT = 18;
  SQLITE_PRAGMA = 19;
  SQLITE_READ = 20;
  SQLITE_SELECT = 21;
  SQLITE_TRANSACTION = 22;
  SQLITE_UPDATE = 23;
  SQLITE_ATTACH = 24;
  SQLITE_DETACH = 25;
  SQLITE_ALTER_TABLE = 26;
  SQLITE_REINDEX = 27;
  SQLITE_ANALYZE = 28;
  SQLITE_CREATE_VTABLE = 29;
  SQLITE_DROP_VTABLE = 30;
  SQLITE_FUNCTION = 31;
  SQLITE_SAVEPOINT = 32;
  SQLITE_COPY = 0;
  SQLITE_RECURSIVE = 33;
  SQLITE_TRACE_STMT = $01;
  SQLITE_TRACE_PROFILE = $02;
  SQLITE_TRACE_ROW = $04;
  SQLITE_TRACE_CLOSE = $08;
  SQLITE_LIMIT_LENGTH = 0;
  SQLITE_LIMIT_SQL_LENGTH = 1;
  SQLITE_LIMIT_COLUMN = 2;
  SQLITE_LIMIT_EXPR_DEPTH = 3;
  SQLITE_LIMIT_COMPOUND_SELECT = 4;
  SQLITE_LIMIT_VDBE_OP = 5;
  SQLITE_LIMIT_FUNCTION_ARG = 6;
  SQLITE_LIMIT_ATTACHED = 7;
  SQLITE_LIMIT_LIKE_PATTERN_LENGTH = 8;
  SQLITE_LIMIT_VARIABLE_NUMBER = 9;
  SQLITE_LIMIT_TRIGGER_DEPTH = 10;
  SQLITE_LIMIT_WORKER_THREADS = 11;
  SQLITE_LIMIT_PARSER_DEPTH = 12;
  SQLITE3_TEXT = 3;
  SQLITE_WIN32_DATA_DIRECTORY_TYPE = 1;
  SQLITE_WIN32_TEMP_DIRECTORY_TYPE = 2;
  SQLITE_TXN_NONE = 0;
  SQLITE_TXN_READ = 1;
  SQLITE_TXN_WRITE = 2;
  SQLITE_MUTEX_FAST = 0;
  SQLITE_MUTEX_RECURSIVE = 1;
  SQLITE_MUTEX_STATIC_MAIN = 2;
  SQLITE_MUTEX_STATIC_MEM = 3;
  SQLITE_MUTEX_STATIC_MEM2 = 4;
  SQLITE_MUTEX_STATIC_OPEN = 4;
  SQLITE_MUTEX_STATIC_PRNG = 5;
  SQLITE_MUTEX_STATIC_LRU = 6;
  SQLITE_MUTEX_STATIC_LRU2 = 7;
  SQLITE_MUTEX_STATIC_PMEM = 7;
  SQLITE_MUTEX_STATIC_APP1 = 8;
  SQLITE_MUTEX_STATIC_APP2 = 9;
  SQLITE_MUTEX_STATIC_APP3 = 10;
  SQLITE_MUTEX_STATIC_VFS1 = 11;
  SQLITE_MUTEX_STATIC_VFS2 = 12;
  SQLITE_MUTEX_STATIC_VFS3 = 13;
  SQLITE_MUTEX_STATIC_MASTER = 2;
  SQLITE_TESTCTRL_FIRST = 5;
  SQLITE_TESTCTRL_PRNG_SAVE = 5;
  SQLITE_TESTCTRL_PRNG_RESTORE = 6;
  SQLITE_TESTCTRL_PRNG_RESET = 7;
  SQLITE_TESTCTRL_FK_NO_ACTION = 7;
  SQLITE_TESTCTRL_BITVEC_TEST = 8;
  SQLITE_TESTCTRL_FAULT_INSTALL = 9;
  SQLITE_TESTCTRL_BENIGN_MALLOC_HOOKS = 10;
  SQLITE_TESTCTRL_PENDING_BYTE = 11;
  SQLITE_TESTCTRL_ASSERT = 12;
  SQLITE_TESTCTRL_ALWAYS = 13;
  SQLITE_TESTCTRL_RESERVE = 14;
  SQLITE_TESTCTRL_JSON_SELFCHECK = 14;
  SQLITE_TESTCTRL_OPTIMIZATIONS = 15;
  SQLITE_TESTCTRL_ISKEYWORD = 16;
  SQLITE_TESTCTRL_GETOPT = 16;
  SQLITE_TESTCTRL_SCRATCHMALLOC = 17;
  SQLITE_TESTCTRL_INTERNAL_FUNCTIONS = 17;
  SQLITE_TESTCTRL_LOCALTIME_FAULT = 18;
  SQLITE_TESTCTRL_EXPLAIN_STMT = 19;
  SQLITE_TESTCTRL_ONCE_RESET_THRESHOLD = 19;
  SQLITE_TESTCTRL_NEVER_CORRUPT = 20;
  SQLITE_TESTCTRL_VDBE_COVERAGE = 21;
  SQLITE_TESTCTRL_BYTEORDER = 22;
  SQLITE_TESTCTRL_ISINIT = 23;
  SQLITE_TESTCTRL_SORTER_MMAP = 24;
  SQLITE_TESTCTRL_IMPOSTER = 25;
  SQLITE_TESTCTRL_PARSER_COVERAGE = 26;
  SQLITE_TESTCTRL_RESULT_INTREAL = 27;
  SQLITE_TESTCTRL_PRNG_SEED = 28;
  SQLITE_TESTCTRL_EXTRA_SCHEMA_CHECKS = 29;
  SQLITE_TESTCTRL_SEEK_COUNT = 30;
  SQLITE_TESTCTRL_TRACEFLAGS = 31;
  SQLITE_TESTCTRL_TUNE = 32;
  SQLITE_TESTCTRL_LOGEST = 33;
  SQLITE_TESTCTRL_USELONGDOUBLE = 34;
  SQLITE_TESTCTRL_ATOF = 34;
  SQLITE_TESTCTRL_LAST = 34;
  SQLITE_STATUS_MEMORY_USED = 0;
  SQLITE_STATUS_PAGECACHE_USED = 1;
  SQLITE_STATUS_PAGECACHE_OVERFLOW = 2;
  SQLITE_STATUS_SCRATCH_USED = 3;
  SQLITE_STATUS_SCRATCH_OVERFLOW = 4;
  SQLITE_STATUS_MALLOC_SIZE = 5;
  SQLITE_STATUS_PARSER_STACK = 6;
  SQLITE_STATUS_PAGECACHE_SIZE = 7;
  SQLITE_STATUS_SCRATCH_SIZE = 8;
  SQLITE_STATUS_MALLOC_COUNT = 9;
  SQLITE_DBSTATUS_LOOKASIDE_USED = 0;
  SQLITE_DBSTATUS_CACHE_USED = 1;
  SQLITE_DBSTATUS_SCHEMA_USED = 2;
  SQLITE_DBSTATUS_STMT_USED = 3;
  SQLITE_DBSTATUS_LOOKASIDE_HIT = 4;
  SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE = 5;
  SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL = 6;
  SQLITE_DBSTATUS_CACHE_HIT = 7;
  SQLITE_DBSTATUS_CACHE_MISS = 8;
  SQLITE_DBSTATUS_CACHE_WRITE = 9;
  SQLITE_DBSTATUS_DEFERRED_FKS = 10;
  SQLITE_DBSTATUS_CACHE_USED_SHARED = 11;
  SQLITE_DBSTATUS_CACHE_SPILL = 12;
  SQLITE_DBSTATUS_TEMPBUF_SPILL = 13;
  SQLITE_DBSTATUS_MAX = 13;
  SQLITE_STMTSTATUS_FULLSCAN_STEP = 1;
  SQLITE_STMTSTATUS_SORT = 2;
  SQLITE_STMTSTATUS_AUTOINDEX = 3;
  SQLITE_STMTSTATUS_VM_STEP = 4;
  SQLITE_STMTSTATUS_REPREPARE = 5;
  SQLITE_STMTSTATUS_RUN = 6;
  SQLITE_STMTSTATUS_FILTER_MISS = 7;
  SQLITE_STMTSTATUS_FILTER_HIT = 8;
  SQLITE_STMTSTATUS_MEMUSED = 99;
  SQLITE_ROLLBACK = 1;
  SQLITE_FAIL = 3;
  SQLITE_REPLACE = 5;
  SQLITE_SCANSTAT_NLOOP = 0;
  SQLITE_SCANSTAT_NVISIT = 1;
  SQLITE_SCANSTAT_EST = 2;
  SQLITE_SCANSTAT_NAME = 3;
  SQLITE_SCANSTAT_EXPLAIN = 4;
  SQLITE_SCANSTAT_SELECTID = 5;
  SQLITE_SCANSTAT_PARENTID = 6;
  SQLITE_SCANSTAT_NCYCLE = 7;
  SQLITE_SCANSTAT_COMPLEX = $0001;
  FTS5_TOKENIZE_QUERY = $0001;
  FTS5_TOKENIZE_PREFIX = $0002;
  FTS5_TOKENIZE_DOCUMENT = $0004;
  FTS5_TOKENIZE_AUX = $0008;
  FTS5_TOKEN_COLOCATED = $0001;
  {$endregion}

type

  {$region ' arguments values'}
  Psqlite3_arg_values = ^sqlite3_arg_values;
  {$ifdef CPU64BITS}
  sqlite3_arg_values = array [0..256*1024*1024 - 2] of Pointer;
  {$ELSE}
  sqlite3_arg_values = array [0..512*1024*1024 - 2] of Pointer;
  {$ENDIF}
  {$endregion}

  {$region ' callback types'}
  // busy_handler: int(*)(void*,int)
  sqlite3_busy_callback = function(pArg: Pointer; nPrevInvokes: Integer): Integer; cdecl;

  //common compare callback for collation_needed/create_collation[_v2]:
  // int(*)(void*,int,const void*,int,const void*)
  sqlite3_compare_callback = function(pArg: Pointer; len1: Integer; p1: Pointer; len2: Integer; p2: Pointer): Integer; cdecl;
  // commit_hook: int(*)(void*)
  sqlite3_commit_callback = function(pArg: Pointer): Integer; cdecl;

  // create_function/16/v2: xFunc/xStep/xFinal ; create_window_function: xStep/xFinal/xValue/xInv/xDestroy
  sqlite3_xFunc = procedure(pCtx: Pointer; argc: Integer; argv: Psqlite3_arg_values); cdecl;
  // set value callback
  sqlite3_xValueFunc = procedure(cCtx: Pointer); cdecl;
  // common destructor callback: (void(*)(void*))
  sqlite3_xDestroy = procedure(pData: Pointer); cdecl;

  // exec: int(*)(void*,int,char**,char**)
  sqlite3_exec_callback = function(UserData: Pointer; ColCount: Integer; ColValues: PPAnsiChar; ColNames: PPAnsiChar): Integer; cdecl;

  // profile: void(*)(void*,const char*,sqlite_uint64)
  sqlite3_xProfile = procedure(pArg: Pointer; const zSql: PAnsiChar; elapsedCycles: UInt64); cdecl;

  // progress_handler: int(*)(void*)
  sqlite3_xProgress = function(pArg: Pointer): Integer; cdecl;

  // trace (legacy): void(*)(void*,const char*)
  sqlite3_xTrace = procedure(pArg: Pointer; const zSql: PAnsiChar); cdecl;

  // update_hook: void(*)(void*,int,const char*,const char*,sqlite_int64)
  sqlite3_xUpdate = procedure(pArg: Pointer; op: Integer; const dbName, tableName: PAnsiChar; rowid: Int64); cdecl;

  // unlock_notify: void(*)(void**,int)
  sqlite3_xNotify = procedure(apArg: PPointer; nArg: Integer); cdecl;

  // wal_hook: int(*)(void*,sqlite3*,const char*,int)
  sqlite3_xWalHook = function(pArg: Pointer; db: Pointer; const dbName: PAnsiChar; nPages: Integer): Integer; cdecl;

  // trace_v2: int(*)(unsigned,void*,void*,void*)
  sqlite3_xTrace2 = function(uMask: Cardinal; pCtx, pP, pX: Pointer): Integer; cdecl;

  // autovacuum_pages: unsigned int(*)(void*,const char*,unsigned int,unsigned int,unsigned int)
  sqlite3_xAutovacuumCallback = function(pArg: Pointer; const zDb: PAnsiChar; page: Cardinal; pageSize: Cardinal; remaining: Cardinal): Cardinal; cdecl;

  {$endregion}

  {$region ' print interfaces'}
  sqlite3_mprintf_func = function(fmt: PAnsiChar): PAnsiChar; cdecl varargs;
  sqlite3_vmprintf_func = function(fmt: PAnsiChar; ap: Pointer{va_list}): PAnsiChar; cdecl;
  sqlite3_snprintf_func = function(n: Integer; dst: PAnsiChar; fmt: PAnsiChar): PAnsiChar; cdecl varargs;
  {$endregion}

  {$region ' sqlite3_io_methods'}
  //https://sqlite.org/c3ref/io_methods.html
  Psqlite3_io_methods = ^sqlite3_io_methods;
  sqlite3_io_methods = record
    /// <summary>Structure version. Controls which trailing methods are valid (v1..v3).</summary>
    /// <remarks>v1: xClose..xDeviceCharacteristics;<br/>v2: +xShmMap/xShmLock/xShmBarrier/xShmUnmap;<br/>v3: +xFetch/xUnfetch.</remarks>
    iVersion: Integer;
    /// <summary>Close the file handle. May be called even if xOpen ultimately failed, unless pMethods is set to NULL.</summary>
    xClose: function(f: Pointer): Integer; cdecl;
    /// <summary>Read iAmt bytes at absolute offset iOfst into buffer; must zero-fill unread tail on short read.</summary>
    xRead: function(f: Pointer; buf: Pointer; iAmt: Integer; iOfst: Int64): Integer; cdecl;
    /// <summary>Write iAmt bytes from buffer at absolute offset iOfst.</summary>
    xWrite: function(f: Pointer; const buf: Pointer; iAmt: Integer; iOfst: Int64): Integer; cdecl;
    /// <summary>Truncate file to the specified size (bytes).</summary>
    xTruncate: function(f: Pointer; size: Int64): Integer; cdecl;
    /// <summary>Flush file contents to durable storage; flags is SQLITE_SYNC_NORMAL or SQLITE_SYNC_FULL, optionally ORed with SQLITE_SYNC_DATAONLY.</summary>
    xSync: function(f: Pointer; flags: Integer): Integer; cdecl;
    /// <summary>Return current file size via pSize (bytes).</summary>
    xFileSize: function(f: Pointer; pSize: PInt64): Integer; cdecl;
    /// <summary>Upgrade lock state toward EXCLUSIVE. Arg is SHARED/RESERVED/PENDING/EXCLUSIVE (never NONE).</summary>
    xLock: function(f: Pointer; lock: Integer): Integer; cdecl;
    /// <summary>Downgrade lock state to SHARED or NONE.</summary>
    xUnlock: function(f: Pointer; lock: Integer): Integer; cdecl;
    /// <summary>Report via pResOut if any connection holds RESERVED/PENDING/EXCLUSIVE lock on this file.</summary>
    xCheckReservedLock: function(f: Pointer; pResOut: PInteger): Integer; cdecl;
    /// <summary>Generic control hook; invoked via sqlite3_file_control(db, zDbName, op, pArg). Return SQLITE_NOTFOUND for unknown opcodes.</summary>
    xFileControl: function(f: Pointer; op: Integer; pArg: Pointer): Integer; cdecl;
    /// <summary>Report device sector size (minimum write granularity).</summary>
    xSectorSize: function(f: Pointer): Integer; cdecl;
    /// <summary>Return bitmask of device characteristics (SQLITE_IOCAP_*).</summary>
    xDeviceCharacteristics: function(f: Pointer): Integer; cdecl;

    // -- Methods above are valid for version 1 --

    /// <summary>Map shared-memory page iPg of size pgsz; return pointer via pp; flags controls mapping behavior.</summary>
    xShmMap: function(f: Pointer; iPg, pgsz, flags: Integer; var pp: Pointer): Integer; cdecl;
    /// <summary>Acquire/release a shared-memory lock at byte offset for n bytes with flags.</summary>
    xShmLock: function(f: Pointer; offset, n, flags: Integer): Integer; cdecl;
    /// <summary>Memory barrier operation for shared-memory region.</summary>
    xShmBarrier: procedure(f: Pointer); cdecl;
    /// <summary>Unmap shared-memory; deleteFlag indicates whether to delete shared-memory region.</summary>
    xShmUnmap: function(f: Pointer; deleteFlag: Integer): Integer; cdecl;

    // -- Methods above are valid for version 2 --

    /// <summary>Return a direct pointer to a read-only mapping for the range [iOfst, iOfst+iAmt); may improve performance via mmap.</summary>
    xFetch: function(f: Pointer; iOfst: Int64; iAmt: Integer; var pp: Pointer): Integer; cdecl;
    /// <summary>Release a pointer previously obtained from xFetch for the given range.</summary>
    xUnfetch: function(f: Pointer; iOfst: Int64; p: Pointer): Integer; cdecl;
  end;
  {$endregion}

  {$region ' sqlite3_file'}
  ///<summary>OS Interface Open File Handle</summary>
  Psqlite3_file = ^sqlite3_file;
  sqlite3_file = record
    pMethods: Psqlite3_io_methods;
  end;
  {$endregion}

  {$region ' sqlite3_api_routines - for sqlite3 version: 3.53.3'}
  Psqlite3_api_routines = ^sqlite3_api_routines;
  /// <summary>structure that holds pointers to all of the SQLite API routines.</summary>
  sqlite3_api_routines = record
    /// <summary>Return aggregate context buffer (>= nBytes) for xStep/xFinal; owned by SQLite.</summary>
    aggregate_context: function(ctx: Pointer; nBytes: Integer): Pointer; cdecl;
    /// <summary>(Deprecated) Return count of xStep calls for current aggregate invocation.</summary>
    aggregate_count: function(ctx: Pointer): Integer; cdecl;
    /// <summary>Bind parameter i with BLOB data (n bytes); xDel is destructor for buffer.</summary>
    bind_blob: function(st: Pointer; i: Integer; const buf: Pointer; n: Integer; xDel: sqlite3_xDestroy): Integer; cdecl;
    /// <summary>Bind parameter i with a Double value.</summary>
    bind_double: function(st: Pointer; i: Integer; v: Double): Integer; cdecl;
    /// <summary>Bind parameter i with a 32-bit integer.</summary>
    bind_int: function(st: Pointer; i, v: Integer): Integer; cdecl;
    /// <summary>Bind parameter i with a 64-bit integer.</summary>
    bind_int64: function(st: Pointer; i: Integer; v: Int64): Integer; cdecl;
    /// <summary>Bind parameter i with NULL.</summary>
    bind_null: function(st: Pointer; i: Integer): Integer; cdecl;
    /// <summary>Return number of parameters in a prepared statement.</summary>
    bind_parameter_count: function(st: Pointer): Integer; cdecl;
    /// <summary>Look up parameter index by name (e.g. ":name").</summary>
    bind_parameter_index: function(st: Pointer; const zName: PAnsiChar): Integer; cdecl;
    /// <summary>Return parameter name by index (or NULL for positional '?').</summary>
    bind_parameter_name: function(st: Pointer; i: Integer): PAnsiChar; cdecl;
    /// <summary>Bind UTF-8 text (n bytes); xDel is destructor; UTF-8 must be well-formed.</summary>
    bind_text: function(st: Pointer; i: Integer; const txt: PAnsiChar; n: Integer; xDel: sqlite3_xDestroy): Integer; cdecl;
    /// <summary>Bind UTF-16 text in native byte order (n bytes); xDel is destructor.</summary>
    bind_text16: function(st: Pointer; i: Integer; const txt16: Pointer; n: Integer; xDel: sqlite3_xDestroy): Integer; cdecl;
    /// <summary>Bind parameter i with value from Pointer*.</summary>
    bind_value: function(st: Pointer; i: Integer; const v: Pointer): Integer; cdecl;
    /// <summary>Install/replace a busy-handler callback on the connection.</summary>
    busy_handler: function(db: Pointer; xBusy: sqlite3_busy_callback; pArg: Pointer): Integer; cdecl;
    /// <summary>Set busy timeout in milliseconds; replaces any existing busy-handler.</summary>
    busy_timeout: function(db: Pointer; ms: Integer): Integer; cdecl;
    /// <summary>Return number of rows changed by the most recent operation on this connection.</summary>
    changes: function(db: Pointer): Integer; cdecl;
    /// <summary>Close database connection; statements must be finalized before close.</summary>
    close: function(db: Pointer): Integer; cdecl;
    /// <summary>Register collation-needed callback (UTF-8 variant) to lazily provide collations.</summary>
    collation_needed: function(db: Pointer; pArg: Pointer; x: Pointer): Integer; cdecl;
    /// <summary>UTF-16 variant of collation-needed callback (collation name in UTF-16).</summary>
    collation_needed16: function(db: Pointer; pArg: Pointer; x: Pointer): Integer; cdecl;
    /// <summary>Access column value as raw BLOB pointer for current row; valid until next step/reset.</summary>
    column_blob: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Size in bytes of BLOB/UTF-8 text column value.</summary>
    column_bytes: function(st: Pointer; iCol: Integer): Integer; cdecl;
    /// <summary>Size in bytes of UTF-16 text column value.</summary>
    column_bytes16: function(st: Pointer; iCol: Integer): Integer; cdecl;
    /// <summary>Number of result columns in a prepared statement.</summary>
    column_count: function(st: Pointer): Integer; cdecl;
    /// <summary>Database name for column (UTF-8).</summary>
    column_database_name: function(st: Pointer; iCol: Integer): PAnsiChar; cdecl;
    /// <summary>Database name for column (UTF-16).</summary>
    column_database_name16: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Declared type of result column (schema type), UTF-8.</summary>
    column_decltype: function(st: Pointer; iCol: Integer): PAnsiChar; cdecl;
    /// <summary>Declared type of result column (schema type), UTF-16.</summary>
    column_decltype16: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Access column as Double.</summary>
    column_double: function(st: Pointer; iCol: Integer): Double; cdecl;
    /// <summary>Access column as 32-bit integer.</summary>
    column_int: function(st: Pointer; iCol: Integer): Integer; cdecl;
    /// <summary>Access column as 64-bit integer.</summary>
    column_int64: function(st: Pointer; iCol: Integer): Int64; cdecl;
    /// <summary>Result column name (UTF-8).</summary>
    column_name: function(st: Pointer; iCol: Integer): PAnsiChar; cdecl;
    /// <summary>Result column name (UTF-16).</summary>
    column_name16: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Origin (base table) column name, UTF-8.</summary>
    column_origin_name: function(st: Pointer; iCol: Integer): PAnsiChar; cdecl;
    /// <summary>Origin (base table) column name, UTF-16.</summary>
    column_origin_name16: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Origin table name, UTF-8.</summary>
    column_table_name: function(st: Pointer; iCol: Integer): PAnsiChar; cdecl;
    /// <summary>Origin table name, UTF-16.</summary>
    column_table_name16: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Access column as UTF-8 text; pointer valid until next step/reset.</summary>
    column_text: function(st: Pointer; iCol: Integer): PAnsiChar; cdecl;
    /// <summary>Access column as UTF-16 text; pointer valid until next step/reset.</summary>
    column_text16: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Default datatype code of column value (SQLITE_INTEGER/REAL/TEXT/BLOB/NULL).</summary>
    column_type: function(st: Pointer; iCol: Integer): Integer; cdecl;
    /// <summary>Return Pointer* for column (unprotected value object).</summary>
    column_value: function(st: Pointer; iCol: Integer): Pointer; cdecl;
    /// <summary>Install commit-hook; returns previous hook pointer.</summary>
    commit_hook: function(db: Pointer; xCommit: Pointer; pArg: Pointer): Pointer; cdecl;
    /// <summary>Return non-zero if input SQL text forms a complete statement (UTF-8).</summary>
    complete: function(const sql: PAnsiChar): Integer; cdecl;
    /// <summary>UTF-16 variant of sqlite3_complete().</summary>
    complete16: function(const sql16: Pointer): Integer; cdecl;
    /// <summary> Define New collating Sequence(UTF-8)</summary>
    create_collation: function(db: Pointer;const zName: PAnsiChar;eTextRep: Integer;pArg: Pointer; xCompare: sqlite3_compare_callback): Integer; cdecl;
    /// <summary>UTF-16 variant of create_collation()</summary>
    create_collation16: function(db: Pointer;const zName16: Pointer;eTextRep: Integer;pArg: Pointer; xCompare: sqlite3_compare_callback): Integer; cdecl;
    /// <summary>Register scalar/aggregate function (UTF-8 name); eTextRep enc/flags; xFunc/xStep/xFinal handlers.</summary>
    create_function: function(db: Pointer; const zFunc: PAnsiChar; nArg: Integer; eTextRep: Integer; pApp: Pointer; xFunc: sqlite3_xFunc; xStep: sqlite3_xFunc; xFinal: sqlite3_xValueFunc): Integer; cdecl;
    /// <summary>Same as create_function but with UTF-16 function name.</summary>
    create_function16: function(db: Pointer; const zFunc16: Pointer; nArg: Integer; eTextRep: Integer; pApp: Pointer; xFunc: sqlite3_xFunc; xStep: sqlite3_xFunc; xFinal: sqlite3_xValueFunc): Integer; cdecl;
    /// <summary>Register a virtual table module under name zName (legacy create_module).</summary>
    create_module: function(db: Pointer; const zName: PAnsiChar; const pModule: Pointer; pAux: Pointer): Integer; cdecl;
    /// <summary>Number of columns in the current row (0 if none / after SQLITE_DONE).</summary>
    data_count: function(st: Pointer): Integer; cdecl;
    /// <summary>Return Pointer* connection that owns this prepared statement.</summary>
    db_handle: function(st: Pointer): Pointer; cdecl;
    /// <summary>Declare the schema of a virtual table (called by xCreate/xConnect).</summary>
    declare_vtab: function(db: Pointer; const zSQL: PAnsiChar): Integer; cdecl;
    /// <summary>(Legacy control) Enable/disable shared page cache for connections.</summary>
    enable_shared_cache: function(Enable: Integer): Integer; cdecl;
    /// <summary>Primary error code for the most recent API call on this connection.</summary>
    errcode: function(db: Pointer): Integer; cdecl;
    /// <summary>English error message (UTF-8) for last error on the connection.</summary>
    errmsg: function(db: Pointer): PAnsiChar; cdecl;
    /// <summary>UTF-16 variant of sqlite3_errmsg().</summary>
    errmsg16: function(db: Pointer): Pointer; cdecl;
    /// <summary>Execute SQL text with row-callback; returns an error code and optional error string.</summary>
    exec: function(db: Pointer; const sql: PAnsiChar; cb: sqlite3_exec_callback; arg: Pointer; var pzErr: PAnsiChar): Integer; cdecl;
    /// <summary>(Deprecated) True if statement is expired due to schema change.</summary>
    expired: function(st: Pointer): Integer; cdecl;
    /// <summary>Finalize (destroy) prepared statement and release resources.</summary>
    finalize: function(st: Pointer): Integer; cdecl;
    /// <summary>Free memory allocated by SQLite (use for strings/buffers returned by API).</summary>
    free: procedure(p: Pointer); cdecl;
    /// <summary>Free result table memory allocated by sqlite3_get_table().</summary>
    free_table: procedure(resultPtr: PPAnsiChar); cdecl;
    /// <summary>Return 1 if connection is in autocommit mode, else 0.</summary>
    get_autocommit: function(db: Pointer): Integer; cdecl;
    /// <summary>Fetch auxiliary data previously set via set_auxdata() for arg N of this function call.</summary>
    get_auxdata: function(ctx: Pointer; N: Integer): Pointer; cdecl;
    /// <summary>Convenience: execute SQL and collect entire result set in memory (legacy interface).</summary>
    get_table: function(db: Pointer; const sql: PAnsiChar; out resultPtr: PPAnsiChar; out nRow: Integer; out nCol: Integer; out pzErr: PAnsiChar): Integer; cdecl;
    /// <summary>(Historical) Attempt global recovery after a crash (legacy).</summary>
    global_recover: function: Integer; cdecl;
    /// <summary>Asynchronously interrupt ongoing operations on the connection.</summary>
    interruptx: procedure(db: Pointer); cdecl;
    /// <summary>ROWID of most recent successful INSERT on this connection.</summary>
    last_insert_rowid: function(db: Pointer): Int64; cdecl;
    /// <summary>Return library version string, e.g. "3.45.1".</summary>
    libversion: function: PAnsiChar; cdecl;
    /// <summary>Return library version as integer (3xxxyyzz).</summary>
    libversion_number: function: Integer; cdecl;
    /// <summary>Allocate memory using SQLite's allocator.</summary>
    malloc: function(n: Integer): Pointer; cdecl;
    /// <summary>Format string using SQLite allocator; returns heap-allocated C string.</summary>
    mprintf: function(fmt: PAnsiChar): PAnsiChar; cdecl varargs;
    /// <summary>Open database file (UTF-8 filename); returns SQLITE_OK on success.</summary>
    open: function(const filename: PAnsiChar; out pdb: Pointer): Integer; cdecl;
    /// <summary>Open database file (UTF-16 native-endian filename).</summary>
    open16: function(const filename16: Pointer; out pdb: Pointer): Integer; cdecl;
    /// <summary>Compile SQL (UTF-8) into a prepared statement; pzTail points to unused SQL tail.</summary>
    prepare: function(db: Pointer; const zSql: PAnsiChar; nByte: Integer; var ppStmt: Pointer; pzTail: PPAnsiChar): Integer; cdecl;
    /// <summary>Compile SQL (UTF-16) into a prepared statement.</summary>
    prepare16: function(db: Pointer; const zSql16: Pointer; nByte: Integer; var ppStmt: Pointer; pzTail: PPointer): Integer; cdecl;
    /// <summary>Install progress handler: X(P) invoked about every N VM instructions; non-zero return cancels.</summary>
    profile: function(db: Pointer; x: sqlite3_xProfile; pArg: Pointer): Pointer; cdecl; // legacy profile hook
    /// <summary>Install progress handler (preferred): called periodically during prepare/step for cancellation/GUI updates.</summary>
    progress_handler: procedure(db: Pointer; n: Integer; xProgress: sqlite3_xProgress; pArg: Pointer); cdecl;
    /// <summary>Reallocate memory using SQLite allocator.</summary>
    realloc: function(p: Pointer; n: Integer): Pointer; cdecl;
    /// <summary>Reset prepared statement to initial state, preserving the prepared program.</summary>
    reset: function(st: Pointer): Integer; cdecl;
    /// <summary>Set function result to BLOB (n bytes); xDel is destructor for buffer.</summary>
    result_blob: procedure(ctx: Pointer; const p: Pointer; n: Integer; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>Set function result to Double.</summary>
    result_double: procedure(ctx: Pointer; r: Double); cdecl;
    /// <summary>Set function error message (UTF-8) with n bytes (or -1 for nul-terminated).</summary>
    result_error: procedure(ctx: Pointer; const msg: PAnsiChar; n: Integer); cdecl;
    /// <summary>Set function error message (UTF-16).</summary>
    result_error16: procedure(ctx: Pointer; const msg16: Pointer; n: Integer); cdecl;
    /// <summary>Set function result to 32-bit integer.</summary>
    result_int: procedure(ctx: Pointer; v: Integer); cdecl;
    /// <summary>Set function result to 64-bit integer.</summary>
    result_int64: procedure(ctx: Pointer; v: Int64); cdecl;
    /// <summary>Set function result to NULL.</summary>
    result_null: procedure(ctx: Pointer); cdecl;
    /// <summary>Set function result to UTF-8 text (n bytes; xDel destructor).</summary>
    result_text: procedure(ctx: Pointer; const txt: PAnsiChar; n: Integer; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>Set function result to UTF-16 text.</summary>
    result_text16: procedure(ctx: Pointer; const txt16: Pointer; n: Integer; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>Set function result to UTF-16BE text.</summary>
    result_text16be: procedure(ctx: Pointer; const txt16: Pointer; n: Integer; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>Set function result to UTF-16LE text.</summary>
    result_text16le: procedure(ctx: Pointer; const txt16: Pointer; n: Integer; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>Set function result to value copied from Pointer*.</summary>
    result_value: procedure(ctx: Pointer; v: Pointer); cdecl;
    /// <summary>Install rollback-hook; returns previous hook pointer.</summary>
    rollback_hook: function(db: Pointer; xRollback: Pointer; pArg: Pointer): Pointer; cdecl;
    /// <summary>Install authorizer callback to allow/deny SQL operations per-connection.</summary>
    set_authorizer: function(db: Pointer; xAuth: Pointer; pArg: Pointer): Integer; cdecl;
    /// <summary>Associate auxiliary data N with current function call; freed via xDel when args change.</summary>
    set_auxdata: procedure(ctx: Pointer; N: Integer; p: Pointer; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>snprintf-like formatting into caller-provided buffer.</summary>
    xsnprintf: function(n: Integer; dst: PAnsiChar; fmt: PAnsiChar): PAnsiChar; cdecl varargs;
    /// <summary>Evaluate one VM step on prepared statement: returns SQLITE_ROW/DONE or error code.</summary>
    step: function(st: Pointer): Integer; cdecl;
    /// <summary>Return table/column metadata (declared type, collation, NOT NULL, PK, autoincrement).</summary>
    table_column_metadata: function(db: Pointer; const zDb, zTable, zCol: PAnsiChar; out zDataType, zCollSeq: PAnsiChar; out notNull, primaryKey, autoinc: Integer): Integer; cdecl;
    /// <summary>(Legacy) Thread cleanup hook; unused in modern builds.</summary>
    thread_cleanup: procedure; cdecl;
    /// <summary>Total number of rows changed by this connection since open.</summary>
    total_changes: function(db: Pointer): Integer; cdecl;
    /// <summary>Install trace callback (legacy). Prefer trace_v2().</summary>
    trace: function(db: Pointer; xTrace: sqlite3_xTrace; pArg: Pointer): Pointer; cdecl;
    /// <summary>Transfer parameter bindings from one statement to another.</summary>
    transfer_bindings: function(fromStmt, toStmt: Pointer): Integer; cdecl;
    /// <summary>Install update-hook to receive notifications on row changes.</summary>
    update_hook: function(db: Pointer; xUpdate: sqlite3_xUpdate; pArg: Pointer): Pointer; cdecl;
    /// <summary>Return application data pointer (pApp) supplied at function registration.</summary>
    user_data: function(ctx: Pointer): Pointer; cdecl;
    /// <summary>Access Pointer* as raw BLOB pointer.</summary>
    value_blob: function(v: Pointer): Pointer; cdecl;
    /// <summary>Size in bytes of BLOB/UTF-8 text Pointer.</summary>
    value_bytes: function(v: Pointer): Integer; cdecl;
    /// <summary>Size in bytes of UTF-16 Pointer.</summary>
    value_bytes16: function(v: Pointer): Integer; cdecl;
    /// <summary>Access Pointer as Double.</summary>
    value_double: function(v: Pointer): Double; cdecl;
    /// <summary>Access Pointer as 32-bit integer.</summary>
    value_int: function(v: Pointer): Integer; cdecl;
    /// <summary>Access Pointer as 64-bit integer.</summary>
    value_int64: function(v: Pointer): Int64; cdecl;
    /// <summary>Return numeric affinity type for Pointer.</summary>
    value_numeric_type: function(v: Pointer): Integer; cdecl;
    /// <summary>Access Pointer as UTF-8 text.</summary>
    value_text: function(v: Pointer): PAnsiChar; cdecl;
    /// <summary>Access Pointer as UTF-16 text in the native byteorder. </summary>
    value_text16: function(v: Pointer): Pointer; cdecl;
    /// <summary>Access Pointer as UTF-16be TEXT value </summary>
    value_text16be: function(v: Pointer): Pointer; cdecl;
    /// <summary>Access Pointer as UTF-16le TEXT value </summary>
    value_text16le: function(v: Pointer): Pointer; cdecl;
    /// <summary>Return fundamental datatype code of Pointer.</summary>
    value_type: function(v: Pointer): Integer; cdecl;
    /// <summary>vprintf-like using SQLite allocator; returns heap-allocated string.</summary>
    vmprintf: function(fmt: PAnsiChar): PAnsiChar; cdecl varargs;
    /// <summary>Ensure a global function name exists (used by vtab overloads).</summary>
    overload_function: function(db: Pointer; const zFunc: PAnsiChar; nArg: Integer): Integer; cdecl;
    /// <summary>Prepare SQL (UTF-8) with v2 behavior (better error reporting).</summary>
    prepare_v2: function(db: Pointer; const zSql: PAnsiChar; nByte: Integer; var ppStmt: Pointer; pzTail: PPAnsiChar ): Integer; cdecl;
    /// <summary>Prepare SQL (UTF-16) with v2 behavior.</summary>
    prepare16_v2: function(db: Pointer; const zSql16: Pointer; nByte: Integer; var ppStmt: Pointer; pzTail: PPointer): Integer; cdecl;
    /// <summary>Reset all parameter bindings on a prepared statement to NULL.</summary>
    clear_bindings: function(st: Pointer): Integer; cdecl;
    /// <summary>Register virtual table module with xDestroy finalizer for pAux (create_module v2).</summary>
    create_module_v2: function(db: Pointer; const zName: PAnsiChar; const pModule: Pointer; pAux: Pointer; xDestroy: sqlite3_xDestroy): Integer; cdecl;

    // ----- 3.5.0+ -----

    /// <summary>Bind a zero-filled blob of n bytes to parameter i.</summary>
    bind_zeroblob: function(st: Pointer; i, n: Integer): Integer; cdecl;
    /// <summary>Return size of open incremental BLOB handle.</summary>
    blob_bytes: function(b: Pointer): Integer; cdecl;
    /// <summary>Close incremental BLOB handle.</summary>
    blob_close: function(b: Pointer): Integer; cdecl;
    /// <summary>Open incremental BLOB handle for rowid/column with flags.</summary>
    blob_open: function(db: Pointer; const zDb, zTable, zCol: PAnsiChar; rowid: Int64; flags: Integer; var pBlob: Pointer): Integer; cdecl;
    /// <summary>Read n bytes from BLOB at offset into buffer Z.</summary>
    blob_read: function(b: Pointer; Z: Pointer; n, offset: Integer): Integer; cdecl;
    /// <summary>Write n bytes to BLOB at offset from buffer Z.</summary>
    blob_write: function(b: Pointer; const Z: Pointer; n, offset: Integer): Integer; cdecl;
    /// <summary>Register collation with destructor callback xDel.</summary>
    create_collation_v2: function(db: Pointer; const zName: PAnsiChar; eTextRep: Integer; pArg: Pointer; xCmp: Pointer; xDel: sqlite3_xDestroy): Integer; cdecl;
    /// <summary>Issue file-control operation on a named database or VFS.</summary>
    file_control: function(db: Pointer; const zDb: PAnsiChar; op: Integer; pArg: Pointer): Integer; cdecl;
    /// <summary>Return high-water mark of memory usage (optionally reset).</summary>
    memory_highwater: function(resetFlag: Integer): Int64; cdecl;
    /// <summary>Return current memory usage by SQLite.</summary>
    memory_used: function: Int64; cdecl;
    /// <summary>Allocate a mutex object of given type.</summary>
    mutex_alloc: function(mType: Integer): Pointer; cdecl;
    /// <summary>Enter (lock) mutex m.</summary>
    mutex_enter: procedure(m: Pointer); cdecl;
    /// <summary>Free a mutex object.</summary>
    mutex_free: procedure(m: Pointer); cdecl;
    /// <summary>Leave (unlock) mutex m.</summary>
    mutex_leave: procedure(m: Pointer); cdecl;
    /// <summary>Attempt to enter mutex without blocking; returns SQLITE_OK or BUSY.</summary>
    mutex_try: function(m: Pointer): Integer; cdecl;
    /// <summary>Open database with flags and optional VFS name (UTF-8).</summary>
    open_v2: function(const filename: PAnsiChar; out pdb: Pointer; flags: Integer; const zVfs: PAnsiChar): Integer; cdecl;
    /// <summary>Release at least n bytes of heap memory back to the OS if possible.</summary>
    release_memory: function(n: Integer): Integer; cdecl;
    /// <summary>Set function result: SQLITE_NOMEM error.</summary>
    result_error_nomem: procedure(ctx: Pointer); cdecl;
    /// <summary>Set function result: SQLITE_TOOBIG error.</summary>
    result_error_toobig: procedure(ctx: Pointer); cdecl;
    /// <summary>Suspend current thread for at least ms milliseconds.</summary>
    sleep: function(ms: Integer): Integer; cdecl;
    /// <summary>Set soft heap limit (obsolete; prefer soft_heap_limit64()).</summary>
    soft_heap_limit: procedure(n: Integer); cdecl;
    /// <summary>Find VFS by name (NULL for default).</summary>
    vfs_find: function(const zVfs: PAnsiChar): Pointer; cdecl;
    /// <summary>Register a VFS object (optionally make default).</summary>
    vfs_register: function(vfs: Pointer; makeDflt: Integer): Integer; cdecl;
    /// <summary>Unregister a VFS object.</summary>
    vfs_unregister: function(vfs: Pointer): Integer; cdecl;
    /// <summary>Return non-zero if library was compiled thread-safe.</summary>
    xthreadsafe: function: Integer; cdecl;
    /// <summary>Set function result to a zero-filled blob of n bytes.</summary>
    result_zeroblob: procedure(ctx: Pointer; n: Integer); cdecl;
    /// <summary>Set function result to specific SQLite error code.</summary>
    result_error_code: procedure(ctx: Pointer; err: Integer); cdecl;
    /// <summary>Test-control interface for internal features (debug/diagnostics).</summary>
    test_control: function(op: Integer): Integer; cdecl; // varargs suppressed
    /// <summary>Fill buffer P with N bytes of randomness.</summary>
    randomness: procedure(N: Integer; P: Pointer); cdecl;
    /// <summary>Return Pointer* associated with function context (for UDFs).</summary>
    context_db_handle: function(ctx: Pointer): Pointer; cdecl;
    /// <summary>Enable/disable extended result codes on a connection.</summary>
    extended_result_codes: function(db: Pointer; onoff: Integer): Integer; cdecl;
    /// <summary>Get/set per-connection limits (e.g., length, SQL variables).</summary>
    limit: function(db: Pointer; id, newVal: Integer): Integer; cdecl;
    /// <summary>Return next prepared statement on connection (for iterating).</summary>
    next_stmt: function(db: Pointer; stmt: Pointer): Pointer; cdecl;
    /// <summary>Return original SQL text for a prepared statement.</summary>
    sql: function(st: Pointer): PAnsiChar; cdecl;
    /// <summary>Global status metrics; optionally reset high-water marks.</summary>
    status: function(op: Integer; out cur, hi: Integer; resetFlag: Integer): Integer; cdecl;

    /// <summary>Finish a backup operation; release resources.</summary>
    backup_finish: function(b: Pointer): Integer; cdecl;
    /// <summary>Initialize online backup from (srcDb:src) to (dstDb:dst).</summary>
    backup_init: function(dstDb: Pointer; const zDst: PAnsiChar; srcDb: Pointer; const zSrc: PAnsiChar): Pointer; cdecl;
    /// <summary>Total pages in source database for backup handle.</summary>
    backup_pagecount: function(b: Pointer): Integer; cdecl;
    /// <summary>Remaining pages to be copied for backup handle.</summary>
    backup_remaining: function(b: Pointer): Integer; cdecl;
    /// <summary>Copy up to nPage pages; returns SQLITE_OK/BUSY/LOCKED/DONE.</summary>
    backup_step: function(b: Pointer; nPage: Integer): Integer; cdecl;

    /// <summary>Return compile-time option name by index (or NULL).</summary>
    compileoption_get: function(N: Integer): PAnsiChar; cdecl;
    /// <summary>True if named compile-time option was used.</summary>
    compileoption_used: function(const zOptName: PAnsiChar): Integer; cdecl;

    /// <summary>Register function with destructor (preferred API for new code).</summary>
    create_function_v2: function(db: Pointer; const zFunc: PAnsiChar; nArg, eTextRep: Integer; pApp: Pointer; xFunc: sqlite3_xFunc; xStep: sqlite3_xFunc; xFinal: sqlite3_xValueFunc; xDestroy: sqlite3_xDestroy): Integer; cdecl;

    /// <summary>Per-connection configuration control (varargs; see sqlite3_db_config docs).</summary>
    db_config: function(db: Pointer; op: Integer): Integer; cdecl; // varargs suppressed
    /// <summary>Return mutex object protecting a database connection.</summary>
    db_mutex: function(db: Pointer): Pointer; cdecl;
    /// <summary>Per-connection status metrics; optionally reset.</summary>
    db_status: function(db: Pointer; op: Integer; out cur, hi: Integer; resetFlag: Integer): Integer; cdecl;

    /// <summary>Extended error code for last failure on the connection.</summary>
    extended_errcode: function(db: Pointer): Integer; cdecl;
    /// <summary>Write a message to the compile-time configured log function.</summary>
    log: procedure(iErrCode: Integer; const zFmt: PAnsiChar); cdecl; // varargs suppressed
    /// <summary>Set or get soft heap limit in bytes; returns previous limit.</summary>
    soft_heap_limit64: function(N: Int64): Int64; cdecl;
    /// <summary>Return full source-id string for this SQLite build.</summary>
    sourceid: function: PAnsiChar; cdecl;
    /// <summary>Return per-statement status counter; optionally reset.</summary>
    stmt_status: function(st: Pointer; op, resetFlg: Integer): Integer; cdecl;
    /// <summary>Case-insensitive string compare for UTF-8 (ASCII-ish).</summary>
    strnicmp: function(const a, b: PAnsiChar; n: Integer): Integer; cdecl;
    /// <summary>Register unlock-notify callback for blocked connection (shared-cache).</summary>
    unlock_notify: function(db: Pointer; xNotify: sqlite3_xNotify; pArg: Pointer): Integer; cdecl;
    /// <summary>Set WAL autocheckpoint threshold in pages.</summary>
    wal_autocheckpoint: function(db: Pointer; N: Integer): Integer; cdecl;
    /// <summary>Trigger a passive/active/full checkpoint on a database.</summary>
    wal_checkpoint: function(db: Pointer; const zDb: PAnsiChar): Integer; cdecl;
    /// <summary>Install WAL hook; called on each frame/transaction in WAL mode.</summary>
    wal_hook: function(db: Pointer; xHook: sqlite3_xWalHook; pArg: Pointer): Pointer; cdecl;
    /// <summary>Retarget an open blob handle to a different rowid.</summary>
    blob_reopen: function(b: Pointer; rowid: Int64): Integer; cdecl;
    /// <summary>Configure virtual table behaviors (e.g., constraint support).</summary>
    vtab_config: function(db: Pointer; op: Integer): Integer; cdecl; // varargs suppressed
    /// <summary>Return conflict policy currently in effect for vtab (for xUpdate).</summary>
    vtab_on_conflict: function(db: Pointer): Integer; cdecl;

    // ----- 3.7.16+ -----

    /// <summary>Close database connection; leaves unfinalized statements alive (safer close).</summary>
    close_v2: function(db: Pointer): Integer; cdecl;
    /// <summary>Return filename of database schema name zDbName.</summary>
    db_filename: function(db: Pointer; const zDbName: PAnsiChar): PAnsiChar; cdecl;
    /// <summary>Return 1 if named database is read-only; else 0; -1 if unknown.</summary>
    db_readonly: function(db: Pointer; const zDbName: PAnsiChar): Integer; cdecl;
    /// <summary>Attempt to return memory from a specific connection to the OS.</summary>
    db_release_memory: function(db: Pointer): Integer; cdecl;
    /// <summary>Return English error string for a result code (not tied to a connection).</summary>
    errstr: function(ec: Integer): PAnsiChar; cdecl;
    /// <summary>Return non-zero if statement has not yet completed (busy).</summary>
    stmt_busy: function(st: Pointer): Integer; cdecl;
    /// <summary>Return non-zero if statement is read-only.</summary>
    stmt_readonly: function(st: Pointer): Integer; cdecl;
    /// <summary>Case-insensitive UTF-8 compare (full string).</summary>
    stricmp: function(const a, b: PAnsiChar): Integer; cdecl;
    /// <summary>Return boolean value of URI query parameter k from filename z.</summary>
    uri_boolean: function(const z: PAnsiChar; const k: PAnsiChar; dflt: Integer): Integer; cdecl;
    /// <summary>Return 64-bit integer value of URI parameter k from filename z.</summary>
    uri_int64: function(const z, k: PAnsiChar; dflt: Int64): Int64; cdecl;
    /// <summary>Return value of URI parameter k from filename z (string or NULL).</summary>
    uri_parameter: function(const z, k: PAnsiChar): PAnsiChar; cdecl;
    /// <summary>vsnprintf-like formatting into caller buffer using Pointer.</summary>
    xvsnprintf: function(n: Integer; dst: PAnsiChar; const fmt: PAnsiChar; ap: Pointer): PAnsiChar; cdecl;
    /// <summary>Perform a WAL checkpoint with mode and return log/checkpoint sizes.</summary>
    wal_checkpoint_v2: function(db: Pointer; const zDb: PAnsiChar; eMode: Integer; out nLog, nCkpt: Integer): Integer; cdecl;

    // ----- 3.8.7+ -----

    /// <summary>Register automatic extension entry point for future db opens.</summary>
    auto_extension: function(xEntry: Pointer): Integer; cdecl;
    /// <summary>Bind large BLOB using 64-bit length.</summary>
    bind_blob64: function(st: Pointer; i: Integer; const p: Pointer; n: UInt64; xDel: sqlite3_xDestroy): Integer; cdecl;
    /// <summary>Bind large text using 64-bit length and explicit encoding selector.</summary>
    bind_text64: function(st: Pointer; i: Integer; const p: PAnsiChar; n: UInt64; xDel: sqlite3_xDestroy; enc: Byte): Integer; cdecl;
    /// <summary>Unregister an automatic extension.</summary>
    cancel_auto_extension: function(xEntry: Pointer): Integer; cdecl;
    /// <summary>Load extension from shared library file with optional entry-point.</summary>
    load_extension: function(db: Pointer; const zFile, zProc: PAnsiChar; out pzErr: PAnsiChar): Integer; cdecl;
    /// <summary>Allocate memory using 64-bit size.</summary>
    malloc64: function(n: UInt64): Pointer; cdecl;
    /// <summary>Return size of a heap allocation made by SQLite.</summary>
    msize: function(p: Pointer): UInt64; cdecl;
    /// <summary>Reallocate using 64-bit size.</summary>
    realloc64: function(p: Pointer; n: UInt64): Pointer; cdecl;
    /// <summary>Clear all registered automatic extensions.</summary>
    reset_auto_extension: procedure; cdecl;
    /// <summary>Set function result to large BLOB (64-bit length).</summary>
    result_blob64: procedure(ctx: Pointer; const p: Pointer; n: UInt64; xDel: sqlite3_xDestroy); cdecl;
    /// <summary>Set function result to large text (64-bit length, with encoding selector).</summary>
    result_text64: procedure(ctx: Pointer; const p: PAnsiChar; n: UInt64; xDel: sqlite3_xDestroy; enc: Byte); cdecl;
    /// <summary>Glob-style pattern match (case-sensitive, '*' and '?' wildcards).</summary>
    strglob: function(const zGlob, zStr: PAnsiChar): Integer; cdecl;

    // ----- 3.8.11+ -----

    /// <summary>Duplicate Pointer* (unprotected copy).</summary>
    value_dup: function(const v: Pointer): Pointer; cdecl;
    /// <summary>Free Pointer* created by value_dup().</summary>
    value_free: procedure(v: Pointer); cdecl;
    /// <summary>Set function result to zeroblob of 64-bit size.</summary>
    result_zeroblob64: function(ctx: Pointer; n: UInt64): Integer; cdecl;
    /// <summary>Bind zeroblob with 64-bit size.</summary>
    bind_zeroblob64: function(st: Pointer; i: Integer; n: UInt64): Integer; cdecl;

    // ----- 3.9.0+ -----

    /// <summary>Return subtype tag associated with Pointer (for application use).</summary>
    value_subtype: function(v: Pointer): Cardinal; cdecl;
    /// <summary>Assign subtype tag to function result value.</summary>
    result_subtype: procedure(ctx: Pointer; st: Cardinal); cdecl;

    // ----- 3.10.0+ -----

    /// <summary>Global status metrics with 64-bit counters.</summary>
    status64: function(op: Integer; out cur, hi: Int64; resetFlag: Integer): Integer; cdecl;
    /// <summary>LIKE-style pattern match with ESC character (case-insensitive).</summary>
    strlike: function(const zGlob, zStr: PAnsiChar; esc: Cardinal): Integer; cdecl;
    /// <summary>Flush pager cache to disk for all databases attached to connection.</summary>
    db_cacheflush: function(db: Pointer): Integer; cdecl;

    // ----- 3.12.0+ -----

    /// <summary>Return most recent system errno seen by VFS on this connection.</summary>
    system_errno: function(db: Pointer): Integer; cdecl;

    // ----- 3.14.0+ -----

    /// <summary>Install extended trace callbacks with mask uMask (prepare/execute/profile/etc.).</summary>
    trace_v2: function(db: Pointer; uMask: Cardinal; xTrace2: sqlite3_xTrace2; pCtx: Pointer): Integer; cdecl;
    /// <summary>Return SQL text with bound parameter values expanded.</summary>
    expanded_sql: function(st: Pointer): PAnsiChar; cdecl;

    // ----- 3.18.0+ -----

    /// <summary>Override the ROWID returned by last_insert_rowid().</summary>
    set_last_insert_rowid: procedure(db: Pointer; v: Int64); cdecl;

    // ----- 3.20.0+ -----

    /// <summary>Prepare SQL (UTF-8) with v3 flags (e.g., SQLITE_PREPARE_PERSISTENT).</summary>
    prepare_v3: function(db: Pointer; const zSql: PAnsiChar; nByte: Integer; prepFlags: Cardinal;
                         var ppStmt: Pointer; pzTail: PPAnsiChar): Integer; cdecl;
    /// <summary>Prepare SQL (UTF-16) with v3 flags.</summary>
    prepare16_v3: function(db: Pointer; const zSql16: Pointer; nByte: Integer; prepFlags: Cardinal;
                           var ppStmt: Pointer; pzTail: PPointer): Integer; cdecl;
    /// <summary>Bind a typed pointer as a parameter with a type-tag string and destructor.</summary>
    bind_pointer: function(st: Pointer; i: Integer; p: Pointer; const zPTName: PAnsiChar; xDestroy: sqlite3_xDestroy): Integer; cdecl;
    /// <summary>Set function result to typed pointer with type-tag string and destructor.</summary>
    result_pointer: procedure(ctx: Pointer; p: Pointer; const zPTName: PAnsiChar; xDestroy: sqlite3_xDestroy); cdecl;
    /// <summary>Extract typed pointer from Pointer with expected type-tag.</summary>
    value_pointer: function(v: Pointer; const zPTName: PAnsiChar): Pointer; cdecl;
    /// <summary>Return non-zero if called from vtab xUpdate with no-change flag.</summary>
    vtab_nochange: function(ctx: Pointer): Integer; cdecl;
    /// <summary>Return non-zero if Pointer represents a SQL parameter marked as NOCHANGE.</summary>
    value_nochange: function(v: Pointer): Integer; cdecl;
    /// <summary>Return collation name for argument N in xBestIndex (vtab planning).</summary>
    vtab_collation: function(info: Pointer; N: Integer): PAnsiChar; cdecl;

    // ----- 3.24.0+ -----

    /// <summary>Return total number of SQL keywords recognized by tokenizer.</summary>
    keyword_count: function: Integer; cdecl;
    /// <summary>Return Nth keyword text and its length.</summary>
    keyword_name: function(N: Integer; out zName: PAnsiChar; out nName: Integer): Integer; cdecl;
    /// <summary>Return non-zero if given text is a SQL keyword.</summary>
    keyword_check: function(const zName: PAnsiChar; nName: Integer): Integer; cdecl;
    /// <summary>Create SQLite string builder object tied to connection allocator.</summary>
    str_new: function(db: Pointer): Pointer; cdecl;
    /// <summary>Finish builder and return heap-allocated C string; frees builder.</summary>
    str_finish: function(s: Pointer): PAnsiChar; cdecl;
    /// <summary>Append formatted text to builder (printf-style).</summary>
    str_appendf: procedure(s: Pointer; const fmt: PAnsiChar); cdecl; // varargs omitted
    /// <summary>Append formatted text using Pointer.</summary>
    str_vappendf: procedure(s: Pointer; const fmt: PAnsiChar; ap: Pointer); cdecl;
    /// <summary>Append up to N bytes from zIn to builder.</summary>
    str_append: procedure(s: Pointer; const zIn: PAnsiChar; N: Integer); cdecl;
    /// <summary>Append entire nul-terminated string to builder.</summary>
    str_appendall: procedure(s: Pointer; const zIn: PAnsiChar); cdecl;
    /// <summary>Append N copies of character C to builder.</summary>
    str_appendchar: procedure(s: Pointer; N: Integer; C: AnsiChar); cdecl;
    /// <summary>Reset builder to empty state, preserving buffer.</summary>
    str_reset: procedure(s: Pointer); cdecl;
    /// <summary>Return error code associated with builder (SQLITE_NOMEM etc.).</summary>
    str_errcode: function(s: Pointer): Integer; cdecl;
    /// <summary>Return current length of builder in bytes (excluding nul).</summary>
    str_length: function(s: Pointer): Integer; cdecl;
    /// <summary>Return pointer to builder internal buffer (may be NULL).</summary>
    str_value: function(s: Pointer): PAnsiChar; cdecl;

    /// <summary>Create a window function with step/final/value/inverse and optional destructor.</summary>
    create_window_function: function(db: Pointer; const zFunc: PAnsiChar; nArg, eTextRep: Integer; pApp: Pointer; xStep: sqlite3_xFunc; xFinal: sqlite3_xValueFunc; xValue: sqlite3_xValueFunc; xInv: sqlite3_xFunc; xDestroy: sqlite3_xDestroy): Integer; cdecl;

    // ----- 3.26.0+ -----

    /// <summary>Return normalized SQL text for a prepared statement.</summary>
    normalized_sql: function(st: Pointer): PAnsiChar; cdecl;

    // ----- 3.28.0+ -----

    /// <summary>Return non-zero if statement is an EXPLAIN (or EXPLAIN QUERY PLAN).</summary>
    stmt_isexplain: function(st: Pointer): Integer; cdecl;
    /// <summary>Return non-zero if value originated from a bound parameter (not from column expression).</summary>
    value_frombind: function(v: Pointer): Integer; cdecl;

    // ----- 3.30.0+ -----

    /// <summary>Drop all virtual table modules except those listed (azKeep NULL-terminated array).</summary>
    drop_modules: function(db: Pointer; const azKeep: PPAnsiChar): Integer; cdecl;

    // ----- 3.31.0+ -----

    /// <summary>Set hard heap limit in bytes; returns previous limit.</summary>
    hard_heap_limit64: function(N: Int64): Int64; cdecl;
    /// <summary>Return pointer to Nth URI parameter key in filename (or NULL).</summary>
    uri_key: function(const zUri: PAnsiChar; N: Integer): PAnsiChar; cdecl;
    /// <summary>Return database filename part (excluding -journal/-wal suffixes).</summary>
    filename_database: function(const z: PAnsiChar): PAnsiChar; cdecl;
    /// <summary>Return corresponding journal filename for database filename z.</summary>
    filename_journal: function(const z: PAnsiChar): PAnsiChar; cdecl;
    /// <summary>Return corresponding WAL filename for database filename z.</summary>
    filename_wal: function(const z: PAnsiChar): PAnsiChar; cdecl;

    // ----- 3.32.0+ -----

    /// <summary>Create composite filename from parts and URI parameters.</summary>
    create_filename: function(const zDb, zJournal, zWal: PAnsiChar; nParam: Integer; const azParam: PPAnsiChar): PAnsiChar; cdecl;
    /// <summary>Free filename returned by create_filename().</summary>
    free_filename: procedure(const zFilename: PAnsiChar); cdecl;
    /// <summary>Return Pointer* associated with a database filename string.</summary>
    database_file_object: function(const zFilename: PAnsiChar): Pointer; cdecl;

    // ----- 3.34.0+ -----

    /// <summary>Return transaction state for schema zSchema (e.g., SQLITE_TXN_NONE/READ/WRITE).</summary>
    txn_state: function(db: Pointer; const zSchema: PAnsiChar): Integer; cdecl;

    // ----- 3.36.1+ -----

    /// <summary>Return 64-bit number of rows changed by most recent operation.</summary>
    changes64: function(db: Pointer): Int64; cdecl;
    /// <summary>Return 64-bit total number of rows changed since open.</summary>
    total_changes64: function(db: Pointer): Int64; cdecl;

    // ----- 3.37.0+ -----

    /// <summary>Install autovacuum-pages callback (per-connection page reclamation notifications).</summary>
    autovacuum_pages: function(db: Pointer; xCallback: sqlite3_xAutovacuumCallback; pArg: Pointer; xDestroy: sqlite3_xDestroy): Integer; cdecl;

    // ----- 3.38.0+ -----

    /// <summary>Return character offset of parse error in most recent prepare (or -1).</summary>
    error_offset: function(db: Pointer): Integer; cdecl;
    /// <summary>Fetch rhs Pointer for constraint iCons in xBestIndex.</summary>
    vtab_rhs_value: function(info: Pointer; iCons: Integer; out v: Pointer): Integer; cdecl;
    /// <summary>Return DISTINCT mode requested by core for vtab planning.</summary>
    vtab_distinct: function(info: Pointer): Integer; cdecl;
    /// <summary>Mark constraint iCons as an IN(...) constraint; bVal indicates if values are available.</summary>
    vtab_in: function(info: Pointer; iCons, bVal: Integer): Integer; cdecl;
    /// <summary>Begin iterate values for IN(...) constraint; returns first value.</summary>
    vtab_in_first: function(v: Pointer; out pOut: Pointer): Integer; cdecl;
    /// <summary>Advance iterator for IN(...) values; returns next value.</summary>
    vtab_in_next: function(v: Pointer; out pOut: Pointer): Integer; cdecl;

    // ----- 3.39.0+ -----

    /// <summary>Deserialize a database into memory for schema zSchema (experimental flags).</summary>
    deserialize: function(db: Pointer; const zSchema: PAnsiChar; pData: PByte; szDb, szBuf: Int64; mFlags: Cardinal): Integer; cdecl;
    /// <summary>Serialize a database to a contiguous memory buffer; returns size via pSize.</summary>
    serialize: function(db: Pointer; const zSchema: PAnsiChar; out pSize: Int64; mFlags: Cardinal): PByte; cdecl;
    /// <summary>Return name of Nth database attached to connection.</summary>
    db_name: function(db: Pointer; N: Integer): PAnsiChar; cdecl;

    // ----- 3.40.0+ -----

    /// <summary>Return internal encoding flag for Pointer (SQLITE_UTF8/UTF16BE/UTF16LE).</summary>
    value_encoding: function(v: Pointer): Integer; cdecl;

    // ----- 3.41.0+ -----

    /// <summary>Return non-zero if connection has been interrupted since last check.</summary>
    is_interrupted: function(db: Pointer): Integer; cdecl;

    // ----- 3.43.0+ -----

    /// <summary>Return non-zero if statement is EXPLAIN and which mode (eMode).</summary>
    stmt_explain: function(st: Pointer; eMode: Integer): Integer; cdecl;

    // ----- 3.44.0+ -----

    /// <summary>Get opaque client data by name stored on connection.</summary>
    get_clientdata: function(db: Pointer; const zName: PAnsiChar): Pointer; cdecl;
    /// <summary>Set opaque client data by name with destructor; returns error code.</summary>
    set_clientdata: function(db: Pointer; const zName: PAnsiChar; p: Pointer; xDestroy: sqlite3_xDestroy): Integer; cdecl;

    // ----- 3.50.0+ -----

    /// <summary>Set setlk-timeout (ms) for VFS blocking locks on WAL databases; flags control behavior.</summary>
    setlk_timeout: function(db: Pointer; ms: Integer; flags: Integer): Integer; cdecl;

    // ----- 3.51.0+ -----

    /// <summary>Set error message on the connection explicitly (code + message).</summary>
    set_errmsg: function(db: Pointer; ec: Integer; const z: PAnsiChar): Integer; cdecl;
    /// <summary>Per-connection status metrics with 64-bit counters.</summary>
    db_status64: function(db: Pointer; op: Integer; out cur, hi: Int64; resetFlag: Integer): Integer; cdecl;

    // since 3.52.0
    /// <summary>Truncate an sqlite3_str builder to N bytes or less.</summary>
    str_truncate: procedure(s: Pointer; N: Integer); cdecl;
    // since 3.52.0
    /// <summary>Destroy sqlite3_str and its current string content.</summary>
    str_free: procedure(s: Pointer); cdecl;
    // since 3.52.0
    /// <summary>Bind an array value to the first argument of carray().</summary>
    carray_bind: function(st: Pointer; i: Integer; aData: Pointer; nData, mFlags: Integer; xDestroy: sqlite3_xDestroy): Integer; cdecl;
    // since 3.52.0
    /// <summary>Bind an array value to carray() with a separate destructor argument.</summary>
    carray_bind_v2: function(st: Pointer; i: Integer; aData: Pointer; nData, mFlags: Integer; xDestroy: sqlite3_xDestroy; pDestroy: Pointer): Integer; cdecl;
  end;
  {$endregion}

  Psqlite3_vtab = ^sqlite3_vtab;
  Psqlite3_vtab_cursor = ^sqlite3_vtab_cursor;
  Psqlite3_module = ^sqlite3_module;

  {$region ' Virtual Table Instance Object'}
  /// <summary>Virtual Table Instance Object</summary>
  sqlite3_vtab = record
  /// <summary>The module for this virtual table</summary>
    pModule: Psqlite3_module;
    /// <summary>Number of open cursors</summary>
    nRef: integer;
    /// <summary>Error message from sqlite3_mprintf()</summary>
    zErrMsg: PAnsiChar;
  end;
 {$endregion}

  {$region ' Virtual Table Cursor Object'}
  /// <summary>Virtual Table Cursor Object</summary>
  sqlite3_vtab_cursor = record
    /// <summary>Virtual table of this cursor</summary>
    pVtab: Psqlite3_vtab;
  end;
 {$endregion}

  {$region ' Virtual Table Indexing Information'}
  Psqlite3_index_constraint = ^sqlite3_index_constraint;
  /// <summary>WHERE-clause constraint descriptor passed to xBestIndex (input).</summary>
  sqlite3_index_constraint = record
    /// <summary>Constrained column index; -1 denotes the implicit ROWID.</summary>
    iColumn: Integer;
    /// <summary>Constraint operator code (e.g. SQLITE_INDEX_CONSTRAINT_EQ, GT, LE, etc.).</summary>
    op: Byte; // unsigned char
    /// <summary>Non-zero if this constraint is usable by the virtual table.</summary>
    usable: Byte; // unsigned char
    /// <summary>Internal use by the core; xBestIndex must ignore this field.</summary>
    iTermOffset: Integer;
  end;

  Psqlite3_index_orderby = ^sqlite3_index_orderby;
  /// <summary>ORDER BY term descriptor passed to xBestIndex (input).</summary>
  sqlite3_index_orderby = record
    /// <summary>Column number referenced by this ORDER BY term.</summary>
    iColumn: Integer;
    /// <summary>Non-zero for DESC order; zero for ASC.</summary>
    desc: Byte; // unsigned char
  end;

  Psqlite3_index_constraint_usage = ^sqlite3_index_constraint_usage;
  /// <summary>Usage hints returned by xBestIndex for each input constraint (output).</summary>
  sqlite3_index_constraint_usage = record
    /// <summary>If &gt; 0, this constraint becomes an argument to xFilter at position argvIndex.</summary>
    argvIndex: Integer;
    /// <summary>Non-zero means the core should omit emitting a separate test for this constraint.</summary>
    omit: Byte; // unsigned char
  end;

  Psqlite3_index_info = ^sqlite3_index_info;
  /// <summary>Composite information block exchanged with xBestIndex.</summary>
  sqlite3_index_info = record
    // --- Inputs ---

    /// <summary>Number of entries in aConstraint.</summary>
    nConstraint: Integer;

    /// <summary>Array of WHERE-clause constraints (length = nConstraint).</summary>
    aConstraint: Psqlite3_index_constraint;

    /// <summary>Number of ORDER BY terms in the query.</summary>
    nOrderBy: Integer;

    /// <summary>Array describing ORDER BY terms (length = nOrderBy).</summary>
    aOrderBy: Psqlite3_index_orderby;

    // --- Outputs ---

    /// <summary>Per-constraint usage directives returned by xBestIndex (length = nConstraint).</summary>
    aConstraintUsage: Psqlite3_index_constraint_usage;

    /// <summary>Arbitrary integer chosen by xBestIndex to identify the selected index/plan (passed back to xFilter).</summary>
    idxNum: Integer;

    /// <summary>Optional plan string (allocated via sqlite3_malloc / sqlite3_mprintf if needToFreeIdxStr is non-zero).</summary>
    idxStr: PAnsiChar;

    /// <summary>If non-zero, SQLite will free idxStr using sqlite3_free().</summary>
    needToFreeIdxStr: Integer;

    /// <summary>Set non-zero if the virtual table promises rows are already in the requested ORDER BY.</summary>
    orderByConsumed: Integer;

    /// <summary>Estimated cost of using the proposed plan (smaller is better).</summary>
    estimatedCost: Double;

    /// <summary>Estimated number of rows produced by the plan (available since 3.8.2).</summary>
    estimatedRows: int64;

    /// <summary>Scan flags mask (SQLITE_INDEX_SCAN_*; available since 3.9.0).</summary>
    idxFlags: Integer;

    /// <summary>Bitmask of columns used by the statement (available since 3.10.0).</summary>
    colUsed: uint64;
  end;
  {$endregion}

  {$region ' Virtual Table Object'}
  sqlite3_module = record
    /// <summary>Structure version: 1 -> base methods; 2 -> +xSavepoint/xRelease/xRollbackTo; 3 -> +xShadowName; 4 -> +xIntegrity.</summary>
    iVersion: Integer;

    // --- Version 1 methods ---

    /// <summary>Create a new virtual table instance for CREATE VIRTUAL TABLE; return the new vtab via ppVTab and optionally error text via pzErr.</summary>
    xCreate: function(db: Pointer; pAux: Pointer; argc: Integer; const argv: PPAnsiChar; var ppVTab: Psqlite3_vtab; var pzErr: PAnsiChar): Integer; cdecl;
    /// <summary>Connect to an existing virtual table (for ATTACH/CONNECT); return vtab via ppVTab and optional error text via pzErr.</summary>
    xConnect: function(db: Pointer; pAux: Pointer; argc: Integer; const argv: PPAnsiChar; var ppVTab: Psqlite3_vtab; var pzErr: PAnsiChar): Integer; cdecl;
    /// <summary>Advise the query planner: compute optimal index/constraint usage in pInfo.</summary>
    xBestIndex: function(pVTab: Psqlite3_vtab; pInfo: Psqlite3_index_info): Integer; cdecl;
    /// <summary>Disconnect from a virtual table instance (inverse of xConnect).</summary>
    xDisconnect: function(pVTab: Psqlite3_vtab): Integer; cdecl;
    /// <summary>Destroy a virtual table instance (inverse of xCreate).</summary>
    xDestroy: function(pVTab: Psqlite3_vtab): Integer; cdecl;
    /// <summary>Open a new cursor on the virtual table; return it via ppCursor.</summary>
    xOpen: function(pVTab: Psqlite3_vtab; var ppCursor: Psqlite3_vtab_cursor): Integer; cdecl;
    /// <summary>Close (destroy) a cursor previously opened by xOpen.</summary>
    xClose: function(pCursor: Psqlite3_vtab_cursor): Integer; cdecl;
    /// <summary>Start a cursor scan using idxNum/idxStr and argv arguments produced by xBestIndex.</summary>
    xFilter: function(pCursor: Psqlite3_vtab_cursor; idxNum: Integer; const idxStr: PAnsiChar; argc: Integer; pArgv: Psqlite3_arg_values): Integer; cdecl;
    /// <summary>Advance the cursor to the next row.</summary>
    xNext: function(pCursor: Psqlite3_vtab_cursor): Integer; cdecl;
    /// <summary>Return nonzero if the cursor has reached end-of-scan (EOF), otherwise 0.</summary>
    xEof: function(pCursor: Psqlite3_vtab_cursor): Integer; cdecl;
    /// <summary>Compute and return a column value for the current row into context pCtx (column iCol).</summary>
    xColumn: function(pCursor: Psqlite3_vtab_cursor; pCtx: Pointer; iCol: Integer): Integer; cdecl;
    /// <summary>Return the ROWID for the current row via pRowid.</summary>
    xRowid: function(pCursor: Psqlite3_vtab_cursor; pRowid: PInt64): Integer; cdecl;
    /// <summary>Insert/Update/Delete a row. argc/argv describe the operation; on INSERT write new rowid to *pRowid.</summary>
    xUpdate: function(pVTab: Psqlite3_vtab; argc: Integer; pArgv: Psqlite3_arg_values; pRowid: Pint64): Integer; cdecl;
    /// <summary>Begin a transaction on the virtual table.</summary>
    xBegin: function(pVTab: Psqlite3_vtab): Integer; cdecl;
    /// <summary>Prepare for commit (sync); called before xCommit.</summary>
    xSync: function(pVTab: Psqlite3_vtab): Integer; cdecl;
    /// <summary>Commit a transaction.</summary>
    xCommit: function(pVTab: Psqlite3_vtab): Integer; cdecl;
    /// <summary>Rollback a transaction.</summary>
    xRollback: function(pVTab: Psqlite3_vtab): Integer; cdecl;
    /// <summary>Custom function lookup by name/arity. Set *pxFunc and *ppArg if handled; return nonzero on success.</summary>
    xFindFunction: function(pVTab: Psqlite3_vtab; nArg: Integer; const zName: PAnsiChar; var pxFunc: sqlite3_xFunc; var ppArg: Pointer): Integer; cdecl;
    /// <summary>Rename the table to zNew (ALTER TABLE ... RENAME TO ...).</summary>
    xRename: function(pVTab: Psqlite3_vtab; const zNew: PAnsiChar): Integer; cdecl;

    // --- Version 2 additions ---

    /// <summary>Start a SAVEPOINT with the given index.</summary>
    xSavepoint: function(pVTab: Psqlite3_vtab; iSavepoint: Integer): Integer; cdecl;
    /// <summary>Release (commit) a SAVEPOINT with the given index.</summary>
    xRelease: function(pVTab: Psqlite3_vtab; iSavepoint: Integer): Integer; cdecl;
    /// <summary>Rollback to a SAVEPOINT with the given index.</summary>
    xRollbackTo: function(pVTab: Psqlite3_vtab; iSavepoint: Integer): Integer; cdecl;

    // --- Version 3 addition ---

    /// <summary>Return nonzero if zName is a shadow table for this module (affects DDL visibility/behavior).</summary>
    xShadowName: function(const zName: PAnsiChar): Integer; cdecl;

    // --- Version 4 addition ---

    /// <summary>Run integrity checks; may allocate an error message into pzErr; mFlags controls check scope.</summary>
    xIntegrity: function(pVTab: Psqlite3_vtab; const zSchema, zTabName: PAnsiChar; mFlags: Integer; var pzErr: PAnsiChar): Integer; cdecl;
  end;
  {$endregion}

  {$region ' sqlite3_loadext_entry'}
  /// <summary>function signature used for all extension entry points.</summary>
  /// <param name="db">Handle to the database.
  /// </param>
  /// <param name="pzErrMsg">Used to set error string on failure.
  /// </param>
  /// <param name="pThunk">pointer to sqlite3_api_routines
  /// </param>
  /// <returns>SQLITE_OK (0) if extention loaded succefully; otherwise error code (1)
  /// </returns>
  sqlite3_loadext_entry = function(db: Pointer; pzErrMsg: PPAnsiChar; pThunk: Psqlite3_api_routines): Integer; cdecl;
 {$endregion}

implementation

end.
