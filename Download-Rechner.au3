#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\Download-Rechner.ico
#AutoIt3Wrapper_Res_Comment=Berechnet mit eingegebener Datenmenge und Datenrate die Kopierzeit.
#AutoIt3Wrapper_Res_Description=Berechnet mit eingegebener Datenmenge und Datenrate die Kopierzeit.
#AutoIt3Wrapper_Res_Fileversion=1.0.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_CompanyName=Norddeutscher Rundfunk
#AutoIt3Wrapper_Res_LegalCopyright=Conrad Zelck
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_Field=Copyright|Conrad Zelck
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <Date.au3>
#include "udf/TrayCox/TrayCox.au3" ; source: https://github.com/SimpelMe/TrayCox

Global $iDecimal = 2	; number of decimal places
Global $fgRR =""
Global $tRR =""
Global $dRR = ""

GUICreate("Download-Rechner",460,290)
GUICtrlCreateLabel("File-Grösse:",10,8,80,20)
GUICtrlCreateLabel("Transfer-Rate:",10,68)
GUICtrlCreateLabel("Download-Zeit:",10,223)
GUICtrlCreateLabel("hh:mm:ss",245,223)
GUICtrlCreateLabel("Preset:",10,260)

Global $fg = GUICtrlCreateInput("",85,5,150,20,$ES_RIGHT)
GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")	; only allow numbers

Global $t = GUICtrlCreateInput("",85,65,150,20,$ES_RIGHT)
GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")	; only allow numbers

Global $sTime = ""	; keep the output clean
Global $d = GUICtrlCreateInput($sTime,85,220,150,20,BitOR ($ES_RIGHT,$ES_READONLY))	; output of download time

Global $Berechnen_Button = GUICtrlCreateButton("Berechnen", 85, 185, 150, 25,$BS_DEFPUSHBUTTON)

GUIStartGroup()
Global $fgb = GUICtrlCreateRadio("B",245,5)
Global $fgkb = GUICtrlCreateRadio("KB",280,5)
Global $fgmb = GUICtrlCreateRadio("MB",320,5)
Global $fggb = GUICtrlCreateRadio("GB",360,5)
Global $fgtb = GUICtrlCreateRadio("TB",400,5)

GUIStartGroup()
Global $osw = GUICtrlCreateRadio("Windows",245,35)
Global $osa = GUICtrlCreateRadio("Apple",320,35)

GUIStartGroup()
Global $tb = GUICtrlCreateRadio("bit/s",245,65)
Global $tkb = GUICtrlCreateRadio("Kbit/s",295,65)
Global $tmb = GUICtrlCreateRadio("Mbit/s",350,65)
Global $tgb = GUICtrlCreateRadio("Gbit/s",405,65)

Global $tby = GUICtrlCreateRadio("B/s",245,95)
Global $tkby = GUICtrlCreateRadio("KB/s",295,95)
Global $tmby = GUICtrlCreateRadio("MB/s",350,95)
Global $tgby = GUICtrlCreateRadio("GB/s",405,95)

Global $tkib = GUICtrlCreateRadio("Kibit/s",295,125)
Global $tmib = GUICtrlCreateRadio("Mibit/s",350,125)
Global $tgib = GUICtrlCreateRadio("Gibit/s",405,125)

Global $tkiby = GUICtrlCreateRadio("KiB/s",295,155)
Global $tmiby = GUICtrlCreateRadio("MiB/s",350,155)
Global $tgiby = GUICtrlCreateRadio("GiB/s",405,155)

; hard coded presets
Global $g_aPresets = [["XDCAM HD 422", "60.15", "tmb"],["Audio 48kHz 24bit Stereo", "2304", "tkb"], ["MG-copy Transfer-MAC", "75", "tmby"], ["Ethernet 100MBit/s", "94", "tmb"], ["Ethernet 1GBit/s", "940", "tmb"], ["FireWire 400", "240", "tmb"], ["FireWire 800", "480", "tmb"], _
						["Thunderbolt (2)", "1.3", "tgby"], ["Thunderbolt 3", "3", "tgby"], _
						["USB 1.1", "6.6", "tmb"], ["USB 2.0", "280", "tmb"], ["USB 3.0", "480", "tmby"], ["USB-C (3.1)", "900", "tmby"]]
