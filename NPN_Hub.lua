-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "NPN Hub Premium",
    Icon = "rbxassetid://116236936447443",
    Author = "XYOURZONE | All Modes",
    Folder = "RockHubCombined",
    Size = UDim2.fromOffset(600, 450),
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

-- Remote Handling
local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
local function GetRemote(remotePath, name, timeout)
    local currentInstance = RepStorage
    for _, childName in ipairs(remotePath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

-- Remotes Global (Digunakan oleh V3 & Fishing Area)
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

-- [GLOBAL ANIMATION VARIABLES]
local originalAnimateScript = nil
local originalAnimator = nil

local function EnableAnimations()
    local character = LocalPlayer.Character
    if not character then return end
    
    local animScript = character:FindFirstChild("Animate")
    if animScript then animScript.Enabled = true end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local existingAnimator = humanoid:FindFirstChildOfClass("Animator")
    if not existingAnimator then
        if originalAnimator then originalAnimator.Parent = humanoid
        else Instance.new("Animator", humanoid) end
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

-- [[ 1. X7 SPEED (BETA) ]] --
do
    local MainSection = farm:Section({ Title = "1. X7 Speed (Beta)", TextSize = 20 })

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
        Instant_ResetPause = 0.1,
        AutoSellMode = "Disabled",
        AutoSellDelay = 1800
    }
    local fishingTrove = {}
    local fishCaughtBindable = Instance.new("BindableEvent")
    local lastSellTime = 0

    local function customRequire(module)
        if not module then return nil end
        local success, result = pcall(require, module)
        if success then return result end
        local clone = module:Clone()
        clone.Parent = nil
        local s, r = pcall(require, clone)
        return s and r or nil
    end

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
            Modules.FishingController = customRequire(RepStorage.Controllers.FishingController)
            Modules.ReplicateTextEffect = NetFolder["RE/ReplicateTextEffect"]
        end)
    end
    LoadX7Modules()

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

    local function sellAllItems()
        if Modules.SellAllItemsFunc then pcall(Modules.SellAllItemsFunc.InvokeServer, Modules.SellAllItemsFunc) end
    end

    local function startAutoFishMethod_Instant()
        if not (Modules.ChargeRodFunc and Modules.StartMinigameFunc and Modules.CompleteFishingEvent) then
            LoadX7Modules(); return
        end
        featureState.AutoFish = true
        
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
                    if featureState.AutoSellMode ~= "Disabled" and (tick() - lastSellTime > featureState.AutoSellDelay) then
                        sellAllItems(); lastSellTime = tick()
                    end

                    if not featureState.AutoFish or isCurrentlyResetting then return end
                    if chargeCount < currentResetTarget_Worker then chargeCount = chargeCount + 1 else return end

                    Modules.ChargeRodFunc:InvokeServer(workspace:GetServerTimeNow())
                    task.wait(featureState.Instant_ChargeDelay)
                    
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

    -- X7 Tuning (Input)
    local TuningSection = farm:Section({ Title = "X7 Tuning (Delay Pantat)", TextSize = 18 })
    Reg("x7startdelay", TuningSection:Input({ Title = "Start Delay", Value = tostring(featureState.Instant_StartDelay), Placeholder = "1.20", Callback = function(text) local num = tonumber(text); if num then featureState.Instant_StartDelay = num end end }))
    Reg("x7timeout", TuningSection:Input({ Title = "Catch Timeout", Value = tostring(featureState.Instant_CatchTimeout), Placeholder = "0.25", Callback = function(text) local num = tonumber(text); if num then featureState.Instant_CatchTimeout = num end end }))
    Reg("x7cycle", TuningSection:Input({ Title = "Cycle Cooldown", Value = tostring(featureState.Instant_CycleDelay), Placeholder = "0.10", Callback = function(text) local num = tonumber(text); if num then featureState.Instant_CycleDelay = num end end }))
    TuningSection:Toggle({ Title = "Auto Sell All", Value = false, Callback = function(state) featureState.AutoSellMode = state and "Auto Sell All" or "Disabled"; if state then lastSellTime = tick() end end })
end

