-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "RockHub (Extracted)",
    Icon = "rbxassetid://116236936447443",
    Author = "Player & Fishing Only",
    Folder = "RockHubExtracted",
    Size = UDim2.fromOffset(600, 360),
    Transparent = true,
    Theme = "Rose",
    Resizable = true,
})

-- [[ GLOBAL VARIABLES & SERVICES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Helper untuk Registry (Agar UI tidak error saat dipanggil Reg)
local RockHubConfig = Window.ConfigManager:CreateConfig("rockhub_extracted")
local ElementRegistry = {}
local function Reg(id, element)
    RockHubConfig:Register(id, element)
    ElementRegistry[id] = element
    return element
end

-- [[ HELPER FUNCTIONS ]] --
local function GetHumanoid()
    local Character = LocalPlayer.Character
    if not Character then Character = LocalPlayer.CharacterAdded:Wait() end
    return Character:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local Character = LocalPlayer.Character
    if not Character then Character = LocalPlayer.CharacterAdded:Wait() end
    return Character:WaitForChild("HumanoidRootPart", 5)
end

local function TeleportToLookAt(position, lookVector)
    local hrp = GetHRP()
    if hrp and typeof(position) == "Vector3" and typeof(lookVector) == "Vector3" then
        local targetCFrame = CFrame.new(position, position + lookVector)
        hrp.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
        WindUI:Notify({ Title = "Teleport Sukses!", Duration = 3, Icon = "map-pin" })
    end
end

-- Remote Handling (Untuk Fishing)
local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
local function GetRemote(remotePath, name, timeout)
    local currentInstance = RepStorage
    for _, childName in ipairs(remotePath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

-- =================================================================
-- 1. TAB PLAYER & LOGIC
-- =================================================================
do
    local player = Window:Tab({ Title = "Player", Icon = "user" })
    local movement = player:Section({ Title = "Movement", TextSize = 20 })

    -- Variables
    local DEFAULT_SPEED = 16
    local DEFAULT_JUMP = 50
    local InfinityJumpConnection = nil
    
    -- WalkSpeed
    local SliderSpeed = Reg("Walkspeed", movement:Slider({
        Title = "WalkSpeed", Step = 1,
        Value = { Min = 16, Max = 200, Default = 16 },
        Callback = function(value)
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = tonumber(value) end
        end,
    }))

    -- JumpPower
    local SliderJump = Reg("slidjump", movement:Slider({
        Title = "JumpPower", Step = 1,
        Value = { Min = 50, Max = 200, Default = 50 },
        Callback = function(value)
            local hum = GetHumanoid()
            if hum then hum.JumpPower = tonumber(value) end
        end,
    }))

    -- Reset Movement
    movement:Button({
        Title = "Reset Movement", Icon = "rotate-ccw",
        Callback = function()
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = DEFAULT_SPEED
                hum.JumpPower = DEFAULT_JUMP
                SliderSpeed:Set(DEFAULT_SPEED)
                SliderJump:Set(DEFAULT_JUMP)
            end
        end
    })

    -- Freeze Player
    Reg("frezee", movement:Toggle({
        Title = "Freeze Player", Desc = "Anti-Push / Anchor Position",
        Value = false,
        Callback = function(state)
            local hrp = GetHRP()
            if hrp then
                hrp.Anchored = state
                if state then
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    hrp.Velocity = Vector3.new(0,0,0)
                end
            end
        end
    }))

    -- ABILITIES SECTION
    local ability = player:Section({ Title = "Abilities", TextSize = 20 })

    -- Infinite Jump
    Reg("infj", ability:Toggle({
        Title = "Infinite Jump", Value = false,
        Callback = function(state)
            if state then
                InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local hum = GetHumanoid()
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
            else
                if InfinityJumpConnection then InfinityJumpConnection:Disconnect() end
            end
        end
    }))

    -- No Clip
    local noclipConnection = nil
    Reg("nclip", ability:Toggle({
        Title = "No Clip", Value = false,
        Callback = function(state)
            if state then
                noclipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                        end
                    end
                end)
            else
                if noclipConnection then noclipConnection:Disconnect() end
            end
        end
    }))

    -- Fly Mode
    local flyConnection, bodyGyro, bodyVel
    local isFlying = false
    Reg("flym", ability:Toggle({
        Title = "Fly Mode", Value = false,
        Callback = function(state)
            local hrp = GetHRP()
            local hum = GetHumanoid()
            local cam = workspace.CurrentCamera
            
            if state and hrp and hum then
                isFlying = true
                bodyGyro = Instance.new("BodyGyro", hrp)
                bodyGyro.P = 9e4; bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyVel = Instance.new("BodyVelocity", hrp)
                bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9); bodyVel.Velocity = Vector3.zero
                
                flyConnection = RunService.RenderStepped:Connect(function()
                    if not isFlying or not hrp then return end
                    bodyGyro.CFrame = cam.CFrame
                    local moveDir = hum.MoveDirection
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                    bodyVel.Velocity = moveDir.Unit * 60
                end)
            else
                isFlying = false
                if flyConnection then flyConnection:Disconnect() end
                if bodyGyro then bodyGyro:Destroy() end
                if bodyVel then bodyVel:Destroy() end
            end
        end
    }))

    -- Walk on Water
    local walkWaterConn, waterPlatform
    Reg("walkwat", ability:Toggle({
        Title = "Walk on Water", Value = false,
        Callback = function(state)
            if state then
                walkWaterConn = RunService.RenderStepped:Connect(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    
                    if not waterPlatform or not waterPlatform.Parent then
                        waterPlatform = Instance.new("Part", workspace)
                        waterPlatform.Name = "WaterPlatform"; waterPlatform.Anchored = true
                        waterPlatform.CanCollide = true; waterPlatform.Transparency = 1; waterPlatform.Size = Vector3.new(15, 1, 15)
                    end
                    
                    local rayOrigin = hrp.Position + Vector3.new(0, 5, 0)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {workspace.Terrain}; rayParams.FilterType = Enum.RaycastFilterType.Include
                    rayParams.IgnoreWater = false
                    
                    local result = workspace:Raycast(rayOrigin, Vector3.new(0, -500, 0), rayParams)
                    if result and result.Material == Enum.Material.Water then
                        waterPlatform.Position = Vector3.new(hrp.Position.X, result.Position.Y, hrp.Position.Z)
                    else
                        waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
                    end
                end)
            else
                if walkWaterConn then walkWaterConn:Disconnect() end
                if waterPlatform then waterPlatform:Destroy() end
            end
        end
    }))

    -- OTHER (ESP)
    local other = player:Section({ Title = "Other", TextSize = 20 })
    local espEnabled, espConnections = false, {}
    
    local function removeESP(plr)
        if espConnections[plr] then
            pcall(function() espConnections[plr].billboard:Destroy() end)
            espConnections[plr] = nil
        end
    end

    local function createESP(target)
        if not target or not target.Character or target == LocalPlayer then return end
        removeESP(target)
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui", target.Character)
        bb.Size = UDim2.new(0, 100, 0, 40); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3, 0)
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
        txt.Text = target.DisplayName; txt.TextColor3 = Color3.new(1,0,0); txt.TextStrokeTransparency = 0
        
        espConnections[target] = {billboard = bb}
    end

    Reg("esp", other:Toggle({
        Title = "Player ESP", Value = false,
        Callback = function(state)
            espEnabled = state
            if state then
                for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
                espConnections.Added = Players.PlayerAdded:Connect(function(p) 
                    p.CharacterAdded:Connect(function() task.wait(1) if espEnabled then createESP(p) end end)
                end)
            else
                for p, _ in pairs(espConnections) do if typeof(p)=="Instance" then removeESP(p) end end
                if espConnections.Added then espConnections.Added:Disconnect() end
            end
        end
    }))
