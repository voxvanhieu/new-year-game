#include-once <WinAPI.au3>

#cs
    Returns a cursor ID Number:
    -1 = UNKNOWN (@error can be set if the handle to the cursor cannot be found)
    0   32649   OCR_HAND            Hand
    1   32650   OCR_APPSTARTING     Standard arrow and small hourglass
    2   32512   OCR_NORMAL          Standard arrow
    3   32515   OCR_CROSS           Crosshair
    4   32651   OCR_HELP            Arrow and question mark
    5   32513   OCR_IBEAM           I-beam
    6           ICON (Obsolete for applications marked version 4.0 or later)
    7   32648   OCR_NO              Slashed circle
    8           SIZE (Obsolete for applications marked version 4.0 or later)
    9   32646   OCR_SIZEALL         Four-pointed arrow pointing north, south, east, and west
    10  32643   OCR_SIZENESW        Double-pointed arrow pointing northeast and southwest
    11  32645   OCR_SIZENS          Double-pointed arrow pointing north and south
    12  32642   OCR_SIZENWSE        Double-pointed arrow pointing northwest and southeast
    13  32644   OCR_SIZEWE          Double-pointed arrow pointing west and east
    14  32516   OCR_UP              UPARROW/Vertical arrow
    15  32514   OCR_WAIT            WAIT/Hourglass
#ce

Global Const $__hDefault_Cursor_arrow = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, 32512))
Global Const $__hDefault_Cursor_ibeam = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, 32513))

Func _Cursor_Load($hFile = "")
    If ($hFile == "")
        Return False
    Else
        Return _WinAPI_LoadCursorFromFile($hFile)
    EndIf
EndFunc

Func _Cursor_Set()
   Return _WinAPI_SetSystemCursor(_WinAPI_LoadCursorFromFile(@ScriptDir & "\cross.cur"),32512)
EndFunc

Func _Cursor_Restore()
   _WinAPI_SetSystemCursor($__hDefault_Cursor_arrow,32512)
   _WinAPI_SetSystemCursor($__hDefault_Cursor_ibeam,32513)
EndFunc

Func _Cursor_Clear()
    _WinAPI_DestroyCursor()
EndFunc