-- [[ 2. BLATANT V3 (RESTORED) ]] --
do
    local v3 = farm:Section({ Title = "2. Blatant V3 (Advanced Engine)", TextSize = 20 })

    local v3proActive = false
    local v3Loop = nil
    local v3EquipLoop = nil
    local v3proLoopDelay = 1.35
    local v3proCompleteDelay = 2.2
    local v3proCancelDelay = 0.22

    -- UI Tuning V3
    Reg("v3loopdelay", v3:Input({ Title = "V3 Loop Delay", Value = tostring(v3proLoopDelay), Placeholder = "1.35", Callback = function(v) local n = tonumber(v); if n and n >= 0.5 then v3proLoopDelay = n end end }))
    Reg("v3compdelay", v3:Input({ Title = "Catch Delay", Value = tostring(v3proCompleteDelay), Placeholder = "2.2", Callback = function(v) local n = tonumber(v); if n and n >= 0.5 then v3proCompleteDelay = n end end }))
    Reg("v3cancdelay", v3:Input({ Title = "Cancel Delay", Value = tostring(v3proCancelDelay), Placeholder = "0.22", Callback = function(v) local n = tonumber(v); if n and n >= 0.05 then v3proCancelDelay = n end end }))

    local function safeFire(fn) task.spawn(function() pcall(fn) end) end

    local function RunV3Pro()
        if not v3proActive then return end
        if not checkFishingRemotes() then v3proActive = false return end

        task.spawn(function()
            safeFire(function() RF_CancelFishingInputs:InvokeServer() end)
            task.wait(0.05)
            local t = tick()
            safeFire(function() RF_ChargeFishingRod:InvokeServer({[2] = t}) end)
            task.wait(0.01)
            safeFire(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6379699707, 0.99647927980797, t) end)
            task.wait(v3proCompleteDelay)
            safeFire(function() RE_FishingCompleted:FireServer() end)
            task.wait(v3proCancelDelay)
            safeFire(function() RF_CancelFishingInputs:InvokeServer() end)
            task.wait(0.05)
            safeFire(function() RF_ChargeFishingRod:InvokeServer({[2] = t}) end)
            task.wait(0.01)
            safeFire(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6379699707, 0.99647927980797, t) end)
        end)
    end

    local function StartV3Equip()
        v3EquipLoop = task.spawn(function()
            while v3proActive do pcall(function() RE_EquipToolFromHotbar:FireServer(1) end) task.wait(0.08) end
        end)
    end

    local function StartV3Loop()
        v3Loop = task.spawn(function()
            while v3proActive do RunV3Pro() task.wait(v3proLoopDelay) end
        end)
    end

    Reg("v3toggle", v3:Toggle({
        Title = "Enable Blatant V3",
        Value = false,
        Callback = function(s)
            if not checkFishingRemotes() then WindUI:Notify({Title="Missing Remotes", Duration=3}) return end
            v3proActive = s
            if s then
                StartV3Equip(); StartV3Loop()
                WindUI:Notify({ Title="V3 Enabled", Content="Advanced Engine Running", Duration=4, Icon="zap" })
            else
                v3proActive=false
                if v3Loop then task.cancel(v3Loop) v3Loop=nil end
                if v3EquipLoop then task.cancel(v3EquipLoop) v3EquipLoop=nil end
                WindUI:Notify({ Title="V3 Stopped", Duration=2 })
            end
        end
    }))
end

