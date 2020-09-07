@ECHO OFF
:STARTSCRIPT
::
:: Microsoft Windows(R) Command Script
:: Copyright (c) 1990-2020 Microsoft Corp. All rights reserved.
::

::
:: DETAILS
::

::
:: runit.bat
:: Zenfone Max Series/Max Pro Series Console Toolkit
::
:: Date/Time Created:          07/09/2020  2:48pm
:: Date/Time Modified:         09/07/2020  6:40am
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Foundation
::
::
:: VersionInfo:
::
::    File version:      1,0
::    Product Version:   1,0
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   Make it easier to modified the ASUS Zenfone Max series
::    FileVersion:       1.0
::    InternalName:      runit
::    LegalCopyright:    The Firefox Foundation
::    OriginalFileName:  runit.sh
::    ProductName:       Zenfone Max Series/Max Pro Series Console Toolkit
::    ProductVersion:    1.0
::



:: BEGIN

:1
if "%OS%" == "Windows_NT" goto 2

ver | find "Operating System/2" >nul
if not errorlevel 1 goto winos2

ver | find "OS/2" >nul
if not errorlevel 1 goto winos2

ver | find "Windows 95" >nul
if not errorlevel 1 goto winos2

ver | find "Windows 98" >nul
if not errorlevel 1 goto winos2

ver | find "Chicago" >nul
if not errorlevel 1 goto winos2

ver | find "Nashville" >nul
if not errorlevel 1 goto winos2

ver | find "Memphis" >nul
if not errorlevel 1 goto winos2

ver | find "Millennium" >nul
if not errorlevel 1 goto winos2

ver | find "[Version 4" >nul
if not errorlevel 1 goto winos2

goto dos


:2
setlocal
for %%v in (OS/2 NT Hydra Cairo Neptune Whistler 2000 XP) do (
	ver | findstr /r /c:"%%v" >nul
	if not errorlevel 1 goto nt
)

for /f "tokens=5,6 delims=[.XP " %%v in ('ver') do ( set "version=%%v.%%w" )
for %%v in (5.00 5.1 5.2 5.3) do ( if "%version%" == "%%v" goto nt )
for /f "tokens=4,5 delims=[.XP " %%v in ('ver') do ( set "version=%%v.%%w" )
for %%v in (5.1 5.2 5.3 6.0) do ( if "%version%" == "%%v" goto nt )

>nul 2>&1 cacls %systemroot%\system32\config\system
if [%errorlevel%] NEQ [0] (
	echo You have not allowed to access this program.
	echo Please run this script as administrator user mode or with an
	echo administrative privileges access.
	echo.
	echo Access is denied.
	endlocal
	exit /b
	goto endscript
)

echo You will running to this program. If you are sure to modificate your device
echo press Y to allow and continue. Otherwise if deny and get out this program,
echo press N.
echo.
choice /c yn /n /m "Do you agree? [Y/N] "
if errorlevel 2 (
	endlocal
	exit /b
	goto endscript
)

:3
for %%v in (6.1 6.2 6.3 10.0) do ( if "%version%" == "%%v" setlocal EnableExtensions EnableDelayedExpansion )
set "BASEDIR=%~dp0"
set "ORIG_PATH=%PATH%"
set "PATH=%BASEDIR%\bin;%PATH%"
set "errorp=ERROR:"
set "cautionp=CAUTION:"
set "infop=INFORMATION:"
cd /d "%~dp0"

if exist "%BASEDIR%\bin\adb.exe"  (
	echo ADB installed on Console Toolkit.
	echo Starting ADB service...
	adb start-server
)


