--============================================================
-- ROCKHUB | WindUI Premium Integration + Player + Fishing
--============================================================

-- WindUI & Config Exact From Your Code ----------------------
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

local RockHubConfig = Window.ConfigManager:CreateConfig("rockhub")
local ElementRegistry = {}

local function Reg(id, element)
    RockHubConfig:Register(id, element)
    ElementRegistry[id] = element
    return element
end

--============================================================
-- BASE SYSTEMS
--============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

--============================================================
-- PLAYER TAB
--============================================================
local player = Window:Tab({Title="Player",Icon="user"})

local DEFAULT_SPEED = 18
local DEFAULT_JUMP = 50

local hum = GetHumanoid()
local currentSpeed = hum and hum.WalkSpeed or DEFAULT_SPEED
local currentJump = hum and hum.JumpPower or DEFAULT_JUMP


-----------------------------------------------------
-- Movement
-----------------------------------------------------
local movement = player:Section({Title="Movement",TextSize=20})

Reg("WalkSpeed", movement:Slider({
 Title="WalkSpeed",
 Step=1,
 Value={Min=16,Max=200,Default=currentSpeed},
 Callback=function(v)
  local h = GetHumanoid()
  if h then h.WalkSpeed=v end
 end
}))

Reg("JumpPower", movement:Slider({
 Title="JumpPower",
 Step=1,
 Value={Min=50,Max=200,Default=currentJump},
 Callback=function(v)
  local h = GetHumanoid()
  if h then h.JumpPower=v end
 end
}))

movement:Button({
 Title="Reset Movement",
 Icon="rotate-ccw",
 Callback=function()
  local h = GetHumanoid()
  if h then
    h.WalkSpeed = DEFAULT_SPEED
    h.JumpPower = DEFAULT_JUMP
    WindUI:Notify({Title="Reset",Content="Movement Reset",Duration=3})
  end
 end
})

-----------------------------------------------------
-- Freeze
-----------------------------------------------------
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


-----------------------------------------------------
-- Walk On Water
-----------------------------------------------------
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
        waterPlatform.Parent=workspace

        WoWConnection = RunService.Heartbeat:Connect(function()
            local ray = Ray.new(hrp.Position,Vector3.new(0,-50,0))
            local part,pos = workspace:FindPartOnRay(ray,LocalPlayer.Character)

            if part and part.Material == Enum.Material.Water then
                waterPlatform.Position = Vector3.new(hrp.Position.X,pos.Y+2,hrp.Position.Z)
            end
        end)

    else
        if WoWConnection then WoWConnection:Disconnect() end
        if waterPlatform then waterPlatform:Destroy() end
    end
 end
}))


-----------------------------------------------------
-- Streamer Mode
-----------------------------------------------------
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

--============================================================
-- FISHING TAB
--============================================================
local farm = Window:Tab({Title="Fishing",Icon="fish"})

-- Safer Controller Load
local Controllers = RepStorage:WaitForChild("Controllers",10)
local FishingController = require(Controllers:WaitForChild("FishingController",10))

-- Remotes
local R = RepStorage:WaitForChild("Remotes",10)

local RF_ChargeFishingRod = R:WaitForChild("ChargeFishingRod",10)
local RF_RequestFishingMinigameStarted = R:WaitForChild("RequestFishingMinigameStarted",10)
local RE_FishingCompleted = R:WaitForChild("FishingCompleted",10)
local RF_CancelFishingInputs = R:WaitForChild("CancelFishingInputs",10)
local RF_UpdateAutoFishingState = R:WaitForChild("UpdateAutoFishingState",10)
local RE_EquipToolFromHotbar = R:WaitForChild("EquipToolFromHotbar",10)

local function checkFishingRemotes()
    return RF_ChargeFishingRod
        and RF_RequestFishingMinigameStarted
        and RE_FishingCompleted
        and RF_CancelFishingInputs
        and RF_UpdateAutoFishingState
        and RE_EquipToolFromHotbar
end

-----------------------------------------------------
-- LEGIT
-----------------------------------------------------
local legit = false
Reg("legitfish", farm:Toggle({
 Title="Auto Fish (Legit)",
 Value=false,
 Callback=function(s)
 legit=s
 if checkFishingRemotes() then
    pcall(function()
        RF_UpdateAutoFishingState:InvokeServer(s)
    end)
 end
 end
}))

-----------------------------------------------------
-- NORMAL
-----------------------------------------------------
local normal=false
Reg("tognorm", farm:Toggle({
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

-----------------------------------------------------
-- LIGHT VISUAL SPOOF
-----------------------------------------------------
function SuppressGameVisuals(active)
    -- dibuat ringan, cukup cegah spam notif
end

-----------------------------------------------------
-- ⭐ IMPROVED BLATANT ENGINE v6
-----------------------------------------------------
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

-----------------------------------------------------
-- ⭐ TOGGLE IMPROVED BLATANT MODE
-----------------------------------------------------
local blatantUI = farm:Section({Title="Improved Blatant Mode",TextSize=20})

Reg("improvedblatant", blatantUI:Toggle({
 Title="Improved Blatant v6",
 Value=false,
 Callback=function(state)
    SetBlatantState(state)
 end
}))

-----------------------------------------------------
-- Area Teleport (Tetap Dipertahankan)
-----------------------------------------------------
local Areas = {
 ["Spawn"] = Vector3.new(0,5,0),
 ["Lake"] = Vector3.new(200,5,200),
 ["Ocean"] = Vector3.new(500,10,500),
}

local names={}
for n,_ in pairs(Areas) do table.insert(names,n) end

local selected=nil

local areafish = farm:Section({Title="Fishing Area",TextSize=20})

areafish:Dropdown({
 Title="Choose Area",
 Values=names,
 Callback=function(v)
  selected=v
 end
})

areafish:Button({
 Title="Teleport",
 Callback=function()
    if selected then
        GetHRP().CFrame = CFrame.new(Areas[selected])
        WindUI:Notify({Title="Teleported"})
    end
 end
})

Reg("freezearea", areafish:Toggle({
 Title="Teleport + Freeze",
 Value=false,
 Callback=function(state)
 if selected then
    local hrp = GetHRP()
    hrp.CFrame=CFrame.new(Areas[selected])
    hrp.Anchored = state
 end
 end
}))

--============================================================
WindUI:Notify({Title="RockHub Loaded",Content="Press F to open UI",Duration=5})
