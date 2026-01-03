-- [[ FISH IT HUB - FLUENT UI EDITION - FIXED ]] --
-- Universal compatibility untuk semua executor
-- Optimized untuk Delta, Xeno, Krnl, JJSploit, Fluxus

-- [[ EXECUTOR DETECTION & CONFIGURATION ]] --
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

-- Universal configuration
local Config = {
    TeleportDelay = isFreeTier and 3 or 1,
    ScanInterval = isFreeTier and 20 or 8,
    MaxTeleportDistance = isFreeTier and 800 or 9999,
    UseAdvancedFeatures = not isFreeTier,
    AddRandomDelay = isFreeTier,
    EnableDebugMode = false
}

-- [[ FLUENT UI LOADER ]] --
local function loadFluentUI()
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    
    if not success then
        -- Fallback URL
        success, Fluent = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Source.lua"))()
        end)
    end
    
    if not success then
        error("Failed to load Fluent UI! Please check your internet connection.")
    end
    
    return Fluent
end

local Fluent = loadFluentUI()

-- Load save manager
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ SERVICES & VARIABLES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- Script variables
local autoEventRunning = false
local selectedEvent = "Shark Hunt"
local lastTeleportTime = 0
local currentStatus = "Initializing..."
local statusUpdateThread = nil
local autoEventThread = nil

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
    local character = GetCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local character = GetCharacter()
    return character and character:WaitForChild("HumanoidRootPart", 5)
end

-- [[ ANTI-AFK SYSTEM ]] --
local function setupAntiAFK()
    local success = false
    
    -- Advanced method for premium executors
    if Config.UseAdvancedFeatures then
        pcall(function()
            for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                if connection.Disable then
                    connection:Disable()
                    success = true
                end
            end
        end)
    end
    
    -- Universal fallback method
    if not success then
        pcall(function()
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                safeWait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
            success = true
        end)
    end
    
    return success
end

-- [[ STATUS DETECTION SYSTEM ]] --
local function detectPlayerStatus()
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character then return "No Character" end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not hrp then return "Loading..." end

        -- Check swimming state
        if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
            return "🌊 Swimming"
        end

        -- Check floor material
        local floorMaterial = humanoid.FloorMaterial
        if floorMaterial == Enum.Material.Water then
            return "🌊 In Water"
        elseif floorMaterial ~= Enum.Material.Air then
            return "🏝️ On Land"
        end

        -- Raycast check (for premium executors)
        if Config.UseAdvancedFeatures then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.IgnoreWater = false
            
            local raycastResult = Workspace:Raycast(
                hrp.Position, 
                Vector3.new(0, -15, 0), 
                raycastParams
            )
            
            if raycastResult then
                if raycastResult.Material == Enum.Material.Water then
                    return "🌊 Above Water"
                else
                    return "🏝️ Above Land"
                end
            end
        end

        return "✈️ Airborne"
    end)
    
    return success and result or "❌ Error"
end

