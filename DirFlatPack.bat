@ECHO OFF
REM Description:
REM   Batch file for creating symlinks of all files
REM   in a given directory and subdirectories to a
REM	  designated directory using a given symlink name
REM	  format.
REM
REM       Author: Kalbintion
REM         Date: 2024-08-05
REM Last Updated: 2024-08-06
REM
REM Note: Thanks to this SO answer https://stackoverflow.com/a/45070967
REM   for having information on more reliably handling batch arguments

:INIT
CALL :ARG-INIT
GOTO :ARG-PARSER

:USAGE-HEADER
ECHO %__NAME% v%__VERSION%
ECHO Batch file designed to create symlinks by collapsing a given directory
ECHO structure into a provided directory output.
ECHO.
GOTO :EOF

:USAGE
ECHO USAGE:
ECHO   %__BAT_NAME% [flags]
ECHO.
ECHO.  /?, --help                      Shows this usage information
ECHO.  /d path, --from path            The path to get all the files from. Uses the directory path provided.
ECHO.                                  If left out, assumes current working directory
ECHO.  /o path, --to path              The path to output all the symlinks to. Uses the directory path provided.
ECHO.                                  If left out, assumes current working directory
ECHO.  /l filter, --list filter        The filter used listing files. If not set, will get all files
ECHO.  /f format, --format format      Symlink file name format. See below for additional details. Default: @p@fn
ECHO.  /r, --remove                    Removes existing existing symlinks from output path before creating new ones
ECHO.  /fd flags, --dirflags flags     Overrides flags for the DIR command. Default: /A-D-L /B /S
ECHO.  /fs flags, --symflags flags     Overrides flags for the MKLINK command.
ECHO.  /il chars, --illegal chars      Overrides default characters that are not suitable for filenames. Default: \/:?"
ECHO.  /v, --verbose                   If set, shows more detail on what it's doing
ECHO.
ECHO. Format
ECHO.   The format given to the --format flag has the following valid options.
ECHO.   Any illegal characters (overridable with /il or --illegal) present in
ECHO.   any of the following values will be stripped with nothing. Anything
ECHO.   else given is taken literally as the text provided.
ECHO.
ECHO.   @f    The full path, file name and extension to the file
ECHO.   @dr    The drive letter of the file
ECHO.   @p    The path, without drive letter, to the file
ECHO.   @d    The drive letter and path of the file
ECHO.   @r    The relative path to the file from this batch file
ECHO.   @fn   The file name, including extension, of the file
ECHO.   @n    The file name, without extension, of the file
ECHO.   @x    The extension of the file
ECHO.   @a    The attributes of the file
ECHO.   @t    The date and time of the file
ECHO.   @z    The size of the file
GOTO :EOF

:ARG-PARSER
IF "%~1"=="" GOTO :ARG-VALIDATE

REM ?, -?, --help
IF /I "%~1"=="/?"     CALL :USAGE-HEADER & CALL :USAGE & GOTO :END
IF /I "%~1"=="-?"     CALL :USAGE-HEADER & CALL :USAGE & GOTO :END
IF /I "%~1"=="--help" CALL :USAGE-HEADER & CALL :USAGE & GOTO :END

REM /d, -d, --from
IF /I "%~1"=="/d"     SET "_Dir_From=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-d"     SET "_Dir_From=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--from" SET "_Dir_From=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER

REM /o, -o, --to
IF /I "%~1"=="/o"     SET "_Dir_To=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-o"     SET "_Dir_To=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--to"   SET "_Dir_To=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER

REM /l, -l, --list
IF /I "%~1"=="/l"       SET "_Opt_List=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-l"       SET "_Opt_List=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--list"   SET "_Opt_List=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER

REM /f, -f, --format
IF /I "%~1"=="/f"       SET "_Opt_Format=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-f"       SET "_Opt_Format=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--format" SET "_Opt_Format=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER

REM /f, -f, --format
IF /I "%~1"=="/fd"        SET "_Opt_DirFlag=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-fd"        SET "_Opt_DirFlag=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--dirflags" SET "_Opt_DirFlag=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER

REM /f, -f, --format
IF /I "%~1"=="/fs"        SET "_Opt_SymFlag=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-fs"        SET "_Opt_SymFlag=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--symflags" SET "_Opt_SymFlag=%~2" & SHIFT & SHIFT & GOTO :ARG-PARSER

REM /v, -v, --verbose
IF /I "%~1"=="/v"        SET "_Opt_Verbose=TRUE" & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-v"        SET "_Opt_Verbose=TRUE" & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--verbose" SET "_Opt_Verbose=TRUE" & SHIFT & GOTO :ARG-PARSER

REM /r, -r, --remove
IF /I "%~1"=="/r"        SET "_Opt_Remove=TRUE" & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="-r"        SET "_Opt_Remove=TRUE" & SHIFT & GOTO :ARG-PARSER
IF /I "%~1"=="--remove"  SET "_Opt_Remove=TRUE" & SHIFT & GOTO :ARG-PARSER

SHIFT
GOTO :ARG-PARSER

:ARG-INIT
SET "__NAME=%~n0"
SET "__VERSION=1.00"
SET "__BAT_NAME=%~nx0"
SET "__BAT_PATH=%~dp0"
SET "__BAT_FILE=%~0"

SET "_Dir_To="
SET "_Dir_From="
SET "_Opt_Format="
SET "_Opt_Verbose="
SET "_Opt_List="
SET "_Opt_DirFlag="
SET "_Opt_SymFlag="
SET "_Opt_Illegal="

