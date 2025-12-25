repeat task.wait() until game:IsLoaded()
task.wait(1)

print("[NPN] Script Running...")

-- TEST 1: HttpGet Working?
local ok, res = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/")
end)

print("[NPN] HttpGet:", ok)

-- TEST 2: Load WindUI
local s1, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end)

print("[NPN] WindUI Loaded:", s1, WindUI)

if not s1 or not WindUI then
    warn("[NPN] WindUI gagal load. Stop.")
    return
end

-- TEST 3: Buat Window
local s2, Window = pcall(function()
    return WindUI:CreateWindow({
        Title = "NPN UI DEBUG",
        Icon = "rbxassetid://116236936447443",
    })
end)

print("[NPN] Window Created:", s2, Window)

if not s2 or not Window then
    warn("[NPN] WINDOW GAGAL DIBUAT. STOP.")
    return
end

-- TEST 4: Paksa buka
task.wait(1)

print("[NPN] Trying Toggle...")
pcall(function()
    if Window.Toggle then
        Window:Toggle(true)
        print("[NPN] TOGGLE SUCCESS")
    end
end)

print("[NPN] Trying Open()...")
pcall(function()
    if Window.Open then
        Window:Open()
        print("[NPN] OPEN SUCCESS")
    end
end)

print("[NPN] DONE")
