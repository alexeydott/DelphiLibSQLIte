unit sqlite3.static;

interface
{$include 'sqlite3.config.inc'}
uses
  sqlite3.common;
{$IFDEF MSWINDOWS}
{$warn SYMBOL_PLATFORM OFF}
{$ENDIF} // MSWINDOWS

function sqlite3_db_filename(db: Pointer; zDbName: Pointer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_filename';
function sqlite3_libversion: MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_libversion';
function sqlite3_sourceid: MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_sourceid';
function sqlite3_libversion_number: Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_libversion_number';

function sqlite3_compileoption_used(zOptName: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_compileoption_used';
function sqlite3_compileoption_get(N: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_compileoption_get';
function sqlite3_create_filename(zDB, zJournal, zWal: MarshaledAString; nParam: Integer; azParam: PMarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_filename';
procedure sqlite3_free_filename(zFilename: MarshaledAString); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_free_filename';

function sqlite3_threadsafe: Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_threadsafe';
function sqlite3_close(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_close';
function sqlite3_close_v2(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_close_v2';

function sqlite3_exec(pDB: Pointer; zSql: MarshaledAString; xCallback: TxExecCallback; CallbackArg: Pointer; ErrMsg: PMarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_exec';

function sqlite3_initialize: Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_initialize';
function sqlite3_shutdown: Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_shutdown';
function sqlite3_os_init: Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_os_init';
function sqlite3_os_end: Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_os_end';

function sqlite3_config(Option: Integer): Integer; cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_config';
function sqlite3_db_config(pDB: Pointer; op: Integer): Integer; cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_config';
function sqlite3_db_readonly(db: Pointer; zDbName: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_readonly';

function sqlite3_extended_result_codes(pDB: Pointer; onoff: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_extended_result_codes';
function sqlite3_last_insert_rowid(pDB: Pointer): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_last_insert_rowid';
procedure sqlite3_set_last_insert_rowid(pDB: Pointer; iRowid: Int64); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_set_last_insert_rowid';
function sqlite3_changes(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_changes';
function sqlite3_total_changes(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_total_changes';
// since 3.36.1
function sqlite3_changes64(pDB: Pointer): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_changes64';
// since 3.36.1
function sqlite3_total_changes64(pDB: Pointer): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_total_changes64';
procedure sqlite3_interrupt(pDB: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_interrupt';
// since 3.41.0
function sqlite3_is_interrupted(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_is_interrupted';
function sqlite3_complete(sql: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_complete';
function sqlite3_complete16(sql: MarshaledString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_complete16';

function sqlite3_busy_handler(pDB: Pointer; Callback: TxBusyHandlerCallback; Ptr: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_busy_handler';
function sqlite3_busy_timeout(pDB: Pointer; ms: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_busy_timeout';
// since 3.50.0
function sqlite3_setlk_timeout(pDB: Pointer; ms, flags: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_setlk_timeout';

function sqlite3_get_table(db: Pointer; zSql: MarshaledAString; var pazResult: PMarshaledAString; var pnRow, pnColumn: Integer; var pzErrmsg: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_get_table';
procedure sqlite3_free_table(result: PMarshaledAString); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_free_table';

function sqlite3_mprintf(Str: MarshaledAString): MarshaledAString; cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_mprintf';
function sqlite3_vmprintf(Str: MarshaledAString; ArgList: Pointer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vmprintf';
function sqlite3_snprintf(Size: Integer; Str: MarshaledAString; Format: MarshaledAString): MarshaledAString; cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_snprintf';
function sqlite3_vsnprintf(Size: Integer; Str: MarshaledAString; Format: MarshaledAString; ArgList: Pointer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vsnprintf';

function sqlite3_malloc(nBytes: Integer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_malloc';
function sqlite3_malloc64(nBytes: UInt64): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_malloc64';
function sqlite3_realloc(Ptr: Pointer; nBytes: Integer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_realloc';
function sqlite3_realloc64(mMem: Pointer; nBytes: UInt64): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_realloc64';

procedure sqlite3_free(Ptr: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_free';
function sqlite3_msize(pMem: Pointer): UInt64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_msize';

function sqlite3_memory_used: Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_memory_used';
function sqlite3_memory_highwater(resetFlag: Integer): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_memory_highwater';

procedure sqlite3_randomness(N: Integer; Arg0: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_randomness';

{$IFDEF SQLITE3_USE_CIPHER}
function sqlite3_key(pDB: Pointer; Key: MarshaledAString; iKeyLen: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_key';
function sqlite3_key_v2(pDB: Pointer; zDbName, zKey: MarshaledAString; iKeyLen: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_key_v2';
function sqlite3_rekey(db: Pointer; Key: MarshaledAString; Len: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_rekey';
function sqlite3_rekey_v2(pDB: Pointer; zDbName: MarshaledAString; zNewKey: MarshaledAString; iNewKeyLen: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_rekey_v2';
procedure sqlite3_activate_see(zPassPhrase: MarshaledAString); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_activate_see';
{$ENDIF}
function sqlite3_set_authorizer(pDB: Pointer; xAuth: TxAuth; UserData: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_set_authorizer';
// since 3.37.0
function sqlite3_autovacuum_pages(pDB: Pointer; xCallback: TxDbAutovacuumPagesCallback; UserData: Pointer; UserDataDestructor: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_autovacuum_pages';

{$IFDEF link_deprecated_api}
function sqlite3_trace(pDB: Pointer; xTrace: TxTrace; Ptr: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_trace'; deprecated 'use sqlite3_trace_v2 instead';
function sqlite3_profile(db: Pointer; xProfile: TxProfile; Ptr: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_profile'; deprecated 'use sqlite3_trace_v2 instead';
function sqlite3_expired(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_expired'; deprecated;
{$ENDIF}
function sqlite3_trace_v2(db: Pointer; uMask: Cardinal; xTraceFunc: TxTrace2; pCtx: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_trace_v2';

procedure sqlite3_progress_handler(pDB: Pointer; N: Integer; Callback: TxProgressHandlerCallback; pUserData: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_progress_handler';

function sqlite3_open(filename: MarshaledAString; var ppDb: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_open';
function sqlite3_open16(filename: MarshaledString; var ppDb: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_open16';
function sqlite3_open_v2(filename: MarshaledAString; var ppDb: Pointer; flags: Integer; zVfs: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_open_v2';

function sqlite3_uri_boolean(zFile, zParam: MarshaledAString; bDefault: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_uri_boolean';
function sqlite3_uri_int64(zFilename, zParam: MarshaledAString; iDefault: Int64): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_uri_int64';
function sqlite3_uri_parameter(zFilename, zParam: MarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_uri_parameter';
function sqlite3_uri_key(zFilename: MarshaledAString; nNumb: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_uri_key';


function sqlite3_errcode(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_errcode';
function sqlite3_system_errno(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_system_errno';
function sqlite3_errstr(iRetCode: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_errstr';
function sqlite3_extended_errcode(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_extended_errcode';
function sqlite3_errmsg(pDB: Pointer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_errmsg';
function sqlite3_errmsg16(pDB: Pointer): MarshaledString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_errmsg16';
// since 3.51.0
function sqlite3_set_errmsg(pDB: Pointer; errCode: Integer; zErrMsg: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_set_errmsg';
// since 3.38.0
function sqlite3_error_offset(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_error_offset';
// since 3.39.0
function sqlite3_db_name(pDb: Pointer; dbIndex: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_name';

// since 3.43.0
function sqlite3_stmt_explain(pStmt: Pointer; eMode: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_stmt_explain';
// since 3.44.0
function sqlite3_get_clientdata(pDB: Pointer; zName: MarshaledAString): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_get_clientdata';
// since 3.44.0
function sqlite3_set_clientdata(pDB: Pointer; zName: MarshaledAString; pData: Pointer; xDataDestructor: TxAuxDataDestructor): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_set_clientdata';

function sqlite3_limit(pDB: Pointer; id: Integer; newVal: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_limit';

function sqlite3_prepare(pDB: Pointer; zSql: MarshaledAString; nByte: Integer; var ppStmt: Pointer; ppzTail: PMarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_prepare';
function sqlite3_prepare_v2(pDB: Pointer; zSql: MarshaledAString; nByte: Integer; var ppStmt: Pointer; ppzTail: PMarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_prepare_v2';
function sqlite3_prepare_v3(pDB: Pointer; zSql: MarshaledAString; nByte: Integer; prepFlags: Cardinal; var ppStmt: Pointer; ppzTail: PMarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_prepare_v3';

function sqlite3_prepare16(pDB: Pointer; zSql: MarshaledString; nByte: Integer; var ppStmt: Pointer; ppzTail: PMarshaledString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_prepare16';
function sqlite3_prepare16_v2(pDB: Pointer; zSql: MarshaledString; nByte: Integer; var ppStmt: Pointer; ppzTail: PMarshaledString): Integer; overload; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_prepare16_v2';
function sqlite3_prepare16_v3(pDB: Pointer; zSql: MarshaledString; nByte: Integer; prepFlags: Cardinal; var pStmt: Pointer; ppzTail: PMarshaledString): Integer; cdecl; external name SQLITE_METHOD_PREFIX+'sqlite3_prepare16_v3';

// since 3.26.0
{$IFDEF SQLITE_ENABLE_NORMALIZE}
function sqlite3_normalized_sql(pStmt: Pointer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX+'sqlite3_normalized_sql';
{$ENDIF}
function sqlite3_sql(pStmt: Pointer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX+'sqlite3_sql';
function sqlite3_expanded_sql(pStmt: Pointer): MarshaledAString; overload; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_expanded_sql';

function sqlite3_stmt_status(pStmt: Pointer; op, resetFlg: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_stmt_status';
function sqlite3_stmt_readonly(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_stmt_readonly';
function sqlite3_stmt_busy(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_stmt_busy';

function sqlite3_stmt_isexplain(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_stmt_isexplain';

function sqlite3_bind_blob(Statement: Pointer; Index: Integer; Value: Pointer; nBytes: Integer; Proc: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_blob';
function sqlite3_bind_blob64(Statement: Pointer; Index: Integer; Value: Pointer; nBytes: Int64; Proc: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_blob64';
function sqlite3_bind_double(Statement: Pointer; Index: Integer; Value: Double): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_double';
function sqlite3_bind_int(Statement: Pointer; Index: Integer; Value: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_int';
function sqlite3_bind_int64(Statement: Pointer; Index: Integer; Value: Int64): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_int64';
function sqlite3_bind_null(Statement: Pointer; Index: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_null';
function sqlite3_bind_text(Statement: Pointer; Index: Integer; Value: MarshaledAString; N: Integer; Proc: TxDestroy): Integer; overload; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_text';
function sqlite3_bind_text64(Statement: Pointer; Index: Integer; Value: MarshaledAString; N: UInt64; Proc: TxDestroy; encoding: Byte): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_text64';
function sqlite3_bind_text16(Statement: Pointer; Index: Integer; Value: MarshaledString; N: Integer; Proc: TxDestroy): Integer; overload; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_text16';

function sqlite3_bind_value(Statement: Pointer; Index: Integer; Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_value';
function sqlite3_bind_pointer(Statement: Pointer; Index: Integer; var pPtr; const zText: MarshaledAString; xDestructor: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_pointer';
function sqlite3_bind_zeroblob(Statement: Pointer; Index, N: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_zeroblob';
function sqlite3_bind_zeroblob64(Statement: Pointer; Index: Integer; N: UInt64): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_zeroblob64';
function sqlite3_bind_parameter_count(Statement: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_parameter_count';
function sqlite3_bind_parameter_name(Statement: Pointer; ParamNum: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_parameter_name';
function sqlite3_bind_parameter_index(Statement: Pointer; zName: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_bind_parameter_index';
function sqlite3_clear_bindings(Statement: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_clear_bindings';

function sqlite3_column_count(Statement: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_count';
function sqlite3_column_name(Statement: Pointer; N: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_name';
function sqlite3_column_name16(Statement: Pointer; N: Integer): MarshaledString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_name16';

function sqlite3_column_database_name(Statement: Pointer; ColumnNum: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_database_name';
function sqlite3_column_database_name16(Statement: Pointer; ColumnNum: Integer): MarshaledString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_database_name16';
function sqlite3_column_table_name(Statement: Pointer; ColumnNum: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_table_name';
function sqlite3_column_table_name16(Statement: Pointer; ColumnNum: Integer): MarshaledString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_table_name16';
function sqlite3_column_origin_name(Statement: Pointer; ColumnNum: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_origin_name';
function sqlite3_column_origin_name16(Statement: Pointer; ColumnNum: Integer): MarshaledString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_origin_name16';

function sqlite3_column_decltype(Statement: Pointer; ColumnNum: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_decltype';
function sqlite3_column_decltype16(Statement: Pointer; ColumnNum: Integer): MarshaledString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_decltype16';

function sqlite3_step(Statement: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_step';
function sqlite3_data_count(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_data_count';
// Delphi-safe accessor for the sqlite3_data_directory C global.
function sqlite3_get_data_directory: MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'delphi_sqlite3_data_directory';
function sqlite3_db_cacheflush(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_cacheflush';
function sqlite3_db_release_memory(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_release_memory';

function sqlite3_column_blob(Statement: Pointer; iCol: Integer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_blob';
function sqlite3_column_bytes(Statement: Pointer; iCol: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_bytes';
function sqlite3_column_bytes16(Statement: Pointer; iCol: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_bytes16';
function sqlite3_column_double(Statement: Pointer; iCol: Integer): Double; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_double';
function sqlite3_column_int(Statement: Pointer; iCol: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_int';
function sqlite3_column_int64(Statement: Pointer; iCol: Integer): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_int64';
function sqlite3_column_text(Statement: Pointer; iCol: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_text';
function sqlite3_column_text16(Statement: Pointer; iCol: Integer): PChar; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_text16';
function sqlite3_column_type(Statement: Pointer; iCol: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_type';
function sqlite3_column_value(Statement: Pointer; iCol: Integer): PSQLiteValue; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_column_value';

function sqlite3_finalize(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_finalize';
function sqlite3_reset(pStmt: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_reset';

function sqlite3_create_function(db: Pointer; zFunctionName: MarshaledAString; nArg, eTextRep: Integer; pApp: Pointer; xFunc: TxSFunc; xStep: TxSFunc; xFinal: TxFinalize): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_function';
function sqlite3_create_function16(db: Pointer; zFunctionName: PChar; nArg, eTextRep: Integer; pApp: Pointer; xFunc: TxSFunc; xStep: TxSFunc; xFinal: TxFinalize): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_function16';
function sqlite3_create_function_v2(db: Pointer; zFunctionName: MarshaledAString; nArg, eTextRep: Integer; pApp: Pointer; xFunc: TxSFunc; xStep: TxSFunc; xFinal: TxFinalize; xDestroy: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_function_v2';
function sqlite3_create_window_function(pDB: Pointer; zName: MarshaledAString; nArgs, eTextRep: Integer; pApp: Pointer; xStep: TxSFunc; xFinal, xValue: TxValue; xInverse: TxSFunc; xDestroy: TxDestroy): Integer; cdecl;  external name SQLITE_METHOD_PREFIX + 'sqlite3_create_window_function';
function sqlite3_overload_function(pDB: Pointer; zFuncName: MarshaledAString; nArg: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_overload_function';

function sqlite3_value_blob(Value: PSQLiteValue): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_blob';
function sqlite3_value_bytes(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_bytes';
function sqlite3_value_bytes16(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_bytes16';
function sqlite3_value_double(Value: PSQLiteValue): Double; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_double';
function sqlite3_value_dup(Orig: PSQLiteValue): PSQLiteValue; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_dup';
// since 3.40.0
function sqlite3_value_encoding(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_encoding';
function sqlite3_value_int(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_int';
function sqlite3_value_int64(Value: PSQLiteValue): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_int64';
function sqlite3_value_text(Value: PSQLiteValue): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_text';
function sqlite3_value_text16(Value: PSQLiteValue): PChar; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_text16';
function sqlite3_value_text16le(Value: PSQLiteValue): PChar; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_text16le';
function sqlite3_value_text16be(Value: PSQLiteValue): PChar; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_text16be';
function sqlite3_value_type(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_type';
function sqlite3_value_subtype(Value: PSQLiteValue): Cardinal; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_subtype';
function sqlite3_value_numeric_type(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_numeric_type';
procedure sqlite3_value_free(Value: PSQLiteValue); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_free';
function sqlite3_value_str(Value: PSQLiteValue): RawByteString; cdecl;
function sqlite3_value_str16(Value: PSQLiteValue; Unicode: Boolean): string; cdecl;

function sqlite3_value_frombind(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_frombind';

function sqlite3_value_nochange(Value: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_nochange';
function sqlite3_value_pointer(Value: PSQLiteValue; V: MarshaledAString): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_value_pointer';

function sqlite3_aggregate_context(pCtx: PSQLite3FuncContext; nBytes: Integer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_aggregate_context';
function sqlite3_user_data(pCtx: PSQLite3FuncContext): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_user_data';
function sqlite3_context_db_handle(pCtx: PSQLite3FuncContext): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_context_db_handle';

function sqlite3_get_auxdata(pCtx: PSQLite3FuncContext; N: Integer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_get_auxdata';
procedure sqlite3_set_auxdata(pCtx: PSQLite3FuncContext; N: Integer; AData: Pointer; ADataDestructor: TxAuxDataDestructor); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_set_auxdata';

procedure sqlite3_result_blob(pCtx: PSQLite3FuncContext; Data: Pointer; Size: Integer; Proc: TxDestroy); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_blob';
procedure sqlite3_result_blob64(pCtx: PSQLite3FuncContext; Value: Pointer; nBytes: UInt64; xDestroy: TxDestroy); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_blob64';
procedure sqlite3_result_double(pCtx: PSQLite3FuncContext; Data: Double); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_double';
procedure sqlite3_result_error(pCtx: PSQLite3FuncContext; ErrorString: MarshaledAString; Size: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_error';
procedure sqlite3_result_error16(pCtx: PSQLite3FuncContext; ErrorString: PChar; Size: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_error16';
procedure sqlite3_result_error_toobig(pCtx: PSQLite3FuncContext); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_error_toobig';
procedure sqlite3_result_error_nomem(pCtx: PSQLite3FuncContext); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_error_nomem';
procedure sqlite3_result_error_code(pCtx: PSQLite3FuncContext; Code: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_error_code';

procedure sqlite3_result_int(pCtx: PSQLite3FuncContext; Data: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_int';
procedure sqlite3_result_int64(pCtx: PSQLite3FuncContext; Data: Int64); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_int64';
procedure sqlite3_result_null(pCtx: PSQLite3FuncContext); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_null';
procedure sqlite3_result_pointer(pCtx: PSQLite3FuncContext; Value: Pointer; const zType: MarshaledAString; xDestroy: TxDestroy); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_pointer';
procedure sqlite3_result_subtype(pCtx: PSQLite3FuncContext; iSubtype: Cardinal); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_subtype';
procedure sqlite3_result_text(pCtx: PSQLite3FuncContext; Data: MarshaledAString; Size: Integer; Proc: TxDestroy); overload; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_text';
procedure sqlite3_result_text64(pCtx: PSQLite3FuncContext; Value: MarshaledAString; nBytes: UInt64; xDestroy: TxDestroy; encoding: Byte); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_text64';
procedure sqlite3_result_text16(pCtx: PSQLite3FuncContext; Data: PChar; Size: Integer; Proc: TxDestroy); overload; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_text16';
procedure sqlite3_result_text16le(pCtx: PSQLite3FuncContext; Data: PChar; Size: Integer; Proc: TxDestroy); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_text16le';
procedure sqlite3_result_text16be(pCtx: PSQLite3FuncContext; Data: PChar; Size: Integer; Proc: TxDestroy); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_text16be';
procedure sqlite3_result_value(pCtx: PSQLite3FuncContext; Data: PSQLiteValue); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_value';
procedure sqlite3_result_zeroblob(pCtx: PSQLite3FuncContext; N: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_zeroblob';
procedure sqlite3_result_zeroblob64(pCtx: PSQLite3FuncContext; nBytes: UInt64); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_result_zeroblob64';

function sqlite3_txn_state(pDB: Pointer; zSchema: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_txn_state';

function sqlite3_create_collation(pDB: Pointer; zName: MarshaledAString; eTextRep: Integer; pArg: Pointer; xCompare: TxCompare): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_collation';
function sqlite3_create_collation_v2(pDB: Pointer; zName: MarshaledAString; eTextRep: Integer; pArg: Pointer; xCompare: TxCompare; xDestroy: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_collation_v2';
function sqlite3_create_collation16(pDB: Pointer; zName: PChar; eTextRep: Integer; pArg: Pointer; xCompare: TxCompare): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_collation16';
function sqlite3_collation_needed(pDB: Pointer; pUserData: Pointer; xCallback: TxCollationNeededCallback): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_collation_needed';
function sqlite3_collation_needed16(pDB: Pointer; pUserData: Pointer; xCallback: TxCollationNeededCallback16): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_collation_needed16';

function sqlite3_sleep(ms: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_sleep';

function sqlite3_get_autocommit(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_get_autocommit';
function sqlite3_db_handle(Statement: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_handle';
function sqlite3_next_stmt(pDB: Pointer; pStmt: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_next_stmt';

function sqlite3_commit_hook(pDB: Pointer; Callback: TxCommitHook; Ptr: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_commit_hook';
function sqlite3_rollback_hook(pDB: Pointer; Callback: TxRollbackHook; Ptr: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_rollback_hook';
function sqlite3_update_hook(pDB: Pointer; Callback: TxUpdateHook; Ptr: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_update_hook';

function sqlite3_enable_shared_cache(Enable: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_enable_shared_cache';

function sqlite3_release_memory(Size: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_release_memory';

function sqlite3_soft_heap_limit64(N: Int64): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_soft_heap_limit64';

function sqlite3_table_column_metadata(db: Pointer; zDbName, zTableName, zColumnName: MarshaledAString; ppzDataType, ppzCollSeq: PMarshaledAString; pNotNull, pPrimaryKey, pAutoinc: PInteger): Integer; cdecl;
  external name SQLITE_METHOD_PREFIX + 'sqlite3_table_column_metadata';

function sqlite3_load_extension(db: Pointer; zFile, zProc: MarshaledAString; ppzErrMsg: PMarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_load_extension';
function sqlite3_enable_load_extension(db: Pointer; onoff: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_enable_load_extension';


function sqlite3_auto_extension(xEntryPoint: TxEntryPoint): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_auto_extension';
procedure sqlite3_reset_auto_extension; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_reset_auto_extension';
function sqlite3_cancel_auto_extension(xEntryPoint: TxEntryPoint): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_cancel_auto_extension';

function sqlite3_create_module(db: Pointer; zName: MarshaledAString; Arg0: PSQLiteModule; pClientData: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_module';
function sqlite3_create_module_v2(db: Pointer; zName: MarshaledAString; Arg0: PSQLiteModule; pClientData: Pointer; Proc: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_create_module_v2';
// since 3.30.0
function sqlite3_drop_modules(db: Pointer; azKeep: PMarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_drop_modules';

function sqlite3_declare_vtab(pDB: Pointer; zSql: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_declare_vtab';
function sqlite3_vtab_collation(pIndex: PSQLiteIndexInfo; iIndex: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_collation';
function sqlite3_vtab_nochange(pCtxt: PSQLite3FuncContext): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_nochange';
function sqlite3_vtab_config(pDB: Pointer; op: Integer): Integer; cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_config';
function sqlite3_vtab_on_conflict(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_on_conflict';
// since 3.38.0
function sqlite3_vtab_distinct(pIndex: PSQLiteIndexInfo): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_distinct';
// since 3.38.0
function sqlite3_vtab_rhs_value(pIndex: PSQLiteIndexInfo; iIndex: Integer; var ppVal: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_rhs_value';
// since 3.38.0
function sqlite3_vtab_in(pIndex: PSQLiteIndexInfo; iCons, bHandle: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_in';
// since 3.38.0
function sqlite3_vtab_in_first(pVal: PSQLiteValue; var ppOut: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_in_first';
// since 3.38.0
function sqlite3_vtab_in_next(pVal: PSQLiteValue; var ppOut: PSQLiteValue): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vtab_in_next';

function sqlite3_blob_open(pDB: Pointer; zDb, zTable, zColumn: MarshaledAString; iRow: Int64; flags: Integer; ppBlob: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_blob_open';
function sqlite3_blob_reopen(Blob: Pointer; Rowid: Int64): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_blob_reopen';
function sqlite3_blob_close(Blob: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_blob_close';
function sqlite3_blob_bytes(Blob: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_blob_bytes';
function sqlite3_blob_read(Blob, Z: Pointer; N, iOffset: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_blob_read';
function sqlite3_blob_write(Blob, Z: Pointer; N, iOffset: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_blob_write';

function sqlite3_vfs_find(zVfsName: MarshaledAString): PSQLiteVfs; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vfs_find';
function sqlite3_vfs_register(Vfs: PSQLiteVfs; makeDflt: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vfs_register';
function sqlite3_vfs_unregister(Vfs: PSQLiteVfs): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vfs_unregister';

function sqlite3_mutex_alloc(Value: Integer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_mutex_alloc';
procedure sqlite3_mutex_free(Mutex: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_mutex_free';
procedure sqlite3_mutex_enter(Mutex: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_mutex_enter';
function sqlite3_mutex_try(Mutex: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_mutex_try';
procedure sqlite3_mutex_leave(Mutex: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_mutex_leave';

function sqlite3_db_mutex(pDB: Pointer): PSQLiteMutex; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_mutex';
function sqlite3_file_control(pDB: Pointer; zDbName: MarshaledAString; op: Integer; Ptr: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_file_control';
function sqlite3_test_control(op: Integer): Integer; cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_test_control';

function sqlite3_status(op: Integer; var pCurrent, pHighwater: Integer; resetFlag: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_status';

function sqlite3_db_status(pDB: Pointer; op: Integer; var pCur, pHiwtr: Integer; resetFlg: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_status';
// since 3.51.0
function sqlite3_db_status64(pDB: Pointer; op: Integer; var pCur, pHiwtr: Int64; resetFlg: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_status64';

function sqlite3_backup_init(pDest: Pointer; zDestName: MarshaledAString; pSource: Pointer; zSourceName: MarshaledAString): PSQLite3Backup; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_backup_init';
function sqlite3_backup_step(pBckp: PSQLite3Backup; nPage: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_backup_step';
function sqlite3_backup_finish(pBckp: PSQLite3Backup): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_backup_finish';
function sqlite3_backup_remaining(pBckp: PSQLite3Backup): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_backup_remaining';
function sqlite3_backup_pagecount(pBckp: PSQLite3Backup): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_backup_pagecount';

function sqlite3_keyword_check(Z: MarshaledAString; L: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_keyword_check';
function sqlite3_keyword_count(): Integer cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_keyword_count';
function sqlite3_keyword_name(iKey: Integer; var pzName: MarshaledAString; var pnName: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_keyword_name';

function sqlite3_serialize(pDB: Pointer; zSchema: MarshaledAString; piSize: PInt64; mFlags: Cardinal): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_serialize';
function sqlite3_deserialize(pDB: Pointer; zSchema: MarshaledAString; pUserData: Pointer; iDBSize, iBufSize: Int64; iFlags: Cardinal): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_deserialize';
// since 3.51.0
function sqlite3_carray_bind(pStmt: Pointer; i: Integer; aData: Pointer; nData, mFlags: Integer; xDestroy: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_carray_bind';
// since 3.52.0
function sqlite3_carray_bind_v2(pStmt: Pointer; i: Integer; aData: Pointer; nData, mFlags: Integer; xDestroy: TxDestroy; pDestroy: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_carray_bind_v2';

procedure sqlite3_soft_heap_limit(iNew: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_soft_heap_limit';
function sqlite3_status64(op: Integer; var pCurrent, pHighwater: Int64; resetFlag: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_status64';
// since 3.31.0
function sqlite3_hard_heap_limit64(N: Int64): Int64; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_hard_heap_limit64';

procedure sqlite3_str_append(pStr: PSQLite3Str; zIn: MarshaledAString; nBytes: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_append';
procedure sqlite3_str_appendall(pStr: PSQLite3Str; zIn: MarshaledAString); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_appendall';
procedure sqlite3_str_appendchar(pStr: PSQLite3Str; nCopies: Integer; C: AnsiChar); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_appendchar';
procedure sqlite3_str_appendf(pStr: PSQLite3Str; zFormat: MarshaledAString);cdecl varargs;external name SQLITE_METHOD_PREFIX + 'sqlite3_str_appendf';
function sqlite3_str_errcode(pStr: PSQLite3Str): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_errcode';
function sqlite3_str_finish(pStr: PSQLite3Str): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_finish';
// since 3.52.0
procedure sqlite3_str_free(pStr: PSQLite3Str); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_free';
function sqlite3_str_length(pStr: PSQLite3Str): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_length';
function sqlite3_str_new(pDB: Pointer): PSQLite3Str; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_new';
procedure sqlite3_str_reset(pStr: PSQLite3Str); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_reset';
// since 3.52.0
procedure sqlite3_str_truncate(pStr: PSQLite3Str; N: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_truncate';
function sqlite3_str_value(pStr: PSQLite3Str): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_value';
procedure sqlite3_str_vappendf(pStr: PSQLite3Str; zFormat: MarshaledAString; ArgList: Pointer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_str_vappendf';

function sqlite3_strglob(zGlob: MarshaledAString; zStr: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_strglob';

function sqlite3_stricmp(zStr1, zStr2: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_stricmp';
function sqlite3_strlike(zGlob, zStr: MarshaledAString; cEsc: Cardinal): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_strlike';
function sqlite3_strnicmp(Str1: MarshaledAString; Str2: MarshaledAString; MaxLen: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_strnicmp';

// procedure sqlite3_thread_cleanup(); cdecl; // deprecated;
// sqlite3_transfer_bindings(pStmtFrom, pStmtTo: Pointer): Integer; cdecl; // deprecated;

{$REGION 'win specific'}
{$IFDEF MSWINDOWS}
function sqlite3_win32_is_nt(): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_is_nt';
function sqlite3_win32_mbcs_to_utf8(zText: MarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_mbcs_to_utf8';
function sqlite3_win32_mbcs_to_utf8_v2(zText: MarshaledAString; bUseAnsi: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_mbcs_to_utf8_v2';
function sqlite3_win32_set_directory(dwType: Cardinal; zValue: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_set_directory';
function sqlite3_win32_set_directory16(dwType: Cardinal; zValue: MarshaledString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_set_directory16';
function sqlite3_win32_set_directory8(dwType: Cardinal; zValue: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_set_directory8';
procedure sqlite3_win32_sleep(dwMilliseconds: Cardinal); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_sleep';
function sqlite3_win32_unicode_to_utf8(zWideText: PWideChar): PUtf8Char; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_unicode_to_utf8';
function sqlite3_win32_utf8_to_mbcs(zText: PUtf8Char): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_utf8_to_mbcs';
function sqlite3_win32_utf8_to_mbcs_v2(zText: PUtf8Char; bUseAnsi: Integer): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_utf8_to_mbcs_v2';
function sqlite3_win32_utf8_to_unicode(zUtf8Text: PUtf8Char): PWideChar; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_utf8_to_unicode';
procedure sqlite3_win32_write_debug(zBuf: MarshaledAString; nBytes: Integer); cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_win32_write_debug';
{$ENDIF}
{$ENDREGION 'win specific'}
procedure sqlite3_log(iErrCode: Integer; zFormat: MarshaledAString); cdecl; varargs; external name SQLITE_METHOD_PREFIX + 'sqlite3_log';

function sqlite3_wal_hook(pDB: Pointer; Callback: TxWalHookCallback; Ptr: Pointer): Pointer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_wal_hook';
function sqlite3_wal_autocheckpoint(db: Pointer; N: Integer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_wal_autocheckpoint';
function sqlite3_wal_checkpoint(db: Pointer; zDb: MarshaledAString): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_wal_checkpoint';
function sqlite3_wal_checkpoint_v2(db: Pointer; zDb: MarshaledAString; eMode: Integer; pnLog, pnCkpt: PInteger): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_wal_checkpoint_v2';

/// Database File Corresponding To A Journal
function sqlite3_database_file_object(zName: MarshaledAString): PSQLiteFile; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_database_file_object';

/// Translate filenames
function sqlite3_filename_database(f: MarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_filename_database';
function sqlite3_filename_journal(f: MarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_filename_journal';
function sqlite3_filename_wal(f: MarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_filename_wal';

// rtree related
function sqlite3_rtree_query_callback(db: Pointer; zQueryFunc: PByte; xQueryFunc: TRTree_xQueryCallback; pContext: Pointer; xDestructor: TxDestroy): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_rtree_query_callback';
function sqlite3_rtree_geometry_callback(db: Pointer; zGeom: MarshaledAString; Callback: TRTree_xGeomCallback; pContext: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX+'sqlite3_rtree_geometry_callback';

// additional functions

function sqlite3_normalize(zSql: MarshaledAString): MarshaledAString; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_normalize';
//  CARRAY
function sqlite3_carray_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_carray_register';
//  CLOSURE
function sqlite3_closure_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_closure_register';
//  CSV
function sqlite3_csv_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_csv_register';
//  UNIONTAB
function sqlite3_unionvtab_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_unionvtab_register';
//   SQLAR
function sqlite3_zipfile_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_zipfile_register';
//  DBDUMP
function sqlite3_db_dump(pDB: Pointer; const zSchema: MarshaledAString; const zTable: MarshaledAString; xCallBack: TxDbDumpCallBack; pArg: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_db_dump';
//   VSV
function sqlite3_vsv_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_vsv_register';
//   SQLAR
function sqlite3_eval_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_eval_register';
//   UNICODE
function sqlite3_unicode_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_unicode_register';
//   ZORDER
//
//   UUID
//
//   base64
function sqlite3_base64_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + {$ifdef win64}'sqlite3_base64_register'{$else}'sqlite3_base64_register'{$endif};// bug in build scripts
////   base64
function sqlite3_base85_register(pDB: Pointer): Integer; cdecl; external name SQLITE_METHOD_PREFIX + 'sqlite3_base85_register';

function sqlite3_try_step(Statement: Pointer; MaxTryCount: Cardinal; WaitTime: Cardinal): Integer; cdecl;
function sqlite3_exec_simple(const ADB: Pointer; const ASQL: string): Integer; cdecl;
function sqlite3_bind_text(Statement: Pointer; Index: Integer; const AValue: UTF8String): Integer; overload; cdecl;
function sqlite3_bind_text(Statement: Pointer; Index: Integer; const AValue: RawByteString): Integer; overload; cdecl;
function sqlite3_bind_text16(Statement: Pointer; Index: Integer; const AValue: string): Integer; overload; cdecl;
function sqlite3_bind_variant(Statement: Pointer; Index: Integer; const Value: Variant): Integer; cdecl;
function sqlite3_expanded_sql_text(pStmt: Pointer): string; cdecl;

procedure sqlite3_result_text(pCtx: PSQLite3FuncContext; const Text: Utf8String); overload;
procedure sqlite3_result_text(pCtx: PSQLite3FuncContext; const Text: string); overload;
procedure sqlite3_result_text16(pCtx: PSQLite3FuncContext; const Text: string); overload;

procedure sqlite3_result_error_str(pCtx: PSQLite3FuncContext; const ErrorString: Utf8String); overload; cdecl;
procedure sqlite3_result_error_str(pCtx: PSQLite3FuncContext; const ErrorString: string); overload; cdecl;


function fts5_api_from_db(pDB: Pointer): PFTS5Api; cdecl;


implementation

uses
  Winapi.Windows, System.Math, System.SysUtils, System.Variants,
  System.ZLib // compress/decompress

{$IFDEF MSWINDOWS}
{$IFDEF WIN64}
  {$HINTS off}
{$ENDIF}
{$IFDEF SQLITE3_USE_CIPHER}
{$IFNDEF SQLITE3_CNG_CIPHER}
{$ifdef SQLITE3_OpenSSL3_CIPHER}
    , libOpenSSL3 // ..\..\externals\libopenssl
{$else}
    , libOpenSSL  // ..\..\externals\libopenssl
{$endif}
{$ENDIF}
{$ENDIF}
    , System.Win.Crtl
  ;

{$if not Declared(msvcrt)}
  const msvcrt = 'msvcrt.dll';
{$ifend}
//{$if CompilerVersion > 35.0}
//{$IFNDEF WIN32}
//  const msvcrt = 'msvcrt.dll';
//{$ENDIF}
//{$ifend}

{$IFDEF SQLITE3_USE_CIPHER}
{$IFNDEF SQLITE3_CNG_CIPHER}
{$IFDEF SQLITE3_OpenSSL3_CIPHER}
procedure InitializeOpenSSL3Static;
begin
  OPENSSL_init_crypto(
    OPENSSL_INIT_NO_ATEXIT or OPENSSL_INIT_ADD_ALL_CIPHERS or OPENSSL_INIT_ADD_ALL_DIGESTS,
    nil);
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF SQLITE3_USE_CIPHER}
{$IFDEF SQLITE3_CNG_CIPHER}
function BCryptGenRandom(hAlgorithm: Pointer; pbBuffer: PByte; cbBuffer: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptGenRandom';
function BCryptOpenAlgorithmProvider(var phAlgorithm: Pointer; pszAlgId: PWideChar; pszImplementation: PWideChar; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptOpenAlgorithmProvider';
function BCryptGetProperty(hObject: Pointer; pszProperty: PWideChar; pbOutput: PByte; cbOutput: Cardinal; var pcbResult: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptGetProperty';
function BCryptCreateHash(hAlgorithm: Pointer; var phHash: Pointer; pbHashObject: PByte; cbHashObject: Cardinal; pbSecret: PByte; cbSecret: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptCreateHash';
function BCryptHashData(hHash: Pointer; pbInput: PByte; cbInput: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptHashData';
function BCryptFinishHash(hHash: Pointer; pbOutput: PByte; cbOutput: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptFinishHash';
function BCryptDestroyHash(hHash: Pointer): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptDestroyHash';
function BCryptCloseAlgorithmProvider(hAlgorithm: Pointer; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptCloseAlgorithmProvider';
function BCryptDeriveKeyPBKDF2(hPrf: Pointer; pbPassword: PByte; cbPassword: Cardinal; pbSalt: PByte; cbSalt: Cardinal; cIterations: UInt64; pbDerivedKey: PByte; cbDerivedKey: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptDeriveKeyPBKDF2';
function BCryptSetProperty(hObject: Pointer; pszProperty: PWideChar; pbInput: PByte; cbInput: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptSetProperty';
function BCryptGenerateSymmetricKey(hAlgorithm: Pointer; var phKey: Pointer; pbKeyObject: PByte; cbKeyObject: Cardinal; pbSecret: PByte; cbSecret: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptGenerateSymmetricKey';
function BCryptEncrypt(hKey: Pointer; pbInput: PByte; cbInput: Cardinal; pPaddingInfo: Pointer; pbIV: PByte; cbIV: Cardinal; pbOutput: PByte; cbOutput: Cardinal; var pcbResult: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptEncrypt';
function BCryptDecrypt(hKey: Pointer; pbInput: PByte; cbInput: Cardinal; pPaddingInfo: Pointer; pbIV: PByte; cbIV: Cardinal; pbOutput: PByte; cbOutput: Cardinal; var pcbResult: Cardinal; dwFlags: Cardinal): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptDecrypt';
function BCryptDestroyKey(hKey: Pointer): LongInt; stdcall; external 'bcrypt.dll' name 'BCryptDestroyKey';
{$ENDIF}
{$ENDIF}

{$IFDEF WIN32}
function _strtoll(strSource: PAnsiChar; endptr: PPAnsiChar; base: Integer): Extended; cdecl;
{$ELSE}
function strtoll(strSource: PAnsiChar; endptr: PPAnsiChar; base: Integer): Extended; cdecl;
{$ENDIF}
var s: string;
    err: Integer;
begin
  s := TMarshal.ReadStringAsAnsi(TPtrWrapper.Create(strSource)).Replace(FormatSettings.DecimalSeparator,FormatSettings.Invariant.DecimalSeparator,[]);
  Val(s,Result,err);
  if (err <> 0) then
  begin
    Result := 0;
    if Assigned(endptr) then
    begin
      inc(strSource,err);
      Move(strSource^, endptr^^, 1);
    end
  end;
end;
{$IFDEF WIN32}
function _modfl(x: Extended; intptr: PExtended): Extended; cdecl;
{$ELSE}
function modfl(x: Extended; intptr: PExtended): Extended; cdecl;
{$ENDIF}
begin
  Result := Frac(x);
  if Assigned(intptr) then
    intptr^ := Int(x);
end;

{$IFDEF WIN32}
function _strtod(strSource: PAnsiChar; endptr: PPAnsiChar): double; cdecl;
{$ELSE}
function strtod(strSource: PAnsiChar; endptr: PPAnsiChar): double; cdecl;
{$ENDIF}
var s: string;
    err: Integer;
begin
  s := TMarshal.ReadStringAsAnsi(TPtrWrapper.Create(strSource)).Replace(FormatSettings.DecimalSeparator,FormatSettings.Invariant.DecimalSeparator,[]);
  Val(s,Result,err);
  if (err <> 0) then
  begin
    Result := 0;
    if Assigned(endptr) then
    begin
      inc(strSource,err);
      Move(strSource^, endptr^^, 1);
    end
  end;
end;

// function strtod(s,endptr:pansichar):double; cdecl;
// var t:ansistring;
//     i:longint;
// begin
//  t:=s;
//  if assigned(endptr) then
//   SetLength(t,endptr-s);
//  result:=0.0;
//  val(t,result,i);
// end;

// function _copysign(x,y:double):double; cdecl;
// begin
//  result:=abs(x)*sign(y);
// end;

// function scalbn(x:double;e:longint):double; cdecl;
// const FLT_RADIX=2;
// begin
//  result:=power(x*FLT_RADIX,e);
// end;

// function strtoll(str,endptr:pansichar;base:longint):int64; cdecl;
// var s:longint;
// begin
//  result:=0;
//  s:=1;
//  while (str^<>#0) and (ptruint(str)<ptruint(endptr)) do begin
//   case str^ of
//    '-':begin
//     s:=-s;
//    end;
//    '+':begin
//    end;
//    '0'..'9':begin
//     result:=(result*base)+(byte(ansichar(str^))-byte(ansichar('0')));
//    end;
//    'a'..'z':begin
//     result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('a')))+$a);
//    end;
//    'A'..'Z':begin
//     result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('A')))+$a);
//    end;
//   end;
//   inc(str^);
//  end;
// end;
//
// function strtoull(str,endptr:pansichar;base:longint):qword; cdecl;
// var s:longint;
// begin
//  result:=0;
//  s:=1;
//  while (str^<>#0) and (ptruint(str)<ptruint(endptr)) do begin
//   case str^ of
//    '-':begin
//     s:=-s;
//    end;
//    '+':begin
//    end;
//    '0'..'9':begin
//     result:=(result*base)+(byte(ansichar(str^))-byte(ansichar('0')));
//    end;
//    'a'..'z':begin
//     result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('a')))+$a);
//    end;
//    'A'..'Z':begin
//     result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('A')))+$a);
//    end;
//   end;
//   inc(str^);
//  end;
// end;

{$IFDEF WIN32}
function _strtold(strSource: PAnsiChar; endptr: PPAnsiChar): Extended; cdecl;
{$ELSE}
function strtold(strSource: PAnsiChar; endptr: PPAnsiChar): Extended; cdecl;
{$ENDIF}
var s: string;
    err: Integer;
begin
  s := TMarshal.ReadStringAsAnsi(TPtrWrapper.Create(strSource)).Replace(FormatSettings.DecimalSeparator,FormatSettings.Invariant.DecimalSeparator,[]);
  Val(s,Result,err);
  if (err <> 0) then
  begin
    Result := 0;
    if Assigned(endptr) then
    begin
      inc(strSource,err);
      Move(strSource^, endptr^^, 1);
    end
  end;
end;

{$IFDEF WIN32}
function ___get_std_stream(num: Cardinal): Pointer; cdecl;
{$ELSE}
function __get_std_stream(num: Cardinal): Pointer; cdecl;
{$ENDIF}
begin
  Result := Pointer(GetStdHandle(num));
end;

//
{$IFDEF WIN32}
function _strspn(const s: PAnsiChar; const Chars: PAnsiChar): NativeUInt; cdecl;
{$ELSE}
function strspn(const s: PAnsiChar; const Chars: PAnsiChar): NativeUint; cdecl;
{$ENDIF}
label 1;
var
  c: AnsiChar;
  p, cs: PAnsiChar;
begin
  p := s;
  1: c := p^; Inc(p);
  cs := Chars;
  while cs^ <> #0 do
  begin
    if c = cs^ then
      goto 1;
    Inc(cs);
  end;
  Result := p - s - 1;
end;

  {$REGION 'win64'}
{$IFDEF WIN64}
{$IFDEF SQLITE3_USE_CIPHER}
{$IFNDEF SQLITE3_CNG_CIPHER}
// openssl
procedure HMAC_CTX_init(Ctx: HMAC_CTX_ptr); cdecl;
// since 1.1.0 HMAC_CTX_init() was replaced with HMAC_CTX_reset().
begin
  HMAC_CTX_reset(Ctx);
end;

procedure HMAC_CTX_cleanup(Ctx: HMAC_CTX_ptr); cdecl;
// since 1.0.2h HMAC_CTX_cleanup() were removed. HMAC_CTX_reset should be called instead to reinitialise an already created structure.
begin
  HMAC_CTX_reset(Ctx);
end;

procedure OPENSSL_add_all_algorithms_noconf; cdecl;// Macro from evp.h
begin
  OPENSSL_init_crypto(OPENSSL_INIT_NO_ATEXIT or OPENSSL_INIT_ADD_ALL_CIPHERS or OPENSSL_INIT_ADD_ALL_DIGESTS, nil);
end;
{$ENDIF}
{$ENDIF}

// crtl
function atoi(const Str: PAnsiChar): Integer; cdecl; external msvcrt name 'atoi';
function fopen(filename, mode: PAnsiChar): Pointer; cdecl; external msvcrt name 'fopen';
function fopen_s(var pfile: Pointer; filename, mode: PAnsiChar): Pointer; cdecl; external msvcrt name 'fopen_s';
function fclose(stream: Pointer): Integer; cdecl; external msvcrt name 'fclose';
function fread(Ptr: Pointer; Size, nelem: NativeUInt; stream: Pointer): NativeUInt; cdecl; external msvcrt name 'fread';
function fputc(c: Integer; stream: Pointer): Longint; cdecl; external msvcrt name 'fputc';
function ftell(stream: Pointer): Longint; cdecl; external msvcrt name 'ftell';
function fseek(stream: Pointer; offset: Longint; mode: Integer): Integer; cdecl; external msvcrt name 'fseek';
function fwrite(Ptr: Pointer; Size, nelem: NativeUInt; stream: Pointer): NativeUInt; cdecl; external msvcrt name 'fwrite';
function puts(const s: PAnsiChar): Integer; cdecl; external msvcrt name 'puts';
function _Log(x: Double): Double; cdecl; external msvcrt name 'log';
function strftime(strdest: PAnsiChar; maxsize: size_t; format: PAnsiChar; tm: PSystemTime): size_t; cdecl; external msvcrt name 'strftime';
function vfprintf(stream: Pointer; format: PAnsiChar; param: va_list): Integer; cdecl; external msvcrt name 'vfprintf';
function localtime_s(lpSystemTime: TSystemTime; sourceTime: Int64): Integer; cdecl; external msvcrt name '_localtime64_s';
function atexit(func: Pointer): Integer; cdecl; external msvcrt name 'atexit';
function fputws(ws: PWideChar; stream: Pointer): Integer; cdecl; external msvcrt name 'fputws';
function fdopen(fd: Integer; mode: PAnsiChar): Pointer; cdecl; external msvcrt name '_fdopen';
function _wopen(path: PWideChar; oflag: Integer): Integer; cdecl; external msvcrt name '_wopen';
{ Dinkumware locale-aware char conversion (tolower/toupper expand to these in bcc64) }
function _ltolower(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('A')) and (c <= Ord('Z')) then Result := c or $20 else Result := c;
end;
function _ltoupper(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('a')) and (c <= Ord('z')) then Result := c and (not $20) else Result := c;
end;
function _ltowlower(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('A')) and (c <= Ord('Z')) then Result := c or $20 else Result := c;
end;
function _ltowupper(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('a')) and (c <= Ord('z')) then Result := c and (not $20) else Result := c;
end;
procedure __chkstk;
asm
end;

function _FInf: Double; cdecl;
begin
  result := Infinity;
  // 1e308*1e308
end;

{ zlib }
function inflateInit2_(var strm: z_stream; windowBits: Integer; version: MarshaledAString; stream_size: Integer): Integer; cdecl;
begin
  result := System.ZLib.inflateInit2_(strm, windowBits, version, stream_size);
end;

function inflate(var strm: z_stream; flush: Integer): Integer; cdecl;
begin
  result := System.ZLib.inflate(strm, flush);
end;

function inflateEnd(var strm: z_stream): Integer; cdecl;
begin
  result := System.ZLib.inflateEnd(strm);
end;

function compressBound(sourceLen: LongWord): LongWord; cdecl;
begin
  result := System.ZLib.compressBound(sourceLen);
end;

function deflateInit2_(var strm: z_stream; level, method, windowBits, memLevel, strategy: Integer; version: MarshaledAString; stream_size: Integer): Integer; cdecl;
begin
  result := System.ZLib.deflateInit2_(strm, level, method, windowBits, memLevel, strategy, version, stream_size);
end;

function deflate(var strm: z_stream; flush: Integer): Integer; cdecl;
begin
  result := System.ZLib.deflate(strm, flush);
end;

function deflateBound(var strm: z_stream; sourceLen: Cardinal): LongWord; cdecl;
begin
  result := System.ZLib.deflateBound(strm, sourceLen);
end;

function deflateEnd(var strm: z_stream): Integer; cdecl;
begin
  result := System.ZLib.deflateEnd(strm);
end;

function crc32(crc: LongWord; Buf: PByte; Len: Cardinal): LongWord; cdecl;
begin
  result := System.ZLib.crc32(crc, Buf, Len);
end;

function compress(dest: PByte; var destLen: LongWord; source: PByte; sourceLen: LongWord): Integer; cdecl;
begin
  result := System.ZLib.compress(dest, destLen, source, sourceLen);
end;

function uncompress(dest: PByte; var destLen: LongWord; source: PByte; sourceLen: LongWord): Integer; cdecl;
begin
  result := System.ZLib.uncompress(dest, destLen, source, sourceLen);
end;

  {$ENDREGION 'win64'}

  {$ELSE}

  {$REGION 'win32'}

{ openssl }
{$IFDEF SQLITE3_USE_CIPHER}
{$IFNDEF SQLITE3_CNG_CIPHER}
function _EVP_aes_256_cbc: EVP_CIPHER_ptr; cdecl;
begin
  result := EVP_aes_256_cbc();
end;

procedure _HMAC_CTX_init(Ctx: HMAC_CTX_ptr); cdecl;
// since 1.1.0 HMAC_CTX_init() was replaced with HMAC_CTX_reset().
begin
  HMAC_CTX_reset(Ctx);
end;

procedure _HMAC_CTX_cleanup(Ctx: HMAC_CTX_ptr); cdecl;
// since 1.0.2h HMAC_CTX_cleanup() were removed. HMAC_CTX_reset should be called instead to reinitialise an already created structure.
begin
  HMAC_CTX_reset(Ctx);
end;

procedure _OPENSSL_add_all_algorithms_noconf; cdecl; // Macro from evp.h
begin
  OPENSSL_init_crypto(OPENSSL_INIT_NO_ATEXIT or OPENSSL_INIT_ADD_ALL_CIPHERS or OPENSSL_INIT_ADD_ALL_DIGESTS, nil);
end;

function _CRYPTO_malloc(Num: NativeUint; const File_: PAnsiChar; Line: Integer): Pointer; cdecl;
begin
  result := CRYPTO_malloc(Num, File_, Line);
end;

procedure _CRYPTO_free(Ptr: Pointer; const File_: PAnsiChar; Line: Integer); cdecl;
begin
  CRYPTO_free(Ptr, File_, Line);
end;

procedure _RAND_add(const Buf: Pointer; Num: Integer; randomness: Double); cdecl;
begin
  RAND_add(Buf, Num, randomness);
end;

function _EVP_get_cipherbyname(const Name: PAnsiChar): EVP_CIPHER_ptr; cdecl;
begin
  result := EVP_get_cipherbyname(Name);
end;

procedure _EVP_cleanup; cdecl;
begin
  // EVP_cleanup is a no-op in OpenSSL 1.1+; SQLCipher still references it.
end;

function _RAND_bytes(Buf: PAnsiChar; Num: Integer): Integer; cdecl;
begin
  result := RAND_bytes(PByte(Buf), Num);
end;

function _HMAC_Init_ex(Ctx: HMAC_CTX_ptr; const Key: Pointer; Len: Integer; const md: EVP_MD_ptr; impl: ENGINE_ptr): Integer; cdecl;
begin
  result := HMAC_Init_ex(Ctx, Key, Len, md, impl);
end;

function _EVP_sha1: EVP_MD_ptr; cdecl;
begin
  result := EVP_sha1;
end;

function _EVP_sha256: EVP_MD_ptr; cdecl;
begin
  result := EVP_sha256;
end;

function _EVP_sha512: EVP_MD_ptr; cdecl;
begin
  result := EVP_sha512;
end;

function _HMAC_Update(Ctx: HMAC_CTX_ptr; const Data: PAnsiChar; Len: NativeUint): Integer; cdecl;
begin
  result := HMAC_Update(Ctx, PByte(Data), Len);
end;

function _HMAC_Final(Ctx: HMAC_CTX_ptr; md: PAnsiChar; Len: PCardinal): Integer; cdecl;
begin
  result := HMAC_Final(Ctx, PByte(md), Len);
end;

function _PKCS5_PBKDF2_HMAC(const pass: PAnsiChar; passlen: Integer; const Salt: PAnsiChar; SaltLen: Integer; Iter: Integer; const digest: EVP_MD_ptr; keylen: Integer; Out_: PAnsiChar): Integer; cdecl;
begin
  result := PKCS5_PBKDF2_HMAC(pass, passlen, PByte(Salt), SaltLen, Iter, digest, keylen, PByte(Out_));
end;

function _EVP_CIPHER_CTX_new: EVP_CIPHER_CTX_ptr; cdecl;
begin
  result := EVP_CIPHER_CTX_new;
end;

function _EVP_CipherInit_ex(Ctx: EVP_CIPHER_CTX_ptr; const cipher: EVP_CIPHER_ptr; impl: ENGINE_ptr; const Key: PAnsiChar; const iv: PAnsiChar; Enc: Integer): Integer; cdecl;
begin
  result := EVP_CipherInit_ex(Ctx, cipher, impl, PByte(Key), PByte(iv), Enc);
end;

function _EVP_CipherUpdate(Ctx: EVP_CIPHER_CTX_ptr; Out_: Pointer; outl: PInteger; const In_: Pointer; inl: Integer): Integer; cdecl;
begin
  result := EVP_CipherUpdate(Ctx, PByte(Out_), outl, PByte(In_), inl);
end;

function _EVP_CIPHER_CTX_set_padding(C: EVP_CIPHER_CTX_ptr; pad: Integer): Integer; cdecl;
begin
  result := EVP_CIPHER_CTX_set_padding(C, pad);
end;

function _EVP_CipherFinal_ex(Ctx: EVP_CIPHER_CTX_ptr; outm: Pointer; outl: PInteger): Integer; cdecl;
begin
  result := EVP_CipherFinal_ex(Ctx, PByte(outm), outl);
end;

procedure _EVP_CIPHER_CTX_free(C: EVP_CIPHER_CTX_ptr); cdecl;
begin
  EVP_CIPHER_CTX_free(C);
end;

function _OBJ_nid2sn(N: Integer): PAnsiChar; cdecl;
begin
  result := OBJ_nid2sn(N);
end;

function _EVP_CIPHER_nid(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_get_nid(cipher);
end;

function _EVP_CIPHER_get_nid(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_get_nid(cipher);
end;

function _EVP_CIPHER_key_length(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_key_length(cipher);
end;

function _EVP_CIPHER_get_key_length(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_get_key_length(cipher);
end;

function _EVP_CIPHER_iv_length(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_iv_length(cipher);
end;

function _EVP_CIPHER_get_iv_length(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_get_iv_length(cipher);
end;

function _EVP_CIPHER_block_size(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_block_size(cipher);
end;

function _EVP_CIPHER_get_block_size(const cipher: EVP_CIPHER_ptr): Integer; cdecl;
begin
  result := EVP_CIPHER_get_block_size(cipher);
end;

function _EVP_MD_size(const md: EVP_MD_ptr): Integer; cdecl;
begin
  result := EVP_MD_size(md);
end;

function _EVP_MD_get_size(const md: EVP_MD_ptr): Integer; cdecl;
begin
  result := EVP_MD_get_size(md);
end;

function _EVP_MAC_fetch(libctx: OSSL_LIB_CTX_ptr; algorithm: PAnsiChar; properties: PAnsiChar): EVP_MAC_ptr; cdecl;
begin
  result := EVP_MAC_fetch(libctx, algorithm, properties);
end;

function _EVP_MAC_CTX_new(mac: EVP_MAC_ptr): EVP_MAC_CTX_ptr; cdecl;
begin
  result := EVP_MAC_CTX_new(mac);
end;

function _EVP_MAC_init(ctx: EVP_MAC_CTX_ptr; key: PByte; keylen: NativeUInt; params: Pointer): Integer; cdecl;
begin
  result := EVP_MAC_init(ctx, key, keylen, params);
end;

function _EVP_MAC_update(ctx: EVP_MAC_CTX_ptr; data: PByte; datalen: NativeUInt): Integer; cdecl;
begin
  result := EVP_MAC_update(ctx, data, datalen);
end;

function _EVP_MAC_final(ctx: EVP_MAC_CTX_ptr; out_: PByte; outl: PNativeUInt; outsize: NativeUInt): Integer; cdecl;
begin
  result := EVP_MAC_final(ctx, out_, outl, outsize);
end;

procedure _EVP_MAC_CTX_free(ctx: EVP_MAC_CTX_ptr); cdecl;
begin
  EVP_MAC_CTX_free(ctx);
end;

procedure _EVP_MAC_free(mac: EVP_MAC_ptr); cdecl;
begin
  EVP_MAC_free(mac);
end;

function _ERR_get_error: Cardinal; cdecl;
begin
  Result := ERR_get_error;
end;

function _ERR_error_string(e: Cardinal; Buf: PAnsiChar): PAnsiChar; cdecl;
begin
  Result := ERR_error_string(e,Buf);
end;

procedure _ERR_load_CRYPTO_strings; cdecl;
begin
  ERR_load_CRYPTO_strings;
end;

function _OPENSSL_sk_num(const st: OPENSSL_STACK_ptr): Integer; cdecl;
begin
  Result := OPENSSL_sk_num(st);
end;

function _OPENSSL_sk_value(const n: OPENSSL_STACK_ptr; i: Integer): Pointer; cdecl;
begin
  Result := OPENSSL_sk_value(n,i);
end;

function _OPENSSL_sk_set(st: OPENSSL_STACK_ptr; i: Integer; const Data: Pointer): Pointer; cdecl;
begin
  Result := OPENSSL_sk_set(st, i, Data);
end;

function _OPENSSL_sk_new(cmp: OPENSSL_sk_compfunc): OPENSSL_STACK_ptr; cdecl;
begin
  Result := OPENSSL_sk_new(cmp);
end;

function _OPENSSL_sk_new_null: OPENSSL_STACK_ptr; cdecl;
begin
  Result := OPENSSL_sk_new_null;
end;

function _OPENSSL_sk_new_reserve(c: OPENSSL_sk_compfunc; n: Integer): OPENSSL_STACK_ptr; cdecl;
begin
  Result := OPENSSL_sk_new_reserve(c,n);
end;

function _OPENSSL_sk_reserve(sk: OPENSSL_STACK_ptr; n: Integer): Integer; cdecl;
begin
  Result := OPENSSL_sk_reserve(sk, n);
end;

procedure _OPENSSL_sk_free(st: OPENSSL_STACK_ptr); cdecl;
begin
  if st <> nil then OPENSSL_sk_free(st);
end;

procedure _OPENSSL_sk_pop_free(st: OPENSSL_STACK_ptr; Func: OPENSSL_sk_freefunc); cdecl;
begin
  OPENSSL_sk_pop_free(st, Func);
end;

function _OPENSSL_sk_deep_copy(const sk: OPENSSL_STACK_ptr; c: OPENSSL_sk_copyfunc; f: OPENSSL_sk_freefunc): OPENSSL_STACK_ptr;cdecl;
begin
  Result := OPENSSL_sk_deep_copy(sk,c,f);
end;

function _OPENSSL_sk_insert(sk: OPENSSL_STACK_ptr; const Data: Pointer; where: Integer): Integer; cdecl;
begin
  Result := OPENSSL_sk_insert(sk,Data,where);
end;

function _OPENSSL_sk_delete(st: OPENSSL_STACK_ptr; loc: Integer): Pointer; cdecl;
begin
  Result := OPENSSL_sk_delete(st, loc);
end;

function _OPENSSL_sk_delete_ptr(st: OPENSSL_STACK_ptr; const p: Pointer): Pointer; cdecl;
begin
  Result := OPENSSL_sk_delete_ptr(st, p);
end;

function _OPENSSL_sk_find(st: OPENSSL_STACK_ptr; const Data: Pointer): Integer; cdecl;
begin
  Result := OPENSSL_sk_find(st, Data);
end;

function _OPENSSL_sk_find_ex(st: OPENSSL_STACK_ptr; const Data: Pointer): Integer; cdecl;
begin
  Result := OPENSSL_sk_find_ex(st, Data);
end;

function _OPENSSL_sk_push(st: OPENSSL_STACK_ptr; const Data: Pointer): Integer; cdecl;
begin
  Result := OPENSSL_sk_push(st, Data);
end;

function _OPENSSL_sk_unshift(st: OPENSSL_STACK_ptr; const Data: Pointer): Integer; cdecl;
begin
  Result := OPENSSL_sk_unshift(st, data);
end;

function _OPENSSL_sk_shift(st: OPENSSL_STACK_ptr): Pointer; cdecl;
begin
  Result := OPENSSL_sk_shift(st);
end;

function _OPENSSL_sk_pop(st: OPENSSL_STACK_ptr): Pointer; cdecl;
begin
  Result := OPENSSL_sk_pop(st);
end;

procedure _OPENSSL_sk_zero(st: OPENSSL_STACK_ptr); cdecl;
begin
  OPENSSL_sk_zero(st);
end;

function _OPENSSL_sk_set_cmp_func(st: OPENSSL_STACK_ptr; cmp: OPENSSL_sk_compfunc): OPENSSL_sk_compfunc; cdecl;
begin
  Result := OPENSSL_sk_set_cmp_func(st,cmp);
end;

function _OPENSSL_sk_dup(const st: OPENSSL_STACK_ptr): OPENSSL_STACK_ptr; cdecl;
begin
  Result := OPENSSL_sk_dup(st);
end;

procedure _OPENSSL_sk_sort(st: OPENSSL_STACK_ptr); cdecl;
begin
  OPENSSL_sk_sort(st);
end;

function _OPENSSL_sk_is_sorted(const st: OPENSSL_STACK_ptr): Integer; cdecl;
begin
  Result := OPENSSL_sk_is_sorted(st);
end;

function _OPENSSL_LH_new(h: OPENSSL_LH_HASHFUNC; c: OPENSSL_LH_COMPFUNC): OPENSSL_LHASH_ptr; cdecl;
begin
  Result := OPENSSL_LH_new(h, c);
end;

procedure _OPENSSL_LH_free(lh: OPENSSL_LHASH_ptr); cdecl;
begin
 if lh <> nil then OPENSSL_LH_free(lh);
end;

function _OPENSSL_LH_insert(lh: OPENSSL_LHASH_ptr; Data: Pointer): Pointer; cdecl;
begin
  Result := OPENSSL_LH_insert(lh, Data);
end;

function _OPENSSL_LH_delete(lh: OPENSSL_LHASH_ptr; const Data: Pointer): Pointer; cdecl;
begin
  Result := OPENSSL_LH_delete(lh, Data);
end;

function _OPENSSL_LH_retrieve(lh: OPENSSL_LHASH_ptr; const Data: Pointer): Pointer; cdecl;
begin
  Result := OPENSSL_LH_retrieve(lh, Data);
end;

function _OPENSSL_LH_error(lh: OPENSSL_LHASH_ptr): Integer; cdecl;
begin
  Result := OPENSSL_LH_error(lh);
end;

function _OPENSSL_LH_num_items(const lh: OPENSSL_LHASH_ptr): Cardinal; cdecl;
begin
  Result := OPENSSL_LH_num_items(lh);
end;

procedure _OPENSSL_LH_stats_bio(const lh: OPENSSL_LHASH_ptr; Out_: BIO_ptr); cdecl;
begin
  OPENSSL_LH_stats_bio(lh, Out_);
end;

procedure _OPENSSL_LH_node_stats_bio(const lh: OPENSSL_LHASH_ptr; Out_: BIO_ptr); cdecl;
begin
  OPENSSL_LH_node_stats_bio(lh, Out_);
end;

procedure _OPENSSL_LH_node_usage_stats_bio(const lh: OPENSSL_LHASH_ptr; Out_: BIO_ptr); cdecl;
begin
  OPENSSL_LH_node_usage_stats_bio(lh, Out_);
end;

function _OPENSSL_LH_get_down_load(const lh: OPENSSL_LHASH_ptr): Cardinal; cdecl;
begin
  Result := OPENSSL_LH_get_down_load(lh);
end;

procedure _OPENSSL_LH_set_down_load(lh: OPENSSL_LHASH_ptr; down_load: Cardinal); cdecl;
begin
  OPENSSL_LH_set_down_load(lh, down_load);
end;

procedure _OPENSSL_LH_doall(lh: OPENSSL_LHASH_ptr; Func: OPENSSL_LH_DOALL_FUNC); cdecl;
begin
  OPENSSL_LH_doall(lh, Func);
end;

function _HMAC_CTX_new: HMAC_CTX_ptr; cdecl;
begin
  Result := HMAC_CTX_new();
end;

procedure _HMAC_CTX_free(Ctx: HMAC_CTX_ptr); cdecl;
begin
  if Assigned(Ctx) then
    HMAC_CTX_free(Ctx);
end;

function _OpenSSL_version(Type_: Integer): PAnsiChar; cdecl;
begin
  Result := OpenSSL_version(Type_);
end;

{$ENDIF} // SQLITE3_CNG_CIPHER
{$ENDIF} // SQLITE3_USE_CIPHER
{ crtl }
procedure __lldiv;
asm
  jmp System.@_lldiv
end;

procedure __llmod;
asm
  jmp System.@_llmod
end;

procedure __llmul;
asm
  jmp System.@_llmul
end;

procedure __lludiv;
asm
  jmp System.@_lludiv
end;

procedure __llumod;
asm
  jmp System.@_llumod
end;

procedure __llshl;
asm
  jmp System.@_llshl
end;

procedure __llushr;
asm
  jmp System.@_llushr
end;

procedure __llshr;
// asm
// shrd    eax, edx, cl
// sar     edx, cl
// cmp     cl, 32
// jl      @@Done
// cmp     cl, 64
// jge     @@RetSign
// mov     eax, edx
// sar     edx, 31
// ret
// @@RetSign:
// sar     edx, 31
// mov     eax, edx
// @@Done:
// end;
asm
  AND   CL, $3F
  CMP   CL, 32
  JL    @__llshr@below32
  MOV   EAX, EDX
  CDQ
  SAR   EAX,CL
  RET

@__llshr@below32:
  SHRD  EAX, EDX, CL
  SAR   EDX, CL
  RET
end;

const
  __streams: array [0 .. 2] of NativeInt = (0, 1, 2);

function _atoi(const Str: PAnsiChar): Integer; cdecl; external msvcrt name 'atoi';
function _fabs(const x: double): Double; cdecl; external msvcrt name 'fabs';
function _fopen(filename, mode: PAnsiChar): Pointer; cdecl; external msvcrt name 'fopen';
function _fopen_s(var pfile: Pointer; filename, mode: PAnsiChar): Pointer; cdecl; external msvcrt name 'fopen_s';
function _fclose(stream: Pointer): Integer; cdecl; external msvcrt name 'fclose';
function _fread(Ptr: Pointer; Size, nelem: size_t; stream: Pointer): size_t; cdecl; external msvcrt name 'fread';
function _ftell(stream: Pointer): Longint; cdecl; external msvcrt name 'ftell';
function _fseek(stream: Pointer; offset: Longint; mode: Integer): Integer; cdecl; external msvcrt name 'fseek';
function _fwrite(Ptr: Pointer; Size, nelem: size_t; stream: Pointer): size_t; cdecl; external msvcrt name 'fwrite';
function _localtime(const tod: ptime_t): ptm; cdecl; external msvcrt name 'localtime';
function _Log(x: Double): Double; cdecl; external msvcrt name 'log';
function _localtime_s(lpSystemTime: TSystemTime; sourceTime: time_t): Integer; cdecl; external msvcrt name '_localtime32_s';
function _strftime(strdest: PAnsiChar; maxsize: size_t; format: PAnsiChar; tm: PSystemTime): size_t; cdecl; external msvcrt name 'strftime';
function _vfprintf(stream: Pointer; format: PAnsiChar; param: va_list): Integer; cdecl; external msvcrt name 'vfprintf';
function _strrchr(__s: PAnsiChar; __c: Integer): PAnsiChar; cdecl; external msvcrt name 'strrchr';

function _atexit(func: Pointer): Integer; cdecl; external msvcrt name 'atexit';
function _fputws(ws: PWideChar; stream: Pointer): Integer; cdecl; external msvcrt name 'fputws';
function _fdopen(fd: Integer; mode: PAnsiChar): Pointer; cdecl; external msvcrt name '_fdopen';
function __wopen(path: PWideChar; oflag: Integer): Integer; cdecl; external msvcrt name '_wopen';
{ Dinkumware locale-aware char conversion: bcc32 mangles _ltolower -> __ltolower }
function __ltolower(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('A')) and (c <= Ord('Z')) then Result := c or $20 else Result := c;
end;
function __ltoupper(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('a')) and (c <= Ord('z')) then Result := c and (not $20) else Result := c;
end;
function __ltowlower(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('A')) and (c <= Ord('Z')) then Result := c or $20 else Result := c;
end;
function __ltowupper(c: Integer): Integer; cdecl;
begin
  if (c >= Ord('a')) and (c <= Ord('z')) then Result := c and (not $20) else Result := c;
end;

// function _beginthreadex(security: pointer; stksize: cardinal; start,arg: pointer; flags: cardinal; var threadid: cardinal): THandle; cdecl; external msvcrt name '_beginthreadex';
function __beginthreadex(security: Pointer; stksize: Cardinal; start, arg: Pointer; flags: Cardinal; var threadid: Cardinal): THandle; cdecl;
begin
  result := BeginThread(security, stksize, start, arg, flags, threadid);
end;

// procedure _endthreadex(exitcode: cardinal); cdecl; external msvcrt name '_endthreadex';
procedure __endthreadex(ExitCode: Cardinal); cdecl;
begin
  EndThread(ExitCode);
end;

function _strchr(__s: PAnsiChar; __c: Integer): PAnsiChar; cdecl;
begin
  result := strchr(__s, __c);
end;

function strrchr(__s: PAnsiChar; __c: Integer): PAnsiChar; cdecl;
begin
  result := _strrchr(__s, __c);
end;

procedure _qsort(baseP: PByte; nelem, Width: size_t; comparF: qsort_compare_func); cdecl;
begin
  qsort(baseP, nelem, Width, comparF);
end;

function ___ieee_32_p_inf: Double; cdecl; //
begin

  result := Infinity;
  // 1e308*1e308
end;

{ zlib }
function _inflateInit2_(var strm: z_stream; windowBits: Integer; version: MarshaledAString; stream_size: Integer): Integer; cdecl;
begin
  result := System.ZLib.inflateInit2_(strm, windowBits, version, stream_size);
end;

function _inflate(var strm: z_stream; flush: Integer): Integer; cdecl;
begin
  result := System.ZLib.inflate(strm, flush);
end;

function _inflateEnd(var strm: z_stream): Integer; cdecl;
begin
  result := System.ZLib.inflateEnd(strm);
end;

function _compressBound(sourceLen: LongWord): LongWord; cdecl;
begin
  result := System.ZLib.compressBound(sourceLen);
end;

function _deflateInit2_(var strm: z_stream; level, method, windowBits, memLevel, strategy: Integer; version: MarshaledAString; stream_size: Integer): Integer; cdecl;
begin
  result := System.ZLib.deflateInit2_(strm, level, method, windowBits, memLevel, strategy, version, stream_size);
end;

function _deflate(var strm: z_stream; flush: Integer): Integer; cdecl;
begin
  result := System.ZLib.deflate(strm, flush);
end;

function _deflateBound(var strm: z_stream; sourceLen: Cardinal): LongWord; cdecl;
begin
  result := System.ZLib.deflateBound(strm, sourceLen);
end;

function _deflateEnd(var strm: z_stream): Integer; cdecl;
begin
  result := System.ZLib.deflateEnd(strm);
end;

function _crc32(crc: LongWord; Buf: PByte; Len: Cardinal): LongWord; cdecl;
begin
  result := System.ZLib.crc32(crc, Buf, Len);
end;

function _compress(dest: PByte; var destLen: LongWord; source: PByte; sourceLen: LongWord): Integer; cdecl;
begin
  result := System.ZLib.compress(dest, destLen, source, sourceLen);
end;

function _uncompress(dest: PByte; var destLen: LongWord; source: PByte; sourceLen: LongWord): Integer; cdecl;
begin
  result := System.ZLib.uncompress(dest, destLen, source, sourceLen);
end;
{$ENDIF}
  {$ENDREGION 'win32'}

 {$IFDEF WIN64} // CPU64BITS / CPUX64
  {$IFDEF SQLITE3_FULL_DEBUG}
    {$L sqlite3_win64d.obj}
  {$ELSE}
    {$IFDEF SQLITE3_CNG_CIPHER}
      {$L sqlite3_win64_cng.obj}
    {$ELSE}
      {$IFDEF SQLITE3_OpenSSL3_CIPHER}
        {$L sqlite3_win64_ossl.obj}
      {$ELSE}
        {$MESSAGE FATAL 'No SQLCipher static object profile selected for Win64'}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
  {$ELSE}               // CPU32BITS / CPUX86
  {$IFDEF SQLITE3_FULL_DEBUG}
   {$L sqlite3_win32d.obj}
  {$ELSE}
    {$IFDEF SQLITE3_CNG_CIPHER}
      {$L sqlite3_win32_cng.obj}
    {$ELSE}
      {$IFDEF SQLITE3_OpenSSL3_CIPHER}
        {$L sqlite3_win32_ossl.obj}
      {$ELSE}
        {$MESSAGE FATAL 'No SQLCipher static object profile selected for Win32'}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
  {$ENDIF}

{$ENDIF} // MSWINDOWS

procedure sqlite3_destroy_mem(p: Pointer); cdecl;
begin
  if p <> nil then
  begin
    FreeMem(p);
  end;
end;


//function StrEndA(const s: PAnsiChar): PAnsiChar;
//label
//  0, 1, 2, 3;
//begin
//  Result := s;
//  if Assigned(Result) then
//  begin
//    repeat
//      if Result[0] = #0 then
//        goto 0;
//      if Result[1] = #0 then
//        goto 1;
//      if Result[2] = #0 then
//        goto 2;
//      if Result[3] = #0 then
//        goto 3;
//      Inc(Result, 4);
//    until False;
//
//  3:
//    Inc(Result);
//  2:
//    Inc(Result);
//  1:
//    Inc(Result);
//  0:
//  end;
//end;
//
//function StrLenA(const s: PAnsiChar): NativeUInt;
//begin
//  Result := StrEndA(s) - s;
//end;

function sqlite3_try_step(Statement: Pointer; MaxTryCount: Cardinal; WaitTime: Cardinal): Integer;
var
  i: Cardinal;
begin
  if Statement = nil then
    Exit(SQLITE_MISUSE);

  if MaxTryCount < 1 then
    MaxTryCount := 8;

  if WaitTime < 1 then
    WaitTime := 10;

  i := MaxTryCount;

  repeat
    Result := sqlite3_step(Statement);
    case Result and $FF of
      SQLITE_OK, SQLITE_ROW, SQLITE_DONE: Exit;
      SQLITE_BUSY, SQLITE_LOCKED: Sleep(WaitTime);
    else
      Break;
    end;

    Dec(i);

  until i = 0;
end;

function sqlite3_exec_simple(const ADB: Pointer; const ASQL: string): Integer;
var
  err: Integer;
  Stmt: Pointer;
  Tail: MarshaledString;
begin
  if not Assigned(ADB) or (ASQL = '') then
    Exit(SQLITE_MISUSE);

  Tail := nil;
  Result := sqlite3_prepare16_v2(ADB, Pointer(ASQL), (Length(ASQL) + 1) * SizeOf(WideChar), Stmt, @Tail);

  if Result = SQLITE_OK then
  begin
    Result := sqlite3_try_step(Stmt, 8, 10);

    case Result and $FF of
      SQLITE_ROW, SQLITE_DONE: Result := SQLITE_OK;
    end;

    err := sqlite3_finalize(Stmt);
    if  err <> SQLITE_OK then
      Result :=  err;
  end;
end;

function sqlite3_value_str(Value: PSQLiteValue): RawByteString;
var
  v: pointer;
  l: Integer;
begin
  v := sqlite3_value_blob(value);
  l := sqlite3_value_bytes(value);

  if (v <> nil) and (l > 0) then
  begin
    SetLength(result, l);
    Move(v^,result[1],l);
    Exit;
  end;

  result := '';
end;

function sqlite3_value_str16(Value: PSQLiteValue; Unicode: Boolean): string;
var
  v: pointer;
  l: Integer;
begin
  v := sqlite3_value_blob(value);

  if Unicode then
  begin
    l := sqlite3_value_bytes16(value);
  end
  else
  begin
    l := sqlite3_value_bytes(value);
  end;

  if (v <> nil) and (l > 0) then
  begin

    if Unicode then
      Result := TMarshal.ReadStringAsUnicodeUpTo(TPtrWrapper.Create(v),l)
    else
      Result := TMarshal.ReadStringAsUtf8(TPtrWrapper.Create(v),l);

    Exit;
  end;

  result := '';
end;


function sqlite3_bind_text(Statement: Pointer; Index: Integer; const AValue: UTF8String): Integer;
var
  allocBytes: Integer;
  nByte: Integer;
  d: Pointer;
  s: PUtf8Char absolute AValue;
begin
  if Assigned(Statement) then
  begin
    nByte := Length(AValue) * SizeOf(Utf8Char);
    allocBytes := nByte + SizeOf(Utf8Char);
    if allocBytes > 0 then
    begin
      d := AllocMem(allocBytes);

      if nByte > 0 then
        Move(s^, d^, nByte);

      Result := sqlite3_bind_text(Statement,Index,d,nByte,sqlite3_destroy_mem);
      Exit;
    end;
  end;
  Result := SQLITE_MISUSE;
end;

function sqlite3_bind_text(Statement: Pointer; Index: Integer; const AValue: RawByteString): Integer;
var
  allocBytes: Integer;
  nByte: Integer;
  d: Pointer;
  s: PUtf8Char absolute AValue;
begin
  if Assigned(Statement) then
  begin
    nByte := Length(AValue) * SizeOf(AnsiChar);
    allocBytes := nByte + SizeOf(AnsiChar);
    if allocBytes > 0 then
    begin
      d := AllocMem(allocBytes);

      if nByte > 0 then
        Move(s^, d^, nByte);

      Result := sqlite3_bind_text(Statement,Index,d,nByte,sqlite3_destroy_mem);
      Exit;
    end;
  end;
  Result := SQLITE_MISUSE;
end;

function sqlite3_bind_text16(Statement: Pointer; Index: Integer; const AValue: string): Integer;
var
  nByte: Integer;
  p: Pointer;
begin
  nByte := Length(AValue) * SizeOf(WideChar);
  p := TMarshal.AllocStringAsUnicode(AValue).ToPointer;

  Result := sqlite3_bind_text16(Statement,Index,p,nByte,sqlite3_destroy_mem);
end;

{$REGION 'adt: todo: use this methods '}

  (*
  type
    TVarDataType = (
      vdtDefault, // varEmpty
      vdtNull,
      vdtSmallint,
      vdtInteger,
      vdtSingle,
      vdtDouble,
      vdtCurrency,
      vdtDate,
      vdtOleStr,  // varOleStr, varString, varUString
      vdtDispatch,
      vdtError,
      vdtBoolean,
      vdtVariant,
      vdtUnknown,
      vdtDecimal,
      vdtUndefined,
      vdtShortint,
      vdtByte,
      vdtWord,
      vdtLongWord,
      vdtInt64,
      vdtUInt64,
      vdtUnsupported
      {Usupported types
      VT_UI8  = 21,
      VT_INT  = 22,
      VT_UINT = 23,
      VT_VOID = 24,
      VT_HRESULT  = 25,
      VT_PTR  = 26,
      VT_SAFEARRAY    = 27,
      VT_CARRAY   = 28,
      VT_USERDEFINED  = 29,
      VT_LPSTR    = 30,
      VT_LPWSTR   = 31,
      VT_RECORD   = 36,
      VT_FILETIME = 64,
      VT_BLOB = 65,
      VT_STREAM   = 66,
      VT_STORAGE  = 67,
      VT_STREAMED_OBJECT  = 68,
      VT_STORED_OBJECT    = 69,
      VT_BLOB_OBJECT  = 70,
      VT_CF   = 71,
      VT_CLSID    = 72,
      VT_VERSIONED_STREAM = 73,
      VT_BSTR_BLOB    = 0xfff,
      VT_VECTOR   = 0x1000,
      VT_ARRAY    = 0x2000,
      VT_BYREF    = 0x4000,
      VT_RESERVED = 0x8000,
      VT_ILLEGAL  = 0xffff,
      VT_ILLEGALMASKED    = 0xfff,
      VT_TYPEMASK = 0xfff
      }
    );

  const
    SVarDataTypes: array [TVarDataType] of string  = (
      'Default',
      'Null',
      'Smallint',
      'Integer',
      'Single',
      'Double',
      'Currency',
      'Date',
      'OleStr',
      'Dispatch',
      'Error',
      'Boolean',
      'Variant',
      'Unknown',
      'Decimal',
      'Undefined',
      'Shortint',
      'Byte',
      'Word',
      'LongWord',
      'Int64',
      'UInt64',
      'Unsupported'
    );

  const
    SVarDataTypes: array [TVarDataType] of string  = (
      'Default',
      'Null',
      'Smallint',
      'Integer',
      'Single',
      'Double',
      'Currency',
      'Date',
      'OleStr',
      'Dispatch',
      'Error',
      'Boolean',
      'Variant',
      'Unknown',
      'Decimal',
      'Undefined',
      'Shortint',
      'Byte',
      'Word',
      'LongWord',
      'Int64',
      'UInt64',
      'Unsupported'
    );

    SVarArray = 'Array of %s';
    SVarByRef = '%s (Reference)';

  function VariantToStr(V: Variant; IncludeType: Boolean = False): string;
  begin
    if VarIsArray(V) then
      Result := VarArrayToStr(V)
    else
      case VarType(V) of
        varError:
          Result := Format('Error($%x)', [TVarData(v).VError]);
        varNull:
          Result := '#NULL';
        varEmpty:
          Result := '#EMPTY';
        varDate:
          Result := FormatDateTime(ShortDateFormat + ' ' + LongTimeFormat + '.zzz', V)
      else
        Result := VarToStr(V);
      end;
    if IncludeType then
      Result := Format('%s{%s}', [Result, VarTypeToString(VarType(V))]);
  end;


  function VarArrayToStr(v: Variant; Delimiter: Char = #0; LineDelimiter: Char = #13): string;
  var
    i,j,d: Integer;
    line: string;
  begin
    if VarIsArray(v) then
    begin
      if Delimiter = #0 then
        Delimiter := SysUtils.ListSeparator ;
      if LineDelimiter = #0 then
        LineDelimiter := SysUtils.ListSeparator ;
      d := VarArrayDimCount(v);
      // The elements
      case d of
        1:
        begin
          Result := '';
          for i := VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
            Result := Result + VariantToStr(v[i]) + Delimiter;
          if Length(Result) > 0 then
            SetLength(Result, Length(Result)-1);
        end;
        2:
        begin
          Result := '';
          if (VarArrayLowBound(v,1) <= VarArrayHighBound(v,1)) and
            (VarArrayLowBound(v,2) <= VarArrayHighBound(v,2)) then
          begin
            for i := VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
            begin
              line := '';
              for j := VarArrayLowBound(v,2) to VarArrayHighBound(v,2) do
                line := line + VariantToStr(v[i,j]) + Delimiter;
              if Length(Result) > 0 then
                SetLength(line, Length(line)-1);
              Result := Result + LineDelimiter + Format('[%s]', [line]);
            end;
          end;
        end // 2
      else
        Result := 'Array Dim=' + IntToStr(d);
      end;
      Result := Format('[%s]', [Result]);
    end
    else
      Result := VarToStr(v);
  end;

  function VarTypeToVarDataType(Value: Word): TVarDataType;
  var
    v: Word;
  begin
    v := Value and varTypeMask;
    if v < Word(vdtUnsupported) then
      result := TVarDataType(v)
    else if v = varString then
      result := vdtOleStr
    else if v = varUString then
      result := vdtOleStr
    else
      result := vdtUnsupported;
  end;

  function VarDataTypeToVarType(Value: TVarDataType; IsArray: Boolean =
      False): Word;
  begin
    if Value = vdtUnsupported then
      Result := varEmpty
    else
    begin
      Result := Word(Value);
      if IsArray then
        Result := Result or varArray;
    end;
  end;

  function VarTypeToString(varType: Integer): string;
  var
    T: TVarDataType;
  begin
    if varType = varString then
      Result := 'string'
    else
    begin
      T := VarTypeToVarDataType(varType);
      if T = vdtUnSupported then
        Result := IntToStr(varType and varTypeMask)
      else
        Result := SPsVarDataTypes[T];
    end;
    if (varType and varArray) <> 0 then
      Result := Format(SVarArray,[Result]);

    if (varType and varByRef) <> 0  then
      Result := Format(SVarByRef,[Result]);
  end;

  *)
{$ENDREGION}

function sqlite3_bind_variant(Statement: Pointer; Index: Integer; const Value: Variant): Integer;
var
  I64: Int64Rec;
  ValueData: TVarData;
begin

  ValueData := TVarData(Value);
  case ValueData.VType of
    varNull: Result := sqlite3_bind_null(Statement,Index);

    varBoolean: Result := sqlite3_bind_int(Statement,Index,Integer(ValueData.VBoolean));
//      if ValueData.VBoolean then
//        Result := sqlite3_bind_int(Statement,Index,1)
//      else
//        Result := sqlite3_bind_int(Statement,Index,0);
    varByte: Result := sqlite3_bind_int(Statement,Index,ValueData.VInteger);
    varSmallint: Result := sqlite3_bind_int(Statement,Index,ValueData.VSmallInt);
    varShortInt: Result := sqlite3_bind_int(Statement,Index,ValueData.VShortInt);
    varWord: Result := sqlite3_bind_int(Statement,Index,ValueData.VWord);
    varLongWord:
    begin
      I64.Lo := ValueData.VLongWord;
      I64.Hi := 0;

      Result := sqlite3_bind_int64(Statement,Index,Int64(I64));
    end;
    varInteger: Result := sqlite3_bind_int(Statement,Index,ValueData.VInteger);
    varInt64 {, varWord64}: Result := sqlite3_bind_int64(Statement,Index,ValueData.VInt64);
    varSingle: Result := sqlite3_bind_double(Statement,Index,ValueData.VSingle);
    varDouble: Result := sqlite3_bind_double(Statement,Index,ValueData.VDouble);
    varDate: Result := sqlite3_bind_double(Statement,Index,ValueData.VDate);
    varCurrency: Result := sqlite3_bind_double(Statement,Index,ValueData.VCurrency);
    varOleStr: // handle special case if was bound explicitely as WideString
      Result := sqlite3_bind_text16(Statement,Index,WideString(ValueData.VAny));
    varUString: Result := sqlite3_bind_text16(Statement,Index, TMarshal.ReadStringAsUnicode(TPtrWrapper.Create(ValueData.VAny))); // UnicodeString(ValueData.VAny);
    varString: Result := sqlite3_bind_text(Statement,Index,RawByteString(ValueData.VAny));
  else
    begin
      if ValueData.VType = varByRef or varVariant then
      begin
        Result := sqlite3_bind_variant(Statement,Index,PVariant(ValueData.VPointer)^)
      end
      else
      if ValueData.VType = varByRef or varOleStr then
      begin
        Result := sqlite3_bind_text16(Statement,Index,PWideString(ValueData.VAny)^)
      end
      else
      begin
        Result := sqlite3_bind_text16(Statement,Index,VarToStrDef(Value,'')); // ??? handle streams and arrays
      end;
    end;
  end;

end;

function sqlite3_expanded_sql_text(pStmt: Pointer): string;
var
  t: Pointer;
begin
  Result := '';

  if not Assigned(pStmt) then Exit;

  t := sqlite3_expanded_sql(pStmt);

  if Assigned(t) then
  begin
    try
      try
        Result := TMarshal.ReadStringAsAnsi(TPtrWrapper.Create(t));
      except
        Exit;
      end;
    finally
      sqlite3_free(t);
    end;
  end;
end;


procedure sqlite3_result_text(pCtx: PSQLite3FuncContext; const Text: Utf8String);
var
  allocBytes: NativeInt;
  nByte: NativeInt;
  p: Pointer;
begin
  nByte := Length(Text) * SizeOf(Utf8Char);
  allocBytes := nByte + SizeOf(Utf8Char);
  if allocBytes > 0 then
  begin
    p := AllocMem(allocBytes);
    if nByte > 0 then
      System.Move(PUtf8Char(Text)^, p^, nByte);
    sqlite3_result_text(pCtx, p, nByte, sqlite3_destroy_mem);
  end;
end;

procedure sqlite3_result_text(pCtx: PSQLite3FuncContext; const Text: string);
var
  nByte: NativeInt;
  p: Pointer;
begin
  p := TMarshal.AllocStringAsUtf8(Text).ToPointer;
  nByte := strlen(p);
  sqlite3_result_text(pCtx, p, nByte, sqlite3_destroy_mem);
end;

procedure sqlite3_result_text16(pCtx: PSQLite3FuncContext; const Text: string);
var
  allocBytes: NativeInt;
  nByte: NativeInt;
  p: Pointer;
begin
  nByte := Length(Text) * SizeOf(WideChar);
  allocBytes := nByte + SizeOf(WideChar);
  if allocBytes > 0 then
  begin
    p := AllocMem(allocBytes);
    if nByte > 0 then
      System.Move(PWideChar(Text)^, p^, nByte);
    sqlite3_result_text16(pCtx, p, nByte, sqlite3_destroy_mem);
  end;
end;

function fts5_api_from_db_v2(pDB: Pointer; ppApi: PPointer): Integer;
const
  pStmtTxt: MarshaledString = 'SELECT fts5(?1)';
var
  stmt: Pointer;
  pApi: Pointer;
begin
  stmt := nil;
  ppApi^ := nil;
  Result := sqlite3_prepare(pDB, 'SELECT fts5(?1)', -1, stmt, nil);
  if Result = SQLITE_OK then
  begin
    sqlite3_bind_pointer(stmt,1, pApi, 'fts5_api_ptr', nil);
    sqlite3_step(stmt);
    Result := sqlite3_finalize(stmt);
    if Result = SQLITE_OK then
      ppApi^ := pApi;
  end;
end;

function fts5_api_from_db(pDB: Pointer): PFTS5Api;
begin
  if fts5_api_from_db_v2(pDB, @Result) <> SQLITE_OK then
    Result := nil;
end;

procedure sqlite3_result_error_str(pCtx: PSQLite3FuncContext; const ErrorString: Utf8String);
var
  P: PUtf8Char;
begin
  P := Pointer(ErrorString);
  sqlite3_result_error(pCtx,P, sqlite3_strlen(P));
end;

procedure sqlite3_result_error_str(pCtx: PSQLite3FuncContext; const ErrorString: string);
var
  nByte: Integer;
  P: PWideChar;
begin
  P := Pointer(ErrorString);
  nByte := (Length(ErrorString) + 1) * SizeOf(WideChar);
  sqlite3_result_error16(pCtx,P,nByte)
end;
initialization
{$IFDEF SQLITE3_USE_CIPHER}
{$IFNDEF SQLITE3_CNG_CIPHER}
{$IFDEF SQLITE3_OpenSSL3_CIPHER}
  InitializeOpenSSL3Static;
{$ENDIF}
{$ENDIF}
{$ENDIF}

end.