Global $g_sPresetListe
For $i = 0 To UBound($g_aPresets) - 1
	$g_sPresetListe &= $g_aPresets[$i][0] & "|"
Next
Global $g_hPreset = GUICtrlCreateCombo("", 85,257,150,20)
GUICtrlSetData($g_hPreset, $g_sPresetListe)

GUISetState(@SW_SHOW)
GUICtrlSetState($fggb, $GUI_CHECKED)
GUICtrlSetState($tmb, $GUI_CHECKED)
GUICtrlSetState($osw, $GUI_CHECKED)

Local $msg
While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $GUI_EVENT_CLOSE
			Exit
		Case $msg = $Berechnen_Button
			Berechnen()
		Case $msg = $g_hPreset
			Preset()
			ControlClick("", "", $Berechnen_Button)
	EndSelect
WEnd

Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)	; only allow numbers
	#forceref $hWnd, $iMsg, $wParam, $lParam
    Global $Read_Inputfg = GUICtrlRead($fg)
    Global $Read_Inputt = GUICtrlRead($t)
	If StringRegExp($Read_Inputfg, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]') Then $Read_Inputfg = StringRegExpReplace($Read_Inputfg, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]', '\1')
    If StringRegExp($Read_Inputt, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]') Then $Read_Inputt = StringRegExpReplace($Read_Inputt, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]', '\1')
	$Read_Inputfg = StringRegExpReplace($Read_Inputfg, ',', '.')
	$Read_Inputt = StringRegExpReplace($Read_Inputt, ',', '.')
    Global $Point1fg = StringInStr($Read_Inputfg, ".", 0)
    Global $Point1t = StringInStr($Read_Inputt, ".", 0)
    Global $Point2fg = StringInStr($Read_Inputfg, ".", 0, 2)
    Global $Point2t = StringInStr($Read_Inputt, ".", 0, 2)
    If $Point2fg <> 0 Then $Read_Inputfg = StringLeft($Read_Inputfg, $Point2fg - 1)
    If $Point2t <> 0 Then $Read_Inputt = StringLeft($Read_Inputt, $Point2t - 1)
    If $Point1fg <> 0 Then $Read_Inputfg = StringLeft($Read_Inputfg, $Point1fg + $iDecimal)
    If $Point1t <> 0 Then $Read_Inputt = StringLeft($Read_Inputt, $Point1t + $iDecimal)
    GUICtrlSetData($fg, $Read_Inputfg)
    GUICtrlSetData($t, $Read_Inputt)
EndFunc

Func Preset()
	Local $sPreset = GUICtrlRead($g_hPreset)
	For $i = 0 To UBound($g_aPresets) -1
		If $sPreset = $g_aPresets[$i][0] Then
			GUICtrlSetData($t, $g_aPresets[$i][1])
			Switch $g_aPresets[$i][2]
				Case "tb"
					GUICtrlSetState($tb, $GUI_CHECKED)
				Case "tkb"
					GUICtrlSetState($tkb, $GUI_CHECKED)
				Case "tmb"
					GUICtrlSetState($tmb, $GUI_CHECKED)
				Case "tgb"
					GUICtrlSetState($tgb, $GUI_CHECKED)
				Case "tby"
					GUICtrlSetState($tby, $GUI_CHECKED)
				Case "tkby"
					GUICtrlSetState($tkby, $GUI_CHECKED)
				Case "tmby"
					GUICtrlSetState($tmby, $GUI_CHECKED)
				Case "tgby"
					GUICtrlSetState($tgby, $GUI_CHECKED)
				Case "tkib"
					GUICtrlSetState($tkib, $GUI_CHECKED)
				Case "tmib"
					GUICtrlSetState($tmib, $GUI_CHECKED)
				Case "tgib"
					GUICtrlSetState($tgib, $GUI_CHECKED)
				Case "tkiby"
					GUICtrlSetState($tkiby, $GUI_CHECKED)
				Case "tmiby"
					GUICtrlSetState($tmiby, $GUI_CHECKED)
				Case "tgiby"
					GUICtrlSetState($tgiby, $GUI_CHECKED)
			EndSwitch
			ControlFocus("", "", $fg)
			ExitLoop
		EndIf
	Next
