repeat task.wait() until game:IsLoaded()
task.wait(1)

print("[NPN] Loading UI...")

local succ, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end)

if not succ or not WindUI then
    warn("[NPN] WindUI gagal load")
    return
end

local Window = WindUI:CreateWindow({
    Title = "NPN HUB TEST UI",
    Icon = "rbxassetid://116236936447443",
})

print("[NPN] UI Created")

task.delay(1, function()
    if Window and Window.Toggle then
        Window:Toggle(true)
        print("[NPN] UI Opened")
    else
        warn("[NPN] Window exists tapi ga punya Toggle() ??")
    end
end)
