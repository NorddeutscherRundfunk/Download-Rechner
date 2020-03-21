#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\Download-Rechner.ico
#AutoIt3Wrapper_Res_Comment=Berechnet mit eingegebener Datenmenge und Datenrate die Kopierzeit.
#AutoIt3Wrapper_Res_Description=Berechnet mit eingegebener Datenmenge und Datenrate die Kopierzeit.
#AutoIt3Wrapper_Res_Fileversion=1.0.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_CompanyName=Norddeutscher Rundfunk
#AutoIt3Wrapper_Res_LegalCopyright=Conrad Zelck
#AutoIt3Wrapper_Res_SaveSource=p
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

Global $g_iDecimal = 2	; number of decimal places
Global Const $DECIMAL = 1000
Global Const $BINARY = 1024

GUICreate("Download-Rechner",460,290)
GUICtrlCreateLabel("File-Grösse:",10,8,80,20)
GUICtrlCreateLabel("Transfer-Rate:",10,68)
GUICtrlCreateLabel("Download-Zeit:",10,223)
GUICtrlCreateLabel("hh:mm:ss",245,223)
GUICtrlCreateLabel("Preset:",10,260)

Global $g_idFileSizeInput = GUICtrlCreateInput("",85,5,150,20,$ES_RIGHT)
Global $g_idTransferRateInput = GUICtrlCreateInput("",85,65,150,20,$ES_RIGHT)
GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")

Global $g_idDownloadInput = GUICtrlCreateInput("",85,220,150,20,BitOR ($ES_RIGHT,$ES_READONLY))	; output of download time

Global $g_idCalculateButton = GUICtrlCreateButton("Berechnen", 85, 185, 150, 25,$BS_DEFPUSHBUTTON)

GUIStartGroup()
Global $g_idFileSizeScale_b = GUICtrlCreateRadio("B",245,5)
Global $g_idFileSizeScale_kb = GUICtrlCreateRadio("KB",280,5)
Global $g_idFileSizeScale_mb = GUICtrlCreateRadio("MB",320,5)
Global $g_idFileSizeScale_gb = GUICtrlCreateRadio("GB",360,5)
Global $g_idFileSizeScale_tb = GUICtrlCreateRadio("TB",400,5)
GUICtrlSetState($g_idFileSizeScale_gb, $GUI_CHECKED)

GUIStartGroup()
Global $g_idOS_win = GUICtrlCreateRadio("Windows",245,35)
Global $g_idOS_apple = GUICtrlCreateRadio("Apple",320,35)
GUICtrlSetState($g_idOS_win, $GUI_CHECKED)

GUIStartGroup()
Global $g_idTransferRateScale_b = GUICtrlCreateRadio("bit/s",245,65)
Global $g_idTransferRateScale_kb = GUICtrlCreateRadio("Kbit/s",295,65)
Global $g_idTransferRateScale_mb = GUICtrlCreateRadio("Mbit/s",350,65)
Global $g_idTransferRateScale_gb = GUICtrlCreateRadio("Gbit/s",405,65)

Global $g_idTransferRateScale_by = GUICtrlCreateRadio("B/s",245,95)
Global $g_idTransferRateScale_kby = GUICtrlCreateRadio("KB/s",295,95)
Global $g_idTransferRateScale_mby = GUICtrlCreateRadio("MB/s",350,95)
Global $g_idTransferRateScale_gby = GUICtrlCreateRadio("GB/s",405,95)

Global $g_idTransferRateScale_kib = GUICtrlCreateRadio("Kibit/s",295,125)
Global $g_idTransferRateScale_mib = GUICtrlCreateRadio("Mibit/s",350,125)
Global $g_idTransferRateScale_gib = GUICtrlCreateRadio("Gibit/s",405,125)

Global $g_idTransferRateScale_kiby = GUICtrlCreateRadio("KiB/s",295,155)
Global $g_idTransferRateScale_miby = GUICtrlCreateRadio("MiB/s",350,155)
Global $g_idTransferRateScale_giby = GUICtrlCreateRadio("GiB/s",405,155)
GUICtrlSetState($g_idTransferRateScale_mb, $GUI_CHECKED)
; As state is set these are the start values
Global $g_iPotencyTransferRate = 2 ; 0=B, 1=K, 2=M, 3=T
Global $g_iConversionFactor = 1000 ; 1024 binary or 1000 decimal
Global $g_bByte = False ; if byte then true, if bit then false

; hard coded presets
Global $g_aPresets = [["XDCAM HD 422", "60.15", "tmb"],["Audio 48kHz 24bit Stereo", "2304", "tkb"], ["MG-copy Transfer-MAC", "75", "tmby"], ["Ethernet 100MBit/s", "94", "tmb"], ["Ethernet 1GBit/s", "940", "tmb"], ["FireWire 400", "240", "tmb"], ["FireWire 800", "480", "tmb"], _
						["Thunderbolt (2)", "1.3", "tgby"], ["Thunderbolt 3", "3", "tgby"], _
						["USB 1.1", "6.6", "tmb"], ["USB 2.0", "280", "tmb"], ["USB 3.0", "480", "tmby"], ["USB-C (3.1)", "900", "tmby"]]
