#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=bug.ico
#AutoIt3Wrapper_Outfile=Dever new year game.exe
#AutoIt3Wrapper_Outfile_x64=Dever new year game.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Chương trình random nhận quà được sử dụng trong lễ hội Halloween đại học FPT Đà Nẵng
#AutoIt3Wrapper_Res_Description=Halloween Random
#AutoIt3Wrapper_Res_Fileversion=6.9.0.0
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=JK .KyTs
#AutoIt3Wrapper_Res_Language=1066
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("TrayIconHide", 1)
Opt("GUICloseOnESC", 1)
Opt("GUIOnEventMode", 1)

#include <WinAPI.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include <Sound.au3>
#include "UDF/GuiHTML_UDF.au3"
#include "UDF/CSV.au3"

; Check resolution
If (@DesktopWidth <> 1366 And @DesktopHeight <> 768) Then
	MsgBox(16, 'Thông báo', 'Độ phân giải màn hình khuyến cáo nên là 1366x768' & @CRLF & "Chạy chương trình trên thiết bị này có thể phát sinh lỗi hiển thị!")
EndIf

; Cursor init
_GDIPlus_Startup()
Global $hPrev = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, 32512))
Global $hNewC = _WinAPI_LoadCursorFromFile(@ScriptDir & "\src\hol408.cur")
_WinAPI_SetSystemCursor($hNewC, 32512)

; Sound init
Global $_hSound = _SoundOpen("src/sound/background.mp3")
Global $_hHeartBeat = _SoundOpen("src/sound/Heartbeat.mp3")
Global $_hWinner = _SoundOpen("src/sound/Winner.mp3")
_SoundPlay($_hSound)
AdlibRegister("_checksoundStatus", 1000)

; Data init
$userdata = _ParseCSV("src/userdata.csv", ',')
Global $LastWinnerID = ""
Global $gWidth = @DesktopWidth, $gHeight = @DesktopHeight

; Create HTML GUI
$hGui = GuiCreate("KyTs - HLW_RAND", $gWidth, $gHeight, -1, -1, $WS_POPUP)
GUISetIcon(@ScriptFullPath)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

HTML_Load(@ScriptDir & '/src/index.html', $gWidth, $gHeight, 0, 0, 1)

GUISetState(@SW_SHOW, $hGui)

While 1
	Switch HTML_GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE)
		Case 'AppBtn'	; Click start button event
			AdlibUnRegister("_PlayWinnerAgain")
			_SoundStop($_hWinner)
			_SoundResume($_hSound)
			_HideFinishElements()
			HTML_SETUSERNAME("HỌP MẶT ĐẦU NĂM!")
			Sleep(1000)
			;~ _SoundSeek($_hHeartBeat, 0, 0, 39)
			;~ _SoundPlay($_hHeartBeat)

			_StartRandom()
	EndSwitch
	Sleep(50)
WEnd

Func _Exit()
	_SoundStop($_hSound)
	_SoundClose($_hSound)
	;~ _SoundStop($_hHeartBeat)
	;~ _SoundClose($_hHeartBeat)
	_SoundStop($_hWinner)
	_SoundClose($_hWinner)
    _WinAPI_SetSystemCursor($hPrev, 32512)
    _WinAPI_DestroyCursor($hPrev)
    _WinAPI_DestroyCursor($hNewC)
    _GDIPlus_Shutdown()
    Exit
EndFunc

Func _StartRandom()
	; Each for loop is a Random speed
	For $I=0 To 150
		_RandomName()
		Sleep(20)
	Next
	For $I=0 To 10
		_RandomName()
		Sleep(100)
	Next
	For $I=0 To 10
		_RandomName()
		Sleep(150)
	Next
	For $I=0 To 10
		_RandomName()
		Sleep(420)
	Next
	For $I=0 To 3
		_RandomName()
		Sleep(1000)
	Next
	;~ _SoundStop($_hHeartBeat)
	$LastWinnerID = _RandomName()
	Sleep(3000)
	_SoundPause($_hSound)
	AdlibRegister("_PlayWinnerAgain", 28000)
	_SoundPlay($_hWinner)
	Sleep(1000)
	$_RandomState = True
	_ShowFinishElements()
EndFunc

Func _PlayWinnerAgain()
	_SoundStop($_hWinner)
	_SoundPlay($_hWinner)
EndFunc
Func _checksoundStatus()
	If (_SoundStatus($_hSound) = "stopped") Then
		_SoundSeek($_hSound, 0, 0, 0)
		_SoundPlay($_hSound)
	EndIf
EndFunc
Func _RandomName()
	Local $iRand = Random(1, UBound($userdata, 1)-1, 1)
	HTML_SETUSERNAME($userdata[$iRand][1])
	Return $userdata[$iRand][2]
EndFunc
Func _HideFinishElements()
	HTML_EvalJS('document.getElementById("xuong").style.display = "none";')
	HTML_EvalJS('document.getElementById("bats2").style.display = "none";')
EndFunc
Func _ShowFinishElements()
	HTML_EvalJS('document.getElementById("xuong").style.display = "block";')
	HTML_EvalJS('document.getElementById("bats2").style.display = "block";')
EndFunc

Func HTML_SETUSERNAME($uName)
	HTML_EvalJS('document.getElementById("UserName").innerHTML = "' & $uName & '";')
EndFunc

Func _GDIPlus_CreatePic($FileName, $Left, $Top, $Width, $Heigth)
	Local $hPicCtrl, $hImage, $iHeight, $hGDIBitmap
	$hImage = _GDIPlus_ImageResize(_GDIPlus_ImageLoadFromFile($FileName), $Width, $Heigth)
		$iWidth = _GDIPlus_ImageGetWidth($hImage)
		$iHeight = _GDIPlus_ImageGetHeight($hImage)
		$hGDIBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
		_GDIPlus_ImageDispose($hImage)
	$hPicCtrl = GUICtrlCreateLabel('', $Left, $Top, $Width, $Heigth, $SS_BITMAP)
	_WinAPI_DeleteObject(GUICtrlSendMsg($hPicCtrl, 0x0172, $IMAGE_BITMAP, $hGDIBitmap)) ;$STM_SETIMAGE = 0x0172
    _WinAPI_DeleteObject($hGDIBitmap)
	Return $hPicCtrl
EndFunc