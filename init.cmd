@echo off
SetLocal EnableDelayedExpansion

@if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%
@if not exist "%HOME%" @set HOME=%USERPROFILE%

if not "%1" == "" (
    if exist %1\* (
        set DEST="%1"
    )
) else (
    set DEST="%HOME%"
)
echo Destination - %DEST%

REM Directory, where script is located.
REM path\to\this\script\
set SCRIPT_DIR=%~dp0
REM path\to\this\script
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

REM Make backup folder if it doesn't exist.
set BACKUP_DIR=%SCRIPT_DIR%\backup
if not exist "%BACKUP_DIR%" (
    echo Making backup dir %BACKUP_DIR%
    mkdir "%BACKUP_DIR%"
)


echo Linking .bashrc
call:backupAndLink "%SCRIPT_DIR%\shells\.bashrc" "%DEST%\.bashrc"

echo Linking .zshrc
call:backupAndLink "%SCRIPT_DIR%\shells\.zshrc" "%DEST%\.zshrc"

echo Linking aliases
call:backupAndLink "%SCRIPT_DIR%\shells\.my_aliases"^
    "%DEST%\.my_aliases"

echo Linking .tmux.conf
call:backupAndLink "%SCRIPT_DIR%\.tmux.conf" "%DEST%\.tmux.conf"

echo Linking .git*
call:backupAndLink "%SCRIPT_DIR%\git\.gitconfig" "%DEST%\.gitconfig"
call:backupAndLink "%SCRIPT_DIR%\git\.gitignore_global"^
    "%DEST%\.gitignore_global"

echo Linking vim
call:backupAndLink "%SCRIPT_DIR%\editors\Vim\.vimrc" "%DEST%\.vimrc"
call:backupAndLinkDir "%SCRIPT_DIR%\editors\Vim\.vim" "%DEST%\vimfiles"

echo Installing vim plugins
git submodule init && git submodule update

goto:eof


REM Helpers

REM Takes last folder name from path.
REM c:\1\2\3 45 => %LAST_DIR%==3 45.
REM Trailing backslash is disallowed.
REM \param Path.
REM \return Last folder name from path.
:takeLastFolderName
    for %%f in ("%~1") do (
        set LAST_DIR=%%~nxf
    )
goto:eof

REM If destination exists backup it, then link destination to source.
REM \param Source path.
REM \param Destination path.
:backupAndLinkDir
    if exist "%~2" (
        call:takeLastFolderName "%~2"

        REM /E - copy all subdirectories, even if they are empty.
        REM /H - copy files with hidden and system file attributes. By default,
        REM xcopy does not copy hidden or system files.
        REM /R - copy read-only files.
        REM /X - copy file audit settings and system access control list (SACL)
        REM information (implies /o).
        REM /Y - suppresses prompting to confirm that you want to overwrite an
        REM existing destination file.
        REM /I - if Source is a directory or contains wildcards and Destination
        REM does not exist, xcopy assumes destination specifies a directory
        REM name and creates a new directory. Then, xcopy copies all specified
        REM files into the new directory. By default, xcopy prompts you to
        REM specify whether Destination is a file or a directory.
        REM /K - copy files and retains the read-only attribute on destination
        REM files if present on the source files. By default, xcopy removes the
        REM read-only attribute.
        REM /B - copy symbolic link itself versus the target of the link.
        xcopy "%~2" "%BACKUP_DIR%\!LAST_DIR!" /E /H /R /X /Y /I /K /B > NUL

        REM -r - delete directory and its content recursively.
        rm -r "%~2" > NUL
    )

    REM /D - creates a directory symbolic link.
    mklink /D "%~2" "%~1" > NUL
goto:eof

REM If destination exists backup it, then link destination to source.
REM \param Source path.
REM \param Destination path.
:backupAndLink
    if exist "%~2" (
        REM /Y - suppress prompting to confirm you want to overwrite an
        REM existing file.
        move /Y "%~2" "%BACKUP_DIR%" > NUL
    )

    mklink "%~2" "%~1" > NUL
goto:eof

