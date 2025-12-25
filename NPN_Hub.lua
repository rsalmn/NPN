repeat task.wait() until game:IsLoaded()
task.wait(1)

print("[NPN] Script Running...")

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

print("[NPN] WindUI:", ok, WindUI)

if not ok or not WindUI then
    warn("[NPN] WindUI masih gagal")
    return
end

local Window = WindUI:CreateWindow({
    Title = "NPN UI TEST FIX",
    Icon = "rbxassetid://116236936447443"
})

task.wait(1)
Window:Toggle(true)
print("DONE")
