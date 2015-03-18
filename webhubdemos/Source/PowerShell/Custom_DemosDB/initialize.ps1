# db.demos.href.com

# use this file as Custom\Initialize.ps1 together with 
# these files in WebHub_Appliance_PS   SVN REPO URL: https://svn.code.sf.net/p/webhubapplianceps/code/trunk/PowerShell/WebHub_Appliance_PS

# http://blogs.msdn.com/b/powershell/archive/2006/12/24/boolean-values-and-operators.aspx

# Enter 1 for True, 0 for False.

$Global:FlagDisableUAC = 1;

$Global:FolderInstallers = 'D:\Downloads\';		# or perhaps D:\Installers\
$Global:FolderZM = 'D:\AppsData\ZaphodsMap\';

# These flags determine whether particular software packages are installed
$Global:FlagInstallBDE = 1;				# BDE Runtime
$Global:FlagInstallEditPadPro = 0;			# Just Great Software: development editor EditPad Pro has WebHub plug-ins
$Global:FlagInstallExamDiff = 1;			# free trial of ExamDiff Pro
$Global:FlagInstallFileZillaServer = 1;			# open source ftp server
$Global:FlagInstallFirebird = 0;			# open source SQL server
$Global:FlagInstallGoogleChrome = 1;
$Global:FlagInstallIB_SQL = 1;				# admin utility for Interbase and Firebird SQL server
$Global:FlagInstallRemBoot = 0;				# Remote Reboot utility from HREF Tools Corp.
$Global:FlagInstallTortoiseSVN = 1;			# Tortoise Subversion client (gui)
$Global:FlagInstallWebHubRuntime = 1;			# WebHub Runtime Setup from HREF Tools Corp.
$Global:FlagInstallWebHubDemos = 1;			# open-source WebHubDemos project from HREF Tools Corp.
$Global:FlagInstallWindowsAdminRename = 0;		# Rename the Administrator account
$Global:FlagInstallWindowsAutoLogon = 0;		# SysInternals AutoLogon feature

$Global:FlagInstallRemoteDesktop = 0;			# true/false Enable Remote Desktop Protocol "RDP" connections
$Global:RemoteDesktopPort = 3389;			# change RDP port here

$Global:WindowsUpdateTime = "1:00"			# GMT!! This time on Sunday for Windows Updates "Maintenance Window"

$Global:ZMGlobalContext = 'DEMOS';
$Global:WindowsAdministratorName = 'Administrator';

$Global:CSConsole = "D:\Apps\HREFTools\MiscUtil\CodeSiteConsole.exe"	# command-line utility to write to Raize CodeSite log

# Relevant when installing WebHub Runtime
$Global:FolderRootForWHDataFolders = 'D:\whData\';
$Global:FolderWebHubData = 'D:\whData\whConfig\';
$Global:WebHubVersion = '3.224';			# WebHub Runtime version
$Global:WebHubUseDefaultLiteLicense = 1;                # if 0, you should provide your own WHLicense.xml 

# no need to re-run the CodeSite Dispatcher. 
if (Test-Path $Global:CSConsole) {
	Start-Process $Global:CSConsole -ArgumentList ('/note "Custom init for ZaphodsMap Context ' + $Global:ZMGlobalContext + '"') -NoNewWindow -Wait
}

