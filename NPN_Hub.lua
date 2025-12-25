-----------------------------------------------
-- N P N   H U B  |  FULL REBUILD VERSION
-----------------------------------------------

repeat task.wait() until game:IsLoaded()
task.wait(1)

-----------------------------------------------
-- LOAD WIND UI
-----------------------------------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "NPN - Fish Hub",
    Icon = "rbxassetid://116236936447443",
    Author = "Premium Version",
    Folder = "NPN",
    Size = UDim2.fromOffset(600, 360),
    Transparent = true,
    Theme = "Rose",
    Resizable = true,
    HideSearchBar = true,
    ScrollBarEnabled = true,
})

local RockHubConfig = Window.ConfigManager:CreateConfig("npn")
local ElementRegistry = {}
local function Reg(id, element)
    RockHubConfig:Register(id, element)
    ElementRegistry[id] = element
    return element
end

task.delay(1,function()
    Window:Toggle(true)
end)

-----------------------------------------------
-- SERVICES
-----------------------------------------------
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-----------------------------------------------
-- PLAYER CORE
-----------------------------------------------
local DEFAULT_SPEED = 18
local DEFAULT_JUMP = 50

local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local hum = GetHumanoid()
local currentSpeed = hum and hum.WalkSpeed or DEFAULT_SPEED
local currentJump = hum and hum.JumpPower or DEFAULT_JUMP

-----------------------------------------------
-- PLAYER TAB
-----------------------------------------------
local player = Window:Tab({Title="Player",Icon="user"})

---------------- Movement ----------------
local movement = player:Section({Title="Movement",TextSize=20})

Reg("WalkSpeed", movement:Slider({
 Title="WalkSpeed",
 Step=1,
 Value={Min=16,Max=200,Default=currentSpeed},
 Callback=function(v)
  local h=GetHumanoid()
  if h then h.WalkSpeed=v end
 end
}))

Reg("JumpPower", movement:Slider({
 Title="JumpPower",
 Step=1,
 Value={Min=50,Max=200,Default=currentJump},
 Callback=function(v)
  local h=GetHumanoid()
  if h then h.JumpPower=v end
 end
}))

movement:Button({
 Title="Reset Movement",
 Icon="rotate-ccw",
 Callback=function()
  local h=GetHumanoid()
  if h then
    h.WalkSpeed=DEFAULT_SPEED
    h.JumpPower=DEFAULT_JUMP
    WindUI:Notify({Title="Reset",Content="Movement Reset",Duration=3})
  end
 end
})

---------------- Freeze ----------------
Reg("Freeze", movement:Toggle({
 Title="Freeze Player",
 Value=false,
 Callback=function(state)
  local hrp = GetHRP()
  if hrp then
    hrp.Anchored = state
    WindUI:Notify({Title = state and "Frozen" or "Unfrozen",Duration=2})
  end
 end
}))

---------------- Walk On Water ----------------
local WoWConnection
local waterPlatform

Reg("WalkOnWater", movement:Toggle({
 Title="Walk On Water",
 Value=false,
 Callback=function(state)
    if state then
        local hrp = GetHRP()
        waterPlatform = Instance.new("Part")
        waterPlatform.Anchored=true
        waterPlatform.Size=Vector3.new(6,1,6)
        waterPlatform.Transparency=1
        waterPlatform.CanCollide=true
        waterPlatform.Parent=workspace

        WoWConnection = RunService.Heartbeat:Connect(function()
            local ray = Ray.new(hrp.Position,Vector3.new(0,-50,0))
            local part,pos = workspace:FindPartOnRay(ray,LocalPlayer.Character)
            if part and part.Material==Enum.Material.Water then
                waterPlatform.Position=Vector3.new(hrp.Position.X,pos.Y+2,hrp.Position.Z)
            end
        end)

    else
        if WoWConnection then WoWConnection:Disconnect() end
        if waterPlatform then waterPlatform:Destroy() end
    end
 end
}))

---------------- Streamer Mode ----------------
local other = player:Section({Title="Streamer Mode",TextSize=20})
local hideConn

Reg("HideName", other:Toggle({
 Title="Hide All Usernames",
 Value=false,
 Callback=function(state)
   if hideConn then hideConn:Disconnect() end
   hideConn = RunService.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local gui = p.Character.Head:FindFirstChild("BillboardGui")
                if gui then gui.Enabled = not state end
            end
        end
   end)
 end
}))

-----------------------------------------------
-- FISHING TAB
-----------------------------------------------
local farm = Window:Tab({Title="Fishing",Icon="fish"})

-----------------------------------------------
-- FishingController
-----------------------------------------------
local Controllers = RepStorage:WaitForChild("Controllers",10)
local FishingController = require(Controllers:WaitForChild("FishingController",10))

