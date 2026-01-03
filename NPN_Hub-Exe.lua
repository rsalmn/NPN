-- [[ UNIVERSAL FISH IT SCRIPT - FREE EXECUTOR COMPATIBLE ]] --
-- Compatible: Delta, Xeno, Krnl, JJSploit, Fluxus, dan lainnya

-- [[ EXECUTOR DETECTION & CONFIG ]] --
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
    return "unknown"
end

local currentExecutor = detectExecutor()
local isFreeTier = (currentExecutor == "xeno" or currentExecutor == "krnl" or currentExecutor == "jjsploit")

-- [[ UNIVERSAL CONFIG ]] --
local UniversalConfig = {
    -- Delays untuk free executors
    TeleportDelay = isFreeTier and 2 or 0.5,
    ScanInterval = isFreeTier and 15 or 8,
    HttpTimeout = isFreeTier and 10 or 5,
    
    -- Feature toggles
    UseAdvancedAntiAFK = not isFreeTier,
    UseFallbackLoader = isFreeTier,
    MaxTeleportDistance = isFreeTier and 800 or 9999,
    
    -- Safety settings
    AddRandomDelay = isFreeTier,
    UseGradualTeleport = isFreeTier,
    EnableDebugMode = false
}

print("[🎣 Fish It] Detected Executor:", currentExecutor, isFreeTier and "(Free Tier)" or "(Premium)")

-- [[ UNIVERSAL WINDUI LOADER ]] --
local function universalLoadWindUI()
    local attempts = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        -- Fallback URLs for limited executors
        "https://pastebin.com/raw/windui_backup" -- Replace with actual backup
    }
    
    for i, url in ipairs(attempts) do
        local success, result = pcall(function()
            if UniversalConfig.EnableDebugMode then
                print("[Debug] Trying URL", i, ":", url)
            end
            return loadstring(game:HttpGet(url, true))()
        end)
        
        if success and result then
            print("[✅ WindUI] Loaded successfully from attempt", i)
            return result
        else
            print("[⚠️ WindUI] Attempt", i, "failed, trying next...")
            task.wait(1) -- Delay between attempts
        end
    end
    
    error("Failed to load WindUI from all sources!")
end

local WindUI = universalLoadWindUI()

-- [[ UNIVERSAL WINDOW CREATION ]] --
local Window = WindUI:CreateWindow({
    Title = "🎣 Fish It Hub - Universal Edition",
    Icon = "geist:fish",
    Author = "Universal Script | All Executors",
    Folder = "FishItUniversal",
    Size = UDim2.fromOffset(isFreeTier and 500 or 600, isFreeTier and 400 or 450),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    KeySystem = not isFreeTier and {
        Note = "Premium features available",
        API = {
            {
                Type = "pandadevelopment",
                ServiceId = "FishItUniversal",
            }
        }
    } or nil -- No key system for free tier testing
})