-- [[ 3. BLATANT V2 (NEW) - X5 LOGIC + REAL NOTIF STACK ]] --
do
    local BlatantV2 = farm:Section({ Title = "3. Blatant V2 (New)", TextSize = 20 })
    
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

    -- [[ NOTIFICATION SYSTEM (REAL STACK) ]] --
    local NotifQueue = {}
    local NotifListener = nil
    local NotifProcessRunning = false
    local NotifEvent = nil

    local function deepCopy(original)
        local copy = {}
        for k,v in pairs(original) do
            if type(v) == "table" then v = deepCopy(v) end
            copy[k] = v
        end
        return copy
    end

    local function SetGameNotifState(enabled)
        if NotifEvent and getconnections then
            for _, c in ipairs(getconnections(NotifEvent.OnClientEvent)) do
                pcall(function()
                    if enabled then 
                        if c.Enable then c:Enable() end
                    else 
                        if c.Disable then c:Disable() end
                    end
                end)
            end
        end
    end

    local function ProcessNotifQueue()
        if NotifProcessRunning then return end
        NotifProcessRunning = true
        task.spawn(function()
            while #NotifQueue > 0 do
                local data = table.remove(NotifQueue, 1)
                SetGameNotifState(true)
                if firesignal and NotifEvent then pcall(function() firesignal(NotifEvent.OnClientEvent, table.unpack(data)) end) end
                SetGameNotifState(false)
                task.wait(1.2) 
            end
            NotifProcessRunning = false
        end)
    end

    local function StartInterceptor()
        if NotifListener then NotifListener:Disconnect() NotifListener = nil end
        if not NotifEvent then return end
        SetGameNotifState(false)
        NotifListener = NotifEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if featureState_X5.AutoFish then fishCaughtBindable_X5:Fire() end
            local newArgs = deepCopy(args)
            if newArgs[3] then newArgs[3].CustomDuration = 10 end
            table.insert(NotifQueue, newArgs)
            ProcessNotifQueue()
        end)
    end

    local function StopInterceptor()
        if NotifListener then NotifListener:Disconnect() NotifListener = nil end
        SetGameNotifState(true)
        NotifQueue = {}
    end

    local function customRequire_X5(module)
        if not module then return nil end
        local success, result = pcall(require, module)
        if success then return result end
        local clone = module:Clone()
        clone.Parent = nil
        local s, r = pcall(require, clone)
        return s and r or nil
    end

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
        NotifEvent = NetFolder:FindFirstChild("RE/ObtainedNewFishNotification")
    end)

    local function equipFishingRod_X5()
        if Modules_X5.EquipToolEvent then pcall(Modules_X5.EquipToolEvent.FireServer, Modules_X5.EquipToolEvent, 1) end
    end

    local function stopAutoFishProcesses_X5()
        featureState_X5.AutoFish = false
        StopInterceptor()
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

    local function startAutoFishMethod_Instant_X5()
        if not (Modules_X5.ChargeRodFunc and Modules_X5.StartMinigameFunc and Modules_X5.CompleteFishingEvent) then return end
        featureState_X5.AutoFish = true
        StartInterceptor()
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

    Reg("x5startdelay", BlatantV2:Input({ Title = "Delay Recast", Value = tostring(featureState_X5.Instant_StartDelay), Placeholder = "1.20", Callback = function(text) local num = tonumber(text); if num then featureState_X5.Instant_StartDelay = num end end }))
    Reg("x5resetcount", BlatantV2:Input({ Title = "Spam Finish", Value = tostring(featureState_X5.Instant_ResetCount), Placeholder = "10", Callback = function(text) local num = tonumber(text); if num then featureState_X5.Instant_ResetCount = math.floor(num) end end }))
    Reg("x5resetpause", BlatantV2:Input({ Title = "Cooldown Recast", Value = tostring(featureState_X5.Instant_ResetPause), Placeholder = "0.01", Callback = function(text) local num = tonumber(text); if num then featureState_X5.Instant_ResetPause = num end end }))

    Reg("x5toggle", BlatantV2:Toggle({
        Title = "Enable Blatant V2", Desc = "Old Blatant + Stacked Notif", Value = false,
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
                     if animator then for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop() end end
                end
            end
        end
    })
end

-- FISHING AREA SECTION
do
    farm:Divider()
    local areafish = farm:Section({ Title = "Fishing Area", TextSize = 20 })
    
    local FishingAreas = {
        ["Ancient Jungle"] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
        ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
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

do
    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings", Locked = false })
    local MiscSection = SettingsTab:Section({ Title = "Misc. Area", TextSize = 20 })

    -- 1. NO ANIMATION
    MiscSection:Toggle({
        Title = "No Animation",
        Desc = "Mematikan animasi karakter.",
        Value = false,
        Icon = "activity",
        Callback = function(state)
            local Char = LocalPlayer.Character
            if not Char then return end
            local Hum = Char:FindFirstChild("Humanoid")
            if not Hum then return end

            if state then
                local animScript = Char:FindFirstChild("Animate")
                if animScript then
                    originalAnimateScript = animScript.Enabled
                    animScript.Enabled = false 
                end
                local animator = Hum:FindFirstChildOfClass("Animator")
                if animator then
                    originalAnimator = animator
                    animator.Parent = nil 
                end
                WindUI:Notify({ Title = "No Anim ON", Duration = 2 })
            else
                EnableAnimations()
                WindUI:Notify({ Title = "No Anim OFF (Restored)", Duration = 2 })
            end
        end
    })

    -- 2. REMOVE SKIN EFFECT
    local SkinCleanerConnection = nil
    MiscSection:Toggle({
        Title = "Remove Skin Effect",
        Value = false,
        Icon = "sparkles",
        Callback = function(state)
            if state then
                SkinCleanerConnection = RunService.Stepped:Connect(function()
                    local globalCosmetics = workspace:FindFirstChild("CosmeticFolder")
                    if globalCosmetics then globalCosmetics:ClearAllChildren() end
                end)
                WindUI:Notify({ Title = "Skin Effect REMOVED", Duration = 2 })
            else
                if SkinCleanerConnection then SkinCleanerConnection:Disconnect() end
                WindUI:Notify({ Title = "Skin Effect ALLOWED", Duration = 2 })
            end
        end
    })

    -- 3. DISABLE 3D RENDERING
    MiscSection:Toggle({
        Title = "Disable 3D Rendering",
        Value = false,
        Icon = "monitor-off",
        Callback = function(state)
            RunService:Set3dRenderingEnabled(not state)
        end
    })

    -- 4. FPS BOOST
    MiscSection:Toggle({
        Title = "FPS Ultra Boost",
        Value = false,
        Icon = "zap",
        Callback = function(state)
            if state then
                game:GetService("Lighting").GlobalShadows = false
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end
                    if v:IsA("Texture") then v.Transparency = 1 end
                end
            end
        end
    })
end

WindUI:Notify({ Title = "NPN Hub Loaded", Content = "All Blatant Modes Ready!", Duration = 5, Icon = "check" })
