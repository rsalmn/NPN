repeat task.wait() until game:IsLoaded()
task.wait(1)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "ROCKHUB TEST UI",
    Icon = "rbxassetid://116236936447443"
})

task.wait(1)
Window:Toggle(true)
