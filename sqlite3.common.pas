unit sqlite3.common;

interface
{$include 'sqlite3.config.inc'}
{$IFDEF MSWINDOWS}
{$ENDIF}
uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,{$ENDIF}
  System.Classes, System.SysUtils, System.Math
  ;
type ESQLite3Exception = class(Exception);

const
  SQLITE_MEMORY_DB_NAME = ':memory:';
  SQLITE_TEMP_DB_URI = 'file:';
  SQLITE_TEMP_DB_FILE = ':temporary:';
  SQLITE_MAINDB_ALIAS = 'main';
  SQLITE_IDENTIFIER_QUOTE_CHAR = '"';
  SQLITE_VERSION_NUMBER = 3053004;
{$IFDEF UNDERSCOREIMPORTNAME}
  SQLITE_METHOD_PREFIX = '_';
{$ELSE}
  SQLITE_METHOD_PREFIX = '';
{$ENDIF}
  SID_SqliteAPIClient = '{27EAF153-4DE8-4791-8D64-6AB4D4935100}';
  SID_SqliteAPI = '{76CCDBE9-24D8-48E9-92DC-B4B79C1D4D39}';
type
  PPPAnsiChar = ^PMarshaledAString;

  MarshaledUtf8String = PUtf8Char;
  PMarshaledUtf8String = ^MarshaledUtf8String;
  PMarshaledUtf8Strings = ^MarshaledUtf8Strings;
  MarshaledUtf8Strings = array[0..MaxInt div SizeOf(PMarshaledUtf8String) - 1] of MarshaledUtf8String;

  PMarshaledAStrings = ^MarshaledAStrings;
  MarshaledAStrings = array[0..MaxInt div SizeOf(PMarshaledAString) - 1] of MarshaledAString;

  TSQLite3Version = record
    iMajor: smallint;
    iMinor: smallint;
    iRelease: Integer;
  constructor Create(const AVersion: string); overload;
  constructor Create(const AVersion: Cardinal); overload;
  end;
  PSQLite3version = ^TSQLite3Version;

  TSQLite3Extention = (
    seStringsVT
    {$ifdef SQLITE3_USE_STEMMER}
    ,seFts5StemmerVT{$endif}
    {$ifdef SQLITE3_REGULAR_EXPRESSIONS}
    ,seRegexpFuncs{$endif}
    ,seMathFuncs
    ,seStringConcatFuncs
    ,seZlibCompressFuns
    ,seArrayFuns
    ,seClosureVT
    ,seCSVVT
    ,seUnionVT
    ,seSQLZipVT
    ,seMemVFS
    ,seDefineEval
    ,seZOrderFunc
    ,seUUIDFunc
    ,seUnicode
    ,seBaseXXFunc
    );

    TSQLite3Extentions = set of TSQLite3Extention;

  {$REGION 'SQLite3 error-codes'}
const
    SQLITE_OK = 0;    // Successful result
    SQLITE_ERROR       =  1; // SQL error or missing database
    SQLITE_INTERNAL = 2; // Internal logic error in SQLite
    SQLITE_PERM = 3; // Access permission denied
    SQLITE_ABORT = 4; // Callback routine requested an abort
    SQLITE_BUSY = 5; // The database file is locked
    SQLITE_LOCKED = 6; // A table in the database is locked
    SQLITE_NOMEM = 7; // A malloc() failed
    SQLITE_READONLY = 8; // Attempt to write a readonly database
    SQLITE_INTERRUPT = 9; // Operation terminated by sqlite3_interrupt()
    SQLITE_IOERR = 10; // Some kind of disk I/O error occurred
    SQLITE_CORRUPT = 11; // The database disk image is malformed
    SQLITE_NOTFOUND = 12; // Unknown opcode in sqlite3_file_control()
    SQLITE_FULL = 13; // Insertion failed because database is full
    SQLITE_CANTOPEN = 14; // Unable to open the database file
    SQLITE_PROTOCOL = 15; // Database lock protocol error
    SQLITE_EMPTY = 16; // Database is empty
    SQLITE_SCHEMA = 17; // The database schema changed
    SQLITE_TOOBIG = 18; // String or BLOB exceeds size limit
    SQLITE_CONSTRAINT = 19; // Abort due to constraint violation
    SQLITE_MISMATCH = 20; // Data type mismatch
    SQLITE_MISUSE = 21; // Library used incorrectly
    SQLITE_NOLFS = 22; // Uses OS features not supported on host
    SQLITE_AUTH = 23; // Authorization denied
    SQLITE_FORMAT = 24; // Auxiliary database format error
    SQLITE_RANGE = 25; // 2nd parameter to sqlite3_bind out of range
    SQLITE_NOTADB = 26; // File opened that is not a database file
    SQLITE_NOTICE = 27;  // Notifications from sqlite3_log()
    SQLITE_WARNING = 28;  // Warnings from sqlite3_log()
    SQLITE_ROW = 100; // sqlite3_step() has another row ready
    SQLITE_DONE = 101; // sqlite3_step() has finished executing
{$ENDREGION 'error-codes'}

  {$REGION 'SQLite3 extended error codes'}
const
  SQLITE_ERROR_MISSING_COLLSEQ    = (SQLITE_ERROR or (1 shl 8));
  SQLITE_ERROR_RETRY              = (SQLITE_ERROR or (2 shl 8));
  SQLITE_ERROR_SNAPSHOT           = (SQLITE_ERROR or (3 shl 8));
  SQLITE_ERROR_RESERVESIZE        = (SQLITE_ERROR or (4 shl 8));
  SQLITE_ERROR_KEY                = (SQLITE_ERROR or (5 shl 8));
  SQLITE_ERROR_UNABLE             = (SQLITE_ERROR or (6 shl 8));
  SQLITE_IOERR_READ = (SQLITE_IOERR or (1 shl 8));
  SQLITE_IOERR_SHORT_READ = (SQLITE_IOERR or (2 shl 8));
  SQLITE_IOERR_WRITE = (SQLITE_IOERR or (3 shl 8));
  SQLITE_IOERR_FSYNC = (SQLITE_IOERR or (4 shl 8));
  SQLITE_IOERR_DIR_FSYNC = (SQLITE_IOERR or (5 shl 8));
  SQLITE_IOERR_TRUNCATE = (SQLITE_IOERR or (6 shl 8));
  SQLITE_IOERR_FSTAT = (SQLITE_IOERR or (7 shl 8));
  SQLITE_IOERR_UNLOCK = (SQLITE_IOERR or (8 shl 8));
  SQLITE_IOERR_RDLOCK = (SQLITE_IOERR or (9 shl 8));
  SQLITE_IOERR_DELETE = (SQLITE_IOERR or (10 shl 8));
  SQLITE_IOERR_BLOCKED = (SQLITE_IOERR or (11 shl 8));
  SQLITE_IOERR_NOMEM = (SQLITE_IOERR or (12 shl 8));
  SQLITE_IOERR_ACCESS = (SQLITE_IOERR or (13 shl 8));
  SQLITE_IOERR_CHECKRESERVEDLOCK = (SQLITE_IOERR or (14 shl 8));
  SQLITE_IOERR_LOCK = (SQLITE_IOERR or (15 shl 8));
  SQLITE_IOERR_CLOSE = (SQLITE_IOERR or (16 shl 8));
  SQLITE_IOERR_DIR_CLOSE = (SQLITE_IOERR or (17 shl 8));
  SQLITE_IOERR_SHMOPEN = (SQLITE_IOERR or (18 shl 8));
  SQLITE_IOERR_SHMSIZE = (SQLITE_IOERR or (19 shl 8));
  SQLITE_IOERR_SHMLOCK = (SQLITE_IOERR or (20 shl 8));
  SQLITE_IOERR_SHMMAP = (SQLITE_IOERR or (21 shl 8));
  SQLITE_IOERR_SEEK = (SQLITE_IOERR or (22 shl 8));
  SQLITE_IOERR_DELETE_NOENT = (SQLITE_IOERR or (23 shl 8));
  SQLITE_IOERR_MMAP = (SQLITE_IOERR or (24 shl 8));
  SQLITE_IOERR_GETTEMPPATH = (SQLITE_IOERR or (25 shl 8));
  SQLITE_IOERR_CONVPATH = (SQLITE_IOERR or (26 shl 8));
  SQLITE_IOERR_VNODE = (SQLITE_IOERR or (27 shl 8));
  SQLITE_IOERR_AUTH               = (SQLITE_IOERR or (28 shl 8));
  SQLITE_IOERR_BEGIN_ATOMIC       = (SQLITE_IOERR or (29 shl 8));
  SQLITE_IOERR_COMMIT_ATOMIC      = (SQLITE_IOERR or (30 shl 8));
  SQLITE_IOERR_ROLLBACK_ATOMIC    = (SQLITE_IOERR or (31 shl 8));
  SQLITE_IOERR_DATA               = (SQLITE_IOERR or (32 shl 8));
  SQLITE_IOERR_CORRUPTFS          = (SQLITE_IOERR or (33 shl 8));
  SQLITE_IOERR_IN_PAGE            = (SQLITE_IOERR or (34 shl 8));
  SQLITE_IOERR_BADKEY             = (SQLITE_IOERR or (35 shl 8));
  SQLITE_IOERR_CODEC              = (SQLITE_IOERR or (36 shl 8));
  SQLITE_LOCKED_SHAREDCACHE = (SQLITE_LOCKED or (1 shl 8));
  SQLITE_LOCKED_VTAB              = (SQLITE_LOCKED or (2 shl 8));
  SQLITE_BUSY_RECOVERY = (SQLITE_BUSY or (1 shl 8));
  SQLITE_BUSY_SNAPSHOT = (SQLITE_BUSY or (2 shl 8));
  SQLITE_BUSY_TIMEOUT             = (SQLITE_BUSY or (3 shl 8));
  SQLITE_CANTOPEN_NOTEMPDIR = (SQLITE_CANTOPEN or (1 shl 8));
  SQLITE_CANTOPEN_ISDIR = (SQLITE_CANTOPEN or (2 shl 8));
  SQLITE_CANTOPEN_FULLPATH = (SQLITE_CANTOPEN or (3 shl 8));
  SQLITE_CANTOPEN_CONVPATH = (SQLITE_CANTOPEN or (4 shl 8));
  SQLITE_CANTOPEN_DIRTYWAL        = (SQLITE_CANTOPEN or (5 shl 8)); // Not Used
  SQLITE_CANTOPEN_SYMLINK         = (SQLITE_CANTOPEN or (6 shl 8));
  SQLITE_CORRUPT_VTAB = (SQLITE_CORRUPT or (1 shl 8));
  SQLITE_CORRUPT_SEQUENCE         = (SQLITE_CORRUPT or (2 shl 8));
  SQLITE_CORRUPT_INDEX            = (SQLITE_CORRUPT or (3 shl 8));
  SQLITE_READONLY_RECOVERY = (SQLITE_READONLY or (1 shl 8));
  SQLITE_READONLY_CANTLOCK = (SQLITE_READONLY or (2 shl 8));
  SQLITE_READONLY_ROLLBACK       = (SQLITE_READONLY or (3 shl 8));
  SQLITE_READONLY_DBMOVED        = (SQLITE_READONLY or (4 shl 8));
  SQLITE_READONLY_CANTINIT        = (SQLITE_READONLY or (5 shl 8));
  SQLITE_READONLY_DIRECTORY       = (SQLITE_READONLY or (6 shl 8));
  SQLITE_ABORT_ROLLBACK          = (SQLITE_ABORT or (2 shl 8));
  SQLITE_CONSTRAINT_CHECK        = (SQLITE_CONSTRAINT or (1 shl 8));
  SQLITE_CONSTRAINT_COMMITHOOK   = (SQLITE_CONSTRAINT or (2 shl 8));
  SQLITE_CONSTRAINT_FOREIGNKEY   = (SQLITE_CONSTRAINT or (3 shl 8));
  SQLITE_CONSTRAINT_FUNCTION     = (SQLITE_CONSTRAINT or (4 shl 8));
  SQLITE_CONSTRAINT_NOTNULL      = (SQLITE_CONSTRAINT or (5 shl 8));
  SQLITE_CONSTRAINT_PRIMARYKEY   = (SQLITE_CONSTRAINT or (6 shl 8));
  SQLITE_CONSTRAINT_TRIGGER      = (SQLITE_CONSTRAINT or (7 shl 8));
  SQLITE_CONSTRAINT_UNIQUE       = (SQLITE_CONSTRAINT or (8 shl 8));
  SQLITE_CONSTRAINT_VTAB         = (SQLITE_CONSTRAINT or (9 shl 8));
  SQLITE_CONSTRAINT_ROWID        = (SQLITE_CONSTRAINT or(10 shl 8));
  SQLITE_CONSTRAINT_PINNED        = (SQLITE_CONSTRAINT or(11 shl 8));
  SQLITE_CONSTRAINT_DATATYPE      = (SQLITE_CONSTRAINT or(12 shl 8));
  SQLITE_NOTICE_RECOVER_WAL      = (SQLITE_NOTICE or (1 shl 8));
  SQLITE_NOTICE_RECOVER_ROLLBACK = (SQLITE_NOTICE or (2 shl 8));
  SQLITE_NOTICE_RBU              = (SQLITE_NOTICE or (3 shl 8));
  SQLITE_WARNING_AUTOINDEX       = (SQLITE_WARNING or (1 shl 8));
  SQLITE_AUTH_USER               = (SQLITE_AUTH or (1 shl 8));
  SQLITE_OK_LOAD_PERMANENTLY      = (SQLITE_OK or (1 shl 8));
  SQLITE_OK_SYMLINK               = (SQLITE_OK or (2 shl 8));
{$ENDREGION 'extended error codes'}

  {$REGION 'SQLite3 error-descriptions'}
{$IFNDEF SQLITE_RUSSIAN_LOCALE}
resourcestring
  RS_SQLITE_MSG_OK = 'Successful result';
  RS_SQLITE_MSG_INTERNAL = 'An internal logic error in SQLite';
  RS_SQLITE_MSG_PERM = 'Access permission denied';
  RS_SQLITE_MSG_ERROR = 'SQL error or missing database';
  RS_SQLITE_MSG_ABORT = 'Callback routine requested an abort';
  RS_SQLITE_MSG_BUSY = 'The database file is locked';
  RS_SQLITE_MSG_LOCKED = 'A table in the database is locked';
  RS_SQLITE_MSG_NOMEM = 'A malloc() failed';
  RS_SQLITE_MSG_READONLY = 'Attempt to write a readonly database';
  RS_SQLITE_MSG_INTERRUPT = 'Operation terminated by sqlite3_interrupt()';
  RS_SQLITE_MSG_IOERR = 'Some kind of disk I/O error occurred';
  RS_SQLITE_MSG_CORRUPT = 'The database disk image is malformed';
  RS_SQLITE_MSG_NOTFOUND = '(Internal Only) Table or record not found';
  RS_SQLITE_MSG_FULL = 'Insertion failed because database is full';
  RS_SQLITE_MSG_CANTOPEN = 'Unable to open the database file';
  RS_SQLITE_MSG_PROTOCOL = 'Database lock protocol error';
  RS_SQLITE_MSG_EMPTY = 'Database is empty';
  RS_SQLITE_MSG_SCHEMA = 'The database schema changed';
  RS_SQLITE_MSG_TOOBIG = 'Too much data for one row of a table';
  RS_SQLITE_MSG_CONSTRAINT = 'Abort due to contraint violation';
  RS_SQLITE_MSG_MISMATCH = 'Data type mismatch';
  RS_SQLITE_MSG_MISUSE = 'Library used incorrectly';
  RS_SQLITE_MSG_NOLFS = 'Uses OS features not supported on host';
  RS_SQLITE_MSG_AUTH = 'Authorization denied';
  RS_SQLITE_MSG_FORMAT = 'Auxiliary database format error';
  RS_SQLITE_MSG_RANGE = '2nd parameter to sqlite3_bind out of range';
  RS_SQLITE_MSG_NOTADB = 'File opened that is not a database file';
  RS_SQLITE_SQLITE_NOTICE = 'SQLITE NOTICE: ';
  RS_SQLITE_SQLITE_WARNING ='SQLITE WARN: ';
  RS_SQLITE_MSG_ROW = 'sqlite3_step() has another row ready';
  RS_SQLITE_MSG_DONE = 'sqlite3_step() has finished executing';
{$ELSE}
resourcestring
  RS_SQLITE_MSG_OK = 'Успешный результат';
  RS_SQLITE_MSG_INTERNAL = 'Внутренняя логическая ошибка в SQLite';
  RS_SQLITE_MSG_PERM = 'В доступе отказано';
  RS_SQLITE_MSG_ERROR = 'Ошибка SQL или отсутствующая база данных';
  RS_SQLITE_MSG_ABORT = 'Процедура обратного вызова запросила прерывание';
  RS_SQLITE_MSG_BUSY = 'Файл базы данных заблокирован';
  RS_SQLITE_MSG_LOCKED = 'Таблица в базе данных заблокирована';
  RS_SQLITE_MSG_NOMEM = 'Ошибка malloc, недостаточно памяти? ';
  RS_SQLITE_MSG_READONLY = 'Попытка записи базы данных, которая защищена от чтения';
  RS_SQLITE_MSG_INTERRUPT = 'Операция прервана внешним обработчиком (sqlite3_interrupt())';
  RS_SQLITE_MSG_IOERR = 'Произошла какая-то ошибка ввода-вывода диска';
  RS_SQLITE_MSG_CORRUPT = 'Файл базы данных поврежден';
  RS_SQLITE_MSG_NOTFOUND = 'Таблица или запись не найдена';
  RS_SQLITE_MSG_FULL = 'Ошибка вставки, так как база данных заполнена';
  RS_SQLITE_MSG_CANTOPEN = 'Не удалось открыть файл базы данных';
  RS_SQLITE_MSG_PROTOCOL = 'Ошибка протокола блокировки базы данных';
  RS_SQLITE_MSG_EMPTY = 'База данных пуста';
  RS_SQLITE_MSG_SCHEMA = 'Изменена схема базы данных';
  RS_SQLITE_MSG_TOOBIG = 'Слишком много данных для одной строки таблицы';
  RS_SQLITE_MSG_CONSTRAINT = 'Abort due to contraint violation';
  RS_SQLITE_MSG_MISMATCH = 'Несоответствие типов данных ';
  RS_SQLITE_MSG_MISUSE = 'Некорректное использование api';
  RS_SQLITE_MSG_NOLFS = 'Попытка вызова метода неподдерживаемого ОС';
  RS_SQLITE_MSG_AUTH = 'В авторизации отказано';
  RS_SQLITE_MSG_FORMAT = 'Ошибка формата вспомогательной базы данных';
  RS_SQLITE_MSG_RANGE = 'sqlite3_bind(): 2-й параметр вне диапазона';
  RS_SQLITE_MSG_NOTADB = 'Открываемый файл не является файлом базы данных';
  RS_SQLITE_SQLITE_NOTICE = 'SQLITE NOTICE: ';
  RS_SQLITE_SQLITE_WARNING ='SQLITE WARN: ';
  RS_SQLITE_MSG_ROW = 'sqlite3_step(): есть еще строки';
  RS_SQLITE_MSG_DONE = 'sqlite3_step(): строк нет';
{$ENDIF}
  {$ENDREGION}

  {$region 'SQLite3 OS Interface File Virtual Methods Object'}

    {$REGION 'flags for file open operations'}
