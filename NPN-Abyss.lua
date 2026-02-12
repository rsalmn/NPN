--[[========================================
    NPN Hub - Abyss (FIXED FISH SOURCE)
    Data Source: workspace.Game.Fish.client
    Goal: TP → Face → StartCatching
==========================================]]

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Knit = ReplicatedStorage
    :WaitForChild("common")
    :WaitForChild("packages")
    :WaitForChild("Knit")

local Services = Knit:WaitForChild("Services")

local HarpoonService = Services
    :WaitForChild("HarpoonService")
    :WaitForChild("RF")

local MinigameService = Services
    :WaitForChild("MinigameService")
    :WaitForChild("RF")

local MinigameServiceRE = Services
    :WaitForChild("MinigameService")
    :WaitForChild("RE")

local SettingsService = Services
    :WaitForChild("SettingsService")
    :WaitForChild("RF")

local SellService = Services
    :WaitForChild("SellService")
    :WaitForChild("RF")

local BackpackService = Services
    :WaitForChild("BackpackService")
    :WaitForChild("RF")

-- UI
local FluxUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/rsalmn/FluxUI/refs/heads/main/FluxUI.lua"
))()

local Window = FluxUI:CreateWindow({
    Name = "NPN Hub - Abyss",
    Size = UDim2.new(0, 444, 0, 340),
    Theme = "Dark"
})

-- CONFIG
local MAX_RANGE = 150
local TELEPORT_DISTANCE = 10
local TELEPORT_DELAY = 0.25

local AutoTest = false
local Busy = false

local FOLLOW_DISTANCE = 9
local FOLLOW_TIMEOUT = 6
local FOLLOW_UPDATE = 0.1

local TP_STEP = 8          -- jarak per teleport (studs)
local TP_DELAY = 0.08     -- delay antar step
local TP_HEIGHT = 3

local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local MinigameDelay = 0.3 -- Delay sebelum auto-complete minigame (detik)
local OptimalMinibarPos = 0.2 -- Posisi optimal minibar (0-1, default 0.2 = zone tengah)
local MinibarMoveAmplitude = 999 -- Hardcoded max
local MinibarMoveFrequency = 999 -- Hardcoded max

local AutoSellEnabled = false
local AutoSellInterval = 30 -- detik (default)
local AutoSellBusy = false


-- UTILS
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Noclip utility for chest unlock
local NoclipEnabled = false
local NoclipConnection = nil

local function SetNoclip(enabled)
    NoclipEnabled = enabled
    
    if enabled then
        -- Enable noclip continuously
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if NoclipEnabled then
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        -- Disable noclip
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        
        -- Restore collisions
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- 🐟 GET FISH FROM CORRECT SOURCE
local function GetNearestFish()
    local hrp = getHRP()
    if not hrp then return end

    local gameFolder = workspace:FindFirstChild("Game")
    local fishFolder = gameFolder
        and gameFolder:FindFirstChild("Fish")
        and gameFolder.Fish:FindFirstChild("client")

    if not fishFolder then
        warn("Fish.client folder NOT FOUND")
        return
    end

    local nearest, closest = nil, MAX_RANGE

    for _, fishModel in pairs(fishFolder:GetChildren()) do
        if fishModel:IsA("Model") then
            local part = fishModel.PrimaryPart
                or fishModel:FindFirstChildWhichIsA("BasePart")

            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < closest then
                    closest = dist
                    nearest = {
                        Id = fishModel.Name,     -- 🔑 FISH ID
                        Object = fishModel,
                        Position = part.Position
                    }
                end
            end
        end
    end

    return nearest
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════
-- MINIGAME AUTOMATION (HYBRID METHOD!)
-- ════════════════════════════════════════════

-- Helper function to check if minigame is active
-- Simplifikasi:
local function IsMinigameActive()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    
    -- Cari GUI spesifik minigame (sesuaikan nama)
    local minigameGui = gui:FindFirstChild("MinigameGui") 
        or gui:FindFirstChild("FishingMinigame")
        or gui:FindFirstChild("ReelGui")
    
    return minigameGui and minigameGui.Enabled
end

-- INSTANT MODE: Fast sequential updates (Bypasses jump checks)
local function CompleteMinigame()
    task.spawn(function()
        -- Simulate mouse hold
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)

        local progress = 0
        local startTime = os.clock()
        
        while (os.clock() - startTime < 2) and IsMinigameActive() do
             -- Step 0.15 per 0.05s = ~0.33s total time (Very Fast but Sequential)
             progress = progress + 0.15
             if progress >= 1 then progress = 1 end
             
             -- Strategy: ProgressUpdate with EMPTY rewards (as per log)
             pcall(function()
                 MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                     progress = progress,
                     rewards = {}
                 })
             end)
             
             -- Fire RE for redundancy
             pcall(function()
                 MinigameServiceRE:WaitForChild("MinigameUpdated"):FireServer(progress)
             end)
             
             if progress >= 1 then break end
             task.wait(0.05)
        end
        
        -- Final completion ensure
        pcall(function()
             MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                 progress = 1,
                 rewards = {}
             })
        end)

        -- Release mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- ════════════════════════════════════════════
-- NEW MINIGAME BYPASS (POST-UPDATE FIX)
-- ════════════════════════════════════════════

local function CompleteMinigameNewMethod()
    task.spawn(function()
        print("🎣 Starting new minigame method...")
        
        -- Hold mouse button untuk simulate normal play
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        
        local currentProgress = 0
        local targetProgress = 1
        local maxAttempts = 200
        local attemptCount = 0
        
        -- Micro-increment system (seperti di spy log)
        while currentProgress < 0.98 and attemptCount < maxAttempts and IsMinigameActive() do
            attemptCount = attemptCount + 1
            
            -- Random increment antara 0.005 - 0.015 (mirip spy log)
            local increment = math.random(500, 1500) / 100000 -- 0.005 - 0.015
            currentProgress = currentProgress + increment
            
            -- Clamp progress
            if currentProgress > 0.98 then 
                currentProgress = 0.98 
            end
            
            -- Send update dengan progress micro-increment
            local success = pcall(function()
                MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                    progress = currentProgress,
                    rewards = {}
                })
            end)
            
            if not success then
                print("❌ MinigameService call failed at progress:", currentProgress)
            end
            
            -- Variable delay untuk avoid detection
            local delay = math.random(20, 80) / 1000 -- 0.02-0.08 detik
            task.wait(delay)
        end
        
        -- Final completion push
        task.wait(math.random(50, 150) / 1000)
        
        local finalSuccess = pcall(function()
            MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                progress = 1,
                rewards = {}
            })
        end)
        
        if finalSuccess then
            print("✅ Minigame completed successfully!")
        else
            print("❌ Final completion failed")
        end
        
        -- Release mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function GetNearestFishV2()
    local hrp = getHRP()
    if not hrp then return nil end

    local gameFolder = workspace:FindFirstChild("Game")
    local fishFolder = gameFolder and gameFolder:FindFirstChild("Fish")
    if not fishFolder then
        warn("❌ Game.Fish folder not found")
        return nil
    end
    
    local clientFolder = fishFolder:FindFirstChild("client")
    if not clientFolder then
        warn("❌ Fish.client folder not found")
        return nil
    end

    local nearest, closest = nil, MAX_RANGE
    local fishCount = 0

    for _, fishModel in pairs(clientFolder:GetChildren()) do
        if fishModel:IsA("Model") and fishModel.Name:match("^%w+$") then -- UUID pattern
            fishCount = fishCount + 1
            
            local part = fishModel.PrimaryPart or fishModel:FindFirstChildWhichIsA("BasePart")
            if part and part.Parent == fishModel then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < closest then
                    closest = dist
                    nearest = {
                        Id = fishModel.Name,
                        Object = fishModel,
                        Position = part.Position,
                        Distance = dist
                    }
                end
            end
        end
    end
    
    print(string.format("🐟 Found %d fish, nearest: %s (%.1f studs)", 
          fishCount, nearest and nearest.Id:sub(1,8).."..." or "none", closest))
    
    return nearest
end

local function StartCatchingV2(fishData)
    if not fishData then return false end
    
    print("🎣 Attempting to catch fish:", fishData.Id:sub(1,8).."...")
    
    -- Try different parameter formats
    local methods = {
        function() return HarpoonService:InvokeServer("StartCatching", fishData.Id) end,
        function() return HarpoonService:InvokeServer("StartCatching", fishData.Object) end,
        function() return HarpoonService:InvokeServer("StartCatching", {
            fishId = fishData.Id,
            position = fishData.Position
        }) end,
        function() return HarpoonService:InvokeServer("StartCatching", fishData.Id, fishData.Position) end
    }
    
    for i, method in ipairs(methods) do
        local success, result = pcall(method)
        if success then
            print("✅ StartCatching successful with method", i)
            return true
        else
            print("❌ Method", i, "failed:", result)
        end
    end
    
    return false
end

local function AutoFarmV2()
    task.spawn(function()
        print("🚀 Starting Auto Farm V2...")
        
        while AutoTest do
            if Busy then
                task.wait(0.5)
                continue
            end
            
            Busy = true
            
            -- Step 1: Find fish
            local fish = GetNearestFishV2()
            if not fish then
                print("⏳ No fish found, waiting...")
                Busy = false
                task.wait(3)
                continue
            end
            
            print("🎯 Target fish:", fish.Id:sub(1,8).."... at", math.floor(fish.Distance), "studs")
            
            -- Step 2: Teleport to fish
            local tpSuccess = StealthTeleportToFish(fish)
            if not tpSuccess then
                print("❌ Teleport failed")
                Busy = false
                task.wait(1)
                continue
            end
            
            task.wait(0.5) -- Stabilization delay
            
            -- Step 3: Start catching
            local catchSuccess = StartCatchingV2(fish)
            if not catchSuccess then
                print("❌ StartCatching failed")
                Busy = false
                task.wait(2)
                continue
            end
            
            print("🎣 Fishing started, waiting for minigame...")
            
            -- Step 4: Wait for minigame
            local minigameTimeout = 0
            while not IsMinigameActive() and minigameTimeout < 50 do -- 5 detik timeout
                task.wait(0.1)
                minigameTimeout = minigameTimeout + 1
            end
            
            if IsMinigameActive() then
                print("🎮 Minigame detected!")
                task.wait(math.random(200, 500) / 1000) -- Random delay sebelum complete
                CompleteMinigameNewMethod()
                
                -- Wait for minigame completion
                local completionTimeout = 0
                while IsMinigameActive() and completionTimeout < 30 do
                    task.wait(0.1)
                    completionTimeout = completionTimeout + 1
                end
                
                if completionTimeout >= 30 then
                    print("⚠️ Minigame timeout, might need manual intervention")
                end
            else
                print("⚠️ Minigame didn't start within timeout")
            end
            
            Busy = false
            
            -- Cooldown between catches
            local cooldown = math.random(1000, 2500) / 1000 -- 1-2.5 detik
            print(string.format("💤 Cooldown %.1fs", cooldown))
            task.wait(cooldown)
        end
        
        print("🛑 Auto Farm V2 stopped")
    end)
end


-- LEGIT MODE: Random progressive updates with correct protocol
-- Gunakan HANYA CompleteMinigameLegit dengan perbaikan:
local function CompleteMinigameLegit()
    task.spawn(function()
        local progress = 0
        local baseDelay = 0.15
        
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(math.random(80, 150) / 1000) -- Random initial delay
        
        while progress < 0.92 and IsMinigameActive() do
            -- Random increment 5-12%
            local increment = math.random(5, 12) / 100
            progress = progress + increment
            if progress > 0.92 then progress = 0.92 end
            
            pcall(function()
                MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                    progress = progress,
                    rewards = {}
                })
            end)
            
            -- Variable delay dengan noise
            local delay = baseDelay + math.random(-30, 50) / 1000
            task.wait(delay)
        end
        
        -- Final completion dengan delay
        task.wait(math.random(100, 200) / 1000)
        pcall(function()
            MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                progress = 1,
                rewards = {}
            })
        end)
        
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- AUTO MODE: Full auto with continuous hold
local function CompleteMinigameAuto()
    task.spawn(function()
        -- Hold mouse button
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        
        local updateCount = 0
        
        -- Keep holding and updating while minigame is active
        while IsMinigameActive() and updateCount < 50 do
            task.wait(0.1)
            
            -- Send progress update every loop
            pcall(function()
                local prog = math.min(0.1 + (updateCount * 0.05), 1)
                MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                    progress = prog,
                    rewards = {}
                })
            end)
            
            updateCount = updateCount + 1
            
            -- Force complete after enough attempts
            if updateCount >= 20 then
                pcall(function()
                    MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                        progress = 1,
                        rewards = {}
                    })
                end)
                task.wait(0.2)
                break
            end
        end
        
        -- Release mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- BLATANT MODE: Maximum speed sequential updates (Clean Protocol)
