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

local isNoAnimationActive = false
local originalAnimator = nil
local originalAnimateScript = nil

local function DisableAnimations()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not humanoid then return end

    -- 1. Blokir script 'Animate' bawaan (yang memuat default anim)
    local animateScript = character:FindFirstChild("Animate")
    if animateScript and animateScript:IsA("LocalScript") and animateScript.Enabled then
        originalAnimateScript = animateScript.Enabled
        animateScript.Enabled = false
    end

    -- 2. Hapus Animator (menghalangi semua animasi dimainkan/dimuat)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        -- Simpan referensi objek Animator aslinya
        originalAnimator = animator 
        animator:Destroy()
    end
end

local function EnableAnimations()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    -- 1. Restore script 'Animate'
    local animateScript = character:FindFirstChild("Animate")
    if animateScript and originalAnimateScript ~= nil then
        animateScript.Enabled = originalAnimateScript
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- 2. Restore/Tambahkan Animator
    local existingAnimator = humanoid:FindFirstChildOfClass("Animator")
    if not existingAnimator then
        -- Jika Animator tidak ada, dan kita memiliki objek aslinya, restore
        if originalAnimator and not originalAnimator.Parent then
            originalAnimator.Parent = humanoid
        else
            -- Jika objek asli hilang, buat yang baru
            Instance.new("Animator").Parent = humanoid
        end
    end
    originalAnimator = nil -- Bersihkan referensi lama
end

local function OnCharacterAdded(newCharacter)
    if isNoAnimationActive then
        task.wait(0.2) -- Tunggu sebentar agar LoadCharacter selesai
        DisableAnimations()
    end
end

