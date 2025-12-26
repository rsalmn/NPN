-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "NPN Hub Premium",
    Icon = "rbxassetid://116236936447443",
    Author = "XYOURZONE | X7 & X5 Logic",
    Folder = "RockHubCombined",
    Size = UDim2.fromOffset(600, 400),
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

local RockHubConfig = Window.ConfigManager:CreateConfig("rockhub_combined")
local function Reg(id, element)
    RockHubConfig:Register(id, element)
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
-- 1. TAB PLAYER
-- =================================================================
do
    local player = Window:Tab({ Title = "Player", Icon = "user" })
    local movement = player:Section({ Title = "Movement", TextSize = 20 })

    local DEFAULT_SPEED = 16
    local DEFAULT_JUMP = 50
    
    Reg("Walkspeed", movement:Slider({
        Title = "WalkSpeed", Step = 1, Value = { Min = 16, Max = 200, Default = 16 },
        Callback = function(value)
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = tonumber(value) end
        end,
    }))

    Reg("slidjump", movement:Slider({
        Title = "JumpPower", Step = 1, Value = { Min = 50, Max = 200, Default = 50 },
        Callback = function(value)
            local hum = GetHumanoid()
            if hum then hum.JumpPower = tonumber(value) end
        end,
    }))

    movement:Button({
        Title = "Reset Movement", Icon = "rotate-ccw",
        Callback = function()
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = DEFAULT_SPEED
                hum.JumpPower = DEFAULT_JUMP
            end
        end
    })

    Reg("frezee", movement:Toggle({
        Title = "Freeze Player", Desc = "Anti-Push / Anchor Position", Value = false,
        Callback = function(state)
            local hrp = GetHRP()
            if hrp then
                hrp.Anchored = state
                if state then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
            end
        end
    }))
end

-- =================================================================
-- 2. TAB FISHING
-- =================================================================
local farm = Window:Tab({ Title = "Fishing", Icon = "fish" })

