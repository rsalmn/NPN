-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "NPN Hub Premium",
    Icon = "rbxassetid://116236936447443",
    Author = "XYOURZONE | X7 Logic",
    Folder = "RockHubX7",
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
-- 2. TAB FISHING (INTEGRATED X7 LOGIC)
-- =================================================================
do
    local farm = Window:Tab({ Title = "Fishing", Icon = "fish" })
    local MainSection = farm:Section({ Title = "X7 Speed (Beta)", TextSize = 20 })

    -- [[ X7 VARIABLES & MODULES SETUP ]] --
    local Modules = {}
    local featureState = {
        AutoFish = false,
        AutoSellMode = "Disabled",
        AutoSellDelay = 1800,
        AutoFishHighQuality = false,
        
        -- Default X7 Settings
        Instant_ChargeDelay = 0.07,
        Instant_SpamCount = 5,
        Instant_WorkerCount = 1, -- Default 1 biar aman
        Instant_StartDelay = 1.20,
        Instant_CatchTimeout = 0.25,
        Instant_CycleDelay = 0.10,
        Instant_ResetCount = 15,
        Instant_ResetPause = 0.1
    }
    local fishingTrove = {}
    local lastSellTime = 0
    local fishCaughtBindable = Instance.new("BindableEvent")
    local MainTrove = {}

    -- Helper: Custom Require (Module Loader)
    local function customRequire(module)
        if not module then return nil end
        if not module:IsA("ModuleScript") then return nil end
        local success, result = pcall(require, module)
        if success then return result end
        -- Fallback: Clone
        local cloneSuccess, clone = pcall(function() return module:Clone() end)
        if not cloneSuccess then return nil end
        clone.Parent = nil
        local cloneRequireSuccess, cloneResult = pcall(require, clone)
        return cloneRequireSuccess and cloneResult or nil
    end

    -- LOAD GAME MODULES (CRITICAL FOR X7)
    local function LoadX7Modules()
        pcall(function()
            local Packages = RepStorage:WaitForChild("Packages")
            local NetFolder = Packages:WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
            
            Modules.NetFolder = NetFolder
            Modules.ChargeRodFunc = NetFolder["RF/ChargeFishingRod"]
            Modules.StartMinigameFunc = NetFolder["RF/RequestFishingMinigameStarted"]
            Modules.CompleteFishingEvent = NetFolder["RE/FishingCompleted"]
            Modules.CancelFishing = NetFolder["RF/CancelFishingInputs"]
            Modules.EquipToolEvent = NetFolder["RE/EquipToolFromHotbar"]
            Modules.SellAllItemsFunc = NetFolder["RF/SellAllItems"]
            Modules.ReplicateTextEffect = NetFolder["RE/ReplicateTextEffect"]
            
            -- Load Controllers
            local Controllers = RepStorage:WaitForChild("Controllers")
            Modules.FishingController = customRequire(Controllers:WaitForChild("FishingController"))
        end)
    end
    LoadX7Modules()

    -- Helper Functions for X7
    local function stopAutoFishProcesses()
        featureState.AutoFish = false
        for _, item in ipairs(fishingTrove) do
            if typeof(item) == "RBXScriptConnection" then item:Disconnect()
            elseif typeof(item) == "thread" then task.cancel(item) end
        end
        fishingTrove = {}
        
        -- Reset Client State
        pcall(function()
            if Modules.FishingController and Modules.FishingController.RequestClientStopFishing then
                Modules.FishingController:RequestClientStopFishing(true)
            end
        end)
        
        -- Reset Server State
        local RF_State = Modules.NetFolder and Modules.NetFolder:FindFirstChild("RF/UpdateAutoFishingState")
        if RF_State then pcall(function() RF_State:InvokeServer(false) end) end
    end

    local function equipFishingRod()
        if Modules.EquipToolEvent then
            pcall(Modules.EquipToolEvent.FireServer, Modules.EquipToolEvent, 1)
        end
    end

    local function sellAllItems()
        if Modules.SellAllItemsFunc then
            pcall(Modules.SellAllItemsFunc.InvokeServer, Modules.SellAllItemsFunc)
        end
    end

    local function isLowQualityFish(colorValue)
        if not colorValue then return false end
        local r, g, b
        if typeof(colorValue) == "Color3" then
            r, g, b = colorValue.R, colorValue.G, colorValue.B
        elseif typeof(colorValue) == "ColorSequence" and #colorValue.Keypoints > 0 then
            local c = colorValue.Keypoints[1].Value
            r, g, b = c.R, c.G, c.B
        else
            return false
        end
        -- Check Common (White/Gray)
        if (r > 0.9 and g > 0.9 and b > 0.9) then return true end
        return false
    end

    -- [[ CORE: X7 INSTANT FISHING LOGIC ]] --
    local function startAutoFishMethod_Instant()
        if not (Modules.ChargeRodFunc and Modules.StartMinigameFunc and Modules.CompleteFishingEvent) then
            WindUI:Notify({Title="Error", Content="X7 Modules not ready!", Duration=3, Icon="x"})
            LoadX7Modules() -- Try reload
            return
        end

        featureState.AutoFish = true
        local chargeCount = 0
        local isCurrentlyResetting = false
        local counterLock = false
        
        -- Update Server State
        local RF_State = Modules.NetFolder and Modules.NetFolder:FindFirstChild("RF/UpdateAutoFishingState")
        if RF_State then pcall(function() RF_State:InvokeServer(true) end) end

        local function worker()
            while featureState.AutoFish and LocalPlayer do
                local currentResetTarget_Worker = featureState.Instant_ResetCount or 15
                if isCurrentlyResetting or chargeCount >= currentResetTarget_Worker then break end

                local success, err = pcall(function()
                    -- Auto Sell
                    if featureState.AutoSellMode ~= "Disabled" and (tick() - lastSellTime > featureState.AutoSellDelay) then
                        sellAllItems(); lastSellTime = tick()
                    end

                    if not featureState.AutoFish or isCurrentlyResetting or chargeCount >= currentResetTarget_Worker then return end

                    -- Counter Logic
                    local currentCount = 0
                    local lockTimeout = 0
                    while counterLock do 
                        task.wait(0.01); lockTimeout = lockTimeout + 0.01
                        if lockTimeout > 5 then counterLock = false; break end
                    end
                
                    counterLock = true
                    if chargeCount < currentResetTarget_Worker then
                        chargeCount = chargeCount + 1
                        currentCount = chargeCount
                    else
                        currentCount = chargeCount
                    end
                    counterLock = false

                    if currentCount > currentResetTarget_Worker then return end
                    
                    -- 1. Charge
                    local chargeStartTime = workspace:GetServerTimeNow()
                    Modules.ChargeRodFunc:InvokeServer(chargeStartTime)
                    task.wait(featureState.Instant_ChargeDelay)

                    if not featureState.AutoFish or isCurrentlyResetting then return end
                    
                    -- 2. Start Minigame (Fix Position)
                    -- Menggunakan posisi karakter agar tidak error
                    local char = LocalPlayer.Character
                    local castPos = char and char.PrimaryPart and (char.PrimaryPart.Position + char.PrimaryPart.CFrame.LookVector * 10) or Vector3.new(-1.25, 1, 0)
                    
                    if typeof(castPos) == "Vector3" then
                         Modules.StartMinigameFunc:InvokeServer(castPos, 100)
                    else
                         Modules.StartMinigameFunc:InvokeServer(-1.25, 1, workspace:GetServerTimeNow())
                    end
                    
                    task.wait(featureState.Instant_StartDelay)

                    if not featureState.AutoFish or isCurrentlyResetting then return end
                    
                    -- 3. Spam Complete
                    for _ = 1, featureState.Instant_SpamCount do
                        if not featureState.AutoFish or isCurrentlyResetting then break end
                        Modules.CompleteFishingEvent:FireServer()
                        task.wait(0.01)
                    end

                    if not featureState.AutoFish or isCurrentlyResetting then return end

                    -- 4. Wait for Signal
                    local signalReceived = false
                    local connection
                    local timeoutThread = task.delay(featureState.Instant_CatchTimeout, function()
                        if not signalReceived and connection and connection.Connected then connection:Disconnect() end
                    end)

                    Modules.CancelFishing:InvokeServer()

                    connection = fishCaughtBindable.Event:Connect(function(status)
                        signalReceived = true
                        if timeoutThread then task.cancel(timeoutThread) end
                        if connection and connection.Connected then connection:Disconnect() end
                        
                        if status == "skipped" then
                            pcall(function() Modules.FishingController:RequestClientStopFishing(true) end)
                        end
                    end)

                    -- Fallback Loop
                    local wTime = 0
                    while not signalReceived and wTime < featureState.Instant_CatchTimeout do
                        if not featureState.AutoFish or isCurrentlyResetting then break end
                        task.wait(0.1)
                        wTime = wTime + 0.1
                    end
                    
                    if connection and connection.Connected then connection:Disconnect() end
                    Modules.CancelFishing:InvokeServer()

                    pcall(function() Modules.FishingController:RequestClientStopFishing(true) end)
                end)

                if not success and not tostring(err):find("busy") then warn("Worker Error:", err) end
                if not featureState.AutoFish then break end
                task.wait(featureState.Instant_CycleDelay)
            end
        end

        -- Worker Manager
        local autoFishThread = task.spawn(function()
            while featureState.AutoFish do
                local currentResetTarget = featureState.Instant_ResetCount or 15
                local currentPauseTime = featureState.Instant_ResetPause or 0.1
                chargeCount = 0
                isCurrentlyResetting = false
                local batchTrove = {} 

                for i = 1, featureState.Instant_WorkerCount do
                    if not featureState.AutoFish then break end
                    local workerThread = task.spawn(worker)
                    table.insert(batchTrove, workerThread)
                    table.insert(fishingTrove, workerThread) 
                end

                while featureState.AutoFish and chargeCount < currentResetTarget do task.wait(0.1) end

                isCurrentlyResetting = true 
                if featureState.AutoFish then
                    for _, thread in ipairs(batchTrove) do task.cancel(thread) end
                    batchTrove = {}
                    task.wait(currentPauseTime) 
                end
            end
            stopAutoFishProcesses()
        end)
        table.insert(fishingTrove, autoFishThread)
    end

    -- Toggle Handler
    local function startOrStopAutoFish(shouldStart)
        if shouldStart then
            stopAutoFishProcesses()
            featureState.AutoFish = true
            equipFishingRod()
            task.wait(0.2)
            startAutoFishMethod_Instant()
            WindUI:Notify({Title="X7 Started", Duration=2})
        else
            stopAutoFishProcesses()
            WindUI:Notify({Title="X7 Stopped", Duration=2})
        end
    end

    -- Fish Detection Logic
    if Modules.ReplicateTextEffect then
        local replicateTextConn = Modules.ReplicateTextEffect.OnClientEvent:Connect(function(data)
            if not featureState.AutoFish then return end
            
            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if not (data and data.TextData and data.TextData.EffectType == "Exclaim" and myHead and data.Container == myHead) then
                return
            end
            
            -- Filter Logic
            if featureState.AutoFishHighQuality then
                local colorValue = data.TextData.TextColor
                if colorValue and isLowQualityFish(colorValue) then
                    pcall(function() Modules.FishingController:RequestClientStopFishing(true) end)
                    fishCaughtBindable:Fire("skipped") 
                    return 
                end
            end
            fishCaughtBindable:Fire("caught")
        end)
        table.insert(MainTrove, replicateTextConn)
    else
        -- Fallback Simulation
        task.spawn(function()
            while task.wait(1) do
                if featureState.AutoFish then fishCaughtBindable:Fire("caught") end
            end
        end)
    end

    -- [[ UI ELEMENTS FOR X7 ]] --
    Reg("x7toggle", MainSection:Toggle({
        Title = "Enable X7 Speed",
        Desc = "Logic Worker + Reset (Sangat Cepat).",
        Value = false,
        Callback = startOrStopAutoFish
    }))

    local TuningSection = farm:Section({ Title = "X7 Tuning (Delay Pantat)", TextSize = 18 })

    Reg("x7startdelay", TuningSection:Slider({
        Title = "Start Delay",
        Value = { Min = 0.01, Max = 5.0, Default = featureState.Instant_StartDelay },
        Step = 0.01,
        Callback = function(v) featureState.Instant_StartDelay = tonumber(v) end
    }))

    Reg("x7timeout", TuningSection:Slider({
        Title = "Catch Timeout",
        Value = { Min = 0.01, Max = 5.0, Default = featureState.Instant_CatchTimeout },
        Step = 0.01,
        Callback = function(v) featureState.Instant_CatchTimeout = tonumber(v) end
    }))

    Reg("x7cycle", TuningSection:Slider({
        Title = "Cycle Cooldown",
        Value = { Min = 0.01, Max = 5.0, Default = featureState.Instant_CycleDelay },
        Step = 0.01,
        Callback = function(v) featureState.Instant_CycleDelay = tonumber(v) end
    }))
    
    TuningSection:Toggle({
        Title = "Auto Sell All",
        Value = false,
        Callback = function(state)
            featureState.AutoSellMode = state and "Auto Sell All" or "Disabled"
            if state then lastSellTime = tick() end
        end
    })

    -- FISHING AREA (BAWAAN)
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

