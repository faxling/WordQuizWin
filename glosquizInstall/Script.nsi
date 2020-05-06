
; NSIS Modern User Interface
!define VERSION 2.0.0.10

VIAddVersionKey "ProductName" "WordQuiz"
VIAddVersionKey "Comments" "WordQuiz"
VIAddVersionKey "CompanyName" "Soft Ax"
VIAddVersionKey "LegalTrademarks" "Soft Ax"
VIAddVersionKey "LegalCopyright" "©Soft Ax"
VIAddVersionKey "FileDescription" "WordQuiz"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIProductVersion ${VERSION}
VIAddVersionKey "PrivateBuild" "${VERSION} ${__DATE__} ${__TIME__}"
; Include Modern UI
!include "MUI2.nsh"

; General

  ; Name and output file
  Name "WordQuiz"
  OutFile "WordQuiz_${VERSION}.exe"

  ; Default installation folder
  InstallDir "$LOCALAPPDATA\WordQuiz"
  
  ; Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\WordQuiz" ""

  ; Request application privileges for Windows Vista/7/8/10
  RequestExecutionLevel user

; --------------------------------
; Interface Settings

; --------------------------------
; Pages

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_WELCOMEPAGE_TEXT "WordQuiz ${VERSION}"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
  
; --------------------------------
; Languages
 
  !insertmacro MUI_LANGUAGE "English"

; --------------------------------
; Installer Sections
; use tool windeployqt.exe c:\Users\fraxl\Documents\qt\build-glosquiz-Desktop_Qt_5_14_2_MinGW_64_bit-Release\release\glosquiz.exe --qmldir c:\Users\fraxl\Documents\qt\glosquiz -dir c:\QtNy\5.14.2\mingw73_64\Deploy\Bin
; to generate install files

Section "WordQuiz" SecDummy

  SetOutPath "$INSTDIR"

   File /r c:\QtNy\5.14.2\mingw73_64\Deploy\Bin	

   SetOutPath "$INSTDIR\Bin"

  File c:\Users\fraxl\Documents\qt\build-glosquiz-Desktop_Qt_5_14_2_MinGW_64_bit-Release\release\glosquiz.exe	

 
  CreateShortCut "$SMPROGRAMS\WordQuiz.lnk" "$INSTDIR\bin\glosquiz.exe" 
  CreateShortCut "$DESKTOP\WordQuiz.lnk" "$INSTDIR\\bin\glosquiz.exe" 
   
  ; Store installation folder
  WriteRegStr HKCU "Software\WordQuiz" "" $INSTDIR

  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

; Uninstaller Section

Section "Uninstall"

  RMDir /r /REBOOTOK "$LOCALAPPDATA\WordQuiz"

  DeleteRegKey /ifempty HKCU "Software\WordQuiz"
  Delete "$DESKTOP\WordQuiz.lnk"


SectionEnd