-- Hubungkan ke CharacterAdded agar tetap berfungsi saat respawn
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

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
    local autofish = farm:Section({ Title = "1. Auto Fishing", TextSize = 20 })

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

    -- [[ BLATANT MODE (OLD / KILLER LOGIC) ]] --
    local blatant = farm:Section({ Title = "2. Blatant Mode (Old)", TextSize = 20, })

    local completeDelay = 3.055
    local cancelDelay = 0.3
    local loopInterval = 1.715
    
    _G.RockHub_BlatantActive = false

    -- [[ 1. LOGIC KILLER: LUMPUHKAN CONTROLLER ]]
    task.spawn(function()
        local S1, FishingController = pcall(function() return require(game:GetService("ReplicatedStorage").Controllers.FishingController) end)
        if S1 and FishingController then
            local Old_Charge = FishingController.RequestChargeFishingRod
            local Old_Cast = FishingController.SendFishingRequestToServer
            
            -- Matikan fungsi charge & cast game asli saat Blatant ON
            FishingController.RequestChargeFishingRod = function(...)
                if _G.RockHub_BlatantActive then return end 
                return Old_Charge(...)
            end
            FishingController.SendFishingRequestToServer = function(...)
                if _G.RockHub_BlatantActive then return false, "Blocked by RockHub" end
                return Old_Cast(...)
            end
        end
    end)

    -- [[ 2. REMOTE KILLER: BLOKIR KOMUNIKASI ]]
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if _G.RockHub_BlatantActive and not checkcaller() then
            -- Cegah game mengirim request mancing atau request update state
            if method == "InvokeServer" and (self.Name == "RequestFishingMinigameStarted" or self.Name == "ChargeFishingRod" or self.Name == "UpdateAutoFishingState") then
                return nil 
            end
            if method == "FireServer" and self.Name == "FishingCompleted" then
                return nil
            end
        end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)

    -- [[ 3. UI & NOTIF KILLER (VISUAL SPOOFING) ]]
    -- Ini yang bikin UI tetep kelihatan mati padahal server taunya idup
    local function SuppressGameVisuals(active)
        -- A. Hook Notifikasi biar ga spam "Auto Fishing: Enabled"
        local Succ, TextController = pcall(function() return require(game.ReplicatedStorage.Controllers.TextNotificationController) end)
        if Succ and TextController then
            if active then
                if not TextController._OldDeliver then TextController._OldDeliver = TextController.DeliverNotification end
                TextController.DeliverNotification = function(self, data)
                    -- Filter pesan Auto Fishing
                    if data and data.Text and (string.find(tostring(data.Text), "Auto Fishing") or string.find(tostring(data.Text), "Reach Level")) then
                        return 
                    end
                    return TextController._OldDeliver(self, data)
                end
            elseif TextController._OldDeliver then
                TextController.DeliverNotification = TextController._OldDeliver
                TextController._OldDeliver = nil
            end
        end

        -- B. Paksa Tombol Jadi Merah (Inactive) Setiap Frame
        if active then
            task.spawn(function()
                local RunService = game:GetService("RunService")
                local CollectionService = game:GetService("CollectionService")
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                
                -- Warna Merah (Inactive) dari kode game yang kamu kasih
                local InactiveColor = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHex("ff5d60")), 
                    ColorSequenceKeypoint.new(1, Color3.fromHex("ff2256"))
                })

                while _G.RockHub_BlatantActive do
                    -- Cari tombol Auto Fishing (Bisa di Backpack atau tagged)
                    local targets = {}
                    
                    -- Cek Tag (Cara paling akurat sesuai script game)
                    for _, btn in ipairs(CollectionService:GetTagged("AutoFishingButton")) do
                        table.insert(targets, btn)
                    end
                    
                    -- Fallback cek path manual
                    if #targets == 0 then
                        local btn = PlayerGui:FindFirstChild("Backpack") and PlayerGui.Backpack:FindFirstChild("AutoFishingButton")
                        if btn then table.insert(targets, btn) end
                    end

                    -- Paksa Gradientnya jadi Merah
                    for _, btn in ipairs(targets) do
                        local grad = btn:FindFirstChild("UIGradient")
                        if grad then
                            grad.Color = InactiveColor -- Timpa animasi spr game
                        end
                    end
                    
                    RunService.RenderStepped:Wait()
                end
            end)
        end
    end

    -- [[ UI CONFIG ]]
    local LoopIntervalInput = Reg("blatantint_old", blatant:Input({
        Title = "Blatant Interval", Value = tostring(loopInterval), Icon = "fast-forward", Type = "Input", Placeholder = "1.58",
        Callback = function(input)
            local newInterval = tonumber(input)
            if newInterval and newInterval >= 0.5 then loopInterval = newInterval end
        end
    }))

    local CompleteDelayInput = Reg("blatantcom_old", blatant:Input({
        Title = "Complete Delay", Value = tostring(completeDelay), Icon = "loader", Type = "Input", Placeholder = "2.75",
        Callback = function(input)
            local newDelay = tonumber(input)
            if newDelay and newDelay >= 0.5 then completeDelay = newDelay end
        end
    }))

    local CancelDelayInput = Reg("blatantcanc_old",blatant:Input({
        Title = "Cancel Delay", Value = tostring(cancelDelay), Icon = "clock", Type = "Input", Placeholder = "0.3", Flag = "canlay",
        Callback = function(input)
            local newDelay = tonumber(input)
            if newDelay and newDelay >= 0.1 then cancelDelay = newDelay end
        end
    }))

    local function runBlatantInstant()
        if not blatantInstantState then return end
        if not checkFishingRemotes(true) then blatantInstantState = false return end

        task.spawn(function()
            local startTime = os.clock()
            local timestamp = os.time() + os.clock()
            
            -- Bypass: Panggil remote langsung (Script kita lolos hook checkcaller)
            pcall(function() RF_ChargeFishingRod:InvokeServer(timestamp) end)
            task.wait(0.001)
            pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6379699707, 0.99647927980797) end)
            
            local completeWaitTime = completeDelay - (os.clock() - startTime)
            if completeWaitTime > 0 then task.wait(completeWaitTime) end
            
            pcall(function() RE_FishingCompleted:FireServer() end)
            task.wait(cancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        end)
    end

    local togblat = Reg("blatantt_old",blatant:Toggle({
        Title = "Instant Fishing (Blatant Old)",
        Value = false,
        Callback = function(state)
            if not checkFishingRemotes() then return end
            disableOtherModes("blatant")
            blatantInstantState = state
            _G.RockHub_BlatantActive = state
            
            -- Jalankan Visual Killer
            SuppressGameVisuals(state)
            
            if state then
                -- 1. Server State: ON (Perfection)
                if RF_UpdateAutoFishingState then
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
                end
                task.wait(0.5)
                if RF_UpdateAutoFishingState then
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
                end
                if RF_UpdateAutoFishingState then
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
                end

                -- 2. Loop Kita
                blatantLoopThread = task.spawn(function()
                    while blatantInstantState do
                        runBlatantInstant()
                        task.wait(loopInterval)
                    end
                end)

                -- 3. Auto Equip
                if blatantEquipThread then task.cancel(blatantEquipThread) end
                blatantEquipThread = task.spawn(function()
                    while blatantInstantState do
                        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                        task.wait(0.1) 
                    end
                end)
                StopNotifListener()
                WindUI:Notify({ Title = "Blatant Mode ON", Duration = 3, Icon = "zap" })
            else
                -- 4. Server State: OFF
                if RF_UpdateAutoFishingState then
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end)
                end

                if blatantLoopThread then task.cancel(blatantLoopThread) blatantLoopThread = nil end
                if blatantEquipThread then task.cancel(blatantEquipThread) blatantEquipThread = nil end
                
                WindUI:Notify({ Title = "Stopped", Duration = 2 })
            end
        end
    }))