Global $g_sPresets
Global Enum $NAME, $RATE, $SCALE
For $i = 0 To UBound($g_aPresets) - 1
	$g_sPresets &= $g_aPresets[$i][$NAME] & "|"
Next
Global $g_idPresetCombo = GUICtrlCreateCombo("", 85,257,150,20)
GUICtrlSetData($g_idPresetCombo, $g_sPresets)

GUISetState(@SW_SHOW)

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $g_idCalculateButton
			Berechnen()
		Case $g_idPresetCombo
			Preset()
			Berechnen()
	EndSwitch
WEnd

Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)	; only allow numbers
	#forceref $hWnd, $iMsg, $wParam, $lParam
	Local $sFileSize = GUICtrlRead($g_idFileSizeInput)
	Local $sFileSize_Current = $sFileSize
	Local $sTransferRate = GUICtrlRead($g_idTransferRateInput)
	Local $sTransferRate_Current = $sTransferRate
	; Delete all which is not digit, comma or dot on file size or transfer rate
	If StringRegExp($sFileSize, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]') Then $sFileSize = StringRegExpReplace($sFileSize, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]', '\1')
	If StringRegExp($sTransferRate, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]') Then $sTransferRate = StringRegExpReplace($sTransferRate, '[^\d.,-]|([{0-9,1}^\A-])[^\d.,]', '\1')
	; Replace comma with dot
	$sFileSize = StringRegExpReplace($sFileSize, ',', '.')
	$sTransferRate = StringRegExpReplace($sTransferRate, ',', '.')
	; First decimal point
	Local $iFirstDecimalPoint_FileSize = StringInStr($sFileSize, ".", 0)
	Local $iFirstDecimalPoint_TransferRate = StringInStr($sTransferRate, ".", 0)
	; Possibly second decimal point
	Local $iSecondDecimalPoint_FileSize = StringInStr($sFileSize, ".", 0, 2)
	Local $iSecondDecimalPoint_TransferRate = StringInStr($sTransferRate, ".", 0, 2)
	; If second decimal point then delete it
	If $iSecondDecimalPoint_FileSize <> 0 Then $sFileSize = StringLeft($sFileSize, $iSecondDecimalPoint_FileSize - 1)
	If $iSecondDecimalPoint_TransferRate <> 0 Then $sTransferRate = StringLeft($sTransferRate, $iSecondDecimalPoint_TransferRate - 1)
	; Trim to maximal allowed decimal place
	If $iFirstDecimalPoint_FileSize <> 0 Then $sFileSize = StringLeft($sFileSize, $iFirstDecimalPoint_FileSize + $g_iDecimal)
	If $iFirstDecimalPoint_TransferRate <> 0 Then $sTransferRate = StringLeft($sTransferRate, $iFirstDecimalPoint_TransferRate + $g_iDecimal)
	; Set corrected data back to inputs
	If $sFileSize <> $sFileSize_Current Then GUICtrlSetData($g_idFileSizeInput, $sFileSize)
	If $sTransferRate <> $sTransferRate_Current Then GUICtrlSetData($g_idTransferRateInput, $sTransferRate)

	Berechnen()
EndFunc

Func Preset()
	Local $sPreset = GUICtrlRead($g_idPresetCombo)
	For $i = 0 To UBound($g_aPresets) -1
		If $sPreset = $g_aPresets[$i][$NAME] Then
			GUICtrlSetData($g_idTransferRateInput, $g_aPresets[$i][$RATE])
			Switch $g_aPresets[$i][$SCALE]
				Case "tb"
					GUICtrlSetState($g_idTransferRateScale_b, $GUI_CHECKED)
				Case "tkb"
					GUICtrlSetState($g_idTransferRateScale_kb, $GUI_CHECKED)
				Case "tmb"
					GUICtrlSetState($g_idTransferRateScale_mb, $GUI_CHECKED)
				Case "tgb"
					GUICtrlSetState($g_idTransferRateScale_gb, $GUI_CHECKED)
				Case "tby"
					GUICtrlSetState($g_idTransferRateScale_by, $GUI_CHECKED)
				Case "tkby"
					GUICtrlSetState($g_idTransferRateScale_kby, $GUI_CHECKED)
				Case "tmby"
					GUICtrlSetState($g_idTransferRateScale_mby, $GUI_CHECKED)
				Case "tgby"
					GUICtrlSetState($g_idTransferRateScale_gby, $GUI_CHECKED)
				Case "tkib"
					GUICtrlSetState($g_idTransferRateScale_kib, $GUI_CHECKED)
				Case "tmib"
					GUICtrlSetState($g_idTransferRateScale_mib, $GUI_CHECKED)
				Case "tgib"
					GUICtrlSetState($g_idTransferRateScale_gib, $GUI_CHECKED)
				Case "tkiby"
					GUICtrlSetState($g_idTransferRateScale_kiby, $GUI_CHECKED)
				Case "tmiby"
					GUICtrlSetState($g_idTransferRateScale_miby, $GUI_CHECKED)
				Case "tgiby"
					GUICtrlSetState($g_idTransferRateScale_giby, $GUI_CHECKED)
			EndSwitch
			ControlFocus("", "", $g_idFileSizeInput)
			ExitLoop
		EndIf
	Next
