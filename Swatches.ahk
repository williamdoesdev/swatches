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

mapColors(window){
    flexbox := window.doc.getElementById("flexbox")
        mapStr := ""
        for j, jelement in colors
        {
            mapStr :=  % mapStr . "<div class='color-container'><div style='background-color: #" . colors[j] . "'></div><input id='" . j . "' onChange='ahk.changeColor(event)' value='" . colors[j] . "'></input><button onClick='ahk.copyColor(event)' name='" . j . "'><img src='copy.svg' /></button></div>"
        }
        mapStr := % mapStr . "<button class='add-btn' onclick='ahk.addColor(event)'>+</button>"
        flexbox.innerHTML := mapStr
    }

closeApp(){
    ExitApp
}
