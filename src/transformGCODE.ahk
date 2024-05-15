F12::
; Select the file first
FileSelectFile, selectedFile,, Please select a file,, *.*
if (!FileExist(selectedFile))
{
    MsgBox, % "File does not exist."
    return
}

FileRead, fileContent, %selectedFile%
if (ErrorLevel)
{
    MsgBox, % "Failed to read the file."
    return
}

; Extract the directory, filename without extension, and extension
SplitPath, selectedFile, name, dir, ext, name_no_ext

newFileContent := ProcessMillingFunction(fileContent)
GoSub, SaveFile
return

ProcessMillingFunction(fileContent)
{
    ;Start new file with command to switch off LEDs
    newFileContent := "M04`nM09`n" 
    PositionFlag := "High" ; Assume starting position is High
    Loop, parse, fileContent, `n, `r
    {
        line := A_LoopField

        ; Delete lines starting with M03, M04, M05, M08, or M09
        if (RegExMatch(line, "^(M03|M04|M05|M08|M09)"))
            continue

        ; Check for G00 lines with Z followed by a number >= 1
        if (SubStr(line, 1, 3) = "G00" && RegExMatch(line, "Z([1-9]\d*)") && PositionFlag = "Low")
        {
            newFileContent .= "M08`nM00`nM09`n"
            PositionFlag := "High"
        }

        ; Check for G0 lines containing "Z-" when PositionFlag is High
        if (SubStr(line, 1, 2) = "G0" && InStr(line, "Z-") && PositionFlag = "High")
        {
            newFileContent .= "M03`nM00`nM04`n"
            PositionFlag := "Low"
        }

        ; Add the current line after any inserted lines
        newFileContent .= line . "`n"
    }
    return newFileContent
}

SaveFile:
; Construct the new file name
newFileName := dir . "\" . name_no_ext . "_manual." . ext

; Delete the file if it exists to ensure it's replaced
IfExist, %newFileName%
{
    FileDelete, %newFileName%
}

; Save the final content to the new file
FileAppend, %newFileContent%, %newFileName%

MsgBox, % "File processing complete. New file saved as '" . newFileName . "'."