-- [[ SERVICES & VARIABLES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser") -- For fallback anti-AFK

local UniversalConfig_Manager = Window.ConfigManager:CreateConfig("fishit_universal")
local function Reg(id, element)
    UniversalConfig_Manager:Register(id, element)
    return element
end

-- [[ UNIVERSAL HELPER FUNCTIONS ]] --
local function safeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

local function GetHumanoid()
    local Character = LocalPlayer.Character
    if not Character then 
        local success = pcall(function()
            Character = LocalPlayer.CharacterAdded:Wait()
        end)
        if not success then return nil end
    end
    return Character and Character:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local Character = LocalPlayer.Character
    if not Character then 
        local success = pcall(function()
            Character = LocalPlayer.CharacterAdded:Wait()
        end)
        if not success then return nil end
    end
    return Character and Character:WaitForChild("HumanoidRootPart", 5)
end

-- [[ UNIVERSAL ANTI-AFK SYSTEM ]] --
local function setupUniversalAntiAFK()
    local success = false
    
    -- Method 1: Advanced (Premium executors)
    if UniversalConfig.UseAdvancedAntiAFK then
        local advancedSuccess = pcall(function()
            for i, v in pairs(getconnections(LocalPlayer.Idled)) do
                if v.Disable then
                    v:Disable()
                    success = true
                end
            end
        end)
        
        if advancedSuccess and success then
            print("[✅ Anti-AFK] Advanced method activated")
            return
        end
    end
    
    -- Method 2: Universal Fallback (All executors)
    local fallbackSuccess = pcall(function()
        LocalPlayer.Idled:Connect(function()
            local cam = workspace.CurrentCamera
            if cam then
                VirtualUser:Button2Down(Vector2.new(0,0), cam.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0), cam.CFrame)
            end
        end)
        success = true
    end)
    
    if fallbackSuccess then
        print("[✅ Anti-AFK] Universal method activated")
    else
        print("[❌ Anti-AFK] Failed to setup")
    end
end

setupUniversalAntiAFK()

-- [[ UNIVERSAL STATUS DETECTION ]] --
local function getUniversalStatus()
    local success, result = pcall(function()
        local char = LocalPlayer.Character
        if not char then return "UNKNOWN" end
        
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not hrp then return "UNKNOWN" end

        -- Swimming state check
        if hum:GetState() == Enum.HumanoidStateType.Swimming then
            return "WATER (SWIMMING)"
        end

        -- Floor material check
        if hum.FloorMaterial == Enum.Material.Water then
            return "WATER"
        elseif hum.FloorMaterial ~= Enum.Material.Air then
            return "LAND"
        end

        -- Simple raycast for free executors
        if not isFreeTier then
            local origin = hrp.Position
            local direction = Vector3.new(0, -10, 0)
            
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.IgnoreWater = false
            
            local rayResult = workspace:Raycast(origin, direction, params)
            
            if rayResult and rayResult.Material == Enum.Material.Water then
                return "WATER"
            elseif rayResult then
                return "LAND"
            end
        end

        return "UNKNOWN"
    end)
    
    return success and result or "ERROR"
end

-- [[ UNIVERSAL TELEPORT SYSTEM ]] --
local lastTeleportTime = 0

local function universalTeleport(position, lookVector)
    local currentTime = tick()
    
    -- Rate limiting for free executors
    if isFreeTier and currentTime - lastTeleportTime < UniversalConfig.TeleportDelay then
        WindUI:Notify({
            Title = "Teleport Cooldown", 
            Description = "Please wait " .. math.ceil(UniversalConfig.TeleportDelay - (currentTime - lastTeleportTime)) .. "s",
            Duration = 2,
            Icon = "clock"
        })
        return false
    end
    
    local success = pcall(function()
        local hrp = GetHRP()
        if not hrp or typeof(position) ~= "Vector3" then return end
        
        -- Add random delay for free executors
        if UniversalConfig.AddRandomDelay then
            task.wait(math.random(50, 200) / 100) -- 0.5-2s random delay
        end
        
        -- Gradual teleport for long distances (free executors)
        if UniversalConfig.UseGradualTeleport then
            local currentPos = hrp.Position
            local distance = (position - currentPos).Magnitude
            
            if distance > UniversalConfig.MaxTeleportDistance then
                -- Split into multiple teleports
                local midPoint = currentPos:Lerp(position, 0.6)
                hrp.CFrame = CFrame.new(midPoint, midPoint + (lookVector or Vector3.new(0, 0, 1)))
                task.wait(1)
            end
        end
        
        -- Final teleport
        local targetCFrame = lookVector and CFrame.new(position, position + lookVector) or CFrame.new(position)
        hrp.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
        
        lastTeleportTime = currentTime
    end)
    
    if success then
        WindUI:Notify({
            Title = "Teleport Success!", 
            Description = "Moved to target location",
            Duration = 2,
            Icon = "map-pin"
        })
        return true
    else
        WindUI:Notify({
            Title = "Teleport Failed", 
            Description = "Please try again",
            Duration = 3,
            Icon = "alert-triangle"
        })
        return false
    end
end

-- [[ UNIVERSAL EVENT SYSTEM ]] --
local UniversalEvents = {
    ["Shark Hunt"] = {
        Vector3.new(1.65, -1.35, 2095.72),
        Vector3.new(1369.94, -1.35, 930.12),
        Vector3.new(-1585.5, -1.35, 1242.87),
    },
    ["Worm Hunt"] = {
        Vector3.new(2190.85, -1.40, 97.57),
        Vector3.new(-2450.6, -1.40, 139.73),
        Vector3.new(-267.47, -1.40, 5188.53),
    },
    ["Megalodon Hunt"] = {
        Vector3.new(-1076.3, -1.40, 1676.19),
        Vector3.new(-1191.8, -1.40, 3597.30),
        Vector3.new(412.70, -1.40, 4134.39),
    },
    ["Ghost Shark Hunt"] = {
        Vector3.new(489.56, -1.35, 25.41),
        Vector3.new(-1358.2, -1.35, 4100.55),
        Vector3.new(627.86, -1.35, 3798.08),
    },
    ["Treasure Hunt"] = {
        Vector3.new(0, -1.35, 0), -- Placeholder
    }
}

local currentAutoEvent = nil
local autoEventRunning = false

local function scanForEvent(eventName, timeout)
    if not UniversalEvents[eventName] then return nil end
    
    local startTime = tick()
    timeout = timeout or (isFreeTier and 30 or 15)
    
    for _, coord in ipairs(UniversalEvents[eventName]) do
        if tick() - startTime > timeout then break end
        
        local success, parts = pcall(function()
            local region = Region3.new(
                coord - Vector3.new(25, 15, 25),
                coord + Vector3.new(25, 15, 25)
            ):ExpandToGrid(4)
            return workspace:FindPartsInRegion3(region, nil, isFreeTier and 30 or 50)
        end)
        
        if success and parts then
            for _, part in ipairs(parts) do
                local partSuccess = pcall(function()
                    if part and part.Parent and (part.Position - coord).Magnitude <= 20 then
                        return true
                    end
                end)
                
                if partSuccess then
                    return Vector3.new(coord.X, coord.Y + 10, coord.Z) -- Add height offset
                end
            end
        end
        
        task.wait(isFreeTier and 1 or 0.5) -- Longer delays for free executors
    end
    
    return nil
end

-- [[ GUI CREATION ]] --
local MainTab = Window:CreateTab({ Title = "🎣 Main Features", Icon = "fish" })

-- Status Section
local StatusSection = MainTab:CreateSection("📊 Player Status")

local StatusLabel = StatusSection:CreateParagraph({
    Title = "Current Status",
    Content = "Initializing..."
})

-- Auto-update status
task.spawn(function()
    while task.wait(isFreeTier and 2 or 1) do -- Slower updates for free executors
        local status = getUniversalStatus()
        StatusLabel:SetContent("Location: " .. status .. "\nExecutor: " .. currentExecutor .. " " .. (isFreeTier and "(Free)" or "(Premium)"))
    end
end)

-- Teleport Section
local TeleportSection = MainTab:CreateSection("🌍 Teleportation")

local eventDropdown = TeleportSection:CreateDropdown({
    Title = "Select Event",
    Values = {"Shark Hunt", "Worm Hunt", "Megalodon Hunt", "Ghost Shark Hunt", "Treasure Hunt"},
    Multi = false,
    Default = 1,
})

Reg("selected_event", eventDropdown)

TeleportSection:CreateButton({
    Title = "🎯 Teleport to Event",
    Description = "Teleport to selected event location",
    Callback = function()
        local selectedEvent = eventDropdown.Value
        if not selectedEvent or selectedEvent == "" then
            WindUI:Notify({
                Title = "No Event Selected",
                Description = "Please select an event first",
                Duration = 3,
                Icon = "alert-triangle"
            })
            return
        end
        
        WindUI:Notify({
            Title = "Searching for " .. selectedEvent,
            Description = "Please wait...",
            Duration = 2,
            Icon = "search"
        })
        
        task.spawn(function()
            local eventPos = scanForEvent(selectedEvent)
            if eventPos then
                universalTeleport(eventPos)
            else
                WindUI:Notify({
                    Title = "Event Not Found",
                    Description = selectedEvent .. " is not currently active",
                    Duration = 4,
                    Icon = "x-circle"
                })
            end
        end)
    end
})

-- Auto Event Section
local AutoSection = MainTab:CreateSection("🤖 Auto Features")

local autoEventToggle = AutoSection:CreateToggle({
    Title = "Auto Event Teleport",
    Description = "Automatically teleport to events when they spawn",
    Default = false
})

Reg("auto_event", autoEventToggle)

autoEventToggle:OnChanged(function(Value)
    autoEventRunning = Value
    currentAutoEvent = eventDropdown.Value
    
    if Value then
        WindUI:Notify({
            Title = "Auto Event Started",
            Description = "Watching for: " .. (currentAutoEvent or "Any Event"),
            Duration = 3,
            Icon = "play"
        })
        
        task.spawn(function()
            while autoEventRunning do
                if currentAutoEvent then
                    local pos = scanForEvent(currentAutoEvent)
                    if pos then
                        universalTeleport(pos)
                        WindUI:Notify({
                            Title = "Auto Teleport",
                            Description = "Found " .. currentAutoEvent,
                            Duration = 3,
                            Icon = "zap"
                        })
                    end
                end
                task.wait(UniversalConfig.ScanInterval)
            end
        end)
    else
        WindUI:Notify({
            Title = "Auto Event Stopped",
            Duration = 2,
            Icon = "stop"
        })
    end
end)

-- Settings Tab
local SettingsTab = Window:CreateTab({ Title = "⚙️ Settings", Icon = "settings" })

local ExecutorSection = SettingsTab:CreateSection("🔧 Executor Info")

ExecutorSection:CreateParagraph({
    Title = "Compatibility Info",
    Content = "Executor: " .. currentExecutor .. "\n" ..
             "Tier: " .. (isFreeTier and "Free" or "Premium") .. "\n" ..
             "Teleport Delay: " .. UniversalConfig.TeleportDelay .. "s\n" ..
             "Scan Interval: " .. UniversalConfig.ScanInterval .. "s"
})

local DebugSection = SettingsTab:CreateSection("🐛 Debug")

DebugSection:CreateToggle({
    Title = "Debug Mode",
    Description = "Show detailed logs in console",
    Default = false
}):OnChanged(function(Value)
    UniversalConfig.EnableDebugMode = Value
    print("[Debug] Debug mode:", Value and "ON" or "OFF")
end)

-- Final notification
WindUI:Notify({
    Title = "🎣 Fish It Universal Loaded!",
    Description = "Compatible with " .. currentExecutor .. " executor\n" .. 
                 (isFreeTier and "Free tier optimizations active" or "Premium features available"),
    Duration = 5,
    Icon = "check-circle"
})

print("=== 🎣 FISH IT UNIVERSAL SCRIPT LOADED ===")
print("Executor:", currentExecutor)
print("Free Tier:", isFreeTier)
print("All features loaded successfully!")
print("=== READY TO USE ===")