-- [[ SECTION: X7 SPEED (BETA) - EXISTING ]] --
do
    local MainSection = farm:Section({ Title = "X7 Speed (Beta)", TextSize = 20 })

    -- Variables X7 (Local Scope)
    local Modules = {}
    local featureState = {
        AutoFish = false,
        Instant_ChargeDelay = 0.07,
        Instant_SpamCount = 5,
        Instant_WorkerCount = 1, 
        Instant_StartDelay = 1.20,
        Instant_CatchTimeout = 0.25,
        Instant_CycleDelay = 0.10,
        Instant_ResetCount = 15,
        Instant_ResetPause = 0.1
    }
    local fishingTrove = {}
    local fishCaughtBindable = Instance.new("BindableEvent")

    -- Custom Require X7
    local function customRequire(module)
        if not module then return nil end
        local success, result = pcall(require, module)
        if success then return result end
        local clone = module:Clone()
        clone.Parent = nil
        local s, r = pcall(require, clone)
        return s and r or nil
    end

    -- Load Modules X7
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
            Modules.FishingController = customRequire(RepStorage.Controllers.FishingController)
            Modules.ReplicateTextEffect = NetFolder["RE/ReplicateTextEffect"]
        end)
    end
    LoadX7Modules()

    -- Functions X7
    local function stopAutoFishProcesses()
        featureState.AutoFish = false
        for _, item in ipairs(fishingTrove) do
            if typeof(item) == "RBXScriptConnection" then item:Disconnect()
            elseif typeof(item) == "thread" then task.cancel(item) end
        end
        fishingTrove = {}
        pcall(function() Modules.FishingController:RequestClientStopFishing(true) end)
        if Modules.NetFolder then
             local RF_State = Modules.NetFolder:FindFirstChild("RF/UpdateAutoFishingState")
             if RF_State then pcall(function() RF_State:InvokeServer(false) end) end
        end
    end

    local function equipFishingRod()
        if Modules.EquipToolEvent then pcall(Modules.EquipToolEvent.FireServer, Modules.EquipToolEvent, 1) end
    end

    local function startAutoFishMethod_Instant()
        if not (Modules.ChargeRodFunc and Modules.StartMinigameFunc and Modules.CompleteFishingEvent) then
            LoadX7Modules(); return
        end
        featureState.AutoFish = true
        
        -- Update Server State
        if Modules.NetFolder then
             local RF_State = Modules.NetFolder:FindFirstChild("RF/UpdateAutoFishingState")
             if RF_State then pcall(function() RF_State:InvokeServer(true) end) end
        end

        local chargeCount = 0
        local isCurrentlyResetting = false

        local function worker()
            while featureState.AutoFish and LocalPlayer do
                local currentResetTarget_Worker = featureState.Instant_ResetCount or 15
                if isCurrentlyResetting or chargeCount >= currentResetTarget_Worker then break end

                pcall(function()
                    if not featureState.AutoFish or isCurrentlyResetting then return end
                    
                    if chargeCount < currentResetTarget_Worker then chargeCount = chargeCount + 1 else return end

                    -- Logic X7
                    Modules.ChargeRodFunc:InvokeServer(workspace:GetServerTimeNow())
                    task.wait(featureState.Instant_ChargeDelay)
                    
                    -- Posisi Dinamis
                    local char = LocalPlayer.Character
                    local castPos = char and char.PrimaryPart and (char.PrimaryPart.Position + char.PrimaryPart.CFrame.LookVector * 10) or Vector3.new(-1.25, 1, 0)
                    if typeof(castPos) == "Vector3" then Modules.StartMinigameFunc:InvokeServer(castPos, 100)
                    else Modules.StartMinigameFunc:InvokeServer(-1.25, 1, workspace:GetServerTimeNow()) end
                    
                    task.wait(featureState.Instant_StartDelay)

                    for _ = 1, featureState.Instant_SpamCount do
                        if not featureState.AutoFish then break end
                        Modules.CompleteFishingEvent:FireServer()
                        task.wait(0.01)
                    end

                    -- Wait Signal
                    local signalReceived = false
                    local connection
                    local timeoutThread = task.delay(featureState.Instant_CatchTimeout, function()
                         if not signalReceived and connection then connection:Disconnect() end
                    end)
                    Modules.CancelFishing:InvokeServer()
                    connection = fishCaughtBindable.Event:Connect(function()
                        signalReceived = true
                        if timeoutThread then task.cancel(timeoutThread) end
                        if connection then connection:Disconnect() end
                    end)
                    
                    local wTime = 0
                    while not signalReceived and wTime < featureState.Instant_CatchTimeout do
                        task.wait(0.1); wTime = wTime + 0.1
                        if not featureState.AutoFish then break end
                    end
                    if connection then connection:Disconnect() end
                    Modules.CancelFishing:InvokeServer()
                    pcall(function() Modules.FishingController:RequestClientStopFishing(true) end)
                end)
                task.wait(featureState.Instant_CycleDelay)
            end
        end

        -- Worker Manager
        local autoFishThread = task.spawn(function()
            while featureState.AutoFish do
                chargeCount = 0; isCurrentlyResetting = false
                local batchTrove = {}
                for i = 1, featureState.Instant_WorkerCount do
                    local t = task.spawn(worker)
                    table.insert(batchTrove, t); table.insert(fishingTrove, t)
                end
                while featureState.AutoFish and chargeCount < (featureState.Instant_ResetCount or 15) do task.wait(0.1) end
                isCurrentlyResetting = true
                for _, t in ipairs(batchTrove) do task.cancel(t) end
                task.wait(featureState.Instant_ResetPause)
            end
            stopAutoFishProcesses()
        end)
        table.insert(fishingTrove, autoFishThread)
    end

    -- Detection Logic X7
    if Modules.ReplicateTextEffect then
        Modules.ReplicateTextEffect.OnClientEvent:Connect(function(data)
            if featureState.AutoFish then fishCaughtBindable:Fire("caught") end
        end)
    else
        task.spawn(function()
            while task.wait(1) do if featureState.AutoFish then fishCaughtBindable:Fire("caught") end end
        end)
    end

    Reg("x7toggle", MainSection:Toggle({
        Title = "Enable X7 Speed", Desc = "Logic Worker + Reset (Sangat Cepat).", Value = false,
        Callback = function(v)
            if v then stopAutoFishProcesses(); featureState.AutoFish = true; equipFishingRod(); task.wait(0.2); startAutoFishMethod_Instant()
            else stopAutoFishProcesses() end
        end
    }))
