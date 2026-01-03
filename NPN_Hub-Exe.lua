-- [[ FISH IT HUB - FLUENT UI WITH ADVANCED FEATURES ]] --
-- Implementasi fitur dari Wind UI ke Fluent UI
-- Universal compatibility untuk semua executor

-- [[ EXECUTOR DETECTION ]] --
local function detectExecutor()
    if identifyexecutor then
        local name = identifyexecutor():lower()
        if name:find("delta") then return "delta"
        elseif name:find("xeno") then return "xeno"
        elseif name:find("krnl") then return "krnl"
        elseif name:find("synapse") then return "synapse"
        elseif name:find("jjsploit") then return "jjsploit"
        elseif name:find("fluxus") then return "fluxus"
        end
    end
    return "unknown"
end

local currentExecutor = detectExecutor()
local isFreeTier = (currentExecutor == "xeno" or currentExecutor == "krnl" or currentExecutor == "jjsploit")

-- Configuration
local Config = {
    TeleportDelay = isFreeTier and 3 or 1,
    ScanInterval = isFreeTier and 20 or 8,
    MaxTeleportDistance = isFreeTier and 800 or 9999,
    UseAdvancedFeatures = not isFreeTier,
    AddRandomDelay = isFreeTier,
    EnableDebugMode = false,
    SearchRadius = 25,
    HeightOffset = 15,
    WaitForEventTimeout = 300
}

