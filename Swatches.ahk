#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir% 
SetBatchLines, -1

;Library inclusions
#Include, lib\neutron.ahk
#Include, lib\json.ahk
#Include, lib\capturescreen.ahk

;FileInstall necessary files
FileInstall, index.html, index.html
FileInstall, styles.css, styles.css
FileInstall, copy.svg, copy.svg
FileInstall, delete.svg, delete.svg
FileInstall, dropper.svg, dropper.svg

;Instantiate Neutron window
window := new NeutronWindow()
window.Load("index.html")
window.Show("w400 h100")

;State
global colors := []
global colorPickerActive := 0
global colorPickerSelectedInput := 0
global colorPickerSelectedIndex := 0
global currentSwatchPath := ""

;If a file is opened using this script, and it's contents are not empty, assume this is a saved swatch json file and assign it to colors.
if(A_Args[1] != ""){
    FileRead, fileContent, % A_Args[1]
    colors := JSON.Load(fileContent)
    mapColors(window)
    currentSwatchPath := filePath
}

;Save/open json files containing arrays of color values
openFile(window){
    FileSelectFile, filePath
    if(filePath != ""){
        FileRead, fileContent, %filePath%
        colors := JSON.Load(fileContent)
        mapColors(window)
        currentSwatchPath := filePath
    }
}

saveFile(window){
    DllCall("DeleteFileA", "Str", currentSwatchPath)
    FileAppend, % JSON.Dump(colors), % currentSwatchPath
}

saveFileAs(window){
    FileSelectFile, filepath, S
    if(filepath != ""){
        DllCall("DeleteFileA", "Str", filepath)
        FileAppend, % JSON.Dump(colors), % filepath
        currentSwatchPath := filePath
    }
}

;Manipulate the colors array
addColor(window, event){
    colors.Push("")
    mapColors(window)
}

changeColor(window, event){
    colorNumber := event.target.id
    colors[colorNumber] := event.target.value
    mapColors(window)
}

deleteColor(window, event){
    colorNumber := event.target.name
    colors.RemoveAt(colorNumber)
    mapColors(window)
}

moveColorBack(window, event){
    colorNumber := event.target.name
    colors.InsertAt(colorNumber - 1, colors[colorNumber])
    colors.RemoveAt(colorNumber + 1, 1)
    mapColors(window)
}

moveColorForward(window, event){
    colorNumber := event.target.name
    colors.InsertAt(colorNumber + 2, colors[colorNumber])
    colors.RemoveAt(colorNumber, 1)
    mapColors(window)
}

;Copy a color value to the clipboard
copyColor(window, event){
    event.preventDefault()
    clipboard := "#" . colors[event.target.name]
}

;Grab a color value from on-screen
pickColor(window, event){
    colorPickerSelectedInput := window.doc.getElementById(event.target.name)

    if(colorPickerActive = 0){
        BlockInput, On
        colorPickerActive := 1
        colorPickerSelectedInput.style.background := "red"
        colorPickerSelectedIndex := event.target.name

        ;Give time for input to update and take screenshot
        sleep, 5
        CaptureScreen(0, 0, A_ScriptDir . "\temp.png")

        ;Create gui containing screenshot to "freeze" the screen
        Gui, Margin, 0, 0
        Gui, -Border -SysMenu -Caption -DPIScale +ToolWindow +AlwaysOnTop
        Gui, Add, Picture, , % A_ScriptDir . "\temp.png"
        Gui, show, W%A_ScreenWidth% h%A_ScreenHeight% x0 y0 AutoSize
        DllCall("DeleteFileA", "Str", A_ScriptDir . "\temp.png")
    }

}

~LButton::
    if(colorPickerActive = 1){
        colorPickerActive := 0
        colorPickerSelectedInput.style.background := "#545454"
        MouseGetPos, x, y
        PixelGetColor, longColor, x, y, RGB
        StringTrimLeft, color, longColor, 2
        colors[colorPickerSelectedIndex] := color
        mapColors(window)
        Gui, destroy
    }
    return

;Save a color swatch using CTRL S
#IfWinActive Swatches.exe
^S::
    saveFile("")

;Update the UI
mapColors(window){
    flexbox := window.doc.getElementById("flexbox")
        mapStr := ""
        for j, jelement in colors
        {
            mapStr :=  % mapStr . "<div class='color-container'><div style='background-color: #" . colors[j] . "'></div><input id='" . j . "' onChange='ahk.changeColor(event)' value='" . colors[j] . "'></input><button class='smol-btn' onClick='ahk.deleteColor(event)' name='" . j . "'><img src='delete.svg' /></button><button class='smol-btn' onClick='ahk.pickColor(event)' name='" . j . "'><img src='dropper.svg' /></button><button class='smol-btn' onClick='ahk.copyColor(event)' name='" . j . "'><img src='copy.svg' /></button><button class='big-btn' onclick='ahk.moveColorBack(event)' name='" . j . "'><img src='back.svg' /></button><button class='big-btn' onclick='ahk.moveColorForward(event)' name='" . j . "'><img src='forward.svg' /></button></div>"
        }
        mapStr := % mapStr . "<button class='add-btn' onclick='ahk.addColor(event)'>+</button>"
        flexbox.innerHTML := mapStr
    }

closeApp(){
    ExitApp
}
