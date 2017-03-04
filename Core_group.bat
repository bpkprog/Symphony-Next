c:
cd c:\Users\Public\Documents\Embarcadero\Studio\18.0\Bpl
move /Y smpl*.bpl bak\

d:
cd d:\Baza\Program\Unicom\Symphony.next\PlugIn_Core
dcc32 smplIntf.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplPrmImpl.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplMsgImpl.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplBaseFrame.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplORA.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplMSSQL.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplIB.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplActListBuilder.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplmng.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplGridStyle.dpk
if %errorlevel% NEQ 0 goto error

dcc32 smplCmdParser.dpk
if %errorlevel% NEQ 0 goto error

dcc32 StateStorageGrid.dpk
if %errorlevel% NEQ 0 goto error

c:
cd c:\Users\Public\Documents\Embarcadero\Studio\18.0\Bpl
copy smpl*.bpl d:\Baza\Program\Ready\bin\*.*

goto end

:error
echo Ошибка сборки группы пакетов ядра Symphony.Next!!!

:end