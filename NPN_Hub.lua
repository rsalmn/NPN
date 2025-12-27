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

local NetFolder = RepStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

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

pcall(function()
    local player = game:GetService("Players").LocalPlayer
    
    -- Cek semua koneksi yang terhubung ke event Idled pemain lokal
    for i, v in pairs(getconnections(player.Idled)) do
        if v.Disable then
            v:Disable() -- Menonaktifkan koneksi event
            print("[RockHub Anti-AFK] ON")
        end
    end
end)

local eventsList = { 
    "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", 
    "Ghost Worm", "Meteor Rain", "Megalodon Hunt", "Treasure Event"
}

-- =========================
-- NEW EVENT TELEPORT MODULE
-- =========================
local EventTP = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/akmiliadevi/Tugas_Kuliah/refs/heads/main/Project_code/Utama/SkinSwapAnimation.lua"
,true))()

-- Sync list ke UI bawaan kamu
local eventsList = EventTP.GetEventNames()


local autoEventTargetName = nil 
local autoEventTeleportState = false
local autoEventTeleportThread = nil


-- =========================
-- BRIDGE UNTUK WINDUI
-- =========================
local function FindAndTeleportToTargetEvent()
    if not autoEventTargetName then return false end
    local ok = EventTP.TeleportNow(autoEventTargetName)

    if ok then
        WindUI:Notify({
            Title = "Event Found",
            Content = "Teleported to "..autoEventTargetName,
            Icon = "map-pin",
            Duration = 3
        })
        return true
    else
        WindUI:Notify({
            Title = "Event Not Found",
            Content = "Belum spawn / tidak terdeteksi.",
            Icon = "x",
            Duration = 3
        })
        return false
    end
end


local function StartAutoEvent()
    local ok = EventTP.Start(autoEventTargetName)
    if ok then
        WindUI:Notify({
            Title = "Auto Event TP ON",
            Content = "Memantau event: "..autoEventTargetName,
            Icon = "search",
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "Gagal",
            Content = "Event tidak valid / tidak punya koordinat.",
            Icon = "x",
            Duration = 3
        })
        Window:GetElementByTitle("Enable Auto Event Teleport"):Set(false)
    end
end

local function StopAutoEvent()
    EventTP.Stop()
    WindUI:Notify({
        Title = "Auto Event TP OFF",
        Duration = 3,
        Icon = "x"
    })
end


local function RunAutoEventTeleportLoop()
    if autoEventTeleportThread then task.cancel(autoEventTeleportThread) end

    autoEventTeleportThread = task.spawn(function()
        WindUI:Notify({ Title = "Auto Event TP ON", Content = "Mulai memindai event terpilih.", Duration = 3, Icon = "search" })
        
        while autoEventTeleportState do
            
            if FindAndTeleportToTargetEvent() then
                
                task.wait(900) 
            else
                
                task.wait(10)
            end
        end
        
        WindUI:Notify({ Title = "Auto Event TP OFF", Duration = 3, Icon = "x" })
    end)
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

local ItemUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
local TierUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))

local function GetPlayerDataReplion()
    if PlayerDataReplion then return PlayerDataReplion end
    local ReplionModule = RepStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
    if not ReplionModule then return nil end
    local ReplionClient = require(ReplionModule).Client
    PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
    return PlayerDataReplion
end

local function GetFishNameAndRarity(item)
    local name = item.Identifier or "Unknown"
    local rarity = item.Metadata and item.Metadata.Rarity or "COMMON"
    local itemID = item.Id

    local itemData = nil

    if ItemUtility and itemID then
        pcall(function()
            itemData = ItemUtility:GetItemData(itemID)
            if not itemData then
                local numericID = tonumber(item.Id) or tonumber(item.Identifier)
                if numericID then
                    itemData = ItemUtility:GetItemData(numericID)
                end
            end
        end)
    end

    if itemData and itemData.Data and itemData.Data.Name then
        name = itemData.Data.Name
    end

    if item.Metadata and item.Metadata.Rarity then
        rarity = item.Metadata.Rarity
    elseif itemData and itemData.Probability and itemData.Probability.Chance and TierUtility then
        local tierObj = nil
        pcall(function()
            tierObj = TierUtility:GetTierFromRarity(itemData.Probability.Chance)
        end)

        if tierObj and tierObj.Name then
            rarity = tierObj.Name
        end
    end

    return name, rarity