EndFunc

Func Berechnen()
	Local $osRR
	If GUICtrlRead($osw) = 1 Then						;OS: 1024 for Windows or 1000 for OSX
		$osRR = 1024
	ElseIf GUICtrlRead($osa) = 1 Then
		$osRR = 1000
	EndIf

	If GUICtrlRead($fgb) = 1 Then						;file size to byte
		$fgRR = GUICtrlRead($fg)
	ElseIf GUICtrlRead($fgkb) = 1 Then
		$fgRR = GUICtrlRead($fg) * $osRR
	ElseIf GUICtrlRead($fgmb) = 1 Then
		$fgRR = GUICtrlRead($fg) * $osRR * $osRR
	ElseIf GUICtrlRead($fggb) = 1 Then
		$fgRR = GUICtrlRead($fg) * $osRR * $osRR * $osRR
	ElseIf GUICtrlRead($fgtb) = 1 Then
		$fgRR = GUICtrlRead($fg) * $osRR * $osRR * $osRR * $osRR
	EndIf

	$fgRR = $fgRR * 8									;byte to bit

	If GUICtrlRead($tb) = 1 Then						;Transfer-Rate to Bit/s decimal
		$tRR = GUICtrlRead($t)
	ElseIf GUICtrlRead($tkb) = 1 Then
		$tRR = GUICtrlRead($t) * 1000
	ElseIf GUICtrlRead($tmb) = 1 Then
		$tRR = GUICtrlRead($t) * 1000 * 1000
	ElseIf GUICtrlRead($tgb) = 1 Then
		$tRR = GUICtrlRead($t) * 1000 * 1000 * 1000
	ElseIf GUICtrlRead($tby) = 1 Then					;Transfer-Rate to Byte/s and then to Bit/s decimal
		$tRR = GUICtrlRead($t)
	ElseIf GUICtrlRead($tkby) = 1 Then
		$tRR = GUICtrlRead($t) * 1000 * 8
	ElseIf GUICtrlRead($tmby) = 1 Then
		$tRR = GUICtrlRead($t) * 1000 * 1000 * 8
	ElseIf GUICtrlRead($tgby) = 1 Then
		$tRR = GUICtrlRead($t) * 1000 * 1000 * 1000 * 8
	ElseIf GUICtrlRead($tkib) = 1 Then					;Transfer-Rate to Bit/s binary
		$tRR = GUICtrlRead($t) * 1024
	ElseIf GUICtrlRead($tmib) = 1 Then
		$tRR = GUICtrlRead($t) * 1024 * 1024
	ElseIf GUICtrlRead($tgib) = 1 Then
		$tRR = GUICtrlRead($t) * 1024 * 1024 * 1024
	ElseIf GUICtrlRead($tkiby) = 1 Then					;Transfer-Rate to Byte/s and then to Bit/s binary
		$tRR = GUICtrlRead($t) * 1024 * 8
	ElseIf GUICtrlRead($tmiby) = 1 Then
		$tRR = GUICtrlRead($t) * 1024 * 1024 * 8
	ElseIf GUICtrlRead($tgiby) = 1 Then
		$tRR = GUICtrlRead($t) * 1024 * 1024 * 1024 * 8
	EndIf

	If $tRR = 0 Then $tRR = $tRR + 0.000000001			;to avoid division with zero
	$dRR = $fgRR / $tRR									;calculate download time
	$dRR = Ceiling($dRR)								;to avoid integer

	Local $sDateTime = _DateAdd("s",$dRR,"2013/01/01 00:00:00")
	Local $iHours = _DateDiff("h","2013/01/01 00:00:00",$sDateTime)
	$sTime = StringRegExpReplace($sDateTime,".+ (.+)","$1")
	if $iHours > 23 Then $sTime = StringRegExpReplace($sTime,"^\d+?:",$iHours&":")

	GUICtrlSetData($d,$sTime)
EndFunc