local function CompleteMinigameBlatant()
    task.spawn(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        
        local progress = 0
        local startTime = os.clock()
        
        -- Super fast loop (max 0.4s total)
        while (os.clock() - startTime < 0.5) and IsMinigameActive() do
            progress = progress + 0.25 -- 4 steps to finish
            if progress >= 1 then progress = 1 end
            
            pcall(function()
                MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                    progress = progress,
                    rewards = {}
                })
            end)
            
            if progress >= 1 then break end
            task.wait(0.03) -- 30ms delay
        end
        
        -- Final ensure
        pcall(function()
            MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
                 progress = 1,
                 rewards = {}
            })
        end)

        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Alternative minigame complete methods (untuk debugging)
local function TryAllMinigameMethods()
    local results = {}
    
    -- Method 1: ACTUAL SPY METHOD
    local ok1 = pcall(function()
        MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
            progress = 1,
            rewards = {}
        })
    end)
    table.insert(results, "M1(SPY METHOD - ProgressUpdate): " .. tostring(ok1))
    
    -- Method 2: Dengan rewards yang ada value
    local ok2 = pcall(function()
        MinigameService:WaitForChild("Update"):InvokeServer("ProgressUpdate", {
            progress = 1,
            rewards = {{progress = 0, pos = 0.5}}
        })
    end)
    table.insert(results, "M2(ProgressUpdate + rewards): " .. tostring(ok2))
    
    -- Method 3: MinigameUpdated (RemoteEvent)
    local ok3 = pcall(function()
        MinigameServiceRE:WaitForChild("MinigameUpdated"):FireServer(1)
    end)
    table.insert(results, "M3(MinigameUpdated RE): " .. tostring(ok3))
    
    -- Method 4: Direct value
    local ok4 = pcall(function()
        MinigameService:WaitForChild("Update"):InvokeServer(1)
    end)
    table.insert(results, "M4(Direct value): " .. tostring(ok4))
    
    return results
end

-- Mode selection
local MinigameMode = "Auto" -- Auto | Instant | Legit | Blatant

local function HandleMinigame()
    if MinigameMode == "Legit" then
        CompleteMinigameLegit()
    elseif MinigameMode == "Instant" then
        CompleteMinigame()
    elseif MinigameMode == "Blatant" then
        CompleteMinigameBlatant()
    else
        CompleteMinigameAuto()
    end
end

local function StealthTeleportToFish(fish)
    local char = LocalPlayer.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local part = fish.Object.PrimaryPart
        or fish.Object:FindFirstChildWhichIsA("BasePart")
    if not part then 
        warn("Fish object has no valid part")
        return false 
    end

    -- Implementasi teleport step-by-step
    local targetPos = part.Position
    local currentPos = hrp.Position
    local distance = (targetPos - currentPos).Magnitude
    
    local steps = math.ceil(distance / TP_STEP)
    
    for i = 1, steps do
        if not AutoTest then break end
        
        local alpha = i / steps
        local newPos = currentPos:Lerp(targetPos, alpha)
        newPos = Vector3.new(newPos.X, newPos.Y + TP_HEIGHT, newPos.Z)
        
        hrp.CFrame = CFrame.new(newPos)
        task.wait(TP_DELAY)
    end
    
    -- Final positioning di depan ikan
    local lookAt = CFrame.new(hrp.Position, targetPos)
    hrp.CFrame = lookAt * CFrame.new(0, 0, -FOLLOW_DISTANCE)
    
    return true
end

local function SwimToFish(fish)
    local char = LocalPlayer.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end

    local startTime = tick()

    while tick() - startTime < FOLLOW_TIMEOUT do
        if not fish.Object or not fish.Object.Parent then
            hum:Move(Vector3.zero, true)
            return false
        end

        local part = fish.Object.PrimaryPart
            or fish.Object:FindFirstChildWhichIsA("BasePart")
        if not part then return false end

        local offset = part.Position - hrp.Position
        local dist = offset.Magnitude

        if dist <= FOLLOW_DISTANCE then
            hum:Move(Vector3.zero, true)
            return true
        end

        -- 🔥 INI KUNCINYA
        local direction = offset.Unit
        hum:Move(direction, true)

        task.wait(FOLLOW_UPDATE)
    end

    hum:Move(Vector3.zero, true)
    return false
end


-- TELEPORT NEAR FISH
local function TeleportToFish(fish)
    local hrp = getHRP()
    if not hrp then return false end

    local part = fish.Object.PrimaryPart
        or fish.Object:FindFirstChildWhichIsA("BasePart")

    if not part then return false end

    local dir = (part.Position - hrp.Position).Unit
    local targetPos = part.Position - (dir * TELEPORT_DISTANCE)

    hrp.CFrame = CFrame.new(
        Vector3.new(targetPos.X, part.Position.Y + 4, targetPos.Z),
        part.Position
    )

    return true
end

local FishService
pcall(function()
    FishService = Services:WaitForChild("FishService"):WaitForChild("RF")
end)

local function CollectFish(fishId)
    if FishService then
        pcall(function()
            FishService:WaitForChild("CollectFish"):InvokeServer(fishId)
        end)
    end
end

-- 🎯 START CATCHING (ACTUAL HIT)
local function ShootFish(fish)
    local hrp = getHRP()
    if not hrp then return false end

    -- Face fish (important)
    hrp.CFrame = CFrame.new(hrp.Position, fish.Position)

    -- Check AutoTest BEFORE blocking server call
    if not AutoTest then return false end

    local ok, err = pcall(function()
        HarpoonService:WaitForChild("StartCatching"):InvokeServer(fish.Id)
    end)

    if ok and AutoTest then
        task.wait(MinigameDelay) -- Delay sebelum complete minigame
        if not AutoTest then return ok end -- Check again after delay
        HandleMinigame() -- Use selected mode (Auto/Instant/Legit/Blatant)

        task.wait(0.1)
        if AutoTest then
            CollectFish(fish.Id)
        end
    end

    return ok
end

local function DoSell()
    if AutoSellBusy then return end
    AutoSellBusy = true

    pcall(function()
        -- Update server autosell flag (biar sinkron)
        SettingsService:WaitForChild("UpdateAutoSell"):InvokeServer(true)
    end)

    task.wait(0.1)

    pcall(function()
        -- Jual semua ikan
        SellService:WaitForChild("SellFish"):InvokeServer()
    end)

    task.wait(0.1)

    pcall(function()
        -- Cleanup inventory
        SellService:WaitForChild("SellInventory"):InvokeServer()
    end)

    AutoSellBusy = false
end

