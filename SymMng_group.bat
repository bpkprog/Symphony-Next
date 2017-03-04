d:
cd d:\Baza\Program\Unicom\Symphony.next\

cd ConstIO
dcc32 cioIntf.dpk
if %errorlevel% NEQ 0 goto error

dcc32 cioXML.dpk
if %errorlevel% NEQ 0 goto error

dcc32 cioORA.dpk
if %errorlevel% NEQ 0 goto error


cd ..\SymDBOra
dcc32 SymDBFB.dpk
if %errorlevel% NEQ 0 goto error

dcc32 SymDBORA.dpk
if %errorlevel% NEQ 0 goto error

dcc32 SymDBMSSQL.dpk
if %errorlevel% NEQ 0 goto error


cd ..\SymTaskOra
dcc32 SymTaskFB.dpk
if %errorlevel% NEQ 0 goto error

dcc32 SymTaskORA.dpk
if %errorlevel% NEQ 0 goto error

dcc32 SymTaskMSSQL.dpk
if %errorlevel% NEQ 0 goto error


cd ..\UITasksBuilders
dcc32 stbIntf.dpk
if %errorlevel% NEQ 0 goto error

dcc32 stbMngs.dpk
if %errorlevel% NEQ 0 goto error

dcc32 stbdxRibbonH.dpk
if %errorlevel% NEQ 0 goto error

dcc32 stbdxRibbonV.dpk
if %errorlevel% NEQ 0 goto error


cd ..\UsageTaskStatistic
dcc32 utsORA.dpk
if %errorlevel% NEQ 0 goto error

cd ..\SymMng
dcc32 SymMng.dpr
if %errorlevel% NEQ 0 goto error

goto end

:error
echo Ошибка сборки группы пакетов Symphony.Next!!!

:end