:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::	Major.Minor.Revision		::
::::::::::::::::::::::::::::::::::

::#############################################################################
::							#DESCRIPTION#
::
::	SCRIPT STYLE: Interactive
::	Active Directory group search and return a list of users.
::#############################################################################

@Echo Off
@SETLOCAL enableextensions
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET Name=AD Group Member Fetcher
SET Version=2.1.0
SET BUILD=2019-11-27-1453
Title %Name% Version: %Version%
Prompt DS$G
color 8F

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
:: All User variables are set within here.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Defaults
::	uses user profile location for logs
SET LogPath=%USERPROFILE%\Documents\Logs
SET Log=AD_Group_Query.log

:: Advanced Settings
:: 
:: Network Location for dependency binary files
SET "NET_BIN_REPO=\\evergreen.edu\netlogon\SciComp\Assets\bin"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	Runnnig Defaults that is not recommended to change in script, rather
::		change during commandlet run time, using menu system.
SET DC=%LOGONSERVER:~2%
SET cUSERNAME=%USERNAME%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: System Variables
SET Counter=0
SET kpLog=Yes
SET nwLine=^& Echo
SET sLimit=500
SET du=1
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Dependency Checks
SET PREREQUISITE_STATUS=1
IF NOT EXIST %SYSTEMROOT%\System32\DSQUERY.EXE SET PREREQUISITE_STATUS=0
IF NOT EXIST %SYSTEMROOT%\System32\DSGET.EXE SET PREREQUISITE_STATUS=0
IF %PREREQUISITE_STATUS% EQU 0 GoTo errDep

:: Is domain user or local user?
whoami /UPN || FOR /F "tokens=1-2 delims=\" %%a IN ('whoami') Do SET domain=%%a && SET du=0 && GoTo err0du
FOR /F "tokens=1-2 delims=^@" %%a IN ('whoami /UPN') Do SET domain=%%b

