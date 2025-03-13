Unicode True

!include MUI2.nsh
!include x64.nsh
!include servicelib.nsh

Name "PawnIO"

!define VERSION 1.0.1.0

VIProductVersion ${VERSION}

VIAddVersionKey "ProductName" "PawnIO"
VIAddVersionKey "CompanyName" "namazso"
VIAddVersionKey "LegalCopyright" "${U+A9} 2025 namazso <admin@namazso.eu>"
VIAddVersionKey "FileDescription" "PawnIO Installer"
VIAddVersionKey "FileVersion" "${VERSION}"

!ifdef UNRESTRICTED
    VIAddVersionKey "Comments" "Unrestricted edition"
    OutFile "PawnIO_Unrestricted_setup.exe"
    LicenseData LicenseUnrestricted.txt
!else
    OutFile "PawnIO_setup.exe"
    LicenseData LicenseSigned.txt
!endif

RequestExecutionLevel admin
InstallDir $PROGRAMFILES64\PawnIO
InstallDirRegKey HKLM "Software\PawnIO" "Install_Dir"

Page license
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section ""
    !insertmacro SERVICE "stop" "PawnIO" ""
    Sleep 2000
    !insertmacro SERVICE "delete" "PawnIO" ""

    SetOutPath $INSTDIR
    
    ${If} ${IsNativeAMD64}
        File /oname=PawnIOLib.dll x64\PawnIOLib.dll
        File /oname=PawnIOLib.pdb x64\PawnIOLib.pdb
        File /oname=PawnIOUtil.exe x64\PawnIOUtil.exe
        File /oname=PawnIOUtil.pdb x64\PawnIOUtil.pdb
        !ifdef UNRESTRICTED
            File /oname=PawnIO.sys x64\ReleaseUnrestricted\PawnIO.sys
            File /oname=PawnIO.pdb x64\ReleaseUnrestricted\PawnIO.pdb
        !else
            File /oname=PawnIO.sys x64\Release\PawnIO.sys
            File /oname=PawnIO.pdb x64\Release\PawnIO.pdb
        !endif
    ${ElseIf} ${IsNativeARM64}
        File /oname=PawnIOLib.dll ARM64\PawnIOLib.dll
        File /oname=PawnIOLib.pdb ARM64\PawnIOLib.pdb
        File /oname=PawnIOUtil.exe ARM64\PawnIOUtil.exe
        File /oname=PawnIOUtil.pdb ARM64\PawnIOUtil.pdb
        !ifdef UNRESTRICTED
            File /oname=PawnIO.sys ARM64\ReleaseUnrestricted\PawnIO.sys
            File /oname=PawnIO.pdb ARM64\ReleaseUnrestricted\PawnIO.pdb
        !else
            File /oname=PawnIO.sys ARM64\Release\PawnIO.sys
            File /oname=PawnIO.pdb ARM64\Release\PawnIO.pdb
        !endif
    ${Else}
      Abort "Unsupported CPU architecture!"
    ${EndIf}
    
    ; Header
    File "PawnIOLib.h"

    WriteRegStr HKLM "Software\PawnIO" "Install_Dir" "$INSTDIR"
    
    ; Write the uninstall keys for Windows
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO" "DisplayName" "PawnIO"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO" "NoRepair" 1
    WriteUninstaller "$INSTDIR\uninstall.exe"

    !insertmacro SERVICE "create" "PawnIO" "path=$INSTDIR\PawnIO.sys;autostart=1;servicetype=1;display=PawnIO;description=PawnIO Driver.;"
    !insertmacro SERVICE "start" "PawnIO" ""
SectionEnd

Section "Uninstall"
    !insertmacro SERVICE "stop" "PawnIO" ""
    Sleep 2000
    !insertmacro SERVICE "delete" "PawnIO" ""

    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PawnIO"
    DeleteRegKey HKLM "Software\PawnIO"

    ; Remove files and uninstaller
    Delete $INSTDIR\PawnIOLib.dll
    Delete $INSTDIR\PawnIOLib.pdb
    Delete $INSTDIR\PawnIOUtil.exe
    Delete $INSTDIR\PawnIOUtil.pdb
    Delete $INSTDIR\PawnIO.sys
    Delete $INSTDIR\PawnIO.pdb
    Delete $INSTDIR\PawnIOLib.h

    ; Remove directories
    RMDir "$SMPROGRAMS\PawnIO"
    RMDir "$INSTDIR"
SectionEnd

!finalize 'sign.bat "%1"'
!uninstfinalize 'sign.bat "%1"'
