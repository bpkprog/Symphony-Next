d:
cd d:\Baza\Program\Unicom\Symphony.next\

cd ConstIO
echo ���ઠ ����� cioIntf.dpk
dcc32 cioIntf.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� cioXML.dpk
dcc32 cioXML.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� ciocioORAIntf.dpk
dcc32 cioORA.dpk
if %errorlevel% NEQ 0 goto error


cd ..\SymDBOra
echo ���ઠ ����� SymDBFB.dpk
dcc32 SymDBFB.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� SymDBORA.dpk
dcc32 SymDBORA.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� SymDBMSSQL.dpk
dcc32 SymDBMSSQL.dpk
if %errorlevel% NEQ 0 goto error


cd ..\SymTaskOra
echo ���ઠ ����� SymTaskFB.dpk
dcc32 SymTaskFB.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� SymTaskORA.dpk
dcc32 SymTaskORA.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� SymTaskMSSQL.dpk
dcc32 SymTaskMSSQL.dpk
if %errorlevel% NEQ 0 goto error


cd ..\UITasksBuilders
echo ���ઠ ����� stbIntf.dpk
dcc32 stbIntf.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� stbMngs.dpk
dcc32 stbMngs.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� stbdxRibbonH.dpk
dcc32 stbdxRibbonH.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� stbdxRibbonV.dpk
dcc32 stbdxRibbonV.dpk
if %errorlevel% NEQ 0 goto error


cd ..\UsageTaskStatistic
echo ���ઠ ����� utsORA.dpk
dcc32 utsORA.dpk
if %errorlevel% NEQ 0 goto error

cd ..\SymMng
echo ���ઠ �ணࠬ�� SymMng.dpk
dcc32 SymMng.dpr
if %errorlevel% NEQ 0 goto error

cd ..\s7exec
echo ���ઠ ����� s7exec.dpk
dcc32 s7exec.dpk
if %errorlevel% NEQ 0 goto error

goto end

:error
echo �訡�� ᡮન ��㯯� ����⮢ Symphony.Next!!!

:end
rem pause