:: Start session and write to log
:wLog
IF NOT EXIST %LogPath% mkdir %LogPath% || GoTo errRWMD
Echo Start Session >> %LogPath%\%Log% || GoTo errRWMD
Echo %DATE% %TIME% >> %LogPath%\%Log%
Echo Script Version: %Version% >> %LogPath%\%Log%
Echo Script Build: %BUILD% >> %LogPath%\%Log%
hostname >> %LogPath%\%Log%
Echo %USERNAME% >> %LogPath%\%Log%
Echo Domain Controller: %DC% >> %LogPath%\%Log%
Echo. >> %LogPath%\%Log%
GoTo Menu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:Menu
Color 7
mode con:cols=55 lines=40
Cls
Echo ******************************************************
Echo Location: Main Menu             
Echo.   
Echo Current settings
Echo _____________________
Echo.
Echo  Log File Path: %LogPath%
Echo  Log File Name: %Log%
Echo  Keep Log at End: %kpLog%
Echo.
Echo  Running Account: %cUSERNAME%
Echo  Domain: %domain%
Echo  Domain Controller: %DC%
Echo ******************************************************
Echo.
Echo.
Echo Choose an action to perform from the list:
Echo.
Echo [1] Search
Echo [2] Settings
Echo [3] Log File
Echo [4] Exit
Echo.
Choice /c 1234
Echo.
::
If ERRORLevel 4 GoTo EOF
If ERRORLevel 3 GoTo Log
If ERRORLevel 2 GoTo Uset
If ERRORLevel 1 GoTo ChooS
Echo.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Uset
Color 7
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Settings         
Echo.
Echo.
Echo Current Settings:
Echo.
Echo  Log File Path: %LogPath%
Echo  Log File Name: %Log%
Echo  Keep Log at End: %kpLog%
Echo.
Echo  Running Account: %cUSERNAME%
Echo  Domain Controller: %DC%
Echo  Domain: %domain%
Echo.
Echo ******************************************************
Echo.
Echo.
Echo Choose an action from the list:
Echo.
Echo.
Echo [1] Change Log Settings
Echo [2] Clear Log
Echo [3] Choose Domain Controller
Echo [4] Advanced Settings
Echo [5] Main menu
Echo.
Echo.
Choice /c 12345
Echo.
::
If ERRORLevel 5 GoTo Menu
If ERRORLevel 4 GoTo uSetDU
If ERRORLevel 3 GoTo uSetDC
If ERRORLevel 2 GoTo uSetCl
If ERRORLevel 1 GoTo UsetLg
Echo.
::
:uSetDC
IF NOT DEFINED cUSERNAME GoTo uSetDU
IF NOT DEFINED PASSWORD GoTo uSetDU
IF NOT DEFINED Domain GoTo uSetDU
Color 7
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Settings [Domain Controller]        
Echo.
Echo.
Echo  Domain Controller: %DC%
Echo ******************************************************
Echo.
Echo.
Echo List of available Domain Controllers:
Echo.
dsquery server -o rdn -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD%
IF %ERRORLEVEL% NEQ 0 GoTo uSetDU
Echo.
Echo.
SET /P DC=Domain Controller:
Echo.
::?Maybe change this to a PING check?
@ping %DC% || (SET DC=%LOGONSERVER:~2%) && GoTo uSetDC
Echo.
Echo Success!
Echo. 
Timeout/t 30
GoTo uSet
::
:uSetCl
Color 0E
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Settings [Clear Log]        
Echo.
Echo.
Echo Log File: %LogPath%\%Log%
Echo ******************************************************
Echo.
Echo.
Echo **************************************************
Echo  !WARNING! !WARNING! !WARNING! !WARNING! !WARNING!
Echo **************************************************
Echo.
Echo.
Echo Are you sure you want to delete the log file?
Echo A new log file will be created with the next search.
Echo.
Echo.
Choice /c YN /m "[Y]es or [N]o"
Echo.
If ERRORLevel 2 GoTo uSet
If ERRORLevel 1 taskkill /f /fi "Windowtitle eq %Log% - Notepad" & Del /q %LogPath%\%Log% && Echo Success! & Echo Log file deleted!
Echo.
Timeout/t 30
GoTo wLog
::
:uSetLg
Color 7
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Settings [Loging]        
Echo.
Echo.
Echo Current Settings:
Echo.
Echo  Log File Path: %LogPath%
Echo  Log File Name: %Log%
Echo  Keep Log at End: %kpLog%
Echo.
Echo ******************************************************
Echo.
Echo.
Echo  Instructions
Echo ______________
Echo.
Echo If no change is desired,
Echo just hit enter and leave blank.
Echo.
SET /p LogPath=Log Path:
Echo.
SET /p Log=Log Name:AD_Group_Query.txt
Echo.
:Sub1
Echo Yes or No
SET /P kpLog=Keep Log:
IF %kpLog%==yes SET kpLog=Yes
IF %kpLog%==YES SET kpLog=Yes
IF %kpLog%==no SET kpLog=No
IF %kpLog%==NO SET kpLog=No
::
:: ERROR CHECKING
IF NOT EXIST %LogPath% mkdir %LogPath% || Echo Log path not valid and/or file name not valid. Back to default!
IF NOT EXIST %LogPath% SET LogPath=%APPDATA%\Logs
Echo.
Timeout/t 30
IF NOT EXIST %LogPath% GoTo Uset
::
GoTo uSet
::
:uSetDU
Color 7
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Settings [Advanced Settings]        
Echo.
Echo.
Echo Current Settings:
Echo.
Echo User: %cUSERNAME%
Echo Domain: %domain%
Echo Domain Controller: %DC%
Echo Query limit: %sLimit%
Echo.
Echo ******************************************************
Echo.
Echo.
Echo INSTRUCTIONS:
Echo.
Echo Configure the query limit.
Echo Use only numeric numbers 0-9.
Echo.
Echo Configure domain credentials (UN ^& PW);
Echo leave blank to not change settings;
Echo note that the connection test to the DC will fail since PW will be blank.
Echo.
:sublim
SET /p sLimit=Query limit:
Echo %sLimit% | findstr /R [a-z]
IF %ERRORLEVEL% EQU 0 SET sLimit=100 & GoTo errlim
Echo.
SET /p cUSERNAME=User name:
Echo.
SET /P Password=User password:
Echo.
SET /P Domain=Domain:
SET strDomain=%Domain%
Echo %Domain% | findStr /l "."
IF %ERRORLEVEL% NEQ 0 FOR /F "tokens=1-2 delims=^@" %%a IN ('whoami /UPN') Do SET domain=%%b & GoTo errVdn
Echo.
Echo.
dsquery server -o rdn -d %domain% -u %cUSERNAME% -p %PASSWORD% || Goto errSdu
Echo.
:Uset0DC
SET /P DC=Domain Controller:
Echo.
@PING %DC%
IF %ERRORLEVEL% GEQ 1 Echo DC [ICMP] check failed! && Echo. && GoTo Uset0DC
Echo.
Echo.
Echo DC check successful!
Echo.
Echo.
Timeout/t 120
GoTo wLog
::
:: Function: Choose which search to do based on default Windows authentication or custom settings.
:ChooS
cls
IF %du%==0 (GoTo aSearch) ELSE (GoTo Search)
IF NOT ERRORLEVEL 0 Echo Choose search function did not work!
Color 8F
Echo.
Timeout/t 60
GoTo uSetDU
::
:Search
IF %PREREQUISITE_STATUS% EQU 0 GoTo errDep
Color 0A
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Search           
Echo.
Echo.
Echo Query limit: %sLimit%
Echo Last Group Searched: %adgroup.n%
Echo Current search count: %COUNTER%
Echo ******************************************************
Echo.
:: Group to look for
Echo INSTRUCTIONS:
Echo -------------------
Echo Wildcard (*) can be used to search;
Echo example: mygroup*, my*, or *my*, etc.
Echo.
Echo Just type the name of the AD group
Echo without any quotes (NO QUOTES!)
Echo.
SET /p adgroup.n=Group to search:
SET adgroup="%adgroup.n%"

