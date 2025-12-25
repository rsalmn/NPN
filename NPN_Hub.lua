local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "RockHub - Fish It",
    Icon = "rbxassetid://116236936447443",
    Author = "Premium Version",
    Folder = "RockHub",
    Size = UDim2.fromOffset(600, 360),
    MinSize = Vector2.new(560, 250),
    MaxSize = Vector2.new(950, 760),
    Transparent = true,
    Theme = "Rose",
    Resizable = true,
    SideBarWidth = 190,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = true,
})

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