:main-menu
@echo off
for %%v in (
	reboot_recovery recovery_adb recovery_fastboot
	reboot_system reboot_adb reboot_fastboot
	reboot_bootloader bootloader_adb bootloader_fastboot
	adbfastboot_notfound no_connection codename_false
	largest_anti error no_mount choice recoveryimg
	rootsel rootzip twrp_exit root_exit
	MOUNT_SCRIPT UNMOUNT_SCRIPT
) do ( set "%%v=" )
break off
cls
color 1f
echo.
echo MAIN MENU
echo 様様様様様
echo.
echo Current state:
adb devices 2>&1 | findstr /r /c:"device\>" || (
adb devices 2>&1 | findstr /r /c:"recovery\>" || (
fastboot devices 2>&1 | findstr /r /c:"fastboot\>" || (
	echo Nothing device connection.
	echo Plug your device to PC with USB cable and press ENTER to refresh.
) ) )
echo.
echo.
echo    1.^)  Check the bootloader status
echo    2.^)  Flash TWRP ^(Custom recovery^)
echo    3.^)  Flash ASUS Decryption
echo    4.^)  Flash Camera2 API Enabler
echo    5.^)  Flash Root
echo    6.^)  Emulate the device shell
echo    7.^)  Reboot to system
echo    8.^)  Reboot to bootloader
echo    9.^)  Reboot to recovery
echo    0.^)  Switch ADB Connection
echo.
echo    A.^)  Run ADB Devices installer
echo    B.^)  Install ADB and Fastboot programs
echo    H.^)  Show help and about this program
echo    Q.^)  Exit this program
echo.
set /p "choice=Choose your option: "
echo.
if [%choice%] EQU []  goto main-menu
for %%a in (C c D d E e F f G g I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
	if [%choice%] == [%%a] goto main-menu
)
if [%choice%] LEQ []  goto main-menu
for %%a in (Q q) do (
	if [%choice%] == [%%a]  (
		call :end1
		exit /b
		goto endscript
	)
)
for %%a in (H h) do (
	if [%choice%] == [%%a]  goto :help
)
for %%a in (B b) do (
	if [%choice%] == [%%a]  goto :adbfastboot
)
for %%a in (A a) do (
	if [%choice%] == [%%a]  goto :adbinstaller
)
if [%choice%] == [0]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-devices1
	if defined no_connection goto main-menu
	call :switch-adb
	call :end2
	goto main-menu
)
if [%choice%] == [9]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	set "reboot_recovery=1"
	echo Trying reboot from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying reboot from recovery state...
		call :check-devices2
		if defined no_connection (
			echo Trying reboot from fastboot state...
			call :check-fastboot
			if defined no_connection (
				call :end2
				goto main-menu
			)
		)
	)
	call :reboot-recovery
	call :end2
	goto main-menu
)
if [%choice%] == [8]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	set "reboot_bootloader=1"
	echo Trying reboot from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying reboot from recovery state...
		call :check-devices2
		if defined no_connection (
			echo Trying reboot from fastboot state...
			call :check-fastboot
			if defined no_connection (
				call :end2
				goto main-menu
			)
		)
	)
	call :reboot-bootloader
	call :end2
	goto main-menu
)
if [%choice%] == [7]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	set "reboot_system=1"
	echo Trying reboot from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying reboot from recovery state...
		call :check-devices2
		if defined no_connection (
			echo Trying reboot from fastboot state...
			call :check-fastboot
			if defined no_connection (
				call :end2
				goto main-menu
			)
		)
	)
	call :reboot-systemdevices
	call :end2
	goto main-menu
)
if [%choice%] == [6]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	echo Trying connect from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying connect from recovery state...
		call :check-devices2
		if defined no_connection (
			call :end2
			goto main-menu
		)
	)
	echo To terminate from shell, type 'exit'...
	adb shell
	call :end2
	goto main-menu
)
if [%choice%] == [5]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :flash-root
	if defined root_exit goto main-menu
	call :end2
	goto main-menu
)
if [%choice%] == [4]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-sideload
	if defined no_connection goto main-menu
	call :flash-cam2api
	call :end2
	goto main-menu
)
if [%choice%] == [3]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-sideload
	if defined no_connection goto main-menu
	call :flash-lazy
	call :end2
	goto main-menu
)
if [%choice%] == [2]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-fastboot
	if defined no_connection goto main-menu
	call :check-codename
	if defined codename_false goto main-menu
	call :flash-twrp
	if defined twrp_exit goto main-menu
	call :end2
	goto main-menu
)
if [%choice%] == [1]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-fastboot
	if defined no_connection goto main-menu
	call :check-codename
	if defined codename_false goto main-menu
	call :check-unlock
	call :end2
	goto main-menu
)



