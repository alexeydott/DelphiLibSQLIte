{$DEFINE SQLITE3_RUSSIAN_LOCALE}          // translated error/warn messages to russian locale
{$DEFINE SQLITE3_USE_URIFILENAMES}        // allow uri file names by default
{.$DEFINE SQLITE3_DEBUGSTRING}             // supports log errors and warning to output debug string
{$DEFINE SQLITE3_USE_STEMMER}             // use stemmer for more accurately full text search
{$DEFINE SQLITE3_REGULAR_EXPRESSIONS}     // register regexp/regextract/regexp_replace
{$DEFINE SQLITE3_BUILTIN_MATH_FUNCTIONS}  // register some math functions for sql99 standart
{$DEFINE SQLITE3_USE_CIPHER}              // support encrypt / decrypting via sqlcipher functions
{$DEFINE SQLITE3_CNG_CIPHER}              // use Windows CNG (bcrypt.dll) provider instead of OpenSSL
{$DEFINE SQLITE_ENABLE_SESSION}           // expose SQLite Session/Changeset API
{$IFDEF MSWINDOWS}
// http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/devcommon/compdirsweakpackaging_xml.html
{.$WEAKPACKAGEUNIT}
{$ENDIF}

{$IFDEF USER_DEFINES_INC}{$I user_defines.inc}{$ENDIF}