end

do
    ------------------------------------------------------------
    -- REAL FISH NOTIFICATION QUEUE ENGINE (SAFE)
    ------------------------------------------------------------
    local RepStorage = game:GetService("ReplicatedStorage")
    local Net = RepStorage.Packages._Index["sleitnick_net@0.2.0"].net

    local ObtainedNotifEvent = Net["RE/ObtainedNewFishNotification"]

    local NotifQueue = {}
    local NotifProcessing = false
    local FishNotifConnection = nil
    local NotificationEnabled = false

    local function DeepCopy(tbl)
        local new = {}
        for k,v in pairs(tbl) do
            new[k] = (type(v)=="table") and DeepCopy(v) or v
        end
        return new
    end

    local function ProcessNotifQueue()
        if NotifProcessing then return end
        NotifProcessing = true

        task.spawn(function()
            while #NotifQueue > 0 do
                local data = table.remove(NotifQueue, 1)

                if firesignal and NotifEvent then
                    pcall(function()
                        firesignal(NotifEvent.OnClientEvent, table.unpack(data))
                    end)
                end
                
                task.wait(1.2) -- delay tampil satu per satu
            end

            NotifProcessing = false
        end)
    end

    function StartFishNotificationControl()
        NotificationEnabled = true

        if FishNotifConnection then
            FishNotifConnection:Disconnect()
        end

        FishNotifConnection = ObtainedNotifEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            local data = args[3]

            if data and data.CustomDuration == 15 then
                return
            end

            local cloned = DeepCopy(args)
            if cloned[3] then
                cloned[3].CustomDuration = 15
            end

            table.insert(NotifQueue, cloned)
            ProcessQueue()
        end)
    end

    function StopFishNotificationControl()
        NotificationEnabled = false

        if FishNotifConnection then
            FishNotifConnection:Disconnect()
            FishNotifConnection = nil
        end

        NotifQueue = {}
    end



    ------------------------------------------------------------
    -- 🔥 BLATANT V2 (ULTIMATE FIX VERSION)
    ------------------------------------------------------------
    local v2 = farm:Section({
        Title = "3. Blatant V2 (Ultimate Stable Edition)",
        TextSize = 20
    })

    local v2Active = false
    local v2Loop = nil
    local v2EquipLoop = nil
    local v2Watchdog = nil

    local v2LoopDelay = 1.25
    local v2CatchDelay = 2.05
    local v2CancelDelay = 0.22

    -------------------------------------------------
    -- UI
    -------------------------------------------------
    Reg("v2loopdelay", v2:Input({
        Title="Loop Delay",
        Value=tostring(v2LoopDelay),
        Placeholder="1.25",
        Callback=function(v)
            local n=tonumber(v)
            if n and n>=0.4 then v2LoopDelay=n end
        end
    }))

    Reg("v2catchdelay", v2:Input({
        Title="Catch Delay",
        Value=tostring(v2CatchDelay),
        Placeholder="2.05",
        Callback=function(v)
            local n=tonumber(v)
            if n and n>=0.5 then v2CatchDelay=n end
        end
    }))

    Reg("v2canceldelay", v2:Input({
        Title="Completely Delay",
        Value=tostring(v2CancelDelay),
        Placeholder="0.22",
        Callback=function(v)
            local n=tonumber(v)
            if n and n>=0.05 then v2CancelDelay=n end
        end
    }))


    -------------------------------------------------
    -- SAFE THREAD WRAPPER
    -------------------------------------------------
    local function safe(fn)
        task.spawn(function()
            pcall(fn)
        end)
    end


    -------------------------------------------------
    -- MAIN ENGINE
    -------------------------------------------------
    local function RunV2()
        if not v2Active then return end
        if not checkFishingRemotes() then
            v2Active = false
            return
        end

        task.spawn(function()

            -- Reset state awal
            safe(function()
                RF_CancelFishingInputs:InvokeServer()
            end)

            task.wait(0.05)

            local t = tick()

            -- Charge rod
            safe(function()
                RF_ChargeFishingRod:InvokeServer({[2]=t})
            end)

            task.wait(0.01)

            -- Start minigame
            safe(function()
                RF_RequestFishingMinigameStarted:InvokeServer(
                    -139.6379699707,
                    0.99647927980797,
                    t
                )
            end)

            -- tunggu ikannya "seolah" dimainin
            task.wait(v2CatchDelay)

            -- Complete
            safe(function()
                RE_FishingCompleted:FireServer()
            end)

            -- delay aman
            task.wait(v2CancelDelay)

            -- Cancel
            safe(function()
                RF_CancelFishingInputs:InvokeServer()
            end)

            -- Recast cepat
            task.wait(0.05)

            safe(function()
                RF_ChargeFishingRod:InvokeServer({[2]=t})
            end)

            task.wait(0.01)

            safe(function()
                RF_RequestFishingMinigameStarted:InvokeServer(
                    -139.6379699707,
                    0.99647927980797,
                    t
                )
            end)
        end)
    end


    -------------------------------------------------
    -- AUTO EQUIP
    -------------------------------------------------
    local function StartV2Equip()
        v2EquipLoop = task.spawn(function()
            while v2Active do
                pcall(function()
                    RE_EquipToolFromHotbar:FireServer(1)
                end)
                task.wait(0.08)
            end
        end)
    end


    -------------------------------------------------
    -- LOOP
    -------------------------------------------------
    local function StartV2Loop()
        v2Loop = task.spawn(function()
            while v2Active do
                RunV2()
                task.wait(v2LoopDelay)
            end
        end)
    end


    -------------------------------------------------
    -- WATCHDOG (Anti Stuck)
    -------------------------------------------------
    local function StartWatchdog()
        v2Watchdog = task.spawn(function()
            while v2Active do
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)
                task.wait(6)
            end
        end)
    end


    -------------------------------------------------
    -- TOGGLE
    -------------------------------------------------
    Reg("v2toggle", v2:Toggle({
        Title="Enable Blatant V2",
        Value=false,
        Callback=function(s)

            if not checkFishingRemotes() then
                WindUI:Notify({
                    Title="Missing Remotes",
                    Duration=3
                })
                return
            end

            v2Active=s

            if s then
                if normal~=nil then normal=false end
                if v3proActive~=nil then v3proActive=false end
                if hyperActive~=nil then hyperActive=false end

                StartV2Equip()
                StartV2Loop()
                StartWatchdog()
                StartFishNotificationControl()

                WindUI:Notify({
                    Title="Blatant V2 Enabled",
                    Content="Ultimate Stable Mode + Notification Queue",
                    Duration=4,
                    Icon="zap"
                })

            else
                v2Active=false

                if v2Loop then task.cancel(v2Loop) v2Loop=nil end
                if v2EquipLoop then task.cancel(v2EquipLoop) v2EquipLoop=nil end
                if v2Watchdog then task.cancel(v2Watchdog) v2Watchdog=nil end

                StopFishNotificationControl()

                pcall(function()
                    RF_UpdateAutoFishingState:InvokeServer(false)
                end)

                WindUI:Notify({
                    Title="Blatant V2 Stopped",
                    Duration=2
                })
            end
        end
    }))