-- [[ EVENT TELEPORT SYSTEM ]] --
local EventLocations = {
    ["Shark Hunt"] = {
        {pos = Vector3.new(1.65, 5, 2095.72), name = "Shark Spot 1"},
        {pos = Vector3.new(1369.94, 5, 930.12), name = "Shark Spot 2"},
        {pos = Vector3.new(-1585.5, 5, 1242.87), name = "Shark Spot 3"},
        {pos = Vector3.new(-1896.8, 5, 2634.37), name = "Shark Spot 4"}
    },
    ["Worm Hunt"] = {
        {pos = Vector3.new(2190.85, 5, 97.57), name = "Worm Spot 1"},
        {pos = Vector3.new(-2450.6, 5, 139.73), name = "Worm Spot 2"},
        {pos = Vector3.new(-267.47, 5, 5188.53), name = "Worm Spot 3"}
    },
    ["Megalodon Hunt"] = {
        {pos = Vector3.new(-1076.3, 5, 1676.19), name = "Megalodon Spot 1"},
        {pos = Vector3.new(-1191.8, 5, 3597.30), name = "Megalodon Spot 2"},
        {pos = Vector3.new(412.70, 5, 4134.39), name = "Megalodon Spot 3"}
    },
    ["Ghost Shark Hunt"] = {
        {pos = Vector3.new(489.56, 5, 25.41), name = "Ghost Spot 1"},
        {pos = Vector3.new(-1358.2, 5, 4100.55), name = "Ghost Spot 2"},
        {pos = Vector3.new(627.86, 5, 3798.08), name = "Ghost Spot 3"}
    },
    ["Treasure Hunt"] = {
        {pos = Vector3.new(0, 5, 0), name = "Treasure Island"}
    },
    ["Black Hole"] = {
        {pos = Vector3.new(-500, 5, -500), name = "Black Hole Zone"}
    },
    ["Meteor Rain"] = {
        {pos = Vector3.new(1000, 5, 1000), name = "Meteor Zone"}
    }
}

local function universalTeleport(targetPosition, locationName)
    if not targetPosition or typeof(targetPosition) ~= "Vector3" then 
        return false, "Invalid position"
    end
    
    -- Rate limiting
    local currentTime = tick()
    if currentTime - lastTeleportTime < Config.TeleportDelay then
        local remaining = math.ceil(Config.TeleportDelay - (currentTime - lastTeleportTime))
        return false, "Cooldown: " .. remaining .. "s"
    end
    
    local success, error = pcall(function()
        local hrp = GetHRP()
        if not hrp then error("No HumanoidRootPart found") end
        
        -- Add random delay for free executors
        if Config.AddRandomDelay then
            safeWait(math.random(50, 150) / 100)
        end
        
        local currentPos = hrp.Position
        local distance = (targetPosition - currentPos).Magnitude
        
        -- Split long teleports for free executors
        if isFreeTier and distance > Config.MaxTeleportDistance then
            local midpoint = currentPos:Lerp(targetPosition, 0.5)
            hrp.CFrame = CFrame.new(midpoint)
            safeWait(1.5)
        end
        
        -- Final teleport
        hrp.CFrame = CFrame.new(targetPosition)
        lastTeleportTime = currentTime
    end)
    
    if success then
        return true, locationName or "Unknown Location"
    else
        return false, tostring(error)
    end
end

local function scanForActiveEvent(eventName)
    if not EventLocations[eventName] then return nil end
    
    for _, location in ipairs(EventLocations[eventName]) do
        local searchPos = location.pos
        local success, foundParts = pcall(function()
            local region = Region3.new(
                searchPos - Vector3.new(30, 20, 30),
                searchPos + Vector3.new(30, 20, 30)
            ):ExpandToGrid(4)
            
            return Workspace:FindPartsInRegion3(region, nil, isFreeTier and 25 or 50)
        end)
        
        if success and foundParts then
            for _, part in ipairs(foundParts) do
                local partSuccess = pcall(function()
                    return part and part.Parent and (part.Position - searchPos).Magnitude <= 25
                end)
                
                if partSuccess then
                    return {
                        pos = Vector3.new(searchPos.X, searchPos.Y + 3, searchPos.Z),
                        name = location.name
                    }
                end
            end
        end
        
        safeWait(isFreeTier and 1 or 0.3)
    end
    
    return nil
end

-- [[ LOCHNESS MONSTER TIMER SYSTEM ]] --
local LOCHNESS_INTERVAL = 4 * 3600  -- 4 hours in seconds
local LOCHNESS_DURATION = 10 * 60   -- 10 minutes in seconds