end

-- [[ SECTION: BLATANT V2 (NEW) - X5 LOGIC ]] --
-- Kode ini diambil persis dari request user (X5 Speed) dan diisolasi agar aman
do
    local BlatantV2 = farm:Section({ Title = "Blatant V2 (New)", TextSize = 20 })
    
    -- X5 Variables (Isolated)
    local Modules_X5 = {}
    local featureState_X5 = {
        AutoFish = false,
        Instant_ChargeDelay = 0.07,
        Instant_SpamCount = 5,
        Instant_WorkerCount = 2,
        Instant_StartDelay = 1.20,
        Instant_CatchTimeout = 0.01,
        Instant_CycleDelay = 0.01,
        Instant_ResetCount = 10,
        Instant_ResetPause = 0.01
    }
    local fishingTrove_X5 = {}
    local autoFishThread_X5 = nil
    local fishCaughtBindable_X5 = Instance.new("BindableEvent")

    -- 1. Custom Require X5
    local function customRequire_X5(module)
        if not module then return nil end
        local success, result = pcall(require, module)
        if success then return result end
        local clone = module:Clone()
        clone.Parent = nil
        local s, r = pcall(require, clone)
        return s and r or nil
    end

    -- 2. Load Modules X5
    pcall(function()
        local Controllers = RepStorage:WaitForChild("Controllers", 20)
        local NetFolder = RepStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net", 20)
        local Shared = RepStorage:WaitForChild("Shared", 20)
        
        Modules_X5.Replion = customRequire_X5(RepStorage.Packages.Replion)
        Modules_X5.ItemUtility = customRequire_X5(Shared.ItemUtility)
        Modules_X5.FishingController = customRequire_X5(Controllers.FishingController)
        
        Modules_X5.EquipToolEvent = NetFolder["RE/EquipToolFromHotbar"]
        Modules_X5.ChargeRodFunc = NetFolder["RF/ChargeFishingRod"]
        Modules_X5.StartMinigameFunc = NetFolder["RF/RequestFishingMinigameStarted"]
        Modules_X5.CompleteFishingEvent = NetFolder["RE/FishingCompleted"]
    end)

    -- 3. UI Detection Loop (Detection Logic from X5)
    task.spawn(function()
        local lastFishName = ""
        while task.wait(0.25) do
            local playerGui = LocalPlayer:findFirstChild("PlayerGui")
            if playerGui then
                local notificationGui = playerGui:FindFirstChild("Small Notification")
                if notificationGui and notificationGui.Enabled then
                    local container = notificationGui:FindFirstChild("Display", true) and notificationGui.Display:FindFirstChild("Container", true)
                    if container then
                        local itemNameLabel = container:FindFirstChild("ItemName")
                        if itemNameLabel and itemNameLabel.Text ~= "" and itemNameLabel.Text ~= lastFishName then
                            lastFishName = itemNameLabel.Text
                            -- Trigger Bindable only if X5 is running
                            if featureState_X5.AutoFish then
                                fishCaughtBindable_X5:Fire()
                            end
                        end
                    end
                else
                    lastFishName = ""
                end
            end
        end
    end)

    -- 4. Helper Functions X5
    local function equipFishingRod_X5()
        if Modules_X5.EquipToolEvent then
            pcall(Modules_X5.EquipToolEvent.FireServer, Modules_X5.EquipToolEvent, 1)
        end
    end

    local function stopAutoFishProcesses_X5()
        featureState_X5.AutoFish = false
        for i, item in ipairs(fishingTrove_X5) do
            if typeof(item) == "RBXScriptConnection" then item:Disconnect()
            elseif typeof(item) == "thread" then task.cancel(item) end
        end
        fishingTrove_X5 = {}
        pcall(function()
            if Modules_X5.FishingController and Modules_X5.FishingController.RequestClientStopFishing then
                Modules_X5.FishingController:RequestClientStopFishing(true)
            end
        end)
    end

    -- 5. Main Logic X5 (Worker System)
    local function startAutoFishMethod_Instant_X5()
        if not (Modules_X5.ChargeRodFunc and Modules_X5.StartMinigameFunc and Modules_X5.CompleteFishingEvent) then return end
        featureState_X5.AutoFish = true

        local chargeCount = 0
        local isCurrentlyResetting = false
        local counterLock = false

        local function worker()
            while featureState_X5.AutoFish and LocalPlayer do
                local currentResetTarget = featureState_X5.Instant_ResetCount or 10
                if isCurrentlyResetting or chargeCount >= currentResetTarget then break end

                local success, err = pcall(function()
                    while counterLock do task.wait() end
                    counterLock = true
                    if chargeCount < currentResetTarget then chargeCount = chargeCount + 1 else counterLock = false; return end
                    counterLock = false

                    Modules_X5.ChargeRodFunc:InvokeServer(nil, nil, nil, workspace:GetServerTimeNow())
                    task.wait(featureState_X5.Instant_ChargeDelay)
                    Modules_X5.StartMinigameFunc:InvokeServer(-139, 1, workspace:GetServerTimeNow())
                    task.wait(featureState_X5.Instant_StartDelay)

                    if not featureState_X5.AutoFish or isCurrentlyResetting then return end

                    for _ = 1, featureState_X5.Instant_SpamCount do
                        if not featureState_X5.AutoFish or isCurrentlyResetting then break end
                        Modules_X5.CompleteFishingEvent:FireServer()
                        task.wait(0.05)
                    end

                    if not featureState_X5.AutoFish or isCurrentlyResetting then return end

                    local gotFishSignal = false
                    local connection
                    local timeoutThread = task.delay(featureState_X5.Instant_CatchTimeout, function()
                        if not gotFishSignal and connection then connection:Disconnect() end
                    end)
                    connection = fishCaughtBindable_X5.Event:Connect(function()
                        if gotFishSignal then return end
                        gotFishSignal = true
                        if timeoutThread then task.cancel(timeoutThread) end
                        if connection then connection:Disconnect() end
                    end)

                    while not gotFishSignal and task.wait() do
                        if not featureState_X5.AutoFish or isCurrentlyResetting then break end
                        if timeoutThread and coroutine.status(timeoutThread) == "dead" then break end
                    end
                    if connection then connection:Disconnect() end

                    if Modules_X5.FishingController then
                        pcall(Modules_X5.FishingController.RequestClientStopFishing, Modules_X5.FishingController, true)
                    end
                    task.wait()
                end)
                if not success then task.wait(1) end
                if not featureState_X5.AutoFish then break end
                task.wait(featureState_X5.Instant_CycleDelay)
            end
        end

        -- Worker Manager X5
        autoFishThread_X5 = task.spawn(function()
            while featureState_X5.AutoFish do
                local currentResetTarget = featureState_X5.Instant_ResetCount or 10
                local currentPauseTime = featureState_X5.Instant_ResetPause or 0.01
                chargeCount = 0; isCurrentlyResetting = false
                local batchTrove = {}

                for i = 1, featureState_X5.Instant_WorkerCount do
                    if not featureState_X5.AutoFish then break end
                    local t = task.spawn(worker)
                    table.insert(batchTrove, t); table.insert(fishingTrove_X5, t)
                end

                while featureState_X5.AutoFish and chargeCount < currentResetTarget do task.wait() end
                isCurrentlyResetting = true
                if featureState_X5.AutoFish then
                    for _, t in ipairs(batchTrove) do task.cancel(t) end
                    batchTrove = {}
                    task.wait(currentPauseTime)
                end
            end
            stopAutoFishProcesses_X5()
        end)
        table.insert(fishingTrove_X5, autoFishThread_X5)
    end

    -- 6. UI Elements X5
    Reg("x5startdelay", BlatantV2:Slider({
        Title = "Delay Recast", Desc = "(Default: 1.20)",
        Value = { Min = 0.00, Max = 5.0, Default = featureState_X5.Instant_StartDelay },
        Step = 0.01,
        Callback = function(v) featureState_X5.Instant_StartDelay = tonumber(v) end
    }))

    Reg("x5resetcount", BlatantV2:Slider({
        Title = "Spam Finish", Desc = "Reset after X Casts (Default: 10)",
        Value = { Min = 5, Max = 50, Default = featureState_X5.Instant_ResetCount },
        Step = 1,
        Callback = function(v) featureState_X5.Instant_ResetCount = math.floor(tonumber(v) or 10) end
    }))

    Reg("x5resetpause", BlatantV2:Slider({
        Title = "Cooldown Recast", Desc = "(Default: 0.01)",
        Value = { Min = 0.01, Max = 5, Default = featureState_X5.Instant_ResetPause },
        Step = 0.01,
        Callback = function(v) featureState_X5.Instant_ResetPause = tonumber(v) end
    }))

    Reg("x5toggle", BlatantV2:Toggle({
        Title = "Enable X5 Speed", Desc = "Old Blatant Logic (UI Detection)", Value = false,
        Callback = function(v)
            if v then
                stopAutoFishProcesses_X5()
                featureState_X5.AutoFish = true
                equipFishingRod_X5()
                task.wait(0.01)
                startAutoFishMethod_Instant_X5()
                WindUI:Notify({ Title = "X5 Started", Duration = 2 })
            else
                stopAutoFishProcesses_X5()
                WindUI:Notify({ Title = "X5 Stopped", Duration = 2 })
            end
        end
    }))
    
    BlatantV2:Button({
        Title = "No Animation (Game)", Desc = "Disable all game animations",
        Callback = function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                     local animator = hum:FindFirstChild("Animator")
                     if animator then
                        for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop() end
                     end
                end
            end
        end
    })