end

-- [[ 2. BLATANT V3 (RESTORED) ]] --
do
    local v3 = farm:Section({ Title = "4. Blatant V3 (Advanced Engine)", TextSize = 20 })

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

------------------------------------------------------------
-- BLATANT V4 - FINAL STABLE EDITION
-- Fast + Safe + Adaptive
------------------------------------------------------------
do
    local v4 = farm:Section({
        Title = "5 Blatant V4 (Final)",
        TextSize = 20
    })

    local RepStorage = game:GetService("ReplicatedStorage")

    local NetFolder = RepStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")

    local RF_ChargeFishingRod = NetFolder["RF/ChargeFishingRod"]
    local RF_RequestFishingMinigameStarted = NetFolder["RF/RequestFishingMinigameStarted"]
    local RF_CancelFishingInputs = NetFolder["RF/CancelFishingInputs"]
    local RF_UpdateAutoFishingState = NetFolder["RF/UpdateAutoFishingState"]
    local RE_FishingCompleted = NetFolder["RE/FishingCompleted"]
    local RE_MinigameChanged = NetFolder["RE/FishingMinigameChanged"]

    ------------------------------------------------------------
    -- STATE
    ------------------------------------------------------------
    local V4_Active = false
    local V4_LoopThread = nil

    local State = {
        lastComplete = 0,
        cooldown = 0.35,
        doingCycle = false,
        lastCast = 0
    }

    ------------------------------------------------------------
    -- DEFAULT CONFIG (SAFE + FAST)
    ------------------------------------------------------------
    local V4_CompleteDelay = 0.72
    local V4_CancelDelay = 0.28
    local V4_RecastDelay = 0.001

    ------------------------------------------------------------
    -- SAFE WRAPPER
    ------------------------------------------------------------
    local function safe(fn)
        task.spawn(function()
            pcall(fn)
        end)
    end

    ------------------------------------------------------------
    -- INTERNAL LOGIC
    ------------------------------------------------------------
    local function ProtectedComplete()
        local now = tick()
        if now - State.lastComplete < State.cooldown then
            return false
        end

        State.lastComplete = now
        safe(function()
            RE_FishingCompleted:FireServer()
        end)

        return true
    end

    local function PerformCast()
        local t = tick()
        State.lastCast = t

        safe(function()
            RF_ChargeFishingRod:InvokeServer({[1]=t})
        end)

        task.wait(0.008)

        safe(function()
            RF_RequestFishingMinigameStarted:InvokeServer(
                1,
                0,
                t
            )
        end)
    end

    ------------------------------------------------------------
    -- MAIN LOOP
    ------------------------------------------------------------
    local function V4_Loop()
        while V4_Active do
            State.doingCycle = true

            PerformCast()

            task.wait(V4_CompleteDelay)

            if V4_Active then
                ProtectedComplete()
            end

            task.wait(V4_CancelDelay)

            if V4_Active then
                safe(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)
            end

            State.doingCycle = false
            task.wait(V4_RecastDelay)
        end

        State.doingCycle = false
    end

    ------------------------------------------------------------
    -- REALTIME FAILSAFE SYNC
    ------------------------------------------------------------
    local lastEvent = 0

    RE_MinigameChanged.OnClientEvent:Connect(function()
        if not V4_Active then return end

        local now = tick()
        if now - lastEvent < 0.15 then return end
        lastEvent = now

        if now - State.lastComplete < 0.25 then return end

        task.spawn(function()
            task.wait(V4_CompleteDelay)

            if ProtectedComplete() then
                task.wait(V4_CancelDelay)
                safe(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)
            end
        end)
    end)

    ------------------------------------------------------------
    -- UI INPUTS
    ------------------------------------------------------------
    Reg("v4_complete", v4:Input({
        Title="Complete Delay",
        Value=tostring(V4_CompleteDelay),
        Placeholder="0.72",
        Callback=function(v)
            local n = tonumber(v)
            if n and n >= 0.1 then
                V4_CompleteDelay = n
            end
        end
    }))

    Reg("v4_cancel", v4:Input({
        Title="Cancel Delay",
        Value=tostring(V4_CancelDelay),
        Placeholder="0.28",
        Callback=function(v)
            local n = tonumber(v)
            if n and n >= 0.1 then
                V4_CancelDelay = n
            end
        end
    }))

    Reg("v4_recast", v4:Input({
        Title="Recast Delay",
        Value=tostring(V4_RecastDelay),
        Placeholder="0.001",
        Callback=function(v)
            local n = tonumber(v)
            if n and n >= 0 then
                V4_RecastDelay = n
            end
        end
    }))

    ------------------------------------------------------------
    -- TOGGLE
    ------------------------------------------------------------
    Reg("v4toggle", v4:Toggle({
        Title = "Enable Blatant V4 (Final)",
        Value = false,
        Callback = function(state)

            if not checkFishingRemotes() then
                WindUI:Notify({
                    Title="Missing Remotes",
                    Content="Fishing Remotes Not Found",
                    Duration=3
                })
                return
            end

            V4_Active = state

            if state then
                if v2Active ~= nil then v2Active = false end
                if blatantInstantState ~= nil then blatantInstantState = false end

                safe(function()
                    RF_UpdateAutoFishingState:InvokeServer(true)
                end)

                V4_LoopThread = task.spawn(V4_Loop)

                WindUI:Notify({
                    Title="Blatant V4 Enabled",
                    Content="Final Stable Mode Activated",
                    Duration=4,
                    Icon="zap"
                })

            else
                V4_Active = false
                
                if V4_LoopThread then
                    task.cancel(V4_LoopThread)
                    V4_LoopThread = nil
                end

                safe(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                WindUI:Notify({
                    Title="Blatant V4 Stopped",
                    Duration=3
                })
            end
        end
    }))
end

do
    ------------------------------------------------------------
    -- BLATANT V5 (TESTER)
    -- Ultra Spam Mode (Gila Cepat, tapi Experimental)
    ------------------------------------------------------------
    local v5 = farm:Section({
        Title = "Blatant V5 (Tester)",
        TextSize = 20
    })

    local RepStorage = game:GetService("ReplicatedStorage")

    local NetFolder = RepStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")

    local RF_ChargeFishingRod = NetFolder["RF/ChargeFishingRod"]
    local RF_RequestFishingMinigameStarted = NetFolder["RF/RequestFishingMinigameStarted"]
    local RF_CancelFishingInputs = NetFolder["RF/CancelFishingInputs"]
    local RF_UpdateAutoFishingState = NetFolder["RF/UpdateAutoFishingState"]
    local RE_FishingCompleted = NetFolder["RE/FishingCompleted"]
    local RE_MinigameChanged = NetFolder["RE/FishingMinigameChanged"]

    ------------------------------------------------------------
    -- STATE
    ------------------------------------------------------------
    local V5_Active = false
    local V5_Thread = nil

    local V5_CompleteDelay = 0.001
    local V5_CancelDelay = 0.001

    ------------------------------------------------------------
    -- SAFE WRAPPER
    ------------------------------------------------------------
    local function safe(fn)
        task.spawn(function()
            pcall(fn)
        end)
    end


    ------------------------------------------------------------
    -- CORE SPAM ENGINE
    ------------------------------------------------------------
    local function V5_Loop()
        while V5_Active do
            local t = tick()

            -- CAST
            safe(function()
                RF_ChargeFishingRod:InvokeServer({[1] = t})
            end)

            safe(function()
                RF_RequestFishingMinigameStarted:InvokeServer(1, 0, t)
            end)

            -- COMPLETE
            task.wait(V5_CompleteDelay)

            if not V5_Active then break end

            safe(function()
                RE_FishingCompleted:FireServer()
            end)

            -- CANCEL
            task.wait(V5_CancelDelay)

            if not V5_Active then break end

            safe(function()
                RF_CancelFishingInputs:InvokeServer()
            end)
        end
    end


    ------------------------------------------------------------
    -- BACKUP FAILSAFE LISTENER
    ------------------------------------------------------------
    RE_MinigameChanged.OnClientEvent:Connect(function()
        if not V5_Active then return end

        task.spawn(function()
            task.wait(V5_CompleteDelay)

            safe(function()
                RE_FishingCompleted:FireServer()
            end)

            task.wait(V5_CancelDelay)

            safe(function()
                RF_CancelFishingInputs:InvokeServer()
            end)
        end)
    end)


    ------------------------------------------------------------
    -- UI INPUTS
    ------------------------------------------------------------
    Reg("v5_complete", v5:Input({
        Title = "Complete Delay",
        Value = tostring(V5_CompleteDelay),
        Placeholder = "0.001",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0 then
                V5_CompleteDelay = n
            end
        end
    }))

    Reg("v5_cancel", v5:Input({
        Title = "Cancel Delay",
        Value = tostring(V5_CancelDelay),
        Placeholder = "0.001",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0 then
                V5_CancelDelay = n
            end
        end
    }))


    ------------------------------------------------------------
    -- TOGGLE
    ------------------------------------------------------------
    Reg("v5toggle", v5:Toggle({
        Title = "Enable Blatant V5 (Tester)",
        Value = false,
        Callback = function(state)

            if not checkFishingRemotes() then
                WindUI:Notify({
                    Title = "Missing Remotes",
                    Content = "Fishing Remotes Not Found",
                    Duration = 3
                })
                return
            end

            V5_Active = state

            if state then
                -- disable other modes
                if v2Active ~= nil then v2Active = false end
                if V4_Active ~= nil then V4_Active = false end
                if blatantInstantState ~= nil then blatantInstantState = false end

                safe(function()
                    RF_UpdateAutoFishingState:InvokeServer(true)
                end)

                V5_Thread = task.spawn(V5_Loop)

                WindUI:Notify({
                    Title = "Blatant V5 Enabled",
                    Content = "Ultra Spam Tester Activated",
                    Duration = 4,
                    Icon = "zap"
                })

            else
                V5_Active = false

                if V5_Thread then
                    task.cancel(V5_Thread)
                    V5_Thread = nil
                end

                safe(function()
                    RF_UpdateAutoFishingState:InvokeServer(true)
                end)

                task.wait(0.2)

                safe(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                WindUI:Notify({
                    Title = "Blatant V5 Stopped",
                    Duration = 3
                })
            end
        end
    }))

end
-- FISHING SUPPORT

do
    farm:Divider()
    local fishingSupport = farm:Section({ Title = "Fishing Support (Tools)",  TextSize = 20})

    local REObtainedNewFishNotification = GetRemote(RPath, "RE/ObtainedNewFishNotification")
    local RunService = game:GetService("RunService")

    local notif = Reg("togglenot",fishingSupport:Toggle({
        Title = "Remove Fish Notification Pop-up",
        Value = false,
        Icon = "slash",
        Callback = function(state)
            local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
            local SmallNotification = PlayerGui:FindFirstChild("Small Notification")
            
            if not SmallNotification then
                SmallNotification = PlayerGui:WaitForChild("Small Notification", 5)
                if not SmallNotification then
                    WindUI:Notify({ Title = "Error", Duration = 3, Icon = "x" })
                    return false
                end
            end

            if state then
                -- ON: Menggunakan RenderStepped untuk pemblokiran per-frame
                DisableNotificationConnection = RunService.RenderStepped:Connect(function()
                    -- Memastikan GUI selalu mati pada setiap frame render
                    SmallNotification.Enabled = false
                end)
                
                WindUI:Notify({ Title = "Pop-up Diblokir",Duration = 3, Icon = "check" })
            else
                -- OFF: Putuskan koneksi RenderStepped
                if DisableNotificationConnection then
                    DisableNotificationConnection:Disconnect()
                    DisableNotificationConnection = nil
                end

                -- Kembalikan GUI ke status normal (aktif)
                SmallNotification.Enabled = true
                
                WindUI:Notify({ Title = "Pop-up Diaktifkan", Content = "Notifikasi kembali normal.", Duration = 3, Icon = "x" })
            end
        end
    }))

    -- 2. ENABLE FISHING RADAR
    local RF_UpdateFishingRadar = GetRemote(RPath, "RF/UpdateFishingRadar")
    fishingSupport:Toggle({
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
    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings", Locked = false })
    local MiscSection = SettingsTab:Section({ Title = "Misc. Area", TextSize = 20 })

    -- 1. NO ANIMATION
    MiscSection:Toggle({
        Title = "No Animation",
        Desc = "Mematikan animasi karakter.",
        Value = false,
        Icon = "activity",
        Callback = function(state)
            isNoAnimationActive = state
            if state then
                DisableAnimations()
                WindUI:Notify({ Title = "No Animation ON!", Duration = 3, Icon = "zap" })
            else
                EnableAnimations()
                WindUI:Notify({ Title = "No Animation OFF!", Duration = 3, Icon = "x" })
            end
        end
    })

    -- Tambahkan di bagian atas blok 'utility'
    local VFXControllerModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Controllers").VFXController)
    local originalVFXHandle = VFXControllerModule.Handle
    local originalPlayVFX = VFXControllerModule.PlayVFX.Fire -- Asumsi PlayVFX adalah Signal/Event yang memiliki Fire

    -- Variabel global untuk status VFX
    local isVFXDisabled = false

    -- 2. REMOVE SKIN EFFECT
    local SkinCleanerConnection = nil
    MiscSection:Toggle({
        Title = "Remove Skin Effect",
        Value = false,
        Icon = "sparkles",
        Callback = function(state)
            isVFXDisabled = state
            if state then
                -- 1. Blokir fungsi Handle (dipanggil oleh Handle Remote dan PlayVFX Signal)
                VFXControllerModule.Handle = function(...) 
                    -- Memastikan tidak ada kode efek yang berjalan 
                end

                -- 2. Blokir fungsi RenderAtPoint dan RenderInstance (untuk jaga-jaga)
                VFXControllerModule.RenderAtPoint = function(...) end
                VFXControllerModule.RenderInstance = function(...) end
                
                -- 3. Hapus semua efek yang sedang aktif (opsional, untuk membersihkan layar)
                local cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
                if cosmeticFolder then
                    pcall(function() cosmeticFolder:ClearAllChildren() end)
                end

                WindUI:Notify({ Title = "No Skin Effect ON", Duration = 3, Icon = "eye-off" })
            else
                -- 1. Kembalikan fungsi Handle asli
                VFXControllerModule.Handle = originalVFXHandle
            end

        end
    })

    -- 3. DISABLE 3D RENDERING
    MiscSection:Toggle({
        Title = "Disable 3D Rendering",
        Value = false,
        Icon = "monitor-off",
        Callback = function(state)
            local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = game.Players.LocalPlayer
            
            if state then
                -- 1. Buat GUI Hitam di PlayerGui (Bukan CoreGui)
                if not _G.BlackScreenGUI then
                    _G.BlackScreenGUI = Instance.new("ScreenGui")
                    _G.BlackScreenGUI.Name = "RockHub_BlackBackground"
                    _G.BlackScreenGUI.IgnoreGuiInset = true
                    -- [-999] = Taruh di paling belakang (di bawah UI Game), tapi nutupin world 3D
                    _G.BlackScreenGUI.DisplayOrder = -999 
                    _G.BlackScreenGUI.Parent = PlayerGui
                    
                    local Frame = Instance.new("Frame")
                    Frame.Size = UDim2.new(1, 0, 1, 0)
                    Frame.BackgroundColor3 = Color3.new(0, 0, 0) -- Hitam Pekat
                    Frame.BorderSizePixel = 0
                    Frame.Parent = _G.BlackScreenGUI
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, 0, 0.1, 0)
                    Label.Position = UDim2.new(0, 0, 0.1, 0) -- Taruh agak atas biar ga ganggu inventory
                    Label.BackgroundTransparency = 1
                    Label.Text = "Saver Mode Active"
                    Label.TextColor3 = Color3.fromRGB(60, 60, 60) -- Abu gelap sekali biar ga ganggu
                    Label.TextSize = 16
                    Label.Font = Enum.Font.GothamBold
                    Label.Parent = Frame
                end
                
                _G.BlackScreenGUI.Enabled = true

                -- 2. SIMPAN POSISI KAMERA ASLI
                _G.OldCamType = Camera.CameraType

                -- 3. PINDAHKAN KAMERA KE VOID
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(0, 100000, 0) 
                
                WindUI:Notify({
                    Title = "Saver Mode ON",
                    Duration = 3,
                    Icon = "battery-charging",
                })
            else
                -- 1. KEMBALIKAN TIPE KAMERA
                if _G.OldCamType then
                    Camera.CameraType = _G.OldCamType
                else
                    Camera.CameraType = Enum.CameraType.Custom
                end
                
                -- 2. KEMBALIKAN FOKUS KE KARAKTER
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                end

                -- 3. MATIKAN LAYAR HITAM
                if _G.BlackScreenGUI then
                    _G.BlackScreenGUI.Enabled = false
                end
                
                WindUI:Notify({
                    Title = "Saver Mode OFF",
                    Content = "Visual kembali normal.",
                    Duration = 3,
                    Icon = "eye",
                })
            end
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
