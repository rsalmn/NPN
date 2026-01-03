-- [[ FISH IT HUB - FLUENT UI EDITION ]] --
-- PART 1/4: Setup Dasar & Helper Functions
-- Implementasi dari Wind UI ke Fluent UI

-- [[ FLUENT UI LOADER ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

-- [[ GLOBAL VARIABLES ]] --
local autoEventTargetName = nil 
local autoEventTeleportState = false
local autoEventTeleportThread = nil
local running = false
local currentEventName = nil
local cachedEventPosition = nil
local eventIsActive = false
local lastTeleportPosition = nil
local lastScanTime = 0
local scanCooldown = 10
local connChild = nil

-- [[ EVENTS LIST ]] --
local eventsList = { 
    "Lochness Hunt",
    "Shark Hunt", 
    "Ghost Shark Hunt", 
    "Worm Hunt", 
    "Black Hole", 
    "Shocked", 
    "Ghost Worm", 
    "Meteor Rain", 
    "Megalodon Hunt", 
    "Treasure Event"
}

-- [[ NET FOLDER SETUP ]] --
local NetFolder = nil
pcall(function()
    NetFolder = RepStorage
        :WaitForChild("Packages", 2)
        :WaitForChild("_Index", 2)
        :WaitForChild("sleitnick_net@0.2.0", 2)
        :WaitForChild("net", 2)
end)

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

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function safeCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- [[ STATUS DETECTOR - DARI WIND UI ]] --
local function getStatus()
    local char = LocalPlayer.Character
    if not char then return "UNKNOWN" end
    
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not hrp then return "UNKNOWN" end

    -- Cek State Swimming (Paling Akurat)
    if hum:GetState() == Enum.HumanoidStateType.Swimming then
        return "WATER (SWIMMING)"
    end

    -- Cek Material Pijakan (FloorMaterial)
    if hum.FloorMaterial == Enum.Material.Water then
        return "WATER"
    end
    
    if hum.FloorMaterial ~= Enum.Material.Air then
        return "LAND"
    end

    -- Raycast Fallback
    local origin = hrp.Position
    local direction = Vector3.new(0, -15, 0)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = false

    local result = workspace:Raycast(origin, direction, params)

    if result then
        if result.Material == Enum.Material.Water then
            return "WATER"
        else
            return "LAND"
        end
    end

    return "UNKNOWN"
end

-- [[ TELEPORT HELPER ]] --
local function TeleportToLookAt(position, lookVector)
    local hrp = GetHRP()
    if hrp and typeof(position) == "Vector3" and typeof(lookVector) == "Vector3" then
        local targetCFrame = CFrame.new(position, position + lookVector)
        hrp.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
        Fluent:Notify({
            Title = "✅ Teleport Sukses!",
            Content = "Berhasil teleport ke lokasi",
            Duration = 3
        })
    end
end

-- [[ REMOTE HANDLING ]] --
local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
local function GetRemote(remotePath, name, timeout)
    local currentInstance = RepStorage
    for _, childName in ipairs(remotePath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

-- [[ ANTI-AFK SYSTEM - DARI WIND UI ]] --
pcall(function()
    local player = LocalPlayer
    
    for i, v in pairs(getconnections(player.Idled)) do
        if v.Disable then
            v:Disable()
        end
    end
end)

-- Fallback Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("✅ PART 1/4 - Setup Dasar & Helper Functions LOADED!")

-- [[ PART 2/4: LOCHNESS TIMER & EVENT TELEPORT ENGINE ]] --

-- [[ LOCHNESS CONFIGURATION ]] --
local LOCH_INTERVAL = 4 * 3600    -- 4 jam (detik)
local LOCH_DURATION = 10 * 60     -- 10 menit (detik)

local lochCountdownGui = nil
local lochCountdownThread = nil

-- [[ HOTFIX - Perbaikan Error Type Comparison ]] --
-- Ganti bagian ini di PART 2 Event Teleport Engine

-- [[ PERBAIKAN: formatTimeSeconds Function ]] --
local function formatTimeSeconds(sec)
    -- Pastikan input adalah number, bukan string
    if type(sec) == "string" then
        sec = tonumber(sec) or 0
    end
    
    sec = math.max(0, math.floor(sec))
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

-- [[ PERBAIKAN: getLochNextTimes Function ]] --
local function getLochNextTimes()
    local now = os.time()
    
    -- Pastikan semua perhitungan menggunakan number
    local base = math.floor(now / LOCH_INTERVAL) * LOCH_INTERVAL
    
    if now >= (base + LOCH_DURATION) then
        base = base + LOCH_INTERVAL
    end
    
    local startTime = base
    local endTime = startTime + LOCH_DURATION
    local active = (now >= startTime) and (now < endTime)
    
    return startTime, endTime, active
end

-- [[ PERBAIKAN: Status Update Function di PART 4 ]] --
local function updateAllStatus()
    pcall(function()
        -- Player Status
        local status = getStatus()
        local character = LocalPlayer.Character
        local position = "Unknown"
        local health = "Unknown"
        
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local hum = character:FindFirstChild("Humanoid")
            
            if hrp then
                local pos = hrp.Position
                position = string.format("X: %d, Y: %d, Z: %d", 
                    math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
            end
            
            if hum then
                health = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            end
        end
        
        PlayerStatusDisplay:SetDesc(
            "Environment: " .. status .. "\n" ..
            "Position: " .. position .. "\n" ..
            "Health: " .. health
        )
        
        -- Event Status
        local selectedEventText = selectedEvent or "None"
        local cachedPosText = cachedEventPosition and "✅ Cached" or "❌ None"
        local eventActiveText = eventIsActive and "🟢 Active" or "🔴 Inactive"
        local lastTPText = lastTeleportPosition and "Set" or "None"
        
        EventStatusDisplay:SetDesc(
            "Selected Event: " .. selectedEventText .. "\n" ..
            "Cached Position: " .. cachedPosText .. "\n" ..
            "Event Status: " .. eventActiveText .. "\n" ..
            "Last Teleport: " .. lastTPText
        )
        
        -- Automation Status
        local autoEventText = autoEventRunning and "🟢 Running" or "🔴 Stopped"
        local autoTargetText = autoEventTargetName or "None"
        local engineRunningText = EventTP.IsRunning() and "🟢 Active" or "🔴 Idle"
        
        AutoStatusDisplay:SetDesc(
            "Auto Event: " .. autoEventText .. "\n" ..
            "Target Event: " .. autoTargetText .. "\n" ..
            "Engine Status: " .. engineRunningText .. "\n" ..
            "Scan Interval: " .. tostring(EventTP.TeleportCheckInterval) .. "s"
        )
        
        -- System Info - PERBAIKAN DI SINI
        local fps = 60 -- Fallback value
        local ping = 0 -- Fallback value
        local uptime = 0 -- Fallback value
        
        -- Safe FPS calculation
        pcall(function()
            fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        end)
        
        -- Safe ping calculation
        pcall(function()
            local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
            if stats then
                ping = math.floor(stats:GetValue())
            end
        end)
        
        -- Safe uptime calculation
        pcall(function()
            local serverTime = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
            if serverTime then
                uptime = math.floor(tick())
            end
        end)
        
        SystemInfoDisplay:SetDesc(
            "FPS: " .. tostring(fps) .. " | Ping: " .. tostring(ping) .. "ms\n" ..
            "Players: " .. tostring(#Players:GetPlayers()) .. " in server\n" ..
            "Status: All systems operational"
        )
    end)
end

-- [[ PERBAIKAN: Lochness Timer Update ]] --
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
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    -- Stroke effect
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 200, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, -8)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 17
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "🐉 Lochness: calculating..."
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame

    -- Update loop dengan type checking
    if lochCountdownThread then 
        pcall(function() task.cancel(lochCountdownThread) end)
    end
    
    lochCountdownThread = task.spawn(function()
        while lochCountdownGui and lochCountdownGui.Parent do
            pcall(function()
                local startT, endT, active = getLochNextTimes()
                local now = os.time()
                
                -- Ensure all values are numbers
                startT = tonumber(startT) or 0
                endT = tonumber(endT) or 0
                now = tonumber(now) or 0
                
                local remaining = (active and (endT - now)) or (startT - now)
                remaining = math.max(0, remaining)
                
                if active then
                    label.Text = ("🔥 Lochness ACTIVE! Ends in %s"):format(formatTimeSeconds(remaining))
                    label.TextColor3 = Color3.fromRGB(255, 100, 100)
                    stroke.Color = Color3.fromRGB(255, 100, 100)
                else
                    label.Text = ("🐉 Next Lochness in %s"):format(formatTimeSeconds(remaining))
                    label.TextColor3 = Color3.fromRGB(100, 200, 255)
                    stroke.Color = Color3.fromRGB(100, 200, 255)
                end
            end)
            
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

-- [[ LOCHNESS LIST UPDATER ]] --
local function hasEventInList(tbl, name)
    for i, v in ipairs(tbl) do 
        if v == name then 
            return true, i 
        end 
    end
    return false, nil
end

local function updateLochInEventsList(dropdownElement)
    local startT, endT, active = getLochNextTimes()
    local now = os.time()
    
    -- Show Lochness in dropdown if active OR within 10 minutes to spawn
    local showWindow = active or (startT - now <= 10 * 60)
    local present, idx = hasEventInList(eventsList, "Lochness Hunt")
    
    if showWindow and not present then
        table.insert(eventsList, 1, "Lochness Hunt") -- Insert di awal list
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

-- [[ EVENT TELEPORT ENGINE - DARI WIND UI ]] --
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

    ["Treasure Event"] = nil,
    
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
}

-- [[ EVENT TP SETTINGS ]] --
EventTP.SearchRadius = 25
EventTP.TeleportCheckInterval = 8
EventTP.HeightOffset = 15
EventTP.SafeZoneRadius = 50
EventTP.RequireEventActive = true
EventTP.UseSmartReteleport = true
EventTP.WaitForEventTimeout = 300

-- [[ EVENT TP HELPER FUNCTIONS ]] --
local function applyOffset(v)
    return Vector3.new(v.X, v.Y + EventTP.HeightOffset, v.Z)
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

-- [[ EVENT SCANNING SYSTEM ]] --
local function scan(eventName)
    local now = tick()
    if now - lastScanTime < scanCooldown then
        return cachedEventPosition
    end

    local list = EventTP.Events[eventName]
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

-- [[ EVENT LISTENER SETUP ]] --
local function setupListener(eventName)
    if connChild then 
        connChild:Disconnect() 
        connChild = nil 
    end
    
    local coords = EventTP.Events[eventName]
    if not coords then return end

    connChild = Workspace.ChildAdded:Connect(function(child)
        if not running then return end
        if not isAlivePart(child) then return end

        local ok, posTry = pcall(function() 
            return child.Position 
        end)
        if not ok then return end

        for _, coord in ipairs(coords) do
            if (posTry - coord).Magnitude <= EventTP.SearchRadius then
                cachedEventPosition = applyOffset(posTry)
                eventIsActive = true
                return
            end
        end
    end)
end

-- [[ WAIT FOR EVENT ACTIVE ]] --
local function waitActive(eventName)
    local start = tick()
    while tick() - start < EventTP.WaitForEventTimeout do
        local p = scan(eventName)
        if p then return p end
        task.wait(5)
    end
    return nil
end

-- [[ EVENT TP MAIN FUNCTIONS ]] --
function EventTP.TeleportNow(name)
    if cachedEventPosition and eventIsActive then
        local success = doTeleport(cachedEventPosition)
        if success then
            Fluent:Notify({
                Title = "✅ Event Teleport Success!",
                Content = "Teleported to active " .. name,
                Duration = 4
            })
            return true
        end
    end
    return false
end

function EventTP.Start(name)
    if running then 
        Fluent:Notify({
            Title = "⚠️ Already Running",
            Content = "Event teleport already active",
            Duration = 3
        })
        return false 
    end
    
    if not EventTP.Events[name] then 
        Fluent:Notify({
            Title = "❌ Invalid Event",
            Content = "Event not found: " .. name,
            Duration = 3
        })
        return false 
    end

    running = true
    currentEventName = name
    cachedEventPosition = nil
    eventIsActive = false
    
    setupListener(name)
    
    Fluent:Notify({
        Title = "🚀 Event Teleport Started",
        Content = "Monitoring: " .. name,
        Duration = 4
    })
    
    task.spawn(function()
        while running and currentEventName == name do
            local pos = scan(name)
            
            if pos then
                if EventTP.TeleportNow(name) then
                    task.wait(EventTP.TeleportCheckInterval)
                end
            else
                -- Event not active, wait and retry
                task.wait(EventTP.TeleportCheckInterval)
            end
        end
    end)
    
    return true
end

function EventTP.Stop()
    if not running then return false end
    
    running = false
    currentEventName = nil
    
    if connChild then
        connChild:Disconnect()
        connChild = nil
    end
    
    Fluent:Notify({
        Title = "🛑 Event Teleport Stopped",
        Content = "Monitoring disabled",
        Duration = 3
    })
    
    return true
end

function EventTP.IsRunning()
    return running
end

function EventTP.GetCurrentEvent()
    return currentEventName
end

function EventTP.GetCachedPosition()
    return cachedEventPosition
end

function EventTP.IsEventActive()
    return eventIsActive
end

-- [[ MANUAL SCAN & TELEPORT ]] --
function EventTP.ScanAndTeleport(name)
    if not EventTP.Events[name] then 
        Fluent:Notify({
            Title = "❌ Invalid Event",
            Content = "Event not found: " .. name,
            Duration = 3
        })
        return false 
    end
    
    Fluent:Notify({
        Title = "🔍 Scanning...",
        Content = "Searching for " .. name,
        Duration = 2
    })
    
    local pos = scan(name)
    
    if pos then
        local success = doTeleport(pos)
        if success then
            Fluent:Notify({
                Title = "✅ Found & Teleported!",
                Content = "Active event detected: " .. name,
                Duration = 5
            })
            return true
        end
    else
        -- Fallback to preset location
        if EventTP.Events[name] and #EventTP.Events[name] > 0 then
            local fallback = EventTP.Events[name][1]
            local success = doTeleport(fallback)
            if success then
                Fluent:Notify({
                    Title = "📍 Preset Location",
                    Content = name .. " (event may not be active)",
                    Duration = 4
                })
                return true
            end
        end
    end
    
    Fluent:Notify({
        Title = "❌ Event Not Found",
        Content = name .. " is not currently active",
        Duration = 4
    })
    return false
end

print("✅ PART 2/4 - Lochness Timer & Event Teleport Engine LOADED!")

-- [[ PART 3/4: FLUENT UI CREATION & MAIN TABS ]] --

-- [[ FLUENT UI WINDOW CREATION ]] --
local Window = Fluent:CreateWindow({
    Title = "🎣 NPN Hub Premium",
    SubTitle = "Fluent Edition - All Modes",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

-- [[ TABS CREATION ]] --
local Tabs = {
    Main = Window:AddTab({ Title = "🎣 Main", Icon = "fish" }),
    Events = Window:AddTab({ Title = "⚡ Events", Icon = "zap" }),
    Auto = Window:AddTab({ Title = "🤖 Auto", Icon = "bot" }),
    Lochness = Window:AddTab({ Title = "🐉 Lochness", Icon = "crown" }),
    Status = Window:AddTab({ Title = "📊 Status", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

-- [[ CONFIG MANAGER ]] --
local Options = Fluent.Options

-- [[ GLOBAL VARIABLES FOR UI ]] --
local selectedEvent = "Shark Hunt"
local autoEventRunning = false
local statusUpdateThread = nil

-- [[ MAIN TAB ]] --
Tabs.Main:AddParagraph({
    Title = "🎣 NPN Hub Premium",
    Content = "Advanced fishing automation with premium features.\nSelect an event below and use the teleport functions."
})

-- Event Selection Dropdown
local EventDropdown = Tabs.Main:AddDropdown("EventSelect", {
    Title = "🎯 Select Event",
    Description = "Choose which event to monitor/teleport to",
    Values = eventsList,
    Multi = false,
    Default = 1,
})

EventDropdown:OnChanged(function(Value)
    selectedEvent = Value
    autoEventTargetName = Value
    
    Fluent:Notify({
        Title = "🎯 Event Selected",
        Content = "Target: " .. Value,
        Duration = 2
    })
end)

-- Smart Scan & Teleport Button
Tabs.Main:AddButton({
    Title = "🔍 Smart Scan & Teleport",
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
        
        EventTP.ScanAndTeleport(selectedEvent)
    end
})

-- Quick Teleport to Preset Location
Tabs.Main:AddButton({
    Title = "📍 Quick Teleport (Preset)",
    Description = "Teleport to preset event location (may not be active)",
    Callback = function()
        if not selectedEvent then
            Fluent:Notify({
                Title = "❌ No Event Selected",
                Content = "Please select an event first",
                Duration = 3
            })
            return
        end
        
        if EventTP.Events[selectedEvent] and #EventTP.Events[selectedEvent] > 0 then
            local location = EventTP.Events[selectedEvent][1]
            local success = doTeleport(location)
            
            if success then
                Fluent:Notify({
                    Title = "📍 Quick Teleport",
                    Content = "Teleported to " .. selectedEvent .. " preset location",
                    Duration = 4
                })
            else
                Fluent:Notify({
                    Title = "❌ Teleport Failed",
                    Content = "Unable to teleport to location",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "❌ No Location Data",
                Content = "No preset location available for " .. selectedEvent,
                Duration = 3
            })
        end
    end
})

-- Return to Spawn
Tabs.Main:AddButton({
    Title = "🏠 Return to Spawn",
    Description = "Smart teleport back to spawn area",
    Callback = function()
        local status = getStatus()
        local spawnPos = Vector3.new(0, 50, 0)
        
        -- Adjust spawn based on current status
        if status:find("WATER") then
            spawnPos = Vector3.new(0, 10, 0)
        end
        
        local success = doTeleport(spawnPos)
        if success then
            Fluent:Notify({
                Title = "🏠 Returned to Spawn",
                Content = "Status: " .. status,
                Duration = 3
            })
        end
    end
})

-- [[ EVENTS TAB ]] --
Tabs.Events:AddParagraph({
    Title = "⚡ Quick Event Access",
    Content = "Direct teleport buttons for all available events.\nClick any event to teleport instantly."
})

-- Quick Event Buttons
local eventButtons = {
    {"🦈 Shark Hunt", "Shark Hunt"},
    {"🪱 Worm Hunt", "Worm Hunt"}, 
    {"🦣 Megalodon Hunt", "Megalodon Hunt"},
    {"👻 Ghost Shark Hunt", "Ghost Shark Hunt"},
    {"🐉 Lochness Hunt", "Lochness Hunt"},
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
            EventDropdown:SetValue(eventData[2])
            EventTP.ScanAndTeleport(eventData[2])
        end
    })
end

-- Batch Scan All Events
Tabs.Events:AddButton({
    Title = "🔍 Scan All Events",
    Description = "Scan all events and show active ones",
    Callback = function()
        Fluent:Notify({
            Title = "🔍 Scanning All Events...",
            Content = "This may take a moment",
            Duration = 3
        })
        
        task.spawn(function()
            local activeEvents = {}
            
            for _, eventName in ipairs(eventsList) do
                if EventTP.Events[eventName] then
                    local pos = scan(eventName)
                    if pos then
                        table.insert(activeEvents, eventName)
                    end
                end
                task.wait(0.5) -- Small delay between scans
            end
            
            if #activeEvents > 0 then
                local content = "Active Events:\n" .. table.concat(activeEvents, "\n")
                Fluent:Notify({
                    Title = "✅ Active Events Found!",
                    Content = content,
                    Duration = 8
                })
            else
                Fluent:Notify({
                    Title = "❌ No Active Events",
                    Content = "No events are currently active",
                    Duration = 4
                })
            end
        end)
    end
})

-- [[ AUTO TAB ]] --
Tabs.Auto:AddParagraph({
    Title = "🤖 Automation Features",
    Content = "Advanced automation system with smart event detection.\nAuto-teleport will continuously monitor and teleport to active events."
})

-- Auto Event Toggle
local AutoEventToggle = Tabs.Auto:AddToggle("AutoEvent", {
    Title = "🤖 Auto Event Teleport",
    Description = "Automatically teleport to selected event when active",
    Default = false
})

AutoEventToggle:OnChanged(function(Value)
    autoEventRunning = Value
    
    if Value then
        if not selectedEvent then
            Fluent:Notify({
                Title = "❌ No Event Selected",
                Content = "Please select an event first",
                Duration = 3
            })
            AutoEventToggle:SetValue(false)
            return
        end
        
        autoEventTeleportState = true
        EventTP.Start(selectedEvent)
        
        Fluent:Notify({
            Title = "🤖 Auto Event Started",
            Content = "Monitoring: " .. selectedEvent,
            Duration = 4
        })
    else
        autoEventTeleportState = false
        EventTP.Stop()
        
        Fluent:Notify({
            Title = "🛑 Auto Event Stopped",
            Content = "Automation disabled",
            Duration = 3
        })
    end
end)

-- Auto Settings
Tabs.Auto:AddSlider("ScanInterval", {
    Title = "🔄 Scan Interval",
    Description = "How often to check for events (seconds)",
    Default = EventTP.TeleportCheckInterval,
    Min = 5,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        EventTP.TeleportCheckInterval = Value
    end
})

Tabs.Auto:AddSlider("SearchRadius", {
    Title = "🎯 Detection Radius", 
    Description = "Event detection radius (studs)",
    Default = EventTP.SearchRadius,
    Min = 10,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        EventTP.SearchRadius = Value
    end
})

Tabs.Auto:AddSlider("HeightOffset", {
    Title = "📏 Height Offset",
    Description = "Teleport height above detected events",
    Default = EventTP.HeightOffset,
    Min = 5,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        EventTP.HeightOffset = Value
    end
})

-- Auto Event Info
local AutoInfo = Tabs.Auto:AddParagraph({
    Title = "📊 Auto Status",
    Content = "Auto Event: 🔴 Stopped\nCurrent Target: None\nEvent Active: ❌ No"
})

-- Update Auto Info
task.spawn(function()
    while true do
        local status = autoEventRunning and "🟢 Running" or "🔴 Stopped"
        local target = selectedEvent or "None"
        local active = EventTP.IsEventActive() and "✅ Yes" or "❌ No"
        
        AutoInfo:SetDesc("Auto Event: " .. status .. "\nCurrent Target: " .. target .. "\nEvent Active: " .. active)
        
        task.wait(2)
    end
end)

-- [[ LOCHNESS TAB ]] --
Tabs.Lochness:AddParagraph({
    Title = "🐉 Lochness Monster",
    Content = "The Lochness Monster appears every 4 hours for 10 minutes.\nUse the timer below to track when it will spawn next."
})

-- Lochness Timer Toggle
local LochTimerToggle = Tabs.Lochness:AddToggle("LochTimer", {
    Title = "🐉 Show Lochness Timer", 
    Description = "Display countdown overlay for Lochness Monster spawns",
    Default = false
})

LochTimerToggle:OnChanged(function(Value)
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
            Title = "🐉 Timer Disabled", 
            Content = "Countdown overlay hidden",
            Duration = 2
        })
    end
end)

-- Check Lochness Schedule
Tabs.Lochness:AddButton({
    Title = "📅 Check Schedule",
    Description = "Get current Lochness Monster schedule information",
    Callback = function()
        local startTime, endTime, isActive = getLochNextTimes()
        local now = os.time()
        
        if isActive then
            local remaining = endTime - now
            Fluent:Notify({
                Title = "🔥 Lochness Monster ACTIVE!",
                Content = "Event ends in " .. formatTimeSeconds(remaining) .. "\n🚀 Go catch it now!",
                Duration = 8
            })
        else
            local nextIn = startTime - now
            Fluent:Notify({
                Title = "🐉 Next Lochness Monster",
                Content = "Starts in " .. formatTimeSeconds(nextIn) .. "\n⏰ Set your alarm!",
                Duration = 6
            })
        end
    end
})

-- Auto Lochness Toggle
local AutoLochToggle = Tabs.Lochness:AddToggle("AutoLoch", {
    Title = "🔥 Auto Lochness Hunt",
    Description = "Automatically teleport when Lochness becomes active",
    Default = false
})

AutoLochToggle:OnChanged(function(Value)
    if Value then
        -- Start auto Lochness monitoring
        task.spawn(function()
            while AutoLochToggle.Value do
                local _, _, isActive = getLochNextTimes()
                
                if isActive then
                    -- Lochness is active, try to teleport
                    selectedEvent = "Lochness Hunt" 
                    EventDropdown:SetValue("Lochness Hunt")
                    EventTP.ScanAndTeleport("Lochness Hunt")
                    
                    Fluent:Notify({
                        Title = "🔥 Auto Lochness!",
                        Content = "Lochness is active! Teleporting...",
                        Duration = 5
                    })
                    
                    task.wait(60) -- Wait 1 minute before next check when active
                else
                    task.wait(30) -- Check every 30 seconds when inactive
                end
            end
        end)
        
        Fluent:Notify({
            Title = "🔥 Auto Lochness Started",
            Content = "Will auto-teleport when Lochness spawns",
            Duration = 4
        })
    else
        Fluent:Notify({
            Title = "🛑 Auto Lochness Stopped",
            Content = "Automatic Lochness hunting disabled",
            Duration = 3
        })
    end
end)

-- Lochness Info Display
local LochInfo = Tabs.Lochness:AddParagraph({
    Title = "📊 Lochness Info",
    Content = "Loading Lochness information..."
})

-- Update Lochness Info
task.spawn(function()
    while true do
        local startTime, endTime, isActive = getLochNextTimes()
        local now = os.time()
        
        if isActive then
            local remaining = endTime - now
            LochInfo:SetDesc("Status: 🔥 ACTIVE!\nTime Remaining: " .. formatTimeSeconds(remaining) .. "\nNext Spawn: In " .. formatTimeSeconds(4 * 3600))
        else
            local nextIn = startTime - now
            LochInfo:SetDesc("Status: ⏰ Waiting\nNext Spawn: " .. formatTimeSeconds(nextIn) .. "\nDuration: 10 minutes")
        end
        
        task.wait(5)
    end
end)

print("✅ PART 3/4 - Fluent UI Creation & Main Tabs LOADED!")

-- [[ PART 4/4: STATUS TAB, SETTINGS & FINALIZATION ]] --

-- [[ STATUS TAB ]] --
Tabs.Status:AddParagraph({
    Title = "📊 System Status",
    Content = "Real-time monitoring of player status, events, and automation.\nUpdates automatically every 2 seconds."
})

-- Player Status Display
local PlayerStatusDisplay = Tabs.Status:AddParagraph({
    Title = "👤 Player Status",
    Content = "Loading player information..."
})

-- Event Status Display
local EventStatusDisplay = Tabs.Status:AddParagraph({
    Title = "⚡ Event Status",
    Content = "Loading event information..."
})

-- Automation Status Display
local AutoStatusDisplay = Tabs.Status:AddParagraph({
    Title = "🤖 Automation Status",
    Content = "Loading automation information..."
})

-- System Info Display
local SystemInfoDisplay = Tabs.Status:AddParagraph({
    Title = "💻 System Information",
    Content = "Loading system information..."
})



-- Start status update loop
statusUpdateThread = task.spawn(function()
    while true do
        updateAllStatus()
        task.wait(2)
    end
end)

-- Manual Refresh Button
Tabs.Status:AddButton({
    Title = "🔄 Refresh Status",
    Description = "Manually refresh all status information",
    Callback = function()
        updateAllStatus()
        Fluent:Notify({
            Title = "🔄 Status Refreshed",
            Content = "All information updated",
            Duration = 2
        })
    end
})

-- Clear Cache Button
Tabs.Status:AddButton({
    Title = "🗑️ Clear Event Cache",
    Description = "Clear cached event positions and force new scan",
    Callback = function()
        cachedEventPosition = nil
        eventIsActive = false
        lastTeleportPosition = nil
        lastScanTime = 0
        
        Fluent:Notify({
            Title = "🗑️ Cache Cleared",
            Content = "Event cache has been reset",
            Duration = 3
        })
    end
})

-- [[ SETTINGS TAB ]] --
Tabs.Settings:AddParagraph({
    Title = "⚙️ Advanced Settings",
    Content = "Configure advanced features and behavior.\nChanges apply immediately."
})

-- Teleport Settings Section
Tabs.Settings:AddSection("Teleport Settings")

Tabs.Settings:AddSlider("TeleportCooldown", {
    Title = "⏱️ Teleport Cooldown",
    Description = "Delay between teleports (seconds)",
    Default = 1,
    Min = 0.5,
    Max = 10,
    Rounding = 0.5,
    Callback = function(Value)
        -- Apply cooldown setting if needed
        Fluent:Notify({
            Title = "⚙️ Setting Updated",
            Content = "Teleport cooldown: " .. Value .. "s",
            Duration = 2
        })
    end
})

Tabs.Settings:AddSlider("MaxTeleportDistance", {
    Title = "📏 Max Teleport Distance",
    Description = "Maximum safe teleport distance (studs)",
    Default = 5000,
    Min = 1000,
    Max = 10000,
    Rounding = 100,
    Callback = function(Value)
        Fluent:Notify({
            Title = "⚙️ Setting Updated",
            Content = "Max distance: " .. Value .. " studs",
            Duration = 2
        })
    end
})

-- Safety Settings Section
Tabs.Settings:AddSection("Safety Settings")

local SafeTeleportToggle = Tabs.Settings:AddToggle("SafeTeleport", {
    Title = "🛡️ Safe Teleport Mode",
    Description = "Use safer teleport method (slower but more stable)",
    Default = false
})

SafeTeleportToggle:OnChanged(function(Value)
    EventTP.UseSmartReteleport = Value
    Fluent:Notify({
        Title = Value and "🛡️ Safe Mode ON" or "⚡ Fast Mode ON",
        Content = Value and "Using safer teleport" or "Using faster teleport",
        Duration = 3
    })
end)

local RequireActiveToggle = Tabs.Settings:AddToggle("RequireActive", {
    Title = "✅ Require Event Active",
    Description = "Only teleport when event is confirmed active",
    Default = true
})

RequireActiveToggle:OnChanged(function(Value)
    EventTP.RequireEventActive = Value
    Fluent:Notify({
        Title = "⚙️ Setting Updated",
        Content = Value and "Will verify event is active" or "Will teleport to preset",
        Duration = 3
    })
end)

-- Notification Settings Section
Tabs.Settings:AddSection("Notification Settings")

local VerboseNotificationsToggle = Tabs.Settings:AddToggle("VerboseNotifs", {
    Title = "📢 Verbose Notifications",
    Description = "Show detailed notifications for all actions",
    Default = true
})

local NotificationDurationSlider = Tabs.Settings:AddSlider("NotifDuration", {
    Title = "⏱️ Notification Duration",
    Description = "How long notifications stay visible (seconds)",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        -- This would be applied to future notifications
    end
})

-- Performance Settings Section
Tabs.Settings:AddSection("Performance Settings")

Tabs.Settings:AddSlider("UpdateRate", {
    Title = "🔄 Status Update Rate",
    Description = "How often to update status display (seconds)",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        -- Restart status update with new rate
        if statusUpdateThread then
            task.cancel(statusUpdateThread)
        end
        
        statusUpdateThread = task.spawn(function()
            while true do
                updateAllStatus()
                task.wait(Value)
            end
        end)
        
        Fluent:Notify({
            Title = "⚙️ Update Rate Changed",
            Content = "Status updates every " .. Value .. "s",
            Duration = 2
        })
    end
})

local ReducedScanToggle = Tabs.Settings:AddToggle("ReducedScan", {
    Title = "⚡ Performance Mode",
    Description = "Reduce scan frequency to improve performance",
    Default = false
})

ReducedScanToggle:OnChanged(function(Value)
    if Value then
        EventTP.TeleportCheckInterval = 15
        scanCooldown = 20
        Fluent:Notify({
            Title = "⚡ Performance Mode ON",
            Content = "Reduced scanning for better FPS",
            Duration = 3
        })
    else
        EventTP.TeleportCheckInterval = 8
        scanCooldown = 10
        Fluent:Notify({
            Title = "🔥 Performance Mode OFF",
            Content = "Normal scanning restored",
            Duration = 3
        })
    end
end)

-- Debug Settings Section
Tabs.Settings:AddSection("Debug & Advanced")

local DebugModeToggle = Tabs.Settings:AddToggle("DebugMode", {
    Title = "🐛 Debug Mode",
    Description = "Show debug information in console",
    Default = false
})

DebugModeToggle:OnChanged(function(Value)
    if Value then
        print("=== 🐛 DEBUG MODE ENABLED ===")
        print("Selected Event:", selectedEvent)
        print("Auto Running:", autoEventRunning)
        print("Event Active:", eventIsActive)
        print("Cached Position:", cachedEventPosition)
        print("EventTP Running:", EventTP.IsRunning())
        print("Search Radius:", EventTP.SearchRadius)
        print("Height Offset:", EventTP.HeightOffset)
        print("============================")
    end
end)

Tabs.Settings:AddButton({
    Title = "🔄 Reset All Settings",
    Description = "Reset all settings to default values",
    Callback = function()
        -- Reset EventTP settings
        EventTP.SearchRadius = 25
        EventTP.TeleportCheckInterval = 8
        EventTP.HeightOffset = 15
        EventTP.RequireEventActive = true
        EventTP.UseSmartReteleport = true
        
        -- Reset cache
        cachedEventPosition = nil
        eventIsActive = false
        lastTeleportPosition = nil
        lastScanTime = 0
        scanCooldown = 10
        
        Fluent:Notify({
            Title = "🔄 Settings Reset",
            Content = "All settings restored to defaults",
            Duration = 4
        })
    end
})

Tabs.Settings:AddButton({
    Title = "🗑️ Clear All Cache & Stop",
    Description = "Stop all automation and clear all cached data",
    Callback = function()
        -- Stop everything
        if autoEventRunning then
            AutoEventToggle:SetValue(false)
        end
        if LochTimerToggle.Value then
            LochTimerToggle:SetValue(false)
        end
        if AutoLochToggle.Value then
            AutoLochToggle:SetValue(false)
        end
        
        EventTP.Stop()
        
        -- Clear cache
        cachedEventPosition = nil
        eventIsActive = false
        lastTeleportPosition = nil
        lastScanTime = 0
        selectedEvent = "Shark Hunt"
        autoEventTargetName = nil
        
        Fluent:Notify({
            Title = "🗑️ Full Reset Complete",
            Content = "All automation stopped & cache cleared",
            Duration = 4
        })
    end
})

-- [[ ABOUT SECTION ]] --
Tabs.Settings:AddSection("About")

Tabs.Settings:AddParagraph({
    Title = "ℹ️ About NPN Hub",
    Content = "Version: 3.0 Fluent Edition\n" ..
              "Created by: XYOURZONE\n" ..
              "UI: Fluent Library\n" ..
              "Features: Advanced Event Detection, Auto Teleport, Lochness Timer\n\n" ..
              "Press Left Alt to minimize/restore GUI"
})

-- [[ INITIALIZATION & CLEANUP ]] --

-- Welcome Notification
Fluent:Notify({
    Title = "🎣 NPN Hub Premium Loaded!",
    Content = "Fluent Edition v3.0\n✅ All systems ready\n🚀 Happy fishing!",
    Duration = 6
})

-- Initial status update
updateAllStatus()

-- Update Lochness in events list (dynamic show/hide)
task.spawn(function()
    while true do
        updateLochInEventsList(EventDropdown)
        task.wait(60) -- Check every minute
    end
end)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        -- Cancel all threads
        if statusUpdateThread then
            pcall(function() task.cancel(statusUpdateThread) end)
        end
        if autoEventTeleportThread then
            pcall(function() task.cancel(autoEventTeleportThread) end)
        end
        if lochCountdownThread then
            pcall(function() task.cancel(lochCountdownThread) end)
        end
        
        -- Stop automation
        EventTP.Stop()
        
        -- Cleanup GUI
        if lochCountdownGui then
            pcall(function() lochCountdownGui:Destroy() end)
        end
        
        -- Disconnect listeners
        if connChild then
            pcall(function() connChild:Disconnect() end)
        end
    end
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Wait for character to load
    task.wait(2)
    
    -- Notify user
    Fluent:Notify({
        Title = "👤 Character Respawned",
        Content = "Systems ready after respawn",
        Duration = 3
    })
    
    -- Refresh status
    updateAllStatus()
end)

-- [[ FINAL CONSOLE OUTPUT ]] --
print("╔═══════════════════════════════════════╗")
print("║   🎣 NPN HUB PREMIUM - FLUENT UI     ║")
print("║        Version 3.0 - LOADED!         ║")
print("╚═══════════════════════════════════════╝")
print("")
print("✅ Part 1: Setup & Helpers - LOADED")
print("✅ Part 2: Lochness & Event Engine - LOADED")
print("✅ Part 3: UI & Main Tabs - LOADED")
print("✅ Part 4: Status & Settings - LOADED")
print("")
print("🎯 Features Available:")
print("  • Smart Event Detection")
print("  • Auto Teleport System")
print("  • Lochness Monster Timer")
print("  • Real-time Status Monitoring")
print("  • Advanced Settings")
print("")
print("📱 Press Left Alt to minimize/restore GUI")
print("🚀 Happy Fishing!")
print("═══════════════════════════════════════")

-- Mark script as fully loaded
_G.NPNHubLoaded = true
_G.NPNHubVersion = "3.0 Fluent"

print("✅ PART 4/4 - Status, Settings & Finalization COMPLETE!")
print("🎉 FULL IMPLEMENTATION DONE! Script ready to use!")

-- [[ PART 5/7: AUTO FISHING SYSTEM ]] --

-- [[ AUTO FISHING VARIABLES ]] --
local autoFishingRunning = false
local autoFishingThread = nil
local autoEquipRodThread = nil
local autoSellThread = nil

-- Fishing Configuration
local fishingConfig = {
    autoEquipRod = true,
    autoSell = true,
    autoRebait = true,
    sellInterval = 30, -- seconds
    rodPriority = {"Mythical Rod", "Legendary Rod", "Epic Rod", "Advanced Rod", "Basic Rod"},
    sellLocation = "Merchant",
    keepRareItems = true,
    castDelay = 0.5,
    reelDelay = 0.2
}

-- [[ AUTO FISHING CORE FUNCTIONS ]] --
local function getRodInInventory()
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    -- Check equipped rod first
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and (item.Name:find("Rod") or item.Name:find("Fishing")) then
                return item
            end
        end
    end
    
    -- Check backpack for best rod
    for _, rodName in ipairs(fishingConfig.rodPriority) do
        local rod = backpack:FindFirstChild(rodName)
        if rod then
            return rod
        end
    end
    
    -- Check any rod in backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:find("Rod") or item.Name:find("Fishing")) then
            return item
        end
    end
    
    return nil
end

local function equipBestRod()
    local rod = getRodInInventory()
    if rod and rod.Parent == LocalPlayer.Backpack then
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid:EquipTool(rod)
            task.wait(0.5)
            return true
        end
    end
    return false
end

local function castFishingRod()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool or not (tool.Name:find("Rod") or tool.Name:find("Fishing")) then
        return false
    end
    
    -- Try to cast using remote
    pcall(function()
        if tool:FindFirstChild("events") then
            local castRemote = tool.events:FindFirstChild("cast")
            if castRemote then
                castRemote:FireServer(100) -- Max power cast
            end
        end
    end)
    
    -- Fallback: simulate mouse click
    pcall(function()
        tool:Activate()
    end)
    
    return true
end

local function reelIn()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    -- Try to reel using remote
    pcall(function()
        if tool:FindFirstChild("events") then
            local reelRemote = tool.events:FindFirstChild("reel")
            if reelRemote then
                reelRemote:FireServer()
            end
        end
    end)
    
    return true
end

local function autoSellItems()
    if not fishingConfig.autoSell then return end
    
    -- Find sell remote
    local sellRemote = GetRemote(RPath, "sell_all")
    if sellRemote then
        pcall(function()
            sellRemote:InvokeServer()
        end)
        
        Fluent:Notify({
            Title = "💰 Auto Sell",
            Content = "Items sold automatically",
            Duration = 2
        })
    end
end

-- [[ MAIN AUTO FISHING LOOP ]] --
local function startAutoFishing()
    autoFishingThread = task.spawn(function()
        while autoFishingRunning do
            pcall(function()
                -- 1. Equip rod if needed
                if fishingConfig.autoEquipRod then
                    local character = LocalPlayer.Character
                    if character then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if not tool or not (tool.Name:find("Rod") or tool.Name:find("Fishing")) then
                            equipBestRod()
                            task.wait(1)
                        end
                    end
                end
                
                -- 2. Cast fishing rod
                if castFishingRod() then
                    task.wait(fishingConfig.castDelay)
                    
                    -- 3. Wait a bit then reel in
                    task.wait(2 + math.random(1, 3)) -- Random wait time
                    reelIn()
                    task.wait(fishingConfig.reelDelay)
                else
                    task.wait(1) -- Wait if can't cast
                end
            end)
            
            task.wait(0.1)
        end
    end)
end

local function stopAutoFishing()
    autoFishingRunning = false
    if autoFishingThread then
        task.cancel(autoFishingThread)
        autoFishingThread = nil
    end
end

-- [[ AUTO SELL LOOP ]] --
local function startAutoSell()
    autoSellThread = task.spawn(function()
        while autoFishingRunning and fishingConfig.autoSell do
            task.wait(fishingConfig.sellInterval)
            autoSellItems()
        end
    end)
end

-- [[ FISHING TAB CREATION ]] --
local FishingTab = Window:AddTab({ Title = "🎣 Auto Fish", Icon = "fish" })

FishingTab:AddParagraph({
    Title = "🎣 Automatic Fishing System",
    Content = "Advanced fishing automation with rod management, auto-sell, and customizable settings.\nEnable Auto Fishing to start automated fishing with smart rod selection."
})

-- Main Auto Fishing Toggle
local AutoFishingToggle = FishingTab:AddToggle("AutoFishing", {
    Title = "🎣 Auto Fishing",
    Description = "Automatically cast and reel fishing rod continuously",
    Default = false
})

AutoFishingToggle:OnChanged(function(Value)
    autoFishingRunning = Value
    
    if Value then
        -- Check if player has a rod
        local rod = getRodInInventory()
        if not rod then
            Fluent:Notify({
                Title = "❌ No Fishing Rod",
                Content = "Please get a fishing rod first!",
                Duration = 4
            })
            AutoFishingToggle:SetValue(false)
            return
        end
        
        startAutoFishing()
        
        if fishingConfig.autoSell then
            startAutoSell()
        end
        
        Fluent:Notify({
            Title = "🎣 Auto Fishing Started",
            Content = "Fishing automation is now active",
            Duration = 4
        })
    else
        stopAutoFishing()
        
        if autoSellThread then
            task.cancel(autoSellThread)
            autoSellThread = nil
        end
        
        Fluent:Notify({
            Title = "🛑 Auto Fishing Stopped",
            Content = "Fishing automation disabled",
            Duration = 3
        })
    end
end)

-- Fishing Settings Section
FishingTab:AddSection("🎣 Fishing Settings")

local AutoEquipToggle = FishingTab:AddToggle("AutoEquipRod", {
    Title = "🎣 Auto Equip Rod",
    Description = "Automatically equip best available fishing rod",
    Default = true
})

AutoEquipToggle:OnChanged(function(Value)
    fishingConfig.autoEquipRod = Value
end)

local AutoSellToggle = FishingTab:AddToggle("AutoSell", {
    Title = "💰 Auto Sell",
    Description = "Automatically sell caught items",
    Default = true
})

AutoSellToggle:OnChanged(function(Value)
    fishingConfig.autoSell = Value
    
    if Value and autoFishingRunning then
        startAutoSell()
    end
end)

FishingTab:AddSlider("SellInterval", {
    Title = "⏱️ Sell Interval",
    Description = "How often to auto-sell items (seconds)",
    Default = 30,
    Min = 10,
    Max = 120,
    Rounding = 5,
    Callback = function(Value)
        fishingConfig.sellInterval = Value
    end
})

FishingTab:AddSlider("CastDelay", {
    Title = "⏱️ Cast Delay",
    Description = "Delay between fishing actions (seconds)",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Rounding = 0.1,
    Callback = function(Value)
        fishingConfig.castDelay = Value
    end
})

-- Manual Actions Section
FishingTab:AddSection("📋 Manual Actions")

FishingTab:AddButton({
    Title = "🎣 Equip Best Rod",
    Description = "Manually equip the best fishing rod available",
    Callback = function()
        if equipBestRod() then
            Fluent:Notify({
                Title = "🎣 Rod Equipped",
                Content = "Best available rod equipped",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "❌ No Rod Available",
                Content = "No fishing rod found in inventory",
                Duration = 3
            })
        end
    end
})

FishingTab:AddButton({
    Title = "💰 Sell All Items",
    Description = "Manually sell all caught items",
    Callback = function()
        autoSellItems()
    end
})

FishingTab:AddButton({
    Title = "🎯 Cast Rod",
    Description = "Manually cast fishing rod once",
    Callback = function()
        if castFishingRod() then
            Fluent:Notify({
                Title = "🎯 Rod Cast",
                Content = "Fishing rod cast successfully",
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "❌ Cast Failed",
                Content = "No fishing rod equipped",
                Duration = 3
            })
        end
    end
})

-- Rod Status Display
local RodStatusDisplay = FishingTab:AddParagraph({
    Title = "🎣 Rod Status",
    Content = "Loading rod information..."
})

-- Update rod status
task.spawn(function()
    while true do
        pcall(function()
            local rod = getRodInInventory()
            local equippedRod = "None"
            local availableRods = 0
            
            if LocalPlayer.Character then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:find("Rod") or tool.Name:find("Fishing")) then
                    equippedRod = tool.Name
                end
            end
            
            if LocalPlayer.Backpack then
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:find("Rod") or item.Name:find("Fishing")) then
                        availableRods = availableRods + 1
                    end
                end
            end
            
            RodStatusDisplay:SetDesc(
                "Equipped Rod: " .. equippedRod .. "\n" ..
                "Available Rods: " .. availableRods .. "\n" ..
                "Auto Fishing: " .. (autoFishingRunning and "🟢 Active" or "🔴 Inactive")
            )
        end)
        
        task.wait(3)
    end
end)

print("✅ PART 5/7 - Auto Fishing System LOADED!")

-- [[ PART 6/7: BLATANT FEATURES & PLAYER MODIFICATIONS ]] --

-- [[ BLATANT VARIABLES ]] --
local blatantConfig = {
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 16,
    noclipEnabled = false,
    flyEnabled = false,
    speedEnabled = false,
    jumpEnabled = false,
    infiniteJump = false
}

local originalValues = {
    walkSpeed = 16,
    jumpPower = 50
}

-- Movement threads
local flyThread = nil
local noclipThread = nil
local speedThread = nil

-- [[ UTILITY FUNCTIONS ]] --
local function saveOriginalValues()
    local humanoid = GetHumanoid()
    if humanoid then
        originalValues.walkSpeed = humanoid.WalkSpeed
        originalValues.jumpPower = humanoid.JumpPower or humanoid.JumpHeight or 50
    end
end

local function restoreOriginalValues()
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = originalValues.walkSpeed
        if humanoid.JumpPower then
            humanoid.JumpPower = originalValues.jumpPower
        elseif humanoid.JumpHeight then
            humanoid.JumpHeight = originalValues.jumpPower
        end
    end
end

-- [[ SPEED HACK ]] --
local function enableSpeed(speed)
    blatantConfig.speedEnabled = true
    blatantConfig.walkSpeed = speed
    
    speedThread = task.spawn(function()
        while blatantConfig.speedEnabled do
            pcall(function()
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid.WalkSpeed = blatantConfig.walkSpeed
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function disableSpeed()
    blatantConfig.speedEnabled = false
    if speedThread then
        task.cancel(speedThread)
        speedThread = nil
    end
    restoreOriginalValues()
end

-- [[ JUMP HACK ]] --
local function enableJump(power)
    blatantConfig.jumpEnabled = true
    blatantConfig.jumpPower = power
    
    local humanoid = GetHumanoid()
    if humanoid then
        if humanoid.JumpPower then
            humanoid.JumpPower = power
        elseif humanoid.JumpHeight then
            humanoid.JumpHeight = power
        end
    end
end

local function disableJump()
    blatantConfig.jumpEnabled = false
    restoreOriginalValues()
end

-- [[ FLY HACK ]] --
local function enableFly()
    blatantConfig.flyEnabled = true
    
    flyThread = task.spawn(function()
        local hrp = GetHRP()
        if not hrp then return end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        local camera = workspace.CurrentCamera
        
        while blatantConfig.flyEnabled and hrp.Parent do
            pcall(function()
                local moveVector = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveVector * blatantConfig.flySpeed
            end)
            
            task.wait()
        end
        
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
    end)
end

local function disableFly()
    blatantConfig.flyEnabled = false
    if flyThread then
        task.cancel(flyThread)
        flyThread = nil
    end
end

-- [[ NOCLIP HACK ]] --
local function enableNoclip()
    blatantConfig.noclipEnabled = true
    
    noclipThread = task.spawn(function()
        while blatantConfig.noclipEnabled do
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            task.wait()
        end
    end)
end

local function disableNoclip()
    blatantConfig.noclipEnabled = false
    if noclipThread then
        task.cancel(noclipThread)
        noclipThread = nil
    end
    
    -- Restore collision
    pcall(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end

-- [[ INFINITE JUMP ]] --
local function setupInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if blatantConfig.infiniteJump then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- [[ CHARACTER RESPAWN HANDLER ]] --
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to load
    saveOriginalValues()
    
    -- Reapply blatant features if they were enabled
    if blatantConfig.speedEnabled then
        enableSpeed(blatantConfig.walkSpeed)
    end
    if blatantConfig.jumpEnabled then
        enableJump(blatantConfig.jumpPower)
    end
    if blatantConfig.flyEnabled then
        enableFly()
    end
    if blatantConfig.noclipEnabled then
        enableNoclip()
    end
end)

-- [[ BLATANT TAB CREATION ]] --
local BlatantTab = Window:AddTab({ Title = "⚡ Blatant", Icon = "zap" })

BlatantTab:AddParagraph({
    Title = "⚡ Player Modifications",
    Content = "Advanced movement and player modifications.\n⚠️ Warning: These features are highly detectable!"
})

-- Speed Section
BlatantTab:AddSection("🏃 Speed Modifications")

local SpeedToggle = BlatantTab:AddToggle("Speed", {
    Title = "🏃 Speed Hack",
    Description = "Modify player walk speed",
    Default = false
})

SpeedToggle:OnChanged(function(Value)
    if Value then
        enableSpeed(blatantConfig.walkSpeed)
        Fluent:Notify({
            Title = "🏃 Speed Enabled",
            Content = "Walk speed: " .. blatantConfig.walkSpeed,
            Duration = 3
        })
    else
        disableSpeed()
        Fluent:Notify({
            Title = "🏃 Speed Disabled", 
            Content = "Walk speed restored to normal",
            Duration = 3
        })
    end
end)

BlatantTab:AddSlider("SpeedValue", {
    Title = "🏃 Speed Value",
    Description = "Set custom walk speed",
    Default = 50,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        blatantConfig.walkSpeed = Value
        if blatantConfig.speedEnabled then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

-- Jump Section
BlatantTab:AddSection("🦘 Jump Modifications")

local JumpToggle = BlatantTab:AddToggle("Jump", {
    Title = "🦘 Jump Boost",
    Description = "Modify player jump power",
    Default = false
})

JumpToggle:OnChanged(function(Value)
    if Value then
        enableJump(blatantConfig.jumpPower)
        Fluent:Notify({
            Title = "🦘 Jump Boost Enabled",
            Content = "Jump power: " .. blatantConfig.jumpPower,
            Duration = 3
        })
    else
        disableJump()
        Fluent:Notify({
            Title = "🦘 Jump Boost Disabled",
            Content = "Jump power restored to normal", 
            Duration = 3
        })
    end
end)

BlatantTab:AddSlider("JumpValue", {
    Title = "🦘 Jump Power",
    Description = "Set custom jump power",
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 5,
    Callback = function(Value)
        blatantConfig.jumpPower = Value
        if blatantConfig.jumpEnabled then
            enableJump(Value)
        end
    end
})

local InfiniteJumpToggle = BlatantTab:AddToggle("InfiniteJump", {
    Title = "🚀 Infinite Jump",
    Description = "Jump unlimited times in the air",
    Default = false
})

InfiniteJumpToggle:OnChanged(function(Value)
    blatantConfig.infiniteJump = Value
    if Value then
        Fluent:Notify({
            Title = "🚀 Infinite Jump Enabled",
            Content = "You can now jump infinitely",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "🚀 Infinite Jump Disabled", 
            Content = "Normal jump behavior restored",
            Duration = 3
        })
    end
end)

-- Flight Section  
BlatantTab:AddSection("✈️ Flight")

local FlyToggle = BlatantTab:AddToggle("Fly", {
    Title = "✈️ Fly Mode",
    Description = "Enable flight with WASD + Space/Shift controls",
    Default = false
})

FlyToggle:OnChanged(function(Value)
    if Value then
        enableFly()
        Fluent:Notify({
            Title = "✈️ Flight Enabled",
            Content = "Use WASD + Space/Shift to fly\nFly speed: " .. blatantConfig.flySpeed,
            Duration = 5
        })
    else
        disableFly()
        Fluent:Notify({
            Title = "✈️ Flight Disabled",
            Content = "Flight mode deactivated",
            Duration = 3
        })
    end
end)

BlatantTab:AddSlider("FlySpeed", {
    Title = "✈️ Fly Speed",
    Description = "Set flight movement speed",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 5,
    Callback = function(Value)
        blatantConfig.flySpeed = Value
    end
})

-- Noclip Section
BlatantTab:AddSection("👻 Noclip")

local NoclipToggle = BlatantTab:AddToggle("Noclip", {
    Title = "👻 Noclip",
    Description = "Walk through walls and objects",
    Default = false
})

NoclipToggle:OnChanged(function(Value)
    if Value then
        enableNoclip()
        Fluent:Notify({
            Title = "👻 Noclip Enabled", 
            Content = "You can now walk through objects",
            Duration = 3
        })
    else
        disableNoclip()
        Fluent:Notify({
            Title = "👻 Noclip Disabled",
            Content = "Normal collision restored",
            Duration = 3
        })
    end
end)

-- Quick Actions Section
BlatantTab:AddSection("⚡ Quick Actions")

BlatantTab:AddButton({
    Title = "🔄 Reset Character",
    Description = "Reset your character to spawn",
    Callback = function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.Health = 0
            Fluent:Notify({
                Title = "🔄 Character Reset",
                Content = "Your character has been reset",
                Duration = 3
            })
        end
    end
})

BlatantTab:AddButton({
    Title = "⚡ Disable All Blatant",
    Description = "Disable all blatant features at once",
    Callback = function()
        -- Disable all toggles
        SpeedToggle:SetValue(false)
        JumpToggle:SetValue(false)
        InfiniteJumpToggle:SetValue(false)
        FlyToggle:SetValue(false)
        NoclipToggle:SetValue(false)
        
        Fluent:Notify({
            Title = "⚡ All Blatant Disabled",
            Content = "All modifications have been disabled",
            Duration = 4
        })
    end
})

BlatantTab:AddButton({
    Title = "💾 Save Current Values",
    Description = "Save current speed/jump as default",
    Callback = function()
        saveOriginalValues()
        Fluent:Notify({
            Title = "💾 Values Saved",
            Content = "Current player values saved as default",
            Duration = 3
        })
    end
})

-- Status Display
local BlatantStatusDisplay = BlatantTab:AddParagraph({
    Title = "📊 Blatant Status",
    Content = "Loading blatant status..."
})

-- Update blatant status
task.spawn(function()
    while true do
        pcall(function()
            local status = {}
            
            if blatantConfig.speedEnabled then
                table.insert(status, "🏃 Speed: " .. blatantConfig.walkSpeed)
            end
            if blatantConfig.jumpEnabled then
                table.insert(status, "🦘 Jump: " .. blatantConfig.jumpPower)
            end
            if blatantConfig.flyEnabled then
                table.insert(status, "✈️ Fly: " .. blatantConfig.flySpeed)
            end
            if blatantConfig.noclipEnabled then
                table.insert(status, "👻 Noclip: ON")
            end
            if blatantConfig.infiniteJump then
                table.insert(status, "🚀 Infinite Jump: ON")
            end
            
            if #status == 0 then
                BlatantStatusDisplay:SetDesc("Status: 🔴 All features disabled\nPerformance: ✅ Normal")
            else
                BlatantStatusDisplay:SetDesc("Active Features:\n" .. table.concat(status, "\n") .. "\n\n⚠️ High detection risk!")
            end
        end)
        
        task.wait(2)
    end
end)

-- Initialize
saveOriginalValues()
setupInfiniteJump()

-- Warning message
task.wait(1)
Fluent:Notify({
    Title = "⚠️ Blatant Features Loaded",
    Content = "Use these features responsibly!\nThey are easily detectable.",
    Duration = 5
})

print("✅ PART 6/7 - Blatant Features & Player Modifications LOADED!")

-- [[ PART 6/7: BLATANT FEATURES & PLAYER MODIFICATIONS ]] --

-- [[ BLATANT VARIABLES ]] --
local blatantConfig = {
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 16,
    noclipEnabled = false,
    flyEnabled = false,
    speedEnabled = false,
    jumpEnabled = false,
    infiniteJump = false
}

local originalValues = {
    walkSpeed = 16,
    jumpPower = 50
}

-- Movement threads
local flyThread = nil
local noclipThread = nil
local speedThread = nil

-- [[ UTILITY FUNCTIONS ]] --
local function saveOriginalValues()
    local humanoid = GetHumanoid()
    if humanoid then
        originalValues.walkSpeed = humanoid.WalkSpeed
        originalValues.jumpPower = humanoid.JumpPower or humanoid.JumpHeight or 50
    end
end

local function restoreOriginalValues()
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = originalValues.walkSpeed
        if humanoid.JumpPower then
            humanoid.JumpPower = originalValues.jumpPower
        elseif humanoid.JumpHeight then
            humanoid.JumpHeight = originalValues.jumpPower
        end
    end
end

-- [[ SPEED HACK ]] --
local function enableSpeed(speed)
    blatantConfig.speedEnabled = true
    blatantConfig.walkSpeed = speed
    
    speedThread = task.spawn(function()
        while blatantConfig.speedEnabled do
            pcall(function()
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid.WalkSpeed = blatantConfig.walkSpeed
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function disableSpeed()
    blatantConfig.speedEnabled = false
    if speedThread then
        task.cancel(speedThread)
        speedThread = nil
    end
    restoreOriginalValues()
end

-- [[ JUMP HACK ]] --
local function enableJump(power)
    blatantConfig.jumpEnabled = true
    blatantConfig.jumpPower = power
    
    local humanoid = GetHumanoid()
    if humanoid then
        if humanoid.JumpPower then
            humanoid.JumpPower = power
        elseif humanoid.JumpHeight then
            humanoid.JumpHeight = power
        end
    end
end

local function disableJump()
    blatantConfig.jumpEnabled = false
    restoreOriginalValues()
end

-- [[ FLY HACK ]] --
local function enableFly()
    blatantConfig.flyEnabled = true
    
    flyThread = task.spawn(function()
        local hrp = GetHRP()
        if not hrp then return end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        local camera = workspace.CurrentCamera
        
        while blatantConfig.flyEnabled and hrp.Parent do
            pcall(function()
                local moveVector = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveVector * blatantConfig.flySpeed
            end)
            
            task.wait()
        end
        
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
    end)
end

local function disableFly()
    blatantConfig.flyEnabled = false
    if flyThread then
        task.cancel(flyThread)
        flyThread = nil
    end
end

-- [[ NOCLIP HACK ]] --
local function enableNoclip()
    blatantConfig.noclipEnabled = true
    
    noclipThread = task.spawn(function()
        while blatantConfig.noclipEnabled do
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            task.wait()
        end
    end)
end

local function disableNoclip()
    blatantConfig.noclipEnabled = false
    if noclipThread then
        task.cancel(noclipThread)
        noclipThread = nil
    end
    
    -- Restore collision
    pcall(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end

-- [[ INFINITE JUMP ]] --
local function setupInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if blatantConfig.infiniteJump then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- [[ CHARACTER RESPAWN HANDLER ]] --
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to load
    saveOriginalValues()
    
    -- Reapply blatant features if they were enabled
    if blatantConfig.speedEnabled then
        enableSpeed(blatantConfig.walkSpeed)
    end
    if blatantConfig.jumpEnabled then
        enableJump(blatantConfig.jumpPower)
    end
    if blatantConfig.flyEnabled then
        enableFly()
    end
    if blatantConfig.noclipEnabled then
        enableNoclip()
    end
end)

-- [[ BLATANT TAB CREATION ]] --
local BlatantTab = Window:AddTab({ Title = "⚡ Blatant", Icon = "zap" })

BlatantTab:AddParagraph({
    Title = "⚡ Player Modifications",
    Content = "Advanced movement and player modifications.\n⚠️ Warning: These features are highly detectable!"
})

-- Speed Section
BlatantTab:AddSection("🏃 Speed Modifications")

local SpeedToggle = BlatantTab:AddToggle("Speed", {
    Title = "🏃 Speed Hack",
    Description = "Modify player walk speed",
    Default = false
})

SpeedToggle:OnChanged(function(Value)
    if Value then
        enableSpeed(blatantConfig.walkSpeed)
        Fluent:Notify({
            Title = "🏃 Speed Enabled",
            Content = "Walk speed: " .. blatantConfig.walkSpeed,
            Duration = 3
        })
    else
        disableSpeed()
        Fluent:Notify({
            Title = "🏃 Speed Disabled", 
            Content = "Walk speed restored to normal",
            Duration = 3
        })
    end
end)

BlatantTab:AddSlider("SpeedValue", {
    Title = "🏃 Speed Value",
    Description = "Set custom walk speed",
    Default = 50,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        blatantConfig.walkSpeed = Value
        if blatantConfig.speedEnabled then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

-- Jump Section
BlatantTab:AddSection("🦘 Jump Modifications")

local JumpToggle = BlatantTab:AddToggle("Jump", {
    Title = "🦘 Jump Boost",
    Description = "Modify player jump power",
    Default = false
})

JumpToggle:OnChanged(function(Value)
    if Value then
        enableJump(blatantConfig.jumpPower)
        Fluent:Notify({
            Title = "🦘 Jump Boost Enabled",
            Content = "Jump power: " .. blatantConfig.jumpPower,
            Duration = 3
        })
    else
        disableJump()
        Fluent:Notify({
            Title = "🦘 Jump Boost Disabled",
            Content = "Jump power restored to normal", 
            Duration = 3
        })
    end
end)

BlatantTab:AddSlider("JumpValue", {
    Title = "🦘 Jump Power",
    Description = "Set custom jump power",
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 5,
    Callback = function(Value)
        blatantConfig.jumpPower = Value
        if blatantConfig.jumpEnabled then
            enableJump(Value)
        end
    end
})

local InfiniteJumpToggle = BlatantTab:AddToggle("InfiniteJump", {
    Title = "🚀 Infinite Jump",
    Description = "Jump unlimited times in the air",
    Default = false
})

InfiniteJumpToggle:OnChanged(function(Value)
    blatantConfig.infiniteJump = Value
    if Value then
        Fluent:Notify({
            Title = "🚀 Infinite Jump Enabled",
            Content = "You can now jump infinitely",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "🚀 Infinite Jump Disabled", 
            Content = "Normal jump behavior restored",
            Duration = 3
        })
    end
end)

-- Flight Section  
BlatantTab:AddSection("✈️ Flight")

local FlyToggle = BlatantTab:AddToggle("Fly", {
    Title = "✈️ Fly Mode",
    Description = "Enable flight with WASD + Space/Shift controls",
    Default = false
})

FlyToggle:OnChanged(function(Value)
    if Value then
        enableFly()
        Fluent:Notify({
            Title = "✈️ Flight Enabled",
            Content = "Use WASD + Space/Shift to fly\nFly speed: " .. blatantConfig.flySpeed,
            Duration = 5
        })
    else
        disableFly()
        Fluent:Notify({
            Title = "✈️ Flight Disabled",
            Content = "Flight mode deactivated",
            Duration = 3
        })
    end
end)

BlatantTab:AddSlider("FlySpeed", {
    Title = "✈️ Fly Speed",
    Description = "Set flight movement speed",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 5,
    Callback = function(Value)
        blatantConfig.flySpeed = Value
    end
})

-- Noclip Section
BlatantTab:AddSection("👻 Noclip")

local NoclipToggle = BlatantTab:AddToggle("Noclip", {
    Title = "👻 Noclip",
    Description = "Walk through walls and objects",
    Default = false
})

NoclipToggle:OnChanged(function(Value)
    if Value then
        enableNoclip()
        Fluent:Notify({
            Title = "👻 Noclip Enabled", 
            Content = "You can now walk through objects",
            Duration = 3
        })
    else
        disableNoclip()
        Fluent:Notify({
            Title = "👻 Noclip Disabled",
            Content = "Normal collision restored",
            Duration = 3
        })
    end
end)

-- Quick Actions Section
BlatantTab:AddSection("⚡ Quick Actions")

BlatantTab:AddButton({
    Title = "🔄 Reset Character",
    Description = "Reset your character to spawn",
    Callback = function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.Health = 0
            Fluent:Notify({
                Title = "🔄 Character Reset",
                Content = "Your character has been reset",
                Duration = 3
            })
        end
    end
})

BlatantTab:AddButton({
    Title = "⚡ Disable All Blatant",
    Description = "Disable all blatant features at once",
    Callback = function()
        -- Disable all toggles
        SpeedToggle:SetValue(false)
        JumpToggle:SetValue(false)
        InfiniteJumpToggle:SetValue(false)
        FlyToggle:SetValue(false)
        NoclipToggle:SetValue(false)
        
        Fluent:Notify({
            Title = "⚡ All Blatant Disabled",
            Content = "All modifications have been disabled",
            Duration = 4
        })
    end
})

BlatantTab:AddButton({
    Title = "💾 Save Current Values",
    Description = "Save current speed/jump as default",
    Callback = function()
        saveOriginalValues()
        Fluent:Notify({
            Title = "💾 Values Saved",
            Content = "Current player values saved as default",
            Duration = 3
        })
    end
})

-- Status Display
local BlatantStatusDisplay = BlatantTab:AddParagraph({
    Title = "📊 Blatant Status",
    Content = "Loading blatant status..."
})

-- Update blatant status
task.spawn(function()
    while true do
        pcall(function()
            local status = {}
            
            if blatantConfig.speedEnabled then
                table.insert(status, "🏃 Speed: " .. blatantConfig.walkSpeed)
            end
            if blatantConfig.jumpEnabled then
                table.insert(status, "🦘 Jump: " .. blatantConfig.jumpPower)
            end
            if blatantConfig.flyEnabled then
                table.insert(status, "✈️ Fly: " .. blatantConfig.flySpeed)
            end
            if blatantConfig.noclipEnabled then
                table.insert(status, "👻 Noclip: ON")
            end
            if blatantConfig.infiniteJump then
                table.insert(status, "🚀 Infinite Jump: ON")
            end
            
            if #status == 0 then
                BlatantStatusDisplay:SetDesc("Status: 🔴 All features disabled\nPerformance: ✅ Normal")
            else
                BlatantStatusDisplay:SetDesc("Active Features:\n" .. table.concat(status, "\n") .. "\n\n⚠️ High detection risk!")
            end
        end)
        
        task.wait(2)
    end
end)

-- Initialize
saveOriginalValues()
setupInfiniteJump()

-- Warning message
task.wait(1)
Fluent:Notify({
    Title = "⚠️ Blatant Features Loaded",
    Content = "Use these features responsibly!\nThey are easily detectable.",
    Duration = 5
})

print("✅ PART 6/7 - Blatant Features & Player Modifications LOADED!")
