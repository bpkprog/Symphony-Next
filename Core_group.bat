echo off 
c:
cd c:\Users\Public\Documents\Embarcadero\Studio\18.0\Bpl
move /Y smpl*.bpl bak\

d:
cd d:\Baza\Program\Unicom\Symphony.next\PlugIn_Core
echo Сборка пакета smplIntf.dpk
dcc32 smplIntf.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplPrmImpl.dpk
dcc32 smplPrmImpl.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplMsgImpl.dpk
dcc32 smplMsgImpl.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplBaseFrame.dpk
dcc32 smplBaseFrame.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplORA.dpk
dcc32 smplORA.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplMSSQL.dpk
dcc32 smplMSSQL.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplIB.dpk
dcc32 smplIB.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplActListBuilder.dpk
dcc32 smplActListBuilder.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplmng.dpk
dcc32 smplmng.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplGridStyle.dpk
dcc32 smplGridStyle.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета smplCmdParser.dpk
dcc32 smplCmdParser.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета StateStorageGrid.dpk
dcc32 StateStorageGrid.dpk
if %errorlevel% NEQ 0 goto error

echo Копирование пакетов в папку bin
c:
cd c:\Users\Public\Documents\Embarcadero\Studio\18.0\Bpl
copy smpl*.bpl d:\Baza\Program\Ready\bin\*.*

goto end

:error
echo Ошибка сборки группы пакетов ядра Symphony.Next!!!

:end