const
  SQLITE_OPEN_READONLY = $00000001; // Ok for sqlite3_open_v2()
  SQLITE_OPEN_READWRITE = $00000002; // Ok for sqlite3_open_v2()
  SQLITE_OPEN_CREATE = $00000004; // Ok for sqlite3_open_v2()
  SQLITE_OPEN_DELETEONCLOSE = $00000008; // VFS only
  SQLITE_OPEN_EXCLUSIVE = $00000010; // VFS only
  SQLITE_OPEN_AUTOPROXY = $00000020; // VFS only
  SQLITE_OPEN_URI = $00000040; // Ok for sqlite3_open_v2()
  SQLITE_OPEN_MEMORY = $00000080; // Ok for sqlite3_open_v2()
  SQLITE_OPEN_MAIN_DB = $00000100; // VFS only
  SQLITE_OPEN_TEMP_DB = $00000200; // VFS only
  SQLITE_OPEN_TRANSIENT_DB = $00000400; // VFS only
  SQLITE_OPEN_MAIN_JOURNAL = $00000800; // VFS only
  SQLITE_OPEN_TEMP_JOURNAL = $00001000; // VFS only
  SQLITE_OPEN_SUBJOURNAL = $00002000; // VFS only
  SQLITE_OPEN_SUPER_JOURNAL = $00004000;  // VFS only
  SQLITE_OPEN_MASTER_JOURNAL = SQLITE_OPEN_SUPER_JOURNAL;  // Legacy alias
  SQLITE_OPEN_NOMUTEX = $00008000;  // Ok for sqlite3_open_v2()
  SQLITE_OPEN_FULLMUTEX = $00010000;  // Ok for sqlite3_open_v2()
  // SQLite 3.7
  SQLITE_OPEN_SHAREDCACHE = $00020000;  // Ok for sqlite3_open_v2()
  SQLITE_OPEN_PRIVATECACHE = $00040000;  // Ok for sqlite3_open_v2()

  SQLITE_OPEN_WAL = $00080000;  // VFS only

  // Reserved:                         $00F00000
  SQLITE_OPEN_NOFOLLOW = $01000000;  // Ok for sqlite3_open_v2()
  // SQLite 3.37.x
  SQLITE_OPEN_EXRESCODE = $02000000;  // Extended result codes
  {$ENDREGION 'flags for file open operations'}

    {$REGION 'flags for os Interface file virtual methods object'}
const
    SQLITE_LOCK_NONE = 0;
    SQLITE_LOCK_SHARED = 1;
    SQLITE_LOCK_RESERVED = 2;
    SQLITE_LOCK_PENDING = 3;
    SQLITE_LOCK_EXCLUSIVE = 4;
    SQLITE_IOCAP_ATOMIC = $00000001;
    SQLITE_IOCAP_ATOMIC512 = $00000002;
    SQLITE_IOCAP_ATOMIC1K = $00000004;
    SQLITE_IOCAP_ATOMIC2K = $00000008;
    SQLITE_IOCAP_ATOMIC4K = $00000010;
    SQLITE_IOCAP_ATOMIC8K = $00000020;
    SQLITE_IOCAP_ATOMIC16K = $00000040;
    SQLITE_IOCAP_ATOMIC32K = $00000080;
    SQLITE_IOCAP_ATOMIC64K = $00000100;
    SQLITE_IOCAP_SAFE_APPEND = $00000200;
    SQLITE_IOCAP_SEQUENTIAL = $00000400;
    SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN = $00000800;
    SQLITE_IOCAP_POWERSAFE_OVERWRITE = $00001000;
    SQLITE_IOCAP_IMMUTABLE = $00002000;
    SQLITE_IOCAP_BATCH_ATOMIC = $00004000;
    SQLITE_IOCAP_SUBPAGE_READ = $00008000;

    SQLITE_SYNC_NORMAL = $00002;
    SQLITE_SYNC_FULL = $00003;
    SQLITE_SYNC_DATAONLY = $00010;

    {$ENDREGION 'flags for os Interface file virtual methods object'}

    {$region 'SQLite3 IO Methods'}
type
  PSQLiteIOMethods = ^TSQLiteIOMethods;

  TSQLiteFile = record
    Methods: PSQLiteIOMethods;
  end;
  PSQLiteFile = ^TSQLiteFile;

  /// <summary>
  /// OS Interface File Virtual Methods API Object
  /// <summary>
  TSQLiteIOMethods = record
    iVersion: Integer;
    xClose: function(aFile: PSQLiteFile): Integer; cdecl;
    xRead: function(aFile: PSQLiteFile; Buffer: Pointer; iAmt: Integer; iOfst: Int64): Integer; cdecl;
    xWrite: function(aFile: PSQLiteFile; Buffer: Pointer; iAmt: Integer; iOfst: Int64): Integer; cdecl;
    xTruncate: function(aFile: PSQLiteFile; size: Int64): Integer; cdecl;
    xSync: function(aFile: PSQLiteFile; flags: Integer): Integer; cdecl;
    xFileSize: function(aFile: PSQLiteFile; var Size: Int64): Integer; cdecl;
    xLock: function(aFile: PSQLiteFile; Lock: Integer): Integer; cdecl;
    xUnlock: function(aFile: PSQLiteFile; Lock: Integer): Integer; cdecl;
    xCheckReservedLock: function(aFile: PSQLiteFile; var ResOut: Integer): Integer; cdecl;
    xFileControl: function(aFile: PSQLiteFile; op: Integer; pArg: Pointer): Integer; cdecl;
    xSectorSize: function(aFile: PSQLiteFile): Integer; cdecl;
    xDeviceCharacteristics: function(aFile: PSQLiteFile): Integer; cdecl;
    xShmMap: function(aFile: PSQLiteFile; iPg, pgsz, param: Integer; volatile: Pointer): Integer; cdecl;
    xShmLock: function(aFile: PSQLiteFile; offset, n, flags: Integer): Integer; cdecl;
    xShmBarrier: procedure(aFile: PSQLiteFile); cdecl;
    xShmUnmap: function(aFile: PSQLiteFile; deleteFlag: Integer): Integer; cdecl;
    // Methods above are valid for version 2 */
    xFetch: function(pFile: PSQLiteFile; iOfst: int64; iAmt: Integer; var pp: PPointer): integer; cdecl;
    xUnfetch: function(pFile: PSQLiteFile; iOfst: int64; var p: Pointer): Integer; cdecl;
  // Methods above are valid for version 3
  // Additional methods may be added in future releases */
  end;
    {$endregion}

    {$region 'SQLite3 Standard File Control Opcodes'}
const
  SQLITE_FCNTL_LOCKSTATE = 1;
  SQLITE_FCNTL_GET_LOCKPROXYFILE = 2;
  SQLITE_FCNTL_SET_LOCKPROXYFILE = 3;
  SQLITE_FCNTL_LAST_ERRNO = 4;
  SQLITE_FCNTL_SIZE_HINT = 5;
  SQLITE_FCNTL_CHUNK_SIZE = 6;
  SQLITE_FCNTL_FILE_POINTER = 7;
  SQLITE_FCNTL_SYNC_OMITTED = 8;
  SQLITE_FCNTL_WIN32_AV_RETRY = 9;
  SQLITE_FCNTL_PERSIST_WAL = 10;
  SQLITE_FCNTL_OVERWRITE = 11;
  SQLITE_FCNTL_VFSNAME = 12;
  SQLITE_FCNTL_POWERSAFE_OVERWRITE = 13;
  SQLITE_FCNTL_PRAGMA = 14;
  SQLITE_FCNTL_BUSYHANDLER = 15;
  SQLITE_FCNTL_TEMPFILENAME = 16;
  SQLITE_FCNTL_MMAP_SIZE = 18;
  SQLITE_FCNTL_TRACE = 19;
  SQLITE_FCNTL_HAS_MOVED = 20;
  SQLITE_FCNTL_SYNC = 21;
  SQLITE_FCNTL_COMMIT_PHASETWO = 22;
  SQLITE_FCNTL_WIN32_SET_HANDLE = 23;
  SQLITE_FCNTL_WAL_BLOCK = 24;
  SQLITE_FCNTL_ZIPVFS = 25;
  SQLITE_FCNTL_RBU = 26;
  SQLITE_FCNTL_VFS_POINTER = 27;
  SQLITE_FCNTL_JOURNAL_POINTER = 28;
  SQLITE_FCNTL_WIN32_GET_HANDLE = 29;
  SQLITE_FCNTL_PDB = 30;
  SQLITE_FCNTL_BEGIN_ATOMIC_WRITE = 31;
  SQLITE_FCNTL_COMMIT_ATOMIC_WRITE = 32;
  SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE = 33;
  SQLITE_FCNTL_LOCK_TIMEOUT = 34;
  SQLITE_FCNTL_DATA_VERSION = 35;
  SQLITE_FCNTL_SIZE_LIMIT = 36;
  SQLITE_FCNTL_CKPT_DONE = 37;
  SQLITE_FCNTL_RESERVE_BYTES = 38;
  SQLITE_FCNTL_CKPT_START = 39;
  SQLITE_FCNTL_EXTERNAL_READER = 40;
  SQLITE_FCNTL_CKSM_FILE = 41;
  SQLITE_FCNTL_RESET_CACHE = 42;
  SQLITE_FCNTL_NULL_IO = 43;
  SQLITE_FCNTL_BLOCK_ON_CONNECT = 44;
  SQLITE_FCNTL_FILESTAT = 45;

  // Deprecated names kept for compatibility.
  SQLITE_GET_LOCKPROXYFILE = SQLITE_FCNTL_GET_LOCKPROXYFILE;
  SQLITE_SET_LOCKPROXYFILE = SQLITE_FCNTL_SET_LOCKPROXYFILE;
  SQLITE_LAST_ERRNO = SQLITE_FCNTL_LAST_ERRNO;
{$endregion 'Standard File Control Opcodes'}

    {$region 'SQLite3 Virtual file system API'}
type
  TxSyscallPtr = procedure(); cdecl;
  TxDlSym2 = procedure(); cdecl;

  PSQLiteVfs = ^TSQLiteVfs;

  TSQLiteVfs = record
    iVersion: Integer;
    szOsFile: Integer;
    mxPathname: Integer;
    pNext: PSQLiteVfs;
    zName: MarshaledAString;
    pAppData: Pointer;
    xOpen: function(pVfs: PSQLiteVfs; zName: MarshaledAString; aFile: PSQLiteFile; flags: Integer; var OutFlags: Integer): Integer; cdecl;
    xDelete: function(pVfs: PSQLiteVfs; zName: MarshaledAString; syncDir: Integer): Integer; cdecl;
    xAccess: function(pVfs: PSQLiteVfs; zName: MarshaledAString; flags: Integer; var ResOut: Integer): Integer; cdecl;
    xFullPathname: function(pVfs: PSQLiteVfs; zName: MarshaledAString; nOut: Integer; zOut: MarshaledAString): Integer; cdecl;
    xDlOpen: function(pVfs: PSQLiteVfs; zFilename: MarshaledAString): Pointer; cdecl;
    xDlError: procedure(pVfs: PSQLiteVfs; nByte: Integer; zErrMsg: MarshaledAString); cdecl;
    xDlSym: function(pVfs: PSQLiteVfs; Ptr: Pointer; zSymbol: MarshaledAString): TxDlSym2; cdecl;
    xDlClose: procedure(pVfs: PSQLiteVfs; Ptr: Pointer); cdecl;
    xRandomness: function(pVfs: PSQLiteVfs; nByte: Integer; zOut: MarshaledAString): Integer; cdecl;
    xSleep: function(pVfs: PSQLiteVfs; microseconds: Integer): Integer; cdecl;
    xCurrentTime: function(pVfs: PSQLiteVfs; var Time: Double): Integer; cdecl;
    xGetLastError: function(pVfs: PSQLiteVfs; ErrorCode: Integer; ErrorMsg: MarshaledAString): Integer; cdecl;
    xCurrentTimeInt64: function(pVfs: PSQLiteVfs; var Time: Int64): Integer; cdecl;
    xSetSystemCall: function(pVfs: PSQLiteVfs; zName: MarshaledAString; Ptr: TxSyscallPtr): Integer; cdecl;
    xGetSystemCall: function(pVfs: PSQLiteVfs; zName: MarshaledAString): TxSyscallPtr; cdecl;
    xNextSystemCall: function(pVfs: PSQLiteVfs; zName: MarshaledAString): MarshaledAString; cdecl;
  end;
    {$endregion}

    {$region 'Flags for the xAccess VFS method'}
const
  SQLITE_ACCESS_EXISTS = 0;
  SQLITE_ACCESS_READWRITE = 1;   // Used by PRAGMA temp_store_directory
  SQLITE_ACCESS_READ = 2;   // Unused

  SQLITE_WIN32_DATA_DIRECTORY_TYPE = 1;
  SQLITE_WIN32_TEMP_DIRECTORY_TYPE = 2;
    {$endregion 'Flags for the xAccess VFS method'}

    {$region 'Flags for the xShmLock VFS method'}
const
  SQLITE_SHM_UNLOCK = 1;
  SQLITE_SHM_LOCK = 2;
  SQLITE_SHM_SHARED = 4;
  SQLITE_SHM_EXCLUSIVE = 8;
  SQLITE_SHM_NLOCK = 8;
    {$endregion 'Flags for the xShmLock VFS method'}

  {$endregion 'OS Interface File Virtual Methods Object'}

  {$region 'SQLite3 Memory management API'}
type
  PSQLiteMemMethods = ^TSQLiteMemMethods;
  TSQLiteMemMethods = record
    xMalloc: function(Size: Integer): Pointer; cdecl;
    xFree: procedure(Obj: Pointer); cdecl;
    xRealloc: function(Obj: Pointer; Size: Integer): Pointer; cdecl;
    xSize: function(Obj: Pointer): Integer; cdecl;
    xRoundup: function(Size: Integer): Integer; cdecl;
    xInit: function(Obj: Pointer): Integer; cdecl;
    xShutdown: procedure(Obj: Pointer); cdecl;
    pAppData: Pointer;
  end;
  {$endregion 'SQLite3 Memory management API'}

  {$region 'SQLite3 Dynamic String Object'}
type
  /// <summary>
  ///   <para>
  ///     Dynamic String Object
  ///   </para>
  ///   <para>
  ///     An instance of the sqlite3_str object contains a dynamically-sized
  ///     string under construction. <br />The lifecycle of an sqlite3_str
  ///     object is as follows: <br />The sqlite3_str object is created using
  ///     <i>sqlite3_str_new()</i>. Text is appended to the sqlite3_str
  ///     object using various methods, such as <i>sqlite3_str_appendf()</i>.
  ///     The sqlite3_str object is destroyed and the string it created is
  ///     returned using the <i>sqlite3_str_finish()</i>interface.
  ///   </para>
  /// </summary>
  TSQLite3Str = record end;
  PSQLite3Str = ^TSQLite3Str;
{$endregion 'Dynamic String Object'}

  {$region 'configuration flags'}