:startopt
echo ------------------------------------ START ------------------------------------
goto :eof

:adbinstaller
call "%BASEDIR%\bin\pkg\adb-drivers_installer.exe"
goto main-menu

:adbfastboot
for %%f in ('adb' 'fastboot') do ( if exist "%BASEDIR%\bin\%%f.exe" (
	echo %infop%  ADB and Fastboot already installed. )
	timeout /t 2 /nobreak >nul
	goto main-menu
)
if not exist "%BASEDIR%\bin\pkg\android-platform-tools-win.zip" (
	wget -O "%BASEDIR%\bin\pkg\android-platform-tools-win.zip" https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip?hl=id
)
7z -ao -x -o "%BASEDIR%\bin" "%BASEDIR%\bin\pkg\android-platform-tools-win.zip"
echo d | xcopy "%BASEDIR%\bin\platform-tools" "%BASEDIR%\bin"
del /sq "%BASEDIR%\bin\platform-tools"
for %%f in ('adb' 'fastboot') do ( if exist "%BASEDIR%\bin\%%f.exe" (
	echo %infop%  ADB and Fastboot successfully installed. ) else (
	echo %errorp%  Failed installed. Please try again. )
	pause
)
goto main-menu

:help
cls
echo This program was written and created by Faizal Hamzah with the aim of
echo making it easier for users to do the work of modifying Android mobile
echo devices. Facilities of this program, include^:
echo.
echo   1.  Check the status bootloader ^(e.g. Unlock and Lock^)
echo   2.  Flash custom reecovery^/TWRP
echo   3.  Flash ASUS Decryption.
echo   4.  Enable Camera2 API
echo   5.  Flash Root Access
echo   6.  Run Terminal Android in PC
echo   7.  Switch ADB Connection
echo.
echo This program is only for those who have a ASUS Zenfone Max series
echo phone ^(codename^: X00P msm8917^/X00TD sdm636^/X01AD msm8953^/X01BD sdm660^)
echo.
pause
cls
echo Special thanks:
echo ^>  Google - Android
echo ^>  TWRP team
echo ^>  Orangefox team
echo ^>  PitchBlack team
echo ^>  Magisk team
echo ^>  XDA
echo ^>  ASUS Flashing Team
echo ^>  and the users ASUS Zenfone Max series
echo    -  ASUS Zenfone Max M1
echo    -  ASUS Zenfone Max Pro M1
echo  	-  ASUS Zenfone Max M2
echo 	-  ASUS Zenfone Max Pro M2
echo.
pause
cls
echo Contact person^:
echo ^> https^:^/^/api.whatsapp.com^/send^?phone^=6288228419117
echo ^> https^:^/^/www.facebook.com^/thefirefoxflasher
echo ^> https^:^/^/www.instagram.com^/thefirefoxflasher^_
echo.
pause
goto main-menu



:check-adb
echo Checking ADB and Fastboot programs...
for %%f in ('adb' 'fastboot') do ( if exist "%BASEDIR%\bin\%%f.exe" (
	echo %errorp%  ADB and Fastboot not installed.
	set "adbfastboot_notfound=1"
	call :end2
) )
goto :eof

:check-devices1
if defined back (
	echo Reconnecting...
	set "back="
) else ( echo Checking connection... )
set no_connection=
for %%v in (reboot_recovery reboot_system reboot_bootloader) do ( if defined %%v adb wait-for-device )
adb devices 2>&1 | findstr /r /c:"device\>" || (
	echo %errorp%  Your device not connected. Check the driver or USB debugging.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		set "no_connection=1"
		if [%reboot_recovery%] == [1]	 goto :eof
		if [%reboot_system%] == [1]		 goto :eof
		if [%reboot_bootloader%] == [1]	 goto :eof
		call :end2
		goto :eof
	)
	set "back=1"
	goto check-devices1
)
if [%reboot_recovery%] == [1]	 set "recovery_adb=1"
if [%reboot_system%] == [1]		 set "reboot_adb=1"
if [%reboot_bootloader%] == [1]	 set "bootloader_adb=1"
goto :eof