EndFunc

Func Berechnen()
	Local $iOsFactor = $BINARY ; factor win/osx
	Local $iPotencyFileSize
	Local $iFileSize ; size in bit
	Local $iTransferRate
	Local $iSecondsDownloadTime

	If GUICtrlRead($g_idOS_apple) = $GUI_CHECKED Then $iOsFactor = $DECIMAL ; 1024 for Windows or 1000 for OSX

	If GUICtrlRead($g_idFileSizeScale_b) = $GUI_CHECKED Then				; file size
		$iPotencyFileSize = 0
	ElseIf GUICtrlRead($g_idFileSizeScale_kb) = $GUI_CHECKED Then
		$iPotencyFileSize = 1
	ElseIf GUICtrlRead($g_idFileSizeScale_mb) = $GUI_CHECKED Then
		$iPotencyFileSize = 2
	ElseIf GUICtrlRead($g_idFileSizeScale_gb) = $GUI_CHECKED Then
		$iPotencyFileSize = 3
	ElseIf GUICtrlRead($g_idFileSizeScale_tb) = $GUI_CHECKED Then
		$iPotencyFileSize = 4
	EndIf

	$iFileSize = GUICtrlRead($g_idFileSizeInput) * $iOsFactor ^ $iPotencyFileSize * 8

	If GUICtrlRead($g_idTransferRateScale_b) = $GUI_CHECKED Then			; decimal in bit
		$g_iPotencyTransferRate = 0
		$g_iConversionFactor = $DECIMAL
	ElseIf GUICtrlRead($g_idTransferRateScale_kb) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 1
		$g_iConversionFactor = $DECIMAL
	ElseIf GUICtrlRead($g_idTransferRateScale_mb) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 2
		$g_iConversionFactor = $DECIMAL
	ElseIf GUICtrlRead($g_idTransferRateScale_gb) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 3
		$g_iConversionFactor = $DECIMAL
	ElseIf GUICtrlRead($g_idTransferRateScale_by) = $GUI_CHECKED Then		; decimal in byte
		$g_iPotencyTransferRate = 0
		$g_iConversionFactor = $DECIMAL
		$g_bByte = True
	ElseIf GUICtrlRead($g_idTransferRateScale_kby) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 1
		$g_iConversionFactor = $DECIMAL
		$g_bByte = True
	ElseIf GUICtrlRead($g_idTransferRateScale_mby) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 2
		$g_iConversionFactor = $DECIMAL
		$g_bByte = True
	ElseIf GUICtrlRead($g_idTransferRateScale_gby) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 3
		$g_iConversionFactor = $DECIMAL
		$g_bByte = True
	ElseIf GUICtrlRead($g_idTransferRateScale_kib) = $GUI_CHECKED Then		; binary in bit
		$g_iPotencyTransferRate = 1
		$g_iConversionFactor = $BINARY
	ElseIf GUICtrlRead($g_idTransferRateScale_mib) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 2
		$g_iConversionFactor = $BINARY
	ElseIf GUICtrlRead($g_idTransferRateScale_gib) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 3
		$g_iConversionFactor = $BINARY
	ElseIf GUICtrlRead($g_idTransferRateScale_kiby) = $GUI_CHECKED Then		; binary in byte
		$g_iPotencyTransferRate = 1
		$g_iConversionFactor = $BINARY
		$g_bByte = True
	ElseIf GUICtrlRead($g_idTransferRateScale_miby) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 2
		$g_iConversionFactor = $BINARY
		$g_bByte = True
	ElseIf GUICtrlRead($g_idTransferRateScale_giby) = $GUI_CHECKED Then
		$g_iPotencyTransferRate = 3
		$g_iConversionFactor = $BINARY
		$g_bByte = True
	EndIf

	$iTransferRate = GUICtrlRead($g_idTransferRateInput) * $g_iConversionFactor ^ $g_iPotencyTransferRate
	If $g_bByte Then $iTransferRate *= 8 ; byte to bit
	If $iTransferRate = 0 Then $iTransferRate = $iTransferRate + 0.000000001			;to avoid division with zero

	$iSecondsDownloadTime = $iFileSize / $iTransferRate									;calculate download time
	$iSecondsDownloadTime = Ceiling($iSecondsDownloadTime)								;to avoid integer

	Local $sDateTime = _DateAdd("s",$iSecondsDownloadTime,"2013/01/01 00:00:00")
	Local $iHours = _DateDiff("h","2013/01/01 00:00:00",$sDateTime)
	Local $sTime = StringRegExpReplace($sDateTime,".+ (.+)","$1")
	if $iHours > 23 Then $sTime = StringRegExpReplace($sTime,"^\d+?:",$iHours&":")

	GUICtrlSetData($g_idDownloadInput,$sTime)
EndFunc
