F12::
FileSelectFile, selectedFile,, Please select a .nc file,, *.nc
if (!FileExist(selectedFile))
{
    MsgBox, File does not exist.
    return
}

FileRead, fileContent, %selectedFile%
if (ErrorLevel)
{
    MsgBox, Failed to read the file.
    return
}

; Extract the directory and filename without extension
SplitPath, selectedFile, name, dir, ext, name_no_ext

newFileContent := ""
replacementCount := 0
doubleM4 := false

Loop, parse, fileContent, `n, `r
{
    line := A_LoopField

    ; Delete lines starting with M03, M04, M05, M08, or M09
    if (SubStr(line, 1, 3) = "M03" or SubStr(line, 1, 3) = "M04" or SubStr(line, 1, 3) = "M05" or SubStr(line, 1, 3) = "M08" or SubStr(line, 1, 3) = "M09")
        continue

    ; Keep lines starting with G00, containing Z, and append corresponding M-commands if Z value >= 1
    if (SubStr(line, 1, 3) = "G00" and InStr(line, "Z"))
    {
        RegExMatch(line, "Z(-?\d+(\.\d+)?)", number)
        if (number1 >= 1) and (doubleM4 = false)
        {
            newFileContent .= "M04`nM00`nM03`n" . line . "`n"
	    doubleM4 := true
            replacementCount++
        }
        else
        {
            newFileContent .= line . "`n"
        }
        continue
    }

    ; Keep lines starting with G01 and containing "Z-1", and append corresponding M-commands
    if (SubStr(line, 1, 2) = "G0" and InStr(line, "Z-1"))
    {
        newFileContent  .= "M08`nM00`nM09`n" . line . "`n"
		doubleM4 := false
        replacementCount++
        continue
    }

    ; Copy line as-is
    newFileContent .= line . "`n"
}



; Second analysis to check conditions between M04 and the next M04 or M08
finalContent := ""
inBlock := false
keepBlock := false
blockContent := ""

Loop, parse, newFileContent, `n, `r
{
    line := A_LoopField

    if (inBlock and (SubStr(line, 1, 3) = "M04" or SubStr(line, 1, 3) = "M08"))
    {
        if (keepBlock)
            finalContent .= blockContent
        inBlock := false
        blockContent := ""
        keepBlock := false
    }

    if (SubStr(line, 1, 3) = "M04")
    {
        inBlock := true
        keepBlock := false
        blockContent := line . "`n"
        continue
    }

    if (inBlock)
    {
        blockContent .= line . "`n"
        if (SubStr(line, 1, 1) = "G" and (InStr(line, "X") or InStr(line, "Y")))
            keepBlock := true
    }
    else
        finalContent .= line . "`n"
}

; Construct the new file name
newFileName := dir . "\" . name_no_ext . "_manual." . ext

; Delete the file if it exists to ensure it's replaced
IfExist, %newFileName%
{
    FileDelete, %newFileName%
}

; Save the final content to the new file

FileAppend, %finalContent%, %newFileName%

MsgBox, File processing complete. Modifications made. New file saved as '%newFileName%'.

return