end

-- =================================================================
-- 3. TAB SETTINGS & MISC
-- =================================================================
do
    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
    local MiscSection = SettingsTab:Section({ Title = "Misc. Area", TextSize = 20 })

    -- 1. Disable 3D Rendering
    Reg("disable3d", MiscSection:Toggle({
        Title = "Disable 3D Rendering", Value = false, Icon = "monitor-off",
        Callback = function(state)
            RunService:Set3dRenderingEnabled(not state)
        end
    }))
    
    -- 2. FPS Boost
    Reg("fpsboost", MiscSection:Toggle({
        Title = "FPS Ultra Boost", Desc = "Clear textures", Value = false, Icon = "zap",
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            if state then
                Lighting.GlobalShadows = false
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end
                    if v:IsA("Texture") then v.Transparency = 1 end
                end
            end
        end
    }))
    
    -- 3. Remove Fish Notif
    Reg("removenotif", MiscSection:Toggle({
        Title = "Remove Pop-up Notif", Desc = "Hide Small Notification", Value = false, Icon = "bell-off",
        Callback = function(state)
            local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Small Notification")
            if gui then gui.Enabled = not state end
        end
    }))
end

WindUI:Notify({ Title = "NPN Hub Loaded", Content = "X7 & X5 Logic Integrated!", Duration = 5, Icon = "check" })