const
  // Configuration Options
  SQLITE_CONFIG_SINGLETHREAD  = 1;  // nil
  SQLITE_CONFIG_MULTITHREAD = 2;  // nil
  SQLITE_CONFIG_SERIALIZED = 3;  // nil
  SQLITE_CONFIG_MALLOC = 4;  // sqlite3_mem_methods*
  SQLITE_CONFIG_GETMALLOC = 5;  // sqlite3_mem_methods*
  SQLITE_CONFIG_SCRATCH = 6;  // void*, int sz, int N
  SQLITE_CONFIG_PAGECACHE = 7;  // void*, int sz, int N
  SQLITE_CONFIG_HEAP = 8;  // void*, int nByte, int min
  SQLITE_CONFIG_MEMSTATUS = 9;  // boolean
  SQLITE_CONFIG_MUTEX = 10;  // sqlite3_mutex_methods*
  SQLITE_CONFIG_GETMUTEX = 11;  // sqlite3_mutex_methods*
  SQLITE_CONFIG_CHUNKALLOC = 12;  // legacy unused name
  SQLITE_CONFIG_LOOKASIDE = 13;  // int int
  SQLITE_CONFIG_PCACHE = 14; // sqlite3_pcache_methods*
  SQLITE_CONFIG_GETPCACHE = 15; // sqlite3_pcache_methods*
  SQLITE_CONFIG_LOG = 16; // xFunc, void*
  SQLITE_CONFIG_URI = 17; // int
  SQLITE_CONFIG_PCACHE2 = 18; // sqlite3_pcache_methods2*
  SQLITE_CONFIG_GETPCACHE2 = 19; // sqlite3_pcache_methods2*
  SQLITE_CONFIG_COVERING_INDEX_SCAN = 20; // int
  SQLITE_CONFIG_SQLLOG = 21; // xSqllog, void*
  SQLITE_CONFIG_MMAP_SIZE = 22; // sqlite3_int64, sqlite3_int64
  SQLITE_CONFIG_WIN32_HEAPSIZE = 23; // int nByte
  SQLITE_CONFIG_PCACHE_HDRSZ = 24; // int *psz
  SQLITE_CONFIG_PMASZ = 25; // unsigned int szPma
  SQLITE_CONFIG_STMTJRNL_SPILL = 26; // int nByte
  SQLITE_CONFIG_SMALL_MALLOC = 27; // boolean
  SQLITE_CONFIG_SORTERREF_SIZE = 28; // int nByte
  SQLITE_CONFIG_MEMDB_MAXSIZE = 29; // sqlite3_int64
  SQLITE_CONFIG_ROWID_IN_VIEW = 30; // int*
  {$endregion 'configuration flags'}

  {$region 'db configuration options'}
const
  // Configuration Options
  SQLITE_DBCONFIG_MAINDBNAME = 1000; // const char*
  SQLITE_DBCONFIG_LOOKASIDE = 1001; // void* int int
  SQLITE_DBCONFIG_ENABLE_FKEY = 1002; // int int*
  SQLITE_DBCONFIG_ENABLE_TRIGGER = 1003; // int int*
  SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER = 1004; // int int*
  SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION = 1005; // int int*
  SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE = 1006; // int int*
  SQLITE_DBCONFIG_ENABLE_QPSG = 1007; // int int*
  SQLITE_DBCONFIG_TRIGGER_EQP = 1008; // int int*
  SQLITE_DBCONFIG_RESET_DATABASE = 1009; // int int*
  SQLITE_DBCONFIG_DEFENSIVE = 1010; // int int*
  SQLITE_DBCONFIG_WRITABLE_SCHEMA = 1011; // int int*
  SQLITE_DBCONFIG_LEGACY_ALTER_TABLE = 1012; // int int*
  SQLITE_DBCONFIG_DQS_DML = 1013; // int int*
  SQLITE_DBCONFIG_DQS_DDL = 1014; // int int*
  SQLITE_DBCONFIG_ENABLE_VIEW = 1015; // int int*
  SQLITE_DBCONFIG_LEGACY_FILE_FORMAT = 1016; // int int*
  SQLITE_DBCONFIG_TRUSTED_SCHEMA = 1017; // int int*
  SQLITE_DBCONFIG_STMT_SCANSTATUS = 1018; // int int*
  SQLITE_DBCONFIG_REVERSE_SCANORDER = 1019; // int int*
  SQLITE_DBCONFIG_ENABLE_ATTACH_CREATE = 1020; // int int*
  SQLITE_DBCONFIG_ENABLE_ATTACH_WRITE = 1021; // int int*
  SQLITE_DBCONFIG_ENABLE_COMMENTS = 1022; // int int*
  SQLITE_DBCONFIG_FP_DIGITS = 1023; // int int*
  SQLITE_DBCONFIG_MAX = 1023;
  {$endregion}

  {$region 'Virtual Tables related'}
  // Virtual Table Indexing Information
  SQLITE_INDEX_CONSTRAINT_EQ = 2;
  SQLITE_INDEX_CONSTRAINT_GT = 4;
  SQLITE_INDEX_CONSTRAINT_LE = 8;
  SQLITE_INDEX_CONSTRAINT_LT = 16;
  SQLITE_INDEX_CONSTRAINT_GE = 32;
  SQLITE_INDEX_CONSTRAINT_MATCH = 64;
  // 3.10.0
  SQLITE_INDEX_CONSTRAINT_LIKE = 65;
  SQLITE_INDEX_CONSTRAINT_GLOB = 66;
  SQLITE_INDEX_CONSTRAINT_REGEXP = 67;
  // 3.21.0
  SQLITE_INDEX_CONSTRAINT_NE = 68;
  SQLITE_INDEX_CONSTRAINT_ISNOT = 69;
  SQLITE_INDEX_CONSTRAINT_ISNOTNULL = 70;
  SQLITE_INDEX_CONSTRAINT_ISNULL = 71;
  SQLITE_INDEX_CONSTRAINT_IS = 72;
  // since 3.38.0
  SQLITE_INDEX_CONSTRAINT_LIMIT = 73;
  // since 3.38.0
  SQLITE_INDEX_CONSTRAINT_OFFSET = 74;
  // since 3.25.0
  SQLITE_INDEX_CONSTRAINT_FUNCTION = 150;

  // Virtual Table Scan Flags
  SQLITE_INDEX_SCAN_UNIQUE = 1; // Scan visits at most 1 row
  SQLITE_INDEX_SCAN_HEX = $00000002; // Display idxNum as hex

  // Virtual Table Safecall result
  E_SQLITE_VTAB_RES = HRESULT($8000);
  {$endregion}

  {$region 'Prepare flags'}
const
  SQLITE_PREPARE_PERSISTENT = $01;
  SQLITE_PREPARE_NORMALIZE = $02;
  SQLITE_PREPARE_NO_VTAB = $04;
  SQLITE_PREPARE_DONT_LOG = $10;
  // since 3.52.0
  SQLITE_PREPARE_FROM_DDL = $20;
  {$endregion}

  {$region 'Limit Categories'}
const
  // Run-Time Limit Categories
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
  {$endregion}

  {$region 'other'}
const
  SQLITE_FALSE = 0;
  SQLITE_TRUE  = 1;

  // Abort the SQL statement with an error
  SQLITE_DENY = 1;
  // Don't allow access, but don't generate an error
  SQLITE_IGNORE = 2;

  /// Conflict resolution modes
  /// These constants are returned by sqlite3_vtab_on_conflict()
  /// to inform a virtual table implementation what the ON CONFLICT mode is for the SQL statement being evaluated.
  SQLITE_ROLLBACK = 1;
  SQLITE_FAIL = 3;
  SQLITE_REPLACE = 5;
  {$endregion}

  {$region 'Authorizer Action Codes'}
  // ******************************************** 3rd *********** 4th *********
  SQLITE_CREATE_INDEX = 1;                    // Index Name      Table Name
  SQLITE_CREATE_TABLE = 2;                    // Table Name      NULL
  SQLITE_CREATE_TEMP_INDEX = 3;               // Index Name      Table Name
  SQLITE_CREATE_TEMP_TABLE = 4;               // Table Name      NULL
  SQLITE_CREATE_TEMP_TRIGGER = 5;             // Trigger Name    Table Name
  SQLITE_CREATE_TEMP_VIEW = 6;                // View Name       NULL
  SQLITE_CREATE_TRIGGER = 7;                  // Trigger Name    Table Name
  SQLITE_CREATE_VIEW = 8;                     // View Name       NULL
  SQLITE_DELETE = 9;                          // Table Name      NULL
  SQLITE_DROP_INDEX = 10;                     // Index Name      Table Name
  SQLITE_DROP_TABLE = 11;                     // Table Name      NULL
  SQLITE_DROP_TEMP_INDEX = 12;                // Index Name      Table Name
  SQLITE_DROP_TEMP_TABLE = 13;                // Table Name      NULL
  SQLITE_DROP_TEMP_TRIGGER = 14;              // Trigger Name    Table Name
  SQLITE_DROP_TEMP_VIEW = 15;                 // View Name       NULL
  SQLITE_DROP_TRIGGER = 16;                   // Trigger Name    Table Name
  SQLITE_DROP_VIEW = 17;                      // View Name       NULL
  SQLITE_INSERT = 18;                         // Table Name      NULL
  SQLITE_PRAGMA = 19;                         // Pragma Name     1st arg or NULL
  SQLITE_READ = 20;                           // Table Name      Column Name
  SQLITE_SELECT = 21;                         // NULL            NULL
  SQLITE_TRANSACTION = 22;                    // Operation       NULL
  SQLITE_UPDATE = 23;                         // Table Name      Column Name
  SQLITE_ATTACH = 24;                         // Filename        NULL
  SQLITE_DETACH = 25;                         // Database Name   NULL
  SQLITE_ALTER_TABLE = 26;                    // Database Name   Table Name
  SQLITE_REINDEX = 27;                        // Index Name      NULL
  SQLITE_ANALYZE = 28;                        // Table Name      NULL
  SQLITE_CREATE_VTABLE = 29;                  // Table Name      Module Name
  SQLITE_DROP_VTABLE = 30;                    // Table Name      Module Name
  SQLITE_FUNCTION = 31;                       // NULL            Function Name
  SQLITE_SAVEPOINT = 32;                      // Operation       Savepoint Name
  SQLITE_COPY = 0;                            // No longer used
  SQLITE_RECURSIVE = 33;                      // NULL            NULL

type
  TSQLiteActionCode =
  (
    acCreateIndex = SQLITE_CREATE_INDEX,
    acCreateTable = SQLITE_CREATE_TABLE,
    acCreateTempIndex = SQLITE_CREATE_TEMP_INDEX,
    acCreateTempTable = SQLITE_CREATE_TEMP_TABLE,
    acCreateTempTrigger = SQLITE_CREATE_TEMP_TRIGGER,
    acCreateTempView = SQLITE_CREATE_TEMP_VIEW,
    acCreateTrigger = SQLITE_CREATE_TRIGGER,
    acCreateView = SQLITE_CREATE_VIEW,
    acDelete = SQLITE_DELETE,
    acDropIndex = SQLITE_DROP_INDEX,
    acDropTable = SQLITE_DROP_TABLE,
    acDropTempIndex = SQLITE_DROP_TEMP_INDEX,
    acDropTempTable = SQLITE_DROP_TEMP_TABLE,
    acDropTempTrigger = SQLITE_DROP_TEMP_TRIGGER,
    acDropTempView = SQLITE_DROP_TEMP_VIEW,
    acDropTtrigger = SQLITE_DROP_TRIGGER,
    acDropView = SQLITE_DROP_VIEW,
    acInsert = SQLITE_INSERT,
    acPragma = SQLITE_PRAGMA,
    acRead = SQLITE_READ,
    acSelect = SQLITE_SELECT,
    acTransaction = SQLITE_TRANSACTION,
    acUpdate =  SQLITE_UPDATE,
    acAttach = SQLITE_ATTACH,
    acDetach = SQLITE_DETACH,
    acAlterTable = SQLITE_ALTER_TABLE,
    acReIndex =  SQLITE_REINDEX,
    acAnalyze = SQLITE_ANALYZE,
    acCreateVTable = SQLITE_CREATE_VTABLE,
    acDropVTable = SQLITE_DROP_VTABLE,
    acFunction = SQLITE_FUNCTION,
    acSavePoint = SQLITE_SAVEPOINT,
    acCopy = SQLITE_COPY
  );
  {$endregion 'Authorizer Action Codes'}

  {$region 'traceflags'}
const
  SQLITE_TRACE_STMT = $01;
  SQLITE_TRACE_PROFILE = $02;
  SQLITE_TRACE_ROW = $04;
  SQLITE_TRACE_CLOSE = $08;

  SQLITE_TRACE_FLAG_STMT = SQLITE_TRACE_STMT;
  SQLITE_TRACE_FLAG_PROFILE = SQLITE_TRACE_PROFILE;
  SQLITE_TRACE_FLAG_ROW = SQLITE_TRACE_ROW;
  SQLITE_TRACE_FLAG_CLOSE = SQLITE_TRACE_CLOSE;
  SQLITE_TRACE_FLAGS_MASK = $F;

const
  SQLITE_DEFAULT_TRACE_FLAGS = SQLITE_TRACE_FLAG_STMT or SQLITE_TRACE_FLAG_PROFILE or SQLITE_TRACE_FLAG_CLOSE;
  {$endregion traceflags}

  {$region 'transaction states'}
    SQLITE_TXN_UNKNOWN = -1;
    SQLITE_TXN_NONE = 0;
    SQLITE_TXN_READ = 1;
    SQLITE_TXN_WRITE = 2;
  {$endregion}

  // fundamental types
const
  SQLITE_INTEGER = 1;
  SQLITE_FLOAT = 2;
  SQLITE_BLOB = 4;
  SQLITE_NULL = 5;
  SQLITE_TEXT = 3;
  SQLITE3_TEXT = SQLITE_TEXT;

  {$region 'user function related'}
type
  TSQLiteValue = record end;
  PSQLiteValue = ^TSQLiteValue;
  PSQLiteValues = packed array[Word] of PSQLiteValue;
  PPSQLiteValues = ^PSQLiteValues;

const
  /// <summary>
  ///   means that the new function always gives the same output when the input
  ///   parameters are the same
  /// </summary>
  SQLITE_DETERMINISTIC = $000000800;
  /// <summary>
  ///   means that the function may only be invoked from top-level SQL, and
  ///   cannot be used in VIEWs or TRIGGERs nor in schema structures such as
  ///   CHECK constraints, DEFAULT clauses, expression indexes, partial
  ///   indexes, or generated columns. The SQLITE_DIRECTONLY flags is a
  ///   security feature which is recommended for all application-defined SQL
  ///   functions, and especially for functions that have side-effects or that
  ///   could potentially leak sensitive information. <br />
  /// </summary>
  SQLITE_DIRECTONLY = $000080000;
  /// <summary>
  ///   indicates to SQLite that a function may call sqlite3_value_subtype() to
  ///   inspect the sub-types of its arguments. Specifying this flag makes no
  ///   difference for scalar or aggregate user functions. However, if it is
  ///   not specified for a user-defined window function, then any sub-types
  ///   belonging to arguments passed to the window function may be discarded
  ///   before the window function is called (i.e. sqlite3_value_subtype() will
  ///   always return 0).
  /// </summary>
  SQLITE_SUBTYPE = $000100000;
  /// <summary>
  ///   means that the function is unlikely to cause problems even if misused.
  ///   An innocuous function should have no side effects and should not depend
  ///   on any values other than its input parameters.
  /// </summary>
  SQLITE_INNOCUOUS = $000200000;
  SQLITE_RESULT_SUBTYPE = $001000000;
  SQLITE_SELFORDER1 = $002000000;

  /// <summary>
  ///   means that a function may be called witn unlimited number of arguments
  /// </summary>
  SQLITE_FUNC_UNLIMITED_ARGS = -1;

