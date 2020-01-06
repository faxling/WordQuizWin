
; NSIS Modern User Interface
!define VERSION 2.0.0.5

VIAddVersionKey "ProductName" "WordQuiz"
VIAddVersionKey "Comments" "WordQuiz"
VIAddVersionKey "CompanyName" "Soft Ax"
VIAddVersionKey "LegalTrademarks" "Soft Ax"
VIAddVersionKey "LegalCopyright" "�Soft Ax"
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

Section "WordQuiz" SecDummy

  SetOutPath "$INSTDIR"
  
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Core.dll
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Gui.dll
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Multimedia.dll	
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Network.dll	
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Qml.dll									
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Quick.dll								
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Sql.dll									
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Svg.dll									
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5Widgets.dll					     	
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\Qt5XmlPatterns.dll					

  File c:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\libeay32.dll 
  File c:\Qt\Qt5.5.1\5.5\msvc2013_64\bin\ssleay32.dll  

 	
  File /r C:\Qt\Deploy\QtQuick.2		
  File /r C:\Qt\Deploy\Controls	
  File /r C:\Qt\Deploy\LocalStorage
  File /r C:\Qt\Deploy\Window.2
  File /r C:\Qt\Deploy\XmlListModel
             
 

  File c:\Users\fraxl\Documents\qt\build-glosquiz-Desktop_Qt_5_5_1_MSVC2013_64bit-Release\release\glosquiz.exe	

  SetOutPath "$INSTDIR\imageformats"
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qdds.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qgif.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qicns.dll					
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qico.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qjp2.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qjpeg.dll					
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qmng.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qsvg.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qtga.dll						
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qtiff.dll					
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qwbmp.dll					
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\imageformats\qwebp.dll				
	
  SetOutPath "$INSTDIR\platforms"

  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\platforms\qwindows.dll		

  SetOutPath "$INSTDIR\audio"

  File 	"C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\audio\qtaudio_windows.dll"

  SetOutPath "$INSTDIR\sqldrivers"
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\sqldrivers\qsqlite.dll		
  SetOutPath "$INSTDIR\bearer"
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\bearer\qgenericbearer.dll			
  File C:\Qt\Qt5.5.1\5.5\msvc2013_64\plugins\bearer\qnativewifibearer.dll	


  CreateShortCut "$DESKTOP\WordQuiz.lnk" "$INSTDIR\glosquiz.exe" 
   
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