:check-devices2
if defined back (
	echo Reconnecting...
	set "back="
) else ( echo Checking connection... )
set no_connection=
for %%v in (reboot_recovery reboot_system reboot_bootloader) do ( if defined %%v adb wait-for-recovery )
adb devices 2>&1 | findstr /r /c:"recovery\>" || (
	echo %errorp%  Your device not connected in recovery. Check the driver or reboot recovery again.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		set "no_connection=1"
		if [%reboot_recovery%] == [1]	 goto :eof
		if [%reboot_system%] == [1]		 goto :eof
		if [%reboot_bootloader%] == [1]	 goto :eof
		call :end2
		goto :eof
	)
	set "back=1"
	goto check-devices2
)
if [%reboot_recovery%] == [1]	 set "recovery_adb=1"
if [%reboot_system%] == [1]		 set "reboot_adb=1"
if [%reboot_bootloader%] == [1]	 set "bootloader_adb=1"
goto :eof

:switch-adb
set "no_connection="
if not defined ipaddrs echo Identifying IP Address from your device...
for /f "tokens=2 delims= " %%i in ('adb shell ip addr^| findstr "wlan0"^| findstr "inet"') do ( set "ipaddrs=%%i" )
for /f "tokens=1 delims=/" %%i in ("%ipaddrs%") do ( set "ipaddrs=%%i" )
set tcport=5555
adb devices | findstr /r /c:"%ipaddrs%:%tcport%" >nul 2>&1
if [%errorlevel%] EQU [0] (
	echo %infop%  Your device already connected on network.
	choice /c yn /n /m "Do you want to disable ADB Network? [Y/N] "
	set "back=1"
	if errorlevel 2 goto :eof
	echo.
	echo Disconnecting ADB from network...
	adb disconnect >nul
	echo Please plug USB cable on this PC and your device.
	pause
	echo Connecting...
	adb wait-for-device
	adb usb 2>&1 || (
		echo %errorp%  Connected failure. Please try again.
		call :end2
		goto :eof
	)
	echo Successfully disconnected.
	for %%v in ('tcport' 'ipaddrs') do ( set "%%v=" )
	call :end2
	goto :eof
) else (
	echo Disconnecting ADB from USB...
	adb disconnect >nul
	adb tcpip %tcport%
	echo Please unplug USB cable on this PC and your device.
	pause
	echo Connecting to your IP Address and ADB Server Port...
	adb connect %ipaddrs%:%tcport%
	adb wait-for-device
	adb devices 2>&1 | findstr /r /c:"%ipaddrs%:%tcport%" || (
		echo %errorp%  Connected failure. Plug your device and try again.
		adb usb 2>&1
		goto :eof
	)
	echo %infop%  Success connected. To back the USB, disable network at your device.
	call :end2
	goto :eof
)

:check-fastboot
echo Checking fastboot connection...
set no_connection=
fastboot devices 2>&1 | findstr /r /c:"fastboot\>" || (
	echo %errorp%  Your device not connected.
	set "no_connection=1"
	if [%reboot_recovery%] == [1]	 goto :eof
	if [%reboot_system%] == [1]		 goto :eof
	if [%reboot_bootloader%] == [1]	 goto :eof
	call :end2
	goto :eof
)
if [%reboot_recovery%] == [1]	 set "recovery_fastboot=1"
if [%reboot_system%] == [1]		 set "reboot_fastboot=1"
if [%reboot_bootloader%] == [1]	 set "bootloader_fastboot=1"
goto :eof

:check-codename
echo Checking require codename devices...

for /f "tokens=2 delims=: " %%i in ('fastboot getvar product 2^>^&1 ^| findstr /r /c:"^product:"') do ( set "product=%%i" )
for /f "tokens=2 delims=: " %%i in ('fastboot getvar platform 2^>^&1 ^| findstr /r /c:"^platform:"') do ( set "platform=%%i" )

if [%platform%] == [msm8917] (
	set "devices=mxm1"
	set "devices_codename=X00P"
) else if [%platform%] == [msm8953] (
	set "devices=mxm2"
	set "devices_codename=X01AD"
) else if [%platform%] == [sdm636] (
	set "devices=mpm1"
	set "devices_codename=X00T"
) else if [%platform%] == [sdm660] (
	set "devices=mpm2"
	set "devices_codename=X01BD"
)
if not defined devices_codename (
	echo %errorp%  Your device is not ASUS Zenfone Max Series/Max Pro Seriess.
	set "codename_false=1"
)
goto :eof