task.spawn(function()
    while true do
        if AutoSellEnabled then
            DoSell()
            task.wait(AutoSellInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- AUTO TEST LOOP
local function AutoLoop()
    if Busy then return end
    Busy = true

    task.spawn(function()
        while AutoTest do
            -- Check before finding fish
            if not AutoTest then break end

            local fish = GetNearestFish()
            if fish then
                -- Check before TP
                if not AutoTest then break end

                if StealthTeleportToFish(fish) then
                    -- Check after TP, before shooting
                    if not AutoTest then break end
					ShootFish(fish)
				else
					if not AutoTest then break end
					warn("Failed to reach fish safely")
				end
            else
                warn("No fish found in Fish.client")
            end

            -- Check before waiting
            if not AutoTest then break end
            task.wait(0.6)
        end
        Busy = false
    end)
end

-- UI
do
    local FishingTab = Window:CreateTab("Fishing")

    -- ═══════════════════════════════════════
    -- Collapsible: Auto Fishing
    -- ═══════════════════════════════════════
    do
        local AutoFishingCollapsible = FishingTab:CreateCollapsible({
            Name = "🎣 Auto Fishing",
            DefaultOpen = true
        })

        -- Mode Selection
        AutoFishingCollapsible:AddDropdown({
            Name = "Minigame Mode",
            Options = {"Auto", "Instant", "Legit", "Blatant"},
            Default = MinigameMode,
            Callback = function(v)
                MinigameMode = v
                Window:Notify({
                    Title = "Minigame Mode",
                    Content = "Mode set to: " .. v,
                    Duration = 2,
                    Type = "Success"
                })
            end
        })

        AutoFishingCollapsible:AddTextbox({
            Name = "Minigame Delay (sec)",
            PlaceholderText = tostring(MinigameDelay),
            Callback = function(v)
                local n = tonumber(v)
                if n and n >= 0 then 
                    MinigameDelay = n 
                    Window:Notify({
                        Title = "Minigame Delay",
                        Content = "Set to " .. n .. " seconds",
                        Duration = 2,
                        Type = "Success"
                    })
                end
            end
        })

        AutoFishingCollapsible:AddTextbox({
            Name = "Minibar Position (Legit Mode)",
            PlaceholderText = tostring(OptimalMinibarPos) .. " (0.15-0.25 recommended)",
            Callback = function(v)
                local n = tonumber(v)
                if n and n >= 0 and n <= 1 then 
                    OptimalMinibarPos = n 
                    Window:Notify({
                        Title = "Minibar Position",
                        Content = "Set to " .. n .. " (0=top, 1=bottom)",
                        Duration = 3,
                        Type = "Success"
                    })
                else
                    Window:Notify({
                        Title = "Invalid Value",
                        Content = "Enter number between 0-1",
                        Duration = 2,
                        Type = "Error"
                    })
                end
            end
        })

        AutoFishingCollapsible:AddDivider()

        -- ── Inventory Weight Auto-Return ──
        local WeightTargetKg = 50
        local AutoWeightReturnEnabled = false
        local SellDelaySeconds = 0

        AutoFishingCollapsible:AddTextbox({
            Name = "Weight Target (kg) - Auto Return",
            PlaceholderText = "50 (return to safezone when reached)",
            Callback = function(v)
                local n = tonumber(v)
                if n and n > 0 then
                    WeightTargetKg = n
                    Window:Notify({
                        Title = "Weight Target",
                        Content = "Will return to safezone at " .. n .. " kg",
                        Duration = 2,
                        Type = "Success"
                    })
                end
            end
        })

        AutoFishingCollapsible:AddTextbox({
            Name = "Sell Delay (seconds)",
            PlaceholderText = "1 (stay near Kraken after sell)",
            Callback = function(v)
                local n = tonumber(v)
                if n and n >= 0 then
                    SellDelaySeconds = n
                    Window:Notify({
                        Title = "Sell Delay",
                        Content = "Delay set to " .. n .. " seconds",
                        Duration = 2,
                        Type = "Success"
                    })
                end
            end
        })

        AutoFishingCollapsible:AddDivider()
        
        -- Auto Sell Filters
        local RarityOrder = {
            ["Common"] = 1,
            ["Uncommon"] = 2,
            ["Rare"] = 3,
            ["Epic"] = 4,
            ["Legendary"] = 5,
            ["Mythic"] = 6,
            ["Exotic"] = 7,
            ["Secret"] = 8
        }
        local SellFilterMode = "Off (Sell All)"
        local SellFilterOptions = {"Off (Sell All)", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}

        AutoFishingCollapsible:AddDropdown({
            Name = "Auto Sell Mode (Sells selected & below)",
            Options = SellFilterOptions,
            Default = "Off (Sell All)",
            Callback = function(v)
                SellFilterMode = v
            end
        })

        AutoFishingCollapsible:AddToggle({
            Name = "Auto Sell (Enable to use filters)",
            Default = false,
            Callback = function(v)
                AutoSellEnabled = v
                Window:Notify({
                    Title = "Auto Sell",
                    Content = v and "Enabled" or "Disabled",
                    Duration = 2,
                    Type = "Default"
                })
            end
        })

        AutoFishingCollapsible:AddToggle({
            Name = "Auto Return When Full",
            Default = false,
            Callback = function(v)
                AutoWeightReturnEnabled = v
                Window:Notify({
                    Title = "Weight Auto-Return",
                    Content = v and ("Enabled - Return at " .. WeightTargetKg .. " kg") or "Disabled",
                    Duration = 2,
                    Type = v and "Success" or "Warning"
                })

                if v then
                    task.spawn(function()
                        while AutoWeightReturnEnabled do
                            local shouldSellAndResume = false
                            pcall(function()
                                local character = Players.LocalPlayer.Character
                                if not character then return end

                                -- Get inventory weight from player's backpack/inventory
                                local currentWeight = 0
                                pcall(function()
                                    currentWeight = character:GetAttribute("inventoryweight") or character:GetAttribute("weight") or 0
                                end)

                                -- Fallback: scan backpack
                                if currentWeight == 0 then
                                    pcall(function()
                                        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                                        if backpack then
                                            for _, tool in pairs(backpack:GetChildren()) do
                                                local w = tool:GetAttribute("weight") or 0
                                                currentWeight = currentWeight + w
                                            end
                                        end
                                    end)
                                end

                                -- Check if weight target reached
                                if currentWeight >= WeightTargetKg then
                                    -- Step 1: Stop auto fish
                                    AutoTest = false
                                    task.wait(0.5)

                                    -- Step 2: Teleport to Kraken NPC
                                    pcall(function()
                                        local hrp = character:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            local npcFolder = workspace:FindFirstChild("Game")
                                            if npcFolder then npcFolder = npcFolder:FindFirstChild("Interactables") end
                                            if npcFolder then npcFolder = npcFolder:FindFirstChild("Npc") end

                                            local target = nil
                                            if npcFolder then
                                                target = npcFolder:FindFirstChild("Kraken") or npcFolder:FindFirstChild("kraken")
                                                if not target then
                                                    for _, npc in pairs(npcFolder:GetChildren()) do
                                                        if npc.Name:lower():find("sell") or npc.Name:lower():find("shop") then
                                                            target = npc
                                                            break
                                                        end
                                                    end
                                                end
                                            end

                                            if target then
                                                local part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                                                if part then
                                                    hrp.CFrame = part.CFrame * CFrame.new(0, 0, 10)
                                                end
                                            end
                                        end
                                    end)

                                    Window:Notify({
                                        Title = "Weight Limit Reached!",
                                        Content = string.format("Weight: %.1f kg - Teleported to Kraken!", currentWeight),
                                        Duration = 3,
                                        Type = "Warning"
                                    })

                                    -- Step 3: Wait custom delay
                                    if SellDelaySeconds > 0 then
                                        Window:Notify({
                                            Title = "Sell Delay",
                                            Content = "Waiting " .. SellDelaySeconds .. "s near Kraken...",
                                            Duration = SellDelaySeconds,
                                            Type = "Default"
                                        })
                                        task.wait(SellDelaySeconds)
                                    else
                                        task.wait(0.5)
                                    end

                                    -- Step 4: Auto sell
                                    if AutoSellEnabled then
                                        local soldCount = 0
                                        
                                        if SellFilterMode ~= "Off (Sell All)" then
                                            -- Rarity Filter Mode
                                            pcall(function()
                                                local DataController = require(ReplicatedStorage.common.source.controllers.DataController)
                                                local replica = DataController:GetReplica()
                                                if replica and replica.Data and replica.Data.inventory then
                                                    local inventory = replica.Data.inventory
                                                    local presets = ReplicatedStorage.common.presets
                                                    local itemsFolder = presets and presets:FindFirstChild("items")
                                                    
                                                    if itemsFolder then
                                                        local maxSellVal = RarityOrder[SellFilterMode] or 0
                                                        
                                                        for uuid, item in pairs(inventory) do
                                                            -- Check favorited/locked
                                                            if not item.favorited and not item.locked then
                                                                local rarity = "Common"
                                                                local itemConfig = nil
                                                                for _, cat in pairs(itemsFolder:GetChildren()) do
                                                                    local found = cat:FindFirstChild(item.id)
                                                                    if found then
                                                                        itemConfig = require(found)
                                                                        break
                                                                    end
                                                                end
                                                                if itemConfig and itemConfig.rarity then
                                                                    rarity = itemConfig.rarity
                                                                end
                                                                
                                                                local itemRarityVal = RarityOrder[rarity] or 0
                                                                
                                                                if itemRarityVal <= maxSellVal then
                                                                    SellService:WaitForChild("SellFish"):InvokeServer(uuid)
                                                                    soldCount = soldCount + 1
                                                                    task.wait(0.05) -- prevent flood
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end)
                                            if soldCount > 0 then
                                                Window:Notify({
                                                    Title = "Filtered Sell", 
                                                    Content = "Sold " .. soldCount .. " items (<= " .. SellFilterMode .. ")", 
                                                    Duration = 2, 
                                                    Type = "Success"
                                                })
                                            end
                                        else
                                            -- Sell All Mode
                                            pcall(function()
                                                SellService:WaitForChild("SellInventory"):InvokeServer()
                                            end)
                                            Window:Notify({
                                                Title = "Auto Sell", 
                                                Content = "Sell All command sent!", 
                                                Duration = 2, 
                                                Type = "Success"
                                            })
                                        end

                                        -- Step 5: Verify and resume
                                        task.wait(2)
                                        shouldSellAndResume = true
                                    end
                                end
                            end)

                            -- Resume auto fish outside pcall scope
                            if shouldSellAndResume then
                                Busy = false
                                AutoTest = true
                                AutoLoop()
                                Window:Notify({
                                    Title = "Auto Fish Resumed",
                                    Content = "Back to fishing! Monitoring weight again...",
                                    Duration = 3,
                                    Type = "Success"
                                })
                            end

                            task.wait(3) -- Check every 3 seconds
                        end
                    end)
                end
            end
        })

        AutoFishingCollapsible:AddButton({
            Name = "Check Current Weight",
            Callback = function()
                local weight = 0
                pcall(function()
                    local character = Players.LocalPlayer.Character
                    if character then
                        weight = character:GetAttribute("inventoryweight") or character:GetAttribute("weight") or 0
                    end
                end)

                -- Also try backpack scan
                if weight == 0 then
                    pcall(function()
                        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                        if backpack then
                            for _, tool in pairs(backpack:GetChildren()) do
                                weight = weight + (tool:GetAttribute("weight") or 0)
                            end
                        end
                    end)
                end

                Window:Notify({
                    Title = "Inventory Weight",
                    Content = string.format("Current: %.1f kg / Target: %.1f kg", weight, WeightTargetKg),
                    Duration = 3,
                    Type = weight >= WeightTargetKg and "Warning" or "Success"
                })
            end
        })

        AutoFishingCollapsible:AddDivider()

        AutoFishingCollapsible:AddToggle({
            Name = "🎯 Auto Fish",
            Default = false,
            Callback = function(v)
                AutoTest = v
                if v then
                    Busy = false -- Reset busy flag so AutoLoop can start fresh
                    AutoLoop()
                else
                    -- Force stop: reset Busy so next enable works
                    Busy = false
                end
                Window:Notify({
                    Title = "Auto Fish",
                    Content = v and "Enabled" or "Disabled - Stopping...",
                    Duration = 2,
                    Type = v and "Success" or "Warning"
                })
            end
        })
    end

    -- ═══════════════════════════════════════
    -- 🌟 AUTO FAVORITE
    -- ═══════════════════════════════════════
    do
        local FavoriteCollapsible = FishingTab:CreateCollapsible({
            Name = "🌟 Auto Favorite",
            DefaultOpen = false
        })
        
        local AutoFavoriteEnabled = false
        local FavoriteRarities = {
            ["Common"] = false,
            ["Uncommon"] = false,
            ["Rare"] = false,
            ["Epic"] = false,
            ["Legendary"] = true,
            ["Mythic"] = true,
            ["Exotic"] = true,
            ["Secret"] = true,
        }

        FavoriteCollapsible:AddToggle({
            Name = "Active",
            Default = false,
            Callback = function(v)
                AutoFavoriteEnabled = v
                if v then
                    task.spawn(function()
                        while AutoFavoriteEnabled do
                            pcall(function()
                                -- Get Inventory Data
                                local DataController = require(ReplicatedStorage.common.source.controllers.DataController)
                                local replica = DataController:GetReplica()
                                
                                if replica and replica.Data and replica.Data.inventory then
                                    local inventory = replica.Data.inventory
                                    
                                    -- Load Item Data just once per loop
                                    local presets = ReplicatedStorage.common.presets
                                    local itemsFolder = presets and presets:FindFirstChild("items")
                                    
                                    if itemsFolder then
                                        for uuid, item in pairs(inventory) do
                                            if not AutoFavoriteEnabled then break end
                                            
                                            -- Check if already favorited
                                            if not item.favorited then
                                                -- Find Item Rarity
                                                local rarity = "Common" -- default
                                                
                                                -- Search for item config in presets
                                                local itemConfig = nil
                                                
                                                -- Scan categories to find item
                                                for _, cat in pairs(itemsFolder:GetChildren()) do
                                                    local found = cat:FindFirstChild(item.id)
                                                    if found then
                                                        itemConfig = require(found)
                                                        break
                                                    end
                                                end
                                                
                                                if itemConfig and itemConfig.rarity then
                                                    rarity = itemConfig.rarity
                                                end
                                                
                                                -- Check if this rarity is enabled
                                                if FavoriteRarities[rarity] then
                                                    -- Favorite it!
                                                    BackpackService:InvokeServer("Favorite", uuid, true)
                                                    print("🌟 Auto Favorite: " .. item.id .. " (" .. rarity .. ")")
                                                    task.wait(0.1) -- gentle delay
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(3) -- Check every 3 seconds
                        end
                    end)
                end
            end
        })

        FavoriteCollapsible:AddDivider()

        local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic", "Secret"}
        for _, r in ipairs(rarities) do
            FavoriteCollapsible:AddToggle({
                Name = "Favorite " .. r,
                Default = FavoriteRarities[r],
                Callback = function(v)
                    FavoriteRarities[r] = v
                end
            })
        end
    end
end

-- ═══════════════════════════════════════
-- Auto Tab
-- ═══════════════════════════════════════
do
    local AutoTab = Window:CreateTab("Auto")

    -- ── Auto Sell ──
    local AutoSellCollapsible = AutoTab:CreateCollapsible({
        Name = "Auto Sell",
        DefaultOpen = false
    })

    -- Sell functions using SellService remotes
    local function DoSellInventory()
        local success, result = pcall(function()
            return SellService:WaitForChild("SellInventory"):InvokeServer()
        end)
        return success, result
    end

    local function DoSellFish()
        local success, result = pcall(function()
            return SellService:WaitForChild("SellFish"):InvokeServer()
        end)
        return success, result
    end

    local function DoSellAll()
        local s1, r1 = DoSellInventory()
        local s2, r2 = DoSellFish()
        return s1 or s2, tostring(r1) .. " | " .. tostring(r2)
    end
    
    AutoSellCollapsible:AddToggle({
        Name = "Enable Auto Sell",
        Default = false,
        Callback = function(v)
            AutoSellEnabled = v
            -- Also tell game's built-in auto sell
            pcall(function()
                SettingsService:WaitForChild("UpdateAutoSell"):InvokeServer(v)
            end)
            Window:Notify({
                Title = "Auto Sell",
                Content = v and "Enabled" or "Disabled",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })

            -- Auto sell loop
            if v then
                task.spawn(function()
                    while AutoSellEnabled do
                        task.wait(AutoSellInterval)
                        if not AutoSellEnabled then break end
                        if not AutoSellBusy then
                            AutoSellBusy = true
                            local success = pcall(function()
                                DoSellAll()
                            end)
                            AutoSellBusy = false
                        end
                    end
                end)
            end
        end
    })

    AutoSellCollapsible:AddTextbox({
        Name = "Sell Interval (seconds)",
        PlaceholderText = tostring(AutoSellInterval),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 5 then
                AutoSellInterval = math.floor(n)
                Window:Notify({
                    Title = "Auto Sell Interval",
                    Content = "Interval set to " .. AutoSellInterval .. " seconds",
                    Duration = 2,
                    Type = "Success"
                })
            end
        end
    })

    -- ── Auto Unlock Chest ──
    local ChestCollapsible = AutoTab:CreateCollapsible({
        Name = "Unlock Chest",
        DefaultOpen = false
    })

    local AutoChestEnabled = false

    local ChestTiers = {"Tier 1", "Tier 2", "Tier 3", "All Tiers"}
    local SelectedChestTier = "Tier 1"

    ChestCollapsible:AddDropdown({
        Name = "Select Tier",
        Options = ChestTiers,
        Default = "Tier 1",
        Callback = function(selected)
            SelectedChestTier = selected
            Window:Notify({
                Title = "Chest Tier",
                Content = "Selected: " .. selected,
                Duration = 2,
                Type = "Default"
            })
        end
    })

    ChestCollapsible:AddToggle({
        Name = "Auto Unlock Chests",
        Default = false,
        Callback = function(v)
            AutoChestEnabled = v
            
            -- Enable/Disable Noclip
            SetNoclip(v)
            
            Window:Notify({
                Title = "Auto Chest",
                Content = v and ("Enabled for " .. SelectedChestTier .. " (Noclip: ON)") or "Disabled (Noclip: OFF)",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })

            if v then
                task.spawn(function()
                    while AutoChestEnabled do
                        local chestsFound = 0
                        local chestsClaimed = 0
                        
                        pcall(function()
                            local char = Players.LocalPlayer.Character
                            if not char then return end
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if not hrp then return end
                            
                            -- Find chests in workspace.Game.Chests
                            local chestsFolder = workspace:FindFirstChild("Game")
                            if chestsFolder then
                                chestsFolder = chestsFolder:FindFirstChild("Chests")
                            end
                            
                            -- GATE UNLOCK INTEGRATION
                            pcall(function()
                                local gatesFolder = workspace.Game:FindFirstChild("Gates")
                                if gatesFolder then
                                    local GateService = Services:WaitForChild("GateService"):WaitForChild("RF")
                                    
                                    local function checkGate(model)
                                        if model then
                                            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                                            if part and (part.Position - hrp.Position).Magnitude < 150 then
                                                GateService:InvokeServer("Unlock", model)
                                            end
                                        end
                                    end
                                    
                                    -- Check Pirate Gate
                                    checkGate(gatesFolder:FindFirstChild("Pirate"))
                                    
                                    -- Check Tier 3 Gates
                                    local t3 = gatesFolder:FindFirstChild("Tier 3 Chests")
                                    if t3 then
                                        for _, g in pairs(t3:GetChildren()) do
                                            checkGate(g)
                                        end
                                    end
                                end
                            end)
                            
                            if not chestsFolder then
                                Window:Notify({
                                    Title = "Auto Chest",
                                    Content = "Chests folder not found in workspace!",
                                    Duration = 3,
                                    Type = "Error"
                                })
                                return
                            end
                            
                            -- Determine which tiers to process
                            local tiersToProcess = {}
                            if SelectedChestTier == "All Tiers" then
                                tiersToProcess = {"Tier 1", "Tier 2", "Tier 3"}
                            else
                                tiersToProcess = {SelectedChestTier}
                            end
                            
                            -- Process each tier
                            for _, tierName in ipairs(tiersToProcess) do
                                if not AutoChestEnabled then break end
                                
                                local tierFolder = chestsFolder:FindFirstChild(tierName)
                                if tierFolder then
                                    -- Iterate through all chest IDs in this tier
                                    for _, chestContainer in pairs(tierFolder:GetChildren()) do
                                        if not AutoChestEnabled then break end
                                        
                                        chestsFound = chestsFound + 1
                                        
                                        -- Find the Chest model inside container
                                        local chestModel = chestContainer:FindFirstChild("Chest")
                                        if chestModel then
                                            -- Navigate to ProximityPrompt: Chest.Main.BottomChest.RewardPart.Prompt
                                            local prompt = nil
                                            pcall(function()
                                                local main = chestModel:FindFirstChild("Main")
                                                if main then
                                                    local bottomChest = main:FindFirstChild("BottomChest")
                                                    if bottomChest then
                                                        local rewardPart = bottomChest:FindFirstChild("RewardPart")
                                                        if rewardPart then
                                                            prompt = rewardPart:FindFirstChild("Prompt")
                                                        end
                                                    end
                                                end
                                            end)
                                            
                                            if prompt and prompt:IsA("ProximityPrompt") then
                                                -- Chest not yet unlocked - teleport and claim
                                                local chestPart = chestModel.PrimaryPart or chestModel:FindFirstChildWhichIsA("BasePart", true)
                                                if chestPart then
                                                    -- Calculate target position (in front of chest)
                                                    local targetCFrame = chestPart.CFrame * CFrame.new(0, 2, 5)
                                                    
                                                    -- Slower tween for human-like movement (anti-kick)
                                                    local tweenInfo = TweenInfo.new(
                                                        2.5, -- 2.5 seconds (much slower, more natural)
                                                        Enum.EasingStyle.Sine, -- Smoother easing
                                                        Enum.EasingDirection.InOut
                                                    )
                                                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                                                    tween:Play()
                                                    tween.Completed:Wait() -- Wait for tween to complete
                                                    
                                                    task.wait(0.3) -- Brief wait for position to register
                                                    
                                                    -- Fire ProximityPrompt to claim chest
                                                    pcall(function()
                                                        fireproximityprompt(prompt)
                                                    end)
                                                    
                                                    chestsClaimed = chestsClaimed + 1
                                                    
                                                    -- Wait 2 seconds near chest after claim (for reward collection)
                                                    task.wait(2)
                                                end
                                            else
                                                -- No prompt = already unlocked, skip
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        
                        -- Summary notification
                        if chestsFound > 0 then
                            Window:Notify({
                                Title = "Auto Chest Complete",
                                Content = string.format("Claimed %d/%d chests in %s. Re-checking in 20s...", 
                                    chestsClaimed, chestsFound, SelectedChestTier),
                                Duration = 4,
                                Type = "Success"
                            })
                        else
                            Window:Notify({
                                Title = "Auto Chest",
                                Content = "No chests found for " .. SelectedChestTier .. ". Re-checking in 20s...",
                                Duration = 3,
                                Type = "Warning"
                            })
                        end
                        
                        task.wait(20) -- Re-check every 20 seconds
                    end
                end)
            end
        end
    })

    ChestCollapsible:AddButton({
        Name = "Claim All Chests (Selected Tier) - Once",
        Callback = function()
            task.spawn(function()
                local chestsFound = 0
                local chestsClaimed = 0
                
                Window:Notify({
                    Title = "Chest Claim",
                    Content = "Claiming chests in " .. SelectedChestTier .. "... (Noclip: ON)",
                    Duration = 2,
                    Type = "Default"
                })
                
                -- Enable noclip for manual claim
                SetNoclip(true)
                
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    local chestsFolder = workspace:FindFirstChild("Game")
                    if chestsFolder then chestsFolder = chestsFolder:FindFirstChild("Chests") end
                    if not chestsFolder then return end
                    
                    local tiersToProcess = {}
                    if SelectedChestTier == "All Tiers" then
                        tiersToProcess = {"Tier 1", "Tier 2", "Tier 3"}
                    else
                        tiersToProcess = {SelectedChestTier}
                    end
                    
                    for _, tierName in ipairs(tiersToProcess) do
                        local tierFolder = chestsFolder:FindFirstChild(tierName)
                        if tierFolder then
                            for _, chestContainer in pairs(tierFolder:GetChildren()) do
                                chestsFound = chestsFound + 1
                                
                                local chestModel = chestContainer:FindFirstChild("Chest")
                                if chestModel then
                                    local prompt = nil
                                    pcall(function()
                                        prompt = chestModel.Main.BottomChest.RewardPart:FindFirstChild("Prompt")
                                    end)
                                    
                                    if prompt and prompt:IsA("ProximityPrompt") then
                                        local chestPart = chestModel.PrimaryPart or chestModel:FindFirstChildWhichIsA("BasePart", true)
                                        if chestPart then
                                            -- Calculate target position
                                            local targetCFrame = chestPart.CFrame * CFrame.new(0, 2, 5)
                                            
                                            -- Slower tween for human-like movement
                                            local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                                            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                                            tween:Play()
                                            tween.Completed:Wait()
                                            
                                            task.wait(0.3)
                                            
                                            pcall(function()
                                                fireproximityprompt(prompt)
                                            end)
                                            
                                            chestsClaimed = chestsClaimed + 1
                                            task.wait(2) -- Wait 2 seconds after claim
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                
                -- Disable noclip after manual claim
                SetNoclip(false)
                
                Window:Notify({
                    Title = "Chest Claim Complete",
                    Content = string.format("Claimed %d/%d chests in %s! (Noclip: OFF)", chestsClaimed, chestsFound, SelectedChestTier),
                    Duration = 4,
                    Type = "Success"
                })
            end)
        end
    })



    -- ── Auto Daily Rewards ──
    local DailyCollapsible = AutoTab:CreateCollapsible({
        Name = "Daily Rewards",
        DefaultOpen = false
    })

    DailyCollapsible:AddButton({
        Name = "Claim Daily Reward",
        Callback = function()
            local success, result = pcall(function()
                local DailyService = Services:WaitForChild("DailyRewardService")
                return DailyService:WaitForChild("RF"):WaitForChild("Claim"):InvokeServer()
            end)
            Window:Notify({
                Title = "Daily Reward",
                Content = success and "Claimed!" or ("Failed: " .. tostring(result)),
                Duration = 3,
                Type = success and "Success" or "Error"
            })
        end
    })

    -- ── Code Redeemer ──
    local CodeCollapsible = AutoTab:CreateCollapsible({
        Name = "Code Redeemer",
        DefaultOpen = false
    })

    local RedeemCodeInput = ""

    CodeCollapsible:AddTextbox({
        Name = "Enter Code",
        PlaceholderText = "Enter redeem code here",
        Callback = function(text)
            RedeemCodeInput = text
        end
    })

    CodeCollapsible:AddButton({
        Name = "Redeem Code",
        Callback = function()
            if RedeemCodeInput == "" then
                Window:Notify({
                    Title = "Code Redeemer",
                    Content = "Please enter a code first!",
                    Duration = 2,
                    Type = "Error"
                })
                return
            end

            local success, result = pcall(function()
                return SettingsService:WaitForChild("RedeemCode"):InvokeServer(RedeemCodeInput)
            end)
            Window:Notify({
                Title = "Code Redeemer",
                Content = success and ("Code '" .. RedeemCodeInput .. "' redeemed! Result: " .. tostring(result)) or ("Failed: " .. tostring(result)),
                Duration = 5,
                Type = success and "Success" or "Error"
            })
        end
    })
end

-- ═══════════════════════════════════════
-- Buy Tab
-- ═══════════════════════════════════════
do
    local BuyTab = Window:CreateTab("Buy")

    -- ═══ Auto-scan equipment data from game ═══
    local EquipmentPath = ReplicatedStorage:FindFirstChild("common")
    if EquipmentPath then EquipmentPath = EquipmentPath:FindFirstChild("presets") end
    if EquipmentPath then EquipmentPath = EquipmentPath:FindFirstChild("equipment") end

    -- Scan all categories and their items
    local ScannedCategories = {}
    local ScannedItems = {} -- items per category: ScannedItems["guns"] = {"Developer", "Starter", ...}
    local AllItemNames = {} -- unified list of all unique item names

    local function ScanEquipment()
        ScannedCategories = {}
        ScannedItems = {}
        AllItemNames = {}
        local seen = {}

        if EquipmentPath then
            for _, categoryFolder in pairs(EquipmentPath:GetChildren()) do
                table.insert(ScannedCategories, categoryFolder.Name)
                ScannedItems[categoryFolder.Name] = {}

                for _, descendant in pairs(categoryFolder:GetDescendants()) do
                    if descendant:IsA("ModuleScript") then
                        table.insert(ScannedItems[categoryFolder.Name], descendant.Name)
                        if not seen[descendant.Name] then
                            seen[descendant.Name] = true
                            table.insert(AllItemNames, descendant.Name)
                        end
                    end
                end

                table.sort(ScannedItems[categoryFolder.Name])
            end

            table.sort(ScannedCategories)
            table.sort(AllItemNames)
        end

        -- Fallback if scan failed
        if #ScannedCategories == 0 then
            ScannedCategories = {"guns", "tubes", "flare", "glow", "bait", "repair"}
        end
        if #AllItemNames == 0 then
            AllItemNames = {"Starter", "Normal", "Developer", "Advanced", "Crossbow"}
        end
    end

    ScanEquipment() -- Run scan at init

    -- ── Shop (Buy Items) ──
    local BuyCollapsible = BuyTab:CreateCollapsible({
        Name = "Shop",
        DefaultOpen = false
    })

    local SelectedCategory = ScannedCategories[1] or "guns"
    local SelectedItemName = AllItemNames[1] or "Starter"
    local BuyQuantity = 1
    local CustomItemName = "" -- For textbox override

    BuyCollapsible:AddDropdown({
        Name = "Category",
        Options = ScannedCategories,
        Default = SelectedCategory,
        Callback = function(selected)
            SelectedCategory = selected
            -- Show items in this category
            local items = ScannedItems[selected]
            if items and #items > 0 then
                Window:Notify({
                    Title = selected .. " Items (" .. #items .. ")",
                    Content = table.concat(items, ", "),
                    Duration = 5,
                    Type = "Default"
                })
            end
        end
    })

    BuyCollapsible:AddDropdown({
        Name = "Item Name",
        Options = AllItemNames,
        Default = SelectedItemName,
        Callback = function(selected)
            SelectedItemName = selected
            CustomItemName = "" -- Reset custom
        end
    })

    BuyCollapsible:AddTextbox({
        Name = "Custom Item (override dropdown)",
        PlaceholderText = "Type item name if not in list",
        Callback = function(text)
            if text ~= "" then
                CustomItemName = text
            end
        end
    })

    BuyCollapsible:AddTextbox({
        Name = "Quantity",
        PlaceholderText = "1",
        Callback = function(text)
            local num = tonumber(text)
            if num and num >= 1 and num <= 100 then
                BuyQuantity = math.floor(num)
                Window:Notify({
                    Title = "Quantity Set",
                    Content = BuyQuantity .. " items",
                    Duration = 1,
                    Type = "Success"
                })
            end
        end
    })

    BuyCollapsible:AddDivider()

    BuyCollapsible:AddButton({
        Name = "Buy Item",
        Callback = function()
            local itemToBuy = CustomItemName ~= "" and CustomItemName or SelectedItemName

            local function TryBuy(item, qty, cat)
                local PurchaseService = Services:WaitForChild("PurchaseService")
                local buyRemote = PurchaseService:WaitForChild("RF"):WaitForChild("BuyItem")
                
                -- Method 1: Legacy (Name, Qty, Cat)
                local ok1, res1 = pcall(function()
                    return buyRemote:InvokeServer(item, qty, cat)
                end)
                if ok1 then return true, "Method 1 (Legacy)" end

                -- Method 2: Table Format (Matches new Minigame pattern)
                local ok2, res2 = pcall(function()
                    return buyRemote:InvokeServer({
                        Item = item,
                        Amount = qty,
                        Quantity = qty, -- Try both keys
                        Category = cat
                    })
                end)
                if ok2 then return true, "Method 2 (Table)" end

                -- Method 3: Knit Action Pattern
                local ok3, res3 = pcall(function()
                    return buyRemote:InvokeServer("BuyItem", {
                        Item = item,
                        Amount = qty,
                        Category = cat
                    })
                end)
                if ok3 then return true, "Method 3 (Knit Action)" end

                -- Method 4: MerchantService Fallback
                local ok4, res4 = pcall(function()
                    local MerchantService = Services:WaitForChild("MerchantService")
                    return MerchantService:WaitForChild("RF"):WaitForChild("Buy"):InvokeServer(item, qty)
                end)
                if ok4 then return true, "Method 4 (MerchantService)" end
                
                return false, "All methods failed. Last error: " .. tostring(res1 or res2 or res3 or res4)
            end

            task.spawn(function()
                Window:Notify({Title = "Buying...", Content = "Attempting to buy " .. itemToBuy, Duration = 2})
                
                local successCount = 0
                local lastMethod = ""
                
                for i = 1, BuyQuantity do
                    local success, method = TryBuy(itemToBuy, 1, SelectedCategory)
                    if success then
                        successCount = successCount + 1
                        lastMethod = method
                    else
                        Window:Notify({
                            Title = "Purchase Failed",
                            Content = method, -- Error message
                            Duration = 4,
                            Type = "Error"
                        })
                        return -- Stop on failure
                    end
                    task.wait(0.2)
                end

                if successCount > 0 then
                    Window:Notify({
                        Title = "Purchase Complete",
                        Content = string.format("Bought %d x %s using %s", successCount, itemToBuy, lastMethod),
                        Duration = 4,
                        Type = "Success"
                    })
                end
            end)
        end
    })

    BuyCollapsible:AddButton({
        Name = "Show Items for Category",
        Callback = function()
            local items = ScannedItems[SelectedCategory]
            if items and #items > 0 then
                local output = "Category: " .. SelectedCategory .. "\nItems (" .. #items .. "):\n"
                for _, name in ipairs(items) do
                    output = output .. "  - " .. name .. "\n"
                end
                print(output)
                pcall(function() setclipboard(output) end)
                Window:Notify({
                    Title = SelectedCategory .. " (" .. #items .. " items)",
                    Content = table.concat(items, ", "),
                    Duration = 8,
                    Type = "Success"
                })
            else
                Window:Notify({
                    Title = "No Items",
                    Content = "No items found for " .. SelectedCategory,
                    Duration = 3,
                    Type = "Error"
                })
            end
        end
    })

    local SwapRootCollapsible = BuyTab:CreateCollapsible({
        Name = "Item Swap (Exploit Menu)",
        DefaultOpen = false
    })

    -- Iterate all categories and create static menus
    for _, catName in ipairs(ScannedCategories) do
        local catItems = ScannedItems[catName] or {}
        if #catItems > 0 then
            local CatCollapsible = BuyTab:CreateCollapsible({
                Name = "Swap: " .. catName .. " (" .. #catItems .. ")",
                DefaultOpen = false
            })

            local SelectedItem = catItems[1]

            CatCollapsible:AddDropdown({
                Name = "Select " .. catName .. " Item",
                Options = catItems,
                Default = SelectedItem,
                Callback = function(v)
                    SelectedItem = v
                end
            })

            CatCollapsible:AddButton({
                Name = "Equip " .. catName,
                Callback = function()
                    local success, result = pcall(function()
                        local InventoryService = Services:WaitForChild("InventoryService")
                        return InventoryService:WaitForChild("RF"):WaitForChild("EquipItem"):InvokeServer(catName, SelectedItem)
                    end)
                    Window:Notify({
                        Title = "Equip " .. catName,
                        Content = success and ("Equipped: " .. SelectedItem) or ("Failed: " .. tostring(result)),
                        Duration = 3,
                        Type = success and "Success" or "Error"
                    })
                end
            })
        end
    end

    -- Custom Swap Fallback
    local CustomSwapCollapsible = BuyTab:CreateCollapsible({
        Name = "Swap: Custom (Manual Input)",
        DefaultOpen = false
    })

    local CustomCategory = "guns"
    local CustomItem = "Developer"

    CustomSwapCollapsible:AddTextbox({
        Name = "Category Name",
        PlaceholderText = "guns",
        Callback = function(t) CustomCategory = t end
    })

    CustomSwapCollapsible:AddTextbox({
        Name = "Item Name",
        PlaceholderText = "Developer",
        Callback = function(t) CustomItem = t end
    })

    CustomSwapCollapsible:AddButton({
        Name = "Force Equip Custom",
        Callback = function()
         local success, result = pcall(function()
                local InventoryService = Services:WaitForChild("InventoryService")
                return InventoryService:WaitForChild("RF"):WaitForChild("EquipItem"):InvokeServer(CustomCategory, CustomItem)
            end)
            Window:Notify({
                Title = "Custom Equip",
                Content = success and ("Sent: " .. CustomItem) or ("Failed"),
                Duration = 3,
                Type = success and "Success" or "Error"
            })
        end
    })

    -- ── Scan Info ──
    local ScanInfoCollapsible = BuyTab:CreateCollapsible({
        Name = "Equipment Scanner",
        DefaultOpen = false
    })

    ScanInfoCollapsible:AddButton({
        Name = "Rescan Equipment Data",
        Callback = function()
            ScanEquipment()
            Window:Notify({
                Title = "Rescan Complete",
                Content = "Found " .. #ScannedCategories .. " categories, " .. #AllItemNames .. " unique items",
                Duration = 3,
                Type = "Success"
            })
        end
    })

    ScanInfoCollapsible:AddButton({
        Name = "Dump All Equipment (Clipboard)",
        Callback = function()
            local output = "══════════════════════════\nEQUIPMENT DATA\n══════════════════════════\n"

            for _, cat in ipairs(ScannedCategories) do
                local items = ScannedItems[cat] or {}
                output = output .. "\n[" .. cat .. "] (" .. #items .. " items):\n"
                for _, item in ipairs(items) do
                    output = output .. "  - " .. item .. "\n"
                end
            end

            output = output .. "\n══════════════════════════"
            print(output)
            pcall(function() setclipboard(output) end)

            Window:Notify({
                Title = "Equipment Dump",
                Content = #ScannedCategories .. " categories, " .. #AllItemNames .. " items → Clipboard!",
                Duration = 5,
                Type = "Success"
            })
        end
    })
end

-- ═══════════════════════════════════════
-- Quest Tab
-- ═══════════════════════════════════════
do
    local QuestTab = Window:CreateTab("Quest")

    -- ── NPC Interaction ──
    local NpcCollapsible = QuestTab:CreateCollapsible({
        Name = "NPC Interaction",
        DefaultOpen = false
    })

    local NpcNames = {
        "Scientist", "Billy", "Crab", "Henry", "Jeff", "Richard", "Virelia",
        "Mr. Black", "David", "Diver", "Victor", "Marcus", "Naomi", "Noah",
        "Isaac", "Isolde", "Lost Captain", "Morveth", "Lightkeeper", "Bob",
        "Kraken", "Grumpy Hank", "Suspicious Fisher", "Lumi", "King Cat", "Golem"
    }
    local SelectedNpc = "Scientist"
    local NpcActions = {"talk_to", "accept", "complete", "decline"}
    local SelectedNpcAction = "talk_to"

    NpcCollapsible:AddDropdown({
        Name = "Select NPC",
        Options = NpcNames,
        Default = "Scientist",
        Callback = function(selected)
            SelectedNpc = selected
        end
    })

    NpcCollapsible:AddDropdown({
        Name = "Action",
        Options = NpcActions,
        Default = "talk_to",
        Callback = function(selected)
            SelectedNpcAction = selected
        end
    })

    NpcCollapsible:AddButton({
        Name = "Interact with NPC",
        Callback = function()
            local success, result = pcall(function()
                local QuestsService = Services:WaitForChild("QuestsService")
                return QuestsService:WaitForChild("RF"):WaitForChild("SubmitNpcDialogueInteract"):InvokeServer(SelectedNpc, SelectedNpcAction)
            end)
            Window:Notify({
                Title = "NPC Interact",
                Content = success and (SelectedNpc .. " - " .. SelectedNpcAction .. " OK!") or ("Failed: " .. tostring(result)),
                Duration = 3,
                Type = success and "Success" or "Error"
            })
        end
    })

    NpcCollapsible:AddButton({
        Name = "Teleport to Scientist",
        Callback = function()
            pcall(function()
                local npc = workspace:FindFirstChild("Game")
                if npc then npc = npc:FindFirstChild("Interactables") end
                if npc then npc = npc:FindFirstChild("Npc") end
                if npc then npc = npc:FindFirstChild("Scientist") end

                if npc then
                    local part = npc:FindFirstChildWhichIsA("BasePart") or npc.PrimaryPart
                    if part then
                        local character = Players.LocalPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0, 3)
                        end
                    end
                    Window:Notify({
                        Title = "Teleport",
                        Content = "Teleported to Scientist!",
                        Duration = 2,
                        Type = "Success"
                    })
                else
                    Window:Notify({
                        Title = "Teleport Failed",
                        Content = "Scientist NPC not found!",
                        Duration = 2,
                        Type = "Error"
                    })
                end
            end)
        end
    })

    -- ── Quest Items (Scientist Quest) ──
    local QuestItemCollapsible = QuestTab:CreateCollapsible({
        Name = "Quest Items - Teleporter Parts",
        DefaultOpen = false
    })

    local TeleporterParts = {"Toilet Paper", "Toilet", "Door", "Power Relays"}

    -- Individual item buttons
    for _, partName in ipairs(TeleporterParts) do
        QuestItemCollapsible:AddButton({
            Name = "TP to: " .. partName,
            Callback = function()
                pcall(function()
                    local questItems = workspace:FindFirstChild("Game")
                    if questItems then questItems = questItems:FindFirstChild("QuestItems") end
                    if questItems then questItems = questItems:FindFirstChild("TeleporterParts") end

                    if questItems then
                        local part = questItems:FindFirstChild(partName)
                        if part then
                            local target = part
                            if target:IsA("Model") then
                                target = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                            end
                            if target and target:IsA("BasePart") then
                                local character = Players.LocalPlayer.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    character.HumanoidRootPart.CFrame = target.CFrame
                                end
                            end
                        end
                    end
                end)
                Window:Notify({
                    Title = "Teleport",
                    Content = "TP to " .. partName,
                    Duration = 1,
                    Type = "Success"
                })
            end
        })
    end

    -- ── Quest Management ──
    local QuestManageCollapsible = QuestTab:CreateCollapsible({
        Name = "Quest Management",
        DefaultOpen = false
    })

    QuestManageCollapsible:AddButton({
        Name = "Claim All Quests",
        Callback = function()
            task.spawn(function()
                local claimed = 0
                pcall(function()
                    local QuestsService = Services:WaitForChild("QuestsService")
                    local claimRemote = QuestsService:WaitForChild("RF"):WaitForChild("ClaimQuest")

                    -- Try claiming multiple quest IDs
                    for i = 1, 20 do
                        pcall(function()
                            claimRemote:InvokeServer(i)
                            claimed = claimed + 1
                        end)
                        task.wait(0.2)
                    end
                end)
                Window:Notify({
                    Title = "Quest Claim",
                    Content = "Attempted to claim " .. claimed .. " quests!",
                    Duration = 3,
                    Type = "Success"
                })
            end)
        end
    })

    QuestManageCollapsible:AddButton({
        Name = "Finish All Quests",
        Callback = function()
            task.spawn(function()
                local finished = 0
                pcall(function()
                    local QuestsService = Services:WaitForChild("QuestsService")
                    local finishRemote = QuestsService:WaitForChild("RF"):WaitForChild("FinishQuest")

                    for i = 1, 20 do
                        pcall(function()
                            finishRemote:InvokeServer(i)
                            finished = finished + 1
                        end)
                        task.wait(0.2)
                    end
                end)
                Window:Notify({
                    Title = "Quest Finish",
                    Content = "Attempted to finish " .. finished .. " quests!",
                    Duration = 3,
                    Type = "Success"
                })
            end)
        end
    })

    -- ── Auto Quest (Full Automation) ──
    local AutoQuestCollapsible = QuestTab:CreateCollapsible({
        Name = "Auto Quest - Scientist",
        DefaultOpen = false
    })

    AutoQuestCollapsible:AddButton({
        Name = "Full Auto: Scientist Quest",
        Callback = function()
            task.spawn(function()
                Window:Notify({
                    Title = "Auto Quest",
                    Content = "Starting Scientist quest automation...",
                    Duration = 3,
                    Type = "Default"
                })

                pcall(function()
                    local QuestsService = Services:WaitForChild("QuestsService")
                    local character = Players.LocalPlayer.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    -- Step 1: TP to Scientist & Accept quest
                    local npc = workspace:FindFirstChild("Game")
                    if npc then npc = npc:FindFirstChild("Interactables") end
                    if npc then npc = npc:FindFirstChild("Npc") end
                    if npc then npc = npc:FindFirstChild("Scientist") end

                    if npc then
                        local part = npc:FindFirstChildWhichIsA("BasePart") or npc.PrimaryPart
                        if part then
                            hrp.CFrame = part.CFrame * CFrame.new(0, 0, 3)
                        end
                    end
                    task.wait(1)

                    -- Accept quest via dialogue
                    pcall(function()
                        QuestsService:WaitForChild("RF"):WaitForChild("SubmitNpcDialogueInteract"):InvokeServer("Scientist", "talk_to")
                    end)
                    task.wait(1)

                    -- Step 2: Collect all teleporter parts
                    local questItems = workspace:FindFirstChild("Game")
                    if questItems then questItems = questItems:FindFirstChild("QuestItems") end
                    if questItems then questItems = questItems:FindFirstChild("TeleporterParts") end

                    if questItems then
                        for _, partName in ipairs({"Toilet Paper", "Toilet", "Door", "Power Relays"}) do
                            local p = questItems:FindFirstChild(partName)
                            if p then
                                local target = p
                                if target:IsA("Model") then
                                    target = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                                end
                                if target and target:IsA("BasePart") then
                                    hrp.CFrame = target.CFrame
                                    task.wait(1.5)
                                end
                            end
                        end
                    end

                    task.wait(1)

                    -- Step 3: Return to Scientist
                    if npc then
                        local part = npc:FindFirstChildWhichIsA("BasePart") or npc.PrimaryPart
                        if part then
                            hrp.CFrame = part.CFrame * CFrame.new(0, 0, 3)
                        end
                    end
                    task.wait(1)

                    -- Step 4: Submit/Complete quest
                    pcall(function()
                        QuestsService:WaitForChild("RF"):WaitForChild("SubmitNpcDialogueInteract"):InvokeServer("Scientist", "talk_to")
                    end)
                    task.wait(0.5)
                    pcall(function()
                        QuestsService:WaitForChild("RF"):WaitForChild("SubmitNpcInteract"):InvokeServer("Scientist")
                    end)
                end)

                Window:Notify({
                    Title = "Auto Quest",
                    Content = "Scientist quest automation complete!",
                    Duration = 3,
                    Type = "Success"
                })
            end)
        end
    })
end

-- ═══════════════════════════════════════
-- Oxygen Tab
-- ═══════════════════════════════════════
do
    local OxygenTab = Window:CreateTab("Oxygen")

    -- ── Infinite Oxygen ──
    local InfOxyCollapsible = OxygenTab:CreateCollapsible({
        Name = "Infinite Oxygen",
        DefaultOpen = false
    })

    local InfiniteOxygenEnabled = false

    InfOxyCollapsible:AddToggle({
        Name = "Enable Infinite Oxygen",
        Default = false,
        Callback = function(v)
            InfiniteOxygenEnabled = v
            Window:Notify({
                Title = "Infinite Oxygen",
                Content = v and "Enabled - Oxygen will stay at MAX" or "Disabled",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })

            if v then
                task.spawn(function()
                    while InfiniteOxygenEnabled do
                        pcall(function()
                            local character = Players.LocalPlayer.Character
                            if character then
                                local maxOxygen = character:GetAttribute("maxoxygen") or 100
                                character:SetAttribute("oxygen", maxOxygen)
                            end
                        end)
                        task.wait(0.5) -- Refresh every 0.5 seconds
                    end
                end)
            end
        end
    })

    InfOxyCollapsible:AddButton({
        Name = "Refill Oxygen Once",
        Callback = function()
            local success = pcall(function()
                local character = Players.LocalPlayer.Character
                if character then
                    local maxOxygen = character:GetAttribute("maxoxygen") or 100
                    character:SetAttribute("oxygen", maxOxygen)
                end
            end)
            Window:Notify({
                Title = "Oxygen Refill",
                Content = success and "Oxygen refilled to MAX!" or "Failed!",
                Duration = 2,
                Type = success and "Success" or "Error"
            })
        end
    })

    InfOxyCollapsible:AddButton({
        Name = "Set Oxygen to Custom Value",
        Callback = function()
            -- Will use value from textbox below
        end
    })

    local CustomOxygenValue = 100

    InfOxyCollapsible:AddTextbox({
        Name = "Custom Oxygen Value",
        PlaceholderText = "100",
        Callback = function(text)
            local n = tonumber(text)
            if n and n >= 0 then
                CustomOxygenValue = n
                pcall(function()
                    local character = Players.LocalPlayer.Character
                    if character then
                        character:SetAttribute("oxygen", CustomOxygenValue)
                    end
                end)
                Window:Notify({
                    Title = "Oxygen Set",
                    Content = "Oxygen set to " .. CustomOxygenValue,
                    Duration = 2,
                    Type = "Success"
                })
            end
        end
    })

    -- ── Oxygen Monitor ──
    local MonitorCollapsible = OxygenTab:CreateCollapsible({
        Name = "Oxygen Monitor",
        DefaultOpen = false
    })

    MonitorCollapsible:AddButton({
        Name = "Check Current Oxygen",
        Callback = function()
            local oxygen = 0
            local maxOxygen = 0
            pcall(function()
                local character = Players.LocalPlayer.Character
                if character then
                    oxygen = character:GetAttribute("oxygen") or 0
                    maxOxygen = character:GetAttribute("maxoxygen") or 0
                end
            end)

            local percent = maxOxygen > 0 and math.floor((oxygen / maxOxygen) * 100) or 0
            local bar = ""
            for i = 1, 10 do
                bar = bar .. (i <= math.floor(percent / 10) and "█" or "░")
            end

            Window:Notify({
                Title = "Oxygen Status",
                Content = bar .. " " .. math.floor(oxygen) .. "/" .. math.floor(maxOxygen) .. " (" .. percent .. "%)",
                Duration = 5,
                Type = percent > 30 and "Success" or (percent > 10 and "Warning" or "Error")
            })
        end
    })

    local OxygenMonitorActive = false

    MonitorCollapsible:AddToggle({
        Name = "Auto Monitor (Print to Console)",
        Default = false,
        Callback = function(v)
            OxygenMonitorActive = v
            if v then
                task.spawn(function()
                    while OxygenMonitorActive do
                        pcall(function()
                            local character = Players.LocalPlayer.Character
                            if character then
                                local oxygen = character:GetAttribute("oxygen") or 0
                                local maxOxygen = character:GetAttribute("maxoxygen") or 0
                                print(string.format("[O2] %.1f / %.1f (%.0f%%)", oxygen, maxOxygen, maxOxygen > 0 and (oxygen/maxOxygen*100) or 0))
                            end
                        end)
                        task.wait(3) -- Log every 3 seconds
                    end
                end)
            end
        end
    })

    MonitorCollapsible:AddButton({
        Name = "Scan All Oxygen Attributes",
        Callback = function()
            local output = "══ OXYGEN ATTRIBUTES ══\n"
            pcall(function()
                local character = Players.LocalPlayer.Character
                if character then
                    output = output .. "oxygen = " .. tostring(character:GetAttribute("oxygen")) .. "\n"
                    output = output .. "maxoxygen = " .. tostring(character:GetAttribute("maxoxygen")) .. "\n"

                    -- Check for oxygen-related attributes
                    local attrs = character:GetAttributes()
                    for k, v in pairs(attrs) do
                        if string.lower(k):find("oxy") or string.lower(k):find("breath") or string.lower(k):find("air") then
                            output = output .. k .. " = " .. tostring(v) .. "\n"
                        end
                    end

                    -- Check stats
                    local stats = character:FindFirstChild("stats")
                    if stats then
                        output = output .. "\n[Character Stats]\n"
                        for k, v in pairs(stats:GetAttributes()) do
                            output = output .. "  " .. k .. " = " .. tostring(v) .. "\n"
                        end
                    end
                end
            end)
            output = output .. "══════════════════════"
            print(output)
            pcall(function() setclipboard(output) end)
            Window:Notify({
                Title = "Oxygen Attributes",
                Content = "Scanned! Check console & clipboard",
                Duration = 3,
                Type = "Success"
            })
        end
    })

    -- ── Auto Buy Oxygen Pods ──
    local BuyOxyCollapsible = OxygenTab:CreateCollapsible({
        Name = "Auto Buy Oxygen Pods",
        DefaultOpen = false
    })

    local OxygenItems = {
        "Small Oxygen Pod",
        "Basic Oxygen Pod",
        "Advanced Oxygen Pod",
        "Heavy Oxygen Pod",
        "Oxygen Shard"
    }

    local SelectedOxygenItem = "Basic Oxygen Pod"
    local AutoBuyOxyEnabled = false
    local OxygenBuyThreshold = 30 -- Buy when oxygen drops below this %

    BuyOxyCollapsible:AddDropdown({
        Name = "Oxygen Item",
        Options = OxygenItems,
        Default = "Basic Oxygen Pod",
        Callback = function(selected)
            SelectedOxygenItem = selected
        end
    })

    BuyOxyCollapsible:AddTextbox({
        Name = "Buy Threshold (%)",
        PlaceholderText = "30 (buy when oxygen below this %)",
        Callback = function(text)
            local n = tonumber(text)
            if n and n >= 1 and n <= 100 then
                OxygenBuyThreshold = n
                Window:Notify({
                    Title = "Threshold Set",
                    Content = "Will buy when oxygen < " .. n .. "%",
                    Duration = 2,
                    Type = "Success"
                })
            end
        end
    })

    BuyOxyCollapsible:AddButton({
        Name = "Buy Oxygen Item (Once)",
        Callback = function()
            local success, result = pcall(function()
                local PurchaseService = Services:WaitForChild("PurchaseService")
                return PurchaseService:WaitForChild("RF"):WaitForChild("BuyItem"):InvokeServer(SelectedOxygenItem, 1, "consumables")
            end)
            Window:Notify({
                Title = "Buy Oxygen",
                Content = success and ("Bought " .. SelectedOxygenItem .. "!") or ("Failed: " .. tostring(result)),
                Duration = 3,
                Type = success and "Success" or "Error"
            })
        end
    })

    BuyOxyCollapsible:AddToggle({
        Name = "Auto Buy When Low",
        Default = false,
        Callback = function(v)
            AutoBuyOxyEnabled = v
            Window:Notify({
                Title = "Auto Buy Oxygen",
                Content = v and ("Enabled - Buy when < " .. OxygenBuyThreshold .. "%") or "Disabled",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })

            if v then
                task.spawn(function()
                    while AutoBuyOxyEnabled do
                        pcall(function()
                            local character = Players.LocalPlayer.Character
                            if character then
                                local oxygen = character:GetAttribute("oxygen") or 0
                                local maxOxygen = character:GetAttribute("maxoxygen") or 100
                                local percent = (oxygen / maxOxygen) * 100

                                if percent < OxygenBuyThreshold then
                                    local PurchaseService = Services:WaitForChild("PurchaseService")
                                    PurchaseService:WaitForChild("RF"):WaitForChild("BuyItem"):InvokeServer(SelectedOxygenItem, 1, "consumables")
                                end
                            end
                        end)
                        task.wait(5) -- Check every 5 seconds
                    end
                end)
            end
        end
    })

    -- ── Auto Use Oxygen ──
    local UseOxyCollapsible = OxygenTab:CreateCollapsible({
        Name = "Auto Use Oxygen Items",
        DefaultOpen = false
    })

    local UseOxygenItems = {
        "Small Oxygen Pod",
        "Basic Oxygen Pod",
        "Advanced Oxygen Pod",
        "Heavy Oxygen Pod"
    }

    local SelectedUseOxyItem = "Basic Oxygen Pod"
    local AutoUseOxyEnabled = false
    local OxygenUseThreshold = 40

    UseOxyCollapsible:AddDropdown({
        Name = "Item to Use",
        Options = UseOxygenItems,
        Default = "Basic Oxygen Pod",
        Callback = function(selected)
            SelectedUseOxyItem = selected
        end
    })

    UseOxyCollapsible:AddTextbox({
        Name = "Use Threshold (%)",
        PlaceholderText = "40 (use when oxygen below this %)",
        Callback = function(text)
            local n = tonumber(text)
            if n and n >= 1 and n <= 100 then
                OxygenUseThreshold = n
                Window:Notify({
                    Title = "Threshold Set",
                    Content = "Will use item when oxygen < " .. n .. "%",
                    Duration = 2,
                    Type = "Success"
                })
            end
        end
    })

    UseOxyCollapsible:AddButton({
        Name = "Use Oxygen Item (Once)",
        Callback = function()
            -- Try equipping the consumable to use it
            local success, result = pcall(function()
                local InventoryService = Services:WaitForChild("InventoryService")
                return InventoryService:WaitForChild("RF"):WaitForChild("EquipItem"):InvokeServer("consumables", SelectedUseOxyItem)
            end)
            Window:Notify({
                Title = "Use Oxygen",
                Content = success and ("Used " .. SelectedUseOxyItem .. "!") or ("Failed: " .. tostring(result)),
                Duration = 3,
                Type = success and "Success" or "Error"
            })
        end
    })

    UseOxyCollapsible:AddToggle({
        Name = "Auto Use When Low",
        Default = false,
        Callback = function(v)
            AutoUseOxyEnabled = v
            Window:Notify({
                Title = "Auto Use Oxygen",
                Content = v and ("Enabled - Use when < " .. OxygenUseThreshold .. "%") or "Disabled",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })

            if v then
                task.spawn(function()
                    while AutoUseOxyEnabled do
                        pcall(function()
                            local character = Players.LocalPlayer.Character
                            if character then
                                local oxygen = character:GetAttribute("oxygen") or 0
                                local maxOxygen = character:GetAttribute("maxoxygen") or 100
                                local percent = (oxygen / maxOxygen) * 100

                                if percent < OxygenUseThreshold then
                                    local InventoryService = Services:WaitForChild("InventoryService")
                                    InventoryService:WaitForChild("RF"):WaitForChild("EquipItem"):InvokeServer("consumables", SelectedUseOxyItem)
                                end
                            end
                        end)
                        task.wait(3) -- Check every 3 seconds
                    end
                end)
            end
        end
    })

    -- ── Force Set Oxygen (Cmdr) ──
    local CmdrCollapsible = OxygenTab:CreateCollapsible({
        Name = "Force Set Oxygen (Developer)",
        DefaultOpen = false
    })

    local CmdrOxygenAmount = 9999

    CmdrCollapsible:AddTextbox({
        Name = "Oxygen Amount",
        PlaceholderText = "9999",
        Callback = function(text)
            local n = tonumber(text)
            if n and n >= 0 then
                CmdrOxygenAmount = n
            end
        end
    })

    CmdrCollapsible:AddButton({
        Name = "Force Set Oxygen (Cmdr)",
        Callback = function()
            -- Method 1: Try Cmdr command
            local s1 = pcall(function()
                local Cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
                if Cmdr then
                    local cmdrModule = require(Cmdr)
                    if cmdrModule and cmdrModule.Dispatcher then
                        cmdrModule.Dispatcher:EvaluateAndRun("setoxygen " .. Players.LocalPlayer.Name .. " " .. CmdrOxygenAmount)
                    end
                end
            end)

            -- Method 2: Direct SetAttribute as fallback
            local s2 = pcall(function()
                local character = Players.LocalPlayer.Character
                if character then
                    character:SetAttribute("oxygen", CmdrOxygenAmount)
                    -- Also try setting maxoxygen if amount exceeds current max
                    local maxOxy = character:GetAttribute("maxoxygen") or 100
                    if CmdrOxygenAmount > maxOxy then
                        character:SetAttribute("maxoxygen", CmdrOxygenAmount)
                    end
                end
            end)

            Window:Notify({
                Title = "Force Set Oxygen",
                Content = (s1 and "Cmdr: OK" or "Cmdr: Failed (not developer)") .. " | " .. (s2 and "SetAttribute: OK" or "SetAttribute: Failed"),
                Duration = 4,
                Type = (s1 or s2) and "Success" or "Error"
            })
        end
    })

    CmdrCollapsible:AddButton({
        Name = "Set Max Oxygen (Increase Cap)",
        Callback = function()
            local success = pcall(function()
                local character = Players.LocalPlayer.Character
                if character then
                    character:SetAttribute("maxoxygen", CmdrOxygenAmount)
                    character:SetAttribute("oxygen", CmdrOxygenAmount)
                end
            end)
            Window:Notify({
                Title = "Max Oxygen",
                Content = success and ("Max oxygen set to " .. CmdrOxygenAmount .. "!") or "Failed!",
                Duration = 3,
                Type = success and "Success" or "Error"
            })
        end
    })
end

-- ═══════════════════════════════════════
-- Settings Tab (Developer Tools - Password Protected)
-- ═══════════════════════════════════════
do
    local SettingsTab = Window:CreateTab("Settings")

    -- ── Developer Access ──
    local DevCollapsible = SettingsTab:CreateCollapsible({
        Name = "🔒 Developer Tools",
        DefaultOpen = true
    })

    local DevUnlocked = false
    local RemoteSpyEnabled = false
    local RemoteSpyLogs = {}
    local MAX_LOGS = 200
    local OldNamecall = nil

    -- Serialize args for display
    local function SerializeValue(v, depth)
        depth = depth or 0
        if depth > 3 then return "..." end
        local t = typeof(v)
        if t == "string" then
            return '"' .. v .. '"'
        elseif t == "number" or t == "boolean" then
            return tostring(v)
        elseif t == "nil" then
            return "nil"
        elseif t == "Instance" then
            return v:GetFullName()
        elseif t == "Vector3" then
            return string.format("Vector3.new(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
        elseif t == "CFrame" then
            return string.format("CFrame.new(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
        elseif t == "EnumItem" then
            return tostring(v)
        elseif t == "table" then
            local parts = {}
            local count = 0
            for k, val in pairs(v) do
                count = count + 1
                if count > 8 then
                    table.insert(parts, "...")
                    break
                end
                local key = type(k) == "number" and ("[" .. k .. "]") or ("[\"" .. tostring(k) .. "\"]")
                table.insert(parts, key .. " = " .. SerializeValue(val, depth + 1))
            end
            return "{" .. table.concat(parts, ", ") .. "}"
        else
            return tostring(v)
        end
    end

    local function SerializeArgs(args)
        local parts = {}
        for i, v in ipairs(args) do
            table.insert(parts, SerializeValue(v))
        end
        return table.concat(parts, ", ")
    end

    local function FormatLog(entry)
        local header = string.format("[%s] %s:%s", entry.Time, entry.Type, entry.Method)
        local remote = "  Remote: " .. entry.RemotePath
        local args = "  Args: (" .. entry.Args .. ")"
        return header .. "\n" .. remote .. "\n" .. args
    end

    -- Hook __namecall to spy on remotes
    local function StartRemoteSpy()
        if OldNamecall then return end -- Already hooked

        OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if method == "FireServer" or method == "InvokeServer" then
                if RemoteSpyEnabled then
                    local remotePath = self:GetFullName()
                    
                    -- Filter: Skip ReplicaRemoteEvents (spam framework calls)
                    if remotePath:find("ReplicaRemoteEvents") or remotePath:find("Replica_ReplicaSignal") then
                        return OldNamecall(self, ...)
                    end
                    
                    local entry = {
                        Time = os.date("%H:%M:%S"),
                        Type = self:IsA("RemoteEvent") and "RE" or "RF",
                        Method = method,
                        RemotePath = remotePath,
                        Args = SerializeArgs(args),
                        Raw = args
                    }

                    table.insert(RemoteSpyLogs, 1, entry) -- Newest first
                    if #RemoteSpyLogs > MAX_LOGS then
                        table.remove(RemoteSpyLogs, #RemoteSpyLogs)
                    end

                    -- Print to console
                    print("🔍 [RemoteSpy] " .. FormatLog(entry))
                end
            end

            return OldNamecall(self, ...)
        end))
    end

    -- Unhook
    local function StopRemoteSpy()
        RemoteSpyEnabled = false
        -- Note: we don't restore the hook, just disable logging
    end

    -- Password Input
    DevCollapsible:AddTextbox({
        Name = "🔑 Enter Developer Password",
        PlaceholderText = "Enter password to unlock...",
        Callback = function(input)
            if input == "ngensal" then
                DevUnlocked = true
                Window:Notify({
                    Title = "🔓 Developer Access Granted",
                    Content = "Welcome, Developer! Tools unlocked.",
                    Duration = 3,
                    Type = "Success"
                })

                -- ── Create Dev Tools UI after unlock ──
                local SpyCollapsible = SettingsTab:CreateCollapsible({
                    Name = "🔍 Remote Spy (NPN Spy)",
                    DefaultOpen = true
                })

                local TesterCollapsible = SettingsTab:CreateCollapsible({Name = "🛠️ Remote Tester", DefaultOpen = true})

                SpyCollapsible:AddToggle({
                    Name = "Enable Remote Spy",
                    Default = false,
                    Callback = function(v)
                        if not DevUnlocked then
                            Window:Notify({
                                Title = "Access Denied",
                                Content = "Unlock Developer Tools first!",
                                Duration = 2,
                                Type = "Error"
                            })
                            return
                        end

                        RemoteSpyEnabled = v
                        if v then
                            pcall(function()
                                StartRemoteSpy()
                            end)
                            Window:Notify({
                                Title = "🔍 Remote Spy",
                                Content = "Spy ACTIVE - Logging all FireServer/InvokeServer calls",
                                Duration = 3,
                                Type = "Success"
                            })
                        else
                            Window:Notify({
                                Title = "🔍 Remote Spy",
                                Content = "Spy PAUSED - No longer logging",
                                Duration = 2,
                                Type = "Warning"
                            })
                        end
                    end
                })

                SpyCollapsible:AddButton({
                    Name = "📋 Copy Last 50 Logs to Clipboard",
                    Callback = function()
                        if #RemoteSpyLogs == 0 then
                            Window:Notify({
                                Title = "Remote Spy",
                                Content = "No logs captured yet!",
                                Duration = 2,
                                Type = "Warning"
                            })
                            return
                        end

                        local output = "══════════════════════════\n"
                        output = output .. "NPN REMOTE SPY LOG\n"
                        output = output .. "Captured: " .. #RemoteSpyLogs .. " calls\n"
                        output = output .. "══════════════════════════\n\n"

                        local count = math.min(50, #RemoteSpyLogs)
                        for i = 1, count do
                            local entry = RemoteSpyLogs[i]
                            output = output .. "── Log #" .. i .. " ──\n"
                            output = output .. FormatLog(entry) .. "\n"

                            -- Generate script
                            output = output .. "  Script:\n"
                            output = output .. "    " .. entry.RemotePath
                            if entry.Type == "RE" then
                                output = output .. ":FireServer(" .. entry.Args .. ")\n"
                            else
                                output = output .. ":InvokeServer(" .. entry.Args .. ")\n"
                            end
                            output = output .. "\n"
                        end

                        output = output .. "══════════════════════════"
                        print(output)
                        pcall(function() setclipboard(output) end)

                        Window:Notify({
                            Title = "Remote Spy",
                            Content = count .. " logs copied to clipboard!",
                            Duration = 3,
                            Type = "Success"
                        })
                    end
                })

                SpyCollapsible:AddButton({
                    Name = "📊 Show Log Summary",
                    Callback = function()
                        if #RemoteSpyLogs == 0 then
                            Window:Notify({
                                Title = "Remote Spy",
                                Content = "No logs yet. Enable spy and interact with the game!",
                                Duration = 3,
                                Type = "Warning"
                            })
                            return
                        end

                        -- Count by remote
                        local remoteCounts = {}
                        for _, entry in ipairs(RemoteSpyLogs) do
                            local name = entry.RemotePath
                            remoteCounts[name] = (remoteCounts[name] or 0) + 1
                        end

                        local summary = ""
                        local sortedRemotes = {}
                        for name, count in pairs(remoteCounts) do
                            table.insert(sortedRemotes, {name = name, count = count})
                        end
                        table.sort(sortedRemotes, function(a, b) return a.count > b.count end)

                        for i, r in ipairs(sortedRemotes) do
                            if i > 10 then break end
                            summary = summary .. r.count .. "x " .. r.name .. "\n"
                        end

                        print("═══ REMOTE SPY SUMMARY ═══\n" .. summary)

                        Window:Notify({
                            Title = "Spy Summary (" .. #RemoteSpyLogs .. " total)",
                            Content = summary,
                            Duration = 8,
                            Type = "Default"
                        })
                    end
                })

                SpyCollapsible:AddButton({
                    Name = "🔄 Copy Last Log as Script",
                    Callback = function()
                        if #RemoteSpyLogs == 0 then
                            Window:Notify({
                                Title = "Remote Spy",
                                Content = "No logs captured!",
                                Duration = 2,
                                Type = "Warning"
                            })
                            return
                        end

                        local entry = RemoteSpyLogs[1]
                        local script = "-- Generated by NPN Remote Spy\n"
                        script = script .. "-- " .. entry.Time .. " | " .. entry.Type .. " | " .. entry.Method .. "\n\n"
                        
                        -- Build a clean script format
                        local pathParts = {}
                        for part in entry.RemotePath:gmatch("[^%.]+") do
                            table.insert(pathParts, part)
                        end

                        script = script .. 'local args = {' .. entry.Args .. '}\n\n'

                        if entry.Type == "RE" then
                            script = script .. 'game:GetService("ReplicatedStorage")'
                            -- Skip first part if it's "ReplicatedStorage"
                            local startIdx = 1
                            if pathParts[1] == "ReplicatedStorage" then startIdx = 2 end
                            for i = startIdx, #pathParts do
                                script = script .. ':WaitForChild("' .. pathParts[i] .. '")'
                            end
                            script = script .. ':FireServer(unpack(args))\n'
                        else
                            script = script .. 'game:GetService("ReplicatedStorage")'
                            local startIdx = 1
                            if pathParts[1] == "ReplicatedStorage" then startIdx = 2 end
                            for i = startIdx, #pathParts do
                                script = script .. ':WaitForChild("' .. pathParts[i] .. '")'
                            end
                            script = script .. ':InvokeServer(unpack(args))\n'
                        end

                        print(script)
                        pcall(function() setclipboard(script) end)

                        Window:Notify({
                            Title = "Script Copied!",
                            Content = entry.RemotePath:match("[^%.]+$") .. " (" .. entry.Method .. ")",
                            Duration = 3,
                            Type = "Success"
                        })
                    end
                })


                local TestService = "SellService"
                local TestMethod = "SellInventory"
                local TestArgs = "{}"

                TesterCollapsible:AddTextbox({
                    Name = "Service Name",
                    PlaceholderText = "SellService",
                    Callback = function(v) TestService = v end
                })

                TesterCollapsible:AddTextbox({
                    Name = "Method Name",
                    PlaceholderText = "SellInventory (RF/RE)",
                    Callback = function(v) TestMethod = v end
                })

                TesterCollapsible:AddTextbox({
                    Name = "Arguments (Lua Table)",
                    PlaceholderText = "{'arg1', 123}",
                    Callback = function(v) TestArgs = v end
                })

                TesterCollapsible:AddButton({
                    Name = "🔥 Test FireServer (RE)",
                    Callback = function()
                        pcall(function()
                            local args = loadstring("return " .. TestArgs)()
                            if type(args) ~= "table" then args = {} end
                            
                            local svc = Services:FindFirstChild(TestService)
                            if svc then
                                local re = svc:FindFirstChild("RE")
                                if re then
                                    local method = re:FindFirstChild(TestMethod)
                                    if method then
                                        method:FireServer(unpack(args))
                                        Window:Notify({Title="Remote Tester", Content="Fired " .. TestService.."."..TestMethod, Duration=3, Type="Success"})
                                    else
                                         Window:Notify({Title="Remote Tester", Content="Method not found in RE!", Duration=3, Type="Error"})
                                    end
                                else
                                    Window:Notify({Title="Remote Tester", Content="RE folder not found!", Duration=3, Type="Error"})
                                end
                            else
                                Window:Notify({Title="Remote Tester", Content="Service not found!", Duration=3, Type="Error"})
                            end
                        end)
                    end
                })

                TesterCollapsible:AddButton({
                    Name = "📡 Test InvokeServer (RF)",
                    Callback = function()
                        pcall(function()
                            local args = loadstring("return " .. TestArgs)()
                            if type(args) ~= "table" then args = {} end
                            
                            local svc = Services:FindFirstChild(TestService)
                            if svc then
                                local rf = svc:FindFirstChild("RF")
                                if rf then
                                    local method = rf:FindFirstChild(TestMethod)
                                    if method then
                                         Window:Notify({Title="Remote Tester", Content="Invoking...", Duration=2, Type="Default"})
                                        local res = method:InvokeServer(unpack(args))
                                        print("Remote Tester Result:", res)
                                        Window:Notify({Title="Remote Tester", Content="Invoked!", Duration=3, Type="Success"})
                                    else
                                         Window:Notify({Title="Remote Tester", Content="Method not found in RF!", Duration=3, Type="Error"})
                                    end
                                else
                                    Window:Notify({Title="Remote Tester", Content="RF folder not found!", Duration=3, Type="Error"})
                                end
                            else
                                Window:Notify({Title="Remote Tester", Content="Service not found!", Duration=3, Type="Error"})
                            end
                        end)
                    end
                })

                SpyCollapsible:AddButton({
                    Name = "🗑️ Clear All Logs",
                    Callback = function()
                        RemoteSpyLogs = {}
                        Window:Notify({
                            Title = "Remote Spy",
                            Content = "All logs cleared!",
                            Duration = 2,
                            Type = "Success"
                        })
                    end
                })

                SpyCollapsible:AddDivider()

                SpyCollapsible:AddButton({
                    Name = "📡 Scan All Knit Services & Remotes",
                    Callback = function()
                        task.spawn(function()
                            local fullOutput = "══════════════════════════\n"
                            fullOutput = fullOutput .. "KNIT SERVICES (ALL REMOTES)\n"
                            fullOutput = fullOutput .. "══════════════════════════\n"

                            local serviceCount = 0

                            for _, service in pairs(Services:GetChildren()) do
                                if service:IsA("Folder") then
                                    serviceCount = serviceCount + 1
                                    fullOutput = fullOutput .. "\n[SERVICE] " .. service.Name .. "\n"

                                    local rf = service:FindFirstChild("RF")
                                    if rf then
                                        for _, func in pairs(rf:GetChildren()) do
                                            fullOutput = fullOutput .. "  RF/" .. func.Name .. "\n"
                                        end
                                    end

                                    local re = service:FindFirstChild("RE")
                                    if re then
                                        for _, func in pairs(re:GetChildren()) do
                                            fullOutput = fullOutput .. "  RE/" .. func.Name .. "\n"
                                        end
                                    end
                                end
                            end

                            fullOutput = fullOutput .. "══════════════════════════"
                            print(fullOutput)

                            pcall(function()
                                setclipboard(fullOutput)
                            end)

                            Window:Notify({
                                Title = "Knit Services (" .. serviceCount .. ")",
                                Content = "Copied to clipboard!",
                                Duration = 5,
                                Type = "Success"
                            })
                        end)
                    end
                })

                SpyCollapsible:AddButton({
                    Name = "🌳 Dump ReplicatedStorage Tree",
                    Callback = function()
                        task.spawn(function()
                            local output = "══════════════════════════\n"
                            output = output .. "REPLICATED STORAGE TREE\n"
                            output = output .. "══════════════════════════\n"

                            local function scanTree(obj, depth)
                                if depth > 4 then return end
                                local indent = string.rep("  ", depth)
                                for _, child in pairs(obj:GetChildren()) do
                                    output = output .. indent .. "[" .. child.ClassName .. "] " .. child.Name .. "\n"
                                    scanTree(child, depth + 1)
                                end
                            end

                            pcall(function()
                                local common = ReplicatedStorage:FindFirstChild("common")
                                if common then
                                    local source = common:FindFirstChild("source")
                                    if source then
                                        output = output .. "common/source:\n"
                                        scanTree(source, 1)
                                    end
                                end
                            end)

                            output = output .. "══════════════════════════"
                            print(output)
                            pcall(function() setclipboard(output) end)

                            Window:Notify({
                                Title = "RS Tree",
                                Content = "Copied to clipboard!",
                                Duration = 5,
                                Type = "Success"
                            })
                        end)
                    end
                })

                SpyCollapsible:AddButton({
                    Name = "🗺️ Dump Workspace Game Tree",
                    Callback = function()
                        task.spawn(function()
                            local output = "══════════════════════════\n"
                            output = output .. "WORKSPACE GAME TREE\n"
                            output = output .. "══════════════════════════\n"

                            local function scanTree(obj, depth)
                                if depth > 3 then return end
                                local indent = string.rep("  ", depth)
                                for _, child in pairs(obj:GetChildren()) do
                                    output = output .. indent .. "[" .. child.ClassName .. "] " .. child.Name .. "\n"
                                    scanTree(child, depth + 1)
                                end
                            end

                            pcall(function()
                                local game_folder = workspace:FindFirstChild("Game")
                                if game_folder then
                                    scanTree(game_folder, 1)
                                end
                            end)

                            output = output .. "══════════════════════════"
                            print(output)
                            pcall(function() setclipboard(output) end)

                            Window:Notify({
                                Title = "Workspace Tree",
                                Content = "Copied to clipboard!",
                                Duration = 5,
                                Type = "Success"
                            })
                        end)
                    end
                })

            else
                -- Wrong password
                Window:Notify({
                    Title = "❌ Access Denied",
                    Content = "Password salah, anda bukan seorang developer!",
                    Duration = 4,
                    Type = "Error"
                })
            end
        end
    })
end