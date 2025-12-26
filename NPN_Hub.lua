-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "NPN Hub Premium",
    Icon = "rbxassetid://116236936447443",
    Author = "XYOURZONE | Notif Stack",
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
        Instant_ResetPause = 0.1,
        AutoSellMode = "Disabled",
        AutoSellDelay = 1800
    }
    local fishingTrove = {}
    local fishCaughtBindable = Instance.new("BindableEvent")
    local lastSellTime = 0

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
            Modules.SellAllItemsFunc = NetFolder["RF/SellAllItems"]
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

    local function sellAllItems()
        if Modules.SellAllItemsFunc then pcall(Modules.SellAllItemsFunc.InvokeServer, Modules.SellAllItemsFunc) end
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
                    -- Auto Sell Logic
                    if featureState.AutoSellMode ~= "Disabled" and (tick() - lastSellTime > featureState.AutoSellDelay) then
                        sellAllItems(); lastSellTime = tick()
                    end

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

    -- ==========================================================
    -- X7 TUNING (DENGAN INPUT, BUKAN SLIDER)
    -- ==========================================================
    local TuningSection = farm:Section({ Title = "X7 Tuning (Delay Pantat)", TextSize = 18 })

    Reg("x7startdelay", TuningSection:Input({
        Title = "Start Delay",
        Value = tostring(featureState.Instant_StartDelay),
        Placeholder = "1.20",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState.Instant_StartDelay = num end
        end
    }))

    Reg("x7timeout", TuningSection:Input({
        Title = "Catch Timeout",
        Value = tostring(featureState.Instant_CatchTimeout),
        Placeholder = "0.25",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState.Instant_CatchTimeout = num end
        end
    }))

    Reg("x7cycle", TuningSection:Input({
        Title = "Cycle Cooldown",
        Value = tostring(featureState.Instant_CycleDelay),
        Placeholder = "0.10",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState.Instant_CycleDelay = num end
        end
    }))
    
    TuningSection:Toggle({
        Title = "Auto Sell All",
        Value = false,
        Callback = function(state)
            featureState.AutoSellMode = state and "Auto Sell All" or "Disabled"
            if state then lastSellTime = tick() end
        end
    })
end