local function getLochnessSchedule()
    local currentTime = os.time()
    local cycleStart = math.floor(currentTime / LOCHNESS_INTERVAL) * LOCHNESS_INTERVAL
    
    if currentTime >= cycleStart + LOCHNESS_DURATION then
        cycleStart = cycleStart + LOCHNESS_INTERVAL
    end
    
    local eventStart = cycleStart
    local eventEnd = eventStart + LOCHNESS_DURATION
    local isActive = currentTime >= eventStart and currentTime < eventEnd
    
    return eventStart, eventEnd, isActive
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

-- [[ FLUENT UI CREATION ]] --
local Window = Fluent:CreateWindow({
    Title = "🎣 Fish It Hub",
    SubTitle = "Universal Edition v2.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Main = Window:AddTab({ Title = "🎣 Main", Icon = "fish" }),
    Events = Window:AddTab({ Title = "⚡ Events", Icon = "zap" }),
    Auto = Window:AddTab({ Title = "🤖 Auto", Icon = "bot" }),
    Status = Window:AddTab({ Title = "📊 Status", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

-- [[ MAIN TAB ]] --
local EventDropdown = Tabs.Main:AddDropdown("EventSelect", {
    Title = "Select Event",
    Description = "Choose which event to teleport to",
    Values = {"Shark Hunt", "Worm Hunt", "Megalodon Hunt", "Ghost Shark Hunt", "Treasure Hunt", "Black Hole", "Meteor Rain"},
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
    Title = "🎯 Teleport to Event",
    Description = "Instantly teleport to the selected event location",
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
            Title = "🔍 Searching...",
            Content = "Looking for " .. selectedEvent,
            Duration = 2
        })
        
        task.spawn(function()
            local activeEvent = scanForActiveEvent(selectedEvent)
            if activeEvent then
                local success, result = universalTeleport(activeEvent.pos, activeEvent.name)
                if success then
                    Fluent:Notify({
                        Title = "✅ Teleported!",
                        Content = "Moved to " .. result,
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
                -- Use preset location as fallback
                if EventLocations[selectedEvent] and #EventLocations[selectedEvent] > 0 then
                    local fallbackLocation = EventLocations[selectedEvent][1]
                    local success, result = universalTeleport(fallbackLocation.pos, fallbackLocation.name)
                    if success then
                        Fluent:Notify({
                            Title = "📍 Teleported to Preset Location",
                            Content = selectedEvent .. " (Event may not be active)",
                            Duration = 4
                        })
                    end
                else
                    Fluent:Notify({
                        Title = "❌ Event Not Found",
                        Content = selectedEvent .. " is not currently active",
                        Duration = 4
                    })
                end
            end
        end)
    end
})

Tabs.Main:AddButton({
    Title = "🏠 Teleport to Spawn",
    Description = "Return to the spawn location",
    Callback = function()
        local success, result = universalTeleport(Vector3.new(0, 50, 0), "Spawn")
        if success then
            Fluent:Notify({
                Title = "🏠 Returned to Spawn",
                Content = "Teleported safely",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "❌ Teleport Failed",
                Content = result,
                Duration = 3
            })
        end
    end
})

-- [[ EVENTS TAB ]] --
local LochToggle = Tabs.Events:AddToggle("LochCountdown", {
    Title = "🐉 Lochness Monster Timer",
    Description = "Show countdown to next Lochness Monster event",
    Default = false
})

LochToggle:OnChanged(function(Value)
    if Value then
        -- Show Lochness countdown
        task.spawn(function()
            while LochToggle.Value do
                local startTime, endTime, isActive = getLochnessSchedule()
                local currentTime = os.time()
                local timeRemaining = isActive and (endTime - currentTime) or (startTime - currentTime)
                
                local status = isActive and "🔥 ACTIVE" or "⏰ Upcoming"
                local timeStr = formatTime(math.max(0, timeRemaining))
                
                -- Only notify every few minutes to avoid spam
                if math.floor(timeRemaining) % 300 == 0 or timeRemaining <= 60 then
                    Fluent:Notify({
                        Title = "🐉 Lochness Monster",
                        Content = status .. " - " .. timeStr,
                        Duration = 3
                    })
                end
                
                task.wait(60) -- Update every minute
            end
        end)
    end
end)

-- Event quick teleport buttons
Tabs.Events:AddButton({
    Title = "🦈 Quick Teleport - Shark Hunt",
    Description = "Instantly teleport to Shark Hunt location",
    Callback = function()
        selectedEvent = "Shark Hunt"
        local location = EventLocations["Shark Hunt"][1]
        local success, result = universalTeleport(location.pos, location.name)
        if success then
            Fluent:Notify({
                Title = "🦈 Shark Hunt",
                Content = "Teleported to " .. result,
                Duration = 3
            })
        end
    end
})

Tabs.Events:AddButton({
    Title = "🪱 Quick Teleport - Worm Hunt", 
    Description = "Instantly teleport to Worm Hunt location",
    Callback = function()
        selectedEvent = "Worm Hunt"
        local location = EventLocations["Worm Hunt"][1]
        local success, result = universalTeleport(location.pos, location.name)
        if success then
            Fluent:Notify({
                Title = "🪱 Worm Hunt",
                Content = "Teleported to " .. result,
                Duration = 3
            })
        end
    end
})

Tabs.Events:AddButton({
    Title = "🦣 Quick Teleport - Megalodon Hunt",
    Description = "Instantly teleport to Megalodon Hunt location", 
    Callback = function()
        selectedEvent = "Megalodon Hunt"
        local location = EventLocations["Megalodon Hunt"][1]
        local success, result = universalTeleport(location.pos, location.name)
        if success then
            Fluent:Notify({
                Title = "🦣 Megalodon Hunt", 
                Content = "Teleported to " .. result,
                Duration = 3
            })
        end
    end
})

-- [[ AUTO TAB ]] --
local AutoEventToggle = Tabs.Auto:AddToggle("AutoEvent", {
    Title = "Auto Event Teleport",
    Description = "Automatically teleport when events become active",
    Default = false
})

AutoEventToggle:OnChanged(function(Value)
    autoEventRunning = Value
    
    if Value then
        Fluent:Notify({
            Title = "🤖 Auto Event Started", 
            Content = "Watching for: " .. selectedEvent,
            Duration = 3
        })
        
        autoEventThread = task.spawn(function()
            while autoEventRunning do
                if selectedEvent then
                    local activeEvent = scanForActiveEvent(selectedEvent)
                    if activeEvent then
                        local success, result = universalTeleport(activeEvent.pos, activeEvent.name)
                        if success then
                            Fluent:Notify({
                                Title = "⚡ Auto Teleport",
                                Content = "Found active " .. selectedEvent,
                                Duration = 5
                            })
                        end
                        
                        -- Wait longer after successful teleport
                        safeWait(Config.ScanInterval * 2)
                    end
                end
                
                safeWait(Config.ScanInterval)
            end
        end)
    else
        if autoEventThread then
            task.cancel(autoEventThread)
            autoEventThread = nil
        end
        
        Fluent:Notify({
            Title = "🛑 Auto Event Stopped",
            Content = "Automation disabled",
            Duration = 2
        })
    end
end)

local ScanIntervalSlider = Tabs.Auto:AddSlider("ScanInterval", {
    Title = "Scan Interval",
    Description = "How often to check for events (seconds)",
    Default = Config.ScanInterval,
    Min = 5,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        Config.ScanInterval = Value
    end
})

-- [[ STATUS TAB ]] --
local StatusParagraph = Tabs.Status:AddParagraph({
    Title = "Current Status",
    Content = "Loading status information..."
})

local ExecutorInfo = Tabs.Status:AddParagraph({
    Title = "Executor Information", 
    Content = "Executor: " .. currentExecutor .. "\n" ..
             "Tier: " .. (isFreeTier and "Free" or "Premium") .. "\n" ..
             "Advanced Features: " .. (Config.UseAdvancedFeatures and "Enabled" or "Disabled")
})

-- Status update loop
statusUpdateThread = task.spawn(function()
    while task.wait(isFreeTier and 3 or 1.5) do
        currentStatus = detectPlayerStatus()
        local character = LocalPlayer.Character
        local position = "Unknown"
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            position = string.format("X: %d, Y: %d, Z: %d", 
                math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
        end
        
        StatusParagraph:SetContent(
            "Status: " .. currentStatus .. "\n" ..
            "Position: " .. position .. "\n" ..
            "Selected Event: " .. (selectedEvent or "None") .. "\n" ..
            "Auto Event: " .. (autoEventRunning and "🟢 Running" or "🔴 Stopped")
        )
    end
end)

-- [[ SETTINGS TAB ]] --
local TeleportDelaySlider = Tabs.Settings:AddSlider("TeleportDelay", {
    Title = "Teleport Delay", 
    Description = "Delay between teleports (seconds)",
    Default = Config.TeleportDelay,
    Min = 1,
    Max = 10,
    Rounding = 0.5,
    Callback = function(Value)
        Config.TeleportDelay = Value
    end
})

local DebugToggle = Tabs.Settings:AddToggle("DebugMode", {
    Title = "Debug Mode",
    Description = "Show detailed information in console",
    Default = false
})

DebugToggle:OnChanged(function(Value)
    Config.EnableDebugMode = Value
    if Value then
        print("[🐛 Debug] Debug mode enabled")
        print("[🐛 Debug] Executor:", currentExecutor)
        print("[🐛 Debug] Free Tier:", isFreeTier)
        print("[🐛 Debug] Config:", Config)
    end
end)

Tabs.Settings:AddButton({
    Title = "🔄 Reset All Settings",
    Description = "Reset all settings to default values",
    Callback = function()
        Config.TeleportDelay = isFreeTier and 3 or 1
        Config.ScanInterval = isFreeTier and 20 or 8
        Config.EnableDebugMode = false
        
        TeleportDelaySlider:SetValue(Config.TeleportDelay)
        ScanIntervalSlider:SetValue(Config.ScanInterval) 
        DebugToggle:SetValue(false)
        
        Fluent:Notify({
            Title = "🔄 Settings Reset",
            Content = "All settings restored to defaults",
            Duration = 3
        })
    end
})

-- [[ SAVE MANAGER SETUP ]] --
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("FishItHub")
SaveManager:BuildConfigSection(Tabs.Settings)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FishItHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

-- [[ INITIALIZATION ]] --
local function initialize()
    -- Setup Anti-AFK
    local antiAFKSuccess = setupAntiAFK()
    
    -- Welcome notification
    Fluent:Notify({
        Title = "🎣 Fish It Hub Loaded!",
        Content = "Welcome! Executor: " .. currentExecutor .. "\n" ..
                 "Anti-AFK: " .. (antiAFKSuccess and "✅" or "❌") .. "\n" ..
                 "Ready to use!",
        Duration = 6
    })
    
    -- Debug info
    if Config.EnableDebugMode then
        print("=== 🎣 FISH IT HUB DEBUG INFO ===")
        print("Executor:", currentExecutor)
        print("Free Tier:", isFreeTier) 
        print("Anti-AFK:", antiAFKSuccess)
        print("Config:", Config)
        print("=== INITIALIZATION COMPLETE ===")
    end
end

-- Start initialization
initialize()

-- [[ CLEANUP ON SCRIPT END ]] --
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if statusUpdateThread then
            task.cancel(statusUpdateThread)
        end
        if autoEventThread then
            task.cancel(autoEventThread)
        end
    end
end)

print("🎣 Fish It Hub - Fluent UI Edition loaded successfully!")
print("Executor: " .. currentExecutor .. " | Free Tier: " .. tostring(isFreeTier))
print("Press Left Alt to minimize/restore the GUI")
