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
    KeySystem = {                                                   
        Note = "Example Key System. With pandadevelopment.",        
        API = {                                                     
            { -- pandadevelopment
                Type = "NPNHub", -- type
                ServiceId = "fDS7ZzVtzOQyihv0gSFKjv42Rcex6yw8", -- service id
            },                                                      
        },                                                          
    },
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

--------------------------------------------------------------------
-- 🌊 HELPER STATUS DETECTOR (FIXED & OPTIMIZED)
--------------------------------------------------------------------
local function getStatus()
    -- 1. Selalu ambil karakter terbaru (Anti-Error saat Respawn)
    local char = Players.LocalPlayer.Character
    if not char then return "UNKNOWN" end
    
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not hrp then return "UNKNOWN" end

    -- 2. Cek State Swimming (Paling Akurat)
    if hum:GetState() == Enum.HumanoidStateType.Swimming then
        return "WATER (SWIMMING)"
    end

    -- 3. Cek Material Pijakan (FloorMaterial)
    -- Jika kaki menyentuh air
    if hum.FloorMaterial == Enum.Material.Water then
        return "WATER"
    end
    
    -- Jika kaki menyentuh tanah padat (Bukan udara/air)
    if hum.FloorMaterial ~= Enum.Material.Air then
        return "LAND"
    end

    -- 4. Raycast Fallback (Jika melayang dikit di atas air)
    -- Berguna saat karakter lompat-lompat kecil di permukaan air
    local origin = hrp.Position
    local direction = Vector3.new(0, -15, 0) -- Cukup 15 studs ke bawah

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude -- Gunakan Exclude (Modern), Blacklist (Deprecated)
    params.IgnoreWater = false -- PENTING: Jangan abaikan air

    local result = workspace:Raycast(origin, direction, params)

    if result then
        if result.Material == Enum.Material.Water then
            return "WATER"
        else
            return "LAND"
        end
    end

    return "UNKNOWN" -- Melayang tinggi / Void
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
    "Lochness Hunt","Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", 
    "Ghost Worm", "Meteor Rain", "Megalodon Hunt", "Treasure Event"
}

local autoEventTargetName = nil 
local autoEventTeleportState = false
local autoEventTeleportThread = nil

-- ===== Lochness config & helper (paste dekat deklarasi eventsList) =====
local LOCH_INTERVAL = 4 * 3600    -- 4 jam (detik)
local LOCH_DURATION = 10 * 60     -- 10 menit (detik)

local lochCountdownGui = nil
local lochCountdownThread = nil

local function getLochNextTimes()
    local now = os.time()
    -- Align ke epoch-based 4-hour grid (mis: 0:00, 4:00, 8:00, ...)
    local base = math.floor(now / LOCH_INTERVAL) * LOCH_INTERVAL
    -- Jika periode saat ini sudah lewat durasi, geser ke periode berikutnya
    if now >= base + LOCH_DURATION then
        base = base + LOCH_INTERVAL
    end
    local startTime = base
    local endTime = startTime + LOCH_DURATION
    local active = now >= startTime and now < endTime
    return startTime, endTime, active
end

local function formatTimeSeconds(sec)
    sec = math.max(0, math.floor(sec))
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

local function showLochCountdown()
    -- already shown?
    if lochCountdownGui and lochCountdownGui.Parent then
        lochCountdownGui.Enabled = true
        return
    end

    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    lochCountdownGui = Instance.new("ScreenGui")
    lochCountdownGui.Name = "LochnessCountdownGUI"
    lochCountdownGui.ResetOnSpawn = false
    lochCountdownGui.IgnoreGuiInset = true
    lochCountdownGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "LochFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Size = UDim2.new(0, 260, 0, 44)
    frame.Position = UDim2.new(0.5, 0, 0.06, 0)
    frame.BackgroundTransparency = 0.35
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = lochCountdownGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, -8)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "Lochness: calculating..."
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame

    -- update loop
    if lochCountdownThread then task.cancel(lochCountdownThread) end
    lochCountdownThread = task.spawn(function()
        while lochCountdownGui and lochCountdownGui.Parent do
            local startT, endT, active = getLochNextTimes()
            local now = os.time()
            local remaining = (active and (endT - now)) or (startT - now)
            remaining = math.max(0, remaining)
            if active then
                label.Text = ("Lochness ACTIVE! ends in %s"):format(formatTimeSeconds(remaining))
            else
                label.Text = ("Next Lochness in %s"):format(formatTimeSeconds(remaining))
            end
            task.wait(1)
        end
    end)
end

local function hideLochCountdown()
    if lochCountdownThread then
        pcall(function() task.cancel(lochCountdownThread) end)
        lochCountdownThread = nil
    end
    if lochCountdownGui then
        pcall(function() lochCountdownGui:Destroy() end)
        lochCountdownGui = nil
    end
end

-- ===== Optional: dynamic show/hide of "Lochness Hunt" entry in eventsList =====
local function hasEventInList(tbl, name)
    for i,v in ipairs(tbl) do if v == name then return true, i end end
    return false, nil
end

local function updateLochInEventsList(dropdownElement)
    local startT, endT, active = getLochNextTimes()
    local now = os.time()
    -- show Lochness in dropdown if active OR within 10 minutes to spawn
    local showWindow = active or (startT - now <= 10 * 60)
    local present, idx = hasEventInList(eventsList, "Lochness Hunt")
    if showWindow and not present then
        table.insert(eventsList, "Lochness Hunt")
        if dropdownElement and dropdownElement.Refresh then
            pcall(function() dropdownElement:Refresh(eventsList) end)
        end
    elseif (not showWindow) and present then
        table.remove(eventsList, idx)
        if dropdownElement and dropdownElement.Refresh then
            pcall(function() dropdownElement:Refresh(eventsList) end)
        end
    end
end

--------------------------------------------------------------------
-- 🔥 BUILT-IN EVENT TELEPORT ENGINE (NO MODULE REQUIRED)
--------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local EventTP = {}

EventTP.Events = {
    ["Shark Hunt"] = {
        Vector3.new(1.64999, -1.3500, 2095.72),
        Vector3.new(1369.94, -1.3500, 930.125),
        Vector3.new(-1585.5, -1.3500, 1242.87),
        Vector3.new(-1896.8, -1.3500, 2634.37),
    },

    ["Worm Hunt"] = {
        Vector3.new(2190.85, -1.3999, 97.5749),
        Vector3.new(-2450.6, -1.3999, 139.731),
        Vector3.new(-267.47, -1.3999, 5188.53),
    },

    ["Megalodon Hunt"] = {
        Vector3.new(-1076.3, -1.3999, 1676.19),
        Vector3.new(-1191.8, -1.3999, 3597.30),
        Vector3.new(412.700, -1.3999, 4134.39),
    },

    ["Ghost Shark Hunt"] = {
        Vector3.new(489.558, -1.3500, 25.4060),
        Vector3.new(-1358.2, -1.3500, 4100.55),
        Vector3.new(627.859, -1.3500, 3798.08),
    },

    ["Treasure Hunt"] = nil,
}

EventTP.SearchRadius = 25
EventTP.TeleportCheckInterval = 8
EventTP.HeightOffset = 15
EventTP.SafeZoneRadius = 50
EventTP.RequireEventActive = true
EventTP.UseSmartReteleport = true
EventTP.WaitForEventTimeout = 300

local running = false
local currentEventName = nil
local cachedEventPosition = nil
local eventIsActive = false
local lastTeleportPosition = nil
local lastScanTime = 0
local scanCooldown = 10

local connChild = nil

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function applyOffset(v)
    return Vector3.new(v.X, v.Y + EventTP.HeightOffset, v.Z)
end

local function safeCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function doTeleport(pos)
    local ok = pcall(function()
        local c = safeCharacter()
        if not c then return end

        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if c.PrimaryPart then
            c:PivotTo(CFrame.new(pos))
        else
            hrp.CFrame = CFrame.new(pos)
        end
        lastTeleportPosition = pos
    end)
    return ok
end

local function isAlivePart(p)
    if typeof(p) ~= "Instance" then return false end
    if not p:IsA("BasePart") then return false end

    local success = pcall(function()
        return p.Parent ~= nil and p:IsDescendantOf(Workspace)
    end)

    return success
end

local function scan(eventName)
    local now = tick()
    if now - lastScanTime < scanCooldown then
        return cachedEventPosition
    end

    local list = EventTP.Events[eventName]
    if not list or #list == 0 then return nil end

    lastScanTime = now

    for _,coord in ipairs(list) do
        local region = Region3.new(
            coord - Vector3.new(30,30,30),
            coord + Vector3.new(30,30,30)
        ):ExpandToGrid(4)

        local ok, parts = pcall(function()
            return Workspace:FindPartsInRegion3(region,nil,50)
        end)

        if ok and parts and #parts>0 then
            for _,p in ipairs(parts) do
                if isAlivePart(p) then
                    local ps = p.Position
                    if (ps - coord).Magnitude <= EventTP.SearchRadius then
                        local final = applyOffset(ps)
                        cachedEventPosition = final
                        eventIsActive = true
                        return final
                    end
                end
            end
        end
    end
    return nil
