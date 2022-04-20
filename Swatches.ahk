#NoEnv 
SendMode Input 
SetWorkingDir %A_ScriptDir% 
SetBatchLines, -1

#Include, lib\neutron.ahk

FileInstall, index.html, index.html

window := new NeutronWindow()
window.Load("index.html")
window.Show()

global colors := []
global colorPickerActive := 0
global colorPickerSelectedInput := 0
global colorPickerSelectedIndex := 0

addColor(window, event){
    colors.Push("")
    mapColors(window)
}

changeColor(window, event){
    colorNumber := event.target.id
    colors[colorNumber] := event.target.value
    mapColors(window)
}

copyColor(window, event){
    event.preventDefault()
    clipboard := "#" . colors[event.target.name]
}

deleteColor(window, event){
    colorNumber := event.target.name
    colors.RemoveAt(colorNumber)
    mapColors(window)
}

pickColor(window, event){
    colorPickerSelectedInput := window.doc.getElementById(event.target.name)

    if(colorPickerActive = 0){
        BlockInput, On
        colorPickerActive := 1
        colorPickerSelectedInput.style.background := "red"
        colorPickerSelectedIndex := event.target.name
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
        KeyWait, LButton
        ; BlockInput, Off
    }
    return

mapColors(window){
    flexbox := window.doc.getElementById("flexbox")
        mapStr := ""
        for j, jelement in colors
        {
            mapStr :=  % mapStr . "<div class='color-container'><div style='background-color: #" . colors[j] . "'></div><input id='" . j . "' onChange='ahk.changeColor(event)' value='" . colors[j] . "'></input><button onClick='ahk.deleteColor(event)' name='" . j . "'><img src='delete.svg' /></button><button onClick='ahk.pickColor(event)' name='" . j . "'><img src='dropper.svg' /></button><button onClick='ahk.copyColor(event)' name='" . j . "'><img src='copy.svg' /></button></div>"
        }
        mapStr := % mapStr . "<button class='add-btn' onclick='ahk.addColor(event)'>+</button>"
        flexbox.innerHTML := mapStr
    }



closeApp(){
    ExitApp
}
