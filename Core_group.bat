echo off 
c:
cd c:\Users\Public\Documents\Embarcadero\Studio\18.0\Bpl
move /Y smpl*.bpl bak\

d:
cd d:\Baza\Program\Unicom\Symphony.next\PlugIn_Core
echo ���ઠ ����� smplIntf.dpk
dcc32 smplIntf.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplPrmImpl.dpk
dcc32 smplPrmImpl.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplMsgImpl.dpk
dcc32 smplMsgImpl.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplBaseFrame.dpk
dcc32 smplBaseFrame.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplORA.dpk
dcc32 smplORA.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplMSSQL.dpk
dcc32 smplMSSQL.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplIB.dpk
dcc32 smplIB.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplActListBuilder.dpk
dcc32 smplActListBuilder.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplmng.dpk
dcc32 smplmng.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplGridStyle.dpk
dcc32 smplGridStyle.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� smplCmdParser.dpk
dcc32 smplCmdParser.dpk
if %errorlevel% NEQ 0 goto error

echo ���ઠ ����� StateStorageGrid.dpk
dcc32 StateStorageGrid.dpk
if %errorlevel% NEQ 0 goto error

echo ����஢���� ����⮢ � ����� bin
c:
cd c:\Users\Public\Documents\Embarcadero\Studio\18.0\Bpl
copy smpl*.bpl d:\Baza\Program\Ready\bin\*.*

goto end

:error
echo �訡�� ᡮન ��㯯� ����⮢ �� Symphony.Next!!!

:end