IF NOT EXIST %LogPath% mkdir %LogPath% || GoTo errRWMD
mode con:cols=100 lines=40
Echo Groups returned:
dsquery group domainroot -o rdn -name %adgroup% -s %DC% -limit %sLimit%
Echo New search >> %LogPath%\%Log%
Echo %Date% %Time% >> %LogPath%\%Log%
Echo DC searched: %DC% >> %LogPath%\%Log%
Echo AD Group searched: %adgroup% >> %LogPath%\%Log%
SET "SEARCH_RESULT="
IF EXIST "%TEMP%\var_ADGS_Result.txt" DEL /Q /F "%TEMP%\var_ADGS_Result.txt"
dsquery group domainroot -o rdn -name %adgroup% -s %DC% -limit %sLimit% | FINDSTR /I /R /C:".%adgroup%" > %TEMP%\var_ADGS_Result.txt
SET /P SEARCH_RESULT= < %TEMP%\var_ADGS_Result.txt
IF NOT DEFINED SEARCH_RESULT (SET SEARCH_RESULT=0) ELSE (SET SEARCH_RESULT=1)
ECHO Search Result: %SEARCH_RESULT% >> %LogPath%\%Log%
echo.
IF %SEARCH_RESULT% EQU 0 (GoTo errSR) ELSE ECHO Processing...
echo.
FOR /F "tokens=3 delims= " %%M IN ('FIND /I /C """" "%TEMP%\var_ADGS_Result.txt"') DO ECHO %%M > "%TEMP%\var_ADGS_Count.txt"
SET /P GROUP_COUNT= < "%TEMP%\var_ADGS_Count.txt"
echo Number of groups: %GROUP_COUNT%
echo.
echo Number of groups: %GROUP_COUNT% >> %LogPath%\%Log%
Echo Groups returned: >> %LogPath%\%Log%
dsquery group domainroot -o rdn -name %adgroup% -s %DC% -limit %sLimit% >> %LogPath%\%Log%
ECHO. >> %LogPath%\%Log%
Echo Groups CN: >> %LogPath%\%Log%
FOR /F "delims=" %%P IN ('DSQUERY GROUP -name %adgroup% -limit %sLimit%') DO (ECHO %%P >> %LogPath%\%Log%) & (ECHO %%P | dsget group -samid >> %LogPath%\%Log%) & (ECHO %%P | dsget group -members -expand 2> nul | dsget user -upn -ln -fn -samid -display 2> nul >> %LogPath%\%Log%) & echo. >> %LogPath%\%Log%
FOR /F "delims=" %%P IN ('DSQUERY GROUP -name %adgroup% -limit %sLimit%') DO (ECHO %%P) & (ECHO %%P | dsget group -samid) & ECHO %%P | dsget group -members -expand 2> nul | dsget user -upn -ln -fn -samid -display 2> nul
echo.
Echo.
Echo.
Echo For large record sets, it easier to read the logfile; %nwLine% it's suggested to open the log file by %nwLine% selecting "Log" from the Menu or opening it manually.
Echo. 
Echo Log file directory path: %LogPath% 
Echo.
:: Don't remove this pause, it's part of console
Pause
GoTo fCntr1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:aSearch
IF %PREREQUISITE_STATUS% EQU 0 GoTo errDep
Color 0A
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Advanced Search           
Echo Not a domain computer and/or user
Echo.
Echo Query limit: %sLimit%
Echo.
Echo User: %cUSERNAME%
Echo Domain: %domain%
Echo Domain Controller: %DC%
Echo.
Echo Last Group Searched: %adgroup.n%
Echo Current search count: %COUNTER%
Echo.
Echo ******************************************************
Echo.
IF NOT DEFINED cUSERNAME GoTo uSetDU
IF NOT DEFINED PASSWORD GoTo uSetDU
IF NOT DEFINED Domain GoTo uSetDU
:: Group to look for
Echo INSTRUCTIONS:
Echo -------------------
Echo Wildcard (*) can be used to search;
Echo example: mygroup*, my*, or *my*, etc.
Echo.
Echo Just type the name of the AD group
Echo without any quotes (NO QUOTES!)
Echo.
SET /p adgroup.n=Group to search:
SET adgroup="%adgroup.n%"