end

local function GetItemMutationString(item)
    if item.Metadata and item.Metadata.Shiny == true then return "Shiny" end
    return item.Metadata and item.Metadata.VariantId or ""
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
    local fishMancing = farm:Section({ Title = "Fishing", TextSize = 20})

    local autofish = fishMancing:Section({ Title = "1. Auto Fishing", TextSize = 20 })

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
    local blatant = fishMancing:Section({ Title = "2. Blatant Mode (Old)", TextSize = 20, })

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
        Title = "2. Blatant Old",
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

    local v4 = fishMancing:Section({
        Title = "3. Blatant V2",
        TextSize = 20
    })

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
        Title = "Enable Blatant V2",
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
                    Title="Blatant V2 Enabled",
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
                    Title="Blatant V2 Stopped",
                    Duration=3
                })
            end
        end
    }))

    ------------------------------------------------------------
    -- BLATANT V5 (TESTER)
    -- Ultra Spam Mode (Gila Cepat, tapi Experimental)
    ------------------------------------------------------------
    local v5 = fishMancing:Section({
        Title = "4. Blatant (Tester)",
        TextSize = 20
    })

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

    local V5_CompleteDelay = 0.79
    local V5_CancelDelay = 0.329

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

    -- Tambahkan di bagian atas blok 'utility'
    local VFXControllerModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Controllers").VFXController)
    local originalVFXHandle = VFXControllerModule.Handle
    local originalPlayVFX = VFXControllerModule.PlayVFX.Fire -- Asumsi PlayVFX adalah Signal/Event yang memiliki Fire

    -- Variabel global untuk status VFX
    local isVFXDisabled = false

    -- 2. REMOVE SKIN EFFECT
    local SkinCleanerConnection = nil
    fishingSupport:Toggle({
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

end

-- FISHING AREA SECTION
do
    farm:Divider()
    local areafish = farm:Section({ Title = "Teleport Area", TextSize = 20 })
    
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

    local selectedTargetPlayer = nil -- Nama pemain yang dipilih
    local selectedTargetArea = nil -- Nama area yang dipilih

    -- Helper: Mengambil daftar pemain yang sedang di server (diambil dari kode Automatic)
    local function GetPlayerListOptions()
        local options = {}
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(options, player.Name)
            end
        end
        return options
    end

    -- Helper: Mendapatkan HRP target
    local function GetTargetHRP(playerName)
        local targetPlayer = game.Players:FindFirstChild(playerName)
        local character = targetPlayer and targetPlayer.Character
        if character then
            return character:FindFirstChild("HumanoidRootPart")
        end
        return nil
    end

    -- =================================================================
    -- A. TELEPORT KE PEMAIN (Button)
    -- =================================================================
    local teleplay = areafish:Section({
        Title = "Teleport to Player",
        TextSize = 20,
    })

    local PlayerDropdown = areafish:Dropdown({
        Title = "Select Target Player",
        Values = GetPlayerListOptions(),
        AllowNone = true,
        Callback = function(name)
            selectedTargetPlayer = name
        end
    })

    local listplaytel = areafish:Button({
        Title = "Refresh Player List",
        Icon = "refresh-ccw",
        Callback = function()
            local newOptions = GetPlayerListOptions()
            pcall(function() PlayerDropdown:Refresh(newOptions) end)
            task.wait(0.1)
            pcall(function() PlayerDropdown:Set(false) end)
            selectedTargetPlayer = nil
            WindUI:Notify({ Title = "List Diperbarui", Content = string.format("%d pemain ditemukan.", #newOptions), Duration = 2, Icon = "check" })
        end
    })

    local teletoplay = areafish:Button({
        Title = "Teleport to Player (One-Time)",
        Content = "Teleport satu kali ke lokasi pemain yang dipilih.",
        Icon = "corner-down-right",
        Callback = function()
            local hrp = GetHRP()
            local targetHRP = GetTargetHRP(selectedTargetPlayer)
            
            if not selectedTargetPlayer then
                WindUI:Notify({ Title = "Error", Content = "Pilih pemain target terlebih dahulu.", Duration = 3, Icon = "alert-triangle" })
                return
            end

            if hrp and targetHRP then
                -- Teleport 5 unit di atas target
                local targetPos = targetHRP.Position + Vector3.new(0, 5, 0)
                local lookVector = (targetHRP.Position - hrp.Position).Unit 
                
                hrp.CFrame = CFrame.new(targetPos, targetPos + lookVector)
                
                WindUI:Notify({ Title = "Teleport Sukses", Content = "Teleported ke " .. selectedTargetPlayer, Duration = 3, Icon = "user-check" })
            else
                 WindUI:Notify({ Title = "Error", Content = "Gagal menemukan target atau karakter Anda.", Duration = 3, Icon = "x" })
            end
        end
    })


end

do
    farm:Divider()
    local televent = farm:Section({ Title = "Event Teleport", TextSize = 20 })

    local dropvent = televent:Dropdown({
        Title = "Select Target Event",
        Content = "Pilih event yang ingin di-monitor secara otomatis.",
        Values = eventsList,
        AllowNone = true,
        Value = false,
        Callback = function(option)
            autoEventTargetName = option -- Simpan nama event sebagai target
            if autoEventTeleportState then
                 -- Force stop auto-teleport jika target diubah saat sedang aktif
                 autoEventTeleportState = false
                 if autoEventTeleportThread then task.cancel(autoEventTeleportThread) autoEventTeleportThread = nil end
                 Window:GetElementByTitle("Enable Auto Event Teleport"):Set(false)
            end
        end
    })

    local tovent = televent:Button({
        Title = "Teleport to Chosen Event (Once)",
        Icon = "corner-down-right",
        Callback = function()
            if not autoEventTargetName then
                WindUI:Notify({ Title = "Error", Content = "Pilih event dulu di dropdown!", Duration = 3, Icon = "alert-triangle" })
                return
            end
            
            WindUI:Notify({ Title = "Searching...", Content = "Mencari keberadaan event...", Duration = 2, Icon = "search" })
            
            local found = FindAndTeleportToTargetEvent()
            if not found then
                WindUI:Notify({ Title = "Gagal", Content = "Event tidak ditemukan / belum spawn.", Duration = 3, Icon = "x" })
            end
        end
    })


    local togventel = televent:Toggle({
        Title = "Enable Auto Event Teleport",
        Content = "Secara otomatis mencari dan teleport ke event yang dipilih.",
        Value = false,
        Callback = function(state)
            if not autoEventTargetName then
                 WindUI:Notify({ Title = "Error", Content = "Pilih Event Target terlebih dahulu di dropdown.", Duration = 3, Icon = "alert-triangle" })
                 return false
            end
            
            autoEventTeleportState = state
            if state then
                StartAutoEvent()
            else
                StopAutoEvent()
            end
        end
    })
end

do
    local webhook = Window:Tab({
        Title = "Webhook",
        Icon = "send",
        Locked = false,
    })

    -- Variabel lokal untuk menyimpan data
    local WEBHOOK_URL = ""
    local WEBHOOK_USERNAME = "NPN Notify" 
    local isWebhookEnabled = false
    local SelectedRarityCategories = {}
    local SelectedWebhookItemNames = {} -- Variabel baru untuk filter nama
    
    -- Kita butuh daftar nama item (Copy fungsi helper ini ke dalam tab webhook atau taruh di global scope)
    local function getWebhookItemOptions()
        local itemNames = {}
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local itemsContainer = ReplicatedStorage:FindFirstChild("Items")
        if itemsContainer then
            for _, itemObject in ipairs(itemsContainer:GetChildren()) do
                local itemName = itemObject.Name
                if type(itemName) == "string" and #itemName >= 3 and itemName:sub(1, 3) ~= "!!!" then
                    table.insert(itemNames, itemName)
                end
            end
        end
        table.sort(itemNames)
        return itemNames
    end
    
    -- Variabel KHUSUS untuk Global Webhook
    local GLOBAL_WEBHOOK_URL = "https://discord.com/api/webhooks/1438756450972471387/gHuV9K4UmiTjqK3F9KRt720HkGvLJGogwJ9uh17b7QpqMd1ieBC_UdKAX95ozTanWH37"
    local GLOBAL_WEBHOOK_USERNAME = "NPN | Community"
    local GLOBAL_RARITY_FILTER = {"SECRET", "TROPHY", "COLLECTIBLE", "DEV"}

    local RarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Trophy", "Collectible", "DEV"}
    
    local REObtainedNewFishNotification = GetRemote(RPath, "RE/ObtainedNewFishNotification")
    local HttpService = game:GetService("HttpService")
    local WebhookStatusParagraph -- Forward declaration

    -- ============================================================
    -- 🖼️ SISTEM CACHE GAMBAR (BARU)
    -- ============================================================
    local ImageURLCache = {} -- Table untuk menyimpan Link Gambar (ID -> URL)

    -- FUNGSI HELPER: Format Angka (Updated: Full Digit dengan Titik)
    local function FormatNumber(n)
        n = math.floor(n) -- Bulatkan ke bawah biar ga ada desimal aneh
        -- Logic: Balik string -> Tambah titik tiap 3 digit -> Balik lagi
        local formatted = tostring(n):reverse():gsub("%d%d%d", "%1."):reverse()
        -- Hapus titik di paling depan jika ada (clean up)
        return formatted:gsub("^%.", "")
    end
    
    local function UpdateWebhookStatus(title, content, icon)
        if WebhookStatusParagraph then
            WebhookStatusParagraph:SetTitle(title)
            WebhookStatusParagraph:SetDesc(content)
        end
    end

    -- FUNGSI GET IMAGE DENGAN CACHE
    local function GetRobloxAssetImage(assetId)
        if not assetId or assetId == 0 then return nil end
        
        -- 1. Cek Cache dulu!
        if ImageURLCache[assetId] then
            return ImageURLCache[assetId]
        end
        
        -- 2. Jika tidak ada di cache, baru panggil API
        local url = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%d&size=420x420&format=Png&isCircular=false", assetId)
        local success, response = pcall(game.HttpGet, game, url)
        
        if success then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
            if ok and data and data.data and data.data[1] and data.data[1].imageUrl then
                local finalUrl = data.data[1].imageUrl
                
                -- 3. Simpan ke Cache agar request berikutnya instan
                ImageURLCache[assetId] = finalUrl
                return finalUrl
            end
        end
        return nil
    end

    local function sendExploitWebhook(url, username, embed_data)
        local payload = {
            username = username,
            embeds = {embed_data} 
        }
        
        local json_data = HttpService:JSONEncode(payload)
        
        if typeof(request) == "function" then
            local success, response = pcall(function()
                return request({
                    Url = url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = json_data
                })
            end)
            
            if success and (response.StatusCode == 200 or response.StatusCode == 204) then
                 return true, "Sent"
            elseif success and response.StatusCode then
                return false, "Failed: " .. response.StatusCode
            elseif not success then
                return false, "Error: " .. tostring(response)
            end
        end
        return false, "No Request Func"
    end
    
    local function getRarityColor(rarity)
        local r = rarity:upper()
        if r == "SECRET" then return 0xFFD700 end
        if r == "MYTHIC" then return 0x9400D3 end
        if r == "LEGENDARY" then return 0xFF4500 end
        if r == "EPIC" then return 0x8A2BE2 end
        if r == "RARE" then return 0x0000FF end
        if r == "UNCOMMON" then return 0x00FF00 end
        return 0x00BFFF
    end

    local function shouldNotify(fishRarityUpper, fishMetadata, fishName)
        -- Cek Filter Rarity
        if #SelectedRarityCategories > 0 and table.find(SelectedRarityCategories, fishRarityUpper) then
            return true
        end

        -- Cek Filter Nama (Fitur Baru)
        if #SelectedWebhookItemNames > 0 and table.find(SelectedWebhookItemNames, fishName) then
            return true
        end

        -- Cek Mutasi
        if _G.NotifyOnMutation and (fishMetadata.Shiny or fishMetadata.VariantId) then
             return true
        end
        
        return false
    end
    
    -- FUNGSI UNTUK MENGIRIM PESAN IKAN AKTUAL (FIXED PATH: {"Coins"})
    local function onFishObtained(itemId, metadata, fullData)
        local success, results = pcall(function()
            local dummyItem = {Id = itemId, Metadata = metadata}
            local fishName, fishRarity = GetFishNameAndRarity(dummyItem)
            local fishRarityUpper = fishRarity:upper()

            -- --- START: Ambil Data Embed Umum ---
            local fishWeight = string.format("%.2fkg", metadata.Weight or 0)
            local mutationString = GetItemMutationString(dummyItem)
            local mutationDisplay = mutationString ~= "" and mutationString or "N/A"
            local itemData = ItemUtility:GetItemData(itemId)
            
            -- Handling Image
            local assetId = nil
            if itemData and itemData.Data then
                local iconRaw = itemData.Data.Icon or itemData.Data.ImageId
                if iconRaw then
                    assetId = tonumber(string.match(tostring(iconRaw), "%d+"))
                end
            end

            local imageUrl = assetId and GetRobloxAssetImage(assetId)
            if not imageUrl then
                imageUrl = "https://tr.rbxcdn.com/53eb9b170bea9855c45c9356fb33c070/420/420/Image/Png" 
            end
            
            local basePrice = itemData and itemData.SellPrice or 0
            local sellPrice = basePrice * (metadata.SellMultiplier or 1)
            local formattedSellPrice = string.format("%s$", FormatNumber(sellPrice))
            
            -- 1. GET TOTAL CAUGHT (Untuk Footer)
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local caughtStat = leaderstats and leaderstats:FindFirstChild("Caught")
            local caughtDisplay = caughtStat and FormatNumber(caughtStat.Value) or "N/A"

            -- 2. GET CURRENT COINS (FIXED LOGIC BASED ON DUMP)
            local currentCoins = 0
            local replion = GetPlayerDataReplion()
            
            if replion then
                -- Cara 1: Ambil Path Resmi dari Module (Paling Aman)
                local success_curr, CurrencyConfig = pcall(function()
                    return require(game:GetService("ReplicatedStorage").Modules.CurrencyUtility.Currency)
                end)

                if success_curr and CurrencyConfig and CurrencyConfig["Coins"] then
                    -- Path adalah table: { "Coins" }
                    -- Replion library di game ini support passing table path langsung
                    currentCoins = replion:Get(CurrencyConfig["Coins"].Path) or 0
                else
                    -- Cara 2: Fallback Manual (Root "Coins", bukan "Currency/Coins")
                    -- Kita coba unpack table manual atau string langsung
                    currentCoins = replion:Get("Coins") or replion:Get({"Coins"}) or 0
                end
            else
                -- Fallback Terakhir: Leaderstats
                if leaderstats then
                    local coinStat = leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("C$")
                    currentCoins = coinStat and coinStat.Value or 0
                end
            end

            local formattedCoins = FormatNumber(currentCoins)
            -- --- END: Ambil Data Embed Umum ---

            
            -- ************************************************************
            -- 1. LOGIKA WEBHOOK PRIBADI (USER'S WEBHOOK)
            -- ************************************************************
            local isUserFilterMatch = shouldNotify(fishRarityUpper, metadata, fishName)

            if isWebhookEnabled and WEBHOOK_URL ~= "" and isUserFilterMatch then
                local title_private = string.format("<:TEXTURENOBG:1438662703722790992> NPN | Webhook\n\n<a:ChipiChapa:1438661193857503304> New Fish Caught! (%s)", fishName)
                
                local embed = {
                    title = title_private,
                    description = string.format("Found by **%s**.", LocalPlayer.DisplayName or LocalPlayer.Name),
                    color = getRarityColor(fishRarityUpper),
                    fields = {
                        { name = "<a:ARROW:1438758883203223605> Fish Name", value = string.format("`%s`", fishName), inline = true },
                        { name = "<a:ARROW:1438758883203223605> Rarity", value = string.format("`%s`", fishRarityUpper), inline = true },
                        { name = "<a:ARROW:1438758883203223605> Weight", value = string.format("`%s`", fishWeight), inline = true },
                        
                        { name = "<a:ARROW:1438758883203223605> Mutation", value = string.format("`%s`", mutationDisplay), inline = true },
                        { name = "<a:coines:1438758976992051231> Sell Price", value = string.format("`%s`", formattedSellPrice), inline = true },
                        { name = "<a:coines:1438758976992051231> Current Coins", value = string.format("`%s`", formattedCoins), inline = true },
                    },
                    thumbnail = { url = imageUrl },
                    footer = {
                        text = string.format("RockHub Webhook • Total Caught: %s • %s", caughtDisplay, os.date("%Y-%m-%d %H:%M:%S"))
                    }
                }
                local success_send, message = sendExploitWebhook(WEBHOOK_URL, WEBHOOK_USERNAME, embed)
                
                if success_send then
                    UpdateWebhookStatus("Webhook Aktif", "Terkirim: " .. fishName, "check")
                else
                    UpdateWebhookStatus("Webhook Gagal", "Error: " .. message, "x")
                end
            end

            -- ************************************************************
            -- 2. LOGIKA WEBHOOK GLOBAL (COMMUNITY WEBHOOK)
            -- ************************************************************
            local isGlobalTarget = table.find(GLOBAL_RARITY_FILTER, fishRarityUpper)

            if isGlobalTarget and GLOBAL_WEBHOOK_URL ~= "" then 
                local playerName = LocalPlayer.DisplayName or LocalPlayer.Name
                local censoredPlayerName = CensorName(playerName)
                
                local title_global = string.format("<:TEXTURENOBG:1438662703722790992> NPN | Global Tracker\n\n<a:globe:1438758633151266818> GLOBAL CATCH! %s", fishName)

                local globalEmbed = {
                    title = title_global,
                    description = string.format("Pemain **%s** baru saja menangkap ikan **%s**!", censoredPlayerName, fishRarityUpper),
                    color = getRarityColor(fishRarityUpper),
                    fields = {
                        { name = "<a:ARROW:1438758883203223605> Rarity", value = string.format("`%s`", fishRarityUpper), inline = true },
                        { name = "<a:ARROW:1438758883203223605> Weight", value = string.format("`%s`", fishWeight), inline = true },
                        { name = "<a:ARROW:1438758883203223605> Mutation", value = string.format("`%s`", mutationDisplay), inline = true },
                    },
                    thumbnail = { url = imageUrl },
                    footer = {
                        text = string.format("RockHub Community| Player: %s | %s", censoredPlayerName, os.date("%Y-%m-%d %H:%M:%S"))
                    }
                }
                
                sendExploitWebhook(GLOBAL_WEBHOOK_URL, GLOBAL_WEBHOOK_USERNAME, globalEmbed)
            end
            
            return true
        end)
        
        if not success then
            warn("[RockHub Webhook] Error processing fish data:", results)
        end
    end
    
    if REObtainedNewFishNotification then
        REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, metadata, fullData)
            pcall(function() onFishObtained(itemId, metadata, fullData) end)
        end)
    end
    

    -- =================================================================
    -- UI IMPLEMENTATION (LANJUTAN)
    -- =================================================================
    local webhooksec = webhook:Section({
        Title = "Webhook Setup",
        TextSize = 20,
        FontWeight = Enum.FontWeight.SemiBold,
    })

   local inputweb = Reg("inptweb",webhooksec:Input({
        Title = "Discord Webhook URL",
        Desc = "URL tempat notifikasi akan dikirim.",
        Value = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Icon = "link",
        Type = "Input",
        Callback = function(input)
            WEBHOOK_URL = input
        end
    }))

    webhook:Divider()
    
   local ToggleNotif = Reg("tweb",webhooksec:Toggle({
        Title = "Enable Fish Notifications",
        Desc = "Aktifkan/nonaktifkan pengiriman notifikasi ikan.",
        Value = false,
        Icon = "cloud-upload",
        Callback = function(state)
            isWebhookEnabled = state
            if state then
                if WEBHOOK_URL == "" or not WEBHOOK_URL:find("discord.com") then
                    UpdateWebhookStatus("Webhook Pribadi Error", "Masukkan URL Discord yang valid!", "alert-triangle")
                    return false
                end
                WindUI:Notify({ Title = "Webhook ON!", Duration = 4, Icon = "check" })
                UpdateWebhookStatus("Status: Listening", "Menunggu tangkapan ikan...", "ear")
            else
                WindUI:Notify({ Title = "Webhook OFF!", Duration = 4, Icon = "x" })
                UpdateWebhookStatus("Webhook Status", "Aktifkan 'Enable Fish Notifications' untuk mulai mendengarkan tangkapan ikan.", "info")
            end
        end
    }))

    local dwebname = Reg("drweb", webhooksec:Dropdown({
        Title = "Filter by Specific Name",
        Desc = "Notifikasi khusus untuk nama ikan tertentu",
        Values = getWebhookItemOptions(),
        Value = SelectedWebhookItemNames,
        Multi = true,
        AllowNone = true,
        Callback = function(names)
            SelectedWebhookItemNames = names or {} 
        end
    }))

    local dwebrar = Reg("rarwebd", webhooksec:Dropdown({
        Title = "Rarity to Notify",
        Desc = "Hanya notifikasi ikan rarity yang dipilih.",
        Values = RarityList, -- Menggunakan list yang sudah distandarisasi
        Value = SelectedRarityCategories,
        Multi = true,
        AllowNone = true,
        Callback = function(categories)
            SelectedRarityCategories = {}
            for _, cat in ipairs(categories or {}) do
                table.insert(SelectedRarityCategories, cat:upper()) 
            end
        end
    }))

    WebhookStatusParagraph = webhooksec:Paragraph({
        Title = "Webhook Status",
        Content = "Aktifkan 'Enable Fish Notifications' untuk mulai mendengarkan tangkapan ikan.",
        Icon = "info",
    })
    

    local teswebbut = webhooksec:Button({
        Title = "Test Webhook ",
        Icon = "send",
        Desc = "Mengirim Webhook Test",
        Callback = function()
            if WEBHOOK_URL == "" then
                WindUI:Notify({ Title = "Error", Content = "Masukkan URL Webhook terlebih dahulu.", Duration = 3, Icon = "alert-triangle" })
                return
            end
            local testEmbed = {
                title = "NPN Webhook Test",
                description = "Success <a:ChipiChapa:1438661193857503304>",
                color = 0x00FF00,
                fields = {
                    { name = "Name Player", value = LocalPlayer.DisplayName or LocalPlayer.Name, inline = true },
                    { name = "Status", value = "Success", inline = true },
                    { name = "Cache System", value = "Active ✅", inline = true }
                },
                footer = {
                    text = "NPN Webhook Test"
                }
            }
            local success, message = sendExploitWebhook(WEBHOOK_URL, WEBHOOK_USERNAME, testEmbed)
            if success then
                 WindUI:Notify({ Title = "Test Sukses!", Content = "Cek channel Discord Anda. " .. message, Duration = 4, Icon = "check" })
            else
                 WindUI:Notify({ Title = "Test Gagal!", Content = "Cek console (Output) untuk error. " .. message, Duration = 5, Icon = "x" })
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
