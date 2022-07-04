@echo off
mode con lines=30 & color 8A
Title  CrefoBackup

rem ################################################### VN. 1.0.0.1 28.09.2018 #######################################################
 echo  ____________________________________ 
 echo /    Starting CrefoBackup  NOW!      \
 echo /____________________________________\
 
rem ## mout fileserver LE\install on mount X
 echo #########  mount Net-Share X  ##########
net use X: \\svlefi01\install

rem ## set Vars
set CB=crefobackup_%date:~0,2%%date:~3,2%%date:~6,4%.bak
set SPFAD=X:\CrefoBackup\%CB%
set CPFAD=C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn

set SERVER=\\svlefi01\install\CrefoBackup\%CB%
 
rem ## run backup from DATABASE
 echo ######### Run DATABASE Backup ##########
 
X:
cd X:\CrefoBackup
"C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\SQLCMD.EXE" -Q "BACKUP DATABASE CREFO TO DISK = '%SERVER%';" -E -S localhost
rem "%CPFAD%\SQLCMD.EXE" -Q "BACKUP DATABASE CREFO TO DISK = '%SPFAD%';" -E -S localhost
 echo ######### End DATABASE Backup ##########
timeout 2 > NUL

rem ## del all .bak Files only
 echo ######### Delete old Backups  ##########
X:
cd X:\CrefoBackup
for /f "skip=2 delims=" %%F in ('dir crefobackup_*.bak /B /O-D /A-D') do del "%%F"
 echo ######### Backups cleaned up  ##########
timeout 2 > NUL

rem ## delete netshare server LE\install from mount X
 echo #########  del Net-Share X    ##########
timeout 2 > NUL
net use X: /delete /yes

 echo  ____________________________________ 
 echo /     Ending CrefoBackup NOW!        \
 echo /____________________________________\

exit