end

-- =================================================================
-- 2. TAB FISHING & LOGIC
-- =================================================================
do
    local farm = Window:Tab({ Title = "Fishing", Icon = "fish" })
    
    -- Variables for Fishing
    local legitAutoState = false
    local normalInstantState = false
    local blatantInstantState = false
    local normalLoopThread, normalEquipThread
    local blatantLoopThread, blatantEquipThread
    local legitClickThread, legitEquipThread
    
    -- Remotes
    local RE_EquipToolFromHotbar = GetRemote(RPath, "RE/EquipToolFromHotbar")
    local RF_ChargeFishingRod = GetRemote(RPath, "RF/ChargeFishingRod")
    local RF_RequestFishingMinigameStarted = GetRemote(RPath, "RF/RequestFishingMinigameStarted")
    local RE_FishingCompleted = GetRemote(RPath, "RE/FishingCompleted")
    local RF_CancelFishingInputs = GetRemote(RPath, "RF/CancelFishingInputs")
    local RF_UpdateAutoFishingState = GetRemote(RPath, "RF/UpdateAutoFishingState")

    local function checkFishingRemotes()
        if not (RE_EquipToolFromHotbar and RF_ChargeFishingRod and RF_RequestFishingMinigameStarted and RE_FishingCompleted) then
            WindUI:Notify({ Title = "Error", Content = "Fishing Remotes not found!", Duration = 5, Icon = "x" })
            return false
        end
        return true
    end

    local function disableOtherModes()
        legitAutoState = false; normalInstantState = false; blatantInstantState = false
        if legitClickThread then task.cancel(legitClickThread) end
        if normalLoopThread then task.cancel(normalLoopThread) end
        if blatantLoopThread then task.cancel(blatantLoopThread) end
    end

    -- SECTION: AUTO FISHING
    local autofish = farm:Section({ Title = "Auto Fishing", TextSize = 20 })

    -- 1. LEGIT MODE
    local SPEED_LEGIT = 0.05
    Reg("legit", autofish:Toggle({
        Title = "Auto Fish (Legit)", Value = false,
        Callback = function(state)
            if not checkFishingRemotes() then return end
            disableOtherModes()
            legitAutoState = state
            
            local FishingController = require(RepStorage.Controllers.FishingController)
            
            if state then
                -- Hook logic simple
                local oldRodStarted = FishingController.FishingRodStarted
                FishingController.FishingRodStarted = function(self, ...)
                    oldRodStarted(self, ...)
                    if legitAutoState then
                        legitClickThread = task.spawn(function()
                            while legitAutoState do
                                FishingController:RequestFishingMinigameClick()
                                task.wait(SPEED_LEGIT)
                            end
                        end)
                    end
                end
                
                -- Auto Equip Loop
                legitEquipThread = task.spawn(function()
                    while legitAutoState do
                        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                        task.wait(0.5)
                    end
                end)
            else
                if legitClickThread then task.cancel(legitClickThread) end
                if legitEquipThread then task.cancel(legitEquipThread) end
            end
        end
    }))

    -- 2. NORMAL INSTANT MODE
    local normalDelay = 1.5
    Reg("tognorm", autofish:Toggle({
        Title = "Normal Instant Fish", Value = false,
        Callback = function(state)
            if not checkFishingRemotes() then return end
            disableOtherModes()
            normalInstantState = state
            
            if state then
                normalLoopThread = task.spawn(function()
                    while normalInstantState do
                        local ts = os.time() + os.clock()
                        pcall(function() RF_ChargeFishingRod:InvokeServer(ts) end)
                        pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6, 0.99) end)
                        task.wait(normalDelay)
                        pcall(function() RE_FishingCompleted:FireServer() end)
                        task.wait(0.3)
                        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                        task.wait(0.1)
                    end
                end)
                
                normalEquipThread = task.spawn(function()
                    while normalInstantState do
                        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                        task.wait(0.5)
                    end
                end)
            else
                if normalLoopThread then task.cancel(normalLoopThread) end
                if normalEquipThread then task.cancel(normalEquipThread) end
            end
        end
    }))

    -- 3. BLATANT MODE (Visual Killer)
    local blatant = farm:Section({ Title = "Blatant Mode", TextSize = 20 })
    Reg("blatantt", blatant:Toggle({
        Title = "Instant Fishing (Blatant)", Desc = "Risky but fast.", Value = false,
        Callback = function(state)
            if not checkFishingRemotes() then return end
            disableOtherModes()
            blatantInstantState = state
            _G.RockHub_BlatantActive = state
            
            if state then
                -- Bypass remote checks
                if RF_UpdateAutoFishingState then pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end) end
                
                blatantLoopThread = task.spawn(function()
                    while blatantInstantState do
                        local ts = os.time() + os.clock()
                        pcall(function() RF_ChargeFishingRod:InvokeServer(ts) end)
                        pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6, 0.99) end)
                        -- Minimal delay for blatant
                        task.wait(1.7) 
                        pcall(function() RE_FishingCompleted:FireServer() end)
                        task.wait(0.3)
                        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                    end
                end)

                -- Visual Spoofing (Bikin tombol merah biar dikira mati)
                task.spawn(function()
                    local InactiveColor = ColorSequence.new(Color3.fromHex("ff5d60"), Color3.fromHex("ff2256"))
                    while _G.RockHub_BlatantActive do
                        for _, btn in ipairs(CollectionService:GetTagged("AutoFishingButton")) do
                            if btn:FindFirstChild("UIGradient") then btn.UIGradient.Color = InactiveColor end
                        end
                        task.wait(0.1)
                    end
                end)
            else
                if RF_UpdateAutoFishingState then pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end) end
                if blatantLoopThread then task.cancel(blatantLoopThread) end
            end
        end
    }))

    -- FISHING AREA SECTION
    farm:Divider()
    local areafish = farm:Section({ Title = "Fishing Area", TextSize = 20 })
    
    local FishingAreas = {
        ["Classic Island"] = {Pos = Vector3.new(1440.8, 46.0, 2777.1), Look = Vector3.new(0.9, 0, 0.3)},
        ["Coral Reef"] = {Pos = Vector3.new(-3207.5, 6.0, 2011.0), Look = Vector3.new(0.9, 0, 0.2)},
        ["Ancient Jungle"] = {Pos = Vector3.new(1535.6, 3.1, -193.3), Look = Vector3.new(0.5, 0, 0.8)},
        ["Roslit"] = {Pos = Vector3.new(-1518.5, 2.8, 1916.1), Look = Vector3.new(0.04, 0, 0.99)},
    }
    
    local AreaNames = {}
    for name, _ in pairs(FishingAreas) do table.insert(AreaNames, name) end
    local selectedArea = nil

    areafish:Dropdown({
        Title = "Choose Area", Values = AreaNames, AllowNone = true,
        Callback = function(opt) selectedArea = opt end
    })

    areafish:Button({
        Title = "Teleport to Chosen Area", Icon = "map-pin",
        Callback = function()
            if selectedArea and FishingAreas[selectedArea] then
                local data = FishingAreas[selectedArea]
                TeleportToLookAt(data.Pos, data.Look)
            else
                WindUI:Notify({ Title = "Pilih Area Dulu", Duration = 3, Icon = "x" })
            end
        end
    })
    
    local freezeToggle
    freezeToggle = areafish:Toggle({
        Title = "Teleport & Freeze (Fix Lag)",
        Callback = function(state)
            local hrp = GetHRP()
            if not hrp then return end
            
            if state then
                if not selectedArea then 
                    WindUI:Notify({Title="Pilih Area Dulu", Duration=3, Icon="x"}); 
                    freezeToggle:Set(false)
                    return 
                end
                
                local data = FishingAreas[selectedArea]
                hrp.Anchored = false
                TeleportToLookAt(data.Pos, data.Look)
                
                WindUI:Notify({Title="Syncing...", Duration=1.5})
                local t = os.clock()
                while (os.clock() - t) < 1.5 and state do
                    hrp.Velocity = Vector3.zero
                    hrp.CFrame = CFrame.new(data.Pos, data.Pos + data.Look)
                    RunService.Heartbeat:Wait()
                end
                
                if state then hrp.Anchored = true end
            else
                hrp.Anchored = false
            end
        end
    })
end

WindUI:Notify({ Title = "Extracted Script Loaded", Content = "Player & Fishing Tabs Only", Duration = 5, Icon = "check" })
