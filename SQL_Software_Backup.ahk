#SingleInstance,force

;~ ################################################################################################
;~ Main Script
;~ ################################################################################################

Var() ; set all Var´s
Gui_generate() ; Add the GUI
Gui_check_update() ; Change the GUI for the update check
Checking_backup() ; Cheking the File´s if an update is needed
	If TimeDate >= 14 ; Checks if the create date of the old backup is more than 14 days
	{
		Gui_start_Mail() ; Change the GUI to Outlook Start
		Gui_generate_backup() ; Change the GUI to generate backup
		Generate_backup() ; Generating the backup
	}
	else{
		Gui_no_backup() ; Change the GUI to no backup is needed
	}
Exit:
ExitApp

;~ ################################################################################################
;~ Funktion
;~ ################################################################################################

Generate_backup(){
Global
RunAs, LocalHostDatabaseUserAdmin, PWD, Domain-name
RunWait, %CreateBackup%, , Hide UseErrorLevel
if ErrorLevel = ERROR
	{
		ERRORLOG = %ErrorLevel%
		Checking_last_backup() ; Cheking the last backup
		Body_error() ; Generates the body for the Email
		Gui_update_email() ; Change the GUI to Email gets sended
		Send_mail() ; send the Email
	}
	else
	{
		Checking_last_backup() ; Cheking the last backup
		Body_ok() ; Generates the body for the Email
		Gui_update_email() ; Change the GUI to Email gets sended
		Send_mail() ; send the Email
	}
}

Checking_backup(){
Global
Loop, %Source%
{
     FileGetTime, Time, %A_LoopFileFullPath%, C
     If (Time > Time_Orig)
     {
          Time_Orig := Time
          File := A_LoopFileName
		  Created := A_LoopFileTimeCreated
     }
}
FormatTime, TimeDate,, yyyyMMddHHmmss
EnvSub, TimeDate, %Created%, Days
}

Checking_last_backup(){
Global
Loop, %BackupPath%\*
	{
	If ( A_LoopFileTimeModified >= Time ){
		Time := A_LoopFileTimeModified
		File := A_LoopFileLongPath
		Size := A_LoopFileSizeMB
		}
	}
}

;~ ################################################################################################
;~ Gui
;~ ################################################################################################

Gui_generate(){
Global
Gui, +AlwaysOnTop
Gui, Show, w220 h150, SoftwareName_Backup
Gui, Margin, 20, 15
Gui, Font, s8 Bold
Gui, Add,Text,vCrefoText x20 y15 w180 h25, SoftwareName_Backup
Gui, Add, Progress, w300 h20 vCREFOPROGRESS
Gui, Show, AutoSize
sleep,300
}

Gui_check_update(){
Global
GuiControl, Text, CrefoText , Checking if SoftwareName_Backup is to old
guicontrol,, CREFOPROGRESS, +20
sleep, 150
}

Gui_start_Mail(){
Global
GuiControl, Text, CrefoText , Startig Mail
guicontrol,, CREFOPROGRESS, +20
sleep, 150
}

Gui_generate_backup(){
Global
GuiControl, Text, CrefoText , Creating new SoftwareName_Backup
guicontrol,, CREFOPROGRESS, +20
sleep, 150
}

Gui_no_backup(){
Global
GuiControl, Text, CrefoText , SoftwareName_Backup is not needed
Guicontrol,, CREFOPROGRESS, +100
sleep,150
}

Gui_update_email(){
Global
GuiControl, Text, CrefoText , EMail gets send to Admins
guicontrol,, CREFOPROGRESS, +20
sleep, 150
}

;~ ################################################################################################
;~ Email
;~ ################################################################################################

Body_ok(){
Global
	body=
	(
	A new SoftwareName_Backup got created! The new backup go created on: %Time% - %File% - %Size% MBSoftwareName_Backup successful created!"
	)
	sub= "--SoftwareName!"
}

Body_error(){
Global
	body=
	(
	SoftwareName_Backup couldnt get created! The last backup was created on: %Time% - %File% - %Size% MB SoftwareName_Backup - %ERRORLOG%
	)
	sub= "--SoftwareName ERROR!"
}

Send_mail(){
Global
	regexBody:=RegExReplace(body,"\x20{1,}","_")
	regexSub:=RegExReplace(sub,"\x20{1,}","_")
Run, powershell.exe -Command "Send-MailMessage -To %To1% -Subject %regexSub% -Body %regexBody% -SmtpServer %SmtpServer% -From %From%" ,, hide
Run, powershell.exe -Command "Send-MailMessage -To %To2% -Subject %regexSub% -Body %regexBody% -SmtpServer %SmtpServer% -From %From%" ,, hide
Run, powershell.exe -Command "Send-MailMessage -To %To3% -Subject %regexSub% -Body %regexBody% -SmtpServer %SmtpServer% -From %From%" ,, hide
}

;~ ################################################################################################
;~ VAR
;~ ################################################################################################

Var(){
Global
VNR := "3.0.0.1"
CR := "@Hol"
SUP := "m.hol@domain.xyz"
line := "----------------------------------------------------------------------------------"
From := "System@SoftwareName_Backup.backup"
SmtpServer := "Smtp-server-adress"
To1 := "Admin1-Mail@domain.xyz"
To2 := "Admin2-Mail@domain.xyz"
To3 := "Admin3-Mail@domain.xyz"
Source = \\UNC-SERVER-Path\SoftwareName_*.bak
CreateBackup = \\UNC-SERVER-Path\Folder\CrefoBackup\SoftwareName.bat
BackupPath = \\UNC-SERVER-Path\Folder\SoftwareName
}
