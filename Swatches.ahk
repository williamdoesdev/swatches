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
    MsgBox, test
}

mapColors(window){
    flexbox := window.doc.getElementById("flexbox")
        mapStr := ""
        for j, jelement in colors
        {
            mapStr :=  % mapStr . "<div class='color-container' id='" . colors[j] . "'><div></div><input onChange='ahk.changeColor(event)'>" . colors[j] . "</input><button><img src='copy.svg' /></button></div>"
        }
        mapStr := % mapStr . "<button class='add-btn' onclick='ahk.addColor(event)'>+</button>"
        flexbox.innerHTML := mapStr
    }

closeApp(){
    ExitApp
}
