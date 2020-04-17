; #FUNCTION# ====================================================================================================================
; Name...........: _ParseCSV
; Description ...: Reads a CSV-file
; Syntax.........: _ParseCSV($sFile, $sDelimiters=',', $sQuote='"', $iFormat=0)
; Parameters ....: $sFile       - File to read or string to parse
;                  $sDelimiters - [optional] Fieldseparators of CSV, mulitple are allowed (default: ,;)
;                  $sQuote      - [optional] Character to quote strings (default: ")
;                  $iFormat     - [optional] Encoding of the file (default: 0):
;                  |-1     - No file, plain data given
;                  |0 or 1 - automatic (ASCII)
;                  |2      - Unicode UTF16 Little Endian reading
;                  |3      - Unicode UTF16 Big Endian reading
;                  |4 or 5 - Unicode UTF8 reading
;                  $iAddIndex     - [optional] Adds an index in first column
;                  $AddHeader     - [optional] Adds an automatic header ("Col1", "Col2", ....)
; Return values .: Success - 2D-Array with CSV data (0-based)
;                  Failure - 0, sets @error to:
;                  |1 - could not open file
;                  |2 - error on parsing data
;                  |3 - wrong format chosen
; Author ........: ProgAndy
; Modified.......: funkey (to fit the function to the CSV-Editor)
; Remarks .......:
; Related .......: _WriteCSV
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _ParseCSV($sFile, $sDelimiters = ',;', $sQuote = '"', $iFormat = 0, $iAddIndex = 0, $AddHeader = 0)
    Local Static $aEncoding[6] = [0, 0, 32, 64, 128, 256]
    If $iFormat < -1 Or $iFormat > 6 Then
        Return SetError(3, 0, 0)
    ElseIf $iFormat > -1 Then
        Local $hFile = FileOpen($sFile, $aEncoding[$iFormat]), $sLine, $aTemp, $aCSV[1], $iReserved, $iCount
        If @error Then Return SetError(1, @error, 0)
        $sFile = FileRead($hFile)
        FileClose($hFile)
    EndIf
    If $sDelimiters = "" Or IsKeyword($sDelimiters) Then $sDelimiters = ',;'
    If $sQuote = "" Or IsKeyword($sQuote) Then $sQuote = '"'
    $sQuote = StringLeft($sQuote, 1)
    $iAddIndex = Number($iAddIndex=True)
    $AddHeader = Number($AddHeader=True)
    Local $srDelimiters = StringRegExpReplace($sDelimiters, '[\\\^\-\[\]]', '\\\0')
    Local $srQuote = StringRegExpReplace($sQuote, '[\\\^\-\[\]]', '\\\0')
    Local $sPattern = StringReplace(StringReplace('(?m)(?:^|[,])\h*(["](?:[^"]|["]{2})*["]|[^,\r\n]*)(\v+)?', ',', $srDelimiters, 0, 1), '"', $srQuote, 0, 1)
    Local $aREgex = StringRegExp($sFile, $sPattern, 3)
    If @error Then Return SetError(2, @error, 0)
    $sFile = '' ; save memory
    Local $iBound = UBound($aREgex), $iIndex = $AddHeader, $iSubBound = 1+$iAddIndex, $iSub = $iAddIndex, $sLast='' ;changed
    If $iBound Then $sLast = $aREgex[$iBound-1]
    Local $aResult[$iBound + $iAddIndex][$iSubBound] ;changed
    For $i = 0 To $iBound - 1
        If $iSub = $iSubBound Then
            $iSubBound += 1
            ReDim $aResult[$iBound][$iSubBound]
        EndIf
        Select
            Case StringLeft(StringStripWS($aREgex[$i], 1), 1) = $sQuote
                $aREgex[$i] = StringStripWS($aREgex[$i], 3)
                $aResult[$iIndex][$iSub] = $aREgex[$i]
;~                 $aResult[$iIndex][$iSub] = StringReplace(StringMid($aREgex[$i], 2, StringLen($aREgex[$i])-2), $sQuote&$sQuote, $sQuote, 0, 1)
            Case StringRegExp($aREgex[$i], '^\v+$') ; StringLen($aREgex[$i]) < 3 And StringInStr(@CRLF, $aREgex[$i]) ;new line found
                StringReplace($aREgex[$i], @LF, "", 0, 1)
                $iIndex += @extended
                $iSub = $iAddIndex ;changed
                ContinueLoop
            Case Else
                $aResult[$iIndex][$iSub] = $aREgex[$i]
        EndSelect
        $aREgex[$i] = 0 ; save memory
        $iSub += 1
        If $iAddIndex Then $aResult[$iIndex][0] = $iIndex ;added
    Next
    If Not StringRegExp($sLast, '^\v+$') Then $iIndex+=1
    ReDim $aResult[$iIndex][$iSubBound - 1]
    If $iAddIndex Then $aResult[0][0] = "Index" ;added
    If $AddHeader Then
        For $i = 1 To $iSubBound - 2
            $aResult[0][$i] = "Col" & $i
        Next
    EndIf
    Return $aResult
EndFunc   ;==>_ParseCSV

Func _CSVReadToArray($sFile, $sSeparator, $sQuote = '"')
    Local $hFile = FileOpen($sFile, 0)
    Local $sText = FileRead($hFile)
    FileClose($hFile)
    Local $aArray
    If StringRight($sText, 1) = @LF Then $sText = StringTrimRight($sText, 1)
    If StringRight($sText, 1) = @CR Then $sText = StringTrimRight($sText, 1)

    If StringInStr($sText, @LF) Then
        $aArray = StringSplit(StringStripCR($sText), @LF, 2)
    ElseIf StringInStr($sText, @CR) Then ;; @LF does not exist so split on the @CR
        $aArray = StringSplit($sText, @CR, 2)
    Else ;; unable to split the file
        If StringLen($sText) Then
            Dim $aArray[1] = [$sText]
        Else
            Return SetError(2, 0, 0)
        EndIf
    EndIf
    $aArray = _Array1DTo2D($aArray, $sSeparator)
    ReDim $aArray[UBound($aArray, 1)][UBound($aArray, 2) - 1]
    Return $aArray
EndFunc   ;==>_CSVReadToArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _Array1DTo2D
; Description ...: Transforms a 1D to a 2D array.
; Syntax ........: _Array1DTo2D($avArray, $iCols[, $iStart = 0[, $iEnd = 0[, $iFlag = 0]]])
; Parameters ....: $avArray             - Array to modify.
;                  $iCols               - Number of columns to transform the array to.
;                  $iStart              - [optional] Index of array to start the transformation. Default is the first element.
;                  $iEnd                - [optional] Index of array to stop the transformation. Default is the last element.
;                  $iFlag               - [optional] If set to 1, the array size must to a multiple of $iCols. Default is 0.
; Return values .: Success : Returns a 2D array
;                  Failure : Returns 0 and sets @error to :
;                    1 - $aArray is not an array
;                    2 - $iStart is greater than $iEnd
;                    3 - $aArray is not a 1D array
;                    4 - $aArray size is not a multiple of $iCols
; Author ........: jguinch
; ===============================================================================================================================
Func _Array1DTo2D($avArray, $iCols, $iStart = 0, $iEnd = 0, $iFlag = 0)

    If $iStart = Default OR $iStart < 0 Then $iStart = 0
    If $iEnd = Default Then $iEnd = 0

    If NOT IsArray($avArray) Then Return SetError(1, 0, 0)
    If UBound($avArray, 0) <> 1 Then Return SetError(3, 0, 0)

    Local $iUBound = UBound($avArray) - 1

    If $iEnd < 1 Then $iEnd = $iUBound
    If $iEnd > $iUBound Then $iEnd = $iUBound
    If $iStart > $iEnd Then Return SetError(2, 0, 0)

    Local $iNbRows = ($iEnd - $iStart + 1) / $iCols
    If $iFlag AND IsFloat($iNbRows) Then Return SetError(2, 0, 0)

    Local $aRet[ Ceiling($iNbRows) ][$iCols]
    Local $iCol = 0, $iRow = 0
    For $i = $iStart To $iEnd
        If $iCol = $iCols Then
            $iCol = 0
            $iRow += 1
        EndIf
        $aRet[$iRow][$iCol] = $avArray[$i]
        $iCol += 1
    Next

    Return $aRet
EndFunc