SET "_Count_Creation=0"
SET "_Count_Files=0"
SET "_Count_Skipped=0"
GOTO :EOF

:ARG-VALIDATE
IF NOT DEFINED _Dir_To      SET "_Dir_To=%~dp0"
IF NOT DEFINED _Dir_From    SET "_Dir_From=%~dp0"
IF NOT DEFINED _Opt_Format  SET "_Opt_Format=@p@fn"
IF NOT DEFINED _Opt_Verbose SET "_Opt_Verbose=FALSE"
IF NOT DEFINED _Opt_List    SET "_Opt_List=*"
IF NOT DEFINED _Opt_DirFlag SET "_Opt_DirFlag=/A-D-L /B /S"
IF NOT DEFINED _Opt_SymFlag SET "_Opt_SymFlag="
IF NOT DEFINED _Opt_Illegal SET "_Opt_Illegal=\/:?""
IF NOT DEFINED _Opt_Remove  SET "_Opt_Remove=FALSE"
GOTO :CORE

:ARG-CLEAN
SET "__NAME="
SET "__VERSION="
SET "__BAT_NAME="
SET "__BAT_PATH="
SET "__BAT_FILE="
SET "_Dir_To="
SET "_Dir_From="
SET "_Opt_Format="
SET "_Opt_Verbose="
SET "_Opt_List="
SET "_Opt_DirFlag="
SET "_Opt_SymFlag="
SET "_Opt_Illegal="
SET "_Opt_Remove="

SET "_TEMP_FULL="
SET "_TEMP_DRIVE="
SET "_TEMP_PATH="
SET "_TEMP_DIR="
SET "_TEMP_FILE_NAME="
SET "_TEMP_NAME="
SET "_TEMP_EXT="
SET "_TEMP_ATTR="
SET "_TEMP_SIZE="

SET "_TEMP_Illegal="
SET "_B_Illegal="

SET "_Count_Creation="
SET "_Count_Files="
SET "_Count_Skipped="
GOTO :EOF

:CORE
IF %_Opt_Remove% EQU TRUE CALL :CORE-CLEAN-SYM
FOR /F "usebackq delims=" %%F IN (`DIR %_Opt_DirFlag% "%_Dir_From%%_Opt_List%"`) DO CALL :CORE-SYM-MAKER "%%F"
GOTO :CORE-COMPLETE

:CORE-SYM-MAKER
:: Increment file counter
SET /A _Count_Files=%_Count_Files%+1

:: Set-up file information
SET "_TEMP_FULL=%1"
SET "_TEMP_DRIVE=%~d1"
SET "_TEMP_PATH=%~p1"
SET "_TEMP_DIR=%~dp1"
SET "_TEMP_FILE_NAME=%~nx1"
SET "_TEMP_NAME=%~n1"
SET "_TEMP_EXT=%~x1"
SET "_TEMP_ATTR=%~a1"
SET "_TEMP_DATETIME=%~t1"
SET "_TEMP_SIZE=%~z1"

SET "_TEMP_FORMAT=%_Opt_Format%"

:: REPLACE ALL TOKENS IN _TEMP_FORMAT
:: 2-letter format flags
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@dr^=%_TEMP_DRIVE%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@fn^=%_TEMP_FILE_NAME%%%

:: 1-letter format flags
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@f^=%_TEMP_FULL%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@p^=%_TEMP_PATH%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@d^=%_TEMP_DIR%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@n^=%_TEMP_NAME%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@x^=%_TEMP_EXT%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@a^=%_TEMP_ATTR%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@t^=%_TEMP_DATETIME%%%
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:@z^=%_TEMP_SIZE%%%

:: Clean _TEMP_FORMAT from invalid filename characters
SET _TEMP_Illegal=%_Opt_Illegal%
CALL :CORE-CLEAN-VAR

:: Make Symlink for file
IF EXIST "%_DIR_To%%_TEMP_FORMAT%" IF %_Opt_Verbose% EQU TRUE ECHO Skipping symlink for %_TEMP_FULL%
IF EXIST "%_Dir_To%%_TEMP_FORMAT%" GOTO :EOF
IF %_Opt_Verbose% EQU TRUE ECHO Creating symlink for %_TEMP_FULL%
SET /A _Count_Creation=%_Count_Creation%+1
MKLINK %_OPT_SymFlag% "%_Dir_To%%_TEMP_FORMAT%" %_TEMP_FULL% 2>&1 >NUL
GOTO :EOF

:CORE-CLEAN-VAR
:: Removes illegal characters
SET "_TEMP_CHAR=%_TEMP_Illegal:~0,1%"
SET "_TEMP_Illegal=%_TEMP_Illegal:~1%"
CALL SET _TEMP_FORMAT=%%_TEMP_FORMAT:%_TEMP_CHAR%^=%%
IF NOT DEFINED _TEMP_Illegal GOTO :EOF
GOTO :CORE-CLEAN-VAR

:CORE-CLEAN-SYM
FOR /F "usebackq delims=" %%L IN (`DIR /AL /B "%_Dir_To%"`) DO DEL "%_Dir_To%%%L"
GOTO :EOF

:CORE-COMPLETE
ECHO. Flattening of directory %_Dir_From% has been completed.
:: Fall-through to :END purposefully

:END
IF %_Opt_Verbose% EQU TRUE CALL :END-STATS
CALL :ARG-CLEAN
EXIT /B

:END-STATS
SET /A _Count_Skipped=%_Count_Files%-%_Count_Creation%
ECHO.
ECHO Created %_Count_Creation% symlinks for %_Count_Files% files, and skipped %_Count_Skipped% symlinks
ECHO.
GOTO :EOF

:EOF