-- =================================================================
-- 3. TAB SETTINGS & MISC
-- =================================================================
do
    local SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "settings",
        Locked = false,
    })

    -- [[ MISC SECTION UPDATE ]] --
    local MiscSection = SettingsTab:Section({
        Title = "Misc. Area",
        TextSize = 20,
    })

    -- Dependencies
    local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
    local function GetRemote(remotePath, name, timeout)
        local currentInstance = game:GetService("ReplicatedStorage")
        for _, childName in ipairs(remotePath) do
            currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
            if not currentInstance then return nil end
        end
        return currentInstance:FindFirstChild(name)
    end

    -- 1. REMOVE FISH NOTIFICATION POP-UP
    local DisableNotificationConnection = nil
    MiscSection:Toggle({
        Title = "Remove Fish Notification Pop-up",
        Desc = "Menghilangkan pop-up notifikasi saat menangkap ikan.",
        Value = false,
        Icon = "bell-off",
        Callback = function(state)
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local SmallNotification = PlayerGui:FindFirstChild("Small Notification")
            if not SmallNotification then SmallNotification = PlayerGui:WaitForChild("Small Notification", 5) end

            if state then
                DisableNotificationConnection = RunService.RenderStepped:Connect(function()
                    if SmallNotification then SmallNotification.Enabled = false end
                end)
                WindUI:Notify({ Title = "Notif Diblokir", Duration = 2, Icon = "check" })
            else
                if DisableNotificationConnection then DisableNotificationConnection:Disconnect() end
                if SmallNotification then SmallNotification.Enabled = true end
                WindUI:Notify({ Title = "Notif Normal", Duration = 2, Icon = "check" })
            end
        end
    })

    -- 2. ENABLE FISHING RADAR
    local RF_UpdateFishingRadar = GetRemote(RPath, "RF/UpdateFishingRadar")
    MiscSection:Toggle({
        Title = "Enable Fishing Radar",
        Value = false,
        Icon = "radar",
        Callback = function(state)
            if RF_UpdateFishingRadar then
                pcall(function() RF_UpdateFishingRadar:InvokeServer(state) end)
                WindUI:Notify({ Title = state and "Radar ON" or "Radar OFF", Duration = 2 })
            end
        end
    })

    -- 3. NO ANIMATION (LOGIC FIXED)
    local originalAnimateParent = nil
    local originalAnimateScript = nil
    
    MiscSection:Toggle({
        Title = "No Animation",
        Desc = "Mematikan animasi karakter. (Memulihkan animasi saat dimatikan)",
        Value = false,
        Icon = "activity",
        Callback = function(state)
            local Char = LocalPlayer.Character
            if not Char then return end
            local Hum = Char:FindFirstChild("Humanoid")
            if not Hum then return end

            if state then
                -- SIMPAN & MATIKAN
                local animScript = Char:FindFirstChild("Animate")
                if animScript then
                    originalAnimateScript = animScript
                    animScript.Enabled = false -- Matikan scriptnya
                end
                
                local animator = Hum:FindFirstChildOfClass("Animator")
                if animator then
                    animator:Destroy() -- Hapus animator
                end
                
                WindUI:Notify({ Title = "No Anim ON", Duration = 2 })
            else
                -- PULIHKAN (RESTORE)
                -- 1. Buat Animator Baru jika hilang
                local animator = Hum:FindFirstChildOfClass("Animator")
                if not animator then
                    animator = Instance.new("Animator", Hum)
                end

                -- 2. Restart Script Animate
                local animScript = Char:FindFirstChild("Animate")
                if animScript then
                    animScript.Enabled = false
                    task.wait(0.1)
                    animScript.Enabled = true -- Trigger restart
                end
                
                WindUI:Notify({ Title = "No Anim OFF (Restored)", Duration = 2 })
            end
        end
    })

    -- 4. REMOVE SKIN EFFECT (IMPROVED - BRUTE FORCE CLEANER)
    local SkinCleanerConnection = nil
    local VFXControllerModule = nil
    local originalVFXHandle = nil
    pcall(function()
        VFXControllerModule = require(game:GetService("ReplicatedStorage").Controllers.VFXController)
        originalVFXHandle = VFXControllerModule.Handle
    end)

    MiscSection:Toggle({
        Title = "Remove Skin Effect",
        Desc = "Menghapus paksa semua partikel kosmetik.",
        Value = false,
        Icon = "sparkles",
        Callback = function(state)
            if state then
                -- A. Hook Function (Cara Halus)
                if VFXControllerModule then
                    VFXControllerModule.Handle = function(...) return nil end
                end

                -- B. Brute Force Cleaner (Cara Kasar - Pasti Bersih)
                -- Loop ini akan menghapus efek yang bandel setiap detik
                SkinCleanerConnection = RunService.Stepped:Connect(function()
                    -- 1. Bersihkan CosmeticFolder Global (Biasanya ada di Workspace)
                    local globalCosmetics = workspace:FindFirstChild("CosmeticFolder")
                    if globalCosmetics then
                        globalCosmetics:ClearAllChildren()
                    end

                    -- 2. Bersihkan Efek di Karakter & Tools
                    local Char = LocalPlayer.Character
                    if Char then
                        for _, v in ipairs(Char:GetDescendants()) do
                            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                                v.Enabled = false
                                v:Destroy() 
                            end
                        end
                    end
                end)
                
                WindUI:Notify({ Title = "Skin Effect REMOVED", Duration = 2, Icon = "trash" })
            else
                -- Restore Hook
                if VFXControllerModule and originalVFXHandle then
                    VFXControllerModule.Handle = originalVFXHandle
                end
                
                -- Matikan Cleaner
                if SkinCleanerConnection then
                    SkinCleanerConnection:Disconnect()
                    SkinCleanerConnection = nil
                end
                
                WindUI:Notify({ Title = "Skin Effect ALLOWED", Duration = 2, Icon = "check" })
            end
        end
    })

    -- 5. NO CUTSCENE
    local CutsceneController = nil
    local OldPlayCutscene = nil
    pcall(function()
        CutsceneController = require(game:GetService("ReplicatedStorage").Controllers.CutsceneController)
        OldPlayCutscene = CutsceneController.Play
    end)
    local isNoCutsceneActive = false

    if CutsceneController then
        CutsceneController.Play = function(self, ...)
            if isNoCutsceneActive then return end 
            return OldPlayCutscene(self, ...)
        end
    end

    MiscSection:Toggle({
        Title = "No Cutscene",
        Value = false,
        Icon = "film",
        Callback = function(state)
            isNoCutsceneActive = state
            WindUI:Notify({ Title = state and "No Cutscene ON" or "No Cutscene OFF", Duration = 2 })
        end
    })

    -- 6. DISABLE 3D RENDERING
    MiscSection:Toggle({
        Title = "Disable 3D Rendering",
        Value = false,
        Icon = "monitor-off",
        Callback = function(state)
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local Camera = workspace.CurrentCamera
            
            if state then
                if not _G.BlackScreenGUI then
                    _G.BlackScreenGUI = Instance.new("ScreenGui")
                    _G.BlackScreenGUI.Name = "RockHub_BlackScreen"
                    _G.BlackScreenGUI.IgnoreGuiInset = true
                    _G.BlackScreenGUI.DisplayOrder = 9999
                    _G.BlackScreenGUI.Parent = PlayerGui
                    
                    local Frame = Instance.new("Frame", _G.BlackScreenGUI)
                    Frame.Size = UDim2.new(1,0,1,0); Frame.BackgroundColor3 = Color3.new(0,0,0)
                    local Label = Instance.new("TextLabel", Frame)
                    Label.Size = UDim2.new(1,0,0.1,0); Label.BackgroundTransparency = 1
                    Label.Text = "3D Rendering Disabled"; Label.TextColor3 = Color3.new(1,1,1); Label.TextSize = 20
                end
                _G.BlackScreenGUI.Enabled = true
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(0, -500, 0)
                RunService:Set3dRenderingEnabled(false)
            else
                if _G.BlackScreenGUI then _G.BlackScreenGUI.Enabled = false end
                Camera.CameraType = Enum.CameraType.Custom
                if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
                RunService:Set3dRenderingEnabled(true)
            end
        end
    })

    -- 7. FPS ULTRA BOOST
    MiscSection:Toggle({
        Title = "FPS Ultra Boost",
        Desc = "Menghapus semua tekstur/efek.",
        Value = false,
        Icon = "zap",
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            
            if state then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 
                    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                end
                if Terrain then Terrain.WaterWaveSize = 0 Terrain.WaterTransparency = 1 end
                WindUI:Notify({ Title = "FPS Boost ON", Duration = 2 })
            else
                WindUI:Notify({ Title = "FPS Boost OFF (Rejoin to fix textures)", Duration = 3, Icon = "alert-triangle" })
            end
        end
    })
end

WindUI:Notify({ Title = "NPN Hub Loaded", Content = "X7 Speed Logic Integrated!", Duration = 5, Icon = "check" })