:check-unlock
echo Checking the device unlocked bootloader...
set "CURRENT_RESULT=true"
for /f "tokens=4 delims=: " %%i in ('fastboot oem device-info 2^>^&1 ^| findstr /r /c:"Device unlocked:"') do ( set "unlock_result=%%i" )
for /f "tokens=4 delims=: " %%i in ('fastboot oem device-info 2^>^&1 ^| findstr /r /c:"Device critical unlocked:"') do ( set "unlock_critical_result=%%i" )

if [%unlock_result%] EQU [] set "unlock_result=false"
if [%unlock_result%] NEQ [%CURRENT_RESULT%] (
	set "LOCKED=1"
) else if [%unlock_result%] EQU [%CURRENT_RESULT%] (
	set "UNLOCKED=1"
)

if [%unlock_critical_result%] EQU [] set "unlock_critical_result=false"
if [%unlock_critical_result%] NEQ [%CURRENT_RESULT%] (
	set "LOCKED=1"
) else if [%unlock_critical_result%] EQU [%CURRENT_RESULT%] (
	set "UNLOCKED=1"
)

if [%LOCKED%] EQU [1] (
	echo %infop%  Your device locked bootloader.
	echo This script will be unlock bootloader.
	choice /c yn /n /m "Are you ready? [Y/N] "
	if errorlevel 2   goto :eof
	fastboot getvar build-type 2>&1 | findstr build-type > build-type.txt
	fastboot getvar secret-key-opt 2>&1 | findstr secret-key-opt > secret-key-opt.txt
	fastboot oem get_random_partition 2>&1 | findstr bootloader > frp-partition.txt
	for /f "tokens=2 delims=: " %%a in (build-type.txt) do (
        set "buildtype=%%a"
		del /q build-type.txt
    )
	for /f "tokens=2 delims=: " %%k in (secret-key-opt.txt) do (
        set "secret_key=%%k"
        set /p =!secret_key!<nul> %BASEDIR%\tmp\default_key.bin
		del /q secret-key-opt.txt
    )
    for /f "tokens=2 delims=: " %%m in (frp-partition.txt) do (
        set "frp-partition=%%m"
		del /q frp-partition.txt
    )
	if [%buildtype%] == [user] (
		fastboot flash %frp-partition% "%BASEDIR%\tmp\default_key.bin" || (
			echo %errorp%  Failed unlocked.
			goto :eof
		)
		fastboot flashing unlock || (
			echo %errorp%  Failed unlocked.
			goto :eof
		)
		fastboot flashing unlock_critical || (
			echo %errorp%  Failed unlocked.
			goto :eof
    	)
		echo %cautionp%  Unlocked successfully.
	)
) else if [%UNLOCKED%] EQU [1] (
	echo %infop%  Your device already unlocked bootloader.
	choice /c yn /n /m "Do you want to lock bootloader? [Y/N] "
	if errorlevel 2   goto :eof
	fastboot flashing lock || echo %errorp%  Failed locked.
	fastboot flashing lock_critical || echo %errorp%  Failed locked.
	fastboot oem lock_frp || echo %errorp%  Failed locked.
)
goto :eof