-- [[ SECTION: BLATANT V2 (NEW) - X5 LOGIC + NOTIF MANIPULATION ]] --
do
    local BlatantV2 = farm:Section({ Title = "Blatant V2 (New)", TextSize = 20 })
    
    -- X5 Variables
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
        Instant_ResetPause = 0.01,
        FakeNotifDelay = 0.5 -- [BARU] Delay antar notifikasi
    }
    local fishingTrove_X5 = {}
    local autoFishThread_X5 = nil
    local fishCaughtBindable_X5 = Instance.new("BindableEvent")

    -- [[ NOTIFICATION QUEUE SYSTEM (BARU) ]] --
    local NotifQueue = {}
    local NotifProcessRunning = false
    local NotifEvent = nil -- Akan diisi saat load modules

    local function TriggerFakeNotification()
        if not NotifEvent or not firesignal then return end
        
        -- Masukkan ke antrian agar menumpuk rapi
        table.insert(NotifQueue, true)
        
        if not NotifProcessRunning then
            task.spawn(function()
                NotifProcessRunning = true
                while #NotifQueue > 0 do
                    table.remove(NotifQueue, 1)
                    
                    -- LOGIC MANIPULASI NOTIFIKASI
                    -- Menggunakan firesignal untuk memalsukan event server
                    pcall(function()
                        firesignal(NotifEvent.OnClientEvent, 
                            196, -- Item ID (Sample)
                            { Weight = 0.84 }, -- Data 1
                            {
                                CustomDuration = 5,
                                Type = "Item",
                                ItemType = "Fishes",
                                _newlyIndexed = false,
                                InventoryItem = {
                                    Favorited = false,
                                    Id = 196,
                                    UUID = "8d7dc388-bc51-4d7e-aece-4961fd5f2146",
                                    Metadata = { Weight = 0.84 }
                                },
                                ItemId = 196
                            },
                            false
                        )
                    end)
                    
                    -- Delay agar notifikasi "menumpuk" di layar (tidak instan hilang)
                    task.wait(featureState_X5.FakeNotifDelay) 
                end
                NotifProcessRunning = false
            end)
        end
    end

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
        
        -- Ambil Event Notifikasi untuk manipulasi
        NotifEvent = NetFolder:FindFirstChild("RE/ObtainedNewFishNotification")
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
                    
                    -- [MANIPULASI] Trigger Fake Notif Disini!
                    -- Ini akan memicu UI "Caught" muncul, sehingga loop di bawah langsung jalan tanpa nunggu server asli
                    TriggerFakeNotification()

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

    -- ==========================================================
    -- X5 TUNING (DENGAN INPUT)
    -- ==========================================================
    
    Reg("x5startdelay", BlatantV2:Input({
        Title = "Delay Recast",
        Value = tostring(featureState_X5.Instant_StartDelay),
        Placeholder = "1.20",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.Instant_StartDelay = num end
        end
    }))
    
    -- [BARU] Pengaturan Delay Notifikasi Palsu
    Reg("x5notifdelay", BlatantV2:Input({
        Title = "Notif Stack Delay",
        Desc = "Jeda antar notif palsu agar terlihat menumpuk.",
        Value = tostring(featureState_X5.FakeNotifDelay),
        Placeholder = "0.5",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.FakeNotifDelay = num end
        end
    }))

    Reg("x5resetcount", BlatantV2:Input({
        Title = "Spam Finish (Reset Count)",
        Value = tostring(featureState_X5.Instant_ResetCount),
        Placeholder = "10",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.Instant_ResetCount = math.floor(num) end
        end
    }))

    Reg("x5resetpause", BlatantV2:Input({
        Title = "Cooldown Recast",
        Value = tostring(featureState_X5.Instant_ResetPause),
        Placeholder = "0.01",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.Instant_ResetPause = num end
        end
    }))

    Reg("x5toggle", BlatantV2:Toggle({
        Title = "Enable X5 Speed", Desc = "Old Blatant + Notif Spoofer", Value = false,
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

-- FISHING AREA SECTION
do
    farm:Divider()
    local areafish = farm:Section({ Title = "Fishing Area", TextSize = 20 })
    
    local FishingAreas = {
        ["Ancient Jungle"] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
        ["Arrow Lever"] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, -0.000, 1.000)},
        ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
        ["Crater Island"] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0.000, 0.615)},
        ["Cresent Lever"] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0.000, -0.000, -1.000)},
        ["Crystalline Passage"] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0.000, 0.994)},
        ["Ancient Ruin"] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, -0.000, -0.949)},
        ["Diamond Lever"] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0.000, 0.000, -1.000)},
        ["Enchant Room"] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Esoteric Island"] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Fisherman Island"] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Hourglass Diamond Lever"] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Kohana"] = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, -0.000, 0.458)},
        ["Lost Isle"] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, -0.000, 0.433)},
        --["Ocean (for element)"] = {Pos = Vector3.new(4675.870, 5.210, -554.690), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Sacred Temple"] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, -0.000, 0.143)},
        ["Second Enchant Altar"] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0.000, -0.955)},
        ["Sisyphus Statue"] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0.000, 0.951)},
        ["Treasure Room"] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0.000, -0.998)},
        ["Tropical Island"] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
        ["Underground Cellar"] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0.000, 0.521)},
        ["Volcano"] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
        ["Weather Machine"] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0.000, 0.999)},
        ["Christmas Island"] = {Pos = Vector3.new(1136.833, 23.573, 1562.916), Look = Vector3.new(0.790, 0.000, -0.613)},
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
    
    -- [VARIABEL GLOBAL ANIMASI] (Perbaikan dari error sebelumnya)
    local originalAnimateScript = nil
    local originalAnimator = nil

    local function EnableAnimations()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- 1. Restore script 'Animate'
        local animateScript = character:FindFirstChild("Animate")
        if animateScript then
            animateScript.Enabled = true
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        -- 2. Restore/Tambahkan Animator
        local existingAnimator = humanoid:FindFirstChildOfClass("Animator")
        if not existingAnimator then
            if originalAnimator then
                originalAnimator.Parent = humanoid
            else
                Instance.new("Animator", humanoid)
            end
        end
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
                    originalAnimateScript = animScript.Enabled -- Simpan status boolean atau instance
                    animScript.Enabled = false 
                end
                
                local animator = Hum:FindFirstChildOfClass("Animator")
                if animator then
                    originalAnimator = animator -- Simpan ke global
                    animator.Parent = nil -- Jangan destroy, cukup parent nil agar bisa direstore
                end
                
                WindUI:Notify({ Title = "No Anim ON", Duration = 2 })
            else
                -- Panggil fungsi global yang ada di atas
                EnableAnimations()
                WindUI:Notify({ Title = "No Anim OFF (Restored)", Duration = 2 })
            end
        end
    })

    -- 4. REMOVE SKIN EFFECT (IMPROVED - BRUTE FORCE CLEANER)
    local SkinCleanerConnection = nil
    
    -- Load VFX Controller (Opsional, untuk hook)
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

WindUI:Notify({ Title = "NPN Hub Loaded", Content = "X7 & X5 Logic Integrated!", Duration = 5, Icon = "check" })