type
  PSQLiteFuncDefn = ^TSQLiteFuncDefn;
  TSQLiteFuncDefn = record end;
  PSQLite3FuncContext = ^TSQLite3FuncContext;
  TSQLite3FuncContext = record end;

  /// func or agg-step
  TxSFunc = procedure(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;

//  TxFunc = procedure(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
//  TxStep = procedure(pCtx: PSQLite3FuncContext; Num: Integer; Value: PSQLiteValues); cdecl; // deprecated

  // Agg finalizer agg current Value
  TxValue = procedure(pCtx: PSQLite3FuncContext); cdecl;
  // Agg finalizer
  TxFinalize = TxValue;

//  TxFinal = TxFinalize; // deprecated

  {$region 'sqlite3int.h 3.7.x'}
//struct FuncDef {
//  i16 nArg;            /* Number of arguments.  -1 means unlimited */
//  u8 iPrefEnc;         /* Preferred text encoding (SQLITE_UTF8, 16LE, 16BE) */
//  u8 flags;            /* Some combination of SQLITE_FUNC_* */
//  void *pUserData;     /* User data parameter */
//  FuncDef *pNext;      /* Next function with same name */
//  void (*xFunc)(sqlite3_context*,int,sqlite3_value**); /* Regular function */
//  void (*xStep)(sqlite3_context*,int,sqlite3_value**); /* Aggregate step */
//  void (*xFinalize)(sqlite3_context*);                /* Aggregate finalizer */
//  char *zName;         /* SQL name of the function. */
//  FuncDef *pHash;      /* Next with a different name but the same hash */
//  FuncDestructor *pDestructor;   /* Reference counted destructor function */
//};
{$endregion}

  {$region 'sqlite3int.h 3.8.7x'}
//struct FuncDef {
//  i16 nArg;            /* Number of arguments.  -1 means unlimited */
//  u16 funcFlags;       /* Some combination of SQLITE_FUNC_* */
//  void *pUserData;     /* User data parameter */
//  FuncDef *pNext;      /* Next function with same name */
//  void (*xFunc)(sqlite3_context*,int,sqlite3_value**); /* Regular function */
//  void (*xStep)(sqlite3_context*,int,sqlite3_value**); /* Aggregate step */
//  void (*xFinalize)(sqlite3_context*);                /* Aggregate finalizer */
//  char *zName;         /* SQL name of the function. */
//  FuncDef *pHash;      /* Next with a different name but the same hash */
//  FuncDestructor *pDestructor;   /* Reference counted destructor function */
//};
{$endregion}

  {$region 'sqlite3int.h 3.25.x'}
//struct FuncDef {
//  i8 nArg;             /* Number of arguments.  -1 means unlimited */
//  u32 funcFlags;       /* Some combination of SQLITE_FUNC_* */
//  void *pUserData;     /* User data parameter */
//  FuncDef *pNext;      /* Next function with same name */
//  void (*xSFunc)(sqlite3_context*,int,sqlite3_value**); /* func or agg-step */
//  void (*xFinalize)(sqlite3_context*);                  /* Agg finalizer */
//  void (*xValue)(sqlite3_context*);                     /* Current agg value */
//  void (*xInverse)(sqlite3_context*,int,sqlite3_value**); /* inverse agg-step */
//  const char *zName;   /* SQL name of the function. */
//  union {
//    FuncDef *pHash;      /* Next with a different name but the same hash */
//    FuncDestructor *pDestructor;   /* Reference counted destructor function */
//  } u;
//};
{$endregion}

//  struct FuncDestructor {
//    int nRef;
//    void (*xDestroy)(void *);
//    void *pUserData;
//  };
  TSQLiteFuncDestructorRec = record
    nRef: Integer;
    xDestroy: Pointer;
    pUserData: Pointer;
  end;
  PSQLiteFuncDestructorRec = ^TSQLiteFuncDestructorRec;

  TSQLiteFuncDefn386Rec = record //
    /// Number of arguments.  -1 means unlimited */
    nArg: Smallint;
    /// Preferred text encoding (SQLITE_UTF8, 16LE, 16BE)
    iPrefEnc: Byte;
    /// Some combination of SQLITE_FUNC_
    flags: Byte;
    /// User data parameter
    pUserData: Pointer;
//    /// Next function with same name
//    pNext: PSQLiteFuncDefn;
//    /// func or agg-step
//    xSFunc: TxSFunc;
//    /// Aggregate step
//    xStep: TxSFunc;
//    /// Aggregate finalizer
//    xFinalize: TxValue;
//    /// SQL name of the function.
//    zName: MarshaledAString;
//    /// Next with a different name but the same hash
//    pHash: PSQLiteFuncDefn;
//    /// Reference counted destructor function
//    pDestructor: PSQLiteFuncDestructorRec;
  end;
  PSQLiteFuncDefn386Rec = ^TSQLiteFuncDefn386Rec;

  TSQLiteFuncDefn387Rec = record
    /// Number of arguments.  -1 means unlimited */
    nArg: ShortInt;
    /// Some combination of SQLITE_FUNC_* */
    funcFlags: Cardinal;
    /// User data parameter/
    pUserData: Pointer;
//    /// Next function with same name
//    pNext: PSQLiteFuncDefn;
//    /// Regular function
//    xFunc: TxSFunc;
//    /// Aggregate step
//    xStep: TxSFunc;
//    /// Aggregate finalizer
//    xFinalize: TxValue;
//    /// SQL name of the function.
//    zName: MarshaledAString;
//    /// Next with a different name but the same hash
//    pHash: PSQLiteFuncDefn;
//    /// Reference counted destructor function
//    pDestructor: PSQLiteFuncDestructorRec;
  end;
  PSQLiteFuncDefn387Rec = ^TSQLiteFuncDefn387Rec;

  PSQLiteFuncDefn3250Rec = ^TSQLiteFuncDefn3250Rec;
  TSQLiteFuncDefn3250Rec = record
    /// Number of arguments.  -1 means unlimited */
    nArg: ShortInt;
    /// Some combination of SQLITE_FUNC_* */
    funcFlags: Cardinal;
    /// User data parameter */
    pUserData: Pointer;
//    /// Next function with same name
//    pNext: PSQLiteFuncDefn;
//    /// func or agg-step
//    xSFunc: TxSFunc;
//    /// Aggregate finalizer
//    xFinalize: TxValue;
//    /// Current agg value
//    xValue: TxValue;
//    /// inverse agg-step
//    xInverse: TxSFunc;
//    /// SQL name of the function.
//    zName: MarshaledAString;
//    case Integer of
//    /// Next with a different name but the same hash
//      0: (pHash: PSQLiteFuncDefn);
//    /// Reference counted destructor function
//      1: (pDestructor: PSQLiteFuncDestructorRec);
    end;

//  TSQLiteFuncDefn3250Rec = packed record
//    /// Number of arguments.  -1 means unlimited */
//    nArg: ShortInt;
//    padding1: Word;
//    padding2: Word;
//    padding3: Word;
//    /// Some combination of SQLITE_FUNC_* */
//    funcFlags: Cardinal;
//    /// User data parameter */
//    pUserData: Pointer;
//  end;

  {$region 'vdbeint.h 3.8.6.xx'}
//struct sqlite3_context {
//  FuncDef *pFunc;       /* Pointer to function information.  MUST BE FIRST */
//  Mem s;                /* The return value is stored here */
//  Mem *pMem;            /* Memory cell used to store aggregate context */
//  CollSeq *pColl;       /* Collating sequence */
//  Vdbe *pVdbe;          /* The VM that owns this context */
//  int iOp;              /* Instruction number of OP_Function */
//  int isError;          /* Error code returned by the function. */
//  u8 skipFlag;          /* Skip skip accumulator loading if true */
//  u8 fErrorOrAux;       /* isError!=0 or pVdbe->pAuxData modified */
//};
{$endregion}

  PSQLite3FuncContextRec = ^TSQLite3FuncContextRec;
  TSQLite3FuncContextRec = record
  /// Pointer to function information */
    pFuncDefn: PSQLiteFuncDefn;
  end;

  {$REGION 'vdbeint.h 3.8.7 up'}
  // struct sqlite3_context {
  // Mem *pOut;              /* The return value is stored here */
  // FuncDef *pFunc;         /* Pointer to function information */
  // Mem *pMem;              /* Memory cell used to store aggregate context */
  // Vdbe *pVdbe;            /* The VM that owns this context */
  // int iOp;                /* Instruction number of OP_Function */
  // int isError;            /* Error code returned by the function. */
  // u8 skipFlag;            /* Skip accumulator loading if true */
  // u8 argc;                /* Number of arguments */
  // sqlite3_value *argv[1]; /* Argument set */
//};
{$endregion}
  PSQLite3FuncContext387Rec = ^TSQLite3FuncContext387Rec;
  TSQLite3FuncContext387Rec = record
    /// The return value is stored here */
    pOut: Pointer;
    /// Pointer to function information */
    pFuncDefn: PSQLiteFuncDefn;
  end;
{$endregion}

  {$region 'callback methods'}
type

  { 'SQLite3 Session API handles'}
  TSQLiteSession = record end;
  PSQLiteSession = ^TSQLiteSession;
  TSQLiteChangesetIter = record end;
  PSQLiteChangesetIter = ^TSQLiteChangesetIter;
  TSQLiteChangegroup = record end;
  PSQLiteChangegroup = ^TSQLiteChangegroup;
  TSQLiteRebaser = record end;
  PSQLiteRebaser = ^TSQLiteRebaser;
  { 'SQLite3 Session API handles'}  TxProgressHandlerCallback = function(pUserData: Pointer): Integer; cdecl;

  TxBusyHandlerCallback = function(Ptr: Pointer; NumberOfInvocations: Integer): Integer; cdecl;

  TxAuth = function(UserData: Pointer; ActionCode: Integer; Str1, Str2, Str3, Str4: MarshaledAString): Integer; cdecl;

  TxExecCallback = function(Param: Pointer; NumCols: Integer; var ColTextStrs: PMarshaledAString; var ColNameStrs: PMarshaledAString): Integer; cdecl;

  TxDestroy = procedure(Ptr: Pointer); cdecl;

  TxAuxDataDestructor = type TxDestroy;

  TxCompare = function(pArg: Pointer; Size1: Integer; Str1: Pointer; Size2: Integer; Str2: Pointer): Integer; cdecl;
  TxCollateCompare = function(UserData: Pointer; Buf1Len: Integer; Buf1: Pointer; Buf2Len: Integer; Buf2: Pointer): Integer; cdecl;
  TxCollationNeededCallback = procedure(pUserData: Pointer; pDB: Pointer; eTextRep: Integer; SequenceName: MarshaledAString); cdecl;
  TxCollationNeededCallback16 = procedure(pUserData: Pointer; pDB: Pointer; eTextRep: Integer; SequenceName: Pointer); cdecl;

  TxCommitHook = function(Ptr: Pointer): Integer; cdecl;
  TxRollbackHook = procedure(Ptr: Pointer); cdecl;
  TxUpdateHook = procedure(Ptr: Pointer; Operation: Integer; DbName, TableName: MarshaledAString; RowId: Int64); cdecl;

  TxEntryPoint = function(db: Pointer; pzErrMsg: PMarshaledAString; pThunk: Pointer): Integer; cdecl;
  TxModulexFunc = procedure(pCtx: PSQLite3FuncContext; Num: Integer; Value: PSQLiteValues); cdecl;
//{$ifdef link_deprecated_api}
  TxTrace = procedure(pCtx: Pointer; Text: MarshaledAString); cdecl; // deprecated;
  TxProfile = procedure(Ptr: Pointer; Text: MarshaledAString; Time: UInt64); cdecl; // deprecated;
//{$endif}
  TxTrace2 = procedure(reason: Cardinal; pCtx: Pointer; P: Pointer; X: Pointer); cdecl;
  TxTrace2Callback = procedure(pCtx: Pointer; Reason: Integer; const Msg: string); cdecl;
  TxLogFunc = procedure(ctx: Pointer; iCode: Integer; const msg: MarshaledAString); cdecl;

  TxWalHookCallback = function(Ptr: Pointer; pDB: Pointer; DbName: MarshaledAString; NumPages: Integer): Integer; cdecl;
  TxDbDumpCallBack = procedure(const z: MarshaledAString; pContext: Pointer); cdecl;
  TxDbAutovacuumPagesCallback = function(pClientData: Pointer;zSchema: MarshaledAString;nDbPage,nFreePage,nBytePerPage: Cardinal): Cardinal; cdecl;  TxSessionTableFilter = function(pCtx: Pointer; zTab: MarshaledAString): Integer; cdecl;
  TxSessionConflict = function(pCtx: Pointer; eConflict: Integer; pIter: PSQLiteChangesetIter): Integer; cdecl;
  TxSessionChangesetFilterV3 = function(pCtx: Pointer; pIter: PSQLiteChangesetIter): Integer; cdecl;
  TxSessionInput = function(pIn, pData: Pointer; pnData: PInteger): Integer; cdecl;
  TxSessionOutput = function(pOut, pData: Pointer; nData: Integer): Integer; cdecl;
  {$endregion 'callback methods'}

  {$region 'SQLite3 virtual tables related'}
type
  PSQLiteModule = Pointer;
  TSQLiteVtab = record
    pModule: PSQLiteModule;
    nRef: Integer;
    zErrMsg: MarshaledAString;
  end;
  PSQLiteVtab = ^TSQLiteVtab;
  PPSQLiteVtab = ^PSQLiteVtab;

  TSQLiteIndexConstraint = record
    iColumn: Integer;
    op: Byte;
    usable: Byte;
    iTermOffset: Integer;
  end;
  PSQLiteIndexConstraint = ^TSQLiteIndexConstraint;

  TSQLiteIndexOrderBy = record
    iColumn: Integer;
    desc: Byte;
  end;
  PSQLiteIndexOrderBy = ^TSQLiteIndexOrderBy;

  TSQLiteIndexConstraintUsage = record
    argvIndex: Integer;
    omit: Byte;
  end;
  PSQLiteIndexConstraintUsage = ^TSQLiteIndexConstraintUsage;

  TSQLiteIndexInfo = record
    nConstraint: Integer;
    pConstraint: PSQLiteIndexConstraint;
    nOrderBy: Integer;
    pOrderBy: PSQLiteIndexOrderBy;
    pConstraintUsage: PSQLiteIndexConstraintUsage;
    idxNum: Integer;
    idxStr: MarshaledAString;
    needToFreeIdxStr: Integer;
    orderByConsumed: Integer;
    estimatedCost: Double;
    // since 3.8.2
    estimatedRows: Int64;
    // since 3.9.0
    idxFlags: Integer;
    // since 3.10.0
    colUsed: UInt64;
  end;
  PSQLiteIndexInfo = ^TSQLiteIndexInfo;

  TSQLiteVtabCursor = record
    pVtab: PSQLiteVtab;
  end;
  PSQLiteVtabCursor = ^TSQLiteVtabCursor;
  PPSQLiteVtabCursor = ^PSQLiteVtabCursor;


  TSQLiteModule = record
    iVersion: Integer;
    xCreate: function(pDB: Pointer; pAux: Pointer; argc: Integer; argv: PMarshaledAStrings; ppVTab: PPSQLiteVtab; Str: PMarshaledAString): Integer; cdecl;
    xConnect: function(pDB: Pointer; pAux: Pointer; argc: Integer; argv: Pointer; ppVTab: PPSQLiteVtab; Str: PMarshaledAString): Integer; cdecl;
    xBestIndex: function(pVTab: PSQLiteVtab; IndexInfo: PSQLiteIndexInfo): Integer; cdecl;
    xDisconnect: function(pVTab: PSQLiteVtab): Integer; cdecl;
    xDestroy: function(pVTab: PSQLiteVtab): Integer; cdecl;
    xOpen: function(pVTab: PSQLiteVtab; ppCursor: PPSQLiteVtabCursor): Integer; cdecl;
    xClose: function(pCursor: PSQLiteVtabCursor): Integer; cdecl;
    xFilter: function(pCursor: PSQLiteVtabCursor; idxNum: Integer; idxStr: MarshaledAString; argc: Integer; argv: PSQLiteValues): Integer; cdecl;
    xNext: function(pCursor: PSQLiteVtabCursor): Integer; cdecl;
    xEof: function(pCursor: PSQLiteVtabCursor): Integer; cdecl;
    xColumn: function(pCursor: PSQLiteVtabCursor; pCtx: PSQLite3FuncContext; Column: Integer): Integer; cdecl;
    xRowID: function(pCursor: PSQLiteVtabCursor; var pRowID: Int64): Integer; cdecl;
    xUpdate: function(pVTab: PSQLiteVtab; argc: Integer; argv: PSQLiteValues; var RowID: Int64): Integer; cdecl;
    xBegin: function(pVTab: PSQLiteVtab): Integer; cdecl;
    xSync: function(pVTab: PSQLiteVtab): Integer; cdecl;
    xCommit: function(pVTab: PSQLiteVtab): Integer; cdecl;
    xRollback: function(pVTab: PSQLiteVtab): Integer; cdecl;
    xFindFunction: function(pVTab: PSQLiteVtab; nArg: Integer; zName: MarshaledAString; var xFunc: TxModulexFunc; ppArg: Pointer): Integer; cdecl;
    xRename: function(pVtab: PSQLiteVtab; zNew: MarshaledAString): Integer; cdecl;
    // The methods above are in version 1 of the sqlite_module object. Those below are for version 2 and greater.
    xSavepoint: function(pVTab: PSQLiteVtab; Value: Integer): Integer; cdecl;
    xRelease: function(pVTab: PSQLiteVtab; Value: Integer): Integer; cdecl;
    xRollbackTo: function(pVTab: PSQLiteVtab; Value: Integer): Integer; cdecl;
    // The methods above are in versions 1 and 2 of the sqlite_module object. Those below are for version 3 and greater.
    xShadowName: function(const zName: MarshaledAString): Integer; cdecl;
  end;
  {$endregion 'SQLite3 virtual tables related'}

const
  SQLITE_UTF8 = 1;
  SQLITE_UTF16LE = 2;
  SQLITE_UTF16BE = 3;
  SQLITE_UTF16 = 4;             // Use native byte order
  SQLITE_ANY = 5;               // sqlite3_create_function only
  SQLITE_UTF16_ALIGNED = 8;     // sqlite3_create_collation only
  SQLITE_UTF8_ZT = 16;          // Zero-terminated UTF8

const
  SQLITE_STATIC = Pointer(0);
  SQLITE_TRANSIENT = Pointer(-1);

const
  SQLITE_SERIALIZE_NOCOPY = $001;
  SQLITE_DESERIALIZE_FREEONCLOSE = $01;
  SQLITE_DESERIALIZE_RESIZEABLE = $02;
  SQLITE_DESERIALIZE_READONLY = $04;

  {$region 'Mutexes'}
type
  TSQLiteMutex = record end;
  PSQLiteMutex = ^TSQLiteMutex;

  {$region 'Mutex Types'}
const
  SQLITE_MUTEX_FAST = 0;
  SQLITE_MUTEX_RECURSIVE = 1;
  SQLITE_MUTEX_STATIC_MAIN = 2;
  SQLITE_MUTEX_STATIC_MASTER = 2;
  SQLITE_MUTEX_STATIC_MEM = 3;  // sqlite3_malloc()
  SQLITE_MUTEX_STATIC_MEM2 = 4;  // NOT USED
  SQLITE_MUTEX_STATIC_OPEN = 4;  // sqlite3BtreeOpen()
  SQLITE_MUTEX_STATIC_PRNG = 5;  // sqlite3_random()
  SQLITE_MUTEX_STATIC_LRU = 6;  // lru page list
  SQLITE_MUTEX_STATIC_LRU2 = 7;  // NOT USED
  SQLITE_MUTEX_STATIC_PMEM = 7;  // sqlite3PageMalloc()
  SQLITE_MUTEX_STATIC_APP1 = 8; // For use by application
  SQLITE_MUTEX_STATIC_APP2 = 9; // For use by application
  SQLITE_MUTEX_STATIC_APP3 = 10; // For use by application
  SQLITE_MUTEX_STATIC_VFS1 = 11; // For use by built-in VFS
  SQLITE_MUTEX_STATIC_VFS2 = 12; // For use by extension VFS
  SQLITE_MUTEX_STATIC_VFS3 = 13; // For use by application VFS
  {$endregion 'Mutex Types'}

  {$region 'Mutexes API'}
type
  TSQLiteMutexMethods = record
    xMutexInit: function: Integer; cdecl;
    xMutexEnd: function: Integer; cdecl;
    xMutexAlloc: function(Value: Integer): PSQLiteMutex; cdecl;
    xMutexFree: procedure(pMutex: PSQLiteMutex); cdecl;
    xMutexEnter: procedure(pMutex: PSQLiteMutex); cdecl;
    xMutexTry: function(pMutex: PSQLiteMutex): Integer; cdecl;
    xMutexLeave: procedure(pMutex: PSQLiteMutex); cdecl;
    xMutexHeld: function(pMutex: PSQLiteMutex): Integer; cdecl;
    xMutexNotheld: function(pMutex: PSQLiteMutex): Integer; cdecl;
  end;
  PSQLiteMutexMethods = ^TSQLiteMutexMethods;
  {$endregion 'Mutexes API'}

   {$endregion 'Mutexes'}

const
  SQLITE_TESTCTRL_FIRST = 5;
  SQLITE_TESTCTRL_PRNG_SAVE = SQLITE_TESTCTRL_FIRST;
  SQLITE_TESTCTRL_PRNG_RESTORE = 6;
  SQLITE_TESTCTRL_PRNG_RESET = 7;   // NOT USED
  SQLITE_TESTCTRL_FK_NO_ACTION = 7;
  SQLITE_TESTCTRL_BITVEC_TEST = 8;
  SQLITE_TESTCTRL_FAULT_INSTALL = 9;
  SQLITE_TESTCTRL_BENIGN_MALLOC_HOOKS = 10;
  SQLITE_TESTCTRL_PENDING_BYTE = 11;
  SQLITE_TESTCTRL_ASSERT = 12;
  SQLITE_TESTCTRL_ALWAYS = 13;
  SQLITE_TESTCTRL_RESERVE = 14; // NOT USED
  SQLITE_TESTCTRL_JSON_SELFCHECK = 14;
  SQLITE_TESTCTRL_OPTIMIZATIONS = 15;
  SQLITE_TESTCTRL_ISKEYWORD = 16; // NOT USED
  SQLITE_TESTCTRL_GETOPT = 16;
  SQLITE_TESTCTRL_SCRATCHMALLOC = 17; // NOT USED

  SQLITE_TESTCTRL_INTERNAL_FUNCTIONS = 17;
  SQLITE_TESTCTRL_LOCALTIME_FAULT = 18;
  SQLITE_TESTCTRL_EXPLAIN_STMT = 19;  //NOT USED
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
  SQLITE_TESTCTRL_USELONGDOUBLE = 34; // NOT USED
  SQLITE_TESTCTRL_ATOF = 34;
  SQLITE_TESTCTRL_LAST = 34; // Largest TESTCTRL

  /// These integer constants designate various run-time status parameters that can be returned by sqlite3_status().
const
  SQLITE_STATUS_MEMORY_USED = 0;
  SQLITE_STATUS_PAGECACHE_USED = 1;
  SQLITE_STATUS_PAGECACHE_OVERFLOW = 2;
  SQLITE_STATUS_SCRATCH_USED = 3;  // NOT USED
  SQLITE_STATUS_SCRATCH_OVERFLOW = 4; // NOT USED
  SQLITE_STATUS_MALLOC_SIZE = 5;
  SQLITE_STATUS_PARSER_STACK = 6;
  SQLITE_STATUS_PAGECACHE_SIZE = 7;
  SQLITE_STATUS_SCRATCH_SIZE = 8; // NOT USED
  SQLITE_STATUS_MALLOC_COUNT = 9;

// Status Parameters for database connections
const
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
  // since 3.51.0
  SQLITE_DBSTATUS_TEMPBUF_SPILL = 13;
  SQLITE_DBSTATUS_MAX = SQLITE_DBSTATUS_TEMPBUF_SPILL; // Largest defined DBSTATUS

const
  SQLITE_STMTSTATUS_FULLSCAN_STEP = 1;
  SQLITE_STMTSTATUS_SORT = 2;
  SQLITE_STMTSTATUS_AUTOINDEX = 3;
  SQLITE_STMTSTATUS_VM_STEP = 4;
  SQLITE_STMTSTATUS_REPREPARE = 5;
  SQLITE_STMTSTATUS_RUN = 6;
  SQLITE_STMTSTATUS_FILTER_MISS = 7;
  SQLITE_STMTSTATUS_FILTER_HIT = 8;
  SQLITE_STMTSTATUS_MEMUSED = 99;

const
  SQLITE_SCANSTAT_NLOOP = 0;
  SQLITE_SCANSTAT_NVISIT = 1;
  SQLITE_SCANSTAT_EST = 2;
  SQLITE_SCANSTAT_NAME = 3;
  SQLITE_SCANSTAT_EXPLAIN = 4;
  SQLITE_SCANSTAT_SELECTID = 5;
  SQLITE_SCANSTAT_PARENTID = 6;
  SQLITE_SCANSTAT_NCYCLE = 7;
  SQLITE_SCANSTAT_COMPLEX = $0001;

const
  // since 3.50.0
  SQLITE_SETLK_BLOCK_ON_CONNECT = $01;

const
  // since 3.51.0
  SQLITE_CARRAY_INT32 = 0;
  SQLITE_CARRAY_INT64 = 1;
  SQLITE_CARRAY_DOUBLE = 2;
  SQLITE_CARRAY_TEXT = 3;
  SQLITE_CARRAY_BLOB = 4;

const
  SQLITE_SESSION_OBJCONFIG_SIZE = 1;
  SQLITE_SESSION_OBJCONFIG_ROWID = 2;
  SQLITE_CHANGESETSTART_INVERT = $0002;
  SQLITE_CHANGESETAPPLY_NOSAVEPOINT = $0001;
  SQLITE_CHANGESETAPPLY_INVERT = $0002;
  SQLITE_CHANGESETAPPLY_IGNORENOOP = $0004;
  SQLITE_CHANGESETAPPLY_FKNOACTION = $0008;
  SQLITE_CHANGESETAPPLY_NOUPDATELOOP = $0010;
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

  {$region 'SQLite3 Page Cache'}
type
  PSQLitePageCache = ^TSQLitePageCache;
  TSQLitePageCache = record end;

  PSQLitePageCachePage = ^TSQLitePageCachePage;
  TSQLitePageCachePage = record
    /// The content of the page
    pBuf: Pointer;
    // Extra information associated with the page
    pExtra: Pointer;
  end;

const
  SQLITE_PAGE_FETCH_NO_ALLOCATE = 0;
  SQLITE_PAGE_FETCH_ALLOCATE = 1;
  SQLITE_PAGE_FETCH_FORCE_ALLOCATE = 2;

type
  TSQLitePageCacheMethods = record
    iVersion: integer;
    pArg: Pointer;
    xInit: function(Ptr: Pointer): Integer; cdecl;
    xShutdown: procedure(Ptr: Pointer); cdecl;
    xCreate: function(szPage,szExtra,bPurgeable: Integer): PSQLitePageCache; cdecl;
    xCachesize: procedure(pCache: PSQLitePageCache; nCacheSize: Integer); cdecl;
    xPagecount: function(pCache: PSQLitePageCache): Integer; cdecl;
    xFetch: function(pCache: PSQLitePageCache; key: Cardinal; createFlag: Integer): PSQLitePageCachePage; cdecl;
    xUnpin: procedure(pCache: PSQLitePageCache; pPage: PSQLitePageCachePage; discard: Integer); cdecl;
    xRekey: procedure(pCache: PSQLitePageCache; pPage: Pointer; oldKey, newKey: Cardinal); cdecl;
    xTruncate: procedure(pCache: PSQLitePageCache; iLimit: Cardinal); cdecl;
    xDestroy: procedure(pCache: PSQLitePageCache); cdecl;
    xShrink: procedure(pCache: PSQLitePageCache); cdecl;
  end;

  {$endregion 'SQLite3 Page Cache'}

  {$region 'SQLite3 Backup API'}
type
  TSQLite3Backup = record end;
  PSQLite3Backup = ^TSQLite3Backup;

  {$endregion 'SQLite3 Backup API'}

  {$region 'Checkpoint Mode Values'}
const
  /// Do no work at all
  SQLITE_CHECKPOINT_NOOP = -1;
  /// Do as much as possible w/o blocking
  SQLITE_CHECKPOINT_PASSIVE = 0;
  /// Wait for writers, then checkpoint
  SQLITE_CHECKPOINT_FULL = 1;
  /// Like FULL but wait for for readers
  SQLITE_CHECKPOINT_RESTART = 2;
  /// Like RESTART but also truncate WAL
  SQLITE_CHECKPOINT_TRUNCATE = 3;
{$endregion 'Checkpoint Mode Values'}

  {$region 'Virtual Table Configuration Options'}
const
  SQLITE_VTAB_CONSTRAINT_SUPPORT = 1;
  SQLITE_VTAB_INNOCUOUS = 2;
  SQLITE_VTAB_DIRECTONLY = 3;
  SQLITE_VTAB_USES_ALL_SCHEMAS = 4;
{$endregion 'Virtual Table Configuration Options'}

  {$REGION 'fts5 api'}

{$IFDEF SQLITE3_USE_STEMMER}
type
  TFTS5StemmerOption = (soFreeStemmer, soUnicode);
  TFTS5StemmerOptions = set of TFTS5StemmerOption;
const
  DEFAULT_FTS5_STEMMER_OPTIONS = [soFreeStemmer];
{$ENDIF}

// Flags that may be passed as the third argument to fts5_tokenizer.xTokenize.
const
  FTS5_TOKENIZE_QUERY = $0001;
  FTS5_TOKENIZE_PREFIX = $0002;
  FTS5_TOKENIZE_DOCUMENT = $0004;
  FTS5_TOKENIZE_AUX = $0008;
// Flags that may be passed by the tokenizer implementation back to FTS5 as the third argument to the supplied xToken callback.
  FTS5_TOKEN_COLOCATED = $0001;
type
  TFTS5_xToken = function(
    // Copy of 2nd argument to xTokenize()
    pCtx: Pointer;
    // Mask of FTS5_TOKEN_* flags
    tflags: Integer;
    // Pointer to buffer containing token
    const pToken: MarshaledAString;
    // Size of token in bytes
    nToken: Integer;
    // Byte offset of token within input text
    iStart: Integer;
    // Byte offset of end of token within input text
    iEnd: Integer
  ): Integer; cdecl;

    /// <summary>
    ///   This function is used to allocate and initialize a tokenizer
    ///   instance. A tokenizer instance is required to actually tokenize text.
    /// </summary>
    /// <param name="pContext">
    ///   Copy of the pointer provided by the application when the
    ///   fts5_tokenizer object was registered with FTS5 (the third argument to
    ///   xCreateTokenizer())
    /// </param>
    /// <param name="azArg">
    ///   array of nul-terminated strings containing the tokenizer arguments,
    ///   if any, specified following the tokenizer name as part of the CREATE
    ///   VIRTUAL TABLE statement used to create the FTS5 table.
    /// </param>
    /// <param name="nArg">
    ///   length of azArg array
    /// </param>
    /// <param name="ppOut">
    ///   output variable. If successful, (*ppOut) should be set to point to
    ///   the new tokenizer handle and SQLITE_OK returned. If an error occurs,
    ///   some value other than SQLITE_OK should be returned. In this case,
    ///   fts5 assumes that the final value of *ppOut is undefined.
    /// </param>
  TFTS5Tokenizer_xCreate = function(pContext: Pointer; const azArg: PMarshaledAStrings; nArg: Integer; ppOut: PPointer): Integer; cdecl;
  TFTS5Tokenizer_xDelete = procedure(pTokenizer: Pointer); cdecl;
  TFTS5Tokenizer_xTokenize = function(pTokenizer: Pointer; pCtx: Pointer; flags: Integer; const pText: MarshaledAString; nText: Integer; xToken: TFTS5_xToken): Integer; cdecl;

  PFTS5TokenizerApi = ^TFTS5TokenizerApi;
  TFTS5TokenizerApi = record
    xCreate: function(pContext: Pointer; const azArg: PMarshaledAStrings; nArg: Integer; ppOut: PPointer): Integer; cdecl;
    xDelete: procedure(pTokenizer: Pointer); cdecl;
    xTokenize: function(pTokenizer: Pointer; pCtx: Pointer; flags: Integer; const pText: MarshaledAString; nText: Integer; xToken: TFTS5_xToken): Integer; cdecl;
  end;

  TFTS5_xFunc = procedure(const pApi: Pointer; pFtsCtx: Pointer; pCtx: Pointer; nVal: Integer; Vals: PSQLiteValues); cdecl;

//  TFTS5_xCreateTokenizer = function(pApi: Pointer; const zName: MarshaledAString; pContext: Pointer; pTokenizer: PFTS5TokenizerApi; xDestroy: TxDestroy): Integer; cdecl;
//  TFTS5_xFindTokenizer = function(pApi: Pointer; const zName: MarshaledAString; ppContext: Pointer; pTokenizer: Pointer): Integer; cdecl;
//  TFTS5_xCreateFunction = function(pApi: Pointer; const zName: MarshaledAString; pContext: Pointer; xFunction: TFTS5_xFunc; xDestroy: TxDestroy): Integer; cdecl;

  PFTS5Api = ^TFTS5Api;
  /// <summary>
  ///   fts5_api structure
  /// </summary>
  TFTS5Api = record
    /// <summary>
    ///   Create a new tokenizer
    /// </summary>
    iVersion: Integer;
    /// <summary>
    ///   Create a new tokenizer
    /// </summary>
    xCreateTokenizer: function(pApi: Pointer; const zName: MarshaledAString; pContext: Pointer; pTokenizer: PFTS5TokenizerApi; xDestroy: TxDestroy): Integer; cdecl;
    /// <summary>
    ///   Find an existing tokenizer
    /// </summary>
    xFindTokenizer: function(pApi: Pointer; const zName: MarshaledAString; ppContext: Pointer; pTokenizer: Pointer): Integer; cdecl;
    /// <summary>
    ///   Create a new auxiliary function
    /// </summary>
    xCreateFunction: function(pApi: Pointer; const zName: MarshaledAString; pContext: Pointer; xFunction: TFTS5_xFunc; xDestroy: TxDestroy): Integer; cdecl;
  end;
  {$endregion 'fts5 api'}

  {$REGION 'rtree related'}

type
  TRTree_xGeomCallback = function(Geometry: Pointer; nCoord: Integer; var aCoord: double; var pRes: Integer): Integer; cdecl;
//  TRTree_xDelUserCallback = procedure (userdata: Pointer); cdecl;

  PSQLiteRtreeQueryInfo = ^TSQLiteRtreeQueryInfo;
  TSQLiteRtreeQueryInfo = record
    /// pContext from when function registered
    pContext: Pointer;
    /// Number of function parameters
    nParams: Integer;
    /// value of function parameters
    pValues: PDouble;
    /// callback can use this, if desired
    pUser: Pointer;
    /// function to free pUser
    xDelUser: procedure (pUserdata: Pointer); cdecl;
    /// Coordinates of node or entry to check
    aCoord: PDouble;
    /// Number of pending entries in the queue
    anQueue: PCardinal;
    // Number of coordinates
    nCoord: Integer;
    /// Level of current node or entry
    iLevel: Integer;
    /// The largest iLevel value in the tree
    mxLevel: Integer;
    /// Rowid for current entry
    iRowid: Int64;
    /// Score of parent node
    rParentScore: PDouble;
    /// Visibility of parent node
    eParentWithin: Integer;
    /// OUT: Visiblity
    eWithin: Integer;
    /// OUT: Write the score here
    rScore: PDouble;
  end;

  TSQLiteRtreeQueryInfo2 = record
    info: TSQLiteRtreeQueryInfo;
    /// The following fields are only available in 3.8.11 and later
    apSqlParam: PSQLiteValue
  end;
  PSQLiteRtreeQueryInfo2 = ^TSQLiteRtreeQueryInfo2;

  TRTree_xQueryCallback = function(var info: TSQLiteRtreeQueryInfo): Integer; cdecl;

type
  TSQLiteRtreeGeometry = record
  /// Copy of pContext passed to s_r_g_c()
    pContext: Pointer;
  /// Size of array aParam[]
    nParam: Integer;
  /// Parameters passed to SQL geom function
    aParam: PDouble;
  /// Callback implementation user data
    pUserData: Pointer;
  /// Destructor of pUserDate
    xDelUser: TxDestroy;
  end;

    // Allowed values for sqlite3_rtree_query.eWithin and .eParentWithin.
const
    /// Object completely outside of query region
    SQLITE_RTREE_NOT_WITHIN      = 0;
    /// Object partially overlaps query region
    SQLITE_RTREE_PARTLY_WITHIN   = 1;
    /// Object fully contained within query region
    SQLITE_RTREE_FULLY_WITHIN    = 2;

{$endregion 'rtreerelated'}

function sqlite3_error_message(ACode: Integer): string; inline;
function sqlite3_is_valid_file(const AFileName: TFileName; PageSize: PInteger): Boolean;
function sqlite3_maindb_alias(): string; inline;
function sqlite3_escape_binary_string(const Value: AnsiString): AnsiString; inline;
function sqlite3_unescape_binary_string(const AValue: AnsiString): AnsiString; inline;
function sqlite3_strlen(const s: PAnsiChar): NativeUInt;
function sqlite3_strcomp(const Str1, Str2: PAnsiChar): Integer; inline;
function sqlite3_strlcopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar; inline;
function sqlite3_strpcopy(Dest: PAnsiChar; const Source: AnsiString): PAnsiChar; inline;
function sqlite3_lowercase(const s: AnsiString): AnsiString; inline;
function sqlite3_decode_utf8(const AValue: Utf8String): UnicodeString; overload;
function sqlite3_decode_utf8(p: PUtf8Char; len: Cardinal): UnicodeString; overload;
function sqlite3_utf8_bytes(p: PUtf8Char; L: NativeInt): NativeInt;
function sqlite3_utf8_to_utf16(dest: PWideChar; source: PUtf8Char; sourceBytes: NativeInt = 0; NoTrailingZero: Boolean = False): NativeInt; overload;
function sqlite3_utf8_to_utf16(p: PUtf8Char; var d: Pointer): Integer; overload; inline;
function sqlite3_utf8_to_utf16(p: PUtf8Char; var d: PWideChar): Integer; overload; inline;
function sqlite3_compare_string_ordinal(s1,s2: string): Integer; cdecl; inline;

type
  ISQLiteAPIClient = interface;

  ISQLiteAPI = interface(IInvokable)
  [SID_SqliteApi]
    function BindMethods(var pErr: string): Boolean;
    procedure SubscribeClient(const AClient: ISQLiteAPIClient);
    procedure UnSubscribeClient(const AClient: ISQLiteAPIClient);
    function GetReady: Boolean;
    function GetVersion: TSQLite3Version;
    function GetVersionStr: string;
    //
    function backup_init(pDestDB: Pointer; zDestName: MarshaledAString; pSourceDB: Pointer; zSourceName: MarshaledAString): PSQLite3Backup; overload;
    function backup_init(pDestDB: Pointer; const DestName: string; pSourceDB: Pointer; const SourceName: string): PSQLite3Backup; overload;
    function backup_step(pBckp: PSQLite3Backup; nPage: Integer): Integer;
    function backup_finish(pBckp: PSQLite3Backup): Integer;
    function backup_remaining(pBckp: PSQLite3Backup): Integer;
    function backup_pagecount(pBckp: PSQLite3Backup): Integer;

    function bind_blob(pStmt: Pointer; iParam: Integer; Value: Pointer; nBytes: Integer; xDestroy: TxDestroy): Integer;
    function bind_blob64(pStmt: Pointer; iParam: Integer; Value: Pointer; nBytes: UInt64; xDestroy: TxDestroy): Integer;
    function bind_double(pStmt: Pointer; iParam: Integer; Value: Double): Integer;
    function bind_int(pStmt: Pointer; iParam: Integer; Value: Integer): Integer;
    function bind_int64(pStmt: Pointer; iParam: Integer; Value: Int64): Integer;
    function bind_null(pStmt: Pointer; iParam: Integer): Integer;
    function bind_text(pStmt: Pointer; iParam: Integer; Value: MarshaledAString; nBytes: Integer; xDestroy: TxDestroy): Integer; overload;
    function bind_text(pStmt: Pointer; iParam: Integer; const AValue: Utf8String): Integer; overload;
    function bind_text(pStmt: Pointer; iParam: Integer; const AValue: RawByteString): Integer; overload;
    function bind_text64(pStmt: Pointer; iParam: Integer; Value: MarshaledAString; nBytes: UInt64; xDestroy: TxDestroy; encoding: Integer): Integer;
    function bind_text16(pStmt: Pointer; iParam: Integer; Value: MarshaledString; nBytes: Integer; xDestroy: TxDestroy): Integer; overload;
    function bind_text16(pStmt: Pointer; iParam: Integer; const AValue: string): Integer; overload;
    function bind_value(pStmt: Pointer; iParam: Integer; Value: PSQLiteValue): Integer;
    function bind_variant(pStmt: Pointer; iParam: Integer; const Value: Variant): Integer;
//    function bind_pointer(pStmt: Pointer; iParam: Integer; var Value; const zText: MarshaledAString; xDestroy: TxDestroy): Integer; overload;
//    function bind_pointer(pStmt: Pointer; iParam: Integer; var Value; const zText: string; xDestroy: TxDestroy): Integer; overload;
    function bind_zeroblob(pStmt: Pointer; iParam, nBytes: Integer): Integer;
    function bind_zeroblob64(pStmt: Pointer; iParam: Integer; nBytes: UInt64): Integer;
    function bind_parameter_count(pStmt: Pointer): Integer;
    function bind_parameter_name(pStmt: Pointer; iParam: Integer): MarshaledAString;
    function bind_parameter_name_v2(pStmt: Pointer; iParam: Integer): string;
    function bind_parameter_index(pStmt: Pointer; zName: MarshaledAString): Integer; overload;
    function bind_parameter_index(pStmt: Pointer; zName: string): Integer; overload;

    function busy_handler(pDB: Pointer; xCallback: TxBusyHandlerCallback; pUserData: Pointer): Integer;
    function busy_timeout(pDB: Pointer; ms: Integer): Integer;

    function clear_bindings(pStmt: Pointer): Integer;

    function create_collation(pDB: Pointer; zName: MarshaledAString; eTextRep: Integer; pUserData: Pointer; xCompare: TxCompare): Integer; overload;
    function create_collation(pDB: Pointer; const Name: string; eTextRep: Integer; pUserData: Pointer; xCompare: TxCompare): Integer; overload;
    function create_collation_v2(pDB: Pointer; zName: MarshaledAString; eTextRep: Integer; pUserData: Pointer; xCompare: TxCompare; xDestroy: TxDestroy): Integer; overload;
    function create_collation_v2(pDB: Pointer; Name: string; eTextRep: Integer; pUserData: Pointer; xCompare: TxCompare; xDestroy: TxDestroy): Integer; overload;
    function create_collation16(pDB: Pointer; zName: MarshaledString; eTextRep: Integer; pUserData: Pointer; xCompare: TxCompare): Integer; overload;
    function create_collation16(pDB: Pointer; Name: string; eTextRep: Integer; pUserData: Pointer; xCompare: TxCompare): Integer; overload;
    function collation_needed(pDB: Pointer; pUserData: Pointer; xCallback: TxCollationNeededCallback): Integer;
    function collation_needed16(pDB: Pointer; pUserData: Pointer; xCallback: TxCollationNeededCallback16): Integer;

    function column_count(pStmt: Pointer): Integer;
    function column_name(pStmt: Pointer; iCol: Integer): MarshaledUtf8String;
    function column_name16(pStmt: Pointer; iCol: Integer): MarshaledString;
    function column_database_name(pStmt: Pointer; iCol: Integer): MarshaledUtf8String;
    function column_database_name16(pStmt: Pointer; iCol: Integer): MarshaledString;
    function column_table_name(pStmt: Pointer; iCol: Integer): MarshaledUtf8String;
    function column_table_name16(pStmt: Pointer; iCol: Integer): MarshaledString;
    function column_origin_name(pStmt: Pointer; iCol: Integer): MarshaledUtf8String;
    function column_origin_name16(pStmt: Pointer; iCol: Integer): MarshaledString;
    function column_decltype(pStmt: Pointer; iCol: Integer): MarshaledUtf8String;
    function column_decltype16(pStmt: Pointer; iCol: Integer): MarshaledString;

    function column_name_txt(pStmt: Pointer; iCol: Integer): Utf8String;
    function column_name16_txt(pStmt: Pointer; iCol: Integer): string;
    function column_database_name_txt(pStmt: Pointer; iCol: Integer): Utf8String;
    function column_database_name16_txt(pStmt: Pointer; iCol: Integer): string;
    function column_table_name_txt(pStmt: Pointer; iCol: Integer): Utf8String;
    function column_table_name16_txt(pStmt: Pointer; iCol: Integer): string;
    function column_origin_name_txt(pStmt: Pointer; iCol: Integer): Utf8String;
    function column_origin_name16_txt(pStmt: Pointer; iCol: Integer): string;
    function column_decltype_txt(pStmt: Pointer; iCol: Integer): Utf8String;
    function column_decltype16_txt(pStmt: Pointer; iCol: Integer): string;

    function column_blob(pStmt: Pointer; iCol: Integer): Pointer;
    function column_bytes(pStmt: Pointer; iCol: Integer): Integer;
    function column_bytes16(pStmt: Pointer; iCol: Integer): Integer;
    function column_double(pStmt: Pointer; iCol: Integer): Double;
    function column_int(pStmt: Pointer; iCol: Integer): Integer;
    function column_int64(pStmt: Pointer; iCol: Integer): Int64;
    function column_text(pStmt: Pointer; iCol: Integer): MarshaledUtf8String;
    function column_txt(pStmt: Pointer; iCol: Integer): string;
    function column_text16(pStmt: Pointer; iCol: Integer): MarshaledString;
    function column_txt16(pStmt: Pointer; iCol: Integer): string;
    function column_type(pStmt: Pointer; iCol: Integer): Integer;
    function column_value(pStmt: Pointer; iCol: Integer): PSQLiteValue;

    function close(pDB: Pointer): Integer;
    function close_v2(pDB: Pointer): Integer;
    function context_alloc(ppCtx: PPointer): Integer; cdecl;
    procedure context_free(pCtx: Pointer); cdecl;

    function errstr(iRetCode: Integer): MarshaledAString; overload;
    function errstr16(iRetCode: Integer): string;
    function errstr16_v2(iRetCode: Integer): string;
    function errcode(pDB: Pointer): Integer;
    function extended_errcode(pDB: Pointer): Integer;
    function errmsg(pDB: Pointer): MarshaledAString;
    function errmsg16(pDB: Pointer): MarshaledString;
    function error_message(iRetCode: Integer): string;
    function exec_simple(const ADB: Pointer; const ASQL: string): Integer;
    function system_errno(pDB: Pointer): Integer;

    function escape_binary_string(const AValue: AnsiString): AnsiString;
    function unescape_binary_string(const AValue: AnsiString): AnsiString;

    function db_config(pDB: Pointer; option, optionValue: Integer): Integer;
    function db_encoding(pDB: Pointer): string;
    function db_dump(pDB: Pointer; ASchema: string; const ATable: string; ADest: TStream): NativeInt;
    function db_filename(pDB: Pointer; AAlias: MarshaledAString): MarshaledAString; overload;
    function db_filename(pDB: Pointer; AAlias: string = SQLITE_MAINDB_ALIAS): string; overload;

    function declare_vtab(pDB: Pointer; zSql: MarshaledAString): Integer; overload;
    function declare_vtab(pDB: Pointer; const statement_sql: string): Integer; overload;

    function decode_utf8(const AValue: Utf8String): string; overload;
    function decode_utf8(p: PUtf8Char; len: Cardinal): string; overload;

    procedure free_memory(pMem: Pointer);

    function maindb_alias(): string;

    function malloc(nBytes: Integer): Pointer;
    function malloc64(nBytes: UInt64): Pointer;
    function realloc(Ptr: Pointer; nBytes: Integer): Pointer;
    function realloc64(mMem: Pointer; nBytes: UInt64): Pointer;

    function is_valid_file(const AFileName: string; APageSize: PInteger): Boolean;

    function create_function(pDB: Pointer; zFunctionName: MarshaledAString; nArgs, eTextRep: Integer; pUserData: Pointer; xFunc: TxSFunc; xStep: TxSFunc; xFinal: TxFinalize): Integer;
    function create_function16(pDB: Pointer; zFunctionName: MarshaledString; nArgs, eTextRep: Integer; pUserData: Pointer; xFunc: TxSFunc; xStep: TxSFunc; xFinal: TxFinalize): Integer;
    function create_function_v2(pDB: Pointer; zFunctionName: MarshaledAString; nArgs, eTextRep: Integer; pUserData: Pointer; xFunc: TxSFunc; xStep: TxSFunc; xFinal: TxFinalize; xDestroy: TxDestroy): Integer;
    function create_window_function(pDB: Pointer; zFunctionName: MarshaledAString; nArgs, eTextRep: Integer; pUserData: Pointer; xStep: TxSFunc; xFinal, xValue: TxValue; xInverse: TxSFunc; xDestroy: TxDestroy): Integer;

    function create_module(pDB: Pointer; zName: MarshaledAString; pModule: PSQLiteModule; pUserData: Pointer): Integer;
    function create_module_v2(pDB: Pointer; zName: MarshaledAString; pModule: PSQLiteModule; pUserData: Pointer; xDestroy: TxDestroy): Integer;

    function get_auxdata(pCtx: PSQLite3FuncContext; iParam: Integer): Pointer;
    procedure set_auxdata(pCtx: PSQLite3FuncContext; iParam: Integer; AData: Pointer; xDestroy: TxDestroy);

    function open(zFilename: PUtf8Char; var pDB: Pointer): Integer; overload;
    function open(const Filename: Utf8String; var pDB: Pointer): Integer; overload;
    function open(const Filename: string; var pDB: Pointer): Integer; overload;

    function open16(zFilename: MarshaledString; var pDB: Pointer): Integer; overload;
    function open16(const Filename: string; var pDB: Pointer): Integer; overload;

    function open_v2(zFilename: PUtf8Char; var pDB: Pointer; flags: Integer; zVfs: PUtf8Char): Integer; overload;
    function open_v2(const Filename: Utf8String; var pDB: Pointer; flags: Integer; zVfs: MarshaledAString): Integer; overload;
    function open_v2(const Filename: string; var pDB: Pointer; flags: Integer; zVfs: MarshaledAString): Integer; overload;

    function prepare(pDB: Pointer; zSql: PUtf8Char; nByte: Integer; var pStmt: Pointer; ppzTail: PMarshaledAString): Integer; overload;
    function prepare(pDB: Pointer; zSql: PUtf8Char; nByte: Integer; var pStmt: Pointer): Integer; overload;
    function prepare(pDB: Pointer; const statement_sql: Utf8String; var pStmt: Pointer): Integer; overload;
    function prepare(pDB: Pointer; const statement_sql: string; var pStmt: Pointer): Integer; overload;

    function prepare_v2(pDB: Pointer; zSql: PUtf8Char; nByte: Integer; var pStmt: Pointer; ppzTail: PMarshaledAString): Integer; overload;
    function prepare_v2(pDB: Pointer; zSql: PUtf8Char; nByte: Integer; var pStmt: Pointer): Integer; overload;
    function prepare_v2(pDB: Pointer; const statement_sql: Utf8String; var pStmt: Pointer): Integer; overload;
    function prepare_v2(pDB: Pointer; const statement_sql: string; var pStmt: Pointer): Integer; overload;

    function prepare_v3(pDB: Pointer; zSql: PUtf8Char; nByte: Integer; prepFlags: Cardinal; var pStmt: Pointer; ppzTail: PMarshaledAString): Integer; overload;
    function prepare_v3(pDB: Pointer; zSql: PUtf8Char; nByte: Integer; prepFlags: Cardinal; var pStmt: Pointer): Integer; overload;
    function prepare_v3(pDB: Pointer; const statement_sql: Utf8String; prepFlags: Cardinal; var pStmt: Pointer): Integer; overload;
    function prepare_v3(pDB: Pointer; const statement_sql: string; prepFlags: Cardinal; var pStmt: Pointer): Integer; overload;

    function prepare16(pDB: Pointer; zSql: MarshaledString; nByte: Integer; var pStmt: Pointer; ppzTail: PMarshaledString): Integer; overload;
    function prepare16(pDB: Pointer; zSql: MarshaledString; nByte: Integer; var pStmt: Pointer): Integer; overload;
    function prepare16(pDB: Pointer; const statement_sql: string; var pStmt: Pointer): Integer; overload;
    function prepare16(pDB: Pointer; const statement_sql: Utf8String; var pStmt: Pointer): Integer; overload;

    function prepare16_v2(pDB: Pointer; zSql: MarshaledString; nByte: Integer; var pStmt: Pointer; ppzTail: PMarshaledString): Integer; overload;
    function prepare16_v2(pDB: Pointer; zSql: MarshaledString; nByte: Integer; var pStmt: Pointer): Integer; overload;
    function prepare16_v2(pDB: Pointer; const statement_sql: string; var pStmt: Pointer): Integer; overload;
    function prepare16_v2(pDB: Pointer; const statement_sql: Utf8String; var pStmt: Pointer): Integer; overload;

    function prepare16_v3(pDB: Pointer; zSql: MarshaledString; nByte: Integer; prepFlags: Cardinal; var pStmt: Pointer; ppzTail: PMarshaledString): Integer; overload;
    function prepare16_v3(pDB: Pointer; zSql: MarshaledString; nByte: Integer; prepFlags: Cardinal; var pStmt: Pointer): Integer; overload;
    function prepare16_v3(pDB: Pointer; const statement_sql: string; prepFlags: Cardinal; var pStmt: Pointer): Integer; overload;
    function prepare16_v3(pDB: Pointer; const statement_sql: Utf8String; prepFlags: Cardinal; var pStmt: Pointer): Integer; overload;

    function register_extentions(pDB: Pointer; AExtentions: TSQLite3Extentions): Integer;

    procedure result_blob(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer; xDestroy: TxDestroy);
    procedure result_blob_static(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer);
    procedure result_blob_transient(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer);
    procedure result_blob64(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: UInt64; xDestroy: TxDestroy);
    procedure result_blob64_static(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer);
    procedure result_blob64_transient(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer);
    procedure result_error(pCtx: PSQLite3FuncContext; zErrorString: MarshaledAString; nBytes: Integer); overload;
    procedure result_error(pCtx: PSQLite3FuncContext; const ErrorString: Utf8String); overload;
    procedure result_error(pCtx: PSQLite3FuncContext; const ErrorString: string); overload;
    procedure result_error16(pCtx: PSQLite3FuncContext; zErrorString: MarshaledString; nBytes: Integer);
    procedure result_error_toobig(pCtx: PSQLite3FuncContext);
    procedure result_error_nomem(pCtx: PSQLite3FuncContext);
    procedure result_error_code(pCtx: PSQLite3FuncContext; Code: Integer);
    procedure result_double(pCtx: PSQLite3FuncContext; Value: Double);
    procedure result_int(pCtx: PSQLite3FuncContext; Value: Integer);
    procedure result_int64(pCtx: PSQLite3FuncContext; Value: Int64);
    procedure result_null(pCtx: PSQLite3FuncContext);
    procedure result_pointer(pCtx: PSQLite3FuncContext; Value: Pointer; const zType: MarshaledAString; xDestroy: TxDestroy);
    procedure result_subtype(pCtx: PSQLite3FuncContext; iSubtype: Cardinal);
    procedure result_text(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: Integer; xDestroy: TxDestroy); overload;
    procedure result_text_static(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: Integer); overload;
    procedure result_text_transient(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: Integer); overload;
    procedure result_text64(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: UInt64; xDestroy: TxDestroy; encoding: Integer);
    procedure result_text64_static(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: Integer); overload;
    procedure result_text64_transient(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: Integer); overload;
    procedure result_text(pCtx: PSQLite3FuncContext; const Value: Utf8String); overload;
    procedure result_text_static(pCtx: PSQLite3FuncContext; const Value: Utf8String); overload;
    procedure result_text_transient(pCtx: PSQLite3FuncContext; const Value: Utf8String); overload;
    procedure result_text(pCtx: PSQLite3FuncContext; const Value: string); overload;
    procedure result_text16(pCtx: PSQLite3FuncContext; Value: MarshaledString; nBytes: Integer; xDestroy: TxDestroy); overload;
    procedure result_text16_static(pCtx: PSQLite3FuncContext; Value: MarshaledString; nBytes: Integer); overload;
    procedure result_text16_transient(pCtx: PSQLite3FuncContext; Value: MarshaledString; nBytes: Integer); overload;
    procedure result_text16(pCtx: PSQLite3FuncContext; const Value: string); overload;
    procedure result_text16_static(pCtx: PSQLite3FuncContext; const Value: string); overload;
    procedure result_text16_transient(pCtx: PSQLite3FuncContext; const Value: string); overload;
    procedure result_text16le(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer; xDestroy: TxDestroy);
    procedure result_text16be(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: Integer; xDestroy: TxDestroy);
    procedure result_value(pCtx: PSQLite3FuncContext; Value: PSQLiteValue);
    procedure result_zeroblob(pCtx: PSQLite3FuncContext; nBytes: Integer);
    procedure result_zeroblob64(pCtx: PSQLite3FuncContext; nBytes: UInt64);

    function table_column_metadata(pDB: Pointer; zDbName, zTableName, zColumnName: MarshaledAString; ppzDataType, ppzCollSeq: PMarshaledAString; pNotNull, pPrimaryKey, pAutoinc: PInteger): Integer; overload;
    function table_column_metadata(pDB: Pointer; const DbName, TableName, ColumnName: string; out DataType, CollSeq: string; var NotNull, PrimaryKey, Autoinc: Integer): Integer; overload;

    function value_blob(Value: PSQLiteValue): Pointer;
    function value_bytes(Value: PSQLiteValue): Integer;
    function value_bytes16(Value: PSQLiteValue): Integer;
    function value_double(Value: PSQLiteValue): Double;
    function value_dup(Orig: PSQLiteValue): PSQLiteValue;
    procedure value_free(Value: PSQLiteValue);
    function value_int(Value: PSQLiteValue): Integer;
    function value_int64(Value: PSQLiteValue): Int64; cdecl;
    function value_text(Value: PSQLiteValue): MarshaledAString;
    function value_text16(Value: PSQLiteValue): MarshaledString;
    function value_text16le(Value: PSQLiteValue): Pointer;
    function value_text16be(Value: PSQLiteValue): Pointer;
    function value_str(Value: PSQLiteValue): RawByteString;
    function value_str16(Value: PSQLiteValue; ValueIsUnicode: Boolean): string;
    function value_type(Value: PSQLiteValue): Integer;
    function value_subtype(Value: PSQLiteValue): Cardinal;
    function value_numeric_type(Value: PSQLiteValue): Integer;
    function value_frombind(Value: PSQLiteValue): Integer;
    function value_nochange(Value: PSQLiteValue): Integer;
    function value_pointer(Value: PSQLiteValue; V: MarshaledAString): Pointer;

    function step(pStmt: Pointer): Integer;

    function sql(pStmt: Pointer): MarshaledUtf8String;
    function normalized_sql(pStmt: Pointer): MarshaledUtf8String;
    function expanded_sql(pStmt: Pointer): MarshaledUtf8String;

    function statement_sql_text(pStmt: Pointer): string;
    function statement_normalized_sql_text(pStmt: Pointer): string;
    function statement_expanded_sql_text(pStmt: Pointer): string;

    function set_authorizer(pDB: Pointer; xAuth: TxAuth; pUserData: Pointer): Integer;

    function commit_hook(pDB: Pointer; xCallback: TxCommitHook; pUserData: Pointer): Pointer;
    function rollback_hook(pDB: Pointer; xCallback: TxRollbackHook; pUserData: Pointer): Pointer;
    function update_hook(pDB: Pointer; xCallback: TxUpdateHook; pUserData: Pointer): Pointer; cdecl;

    function try_step(pStmt: Pointer; MaxTryCount: Cardinal = 8; WaitTime: Cardinal = 10): Integer;
    function finalize(pStmt: Pointer): Integer;
    function reset(pStmt: Pointer): Integer;

    function aggregate_context(pCtx: PSQLite3FuncContext; nBytes: Integer): Pointer;
    function user_data(pCtx: PSQLite3FuncContext): Pointer;
    function context_db_handle(pCtx: PSQLite3FuncContext): Pointer;

    function last_insert_rowid(pDB: Pointer): Int64;
    function libversion(): MarshaledAString;
    function libversion_number: Cardinal;

    procedure set_last_insert_rowid(pDB: Pointer; iRowID: Int64);

    function changes(pDB: Pointer): Integer;
    function total_changes(pDB: Pointer): Integer;

    function memory_used: Int64;
    function memory_highwater(resetFlag: Integer): Int64;

    function trace_v2(pDB: Pointer; uMask: Cardinal; xTraceFunc: TxTrace2; pCtx: Pointer): Integer;

    function load_extension(pDB: Pointer; zFilename, zEntryProcName: MarshaledAString; ppzErrMsg: PMarshaledAString): Integer; overload;
    function load_extension(pDB: Pointer; const Filename, EntryProcName: string; out errmsg: string): Integer; overload;

    function enable_load_extension(pDB: Pointer; onOff: Integer): Integer;
    function auto_extension(xEntryPoint: TxEntryPoint): Integer;
    function cancel_auto_extension(xEntryPoint: TxEntryPoint): Integer;
    procedure reset_auto_extension;
    procedure log(const AMessage: string; onNewLine: Boolean = False);

//    function fts5api_from_db(pDB: Pointer): PFTS5Api;
  end;

  ISQLiteAPIClient = interface(IInvokable)
  [SID_SqliteApiClient]
    procedure SubscribeToAPI(const AAPI: ISQLiteAPI);
    procedure UnSubscribeFromAPI(const AAPI: ISQLiteAPI);
    function GetSelf: TObject;
  end;

  PSQLiteDirectAPIContext = ^TSQLite3DirectAPIContext;
  TSQLite3DirectAPIContext = record
    api: ISQLiteAPI;
    ClientData: Pointer;
  end;

  PSQLiteDirectAPITrace2Context = ^TSQLiteDirectAPITrace2Context;
  TSQLiteDirectAPITrace2Context = record
    api: ISQLiteAPI;
    Caller: Pointer;
    xCallback: TxTrace2Callback;
  end;

function GetApiContext386(const ACtx: PSQLite3FuncContext; var apiCtx: PSQLiteDirectAPIContext): Boolean;
function GetApiContext387(const ACtx: PSQLite3FuncContext; var apiCtx: PSQLiteDirectAPIContext): Boolean;
function GetApiContext3250(const ACtx: PSQLite3FuncContext; var apiCtx: PSQLiteDirectAPIContext): Boolean;

implementation

uses System.Types;

{ TSQLite3Version }

constructor TSQLite3Version.Create(const AVersion: string);
var
  s: string;
  i: integer;
begin
  s := AVersion;
  i := pos('.', s);
  Self.iMajor := StrToIntDef(copy(s, 1, i - 1), 0);
  delete(s, 1, i);
  i := pos('.', s);
  Self.iMinor := StrToIntDef(copy(s, 1, i - 1), 0);
  delete(s, 1, i);
  i := pos('.', s);
  if i > 0 then
    Self.iRelease := StrToIntDef(copy(s, 1, i - 1), 0)
  else
    Self.iRelease := StrToIntDef(s, 0);
end;

constructor TSQLite3Version.Create(const AVersion: Cardinal);
var
  s: string;
begin
  s := IntToStr(AVersion);
  Self.iMajor := StrToIntDef(copy(s, 1, 1), 0);
  delete(s, 1, 1);
  Self.iMinor := StrToIntDef(copy(s, 1, 4), 0);
  delete(s, 1, 4);
  Self.iRelease := StrToIntDef(copy(s, 1, Length(s)), 0);
end;

{ Misc. functions }

function sqlite3_strend(const s: PAnsiChar): PAnsiChar; inline;
label
  0, 1, 2, 3;
begin
  Result := s;
  if Assigned(Result) then
  begin
    repeat
      if Result[0] = #0 then
        goto 0;
      if Result[1] = #0 then
        goto 1;
      if Result[2] = #0 then
        goto 2;
      if Result[3] = #0 then
        goto 3;
      Inc(Result, 4);
    until False;

  3:
    Inc(Result);
  2:
    Inc(Result);
  1:
    Inc(Result);
  0:
  end;
end;

function sqlite3_strlen(const s: PAnsiChar): NativeUInt;
begin
  Result := sqlite3_strend(s) - s;
end;

{$IFNDEF MSWINDOWS}
function to_lowercase(c: AnsiChar): AnsiChar;
const
  cLowerCaseMap: array[Byte] of Byte = ( $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30,
    $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67,
    $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E,
    $9F, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF, $F0, $F1, $F2, $F3, $F4, $F5,
    $F6, $D7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $DF, $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF, $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
  );
var
  cc: Cardinal;
begin
  cc := Cardinal(c);
  if cc <= High(cLowerCaseMap) then
    Result := AnsiChar(cLowerCaseMap[cc])
  else
    Result := c;
end;
{$ENDIF}

function sqlite3_lowercase(const s: AnsiString): AnsiString;
var
{$IFNDEF MSWINDOWS}  i, {$ENDIF}len: Integer;
begin
  len := Length(s);
{$IFDEF MSWINDOWS}
  SetString(Result, PAnsiChar(s), len);
  if len > 0 then
    CharLowerBuffA(Pointer(Result), len);
{$ELSE}
  SetLength(Result,len);
  for i := Low(s) to len -1 do
    Result[i] := to_lowercase(s[i]);
{$ENDIF}
end;

function sqlite3_strcomp(const Str1, Str2: PAnsiChar): Integer;
var
  P1, P2: PAnsiChar;
begin
  P1 := Str1;
  P2 := Str2;
  while True do
  begin
    if (P1^ <> P2^) or (P1^ = #0) then
      Exit(Ord(P1^) - Ord(P2^));
    Inc(P1);
    Inc(P2);
  end;
end;

function sqlite3_strlcopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar;
var
  Len: Cardinal;
begin
  Result := Dest;
  Len := sqlite3_strlen(Source);
  if Len > MaxLen then
    Len := MaxLen;
  Move(Source^, Dest^, Len * SizeOf(AnsiChar));
  Dest[Len] := #0;
end;

function sqlite3_strpcopy(Dest: PAnsiChar; const Source: AnsiString): PAnsiChar;
begin
  Result := sqlite3_strlcopy(Dest, PAnsiChar(Source), Length(Source));
end;

function sqlite3_utf8_to_utf16(dest: PWideChar; source: PUtf8Char; sourceBytes: NativeInt = 0; NoTrailingZero: Boolean = False): NativeInt;
// faster than System.UTF8Decode()
const
  UTF16_HISURROGATE_MIN = $D800;
  UTF16_HISURROGATE_MAX = $DBFF;
  UTF16_LOSURROGATE_MIN = $DC00;
  UTF16_LOSURROGATE_MAX = $DFFF;
  UTF8_EXTRABYTES: array [$80 .. $FF] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 0, 0);

UTF8_EXTRA:  array [0 .. 6] of record offset, minimum: Cardinal; end = (
  // http://floodyberry.wordpress.com/2007/04/14/utf-8-conversion-tricks
  (offset: $00000000; minimum: $00010000),
  (offset: $00003080; minimum: $00000080),
  (offset: $000E2080; minimum: $00000800),
  (offset: $03C82080; minimum: $00010000),
  (offset: $FA082080; minimum: $00200000),
  (offset: $82082080; minimum: $04000000),
  (offset: $00000000;
  minimum: $04000000)
);

UTF8_EXTRA_SURROGATE = 3;
UTF8_FIRSTBYTE:
array [2 .. 6] of Byte = ($C0, $E0, $F0, $F8, $FC);

var
  C: Cardinal;
  begd: PWideChar;
  endSource, endSourceBy4: PUtf8Char;
  i, extra: NativeInt;

label Quit, NoSource, By1, By4;
begin
  Result := 0;

  if dest = nil then
    Exit;

  if source = nil then
    goto NoSource;

  if sourceBytes = 0 then
  begin
    if source^ = #0 then
      goto NoSource;
    sourceBytes := sqlite3_strlen(source);
  end;

  begd := dest;
  endSource := source + sourceBytes;
  endSourceBy4 := endSource - 4;

  if (NativeUInt(source) and 3 = 0) and (source <= endSourceBy4) then
    repeat // handle 7 bit ASCII chars, by quad (Sha optimization)
    By4:
      C := PCardinal(source)^;
      if C and $80808080 <> 0 then
        goto By1; // break on first non ASCII quad
      Inc(source, 4);
      PCardinal(dest)^ := (C shl 8 or (C and $FF)) and $00FF00FF;
      C := C shr 16;
      PCardinal(dest + 2)^ := (C shl 8 or C) and $00FF00FF;
      Inc(dest, 4);
    until source > endSourceBy4;

  if source < endSource then
    repeat
    By1:
      C := Byte(source^);
      Inc(source);
      if C <= 127 then
      begin
        PWord(dest)^ := C; // much faster than dest^ := WideChar(c)
        Inc(dest);
        if (NativeUInt(source) and 3 = 0) and (source <= endSourceBy4) then
          goto By4;
        if source < endSource then
          Continue
        else
          Break;
      end;

      extra := UTF8_EXTRABYTES[C];
      if (extra = 0) or (source + extra > endSource) then
        Break;

      for i := 1 to extra do
      begin
        if Byte(source^) and $C0 <> $80 then
          goto Quit; // invalid input content
        C := C shl 6 + Byte(source^);
        Inc(source);
      end;

      with UTF8_EXTRA[extra] do
      begin
        Dec(C, offset);
        if C < minimum then
          Break; // invalid input content
      end;

      if C <= $FFFF then
      begin
        PWord(dest)^ := C;
        Inc(dest);
        if (NativeUInt(source) and 3 = 0) and (source <= endSourceBy4) then
          goto By4;
        if source < endSource then
          Continue
        else
          Break;
      end;

      Dec(C, $10000); // store as UTF-16 surrogates
      PWordArray(dest)[0] := C shr 10 + UTF16_HISURROGATE_MIN;
      PWordArray(dest)[1] := C and $3FF + UTF16_LOSURROGATE_MIN;
      Inc(dest, 2);

      if (NativeUInt(source) and 3 = 0) and (source <= endSourceBy4) then
        goto By4;

      if source >= endSource then
        Break;
    until False;

Quit:
  Result := (NativeUInt(dest) - NativeUInt(begd)) div SizeOf(WideChar);
NoSource:
  if not NoTrailingZero then
    dest^ := #0; // always append a WideChar(0) to the end of the buffer
end;

function sqlite3_utf8_bytes(p: PUtf8Char; L: NativeInt): NativeInt;
const
  UTF8_ACCEPT = 0;
  UTF8_REJECT = 12;

  utf8d: array [0 .. 363] of Byte = (

    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 11, 6, 6, 6, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,

    0, 12, 24, 36, 60, 96, 84, 12, 12, 12, 48, 72, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 0, 12, 12, 12, 12, 12, 0, 12, 0, 12, 12, 12, 24, 12, 12, 12, 12, 12, 24, 12, 24, 12, 12, 12, 12, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 12, 12, 24,
    12, 12, 12, 12, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12, 12, 36, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12, 12, 36, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12);
var
  s: NativeInt;
begin
  Assert(Assigned(p) and (L > 0));

  Result := 1;
  s := 0;
  repeat
    s := utf8d[256 + s + utf8d[Ord(p^)]];
    case s of
      UTF8_ACCEPT:
        Exit;
      UTF8_REJECT:
        Break;
    end;
    Inc(Result);
    Inc(p);
    Dec(L);
  until L = 0;
  Result := -Result;
end;

function sqlite3_utf8_to_utf16(p: PUtf8Char; var d: Pointer): Integer;
var
  len: Integer;
begin

  if d <> nil then
  begin
    FreeMem(d);
    d := nil;
  end;

  len := sqlite3_strlen(p);
  ReallocMem(d, len * 2 + 2);

  Result := sqlite3_utf8_to_utf16(d, p, len);
end;

function sqlite3_utf8_to_utf16(p: PUtf8Char; var d: PWideChar): Integer;
var
  len: Integer;
begin
  if d <> nil then
  begin
    FreeMem(d);
    d := nil;
  end;

  len := sqlite3_strlen(p);
  ReallocMem(d, len * 2 + 2);

  Result := sqlite3_utf8_to_utf16(d, p, len);
end;

function sqlite3_decode_utf8(const AValue: Utf8String): UnicodeString;
begin
  Result := sqlite3_decode_utf8(PUtf8Char(AValue), Length(AValue));
end;

function sqlite3_decode_utf8(p: PUtf8Char; len: Cardinal): UnicodeString;
var
  nBytes: Cardinal;
begin
  nBytes := (1 + len) * SizeOf(WideChar);
  if Assigned(p) and (nBytes > 0) then
  begin
    SetLength(Result, 1 + len);

    len := sqlite3_utf8_to_utf16(PWideChar(Result), p, len);

    SetLength(Result, len);
    Exit;
  end;
  Result := '';
end;

function sqlite3_escape_binary_string(const Value: AnsiString): AnsiString;
var
  i: Integer;
  SrcLength: Integer;
  SrcBuffer: PAnsiChar;
  Ihx: Integer;
  Shx: AnsiString;
begin
  SrcLength := Length(Value);
  SrcBuffer := PAnsiChar(Value);

  SetLength(Result, 3 + SrcLength * 2);
  Result[1] := 'x'; // x
  Result[2] := ''''; // Open Quote
  Ihx := 3; // data start
  for i := 1 to SrcLength do
  begin
    Shx := AnsiString(IntToHex(Ord(SrcBuffer^), 2)); // '3E'

    Result[Ihx] := Shx[1];
    Inc(Ihx, 1); // copy '3'
    Result[Ihx] := Shx[2];
    Inc(Ihx, 1); // copy 'E'

    Inc(SrcBuffer, 1); // next
  end;

  Result[Ihx] := ''''; // Close Quote
end;

function sqlite3_unescape_binary_string(const AValue: AnsiString): AnsiString;
var
  i: Integer;
  SrcBuffer: PAnsiChar;
  Value: AnsiString;
begin
  Value := Copy(AValue, 3, Length(AValue) - 3);

  Value := sqlite3_lowercase(Value);

  i := Length(Value) div 2;

  SrcBuffer := PAnsiChar(Value);

  SetLength(Result, i);

  HexToBin(PAnsiChar(SrcBuffer), PAnsiChar(Result), i);
end;

function sqlite3_error_message(ACode: Integer): string;
begin
  case ACode of
    SQLITE_OK: Result := RS_SQLITE_MSG_OK;
    SQLITE_ERROR: Result := RS_SQLITE_MSG_ERROR;
    SQLITE_INTERNAL: Result := RS_SQLITE_MSG_INTERNAL;
    SQLITE_PERM: Result := RS_SQLITE_MSG_PERM;
    SQLITE_ABORT: Result := RS_SQLITE_MSG_ABORT;
    SQLITE_BUSY: Result := RS_SQLITE_MSG_BUSY;
    SQLITE_LOCKED: Result := RS_SQLITE_MSG_LOCKED;
    SQLITE_NOMEM: Result := RS_SQLITE_MSG_NOMEM;
    SQLITE_READONLY: Result := RS_SQLITE_MSG_READONLY;
    SQLITE_INTERRUPT: Result := RS_SQLITE_MSG_INTERRUPT;
    SQLITE_IOERR: Result := RS_SQLITE_MSG_IOERR;
    SQLITE_CORRUPT: Result := RS_SQLITE_MSG_CORRUPT;
    SQLITE_NOTFOUND: Result := RS_SQLITE_MSG_NOTFOUND;
    SQLITE_FULL: Result := RS_SQLITE_MSG_FULL;
    SQLITE_CANTOPEN: Result := RS_SQLITE_MSG_CANTOPEN;
    SQLITE_PROTOCOL: Result := RS_SQLITE_MSG_PROTOCOL;
    SQLITE_EMPTY: Result := RS_SQLITE_MSG_EMPTY;
    SQLITE_SCHEMA: Result := RS_SQLITE_MSG_SCHEMA;
    SQLITE_TOOBIG: Result := RS_SQLITE_MSG_TOOBIG;
    SQLITE_CONSTRAINT: Result := RS_SQLITE_MSG_CONSTRAINT;
    SQLITE_MISMATCH: Result := RS_SQLITE_MSG_MISMATCH;
    SQLITE_MISUSE: Result := RS_SQLITE_MSG_MISUSE;
    SQLITE_NOLFS: Result := RS_SQLITE_MSG_NOLFS;
    SQLITE_AUTH: Result := RS_SQLITE_MSG_AUTH;
    SQLITE_FORMAT: Result := RS_SQLITE_MSG_FORMAT;
    SQLITE_RANGE: Result := RS_SQLITE_MSG_RANGE;
    SQLITE_NOTADB: Result := RS_SQLITE_MSG_NOTADB;
    SQLITE_ROW: Result := RS_SQLITE_MSG_ROW;
    SQLITE_DONE: Result := RS_SQLITE_MSG_DONE;
  else
    Result := {$IFNDEF SQLITE_RUSSIAN_LOCALE}
    'Unknown error code'{$ELSE}
    'Неизвестный код возврата' +{$ENDIF}+
    '< ' + IntToStr(ACode) + ' >';
  end;
end;

function GetApiContext386(const ACtx: PSQLite3FuncContext; var apiCtx: PSQLiteDirectAPIContext): Boolean;
begin
  apiCtx := nil;
  if Assigned(ACtx) and Assigned(PSQLite3FuncContextRec(ACtx).pFuncDefn) then
    apiCtx := PSQLiteDirectAPIContext(PSQLiteFuncDefn386Rec(PSQLite3FuncContextRec(ACtx).pFuncDefn).pUserData);

  Result := Assigned(apiCtx) and Assigned(apiCtx.api);
end;

function GetApiContext387(const ACtx: PSQLite3FuncContext; var apiCtx: PSQLiteDirectAPIContext): Boolean;
begin
  apiCtx := nil;

  if Assigned(ACtx) and Assigned(PSQLite3FuncContext387Rec(ACtx).pFuncDefn) then
    apiCtx := PSQLiteDirectAPIContext(PSQLiteFuncDefn387Rec(PSQLite3FuncContext387Rec(ACtx).pFuncDefn).pUserData);

  Result := Assigned(apiCtx) and Assigned(apiCtx.api);
end;

function GetApiContext3250(const ACtx: PSQLite3FuncContext; var apiCtx: PSQLiteDirectAPIContext): Boolean;
begin
  apiCtx := nil;

  if Assigned(ACtx) and Assigned(PSQLite3FuncContext387Rec(ACtx).pFuncDefn) then
    apiCtx := PSQLiteDirectAPIContext(PSQLiteFuncDefn3250Rec(PSQLite3FuncContext387Rec(ACtx).pFuncDefn).pUserData);

  Result := Assigned(apiCtx) and Assigned(apiCtx.api);
end;

function sqlite3_maindb_alias(): string;
begin
  Result := 'main';
end;

const
  SQLITE3_PACKED_FILE_MAGIC = $ABA5A5AB;
  /// <summary>
  /// header, which begins every unpacked and not encrypted SQLite file
  /// </summary>
  SQLITE3_FILE_HEADER: array [0 .. 15] of AnsiChar = 'SQLite format 3';
  //53514c69746520666f726d6174203300
type
  TSQLite3HeaderString = array[0..15] of AnsiChar;
  TSqliteDatabaseHeaderRec = record
     headerStr: TSQLite3HeaderString;
     pageSize: Word;
     writeFormat: Byte; // 1 - legacy; 2 - val
     readFormat: Byte;
     pageReserved: Byte;
     maxPayLoad: Byte;
     minPayLoad: Byte;
     leafPayLoad: Byte;
     changesCounter: Integer;
     dbSizePages: Integer;
     firstFreePageNum: Integer;
     schemaCookie: Integer;
     schemaFormatVer: Integer;
     defPageCacheSize: Integer;
     maxBreePageNum: Integer;
     dbEncoding: Integer; // 1 - utf8; 2 - utf16le; 2 - utf16be;
     userVersion: Integer;
     bIncVacuumActive: LongBool;
     AppID: Integer;
     bReserved: array [0..19] of Byte;  // Reserved for expansion. Must be zero.
     versionValidNumber: Integer;
     libraryVersionNum: Integer;
  end;
  PSqliteDatabaseHeaderRec = ^TSqliteDatabaseHeaderRec;

type
  THash128 = array [0 .. 15] of Byte;
  TBlock128 = array [0 .. 3] of Cardinal;
  THash256 = array [0 .. 31] of Byte;

  PHash128Rec = ^THash128Rec;
  // helper to map 128-bit hash as an array of lower bit size values
  THash128Rec = packed record // consumes 16 bytes of memory
    case Integer of
      0: (Lo, Hi: Int64);
      1: (L, H: UInt64);
      2: (i0, i1, i2, i3: Integer);
      3: (c0, c1, c2, c3: Cardinal);
      4: (Block128: array [0 .. 3] of Cardinal); // 128-bit buffer (AES block)
      5: (Hash128: array [0 .. 15] of Byte); // 128-bit hash value
      6: (w: array [0 .. 7] of word);
  end;

  PHash256Rec = ^THash256Rec;
  // helper to map 256-bit hash as an array of lower bit size values
  THash256Rec = packed record // consumes 32 bytes of memory
    case Integer of
      0: (Lo, Hi: THash128);
      1: (d0, d1, d2, d3: Int64);
      2: (i0, i1, i2, i3, i4, i5, i6, i7: Integer);
      3: (c0, c1: TBlock128);
      4: (Block256: THash256);
      5: (q: array [0 .. 3] of UInt64);
      6: (C: array [0 .. 7] of Cardinal);
      7: (w: array [0 .. 15] of word);
  end;

var
  SQLITE3_FILE_HEADER128: THash128Rec absolute SQLITE3_FILE_HEADER;
  SQLITE3_FILE_HEADER256: THash256Rec absolute SQLITE3_FILE_HEADER;

function sqlite3_is_valid_file(const AFileName: TFileName; PageSize: PInteger): Boolean;
var
  FileHandle: THandle;
  FileHeader: THash256Rec;
begin
  Result := False;

  if (AFileName = '') or (SameText(AFileName, SQLITE_MEMORY_DB_NAME)) or (Pos(SQLITE_TEMP_DB_URI, AFileName) <> 0) then
    Exit; // in memory is not a file)

  FileHandle := FileOpen(AFileName, fmOpenRead or fmShareDenyNone);
  if FileHandle = INVALID_HANDLE_VALUE then
  begin
    Exit;
  end
  else
  begin
    try
      Result := FileRead(FileHandle, FileHeader, SizeOf(FileHeader)) = SizeOf(FileHeader);
      if not Result then // file empty or invalid
        Exit;

      Result := (FileHeader.d0 = SQLITE3_FILE_HEADER128.Lo) and
      // don't check header 8..15 (may equal encrypted bytes 16..23)
        (FileHeader.Block256[21] = 64) and (FileHeader.Block256[22] = 32) and (FileHeader.Block256[23] = 32);

      if Result and (PageSize <> nil) then
        // header bytes 16..23 are always stored unencrypted
        PageSize^ := Integer(FileHeader.Block256[16]) shl 8 + FileHeader.Block256[17];
    finally
      FileClose(FileHandle);
    end;
  end
end;

// see https://developers.google.com/maps/documentation/utilities/polylinealgorithm
function sqlite3_decode_latlng(const ASource: string; var VLatitude, VLongitude: Double; AEncodePrecision: Integer = 6): Boolean;
var
  Cnt, Index, Shift, Delta, Value, Block: Integer;

  Factor: Double;
begin
  Cnt := Length(ASource);

  Result := Cnt > 0;
  Index := 1;

  VLatitude := 0;
  VLongitude := 0;

  // Google Encoded Polyline Algorithm Format to a precision of 5 decimal places (180.00000 to -180.00000) but OSRM use a precision of six digits
  Factor := IntPower(10, -EnsureRange(AEncodePrecision, 5, 16));

  while Index < Cnt do
  begin
    Value := 0;
    Shift := 0;

    repeat
      Block := Ord(ASource[Index]) - 63;
      Inc(Index);

      Value := Value or ((Block and 31) shl Shift);

      Shift := Shift + 5;

    until (Block < 32);

    if (Value and 1) > 0 then
      Delta := not(Value shr 1)
    else
      Delta := Value shr 1;

    VLatitude := VLatitude + Delta;

    Value := 0;
    Shift := 0;

    repeat
      Block := Ord(ASource[Index]) - 63;
      Inc(Index);

      Value := Value or ((Block and 31) shl Shift);

      Shift := Shift + 5;

    until (Block < 32);

    if (Value and 1) > 0 then
      Delta := not(Value shr 1)
    else
      Delta := Value shr 1;

    VLongitude := VLongitude + Delta;

  end;

  VLatitude := VLatitude * Factor;
  VLongitude := VLongitude * Factor;
end;

function sqlite3_encode_latlng(ALatitude, ALongitude: Double; AEncodePrecision: Integer = 6): string;
// Google Encoded Polyline Algorithm Format  precision of 5 decimal places (180.00000 to -180.00000) but OSRM use a precision of six digits
var
  Value: Integer;
begin
  Result := '';

  ALatitude := EnsureRange(ALatitude, -85.051150, 85.051150);
  ALongitude := EnsureRange(ALongitude, -180.000000, 180.000000);

  AEncodePrecision := Round(IntPower(10, -EnsureRange(AEncodePrecision, 5, 16)));
  // Convert the decimal value to binary.
  // Left-shift the binary value one bit
  Value := Round(ALatitude * AEncodePrecision) shl 1;
  // If the original decimal value is negative, invert this encoding
  if Value < 0 then
    Value := not Value;

  while Value >= 32 do
  begin

    Result := Result + chr((32 or (Value and 31)) + 63);

    Value := Value shr 5;

  end;

  Result := Result + chr(Value + 63);
  Value := Abs(Round(ALongitude * AEncodePrecision) shl 1);

  while Value >= 32 do
  begin

    Result := Result + chr((32 or (Value and 31)) + 63);

    Value := Value shr 5;

  end;

  Result := Result + chr(Value + 63);
end;

function sqlite3_compare_string_ordinal(s1,s2: string): Integer; cdecl;
var
  s1IsInt, s2IsInt: Boolean;
  s1Cursor, s2Cursor: PChar;
  s1Int, s2Int, counter, s1IntCount, s2IntCount: Integer;
  singleByte: Byte;
begin
  if s1 = '' then
  begin
    if s2 = '' then
    begin
      Result := EqualsValue;
      Exit;
    end
    else
    begin
      Result := LessThanValue;
      Exit;
    end;
  end;

  if s2 = '' then
  begin
    Result := GreaterThanValue;
    Exit;
  end;

  s1Cursor := @AnsiLowerCase(s1)[1];
  s2Cursor := @AnsiLowerCase(s2)[1];

  while True do
  begin
    // check for first string end
    if s1Cursor^ = #0 then
    begin
      if s2Cursor^ = #0 then
      begin
        Result := EqualsValue;
        Exit;
      end
      else
      begin
        Result := LessThanValue;
        Exit;
      end;
    end;

    // check for second string end
    if S2Cursor^ = #0 then
    begin
      Result := GreaterThanValue;
      Exit;
    end;

    // check for both strings is the beginning of a numbers
    s1IsInt := CharInSet(s1Cursor^, ['0'..'9']);
    s2IsInt := CharInSet(s2Cursor^, ['0'..'9']);
    if S1IsInt and not S2IsInt then
    begin
      Result := LessThanValue;
      Exit;
    end;

    if not S1IsInt and S2IsInt then
    begin
      Result := GreaterThanValue;
      Exit;
    end;

    // per character comparison
    if not (S1IsInt and S2IsInt) then
    begin
      if s1Cursor^ = s2Cursor^ then
      begin
        Inc(s1Cursor);
        Inc(s2Cursor);

        Continue;
      end;

      if s1Cursor^ < s2Cursor^ then
      begin
        Result := LessThanValue;
        Exit;
      end
      else
      begin
        Result := GreaterThanValue;
        Exit;
      end;
    end;

    // extract the numbers from both strings and compare them
    s1Int := 0;
    counter := 1;
    s1IntCount := 0;
    repeat
      Inc(s1IntCount);
      singleByte := Byte(s1Cursor^) - Byte('0');
      s1Int := S1Int * Counter + singleByte;
      Inc(s1Cursor);
      counter := 10;
    until not CharInSet(s1Cursor^, ['0'..'9']);

    s2Int := 0;
    counter := 1;
    s2IntCount := 0;

    repeat
      singleByte := Byte(s2Cursor^) - Byte('0');
      Inc(s2IntCount);
      s2Int := s2Int * counter + singleByte;
      Inc(s2Cursor);
      counter := 10;
    until not CharInSet(s2Cursor^, ['0'..'9']);

    if s1Int = s2Int then
    begin
      if s1Int = 0 then
      begin
        Result := CompareValue(s1IntCount,s2IntCount);
        if Result <> EqualsValue then
          Exit;
//        if s1IntCount < s2IntCount then
//        begin
//          Result := LessThanValue;
//          Exit;
//        end;
//        if S1IntCount > S2IntCount then
//        begin
//          Result := GreaterThanValue;
//          Exit;
//        end;
      end;

      Continue;
    end;

    Result := CompareValue(s1Int,s2Int);
    if Result <> EqualsValue then
      Exit;

//    if s1Int < s2Int then
//    begin
//      Result := LessThanValue;
//      Exit;
//    end
//    else
//    begin
//      Result := GreaterThanValue;
//      Exit;
//    end;
  end;

end;
end.