-- [[ FLUENT UI LOADER ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local RepStorage = game:GetService("ReplicatedStorage")

-- Script variables
local autoEventRunning = false
local selectedEvent = "Shark Hunt"
local lastTeleportTime = 0
local currentStatus = "Initializing..."
local statusUpdateThread = nil
local autoEventThread = nil
local lochCountdownGui = nil
local lochCountdownThread = nil

-- Event variables
local cachedEventPosition = nil
local eventIsActive = false
local lastTeleportPosition = nil
local lastScanTime = 0
local scanCooldown = 10

-- [[ ADVANCED ANTI-AFK SYSTEM ]] --
local function setupAntiAFK()
    local success = false
    
    -- Advanced method dari Wind UI
    pcall(function()
        local player = LocalPlayer
        for i, v in pairs(getconnections(player.Idled)) do
            if v.Disable then
                v:Disable()
                success = true
            end
        end
    end)
    
    -- Fallback method
    if not success then
        pcall(function()
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
            success = true
        end)
    end
    
    return success
end

-- [[ HELPER FUNCTIONS ]] --
local function safeWait(duration)
    local start = tick()
    while tick() - start < duration do
        RunService.Heartbeat:Wait()
    end
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

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

-- [[ ADVANCED STATUS DETECTION - DARI WIND UI ]] --
local function getStatus()
    local char = LocalPlayer.Character
    if not char then return "UNKNOWN" end
    
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not hrp then return "UNKNOWN" end

    -- Cek State Swimming (Paling Akurat)
    if hum:GetState() == Enum.HumanoidStateType.Swimming then
        return "🌊 WATER (SWIMMING)"
    end

    -- Cek Material Pijakan (FloorMaterial)
    if hum.FloorMaterial == Enum.Material.Water then
        return "🌊 WATER"
    end
    
    if hum.FloorMaterial ~= Enum.Material.Air then
        return "🏝️ LAND"
    end

    -- Raycast Fallback
    local origin = hrp.Position
    local direction = Vector3.new(0, -15, 0)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = false

    local result = Workspace:Raycast(origin, direction, params)

    if result then
        if result.Material == Enum.Material.Water then
            return "🌊 WATER"
        else
            return "🏝️ LAND"
        end
    end

    return "✈️ AIRBORNE"
end

-- [[ LOCHNESS TIMER SYSTEM - DARI WIND UI ]] --
local LOCH_INTERVAL = 4 * 3600    -- 4 jam
local LOCH_DURATION = 10 * 60     -- 10 menit

local function getLochNextTimes()
    local now = os.time()
    local base = math.floor(now / LOCH_INTERVAL) * LOCH_INTERVAL
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
    if lochCountdownGui and lochCountdownGui.Parent then
        lochCountdownGui.Enabled = true
        return
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    lochCountdownGui = Instance.new("ScreenGui")
    lochCountdownGui.Name = "LochnessCountdownGUI"
    lochCountdownGui.ResetOnSpawn = false
    lochCountdownGui.IgnoreGuiInset = true
    lochCountdownGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "LochFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Size = UDim2.new(0, 280, 0, 50)
    frame.Position = UDim2.new(0.5, 0, 0.06, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = lochCountdownGui

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, -8)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "🐉 Lochness: calculating..."
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame

    -- Update loop
    if lochCountdownThread then task.cancel(lochCountdownThread) end
    lochCountdownThread = task.spawn(function()
        while lochCountdownGui and lochCountdownGui.Parent do
            local startT, endT, active = getLochNextTimes()
            local now = os.time()
            local remaining = (active and (endT - now)) or (startT - now)
            remaining = math.max(0, remaining)
            if active then
                label.Text = ("🔥 Lochness ACTIVE! Ends in %s"):format(formatTimeSeconds(remaining))
                label.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                label.Text = ("🐉 Next Lochness in %s"):format(formatTimeSeconds(remaining))
                label.TextColor3 = Color3.fromRGB(100, 200, 255)
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

-- [[ ADVANCED EVENT LOCATIONS - DARI WIND UI ]] --
local EventLocations = {
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
    ["Lochness Hunt"] = {
        Vector3.new(0, 5, 0), -- Dynamic location
    },
    ["Ghost Worm"] = {
        Vector3.new(-500, 5, -500),
    },
    ["Black Hole"] = {
        Vector3.new(1000, 5, 1000),
    },
    ["Shocked"] = {
        Vector3.new(-1000, 5, -1000),
    },
    ["Meteor Rain"] = {
        Vector3.new(2000, 5, 2000),
    },
    ["Treasure Event"] = {
        Vector3.new(-2000, 5, -2000),
    }
}

-- [[ ADVANCED TELEPORT SYSTEM ]] --
local function applyOffset(v)
    return Vector3.new(v.X, v.Y + Config.HeightOffset, v.Z)
end

local function isAlivePart(p)
    if typeof(p) ~= "Instance" then return false end
    if not p:IsA("BasePart") then return false end

    local success = pcall(function()
        return p.Parent ~= nil and p:IsDescendantOf(Workspace)
    end)

    return success
end

local function advancedEventScan(eventName)
    local now = tick()
    if now - lastScanTime < scanCooldown then
        return cachedEventPosition
    end

    local list = EventLocations[eventName]
    if not list or #list == 0 then return nil end

    lastScanTime = now

    for _, coord in ipairs(list) do
        local region = Region3.new(
            coord - Vector3.new(30, 30, 30),
            coord + Vector3.new(30, 30, 30)
        ):ExpandToGrid(4)

        local ok, parts = pcall(function()
            return Workspace:FindPartsInRegion3(region, nil, 50)
        end)

        if ok and parts and #parts > 0 then
            for _, p in ipairs(parts) do
                if isAlivePart(p) then
                    local ps = p.Position
                    if (ps - coord).Magnitude <= Config.SearchRadius then
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

local function universalTeleport(targetPosition, locationName)
    if not targetPosition or typeof(targetPosition) ~= "Vector3" then 
        return false, "Invalid position"
    end
    
    local currentTime = tick()
    local delayTime = tonumber(Config.TeleportDelay) or 1
    
    if currentTime - lastTeleportTime < delayTime then
        local remaining = math.ceil(delayTime - (currentTime - lastTeleportTime))
        return false, "Cooldown: " .. tostring(remaining) .. "s"
    end
    
    local success, err = pcall(function()
        local hrp = GetHRP()
        if not hrp then error("No HumanoidRootPart found") end
        
        if Config.AddRandomDelay then
            safeWait(math.random(50, 150) / 100)
        end
        
        local currentPos = hrp.Position
        local distance = (targetPosition - currentPos).Magnitude
        local maxDistance = tonumber(Config.MaxTeleportDistance) or 9999
        
        if isFreeTier and distance > maxDistance then
            local midpoint = currentPos:Lerp(targetPosition, 0.5)
            hrp.CFrame = CFrame.new(midpoint)
            safeWait(1.5)
        end
        
        -- Advanced teleport with look direction
        local character = LocalPlayer.Character
        if character and character.PrimaryPart then
            character:PivotTo(CFrame.new(targetPosition))
        else
            hrp.CFrame = CFrame.new(targetPosition)
        end
        
        lastTeleportTime = currentTime
        lastTeleportPosition = targetPosition
    end)
    
    if success then
        return true, locationName or "Unknown Location"
    else
        return false, tostring(err)
    end
end

-- [[ FLUENT UI CREATION ]] --
local Window = Fluent:CreateWindow({
    Title = "🎣 Fish It Hub Advanced",
    SubTitle = "Premium Features Edition v3.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Main = Window:AddTab({ Title = "🎣 Main", Icon = "fish" }),
    Events = Window:AddTab({ Title = "⚡ Events", Icon = "zap" }),
    Auto = Window:AddTab({ Title = "🤖 Auto", Icon = "bot" }),
    Lochness = Window:AddTab({ Title = "🐉 Lochness", Icon = "crown" }),
    Status = Window:AddTab({ Title = "📊 Status", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

-- [[ MAIN TAB ]] --
local EventDropdown = Tabs.Main:AddDropdown("EventSelect", {
    Title = "Select Event",
    Description = "Choose which event to teleport to",
    Values = {"Shark Hunt", "Worm Hunt", "Megalodon Hunt", "Ghost Shark Hunt", "Ghost Worm", "Black Hole", "Shocked", "Meteor Rain", "Treasure Event"},
    Multi = false,
    Default = 1,
})

EventDropdown:OnChanged(function(Value)
    selectedEvent = Value
    if Config.EnableDebugMode then
        print("[Debug] Selected event:", Value)
    end
end)

Tabs.Main:AddButton({
    Title = "🎯 Advanced Event Scan & Teleport",
    Description = "Advanced scanning with real-time event detection",
    Callback = function()
        if not selectedEvent then
            Fluent:Notify({
                Title = "❌ No Event Selected",
                Content = "Please select an event first",
                Duration = 3
            })
            return
        end
        
        Fluent:Notify({
            Title = "🔍 Advanced Scanning...",
            Content = "Scanning for " .. selectedEvent,
            Duration = 2
        })
        
        task.spawn(function()
            local activeEvent = advancedEventScan(selectedEvent)
            if activeEvent then
                local success, result = universalTeleport(activeEvent, selectedEvent)
                if success then
                    Fluent:Notify({
                        Title = "✅ Advanced Teleport Success!",
                        Content = "Found active " .. selectedEvent,
                        Duration = 4
                    })
                else
                    Fluent:Notify({
                        Title = "❌ Teleport Failed",
                        Content = result,
                        Duration = 4
                    })
                end
            else
                -- Fallback to preset locations
                if EventLocations[selectedEvent] and #EventLocations[selectedEvent] > 0 then
                    local fallbackLocation = EventLocations[selectedEvent][1]
                    local success, result = universalTeleport(fallbackLocation, selectedEvent)
                    if success then
                        Fluent:Notify({
                            Title = "📍 Teleported to Preset",
                            Content = selectedEvent .. " (Event may not be active)",
                            Duration = 4
                        })
                    end
                end
            end
        end)
    end
})

Tabs.Main:AddButton({
    Title = "🏠 Smart Return to Spawn",
    Description = "Intelligently return to spawn with status check",
    Callback = function()
        local status = getStatus()
        local spawnPos = Vector3.new(0, 50, 0)
        
        -- Adjust spawn position based on current status
        if status:find("WATER") then
            spawnPos = Vector3.new(0, 10, 0) -- Lower for water spawn
        end
        
        local success, result = universalTeleport(spawnPos, "Smart Spawn")
        if success then
            Fluent:Notify({
                Title = "🏠 Smart Spawn Return",
                Content = "Returned safely (" .. status .. ")",
                Duration = 3
            })
        end
    end
})

-- [[ EVENTS TAB ]] --
local eventButtons = {
    {"🦈 Shark Hunt", "Shark Hunt"},
    {"🪱 Worm Hunt", "Worm Hunt"},
    {"🦣 Megalodon Hunt", "Megalodon Hunt"},
    {"👻 Ghost Shark Hunt", "Ghost Shark Hunt"},
    {"🌪️ Ghost Worm", "Ghost Worm"},
    {"🕳️ Black Hole", "Black Hole"},
    {"⚡ Shocked", "Shocked"},
    {"☄️ Meteor Rain", "Meteor Rain"},
    {"💰 Treasure Event", "Treasure Event"}
}

for _, eventData in ipairs(eventButtons) do
    Tabs.Events:AddButton({
        Title = eventData[1],
        Description = "Quick teleport to " .. eventData[2],
        Callback = function()
            selectedEvent = eventData[2]
            if EventLocations[eventData[2]] then
                local location = EventLocations[eventData[2]][1]
                local success, result = universalTeleport(location, eventData[2])
                if success then
                    Fluent:Notify({
                        Title = eventData[1],
                        Content = "Teleported successfully",
                        Duration = 3
                    })
                end
            end
        end
    })
end

-- [[ AUTO TAB ]] --
local AutoEventToggle = Tabs.Auto:AddToggle("AutoEvent", {
    Title = "🤖 Advanced Auto Event",
    Description = "Smart auto-teleport with event detection",
    Default = false
})

AutoEventToggle:OnChanged(function(Value)
    autoEventRunning = Value
    
    if Value then
        Fluent:Notify({
            Title = "🤖 Advanced Auto Started", 
            Content = "Watching for: " .. selectedEvent,
            Duration = 3
        })
        
        autoEventThread = task.spawn(function()
            while autoEventRunning do
                if selectedEvent then
                    local activeEvent = advancedEventScan(selectedEvent)
                    if activeEvent then
                        local success, result = universalTeleport(activeEvent, selectedEvent)
                        if success then
                            Fluent:Notify({
                                Title = "⚡ Auto Event Success",
                                Content = "Found & teleported to " .. selectedEvent,
                                Duration = 5
                            })
                        end
                        safeWait(tonumber(Config.ScanInterval) * 2 or 40)
                    end
                end
                safeWait(tonumber(Config.ScanInterval) or 20)
            end
        end)
    else
        if autoEventThread then
            task.cancel(autoEventThread)
            autoEventThread = nil
        end
        Fluent:Notify({
            Title = "🛑 Advanced Auto Stopped",
            Duration = 2
        })
    end
end)

Tabs.Auto:AddSlider("ScanInterval", {
    Title = "Smart Scan Interval",
    Description = "How often to perform advanced scans (seconds)",
    Default = Config.ScanInterval,
    Min = 5,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        Config.ScanInterval = tonumber(Value) or 20
    end
})

Tabs.Auto:AddSlider("SearchRadius", {
    Title = "Event Detection Radius",
    Description = "Radius for event detection (studs)",
    Default = Config.SearchRadius,
    Min = 10,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        Config.SearchRadius = tonumber(Value) or 25
    end
})

-- [[ LOCHNESS TAB ]] --
local LochCountdownToggle = Tabs.Lochness:AddToggle("LochCountdown", {
    Title = "🐉 Lochness Monster Timer",
    Description = "Show advanced countdown overlay for Lochness Monster",
    Default = false
})

LochCountdownToggle:OnChanged(function(Value)
    if Value then
        showLochCountdown()
        Fluent:Notify({
            Title = "🐉 Lochness Timer Active",
            Content = "Countdown overlay enabled",
            Duration = 3
        })
    else
        hideLochCountdown()
        Fluent:Notify({
            Title = "🐉 Lochness Timer Disabled",
            Content = "Countdown overlay hidden",
            Duration = 2
        })
    end
end)

Tabs.Lochness:AddButton({
    Title = "📊 Check Lochness Schedule",
    Description = "Get detailed information about next Lochness event",
    Callback = function()
        local startTime, endTime, isActive = getLochNextTimes()
        local now = os.time()
        
        if isActive then
            local remaining = endTime - now
            Fluent:Notify({
                Title = "🔥 Lochness Monster ACTIVE!",
                Content = "Event ends in " .. formatTimeSeconds(remaining),
                Duration = 8
            })
        else
            local nextIn = startTime - now
            Fluent:Notify({
                Title = "🐉 Next Lochness Monster",
                Content = "Starts in " .. formatTimeSeconds(nextIn),
                Duration = 6
            })
        end
    end
})

-- [[ STATUS TAB ]] --
local statusInfo = {
    status = "Loading...",
    position = "Unknown",
    selectedEvent = "None",
    autoRunning = "🔴 Stopped",
    lochStatus = "Unknown"
}

local StatusDisplay = Tabs.Status:AddParagraph({
    Title = "Advanced Player Status",
    Content = "Loading advanced status information..."
})

local SystemDisplay = Tabs.Status:AddParagraph({
    Title = "System Information",
    Content = "Executor: " .. currentExecutor .. "\nTier: " .. (isFreeTier and "Free" or "Premium") .. "\nAdvanced Features: " .. (Config.UseAdvancedFeatures and "✅ Enabled" or "❌ Disabled")
})

local EventDisplay = Tabs.Status:AddParagraph({
    Title = "Event Information",
    Content = "Loading event data..."
})

-- Advanced status update
local function updateAdvancedStatus()
    pcall(function()
        statusInfo.status = getStatus()
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            statusInfo.position = string.format("X: %d, Y: %d, Z: %d", 
                math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
        else
            statusInfo.position = "Unknown"
        end
        
        statusInfo.selectedEvent = selectedEvent or "None"
        statusInfo.autoRunning = autoEventRunning and "🟢 Running" or "🔴 Stopped"
        
        -- Lochness status
        local _, _, lochActive = getLochNextTimes()
        statusInfo.lochStatus = lochActive and "🔥 ACTIVE" or "⏰ Waiting"
        
        StatusDisplay.Content = string.format(
            "Status: %s\nPosition: %s\nSelected Event: %s\nAuto Event: %s",
            statusInfo.status,
            statusInfo.position,
            statusInfo.selectedEvent,
            statusInfo.autoRunning
        )
        
        EventDisplay.Content = string.format(
            "Event Cache: %s\nLast Teleport: %s\nLochness: %s\nEvent Active: %s",
            cachedEventPosition and "✅ Valid" or "❌ None",
            lastTeleportPosition and "Set" or "None",
            statusInfo.lochStatus,
            eventIsActive and "✅ Yes" or "❌ No"
        )
    end)
end

statusUpdateThread = task.spawn(function()
    while task.wait(2) do
        updateAdvancedStatus()
    end
end)

-- [[ SETTINGS TAB ]] --
Tabs.Settings:AddSlider("TeleportDelay", {
    Title = "Teleport Cooldown", 
    Description = "Delay between teleports (seconds)",
    Default = Config.TeleportDelay,
    Min = 1,
    Max = 10,
    Rounding = 0.5,
    Callback = function(Value)
        Config.TeleportDelay = tonumber(Value) or 1
    end
})

Tabs.Settings:AddSlider("HeightOffset", {
    Title = "Teleport Height Offset",
    Description = "Height above detected events (studs)",
    Default = Config.HeightOffset,
    Min = 5,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        Config.HeightOffset = tonumber(Value) or 15
    end
})

local DebugToggle = Tabs.Settings:AddToggle("DebugMode", {
    Title = "🐛 Advanced Debug Mode",
    Description = "Show detailed debug information",
    Default = false
})

DebugToggle:OnChanged(function(Value)
    Config.EnableDebugMode = Value
    if Value then
        print("🐛 [Advanced Debug] Debug mode enabled")
        print("🐛 [Advanced Debug] Executor:", currentExecutor)
        print("🐛 [Advanced Debug] Free Tier:", isFreeTier)
        print("🐛 [Advanced Debug] Config:", Config)
        print("🐛 [Advanced Debug] Event Cache:", cachedEventPosition)
    end
end)

Tabs.Settings:AddButton({
    Title = "🔄 Reset All Advanced Settings",
    Description = "Reset all settings to optimized defaults",
    Callback = function()
        Config.TeleportDelay = isFreeTier and 3 or 1
        Config.ScanInterval = isFreeTier and 20 or 8
        Config.SearchRadius = 25
        Config.HeightOffset = 15
        Config.EnableDebugMode = false
        
        cachedEventPosition = nil
        eventIsActive = false
        
        Fluent:Notify({
            Title = "🔄 Advanced Reset Complete",
            Content = "All settings & cache cleared",
            Duration = 3
        })
    end
})

-- [[ ADVANCED INITIALIZATION ]] --
local function advancedInitialization()
    -- Setup Anti-AFK
    local antiAFKSuccess = setupAntiAFK()
    
    -- Setup workspace listeners for better event detection
    pcall(function()
        Workspace.ChildAdded:Connect(function(child)
            if autoEventRunning and selectedEvent then
                task.wait(1) -- Wait for object to fully load
                if EventLocations[selectedEvent] then
                    for _, coord in ipairs(EventLocations[selectedEvent]) do
                        if child:IsA("BasePart") and (child.Position - coord).Magnitude <= Config.SearchRadius then
                            cachedEventPosition = applyOffset(child.Position)
                            eventIsActive = true
                            if Config.EnableDebugMode then
                                print("🐛 [Event Detected]", selectedEvent, "at", child.Position)
                            end
                        end
                    end
                end
            end
        end)
    end)
    
    -- Welcome notification
    Fluent:Notify({
        Title = "🎣 Fish It Hub Advanced Loaded!",
        Content = "Executor: " .. currentExecutor .. "\nAdvanced Features: " .. (Config.UseAdvancedFeatures and "✅" or "❌") .. "\nAnti-AFK: " .. (antiAFKSuccess and "✅" or "❌") .. "\n🚀 Ready for advanced fishing!",
        Duration = 8
    })
    
    if Config.EnableDebugMode then
        print("=== 🎣 FISH IT HUB ADVANCED DEBUG ===")
        print("Executor:", currentExecutor)
        print("Free Tier:", isFreeTier)
        print("Anti-AFK:", antiAFKSuccess)
        print("Advanced Config:", Config)
        print("Event Locations Count:", #EventLocations)
        print("=== ADVANCED INIT COMPLETE ===")
    end
end

-- Start advanced initialization
advancedInitialization()

-- [[ CLEANUP ]] --
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if statusUpdateThread then task.cancel(statusUpdateThread) end
        if autoEventThread then task.cancel(autoEventThread) end
        if lochCountdownThread then task.cancel(lochCountdownThread) end
        if lochCountdownGui then lochCountdownGui:Destroy() end
    end
end)

print("🎣 Fish It Hub Advanced v3.0 - Loaded Successfully!")
print("🚀 Advanced Features:", Config.UseAdvancedFeatures and "Enabled" or "Limited")
print("🎯 Event Detection: Enhanced")
print("🐉 Lochness Timer: Available")
print("📱 Press Left Alt to minimize/restore GUI")