end

local function setupListener(eventName)
    if connChild then connChild:Disconnect() connChild=nil end
    local coords = EventTP.Events[eventName]
    if not coords then return end

    connChild = Workspace.ChildAdded:Connect(function(child)
        if not running then return end
        if not isAlivePart(child) then return end

        local pos
        local ok,posTry = pcall(function() return child.Position end)
        if not ok then return end

        for _,coord in ipairs(coords) do
            if (posTry - coord).Magnitude <= EventTP.SearchRadius then
                cachedEventPosition = applyOffset(posTry)
                eventIsActive = true
                return
            end
        end
    end)
end

local function waitActive(eventName)
    local start = tick()
    while tick() - start < EventTP.WaitForEventTimeout do
        local p = scan(eventName)
        if p then return p end
        task.wait(5)
    end
    return nil
end

function EventTP.TeleportNow(name)
    if cachedEventPosition and eventIsActive then
        return doTeleport(cachedEventPosition)
    end
    return false
end

function EventTP.Start(name)
    if running then return false end
    if not EventTP.Events[name] then return false end

    running = true
    currentEventName = name
    cachedEventPosition = nil
    eventIsActive = false
    lastScanTime = 0

    setupListener(name)

    task.spawn(function()
        if EventTP.RequireEventActive then
            local pos = waitActive(name)
            if not pos then
                EventTP.Stop()
                return
            end
            doTeleport(pos)
        end

        local failCount = 0
        while running do
            if cachedEventPosition and eventIsActive then
                doTeleport(cachedEventPosition)
                failCount = 0
            else
                local newPos = scan(name)
                if newPos then
                    cachedEventPosition = newPos
                    eventIsActive = true
                    doTeleport(newPos)
                    failCount = 0
                else
                    failCount += 1
                    if failCount >= 3 then
                        EventTP.Stop()
                        break
                    end
                end
            end
            task.wait(EventTP.TeleportCheckInterval)
        end
    end)
    return true
end

function EventTP.Stop()
    running = false
    cachedEventPosition = nil
    currentEventName = nil
    eventIsActive = false
    if connChild then connChild:Disconnect() end
end

_G.EventTP = EventTP
--------------------------------------------------------------------
-- 🔥 END ENGINE
--------------------------------------------------------------------

local function FindAndTeleportToTargetEvent()
    if not autoEventTargetName then
        WindUI:Notify({
            Title = "Event Error",
            Content = "Pilih Event terlebih dahulu!",
            Duration = 3,
            Icon = "alert-triangle"
        })
        return false
    end

    local eventName = autoEventTargetName

    -------------------------------
    -- 🐍 Special Case: Lochness --
    -------------------------------
    if eventName == "Lochness Hunt" then
        
        -- 1) Cari object Lochness di Workspace
        local foundPart = nil

        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("BasePart") then
                local n = inst.Name:lower()
                
                -- ⬇️ ganti keyword sesuai nama asli jika tahu persis
                if string.find(n, "loch") 
                or string.find(n, "ness") 
                or string.find(n, "nessie") then
                    foundPart = inst
                    break
                end
            end
        end

        if foundPart then
            -- Teleport ke object Lochness
            pcall(function()
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:PivotTo(CFrame.new(foundPart.Position + Vector3.new(0, 6, 0)))
                end
            end)

            WindUI:Notify({
                Title = "Lochness Found!",
                Content = "Berhasil teleport ke Lochness",
                Duration = 3,
                Icon = "map-pin"
            })

            return true
        end

        -- 2) Jika tidak ditemukan object → coba pakai EventTP Engine (kalau kamu pakai)
        if EventTP and EventTP.TeleportOnce then
            if EventTP.TeleportOnce("Lochness Hunt") then
                return true
            end
        end

        -- 3) Tidak ketemu sama sekali
        WindUI:Notify({
            Title = "Lochness Not Found",
            Content = "Belum spawn / server ini belum ada Lochness",
            Duration = 3,
            Icon = "x"
        })

        return false
    end


    -- EVENT LAIN pakai engine baru
    if EventTP.TeleportNow(eventName) then
        WindUI:Notify({
            Title = "Event Found!",
            Content = "Teleported ke " .. eventName,
            Duration = 3,
            Icon = "map-pin"
        })
        return true
    end

    return false
end

local function StartAutoEvent()
    -- Simpan posisi awal player sebelum dipaksa ke event
    local hrp = GetHRP()
    if hrp then
        Generic_PreEvent_CFrame = hrp.CFrame
    end

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

-- 🛑 HOOK STOP → balik ke area / posisi lama
do
    local OldStop = EventTP.Stop
    EventTP.Stop = function(...)
        local result = OldStop(...)

        -- Jangan ganggu Lochness karena sudah punya sistem sendiri
        if autoEventTargetName ~= "Lochness Hunt" then
            task.delay(0.5, ReturnAfterAnyEvent)
        end
        
        return result
    end
end
----------------------------------------------------
-- SAFE LAND SPOT
----------------------------------------------------
local SAFE_LAND_POSITION = Vector3.new(6027.88, -585.92, 4710.96)

local Lochness_PreTeleported = false
local Lochness_Returned = false
local Saved_PreLoch_CFrame = nil

-- AREA tujuan setelah event selesai
local Loch_Return_SelectedArea = nil
-- 🌍 GLOBAL RETURN SUPPORT (UNTUK SEMUA EVENT)
local Generic_PreEvent_CFrame = nil

local function ReturnAfterAnyEvent()
    -- PRIORITAS 1 → balik ke Fishing Area jika user pilih
    if Loch_Return_SelectedArea and FishingAreass and FishingAreass[Loch_Return_SelectedArea] then
        local data = FishingAreass[Loch_Return_SelectedArea]
        TeleportToLookAt(data.Pos, data.Look)

        WindUI:Notify({
            Title = "Event Selesai",
            Content = "Kembali ke area: " .. Loch_Return_SelectedArea,
            Duration = 4,
            Icon = "map-pin"
        })
        return
    end

    -- PRIORITAS 2 → balik ke posisi awal sebelum event
    if Generic_PreEvent_CFrame then
        local char = Players.LocalPlayer.Character
        if char then
            pcall(function()
                char:PivotTo(Generic_PreEvent_CFrame)
            end)
        end

        WindUI:Notify({
            Title = "Event Selesai",
            Content = "Kembali ke posisi sebelum event 👍",
            Duration = 4,
            Icon = "map-pin"
        })
    end
end

local function TeleportToSafeLand()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function()
        if character.PrimaryPart then
            character:PivotTo(CFrame.new(SAFE_LAND_POSITION))
        else
            hrp.CFrame = CFrame.new(SAFE_LAND_POSITION)
        end
    end)

    if WindUI then
        WindUI:Notify({
            Title = "Lochness Prep",
            Content = "Auto teleport ke daratan aman 👍",
            Duration = 4,
            Icon = "map-pin"
        })
    end
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