-----------------------------------------------
-- Fishing Remotes
-----------------------------------------------
local R = RepStorage:WaitForChild("Remotes",10)

RF_ChargeFishingRod = R:WaitForChild("ChargeFishingRod",10)
RF_RequestFishingMinigameStarted = R:WaitForChild("RequestFishingMinigameStarted",10)
RE_FishingCompleted = R:WaitForChild("FishingCompleted",10)
RF_CancelFishingInputs = R:WaitForChild("CancelFishingInputs",10)
RF_UpdateAutoFishingState = R:WaitForChild("UpdateAutoFishingState",10)
RE_EquipToolFromHotbar = R:WaitForChild("EquipToolFromHotbar",10)

local function checkFishingRemotes()
    return RF_ChargeFishingRod
       and RF_RequestFishingMinigameStarted
       and RE_FishingCompleted
       and RF_CancelFishingInputs
       and RF_UpdateAutoFishingState
       and RE_EquipToolFromHotbar
end

-----------------------------------------------
-- Legit Mode
-----------------------------------------------
Reg("legitfish", farm:Toggle({
 Title="Auto Fish (Legit)",
 Value=false,
 Callback=function(s)
    if checkFishingRemotes() then
        pcall(function()
            RF_UpdateAutoFishingState:InvokeServer(s)
        end)
    end
 end
}))

-----------------------------------------------
-- Normal Instant Mode
-----------------------------------------------
local normal=false
Reg("normal", farm:Toggle({
 Title="Normal Instant Fish",
 Value=false,
 Callback=function(state)
 normal=state
 task.spawn(function()
    while normal do
        pcall(function()
            FishingController:RequestFishingMinigameClick()
        end)
        task.wait(0.08)
    end
 end)
 end
}))

-----------------------------------------------
-- VISUAL SPOOF (LIGHT MODE)
-----------------------------------------------
function SuppressGameVisuals(active)
    -- dibuat ringan → cukup cegah spam notif
end

-----------------------------------------------
-- IMPROVED BLATANT ENGINE V6
-----------------------------------------------
local completeDelay = 3
local cancelDelay = 0.3
local loopInterval = 1.7

local blatantActive = false
local blatantLoop = nil
local equipLoop = nil

local function SafeInvoke(remote,...)
    if not remote then return end
    return pcall(function()
        return remote:InvokeServer(...)
    end)
end

local function SafeFire(remote,...)
    if not remote then return end
    return pcall(function()
        return remote:FireServer(...)
    end)
end

local function KillThread(thread)
    if thread and task.cancel then
        pcall(function()
            task.cancel(thread)
        end)
    end
end

local function runImprovedBlatant()
    if not blatantActive then return end
    if not checkFishingRemotes() then blatantActive=false return end
    
    task.spawn(function()
        local start = os.clock()

        SafeInvoke(RF_ChargeFishingRod, os.time())
        task.wait(0.02)

        SafeInvoke(RF_RequestFishingMinigameStarted, -139.6, 0.9)

        local remaining = completeDelay - (os.clock() - start)
        if remaining > 0 then task.wait(remaining) end
        
        SafeFire(RE_FishingCompleted)
        task.wait(cancelDelay)
        SafeInvoke(RF_CancelFishingInputs)
    end)
end

function SetBlatantState(state)
    blatantActive = state
    _G.RockHub_BlatantActive = state
    
    SuppressGameVisuals(state)

    if state then
        for i=1,3 do
            SafeInvoke(RF_UpdateAutoFishingState,true)
            task.wait(0.25)
        end

        KillThread(blatantLoop)
        KillThread(equipLoop)

        blatantLoop = task.spawn(function()
            while blatantActive do
                runImprovedBlatant()
                task.wait(loopInterval)
            end
        end)

        equipLoop = task.spawn(function()
            while blatantActive do
                SafeFire(RE_EquipToolFromHotbar,1)
                task.wait(0.15)
            end
        end)

        WindUI:Notify({Title="Blatant Improved ON",Duration=3,Icon="zap"})
    else
        SafeInvoke(RF_UpdateAutoFishingState,false)

        KillThread(blatantLoop)
        KillThread(equipLoop)

        blatantLoop=nil
        equipLoop=nil

        WindUI:Notify({Title="Blatant Stopped",Duration=2})
    end
end

-----------------------------------------------
-- BLATANT TOGGLE UI
-----------------------------------------------
local blatantUI = farm:Section({Title="Improved Blatant",TextSize=20})

Reg("improvedblatant", blatantUI:Toggle({
 Title="Improved Blatant Mode v6",
 Value=false,
 Callback=function(state)
    SetBlatantState(state)
 end
}))

print("NPN HUB Loaded Successfully 🎣")