IF NOT EXIST %LogPath% mkdir %LogPath% || GoTo errRWMD
mode con:cols=100 lines=40
Echo Groups returned:
dsquery group domainroot -o rdn -name %adgroup% -d %DOMAIN% -limit %sLimit% -u %cUSERNAME% -p %PASSWORD%
Echo New search >> %LogPath%\%Log%
Echo %Date% %Time% >> %LogPath%\%Log%
Echo DC searched: %DC% >> %LogPath%\%Log%
Echo AD Group searched: %adgroup% >> %LogPath%\%Log%
SET "SEARCH_RESULT="
IF EXIST "%TEMP%\var_ADGS_Result.txt" DEL /Q /F "%TEMP%\var_ADGS_Result.txt"
dsquery group domainroot -o rdn -name %adgroup% -limit %sLimit% -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% | FINDSTR /I /R /C:".%adgroup%" > %TEMP%\var_ADGS_Result.txt
SET /P SEARCH_RESULT= < %TEMP%\var_ADGS_Result.txt
IF NOT DEFINED SEARCH_RESULT (SET SEARCH_RESULT=0) ELSE (SET SEARCH_RESULT=1)
ECHO Search Result: %SEARCH_RESULT% >> %LogPath%\%Log%
echo.
IF %SEARCH_RESULT% EQU 0 (GoTo errSR) ELSE ECHO Processing...
echo.
FOR /F "tokens=3 delims= " %%M IN ('FIND /I /C """" "%TEMP%\var_ADGS_Result.txt"') DO ECHO %%M > "%TEMP%\var_ADGS_Count.txt"
SET /P GROUP_COUNT= < "%TEMP%\var_ADGS_Count.txt"
echo Number of groups: %GROUP_COUNT%
echo Number of groups: %GROUP_COUNT% >> %LogPath%\%Log%
Echo Groups returned: >> %LogPath%\%Log%
dsquery group domainroot -o rdn -name %adgroup% -limit %sLimit% -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% >> %LogPath%\%Log%
ECHO. >> %LogPath%\%Log%
Echo Groups CN: >> %LogPath%\%Log%
FOR /F "delims=" %%P IN ('DSQUERY GROUP -name %adgroup% -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% -limit %sLimit%') DO (ECHO %%P >> %LogPath%\%Log%) & (ECHO %%P | dsget group -samid -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% >> %LogPath%\%Log%) & (ECHO %%P | dsget group -members -expand -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% 2> nul | dsget user -upn -ln -fn -samid -display -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% 2> nul >> %LogPath%\%Log%) & echo. >> %LogPath%\%Log%
FOR /F "delims=" %%P IN ('DSQUERY GROUP -name %adgroup% -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% -limit %sLimit%') DO (ECHO %%P) & (ECHO %%P | dsget group -samid -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD%) & ECHO %%P | dsget group -members -expand -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% 2> nul | dsget user -upn -ln -fn -samid -display -d %DOMAIN% -u %cUSERNAME% -p %PASSWORD% 2> nul
echo.
Echo.
Echo.
Echo For large record sets, it easier to read the logfile; %nwLine% it's suggested to open the log file by %nwLine% selecting "Log" from the Menu or opening it manually.
Echo. 
Echo Log file directory path: %LogPath% 
Echo.
Pause
GoTo fCntr1
::
:Log
Color 7
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Log           
Echo.
Echo  Log File Path: %LogPath%
Echo  Log File Name: %Log%
Echo  Keep Log at End: %kpLog%
Echo ******************************************************
IF NOT EXIST %LogPath%\%Log% GoTo errLog
taskkill /f /fi "Windowtitle eq %Log% - Notepad"
Echo.
Echo.
Echo log file will stay open.
Echo.
IF EXIST %windir%\system32\notepad.exe (start notepad.exe %LogPath%\%Log%) ELSE (start %LogPath%\%Log%)
GoTo Menu
::
:: FUNCTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:fCntr1
SET /A Counter+=1
GoTo Menu
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: ERRORS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:errLog
cls
Color C
Echo.
Echo !!ERROR!!
Echo.
Echo.
Echo No log file exists yet!
Echo.
Echo Try again once a log file has been created.
Echo.
Timeout/t 30
GoTo Menu
::
:errRWMD
cls
Color C
Echo.
Echo !ERROR!
Echo.
Echo.
Echo It appears your account [%cUSERNAME%] doesn't have proper permissions to the Log Path.
Echo.
Echo Go to settings and try another Log Path.
Echo.
Timeout/t 60
GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:errGrp
cls
Color C
Echo !!ERROR!! !!ERROR!! !!ERROR!!
Echo.
Echo.
Echo AD Group searched: %adgroup.n%
Echo.
Echo Reasons for a failed user membership search:
Echo _____________________________
Echo.
Echo -No such group exists;
Echo -Group has no members, empty group;
Echo -Group has nested group membership (group within a group);
Echo -
Echo.
Echo Note that the log file will still have a list
Echo of returned groups.
Echo.
Echo.
Echo Try again.
echo.
Timeout /t 60
GoTo fCntr1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:errSR
cls
color 6E
ECHO.
ECHO.
ECHO !!NO GROUPS FOUND!!
ECHO.
ECHO.
Echo Try again.
echo.
ECHO __________________________________
echo.
Echo Try using the wildcard:
echo.
echo  *GroupName
echo  Group*Name
echo  GroupName*
echo  *GroupName*
echo.
echo.
ECHO No group found with search term %adgroup%! >> %LogPath%\%Log%
ECHO. >> %LogPath%\%Log%
Timeout /t 60
GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:errDep
cls
mode con:cols=55 lines=40
Color C
SET PREREQUISITE_STATUS=0
Echo  !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!!
Echo.
Echo.
Echo It appears this computer [%COMPUTERNAME%] doesn't have
Echo the required binaries to run this tool:
Echo.
Echo DSQUERY
Echo DSGET
Echo.
Echo Try installing "Remote Server Admin Tool --> AD DS and AD LDS Tools".
Echo Instructions for doing this:
Echo https://support.microsoft.com/en-us/help/2693643/remote-server-administration-tools-rsat-for-windows-operating-systems
Echo.
echo Install RSAT? ([Yes], [No])
set /p INSTALL_DEPENDENCY=[Y]es or [N]o:
IF NOT DEFINED INSTALL_DEPENDENCY GoTo skip skiperrDep
IF "%INSTALL_DEPENDENCY%"=="y" SET INSTALL_DEPENDENCY=Y
IF "%INSTALL_DEPENDENCY%"=="Y" GoTo subIDEP  
Echo.
:skiperrDep
Timeout /t 120
GoTo EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:err0du
cls
mode con:cols=55 lines=40
Color C
Echo  !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!!
Echo.
Echo.
Echo Current User: %cUSERNAME%
Echo Current Local Domain: %domain%
Echo. 
Echo It appears the account you are logged in with is not
Echo a domain account. It's recommended that you configure
Echo a domain account in order to provide LDAP
Echo authentication to Active Directory as it's unlikely
Echo that annonymous access is permitted.
Echo.
Echo.
Timeout /t 120
GoTo uSetDU
::
:errSdu
cls
mode con:cols=55 lines=40
Color C
Echo  !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!!
Echo.
Echo.
Echo Current User: %cUSERNAME%
Echo Current Domain: %domain%
Echo.
Echo.
Echo The account and domain configured did not 
Echo successfully connect to the domain controller.
Echo Make sure password is correct.
Echo Try configuring again...
Timeout /t 90
GoTo Uset
::
:errVdn
:: validation failed for domain name
cls
mode con:cols=55 lines=40
Color C
Echo  !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!!
Echo.
Echo.
Echo Domain name entered: %strdomain%
Echo Default domain: %Domain%
Echo.
Echo.
Echo The domain name entered does not appear
Echo to be valid. Valid domian names look like this:
Echo domain.root
Echo.
Echo Try configuring again...
Timeout /t 90
GoTo uSetDU
::
:errlim
:: search limit is not a number
cls
mode con:cols=55 lines=40
Color C
Echo.
Echo  !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!! !!ERROR!!
Echo.
Echo.
Echo Default search limit: %sLimit%
Echo.
Echo.
Echo The search limit contains invalid input of
Echo non-numeric characters. Must be numeric only.
Echo.
Echo Try configuring again...
Timeout /t 90
Color 7
mode con:cols=55 lines=40
cls
Echo ******************************************************
Echo Location: Settings [Advanced Settings]        
Echo.
Echo.
Echo Current Settings:
Echo.
Echo User: %cUSERNAME%
Echo Domain: %domain%
Echo Domain Controller: %DC%
Echo Query limit: %sLimit%
Echo.
Echo ******************************************************
GoTo sublim
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: SUBROUTINES

