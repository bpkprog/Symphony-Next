d:
cd d:\Baza\Program\Unicom\Symphony.next\

cd ConstIO
echo Сборка пакета cioIntf.dpk
dcc32 cioIntf.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета cioXML.dpk
dcc32 cioXML.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета ciocioORAIntf.dpk
dcc32 cioORA.dpk
if %errorlevel% NEQ 0 goto error


cd ..\SymDBOra
echo Сборка пакета SymDBFB.dpk
dcc32 SymDBFB.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета SymDBORA.dpk
dcc32 SymDBORA.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета SymDBMSSQL.dpk
dcc32 SymDBMSSQL.dpk
if %errorlevel% NEQ 0 goto error


cd ..\SymTaskOra
echo Сборка пакета SymTaskFB.dpk
dcc32 SymTaskFB.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета SymTaskORA.dpk
dcc32 SymTaskORA.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета SymTaskMSSQL.dpk
dcc32 SymTaskMSSQL.dpk
if %errorlevel% NEQ 0 goto error


cd ..\UITasksBuilders
echo Сборка пакета stbIntf.dpk
dcc32 stbIntf.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета stbMngs.dpk
dcc32 stbMngs.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета stbdxRibbonH.dpk
dcc32 stbdxRibbonH.dpk
if %errorlevel% NEQ 0 goto error

echo Сборка пакета stbdxRibbonV.dpk
dcc32 stbdxRibbonV.dpk
if %errorlevel% NEQ 0 goto error


cd ..\UsageTaskStatistic
echo Сборка пакета utsORA.dpk
dcc32 utsORA.dpk
if %errorlevel% NEQ 0 goto error

cd ..\SymMng
echo Сборка программы SymMng.dpk
dcc32 SymMng.dpr
if %errorlevel% NEQ 0 goto error

cd ..\s7exec
echo Сборка пакета s7exec.dpk
dcc32 s7exec.dpk
if %errorlevel% NEQ 0 goto error

goto end

:error
echo Ошибка сборки группы пакетов Symphony.Next!!!

:end
rem pause