do
    local about = Window:Tab({
        Title = "About",
        Icon = "info",
        Locked = false,
    })

    about:Section({
        Title = "Join Discord Server NPN Hub",
        TextSize = 20,
    })

    about:Paragraph({
        Title = "NPN Community",
        Desc = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
        Image = "rbxassetid://18898712828",
        ImageSize = 24,
        Buttons = {
            {
                Title = "Copy Link",
                Icon = "link",
                Callback = function()
                    setclipboard("https://discord.gg/xtDP7SfgFA")
                    WindUI:Notify({
                        Title = "Link Disalin!",
                        Content = "Link Discord NPN berhasil disalin.",
                        Duration = 3,
                        Icon = "copy",
                    })
                end,
            }
        }
    })

    about:Divider()
    
    about:Section({
        Title = "What's New?",
        TextSize = 24,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    about:Image({
        Image = "rbxassetid://18898712828",
        AspectRatio = "16:9",
        Radius = 9,
    })

    about:Space()

    about:Paragraph({
        Title = "Version 1.0.0",
        Desc = "- Initial Release (Stable)",
    })
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

    local v4 = fishMancing:Section({
        Title = "2. Blatant V1",
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

    ------------------------------------------------------------
    -- TOGGLE
    ------------------------------------------------------------
    Reg("v4toggle", v4:Toggle({
        Title = "Enable Blatant V1",
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
                    Title="Blatant V1 Enabled",
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
                    Title="Blatant V1 Stopped",
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
        Title = "3. Blatant v2",
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
                RF_ChargeFishingRod:InvokeServer({[5] = t})
            end)

            safe(function()
                RF_RequestFishingMinigameStarted:InvokeServer(5, 0, t)
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
        Title = "Enable Blatant v2",
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
                    Title = "Blatant v2 Enabled",
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
                    Title = "Blatant v2 Stopped",
                    Duration = 3
                })
            end
        end
    }))


    ------------------------------------------------------------
    -- BLATANT HYBRID (V4 & V5 COMBINED)
    -- Logika: Struktur V4 (Stabil) + Eksekusi V5 (Cepat/Tanpa Safety)
    ------------------------------------------------------------
    local hybrid = fishMancing:Section({
        Title = "3. Blatant Hybrid (Best)",
        TextSize = 20
    })

    -- Mengambil referensi remote dari NetFolder global yang sudah didefinisikan di atas
    local RF_Charge = NetFolder["RF/ChargeFishingRod"]
    local RF_Start = NetFolder["RF/RequestFishingMinigameStarted"]
    local RF_Cancel = NetFolder["RF/CancelFishingInputs"]
    local RF_UpdateState = NetFolder["RF/UpdateAutoFishingState"]
    local RE_Finish = NetFolder["RE/FishingCompleted"]
    local RE_Changed = NetFolder["RE/FishingMinigameChanged"]

    ------------------------------------------------------------
    -- STATE & VARIABLES
    ------------------------------------------------------------
    local Hybrid_Active = false
    local Hybrid_Thread = nil

    -- Default Config (Agresif tapi flow tetap terjaga)
    local H_CompleteDelay = 0.75
    local H_CancelDelay = 0.25
    local H_RecastDelay = 0.0

    ------------------------------------------------------------
    -- SAFE WRAPPER (Prevents Script Crash)
    ------------------------------------------------------------
    local function safe(fn)
        task.spawn(function()
            pcall(fn)
        end)
    end

    ------------------------------------------------------------
    -- MAIN HYBRID LOOP
    ------------------------------------------------------------
    local function Hybrid_Loop()
        while Hybrid_Active do
            local t = tick()

            -- [1] CAST PHASE
            -- Kita eksekusi Charge & Start hampir bersamaan (Style V5)
            -- Namun diberi micro-wait 5ms agar paket data terurut (Style V4)
            safe(function() RF_Charge:InvokeServer({[1]=t}) end)
            safe(function() RF_Start:InvokeServer(1, 0, t) end)

            -- [2] WAITING TO CATCH
            task.wait(H_CompleteDelay)
            if not Hybrid_Active then break end

            -- [3] COMPLETE PHASE
            -- Tanpa safety cooldown, langsung tembak (Style V5)
            safe(function() RE_Finish:FireServer() end)

            -- [4] WAITING TO CANCEL/ANIMATION
            task.wait(H_CancelDelay)
            if not Hybrid_Active then break end

            -- [5] CANCEL PHASE (Reset Rod)
            safe(function() RF_Cancel:InvokeServer() end)
        end
    end

    ------------------------------------------------------------
    -- FAILSAFE LISTENER
    -- Berguna jika main loop telat karena lag, event ini akan memaksa finish
    ------------------------------------------------------------
    RE_Changed.OnClientEvent:Connect(function()
        if not Hybrid_Active then return end
        
        -- Logic: Jika minigame muncul (mungkin karena desync), kita antrikan penyelesaian
        task.delay(H_CompleteDelay, function()
            if Hybrid_Active then 
                safe(function() RE_Finish:FireServer() end) 
            end
            
            task.delay(H_CancelDelay, function()
                if Hybrid_Active then 
                    safe(function() RF_Cancel:InvokeServer() end) 
                end
            end)
        end)
    end)

    ------------------------------------------------------------
    -- UI INPUTS
    ------------------------------------------------------------
    Reg("hybrid_comp", hybrid:Input({
        Title = "Complete Delay",
        Value = tostring(H_CompleteDelay),
        Placeholder = "0.75",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0 then H_CompleteDelay = n end
        end
    }))

    Reg("hybrid_canc", hybrid:Input({
        Title = "Cancel Delay",
        Value = tostring(H_CancelDelay),
        Placeholder = "0.25",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0 then H_CancelDelay = n end
        end
    }))

    Reg("hybrid_recast", hybrid:Input({
        Title = "Recast Delay",
        Value = tostring(H_RecastDelay),
        Placeholder = "0.0",
        Desc = "Jeda sebelum melempar kail lagi (0 = Spam)",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0 then H_RecastDelay = n end
        end
    }))

    ------------------------------------------------------------
    -- TOGGLE
    ------------------------------------------------------------
    Reg("hybrid_toggle", hybrid:Toggle({
        Title = "Enable Blatant Hybrid",
        Value = false,
        Callback = function(state)
            if not (RF_Charge and RF_Start and RE_Finish) then
                WindUI:Notify({Title="Error", Content="Remotes not found!", Duration=3, Icon="alert-triangle"})
                return
            end

            Hybrid_Active = state

            if state then
                -- Matikan mode lain jika aktif
                if legitAutoState ~= nil then legitAutoState = false end
                if normalInstantState ~= nil then normalInstantState = false end
                if blatantInstantState ~= nil then blatantInstantState = false end
                
                -- Set Server State ke True (Biar dikira mancing beneran)
                safe(function() RF_UpdateState:InvokeServer(true) end)
                safe(function() RF_Cancel:InvokeServer() end)

                Hybrid_Thread = task.spawn(Hybrid_Loop)

                WindUI:Notify({
                    Title = "Hybrid Mode ON",
                    Content = "Mode V4+V5 Combined Active",
                    Duration = 3,
                    Icon = "zap"
                })
            else
                Hybrid_Active = false
                if Hybrid_Thread then task.cancel(Hybrid_Thread) Hybrid_Thread = nil end

                -- Reset State
                safe(function() RF_UpdateState:InvokeServer(false) end)
                safe(function() RF_Cancel:InvokeServer() end)

                WindUI:Notify({ Title = "Hybrid Mode OFF", Duration = 2 })
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

    -- =========================================================
    -- WALK ON WATER (USER VERSION - INTEGRATED)
    -- =========================================================
    local walkOnWaterConnection = nil
    local isWalkOnWater = false
    local waterPlatform = nil
    
    -- Simpan elemen toggle ke variabel agar bisa diakses Smart System
    local WalkOnWaterToggleElement = Reg("walkwat", fishingSupport:Toggle({
        Title = "Walk on Water", 
        -- (Ganti 'farm' dengan tab yang kamu mau, misal 'ability')
        Value = false,
        Callback = function(state)
            isWalkOnWater = state

            if state then
                WindUI:Notify({ Title = "Walk on Water ON!", Duration = 2, Icon = "droplet" })
                
                -- Buat Platform jika belum ada
                if not waterPlatform then
                    waterPlatform = Instance.new("Part")
                    waterPlatform.Name = "WaterPlatform"
                    waterPlatform.Anchored = true
                    waterPlatform.CanCollide = true
                    waterPlatform.Transparency = 1 
                    waterPlatform.Size = Vector3.new(20, 1, 20) -- Diperbesar sedikit
                    waterPlatform.Parent = workspace
                end

                if walkOnWaterConnection then walkOnWaterConnection:Disconnect() end

                walkOnWaterConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    local character = game:GetService("Players").LocalPlayer.Character
                    if not isWalkOnWater or not character then return end
                    
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    if not waterPlatform or not waterPlatform.Parent then
                        waterPlatform = Instance.new("Part")
                        waterPlatform.Name = "WaterPlatform"
                        waterPlatform.Anchored = true
                        waterPlatform.CanCollide = true
                        waterPlatform.Transparency = 1 
                        waterPlatform.Size = Vector3.new(20, 1, 20)
                        waterPlatform.Parent = workspace
                    end

                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {workspace.Terrain} 
                    rayParams.FilterType = Enum.RaycastFilterType.Include
                    rayParams.IgnoreWater = false 

                    local rayOrigin = hrp.Position + Vector3.new(0, 5, 0) 
                    local rayDirection = Vector3.new(0, -500, 0)
                    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)

                    if result and result.Material == Enum.Material.Water then
                        local waterSurfaceHeight = result.Position.Y
                        waterPlatform.Position = Vector3.new(hrp.Position.X, waterSurfaceHeight, hrp.Position.Z)
                        
                        -- Logic angkat kaki jika tenggelam dikit
                        if hrp.Position.Y < (waterSurfaceHeight + 2) and hrp.Position.Y > (waterSurfaceHeight - 5) then
                             if not game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                                hrp.CFrame = CFrame.new(hrp.Position.X, waterSurfaceHeight + 3.5, hrp.Position.Z)
                            end
                        end
                    else
                        waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
                    end
                end)
            else
                WindUI:Notify({ Title = "Walk on Water OFF!", Duration = 2, Icon = "x", })
                if walkOnWaterConnection then walkOnWaterConnection:Disconnect() walkOnWaterConnection = nil end
                if waterPlatform then waterPlatform:Destroy() waterPlatform = nil end
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

    local CutsceneController = nil
    local OldPlayCutscene = nil
    local isNoCutsceneActive = false

    -- Mencoba require module CutsceneController dengan aman
    pcall(function()
        CutsceneController = require(game:GetService("ReplicatedStorage"):WaitForChild("Controllers"):WaitForChild("CutsceneController"))
        if CutsceneController and CutsceneController.Play then
            OldPlayCutscene = CutsceneController.Play
            
            -- Overwrite fungsi Play
            CutsceneController.Play = function(self, ...)
                if isNoCutsceneActive then
                    -- Jika aktif, jangan jalankan apa-apa (Skip Cutscene)
                    return 
                end
                -- Jika tidak aktif, jalankan fungsi asli
                return OldPlayCutscene(self, ...)
            end
        end
    end)

    local tcutscen = Reg("tnocut",fishingSupport:Toggle({
        Title = "No Cutscene",
        Value = false,
        Icon = "film", -- Icon film strip
        Callback = function(state)
            isNoCutsceneActive = state
            
            if not CutsceneController then
                WindUI:Notify({ Title = "Gagal Hook", Content = "Module CutsceneController tidak ditemukan.", Duration = 3, Icon = "x" })
                return
            end

            if state then
                WindUI:Notify({ Title = "No Cutscene ON", Content = "Animasi tangkapan dimatikan.", Duration = 3, Icon = "video-off" })
            else
                WindUI:Notify({ Title = "No Cutscene OFF", Content = "Animasi kembali normal.", Duration = 3, Icon = "video" })
            end
        end
    }))

    -- 1. NO ANIMATION
    fishingSupport:Toggle({
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
    local televent = farm:Section({ Title = "Teleport Event", TextSize = 20 })

    -- =========================================================
    -- 1. DATA FISHING AREA (Idle Map)
    -- =========================================================
    local FishingAreass = {
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
    local AreaNamess = {}
    for name, _ in pairs(FishingAreass) do table.insert(AreaNamess, name) end
    table.sort(AreaNamess)

    -- =========================================================
    -- 2. KEYWORD FILTER (STRICT DETECTION)
    -- =========================================================
    -- Script hanya akan menganggap event aktif jika menemukan part dengan nama-nama ini
    local EventKeywords = {
        ["Megalodon Hunt"] = {"Megalodon"},
        ["Shark Hunt"] = {"Shark", "Great White"},
        ["Ghost Shark Hunt"] = {"Ghost", "GHOST Shark Hunt", "Shark Hunt"},
        ["Worm Hunt"] = {"Worm"},
        ["Ghost Worm"] = {"Ghost Worm"},
        ["Treasure Event"] = {"Chest", "Supply", "Crate"},
        ["Meteor Rain"] = {"Meteor"},
        -- Tambahkan event lain jika perlu
    }

    -- =========================================================
    -- 3. VARIABLES
    -- =========================================================
    local SelectedPriorityEvent = nil
    local SelectedNormalEvents = {}
    local Loch_Return_SelectedArea = nil 
    
    local SmartEventState = false
    local SmartEventThread = nil
    local CycleIndex = 1

    -- =========================================================
    -- 4. SCANNER & TELEPORTER (UPDATED)
    -- =========================================================
    
    local function FindEventCoordinate(targetName)
        if not targetName then return nil end

        -- [A] KHUSUS LOCHNESS
        if targetName == "Lochness Hunt" then
            local _, _, active = getLochNextTimes()
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("BasePart") then
                    local n = inst.Name:lower()
                    if string.find(n, "loch") or string.find(n, "ness") then
                        return inst.Position + Vector3.new(0, 10, 0)
                    end
                end
            end
            if active then return SAFE_LAND_POSITION end
            return nil
        end

        -- [B] KHUSUS EVENT BIASA (DENGAN FILTER KETAT)
        if EventTP and EventTP.Events then
            local possibleCoords = EventTP.Events[targetName]
            if possibleCoords and type(possibleCoords) == "table" then
                
                -- Ambil kata kunci untuk event ini
                local keywords = EventKeywords[targetName] or {targetName:gsub(" Hunt", "")}

                for _, coord in ipairs(possibleCoords) do
                    local regionSize = Vector3.new(60, 60, 60) -- Scan area luas
                    local region = Region3.new(coord - regionSize, coord + regionSize)
                    local parts = workspace:FindPartsInRegion3(region, nil, 50)
                    
                    for _, part in ipairs(parts) do
                        local pName = part.Name
                        local mName = part.Parent.Name -- Nama Model (biasanya nama Boss)
                        local char = Players.LocalPlayer.Character

                        -- Filter Dasar: Bukan Terrain, Air, atau Pemain
                        if pName ~= "Terrain" and pName ~= "Water" and (not char or not part:IsDescendantOf(char)) then
                            
                            -- FILTER LANJUTAN: Cek Nama
                            for _, key in ipairs(keywords) do
                                -- Cek apakah nama Part atau nama Model mengandung Keyword
                                if string.find(pName, key) or string.find(mName, key) then
                                    -- KETEMU! Return koordinat
                                    return coord + Vector3.new(0, 15, 0) -- +15 Y (Cukup tinggi untuk jatuh ke platform air)
                                end
                            end
                            
                        end
                    end
                end
            end
        end

        return nil
    end

    -- Fungsi Teleport untuk Walk On Water
    local function SafeTeleportTo(pos)
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- 1. Teleport
            char:PivotTo(CFrame.new(pos))
            
            -- 2. Pastikan TIDAK ANCHOR (Agar WalkOnWater bekerja)
            -- 3. Reset Velocity agar tidak terlempar
            hrp.Anchored = false 
            hrp.Velocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- =========================================================
    -- 5. UI ELEMENTS
    -- =========================================================
    televent:Dropdown({
        Title = "1. Set Event Priority (Utama)",
        Desc = "Fokus utama. Jika aktif, script akan diam disini.",
        Values = eventsList,
        AllowNone = true,
        Callback = function(opt)
            SelectedPriorityEvent = opt
            if opt == "Lochness Hunt" then if showLochCountdown then showLochCountdown() end else if hideLochCountdown then hideLochCountdown() end end
        end
    })

    televent:Dropdown({
        Title = "2. Set Event Biasa (Backup)",
        Desc = "Jika priority kosong, cari event disini (Cycle 5s).",
        Values = eventsList,
        AllowNone = true,
        Multi = true,
        Callback = function(opts) SelectedNormalEvents = opts or {} end
    })

    televent:Dropdown({
        Title = "3. Area Saat Idle / Event Kosong",
        Desc = "Jika SEMUA Event kosong, teleport kesini.",
        Values = AreaNamess,
        AllowNone = true,
        Callback = function(opt)
            Loch_Return_SelectedArea = opt
            if opt then WindUI:Notify({ Title = "Idle Area Set", Content = "Map: " .. opt, Duration = 2, Icon = "map-pin" }) end
        end
    })

    -- =========================================================
    -- 6. MAIN LOGIC LOOP (FINAL)
    -- =========================================================
    televent:Toggle({
        Title = "Enable Smart Event System",
        Desc = "Auto Cycle + Walk on Water Support",
        Value = false,
        Callback = function(state)
            SmartEventState = state

            if SmartEventState then
                WindUI:Notify({ Title = "Smart System", Content = "Started!", Duration = 3, Icon = "cpu" })
                pcall(function() if EventTP and EventTP.Stop then EventTP.Stop() end end)
                
                -- Auto Enable Walk On Water
                if WalkOnWaterToggleElement and WalkOnWaterToggleElement.Set then
                    WalkOnWaterToggleElement:Set(true)
                end

                SmartEventThread = task.spawn(function()
                    while SmartEventState do
                        local priorityFound = false
                        
                        -- [PHASE 1] CEK PRIORITY
                        if SelectedPriorityEvent and SelectedPriorityEvent ~= "" then
                            local dest = FindEventCoordinate(SelectedPriorityEvent)
                            if dest then
                                SafeTeleportTo(dest)
                                priorityFound = true
                                task.wait(1) 
                            end
                        end

                        if priorityFound then 
                            -- Stay on priority
                        else
                            -- [PHASE 2] CEK NORMAL EVENTS (RE-SCAN SETIAP LOOP)
                            local activeNormalEvents = {} 
                            
                            -- Scan ulang semua pilihan user, hanya masukkan yang AKTIF SEKARANG
                            for _, eventName in ipairs(SelectedNormalEvents) do
                                local dest = FindEventCoordinate(eventName)
                                if dest then
                                    table.insert(activeNormalEvents, {Name = eventName, Pos = dest})
                                end
                            end

                            if #activeNormalEvents > 0 then
                                -- Validasi Index Cycle
                                if CycleIndex > #activeNormalEvents then CycleIndex = 1 end
                                
                                local target = activeNormalEvents[CycleIndex]
                                
                                -- Teleport
                                SafeTeleportTo(target.Pos)
                                
                                -- Pindah ke event berikutnya di list (Cycle)
                                CycleIndex = CycleIndex + 1
                                
                                -- Tunggu 5 detik
                                task.wait(5) 
                            else
                                -- [PHASE 3] IDLE / SEMUA KOSONG
                                if Loch_Return_SelectedArea and FishingAreass[Loch_Return_SelectedArea] then
                                    local data = FishingAreass[Loch_Return_SelectedArea]
                                    local char = Players.LocalPlayer.Character
                                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                    
                                    if hrp then
                                        local dist = (hrp.Position - data.Pos).Magnitude
                                        if dist > 15 then
                                            -- Teleport ke Idle Map
                                            hrp.Anchored = false 
                                            TeleportToLookAt(data.Pos, data.Look)
                                        end
                                    end
                                end
                                
                                task.wait(1.5)
                            end
                        end
                    end
                end)
            else
                if SmartEventThread then task.cancel(SmartEventThread) SmartEventThread = nil end
                
                -- Auto Disable Walk On Water (Optional)
                if WalkOnWaterToggleElement and WalkOnWaterToggleElement.Set then
                    WalkOnWaterToggleElement:Set(false)
                end
                
                WindUI:Notify({ Title = "Smart System", Content = "Stopped.", Duration = 3, Icon = "x" })
            end
        end
    })

end

do
    ------------------------------------------------------------
    -- INTERNAL MODULE : AUTO BUY WEATHER
    ------------------------------------------------------------
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local NetPackage = Packages._Index["sleitnick_net@0.2.0"]
    -- Pastikan path remote ini benar sesuai game
    local RFPurchaseWeatherEvent = NetPackage.net["RF/PurchaseWeatherEvent"]
    
    local AutoBuyWeather = {}
    
    local isRunning = false
    local selected = {} -- Menyimpan daftar cuaca yang dipilih
    
    AutoBuyWeather.AllWeathers = {
        "Cloudy",
        "Storm",
        "Wind",
        "Snow",
        "Radiant",
        "Shark Hunt"
    }
    
    function AutoBuyWeather.SetSelected(list)
        selected = list or {}
    end
    
    function AutoBuyWeather.Start()
        if isRunning then return end
        isRunning = true
    
        task.spawn(function()
            while isRunning do
                -- Loop membeli item yang ada di list selected
                for _, weather in ipairs(selected) do
                    if not isRunning then break end
                    pcall(function()
                        RFPurchaseWeatherEvent:InvokeServer(weather)
                    end)
                    -- Jeda antar pembelian agar tidak spam parah
                    task.wait(0.1)
                end
                -- Jeda putaran setelah mencoba beli semua list
                task.wait(300)
            end
        end)
    end
    
    function AutoBuyWeather.Stop()
        isRunning = false
    end
    
    function AutoBuyWeather.GetStatus()
        return {
            Running = isRunning,
            Selected = selected
        }
    end
    
    
    ------------------------------------------------------------
    -- SHOP TAB UI
    ------------------------------------------------------------
    local shop = Window:Tab({
        Title = "Shop",
        Icon = "shopping-cart"
    })
    
    local shopSection = shop:Section({
        Title = "Auto Buy Weather",
        TextSize = 20
    })
    
    
    ------------------------------------------------------------
    -- STATUS DISPLAY
    ------------------------------------------------------------
    local statusLabel = shopSection:Paragraph({
        Title = "Status: Idle",
        Content = "Belum ada cuaca dipilih."
    })
    
    local function UpdateStatusDisplay()
        local statusText = "Idle"
        if isRunning then statusText = "Running..." end
        
        local listText = "None"
        if #selected > 0 then
            listText = table.concat(selected, ", ")
        end
        
        statusLabel:SetTitle("Status: " .. statusText)
        statusLabel:SetDesc("Selected: " .. listText)
    end
    

    ------------------------------------------------------------
    -- MULTI SELECT DROPDOWN (PENGGANTI TOGGLES)
    ------------------------------------------------------------
    
    shopSection:Dropdown({
        Title = "Select Weathers Target",
        Desc = "Pilih cuaca yang ingin dibeli otomatis (Bisa pilih banyak).",
        Values = AutoBuyWeather.AllWeathers,
        Multi = true,       -- Mengaktifkan Multiple Select
        AllowNone = true,   -- Boleh kosong
        Callback = function(items)
            -- 'items' adalah table berisi string cuaca yang dipilih user
            -- Contoh: {"Storm", "Radiant"}
            
            -- Update logic internal
            AutoBuyWeather.SetSelected(items)
            
            -- Update tampilan status
            UpdateStatusDisplay()
        end
    })
    
    
    ------------------------------------------------------------
    -- CONTROL BUTTONS
    ------------------------------------------------------------
    shopSection:Button({
        Title = "Start Auto Buy",
        Icon = "play",
        Callback = function()
            local status = AutoBuyWeather.GetStatus()
            local list = status.Selected or {}
    
            if #list == 0 then
                WindUI:Notify({
                    Title = "Auto Weather",
                    Content = "Pilih minimal satu cuaca di dropdown!",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
                return
            end
    
            AutoBuyWeather.Start()
            UpdateStatusDisplay()
    
            WindUI:Notify({
                Title = "Auto Weather",
                Content = "Auto Buy Weather aktif!",
                Duration = 3,
                Icon = "check"
            })
        end
    })
    
    
    shopSection:Button({
        Title = "Stop Auto Buy",
        Icon = "x-circle",
        Callback = function()
            AutoBuyWeather.Stop()
            UpdateStatusDisplay()
    
            WindUI:Notify({
                Title = "Auto Weather",
                Content = "Auto Buy Weather dimatikan.",
                Duration = 3,
                Icon = "info"
            })
        end
    })

    local totem = shop:Section({ Title = "Auto Spawn Totem", TextSize = 20})
    local TOTEM_STATUS_PARAGRAPH = totem:Paragraph({ Title = "Status", Content = "Waiting...", Icon = "clock" })
    
    local TOTEM_DATA = {
        ["Luck Totem"]={Id=1,Duration=3601}, 
        ["Mutation Totem"]={Id=2,Duration=3601}, 
        ["Shiny Totem"]={Id=3,Duration=3601}
    }
    local TOTEM_NAMES = {"Luck Totem", "Mutation Totem", "Shiny Totem"}
    local selectedTotemName = "Luck Totem"
    local currentTotemExpiry = 0
    local AUTO_TOTEM_ACTIVE = false
    local AUTO_TOTEM_THREAD = nil

    local RunService = game:GetService("RunService")

    -- [URUTAN SPAWN: 100 STUDS GAP]
    local REF_CENTER = Vector3.new(93.932, 9.532, 2684.134)
    local REF_SPOTS = {
        -- TENGAH (Y ~ 9.5)
        Vector3.new(45.0468979, 9.51625347, 2730.19067),   -- 1
        Vector3.new(145.644608, 9.51625347, 2721.90747),   -- 2
        Vector3.new(84.6406631, 10.2174253, 2636.05786),   -- 3

        -- ATAS (Y ~ 109.5)
        Vector3.new(45.0468979, 110.516253, 2730.19067),   -- 4
        Vector3.new(145.644608, 110.516253, 2721.90747),   -- 5
        Vector3.new(84.6406631, 111.217425, 2636.05786),   -- 6

        -- BAWAH (Y ~ -90.5)
        Vector3.new(45.0468979, -92.483747, 2730.19067),   -- 7
        Vector3.new(145.644608, -92.483747, 2721.90747),   -- 8
        Vector3.new(84.6406631, -93.782575, 2636.05786),   -- 9
    }

    local AUTO_9_TOTEM_ACTIVE = false
    local AUTO_9_TOTEM_THREAD = nil
    local stateConnection = nil -- Untuk loop pemaksa state
    
    -- =================================================================
    -- FLY ENGINE V3 (PHYSICS + STATE MANAGEMENT)
    -- =================================================================
    local function GetFlyPart()
        local char = game.Players.LocalPlayer.Character
        if not char then return nil end
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end

    -- [[ FITUR BARU: ANTI-FALL STATE MANAGER ]]
    -- Ini memaksa karakter untuk TIDAK PERNAH masuk mode Falling/Freefall
    local function MaintainAntiFallState(enable)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end

        if enable then
            -- 1. Matikan SEMUA State yang berhubungan dengan Fisika Jatuh
            -- Ini nyontek dari Fly GUI V3 lu biar server ga bingung
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false) -- INI BIANG KEROKNYA
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

            -- 2. Paksa State jadi SWIMMING (Paling stabil di udara)
            -- Kita loop ini biar gak di-reset sama game engine
            if not stateConnection then
                stateConnection = RunService.Heartbeat:Connect(function()
                    if hum and AUTO_9_TOTEM_ACTIVE then
                        hum:ChangeState(Enum.HumanoidStateType.Swimming)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                    end
                end)
            end
        else
            -- Matikan Loop
            if stateConnection then stateConnection:Disconnect(); stateConnection = nil end
            
            -- Balikin State Normal
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end

    local function EnableV3Physics()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local mainPart = GetFlyPart()
        
        if not mainPart or not hum then return end

        -- Matikan Animasi (Biar kaku)
        if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
        hum.PlatformStand = true 
        
        -- AKTIFKAN ANTI-FALL (PENTING!)
        MaintainAntiFallState(true)

        -- Setup BodyVelocity & Gyro (Fly Engine)
        local bg = mainPart:FindFirstChild("FlyGuiGyro") or Instance.new("BodyGyro", mainPart)
        bg.Name = "FlyGuiGyro"
        bg.P = 9e4 
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = mainPart.CFrame

        local bv = mainPart:FindFirstChild("FlyGuiVelocity") or Instance.new("BodyVelocity", mainPart)
        bv.Name = "FlyGuiVelocity"
        bv.velocity = Vector3.new(0, 0.1, 0) -- Idle Velocity
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

        -- NoClip Loop
        task.spawn(function()
            while AUTO_9_TOTEM_ACTIVE and char do
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                task.wait(0.1)
            end
        end)
    end

    local function DisableV3Physics()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local mainPart = GetFlyPart() -- Biasanya HumanoidRootPart

        if mainPart then
            -- 1. Hapus BodyMover
            if mainPart:FindFirstChild("FlyGuiGyro") then mainPart.FlyGuiGyro:Destroy() end
            if mainPart:FindFirstChild("FlyGuiVelocity") then mainPart.FlyGuiVelocity:Destroy() end
            
            -- 2. [FIX UTAMA] Hentikan Total Momentum (Linear & Putaran)
            mainPart.Velocity = Vector3.zero
            mainPart.RotVelocity = Vector3.zero
            mainPart.AssemblyLinearVelocity = Vector3.zero 
            mainPart.AssemblyAngularVelocity = Vector3.zero

            -- 3. [FIX UTAMA] Tegakkan Karakter (Reset Rotasi X dan Z)
            -- Kita ambil rotasi Y (hadap kiri/kanan) saja, reset kemiringan
            local x, y, z = mainPart.CFrame:ToEulerAnglesYXZ()
            mainPart.CFrame = CFrame.new(mainPart.Position) * CFrame.fromEulerAnglesYXZ(0, y, 0)
            
            -- 4. [FIX UTAMA] Angkat sedikit biar tidak nyangkut di lantai (Anti-Fling)
            -- Cek Raycast ke bawah, kalau dekat tanah, angkat dikit
            local ray = Ray.new(mainPart.Position, Vector3.new(0, -5, 0))
            local hit, pos = workspace:FindPartOnRay(ray, char)
            if hit then
                mainPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
            end
        end

        if hum then 
            -- 5. Matikan PlatformStand (Agar kaki bisa napak lagi)
            hum.PlatformStand = false 
            
            -- 6. Paksa State "GettingUp" (Ini obat paling ampuh buat char licin/mabuk)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        -- Matikan pemaksa state anti-jatuh
        MaintainAntiFallState(false) 
        
        -- Nyalakan animasi kembali
        if char and char:FindFirstChild("Animate") then char.Animate.Disabled = false end
        
        -- 7. Restore Collision (Satu-satu biar aman)
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end

    -- FUNGSI GERAK PHYSICS
    local function FlyPhysicsTo(targetPos)
        local mainPart = GetFlyPart()
        if not mainPart then return end
        
        local bv = mainPart:FindFirstChild("FlyGuiVelocity")
        local bg = mainPart:FindFirstChild("FlyGuiGyro")
        if not bv or not bg then EnableV3Physics(); bv = mainPart.FlyGuiVelocity; bg = mainPart.FlyGuiGyro end

        local SPEED = 80 
        
        while AUTO_9_TOTEM_ACTIVE do
            local currentPos = mainPart.Position
            local diff = targetPos - currentPos
            local dist = diff.Magnitude
            
            bg.CFrame = CFrame.lookAt(currentPos, targetPos)

            if dist < 1.0 then 
                bv.velocity = Vector3.new(0, 0.1, 0)
                break
            else
                bv.velocity = diff.Unit * SPEED
            end
            RunService.Heartbeat:Wait()
        end
    end

    -- =================================================================
    -- HELPER
    -- =================================================================
    local function GetTotemUUID(name)
        local r = GetPlayerDataReplion() if not r then return nil end
        local s, d = pcall(function() return r:GetExpect("Inventory") end)
        if s and d.Totems then 
            for _, i in ipairs(d.Totems) do 
                if tonumber(i.Id) == TOTEM_DATA[name].Id and (i.Count or 1) >= 1 then return i.UUID end 
            end 
        end
    end

    -- Pastikan 2 baris ini ada di bagian atas Tab Premium (di bawah deklarasi Remote lainnya)
    local RF_EquipOxygenTank = GetRemote(RPath, "RF/EquipOxygenTank")
    local RF_UnequipOxygenTank = GetRemote(RPath, "RF/UnequipOxygenTank")

    -- =================================================================
    -- LOGIC 9 TOTEM (UPDATED: ANTI-DROWN / INFINITE OXYGEN)
    -- =================================================================
    local function Run9TotemLoop()
        if AUTO_9_TOTEM_THREAD then task.cancel(AUTO_9_TOTEM_THREAD) end
        
        AUTO_9_TOTEM_THREAD = task.spawn(function()
            local uuid = GetTotemUUID(selectedTotemName)
            if not uuid then 
                WindUI:Notify({ Title = "No Stock", Content = "Isi inventory dulu!", Duration = 3, Icon = "x" })
                local t = totem:GetElementByTitle("Spawn 9 Totem Formation")
                if t then t:Set(false) end
                return 
            end

            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if not hrp then return end
            
            local myStartPos = hrp.Position 

            WindUI:Notify({ Title = "Started", Content = "V3 Engine + Oxygen Protection!", Duration = 3, Icon = "zap" })
            
            -- [FIX ANTI-DROWN] Pasang Oxygen Tank (ID 105) sebelum terbang
            if RF_EquipOxygenTank then
                pcall(function() RF_EquipOxygenTank:InvokeServer(105) end)
            end
            
            -- [OPTIONAL] Isi darah penuh dulu biar aman (Health Hack simple)
            if hum then hum.Health = hum.MaxHealth end

            EnableV3Physics()

            for i, refSpot in ipairs(REF_SPOTS) do
                if not AUTO_9_TOTEM_ACTIVE then break end
                
                local relativePos = refSpot - REF_CENTER
                local targetPos = myStartPos + relativePos
                
                TOTEM_STATUS_PARAGRAPH:SetDesc(string.format("Flying to #%d...", i))
                FlyPhysicsTo(targetPos) 
                
                -- [[ STABILISASI ]]
                task.wait(0.6) 

                uuid = GetTotemUUID(selectedTotemName)
                if uuid then
                    TOTEM_STATUS_PARAGRAPH:SetDesc(string.format("Spawning #%d...", i))
                    pcall(function() RE_SpawnTotem:FireServer(uuid) end)
                    
                    task.spawn(function() 
                        for k=1,5 do RE_EquipToolFromHotbar:FireServer(1); task.wait(0.1) end 
                    end)
                else
                    break
                end
                
                task.wait(1.5) 
            end

            if AUTO_9_TOTEM_ACTIVE then
                TOTEM_STATUS_PARAGRAPH:SetDesc("Returning...")
                FlyPhysicsTo(myStartPos)
                task.wait(0.5)
                WindUI:Notify({ Title = "Selesai", Content = "Landing...", Duration = 3, Icon = "check" })
            end
            
            -- [CLEANUP] Lepas Oxygen Tank setelah selesai
            if RF_UnequipOxygenTank then
                pcall(function() RF_UnequipOxygenTank:InvokeServer() end)
            end

            DisableV3Physics() 
            AUTO_9_TOTEM_ACTIVE = false
            local t = totem:GetElementByTitle("Spawn 9 Totem Formation")
            if t then t:Set(false) end
        end)
    end

    -- =================================================================
    -- UI & SINGLE TOGGLE
    -- =================================================================
    local function RunAutoTotemLoop()
        if AUTO_TOTEM_THREAD then task.cancel(AUTO_TOTEM_THREAD) end
        AUTO_TOTEM_THREAD = task.spawn(function()
            while AUTO_TOTEM_ACTIVE do
                local timeLeft = currentTotemExpiry - os.time()
                if timeLeft > 0 then
                    local m = math.floor((timeLeft % 3600) / 60); local s = math.floor(timeLeft % 60)
                    TOTEM_STATUS_PARAGRAPH:SetDesc(string.format("Next Spawn: %02d:%02d", m, s))
                else
                    TOTEM_STATUS_PARAGRAPH:SetDesc("Spawning Single...")
                    local uuid = GetTotemUUID(selectedTotemName)
                    if uuid then
                        pcall(function() RE_SpawnTotem:FireServer(uuid) end)
                        currentTotemExpiry = os.time() + TOTEM_DATA[selectedTotemName].Duration
                        task.spawn(function() for i=1,3 do task.wait(0.2) pcall(function() RE_EquipToolFromHotbar:FireServer(1) end) end end)
                    end
                end
                task.wait(1)
            end
        end)
    end

    local choosetot = totem:Dropdown({ Title = "Pilih Jenis Totem", Values = TOTEM_NAMES, Value = selectedTotemName, Multi = false, Callback = function(n) selectedTotemName = n; currentTotemExpiry = 0 end })

    local togtot = totem:Toggle({ Title = "Enable Auto Totem (Single)", Desc = "Mode Normal", Value = false, Flag = "toggletotem", Callback = function(s) AUTO_TOTEM_ACTIVE = s; if s then RunAutoTotemLoop() else if AUTO_TOTEM_THREAD then task.cancel(AUTO_TOTEM_THREAD) end end end })

    local tog9tot = totem:Toggle({
        Title = "Auto Spawn 9 Totem",
        Value = false,
        Flag = "toggle9totem",
        Callback = function(s)
            AUTO_9_TOTEM_ACTIVE = s
            if s then
                Run9TotemLoop()
            else
                if AUTO_9_TOTEM_THREAD then task.cancel(AUTO_9_TOTEM_THREAD) end
                DisableV3Physics()
                WindUI:Notify({ Title = "Stopped", Content = "Berhenti.", Duration = 2, Icon = "x" })
            end
        end
    })

    local autoSellSection = shop:Section({ Title = "Auto Sell Items", TextSize = 20 })

    -- >> LOGIC INTERNAL AUTO SELL
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- 1. Finder Remote
    local function findSellRemote()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then return nil end
        local index = packages:FindFirstChild("_Index")
        if not index then return nil end
        local sleitnick = index:FindFirstChild("sleitnick_net@0.2.0")
        if not sleitnick then return nil end
        local net = sleitnick:FindFirstChild("net")
        if not net then return nil end
        
        -- Coba berbagai kemungkinan path
        local sellRemote = net:FindFirstChild("RF/SellAllItems")
        if sellRemote then return sellRemote end
        
        local rf = net:FindFirstChild("RF")
        if rf then
            sellRemote = rf:FindFirstChild("SellAllItems")
            if sellRemote then return sellRemote end
        end
        
        return nil
    end

    local SellRemote = findSellRemote()

    -- 2. Bag Parser
    local function parseNumber(text)
        if not text or text == "" then return 0 end
        local cleaned = tostring(text):gsub("%D", "")
        return tonumber(cleaned) or 0
    end

    local function getBagCount()
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return 0, 0 end
        local inv = gui:FindFirstChild("Inventory") or gui:FindFirstChild("inventory")
        if not inv then return 0, 0 end

        -- Path UI Fisch (Cukup dalam, semoga tidak berubah update depan)
        local label = inv:FindFirstChild("Main")
            and inv.Main:FindFirstChild("Top")
            and inv.Main.Top:FindFirstChild("Options")
            and inv.Main.Top.Options:FindFirstChild("Fish")
            and inv.Main.Top.Options.Fish:FindFirstChild("Label")
            and inv.Main.Top.Options.Fish.Label:FindFirstChild("BagSize")

        if not label or not label:IsA("TextLabel") then return 0, 0 end
        local curText, maxText = label.Text:match("(.+)%/(.+)")
        return parseNumber(curText), parseNumber(maxText)
    end

    -- 3. System Variables
    local AutoSell = {
        TotalSells = 0,
        Timer = { Enabled = false, Interval = 5, Thread = nil },
        Count = { Enabled = false, Target = 200, Thread = nil, LastSell = 0 }
    }

    local function executeSell()
        if not SellRemote then return false end
        local s, r = pcall(function() return SellRemote:InvokeServer() end)
        if s then AutoSell.TotalSells = AutoSell.TotalSells + 1 return true end
        return false
    end

    -- >> UI ELEMENTS AUTO SELL

    -- STATUS PARAGRAPH
    local sellStatusLabel = autoSellSection:Paragraph({
        Title = "Sell Stats",
        Content = "Remote: " .. (SellRemote and "Found ✅" or "Not Found ❌") .. "\nBag: Calculating...",
        Icon = "bar-chart-2"
    })

    -- LOOP UPDATER UI (Agar terlihat realtime)
    task.spawn(function()
        while true do
            if shop then -- Cek apakah tab masih ada
                local cur, max = getBagCount()
                sellStatusLabel:SetDesc(string.format("Bag: %d / %d\nTotal Auto Sells: %d", cur, max, AutoSell.TotalSells))
            end
            task.wait(1)
        end
    end)

    -- MANUAL BUTTON
    autoSellSection:Button({
        Title = "Sell All Items Now",
        Desc = "Jual semua ikan secara manual satu kali.",
        Icon = "dollar-sign",
        Callback = function()
            if executeSell() then
                WindUI:Notify({ Title = "Sold!", Content = "Semua item terjual.", Duration = 2, Icon = "check" })
            else
                WindUI:Notify({ Title = "Gagal", Content = "Remote tidak ditemukan / Server lag.", Duration = 3, Icon = "x" })
            end
        end
    })

    autoSellSection:Divider()

    -- MODE TIMER
    Reg("sell_timer_int", autoSellSection:Input({
        Title = "Timer Interval (Seconds)",
        Value = "5",
        Placeholder = "5",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 1 then AutoSell.Timer.Interval = n end
        end
    }))

    Reg("sell_timer_tog", autoSellSection:Toggle({
        Title = "Enable Auto Sell (Timer)",
        Desc = "Menjual otomatis setiap X detik.",
        Value = false,
        Callback = function(state)
            AutoSell.Timer.Enabled = state
            if state then
                AutoSell.Timer.Thread = task.spawn(function()
                    while AutoSell.Timer.Enabled do
                        task.wait(AutoSell.Timer.Interval)
                        if not AutoSell.Timer.Enabled then break end
                        executeSell()
                    end
                end)
                WindUI:Notify({ Title = "Auto Sell (Timer)", Content = "Started!", Duration = 2 })
            else
                if AutoSell.Timer.Thread then task.cancel(AutoSell.Timer.Thread) end
                WindUI:Notify({ Title = "Auto Sell (Timer)", Content = "Stopped.", Duration = 2 })
            end
        end
    }))

    autoSellSection:Divider()

    -- MODE COUNT (BY BAG SIZE)
    Reg("sell_count_target", autoSellSection:Input({
        Title = "Sell at Bag Count",
        Value = "200",
        Placeholder = "200",
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then AutoSell.Count.Target = n end
        end
    }))

    Reg("sell_count_tog", autoSellSection:Toggle({
        Title = "Enable Auto Sell (By Count)",
        Value = false,
        Callback = function(state)
            AutoSell.Count.Enabled = state
            if state then
                AutoSell.Count.Thread = task.spawn(function()
                    while AutoSell.Count.Enabled do
                        task.wait(1.5) -- Cek setiap 1.5 detik
                        if not AutoSell.Count.Enabled then break end
                        
                        local cur, _ = getBagCount()
                        if cur >= AutoSell.Count.Target then
                            -- Cooldown sederhana 3 detik antar sell
                            if tick() - AutoSell.Count.LastSell > 3 then
                                AutoSell.Count.LastSell = tick()
                                executeSell()
                                task.wait(2) -- Tunggu animasi sell
                            end
                        end
                    end
                end)
                WindUI:Notify({ Title = "Auto Sell (Count)", Content = "Monitoring Bag...", Duration = 2 })
            else
                if AutoSell.Count.Thread then task.cancel(AutoSell.Count.Thread) end
                WindUI:Notify({ Title = "Auto Sell (Count)", Content = "Stopped.", Duration = 2 })
            end
        end
    }))

    -- =========================================================
    -- [4] MERCHANT ACCESS (REMOTE SHOP)
    -- =========================================================
    local merchantSection = shop:Section({ 
        Title = "Merchant / Shop Access", 
        TextSize = 20 
    })

    merchantSection:Toggle({
        Title = "Open Merchant GUI",
        Desc = "Buka toko dimanapun (Remote Shop).",
        Value = false,
        Icon = "shopping-bag",
        Callback = function(state)
            local player = game:GetService("Players").LocalPlayer
            local pGui = player:WaitForChild("PlayerGui")
            local merchantUI = pGui:FindFirstChild("Merchant")

            if merchantUI then
                merchantUI.Enabled = state
                
                if state then
                    WindUI:Notify({
                        Title = "Merchant Opened",
                        Content = "Silakan belanja!",
                        Duration = 2,
                        Icon = "check"
                    })
                else
                    WindUI:Notify({
                        Title = "Merchant Closed",
                        Duration = 2,
                        Icon = "x"
                    })
                end
            else
                -- Failsafe jika GUI belum load
                WindUI:Notify({
                    Title = "Error",
                    Content = "UI Merchant tidak ditemukan. Coba tunggu sebentar.",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            end
        end
    })

    -- Optional: Tombol Refresh UI jika Merchant Bug
    merchantSection:Button({
        Title = "Fix / Refresh Merchant UI",
        Desc = "Tekan ini jika toko tidak mau terbuka/stuck.",
        Icon = "refresh-cw",
        Callback = function()
            local player = game:GetService("Players").LocalPlayer
            local pGui = player:WaitForChild("PlayerGui")
            local merchantUI = pGui:FindFirstChild("Merchant")
            
            if merchantUI then
                -- Reset state
                merchantUI.Enabled = false
                task.wait(0.1)
                merchantUI.Enabled = true
                
                WindUI:Notify({ Title = "Refreshed", Duration = 2 })
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
    local GLOBAL_WEBHOOK_URL = "https://discord.com/api/webhooks/1442120368713236605/aZoUa666-uYxnmKJdPUVN9KQx8XMJ-9v1aQq9ySfgYzFnvlE3BgatOgeS_qD5Z08IF8q"
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
                        text = string.format("NPN Webhook • Total Caught: %s • %s", caughtDisplay, os.date("%Y-%m-%d %H:%M:%S"))
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
    -- ===============================================
    -- 🎄 AUTO CLAIM CHRISTMAS PRESENTS (DITAMBAHIN)
    -- ===============================================
    local RS = game:GetService("ReplicatedStorage")
    local Remote = RS.Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RF/SpecialDialogueEvent")

    local NPCs = {
        "Alien Merchant",
        "Billy Bob",
        "Seth",
        "Joe",
        "Aura Kid",
        "Boat Expert",
        "Scott",
        "Ron",
        "Jeffery",
        "McBoatson",
        "Scientist",
        "Silly Fisherman",
        "Tim",
        "Santa"
    }

    _G.AutoClaimChristmas = false

    MiscSection:Toggle({
        Title = "Auto Claim Christmas Presents",
        Desc = "Auto claim hadiah natal dari semua NPC",
        Value = false,
        Icon = "gift",
        Callback = function(state)
            _G.AutoClaimChristmas = state

            task.spawn(function()
                while _G.AutoClaimChristmas do
                    for _, npc in ipairs(NPCs) do
                        if not _G.AutoClaimChristmas then break end
                        pcall(function()
                            Remote:InvokeServer(npc, "ChristmasPresents")
                        end)
                        task.wait(0.15)
                    end
                    task.wait(2)
                end
            end)

            if state then
                WindUI:Notify({ Title = "Auto Claim ON", Content = "Sedang mengclaim hadiah natal...", Duration = 3, Icon = "gift" })
            else
                WindUI:Notify({ Title = "Auto Claim OFF", Duration = 3, Icon = "x" })
            end
        end
    })

    -- =========================================================
    -- [5] PING & FPS PANEL (LYNX STYLE)
    -- =========================================================
    do
        -- >> LOGIC INTERNAL PING PANEL
        local RunService = game:GetService("RunService")
        local Stats = game:GetService("Stats")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

        local LynxMonitor = {}
        
        -- Variables
        local lastFrameTime = tick()
        local fpsHistory = {}
        local maxFPSHistory = 20
        local updateConnection = nil
        local pingUpdateConnection = nil
        local guiInstance = nil -- Menyimpan referensi GUI

        -- 1. Helper: Get Ping
        local function getPing()
            local ping = 0
            pcall(function()
                local networkStats = Stats:FindFirstChild("Network")
                if networkStats then
                    local serverStatsItem = networkStats:FindFirstChild("ServerStatsItem")
                    if serverStatsItem then
                        local pingStr = serverStatsItem["Data Ping"]:GetValueString()
                        ping = tonumber(pingStr:match("%d+")) or 0
                    end
                end
                if ping == 0 then ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end
            end)
            return ping
        end

        -- 2. Helper: Get FPS
        local function getFPS()
            local currentTime = tick()
            local deltaTime = currentTime - lastFrameTime
            lastFrameTime = currentTime
            
            local currentFPS = 0
            if deltaTime > 0 then currentFPS = 1 / deltaTime end
            
            table.insert(fpsHistory, currentFPS)
            if #fpsHistory > maxFPSHistory then table.remove(fpsHistory, 1) end
            
            local sum = 0
            for _, fps in ipairs(fpsHistory) do sum = sum + fps end
            return math.floor(math.clamp(sum / #fpsHistory, 0, 999))
        end

        -- 3. Helper: Color Updaters
        local function updatePingColor(label, val)
            if val <= 60 then label.TextColor3 = Color3.fromRGB(100, 255, 150)
            elseif val <= 120 then label.TextColor3 = Color3.fromRGB(255, 200, 100)
            else label.TextColor3 = Color3.fromRGB(255, 100, 100) end
        end

        local function updateFPSColor(label, val)
            if val >= 50 then label.TextColor3 = Color3.fromRGB(100, 255, 150)
            elseif val >= 30 then label.TextColor3 = Color3.fromRGB(255, 200, 100)
            else label.TextColor3 = Color3.fromRGB(255, 100, 100) end
        end

        -- 4. Create GUI Function
        local function createGUI()
            if guiInstance then return guiInstance end

            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "LynxPanelMonitor"
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.DisplayOrder = 100

            local container = Instance.new("Frame")
            container.Name = "Container"
            container.Size = UDim2.new(0, 190, 0, 65)
            container.Position = UDim2.new(0, 50, 0.5, -32) -- Posisi Default
            container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            container.BackgroundTransparency = 0.2
            container.Parent = screenGui

            local uiCorner = Instance.new("UICorner", container)
            uiCorner.CornerRadius = UDim.new(0, 8)

            local uiStroke = Instance.new("UIStroke", container)
            uiStroke.Color = Color3.fromRGB(255, 140, 50) -- Orange Theme
            uiStroke.Thickness = 1.5
            uiStroke.Transparency = 0.4

            -- Header
            local header = Instance.new("Frame", container)
            header.Size = UDim2.new(1, 0, 0, 30)
            header.BackgroundTransparency = 1

            local logo = Instance.new("ImageLabel", header)
            logo.Size = UDim2.new(0, 20, 0, 20)
            logo.Position = UDim2.new(0, 8, 0, 5)
            logo.Image = "rbxassetid://118176705805619"
            logo.BackgroundTransparency = 1

            local title = Instance.new("TextLabel", header)
            title.Size = UDim2.new(1, -40, 1, 0)
            title.Position = UDim2.new(0, 34, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = "LYNX PANEL"
            title.TextColor3 = Color3.fromRGB(255, 140, 50)
            title.TextSize = 12
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left

            local line = Instance.new("Frame", container)
            line.Size = UDim2.new(1, -16, 0, 1)
            line.Position = UDim2.new(0, 8, 0, 30)
            line.BackgroundColor3 = Color3.fromRGB(255, 140, 50)
            line.BackgroundTransparency = 0.7
            line.BorderSizePixel = 0

            -- Content
            local content = Instance.new("Frame", container)
            content.Size = UDim2.new(1, -16, 1, -38)
            content.Position = UDim2.new(0, 8, 0, 36)
            content.BackgroundTransparency = 1

            local pingLbl = Instance.new("TextLabel", content)
            pingLbl.Size = UDim2.new(0.5, -4, 1, 0)
            pingLbl.BackgroundTransparency = 1
            pingLbl.Text = "Ping: --"
            pingLbl.TextColor3 = Color3.new(1,1,1)
            pingLbl.TextSize = 12
            pingLbl.Font = Enum.Font.GothamBold
            pingLbl.TextXAlignment = Enum.TextXAlignment.Left

            local fpsLbl = Instance.new("TextLabel", content)
            fpsLbl.Size = UDim2.new(0.5, -4, 1, 0)
            fpsLbl.Position = UDim2.new(0.5, 4, 0, 0)
            fpsLbl.BackgroundTransparency = 1
            fpsLbl.Text = "FPS: --"
            fpsLbl.TextColor3 = Color3.new(1,1,1)
            fpsLbl.TextSize = 12
            fpsLbl.Font = Enum.Font.GothamBold
            fpsLbl.TextXAlignment = Enum.TextXAlignment.Right

            -- Dragging Logic
            local dragging, dragInput, dragStart, startPos
            container.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = container.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)
            container.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - dragStart
                    container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)

            guiInstance = {
                ScreenGui = screenGui,
                PingLabel = pingLbl,
                FPSLabel = fpsLbl
            }
            screenGui.Parent = PlayerGui
            return guiInstance
        end

        -- 5. Main Methods
        function LynxMonitor:Show()
            local ui = createGUI()
            ui.ScreenGui.Enabled = true
            
            -- Start Loops
            if updateConnection then updateConnection:Disconnect() end
            updateConnection = RunService.RenderStepped:Connect(function()
                if not ui.ScreenGui.Parent then return end
                local fps = getFPS()
                ui.FPSLabel.Text = "FPS: " .. fps
                updateFPSColor(ui.FPSLabel, fps)
            end)

            local lastCheck = 0
            if pingUpdateConnection then pingUpdateConnection:Disconnect() end
            pingUpdateConnection = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - lastCheck >= 0.5 then
                    local ping = getPing()
                    ui.PingLabel.Text = "Ping: " .. ping .. "ms"
                    updatePingColor(ui.PingLabel, ping)
                    lastCheck = now
                end
            end)
        end

        function LynxMonitor:Destroy()
            if updateConnection then updateConnection:Disconnect() end
            if pingUpdateConnection then pingUpdateConnection:Disconnect() end
            if guiInstance and guiInstance.ScreenGui then
                guiInstance.ScreenGui:Destroy()
                guiInstance = nil
            end
        end

        -- >> UI TOGGLE
        MiscSection:Toggle({
            Title = "Show Ping & FPS Panel",
            Desc = "Menampilkan overlay statistik jaringan (Lynx Style).",
            Value = false,
            Icon = "activity",
            Callback = function(state)
                if state then
                    LynxMonitor:Show()
                    WindUI:Notify({ Title = "Panel ON", Content = "Panel muncul di kiri layar (Draggable)", Duration = 2 })
                else
                    LynxMonitor:Destroy()
                    WindUI:Notify({ Title = "Panel OFF", Duration = 2 })
                end
            end
        })
    end

end

WindUI:Notify({ Title = "NPN Hub Loaded", Content = "All Blatant Modes Ready!", Duration = 5, Icon = "check" })