:: Sub-routine install DS dependency
:subIDEP
Cls
mode con:cols=68 lines=40
Color 2F
ECHO Going to try to install RSAT (Remote Server Administration Tools)...
echo.
:: Check if running with Administrative Privilege
echo Checking if running as an administrator...
openfiles.exe 2>nul 1>nul
SET ADMIN_STATUS=%ERRORLEVEL%
IF %ADMIN_STATUS% EQU 0 GoTo skipASE
echo.
Color C
ECHO Not running as an administrator!
Echo Run %Name% as an administrator!
SET PREREQUISITE_STATUS=0
echo.
IF %ADMIN_STATUS% GTR 0 PAUSE
IF %ADMIN_STATUS% GTR 0 GoTo skipsubIDep
:skipASE
DISM /online /get-capabilities | FIND /I "RSAT.ActiveDirectory"
FOR /F "tokens=3 delims=: " %%P IN ('DISM /online /get-capabilities ^| FIND /I "RSAT.ActiveDirectory"') DO DISM /Online /add-capability /CapabilityName:%%P
SET DISM_STATUS=%ERRORLEVEL%
echo DISM_STATUS:%DISM_STATUS%
IF %DISM_STATUS% EQU 0 SET PREREQUISITE_STATUS=1
echo.
PAUSE
echo.
:skipsubIDep
GoTo Menu
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:EOF
IF %kpLog%==No (IF EXIST %LogPath%\%Log% Del /q %LogPath%\%Log%)
IF EXIST %LogPath%\%Log% Echo End Session >> %LogPath%\%Log%
IF EXIST %LogPath%\%Log% Echo. >> %LogPath%\%Log%
cls
mode con:cols=55 lines=25
COLOR 0B
Echo.
ECHO Developed by:
ECHO David Geeraerts {dgeeraerts.evergreen@gmail.com}
ECHO.
ECHO.
Echo.
ECHO Contributors:
ECHO.
Echo.
Echo.
ECHO.
ECHO.
ECHO Copyleft License
ECHO GNU GPL (General Public License)
ECHO https://www.gnu.org/licenses/gpl-3.0.en.html
Echo.
Timeout /T 30
ENDLOCAL
Exit