:flash-twrp
@echo off
break off
cls
echo.
echo FLASH TWRP
echo ???????????
echo.
echo.
echo    1.^)  Team Win Recovery Project
echo    2.^)  Orange Fox Recovery
echo    3.^)  PitchBlack Recovery Project
echo.
echo    A.^)  Let me choose
echo    Q.^)  Back to main menu
echo.
set choice=
set /p "choice=Select TWRP version: "
echo.
if [%choice%] EQU []  goto flash-twrp
for %%a in (B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
	if [%choice%] == [%%a] goto flash-twrp
)
if [%choice%] LEQ []  goto flash-twrp
for %%a in (4 5 6 7 8 9 0) do (
	if [%choice%] == [%%a]  goto flash-twrp
)
for %%a in (Q q) do (
	if [%choice%] == [%%a]  (
		set "twrp_exit=1"
		goto :eof
	)
)
for %%a in (A a) do (
	if [%choice%] == [%%a]  (
		:type
		set /p "recoveryimg=Type an img file (with directory): "
		if not exist "%recoveryimg%" (
			echo Img file not found.
			goto type
		)
	)
)
if [%choice%] == [3]  (
	if [%devices_codename%] == [X00P] (
		if not exist "%BASEDIR%\recovery\pbrp_X00P.img" (
			wget -O "%BASEDIR%\tmp\pbrp.zip" https://master.dl.sourceforge.net/project/pbrp/X00P/PBRP-X00P-3.0.0-20200804-1432-OFFICIAL.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\pbrp.zip" TWRP\recovery.img
			move "%BASEDIR%\recovery\TWRP\recovery.img" "%BASEDIR%\recovery\pbrp_X00P.img"
			del /sq "%BASEDIR%\recovery\TWRP"
			del /q "%BASEDIR%\tmp\pbrp.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\pbrp_X00P.img"
	) else if [%devices_codename%] == [X01AD] (
		if not exist "%BASEDIR%\recovery\pbrp_X01AD.img" (
			wget -O "%BASEDIR%\tmp\pbrp.zip" https://master.dl.sourceforge.net/project/pbrp/X01AD/PitchBlack-X01AD-2.9.0-20190605-1123-OFFICIAL.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\pbrp.zip" TWRP\recovery.img
			move "%BASEDIR%\recovery\TWRP\recovery.img" "%BASEDIR%\recovery\pbrp_X01AD.img"
			del /sq "%BASEDIR%\recovery\TWRP"
			del /q "%BASEDIR%\tmp\pbrp.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\pbrp_X01AD.img"
	) else if [%devices_codename%] == [X00T] (
		if not exist "%BASEDIR%\recovery\pbrp_X00T.img" (
			wget -O "%BASEDIR%\tmp\pbrp.zip" https://tenet.dl.sourceforge.net/project/pbrp/X00T/PBRP-X00T-3.0.0-20200730-0649-OFFICIAL.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\pbrp.zip" TWRP\recovery.img
			move "%BASEDIR%\recovery\TWRP\recovery.img" "%BASEDIR%\recovery\pbrp_X00T.img"
			del /sq "%BASEDIR%\recovery\TWRP"
			del /q "%BASEDIR%\tmp\pbrp.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\pbrp_X00T.img"
	) else if [%devices_codename%] == [X01BD] (
		if not exist "%BASEDIR%\recovery\pbrp_X01BD.img" (
			wget -O "%BASEDIR%\tmp\pbrp.zip" https://tenet.dl.sourceforge.net/project/pbrp/X01BD/PBRP-X01BD-3.0.0-20200730-0914-OFFICIAL.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\pbrp.zip" TWRP\recovery.img
			move "%BASEDIR%\recovery\TWRP\recovery.img" "%BASEDIR%\recovery\pbrp_X01BD.img"
			del /sq "%BASEDIR%\recovery\TWRP"
			del /q "%BASEDIR%\tmp\pbrp.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\pbrp_X01BD.img"
	)
if [%choice%] == [2]  (
	if [%devices_codename%] == [X00P] (
		echo %infop%  OrangeFox for ASUS Zenfone Max M1 not available.
		pause
		goto flash-twrp
	) else if [%devices_codename%] == [X01AD] (
		if not exist "%BASEDIR%\recovery\ofox_X01AD.img" (
			wget -O "%BASEDIR%\tmp\ofox.zip" https://files.orangefox.tech/OrangeFox-Stable/X01AD/OrangeFox-R10.0-8.1-Stable-X01AD.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\ofox.zip" recovery.img
			move "%BASEDIR%\recovery\recovery.img" "%BASEDIR%\recovery\ofox_X01AD.img"
			del /q "%BASEDIR\tmp\ofox.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\ofox_X01AD.img"
	) else if [%devices_codename%] == [X00T] (
		if not exist "%BASEDIR%\recovery\ofox_X00T.img" (
			wget -O "%BASEDIR%\tmp\ofox.zip" https://files.orangefox.tech/OrangeFox-Stable/x00t/OrangeFox-R10.1_7-Stable-X00T.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\ofox.zip" recovery.img
			move "%BASEDIR%\recovery\recovery.img" "%BASEDIR%\recovery\ofox_X00T.img"
			del /q "%BASEDIR\tmp\ofox.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\ofox_X00T.img"
	) else if [%devices_codename%] == [X01BD] (
		if not exist "%BASEDIR%\recovery\ofox_X01BD.img" (
			wget -O "%BASEDIR%\tmp\ofox.zip" https://files.orangefox.tech/OrangeFox-Stable/x01bd/OrangeFox-R10.1_14-Stable-X01BD.zip
			7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\ofox.zip" recovery.img
			move "%BASEDIR%\recovery\recovery.img" "%BASEDIR%\recovery\ofox_X01BD.img"
			del /q "%BASEDIR\tmp\ofox.zip"
		)
		set "recoveryimg=%BASEDIR%\recovery\ofox_X01BD.img"
	)
if [%choice%] == [1]  (
	if [%devices_codename%] == [X00P] (
		if not exist "%BASEDIR%\recovery\twrp_X00P.img" wget -O "%BASEDIR%\recovery\twrp_X00P.img" https://dl.twrp.me/X00P/twrp-3.4.0-0-X00P.img
		set "recoveryimg=%BASEDIR%\recovery\twrp_X00P.img"
	) else if [%devices_codename%] == [X01AD] (
		if not exist "%BASEDIR%\recovery\twrp_X01AD.img" wget -O "%BASEDIR%\recovery\twrp_X01AD.img" https://dl.twrp.me/X01AD/twrp-3.4.0-0-X01AD.img
		set "recoveryimg=%BASEDIR%\recovery\twrp_X01AD.img"
	) else if [%devices_codename%] == [X00T] (
		if not exist "%BASEDIR%\recovery\twrp_X00T.img" wget -O "%BASEDIR%\recovery\twrp_X00T.img" https://ava3.androidfilehost.com/dl/9pvhlHZgD_gyFBl8eWNkWg/1598129017/6006931924117881962/twrp-3.3.1-0-X00T-20190526.img
		set "recoveryimg=%BASEDIR%\recovery\twrp_X00T.img"
	) else if [%devices_codename%] == [X01BD] (
		if not exist "%BASEDIR%\recovery\twrp_X01BD.img" wget -O "%BASEDIR%\recovery\twrp_X01BD.img" https://dl.twrp.me/X01BD/twrp-3.4.0-0-X01BD.img
		set "recoveryimg=%BASEDIR%\recovery\twrp_X01BD.img"
	)
)
fastboot flash recovery "%recoveryimg%" || (
	echo %errorp%  Failed flash TWRP.
	call :end2
	goto :eof
)
echo %infop%  Flash 'recovery' success.
goto :eof

:check-sideload
set no_connection=
eecho %cautionp%  Select ADB Sideload on Recovery menu ^> Advanced, then swipe and automatically flash.
:sideloadloop
adb wait-for-sideload
adb devices 2>&1 | findstr /r /c:"sideload\>" || (
	echo %errorp%  Your device not connected in sideload. Check the driver or reboot recovery again.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		set "no_connection=1"
		call :end2
		goto :eof
	)
	goto sideloadloop
)
goto :eof

:flash-lazy
echo Installing Lazyflasher...
adb sideload "%BASEDIR%\data\decrypt_%devices%.zip"
goto :eof

:flash-cam2api
echo Installing Camera2 API Enabler...
fastboot oem enable_camera_hal3 true || echo %errorp%  Failed written Camera2 API. && goto :eof
echo %infop%  Successfully.
goto :eof

:flash-root
@echo off
break off
cls
echo.
echo INSTALL ROOT
echo ?????????????
echo.
echo    1.^)  SuperSU
echo    2.^)  Magisk
echo.
echo    Q.^)  Back to main menu
echo.
set choice=
set /p "choice=Select TWRP version: "
echo.
if [%choice%] EQU []  goto flash-root
for %%a in (A a B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
	if [%choice%] == [%%a] goto flash-root
)
if [%choice%] LEQ []  goto flash-root
for %%a in (3 4 5 6 7 8 9 0) do (
	if [%choice%] == [%%a]  goto flash-root
)
for %%a in (Q q) do (
	if [%choice%] == [%%a]  (
		set "root_exit=1"
		goto :eof
	)
)
call :check-sideload
if [%choice%] == [2]  (
	if not exist "%BASEDIR%\data\magisk.zip" wget -O "%BASEDIR%\data\magisk.zip" https://github.com/topjohnwu/Magisk/releases/download/v20.3/Magisk-v20.3.zip
	set "rootsel=Magisk"
	set "rootzip=%BASEDIR%\data\magisk.zip"
)
if [%choice%] == [1]  (
	if not exist "%BASEDIR%\data\supersu.zip" wget -O "%BASEDIR%\data\supersu.zip" http://supersuroot.org/downloads/SuperSU-v2.82-201705271822.zip
	set "rootsel=SuperSU"
	set "rootzip=%BASEDIR%\data\supersu.zip"
)
echo Installing %rootsel%...
>nul 2>&1 adb sideload "%rootzip%"
call :end2
goto :eof

:reboot-systemdevices
echo Rebooting...
if [%reboot_fastboot%] == [1]	set "do_reboot_system=fastboot reboot >nul"
if [%reboot_adb%] == [1]		set "do_reboot_system=adb reboot"
%do_reboot_system% || echo %errorp%  Cannot reboot.
goto :eof

:reboot-bootloader
echo Rebooting to bootloader...
if [%bootloader_fastboot%] == [1]	set "do_reboot_bootloader=fastboot reboot bootloader >nul"
if [%bootloader_adb%] == [1]		set "do_reboot_bootloader=adb reboot bootloader"
%do_reboot_bootloader% || echo %errorp%  Cannot reboot to bootloader.
goto :eof

:reboot-recovery
echo Rebooting to recovery...
if [%recovery_fastboot%] == [1]		set "do_reboot_recovery=fastboot oem recovery_and_reboot"
if [%recovery_adb%] == [1]			set "do_reboot_recovery=adb reboot recovery"
%do_reboot_recovery% || echo %errorp%  Cannot reboot to recovery. && set "error=1"
goto :eof


:end1
if exist "%BASEDIR%\bin\adb.exe"  (
	echo Exiting from program...
	echo Closing ADB service...
	>nul 2>&1 adb kill-server
	set "PATH=%ORIG_PATH%"
)
pause
endlocal
cls
color
exit /b
goto endscript

:end2
echo ------------------------------------- END -------------------------------------
pause
exit /b
goto endscript




:dos
echo This program cannot be run in DOS mode.
goto endscript

:winos2
echo This script requires Microsoft Windows NT.
goto endscript

:nt
echo This script requires a newer version of Windows NT.
endlocal

:: END



::
:: COMMENTS
::

::
:: This program was written and created by Faizal Hamzah with the aim of
:: making it easier for users to do the work of modifying Android mobile
:: devices. Facilities of this program, include:
::
::   1.  Check the status bootloader (e.g. Unlock and Lock)
::   2.  Flash custom reecovery/TWRP
::   3.  Flash ASUS Decryption.
::   4.  Enable Camera2 API
::   5.  Flash Root Access
::   6.  Run Terminal Android in PC
::   7.  Switch ADB Connection
::
:: This program is only for those who have a ASUS Zenfone Max series
:: phone (codename: X00P msm8917/X00TD sdm636/X01AD msm8953/X01BD sdm660)
::
:: Special thanks:
:: >  Google - Android
:: >  TWRP team
:: >  Orangefox team
:: >  PitchBlack team
:: >  Magisk team
:: >  XDA
:: >  ASUS Flashing Team
:: >  and the users ASUS Zenfone Max series
::    -  ASUS Zenfone Max M1
::    -  ASUS Zenfone Max Pro M1
::    -  ASUS Zenfone Max M2
:: 	  -  ASUS Zenfone Max Pro M2
::
:: Contact person:
:: > https://api.whatsapp.com/send?phone=6288228419117
:: > https://www.facebook.com/thefirefoxflasher
:: > https://www.instagram.com/thefirefoxflasher_
::

:ENDSCRIPT
@ECHO ON
