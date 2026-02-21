local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Knit = ReplicatedStorage
    :WaitForChild("common")
    :WaitForChild("packages")
    :WaitForChild("Knit")

local KnitClient = require(Knit)
local MinigameController = KnitClient.GetController("MinigameController")

local Services = Knit:WaitForChild("Services")

local HarpoonService = Services
    :WaitForChild("HarpoonService")
    :WaitForChild("RF")

local DataController = KnitClient.GetController("DataController")

local GameLibrary = nil
pcall(function()
    GameLibrary = require(ReplicatedStorage.common.library)
end)

local FishController = nil
pcall(function()
    local fishModule = ReplicatedStorage:FindFirstChild("common")
        and ReplicatedStorage.common:FindFirstChild("assets")
        and ReplicatedStorage.common.assets:FindFirstChild("fish")
    if fishModule then
        FishController = require(fishModule)
        if FishController and FishController.fish_cache then
            warn("[NPN] FishController loaded via require() ✓ fish_cache accessible")
        else
            FishController = nil
        end
    end
end)

if not FishController then
    pcall(function()
        local fc = KnitClient.GetController("fish")
        if fc and fc.fish_cache then
            FishController = fc
            warn("[NPN] FishController loaded via Knit ✓")
        end
    end)
end

if not FishController then
    warn("[NPN] FishController NOT loaded — using spatial cache fallback (limited range)")
end

local MinigameService = Services
    :WaitForChild("MinigameService")
    :WaitForChild("RF")

local MinigameServiceRE = Services
    :WaitForChild("MinigameService")
    :WaitForChild("RE")

local SettingsService = Services
    :WaitForChild("SettingsService")
    :WaitForChild("RF")

local SellServiceRF = Services:WaitForChild("SellService"):WaitForChild("RF")
local SellFishFunc = SellServiceRF:WaitForChild("SellFish")
local SellInventoryFunc = SellServiceRF:WaitForChild("SellInventory")

local SettingsServiceRF = Services:WaitForChild("SettingsService"):WaitForChild("RF")
local UpdateAutoSellFunc = SettingsServiceRF:WaitForChild("UpdateAutoSell")

local BackpackService = Services
    :WaitForChild("BackpackService")
    :WaitForChild("RF")
    
local ArtifactsServiceRF = Services
    :WaitForChild("ArtifactsService")
    :WaitForChild("RF")

-- UI
local FluxUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/rsalmn/FluxUI/refs/heads/main/FluxUI.lua"
))()

local Window = FluxUI:CreateWindow({
    Name = "NPN Hub - Abyss",
    Size = UDim2.new(0, 444, 0, 340),
    Theme = "Midnight"
})

_G.QuestFishMutation = nil 
_G.AutoQuestBigBoss = false 
_G.AutoQuestCollect = false 
_G.QuestCollectTarget = nil 
_G.AutoGeode = false 
_G.SelectedGeode = "All" 
_G.QuestGeodeType = nil 
_G.DebugMode = false 
_G.TeleportMoveSpeed = 2.0 
_G.TeleportMaxSpeed = 5.0 
_G.LastSafePosition = nil 

local MAX_RANGE = 5000           
local TELEPORT_DISTANCE = 5000      
local TELEPORT_DELAY = 0.5       

local AutoTest = false

local FOLLOW_DISTANCE = 5
local FOLLOW_TIMEOUT = 6
local FOLLOW_UPDATE = 0.1

local TP_STEP = 5
local TP_DELAY = 0.2
local TP_HEIGHT = 5
local MinigameDelay = 0.3
local AntiGravityEnabled = false
local OptimalMinibarPos = 0.2
local MinibarMoveAmplitude = 999
local MinibarMoveFrequency = 999

local CHUNK_SIZE = 100                 
local PREDICTION_SECONDS = 0.8         
local PREDICTION_SECONDS_TP = 0.5      
local PREDICTION_SECONDS_REPREDICT = 0.3 
local FISH_LOOP_DELAY_MIN = 0.35       
local FISH_LOOP_DELAY_MAX = 0.75       
local BLATANT_DESTROY_DELAY = 0.03     
local OXYGEN_CRITICAL_PCT = 15         
local OXYGEN_EMERGENCY_PCT = 5         
local OXYGEN_RESTORED_PCT = 25         
local STAFF_GROUP_ID = 34898222        
local FALLBACK_SAFE_POS = Vector3.new(-1.31, 4873.2, 3.35) 

local AutoSellEnabled = false
local SellThreshold = 80 
local InfiniteOxygenEnabled = false
local OxygenSafeEnabled = false 

local LoopToken = 0
local function NewLoopToken()
    LoopToken = LoopToken + 1
    return LoopToken
end

local CachedWeightLabel = nil
local CachedOxygenLabel = nil
local CacheExpiry = 0 

local MutationMatchCache = {} 

local State = {
    Busy = false,
    Selling = false,
    Recovering = false,
    Flinging = false,
    FishingMode = "Normal" 
}

local FishingModes = {
    Normal = "Normal",
    QuestMutation = "QuestMutation",
    QuestGeode = "QuestGeode"
}

local AutoChestEnabled = false 
local SelectedChestTier = "All" 
local AutoFlingEnabled = false 
local AutoRespawnEnabled = false 
local AutoClaimBestiaryEnabled = false 
local AntiStaffEnabled = false 
local AntiStaffConnection = nil
local HideIdentifyEnabled = false 

local FishingMode = "Off"   
local MinigameInstance = nil
local MovementServiceRF = Services:WaitForChild("MovementService"):WaitForChild("RF")
local RespawnFunc = MovementServiceRF:WaitForChild("Respawn")

local BestiaryServiceRF = Services:WaitForChild("BestiaryService"):WaitForChild("RF")
local ClaimRewardFunc = BestiaryServiceRF:WaitForChild("ClaimReward")

local MerchantServiceRF = Services:WaitForChild("MerchantService"):WaitForChild("RF")
local BuyItemFunc = MerchantServiceRF:WaitForChild("Buy")

local ChestServiceRF = Services:WaitForChild("ChestService"):WaitForChild("RF")
local UnlockChestFunc = ChestServiceRF:WaitForChild("UnlockChest")

local function FindGuiElement(parent, name, timeout)
    local start = tick()
    timeout = timeout or 0.5
    
    repeat
        local found = parent:FindFirstChild(name, true)
        if found then return found end
        task.wait(0.1)
    until (tick() - start > timeout)
    
    return nil
end

local function GetWeightFromUI()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0, 50, false end
    
    if not CachedWeightLabel or not CachedWeightLabel.Parent or tick() > CacheExpiry then
        CachedWeightLabel = FindGuiElement(gui, "Wght", 0.2)
        CacheExpiry = tick() + 5
    end
    
    local wghtLabel = CachedWeightLabel
    local maxLabel = FindGuiElement(gui, "Max", 0.2) 
    
    if wghtLabel and wghtLabel:IsA("TextLabel") then
        local current = tonumber(wghtLabel.Text)
        local max = 50
        
        if maxLabel and maxLabel:IsA("TextLabel") then
            local maxStr = maxLabel.Text:match("([%d%.]+)")
            if maxStr then max = tonumber(maxStr) end
        end
        
        local color = wghtLabel.TextColor3
        local isRed = (color.R > 0.8 and color.G < 0.2 and color.B < 0.2)
        
        if current then
            return current, max, isRed
        end
    end

    return 0, 50, false
end

local OxygenDebugPrinted = false
local function GetOxygenFromUI()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 100 end

    if not CachedOxygenLabel or not CachedOxygenLabel.Parent then
        CachedOxygenLabel = FindGuiElement(gui, "LowOxygen", 0.1)
    end
    if CachedOxygenLabel and CachedOxygenLabel:IsA("GuiObject") and CachedOxygenLabel.Visible then
        return OXYGEN_EMERGENCY_PCT 
    end
    
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local attr = hum:GetAttribute("Oxygen")
            if attr and type(attr) == "number" then return attr end
        end
    end
    
    local outer = FindGuiElement(gui, "OxygenOuter", 0.1)
    if outer then
        local gradient = outer:FindFirstChild("Gradient")
        if gradient and gradient:IsA("Frame") then
             return gradient.Size.X.Scale * 100
        end
    end
    
    return 100 
end

local function GetCurrentWeight()
    local c, m, r = GetWeightFromUI()
    return c
end

local function GetMaxWeight()
    local c, m, r = GetWeightFromUI()
    return m
end

local function IsInventoryFull()
    local c, m, isRed = GetWeightFromUI()
    if isRed then return true end
    
    if c and m and m > 0 then
        local pct = (c / m) * 100
        if pct >= SellThreshold then
            return true
        end
    end
    
    return false
end
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local MutationPresets = ReplicatedStorage.common.presets.fish.mutations
local MutationCache = {}

local function GetMutationParticles(mutationName)
    if not mutationName then return nil end
    if MutationCache[mutationName] then return MutationCache[mutationName] end
    
    local module = MutationPresets:FindFirstChild(mutationName)
    if module then
        local success, data = pcall(require, module)
        if success and data and data.parts and data.parts.Root and data.parts.Root.Particle then
            local particles = data.parts.Root.Particle
            if type(particles) ~= "table" then
                particles = {particles}
            end
            MutationCache[mutationName] = particles
            return particles
        else
            if _G.DebugMode then
                warn("Failed to load mutation preset or invalid structure: " .. mutationName)
            end
        end
    elseif _G.DebugMode then
         warn("Mutation module not found: " .. mutationName)
    end
    
    MutationCache[mutationName] = {} 
    return nil
end

local NoclipEnabled = false
local NoclipConnection = nil

local function SetNoclip(enabled)
    NoclipEnabled = enabled
    
    if enabled then
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
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        
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

local function SmoothTeleport(targetPos, opts)
    opts = opts or {}
    
    local char = LocalPlayer.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Sit then hum.Sit = false end

    local oldNoclip = NoclipEnabled
    if not opts.noNoclip then SetNoclip(true) end

    local MOVE_SPEED = _G.TeleportMoveSpeed or 2.0
    local MAX_SPEED = _G.TeleportMaxSpeed or 5.0
    local ARRIVAL_DIST = opts.arrivalDist or 5
    local MAX_TRAVEL_TIME = 60

    local startTime = os.clock()
    local frameCount = 0
    local totalDist = (targetPos - hrp.Position).Magnitude
    local wobblePhase = math.random() * math.pi * 2
    local wobbleFreq = 0.8 + math.random() * 0.6
    local wobbleAmp = 0.3 + math.random() * 0.4

    while true do
        if opts.cancelCheck and opts.cancelCheck() then
            if not opts.noNoclip then SetNoclip(oldNoclip) end
            return false
        end

        if State.Recovering and not opts.skipRecoveringCheck then
            if not opts.noNoclip then SetNoclip(oldNoclip) end
            return false
        end

        if (os.clock() - startTime) > MAX_TRAVEL_TIME then
            if not opts.noNoclip then SetNoclip(oldNoclip) end
            return false
        end

        frameCount = frameCount + 1
        if opts.trackTarget and frameCount % 5 == 0 then
            targetPos = opts.trackTarget() or targetPos
        end

        local currentPos = hrp.Position
        local toTarget = targetPos - currentPos
        local dist = toTarget.Magnitude

        if dist <= ARRIVAL_DIST then break end

        local direction = toTarget.Unit

        local progress = 1 - (dist / math.max(totalDist, 1))
        local speed
        if progress < 0.15 then
            speed = MOVE_SPEED * (0.4 + progress / 0.15 * 0.6)
        elseif dist < 20 then
            speed = MOVE_SPEED * math.max(0.3, dist / 20)
        else
            speed = MOVE_SPEED + (MAX_SPEED - MOVE_SPEED) * math.sin(progress * math.pi)
        end

        local jitter = Vector3.new(
            (math.random() - 0.5) * 0.15,
            (math.random() - 0.5) * 0.08,
            (math.random() - 0.5) * 0.15
        )
        local elapsed = os.clock() - startTime
        local wobble = math.sin(elapsed * wobbleFreq * math.pi * 2 + wobblePhase) * wobbleAmp
        local perp = Vector3.new(-direction.Z, 0, direction.X)

        local step = direction * speed + jitter + perp * wobble * 0.1
        local newPos = currentPos + step

        local lookAhead = targetPos + Vector3.new(
            (math.random() - 0.5) * 1.5, 0, (math.random() - 0.5) * 1.5
        )

        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(newPos, lookAhead), 0.7 + math.random() * 0.2)
        RunService.Heartbeat:Wait()
    end

    hrp.CFrame = CFrame.new(
        Vector3.new(targetPos.X, targetPos.Y + TP_HEIGHT, targetPos.Z),
        targetPos
    )

    if not opts.noNoclip then SetNoclip(oldNoclip) end
    return true
end

local function SmoothTeleportOxygenSafe(targetPos)
    if not targetPos then return false end
    return SmoothTeleport(targetPos, {
        noNoclip = true,
        cancelCheck = function()
            return not State.Recovering
        end,
        skipRecoveringCheck = true
    })
end

local function Teleport(targetPos)
    return SmoothTeleport(targetPos)
end

local function StealthTeleport(targetPos)
    return SmoothTeleport(targetPos)
end

local RarityPreset = require(ReplicatedStorage.common.presets.rarity)
local BoidBehaviors = require(ReplicatedStorage.common.presets.fish.boidbehaviors)
local CurrencyPreset = require(ReplicatedStorage.common.presets.currency)

local SmartPriorityEnabled = true
local SelectedRarities = {Common=true, Uncommon=true, Rare=true, Epic=true, Legendary=true, Mythic=true, Exotic=true}
local MaxDistanceWeight = 0.4   
local RarityWeight = 0.4        
local ValueWeight = 0.2         

local FishValueCache = {}

local function GetRarityScore(rarity)
    local scores = {Common = 1, Uncommon = 2, Rare = 4, Epic = 8, Legendary = 12}
    return scores[rarity] or 1
end
local function GetRarityRank(rarity)
    local ranks = {Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6, Exotic = 7}
    return ranks[rarity] or 1
end

local function GetFishValue(fishName)
    if FishValueCache[fishName] then return FishValueCache[fishName] end
    
    local fishData = CurrencyPreset.fish and CurrencyPreset.fish[fishName]
    local value = fishData and fishData.value or 50  
    
    FishValueCache[fishName] = value
    return value
end

local FishSpatialCache = {}
local CACHE_REFRESH_INTERVAL = 2 

local function RefreshFishCache()
    FishSpatialCache = {}
    local fishFolder = workspace.Game.Fish.client
    
    for _, fish in pairs(fishFolder:GetChildren()) do
        local part = fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")
        if part then
            local pos = part.Position
            local chunk = Vector3.new(
                math.floor(pos.X / CHUNK_SIZE) * CHUNK_SIZE,
                math.floor(pos.Y / CHUNK_SIZE) * CHUNK_SIZE,
                math.floor(pos.Z / CHUNK_SIZE) * CHUNK_SIZE
            )
            
            FishSpatialCache[chunk] = FishSpatialCache[chunk] or {}
            table.insert(FishSpatialCache[chunk], fish)
        end
    end
end

local _cacheToken = NewLoopToken()
task.spawn(function()
    local myToken = _cacheToken
    while myToken == LoopToken do
        RefreshFishCache()
        task.wait(CACHE_REFRESH_INTERVAL)
    end
end)

local function PredictFishPositionAdvanced(fishModel, secondsAhead)
    local behaviorName = fishModel:GetAttribute("BoidBehavior") or "default"
    local behavior = (BoidBehaviors and (BoidBehaviors[behaviorName] or BoidBehaviors.default)) or {speed = 8}
    
    local part = fishModel.PrimaryPart or fishModel:FindFirstChildWhichIsA("BasePart")
    if not part then return nil end
    
    local currentPos = part.Position
    local velocity = part.AssemblyLinearVelocity
    local speed = behavior.speed or 8
    
    local steeringForce = Vector3.new(0, 0, 0)
    
    if behavior.cohesion then
        local nearbyFish = GetNearbyFish(fishModel, 50)
        if #nearbyFish > 0 then
            local center = Vector3.new(0, 0, 0)
            for _, other in ipairs(nearbyFish) do
                local otherPart = other.PrimaryPart or other:FindFirstChildWhichIsA("BasePart")
                if otherPart then
                    center = center + otherPart.Position
                end
            end
            center = center / #nearbyFish
            steeringForce = steeringForce + (center - currentPos).Unit * behavior.cohesion
        end
    end
    
    if behavior.separation then
        local nearbyFish = GetNearbyFish(fishModel, 20)
        for _, other in ipairs(nearbyFish) do
            local otherPart = other.PrimaryPart or other:FindFirstChildWhichIsA("BasePart")
            if otherPart then
                local diff = currentPos - otherPart.Position
                if diff.Magnitude > 0 then
                    steeringForce = steeringForce + diff.Unit * (behavior.separation / diff.Magnitude)
                end
            end
        end
    end
    
    if behavior.alignment then
        local nearbyFish = GetNearbyFish(fishModel, 30)
        if #nearbyFish > 0 then
            local avgVel = Vector3.new(0, 0, 0)
            for _, other in ipairs(nearbyFish) do
                local otherPart = other.PrimaryPart or other:FindFirstChildWhichIsA("BasePart")
                if otherPart then
                    avgVel = avgVel + otherPart.AssemblyLinearVelocity
                end
            end
            avgVel = avgVel / #nearbyFish
            steeringForce = steeringForce + (avgVel - velocity).Unit * behavior.alignment
        end
    end
    
    local maxForce = 5
    if steeringForce.Magnitude > maxForce then
        steeringForce = steeringForce.Unit * maxForce
    end
    
    local newVelocity = velocity + steeringForce
    if newVelocity.Magnitude > speed then
        newVelocity = newVelocity.Unit * speed
    end
    
    return currentPos + (newVelocity * secondsAhead)
end

local FishClientFolder = workspace:WaitForChild("Game"):WaitForChild("Fish"):WaitForChild("client")

local function GetNearestFish(targetMutation)
    local hrp = getHRP()
    if not hrp then return end
    local playerPos = hrp.Position

    local bestFish = nil
    local bestScore = -10000

    local allFish = FishClientFolder:GetChildren()
    
    for _, fishModel in pairs(allFish) do
        if not fishModel:IsA("Model") then continue end
        
        local part = fishModel.PrimaryPart
            or fishModel:FindFirstChildWhichIsA("BasePart")
        if not part then continue end
        
        local fishPos = part.Position
        local dist = (fishPos - playerPos).Magnitude
        if dist > MAX_RANGE then continue end
        
        local isTarget = true
        if targetMutation then
            isTarget = false
            local targets = (type(targetMutation) == "table") and targetMutation or {targetMutation}
            
            local mutVal = fishModel:GetAttribute("Mutation") or fishModel:GetAttribute("mutation")
            if not mutVal then
                local mValObj = fishModel:FindFirstChild("Mutation")
                if mValObj then mutVal = mValObj.Value end
            end
            
            if mutVal then
                for _, wanted in ipairs(targets) do
                    if tostring(mutVal) == wanted then
                        isTarget = true
                        break
                    end
                end
            end
            
            if not isTarget then
                local head = fishModel:FindFirstChild("Head") or part
                local stats = head and head:FindFirstChild("stats")
                if stats then
                    local mutLabel = stats:FindFirstChild("Mutation")
                    if mutLabel then
                        local label = mutLabel:FindFirstChild("Label")
                        if label and label:IsA("TextLabel") and label.Visible then
                            for _, wanted in ipairs(targets) do
                                if label.Text == wanted then
                                    isTarget = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
            
            if not isTarget then
                for _, mutName in ipairs(targets) do
                    local particles = GetMutationParticles(mutName)
                    if particles then
                        local root = fishModel:FindFirstChild("Root")
                            or fishModel:FindFirstChild("RootPart")
                            or fishModel:FindFirstChild("HumanoidRootPart")
                            or part
                        if root then
                            for _, pName in pairs(particles) do
                                if root:FindFirstChild(pName) then
                                    isTarget = true
                                    break
                                end
                            end
                        end
                    end
                    if isTarget then break end
                end
            end
        end
        
        if not isTarget then continue end
        
        local rarity = fishModel:GetAttribute("Rarity") or "Common"
        if SmartPriorityEnabled and not targetMutation then
            if not SelectedRarities[rarity] then continue end
        end
        
        local value = GetFishValue(fishModel.Name)
        local predictedPos = PredictFishPositionAdvanced(fishModel, 0.8) or fishPos
        
        local score = 0
        if SmartPriorityEnabled and not targetMutation then
            local distScore = (1 - math.clamp(dist / MAX_RANGE, 0, 1)) * 100
            local rarityScore = GetRarityScore(rarity) * 20
            local valueScore = math.clamp(value / 10, 0, 100)
            score = (distScore * MaxDistanceWeight) + (rarityScore * RarityWeight) + (valueScore * ValueWeight)
        else
            score = 100000 - dist
        end
        
        if score > bestScore then
            bestScore = score
            bestFish = {
                Id = fishModel.Name,
                Object = fishModel,
                Position = fishPos,
                PredictedPos = predictedPos,
                Rarity = rarity,
                Value = value
            }
        end
    end

    return bestFish
end

local function SmartStealthTeleportV2(fish)
    if not AutoTest then return false end

    local function getTargetPos()
        if fish.Object and fish.Object.Parent then
            local p = fish.Object.PrimaryPart
            if p then
                return PredictFishPositionAdvanced(fish.Object, 0.4) or p.Position
            end
        end
        if fish.CFrame then return fish.CFrame.Position end
        return fish.PredictedPos or fish.Position
    end

    local targetPos = getTargetPos()
    if not targetPos then return false end

    return SmoothTeleport(targetPos, {
        cancelCheck = function()
            if not AutoTest then return true end
            if fish.Object and fish.Object.Parent == nil then return true end
            return false
        end,
        trackTarget = getTargetPos
    })
end

local function SmartStealthTeleport(fish)
    return SmartStealthTeleportV2(fish)
end

local function StealthTeleportToKraken(targetPos)
    return SmoothTeleport(targetPos, {
        cancelCheck = function() return not State.Selling end
    })
end

local function ShootFish(fish)
    if not AutoTest then return end

    local hrp = getHRP()
    if not hrp then return end

    hrp.CFrame = CFrame.new(hrp.Position, fish.Position)

    pcall(function()
        HarpoonService:WaitForChild("StartCatching"):InvokeServer(fish.Id)
    end)
end

local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    local isActiveFunc = MinigameController.IsMinigameActive
    if not isActiveFunc then return end

    if AntiGravityEnabled then
        local MinigameInstance = debug.getupvalue(isActiveFunc, 1)
        if MinigameInstance and MinigameInstance.running and MinigameInstance.gravityStrength ~= 0 then
            MinigameInstance.gravityStrength = 0
        end
    end

    if not AutoTest then return end

    if FishingMode ~= "Normal" and FishingMode ~= "Instant" and FishingMode ~= "Instant V2" then return end
    if MinigameInstance and MinigameInstance.running then
        if MinigameInstance.zonePos then
            local targetPos = MinigameInstance.zonePos

            if MinigameInstance.rewards and #MinigameInstance.rewards > 0 then
                for _, r in ipairs(MinigameInstance.rewards) do
                    if r.progress < 1 and math.abs(r.pos - MinigameInstance.zonePos) < 0.2 then
                        targetPos = r.pos
                        break
                    end
                end
            end

            MinigameInstance._markerCurrent = targetPos
            MinigameInstance._markerTarget = targetPos
            
            if MinigameInstance.marker then
                MinigameInstance.marker.Position = UDim2.fromScale(0.5, targetPos)
            end
            
            if FishingMode == "Instant V2" then
                MinigameInstance.gravityStrength = 0
                MinigameInstance.momentum = 0
                MinigameInstance.holding = true
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if InfiniteOxygenEnabled then
        pcall(function()
            local oxygenGui = LocalPlayer.PlayerGui:FindFirstChild("OxygenGui") or LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
            if oxygenGui then
                local bar = oxygenGui:FindFirstChild("OxygenBar") or oxygenGui:FindFirstChild("Bar")
                if bar and bar:IsA("NumberValue") then bar.Value = 999999 end
            end
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:SetAttribute("Oxygen", 999999) end
            end
        end)
    end
    
    if OxygenSafeEnabled then
        local num = GetOxygenFromUI()
        
        if num < OXYGEN_CRITICAL_PCT and num > 0 and not State.Recovering then
             State.Recovering = true
             State.Busy = true
             
             task.spawn(function()
                 if MinigameController:IsMinigameActive() then
                     if num >= OXYGEN_EMERGENCY_PCT then
                         local waitStart = tick()
                         while MinigameController:IsMinigameActive() and (tick() - waitStart < 30) do
                             task.wait(0.5)
                             local currentOxy = GetOxygenFromUI()
                             if currentOxy < OXYGEN_EMERGENCY_PCT then
                                 break
                             end
                         end
                         task.wait(0.5)
                     else
                     end
                 end
                 
                 while OxygenSafeEnabled and State.Recovering do
                     local currentOxy = GetOxygenFromUI()
                     
                     if currentOxy > OXYGEN_RESTORED_PCT then
                         State.Recovering = false
                         State.Busy = false
                         break
                     end
                     
                     local hrp = getHRP()
                     if hrp then
                         local currentPos = hrp.Position
                         local safeTarget = _G.LastSafePosition
                         if not safeTarget then
                             local npcFolder = workspace:WaitForChild("Game"):WaitForChild("Interactables"):WaitForChild("Npc")
                             local bestDist = 9999999
                             for _, npc in pairs(npcFolder:GetChildren()) do
                                 if npc:IsA("Model") and (npc.Name == "Kraken" or npc.Name == "Merchant" or npc.Name == "Shipwright") then
                                      local pivot = npc:GetPivot().Position
                                      local dist = (pivot - currentPos).Magnitude
                                      if dist < bestDist then
                                          bestDist = dist
                                          safeTarget = pivot + Vector3.new(0, 15, 30)
                                      end
                                 end
                             end
                             if not safeTarget then safeTarget = FALLBACK_SAFE_POS end
                         end
                         SmoothTeleportOxygenSafe(safeTarget)
                     end
                     
                     task.wait(0.5)
                 end
             end)
         end
    end
end)

local OldCatchingNew = nil

task.spawn(function()
    local modulePath = ReplicatedStorage.common.lib.modules:WaitForChild("CatchingMinigame", 5)
    if not modulePath then warn("CatchingMinigame module not found!") return end
    
    local oldNew = require(modulePath).new
    
    require(modulePath).new = function(controller, data)
        local instance = oldNew(controller, data)
        
        MinigameInstance = instance
        
        if FishingMode == "Blatant" then
            instance.running = false
            instance.progress = 1
            instance.perfectCatch = true
            
            pcall(function()
                controller.MinigameService:Update("ProgressUpdate", {
                    progress = 1,
                    rewards = instance.rewards or {}
                })
            end)
            
            task.delay(BLATANT_DESTROY_DELAY, function()
                if instance then
                    pcall(function() instance:Destroy() end)
                    MinigameInstance = nil
                end
            end)
            
            Window:Notify({Title = "🎯 BLATANT", Content = "Minigame Destroyed Instantly!", Duration = 1, Type = "Success"})
            
        elseif FishingMode == "Instant" then
            instance.gravityStrength = 0
            instance.momentum = 0
            instance.progressSpeed = 0.88
            instance.bonusSpeed = 1
            task.spawn(function()
                while instance.running do
                    local bestPos = instance.zonePos or 0.5
                    
                    if instance.rewards then
                        for _, reward in ipairs(instance.rewards) do
                            if reward.progress < 1 and math.abs(reward.pos - (instance.zonePos or 0.5)) < 0.22 then
                                bestPos = reward.pos
                                break
                            end
                        end
                    end
                    
                    instance._markerCurrent = bestPos
                    instance._markerTarget = bestPos
                    
                    if instance.marker then
                        instance.marker.Position = UDim2.new(0.5, 0, bestPos, 0)
                    end
                    
                    task.wait(0.09)
                end
            end)

            if instance.rewards then
                task.spawn(function()
                    task.wait(0.6)
                    if instance and instance.rewards then
                        for _, reward in ipairs(instance.rewards) do
                            if type(reward) == "table" and reward.pos then
                                reward.pos = instance.zonePos or 0.5
                            end
                        end
                    end
                end)
            end
        elseif FishingMode == "Instant V2" then
            if instance.rewards then
                task.spawn(function()
                    task.wait(0.6)
                    if instance and instance.rewards then
                        for _, reward in ipairs(instance.rewards) do
                            if type(reward) == "table" and reward.pos then
                                reward.pos = instance.zonePos or 0.5
                            end
                        end
                    end
                end)
            end
            
            task.spawn(function()
                task.wait(1.6)
                while instance and instance.running do
                    local zp = instance.zonePos or 0.5
                    instance._markerCurrent = zp
                    instance._markerTarget = zp
                    
                    task.wait(0.03)
                end
            end)
            
            Window:Notify({Title = "⚡ Instant V2", Content = "Smart Physics Override Active!", Duration = 1.5, Type = "Success"})
        end
        
        return instance
    end
end)

local function AutoFishLoop()
    if State.Busy then return end
    State.Busy = true

    local hrp = getHRP()
    if hrp then
        _G.LastSafePosition = hrp.Position
    end

    task.spawn(function()
        while AutoTest do
            if FishingMode == "Off" then
                AutoTest = false
                break
            end

            if State.Recovering or State.Selling then
                if _G.DebugMode then warn("AutoFish: Paused (Oxygen/Sell active)") end
                while AutoTest and (State.Recovering or State.Selling) do
                    task.wait(0.5)
                end
                if not AutoTest then break end
                task.wait(1)
                if _G.DebugMode then warn("AutoFish: Resumed after Oxygen/Sell") end
            end

            local target = nil
            
            if _G.AutoQuestBigBoss and _G.QuestFishMutation then
                target = _G.QuestFishMutation
            elseif State.FishingMode == FishingModes.QuestMutation then
                target = _G.QuestFishMutation
            elseif _G.MutationFilter and #_G.MutationFilter > 0 then
                target = #_G.MutationFilter == 1 and _G.MutationFilter[1] or _G.MutationFilter
            end

            local fish = GetNearestFish(target)
            if fish then
                if SmartStealthTeleportV2(fish) then
                    ShootFish(fish)
                    task.wait(0.05)
                    if not MinigameController:IsMinigameActive() then
                        ShootFish(fish)
                    end
                    
                    local t = tick()
                    local started = false
                    repeat 
                        task.wait(0.08)
                        if MinigameController:IsMinigameActive() then started = true end
                    until started or (tick() - t > 2.5)
                    
                    if started and FishingMode ~= "Blatant" then
                        repeat task.wait(0.1) until not MinigameController:IsMinigameActive()
                        if FishingMode == "Instant V2" then
                            task.wait(0.2)
                        else
                            task.wait(0.4)
                        end
                    else 
                         task.wait(0.5)
                    end
                end
            else
                 if _G.DebugMode then warn("No fish found near, retrying...") end
            end
            task.wait(0.35 + math.random() * 0.4)
        end
        State.Busy = false
    end)
end

local function AutoChestLoop()
    if not AutoChestEnabled then return end
    if State.Busy then return end
    
    local chestsFolder = workspace:WaitForChild("Game"):WaitForChild("Chests")
    local chestFound = false
    
    for _, tierFolder in pairs(chestsFolder:GetChildren()) do
        if not AutoChestEnabled then break end
        local tierName = tierFolder.Name
        
        if SelectedChestTier == "All" or tierName == SelectedChestTier then
            for _, chestObj in pairs(tierFolder:GetChildren()) do
                if not AutoChestEnabled then break end
                
                local prompt = chestObj:FindFirstChildWhichIsA("ProximityPrompt", true)
                
                if prompt and prompt.Enabled then
                    chestFound = true
                    State.Busy = true
                    AutoFlingEnabled = true
                     
                    local chestID = chestObj.Name
                    local targetPart = prompt.Parent 
                    if targetPart then
                        Teleport(targetPart.Position)

                        task.wait(1)
                         
                        local success, err = pcall(function()
                            local args = {
                                [1] = tierName,
                                [2] = chestID
                            }
                            UnlockChestFunc:InvokeServer(unpack(args))
                        end)
                         
                        if success then
                            Window:Notify({Title="Auto Chest", Content="Unlocked!", Duration=2})
                            task.wait(3) 
                        else
                            warn("Failed to unlock chest:", err)
                        end
                    end
                     
                    State.Busy = false
                end
            end
        end
    end
    
    if not chestFound and AutoChestEnabled then
        task.wait(1)
    end
end

-- Auto Collect Loop (For Quests)
local function AutoCollectLoop()
    if not _G.AutoQuestCollect then return end
    if State.Busy then 
        -- print("State.Busy, skipping collect loop")
        return 
    end
    
    local targetFolder = workspace:WaitForChild("Game"):WaitForChild("QuestItems"):FindFirstChild(_G.QuestCollectTarget)
    if not targetFolder then 
        warn("Target Folder NOT FOUND: "..tostring(_G.QuestCollectTarget))
        return 
    end
    
    -- Scientist Quest Items
    local collectItems
    if _G.QuestCollectTarget == "TeleporterParts" then
        collectItems = {"Toilet Paper", "Toilet", "Door", "Power Relays"}
        
        -- Debug: Print folder contents ONCE
        if not _G.DebugCollectPrinted then
            -- print("DEBUG: contents of "..targetFolder.Name)
            for _, c in pairs(targetFolder:GetChildren()) do
                -- print("- Child: "..c.Name.." ("..c.ClassName..")")
                if c:IsA("Model") or c:IsA("Folder") then
                     for _, gc in pairs(c:GetChildren()) do
                         -- print("  - GChild: "..gc.Name.." ("..gc.ClassName..")")
                     end
                end
            end
            _G.DebugCollectPrinted = true
        end
    end
    
    if collectItems then
        for _, itemName in ipairs(collectItems) do
            if not _G.AutoQuestCollect then break end
            
            --print("Checking for: "..itemName) 
            for _, desc in pairs(targetFolder:GetDescendants()) do
                if desc.Name == itemName then
                    -- print("Debug: Found match "..desc.Name.." ("..desc.ClassName..")")
                    
                    local targetPart = desc
                    if desc:IsA("Model") then
                        targetPart = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart", true)
                    end
                    
                    if targetPart and targetPart:IsA("BasePart") then
                        -- Check Prompt on Model or Part
                        local prompt = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
                        
                        if prompt and prompt.Enabled then
                            State.Busy = true
                            AutoFlingEnabled = true
                            
                            print("Teleporting to: "..itemName)
                            Window:Notify({Title="Auto Collect", Content="Found: "..itemName, Duration=2})
                            
                            -- Teleport & Claim
                            Teleport(targetPart.Position)
                            task.wait(0.5)
                            fireproximityprompt(prompt)
                            task.wait(1)
                            
                            State.Busy = false
                            AutoFlingEnabled = false
                            break -- Go to next item type
                        end
                    end
                end
            end
        end
    end
end

-- =============================================
-- Auto Crack Geodes System
-- Uses ArtifactsService:Open(geodeName, amount)
-- Geodes: Heart, Cactus, etc from presets
-- =============================================

-- Determine which geode type to crack
local function GetTargetGeodeType()
    -- Priority 1: Quest-detected geode type (Big Boss / Virelia)
    if _G.QuestGeodeType and _G.QuestGeodeType ~= "" then
        return _G.QuestGeodeType
    end
    -- Priority 2: User-selected geode from dropdown
    if _G.SelectedGeode and _G.SelectedGeode ~= "All" then
        return _G.SelectedGeode
    end
    -- Priority 3: "All" = try any geode in inventory
    return nil
end

-- Check if player has geodes in inventory via replica data
local function GetGeodeInventoryCount(geodeName)
    local count = 0
    pcall(function()
        local replica = DataController:GetReplica()
        if replica and replica.Data and replica.Data.inventory then
            for _, item in pairs(replica.Data.inventory) do
                if item.class == "geodes" and item.name == geodeName then
                    count = count + 1
                end
            end
        end
    end)
    return count
end

-- Check if a geode is currently being cracked
local function IsGeodeCrafting()
    local crafting = false
    pcall(function()
        local replica = DataController:GetReplica()
        if replica and replica.Data and replica.Data.crafting_artifacts then
            crafting = true
        end
    end)
    return crafting
end

-- Auto Crack Geode via ArtifactsService:Open
local function AutoCrackGeode()
    if not _G.AutoGeode then return end
    
    -- Don't start new crack if already crafting
    if IsGeodeCrafting() then return end
    
    local targetType = GetTargetGeodeType()
    local GeodePresets = ReplicatedStorage.common.presets.items.geodes
    if not GeodePresets then return end
    
    if targetType then
        -- Crack specific geode type
        local count = GetGeodeInventoryCount(targetType)
        if count > 0 then
            local amount = math.min(count, 99)
            Window:Notify({
                Title = "Auto Geode",
                Content = "Cracking x" .. amount .. " " .. targetType .. " Geode...",
                Duration = 3,
                Type = "Success"
            })
            pcall(function()
                ArtifactsServiceRF:WaitForChild("Open"):InvokeServer(targetType, amount)
            end)
        end
    else
        -- "All" mode: try every geode type that has inventory
        for _, geodeModule in pairs(GeodePresets:GetChildren()) do
            if not _G.AutoGeode then break end
            if IsGeodeCrafting() then break end
            
            local geodeName = geodeModule.Name
            local count = GetGeodeInventoryCount(geodeName)
            if count > 0 then
                local amount = math.min(count, 99)
                Window:Notify({
                    Title = "Auto Geode",
                    Content = "Cracking x" .. amount .. " " .. geodeName .. " Geode...",
                    Duration = 3,
                    Type = "Success"
                })
                pcall(function()
                    ArtifactsServiceRF:WaitForChild("Open"):InvokeServer(geodeName, amount)
                end)
                break -- One type at a time, wait for it to finish
            end
        end
    end
end

-- Auto interact with geode ProximityPrompts in workspace
local function AutoGeodeLoop()
    if not _G.AutoGeode then return end
    if State.Busy then return end
    
    local targetType = GetTargetGeodeType()
    local targets = workspace:WaitForChild("Game"):GetDescendants()
    
    for _, obj in pairs(targets) do
        if not _G.AutoGeode then break end
        
        if obj:IsA("Model") and string.find(obj.Name, "Geode") then
            -- Filter by target type if specified
            local nameMatch = true
            if targetType then
                nameMatch = string.find(obj.Name, targetType) ~= nil
            end
            
            if nameMatch then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    State.Busy = true
                    
                    Window:Notify({
                        Title = "Auto Geode",
                        Content = "Interacting: " .. obj.Name,
                        Duration = 2
                    })
                    
                    local targetPos = obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
                    Teleport(targetPos)
                    task.wait(0.5)
                    fireproximityprompt(prompt)
                    task.wait(1.5)
                    
                    State.Busy = false
                    return -- One at a time
                end
            end
        end
    end
end

-- Auto Quest Thread (Main Caller)
task.spawn(function()
    while true do
        task.wait(1)
        
        -- Big Boss Smart Detection (Universal - reads quest definitions dynamically)
        if _G.AutoQuestBigBoss then
             pcall(function()
                 local npcName = _G._autoQuestNPC or "Big Boss"
                 local replica = DataController:GetReplica()
                 if not (replica and replica.Data and replica.Data.quests and replica.Data.quests.active) then return end
                 
                 local bbData = replica.Data.quests.active[npcName]
                 if not bbData then
                     -- No active Big Boss quest
                     if _G._lastBBStep then
                         _G._lastBBStep = nil
                         Window:Notify({Title="Quest", Content=npcName .. " quest completed or not active!", Duration=3, Type="Success"})
                     end
                     return
                 end
                 
                 local step = tonumber(bbData.name) or 0
                 local progress = bbData.progress or {}
                 
                 -- Only re-detect when step changes
                 if step == _G._lastBBStep then return end
                 _G._lastBBStep = step
                 
                 -- Try to read quest definitions from GameLibrary
                 local questTasks = nil
                 if GameLibrary and GameLibrary.npcs and GameLibrary.npcs[npcName] then
                     local npcData = GameLibrary.npcs[npcName]
                     if npcData.dialogue then
                         for _, dlg in pairs(npcData.dialogue) do
                             if dlg.name and string.split(dlg.name, " - ")[1] == tostring(step) then
                                 questTasks = dlg.quest
                                 break
                             end
                         end
                     end
                 end
                 
                 -- Reset actions
                 _G.QuestFishMutation = nil
                 _G.AutoGeode = false
                 _G.QuestGeodeType = nil
                 _G.AutoQuestCollect = false
                 
                 if questTasks and #questTasks > 0 then
                     -- ═══ DYNAMIC: Read quest tasks to determine action ═══
                     local mutations = {}
                     local needGeode = false
                     local needCollect = false
                     local collectTarget = nil
                     
                     for _, task in ipairs(questTasks) do
                         local path = task.path
                         local goal = task.goal or 1
                         local taskName = string.lower(task.name or "")
                         local currentProgress = 0
                         
                         -- Get current progress for this task
                         if typeof(path) == "table" and path[1] == "inventory" then
                             -- Inventory-based task (collect items)
                             needCollect = true
                             if path[2] then collectTarget = path[2] end
                         elseif typeof(path) == "string" then
                             currentProgress = progress[path] or 0
                         end
                         
                          -- Skip completed objectives
                          if currentProgress >= goal then
                              -- This task is done, skip it
                          elseif taskName:find("geode") or taskName:find("crack") then
                              needGeode = true
                              -- Extract geode type from task name
                              -- Examples: "crack heart geodes", "crack 15 cactus geodes"
                              local GeodePresets = ReplicatedStorage.common.presets.items.geodes
                              if GeodePresets then
                                  for _, gModule in pairs(GeodePresets:GetChildren()) do
                                      if taskName:find(string.lower(gModule.Name)) then
                                          _G.QuestGeodeType = gModule.Name
                                          print("🎯 Quest Geode Type Detected: " .. gModule.Name)
                                          break
                                      end
                                  end
                              end
                          elseif typeof(path) == "string" and not taskName:find("talk") and not taskName:find("visit") then
                              -- String path that isn't a dialogue/visit task = likely a mutation
                              table.insert(mutations, path)
                          end
                     end
                     
                     -- Set action based on detected tasks
                     if #mutations == 1 then
                         _G.QuestFishMutation = mutations[1]
                         print("🎯 Quest Step " .. step .. ": Target -> " .. mutations[1])
                     elseif #mutations > 1 then
                         _G.QuestFishMutation = mutations
                         print("🎯 Quest Step " .. step .. ": Target -> " .. table.concat(mutations, " + "))
                     end
                     
                     if needGeode then
                         _G.AutoGeode = true
                         print("🎯 Quest Step " .. step .. ": Target -> Geodes")
                     end
                     
                     if needCollect then
                         _G.AutoQuestCollect = true
                         if collectTarget then _G.QuestCollectTarget = collectTarget end
                         print("🎯 Quest Step " .. step .. ": Target -> Collect " .. tostring(collectTarget))
                     end
                     
                     -- Build status text
                     local statusParts = {}
                     if _G.QuestFishMutation then
                         local m = _G.QuestFishMutation
                         if type(m) == "table" then
                             table.insert(statusParts, "Fish: " .. table.concat(m, "+"))
                         else
                             table.insert(statusParts, "Fish: " .. m)
                         end
                     end
                     if needGeode then table.insert(statusParts, "Geodes") end
                     if needCollect then table.insert(statusParts, "Collect: " .. tostring(collectTarget)) end
                     if #statusParts == 0 then table.insert(statusParts, "Monitoring...") end
                     
                     Window:Notify({
                         Title = "🎯 " .. npcName .. " Step " .. step,
                         Content = table.concat(statusParts, " | "),
                         Duration = 4,
                         Type = "Success"
                     })
                 else
                     -- ═══ FALLBACK: Read from progress keys directly ═══
                     -- If GameLibrary not available, use progress keys as mutation hints
                     local mutations = {}
                     for key, val in pairs(progress) do
                         if type(key) == "string" and type(val) == "number" then
                             -- Progress keys = likely mutation names
                             table.insert(mutations, key)
                         end
                     end
                     
                     if #mutations == 1 then
                         _G.QuestFishMutation = mutations[1]
                     elseif #mutations > 1 then
                         _G.QuestFishMutation = mutations
                     end
                     
                     print("🎯 Quest Step " .. step .. " (fallback): Progress keys = " .. table.concat(mutations, ", "))
                     Window:Notify({
                         Title = "🎯 " .. npcName .. " Step " .. step .. " (Fallback)",
                         Content = "Detected: " .. (#mutations > 0 and table.concat(mutations, "+") or "Unknown"),
                         Duration = 4
                     })
                 end
             end)
        end
        
        if _G.AutoQuestCollect then
             pcall(AutoCollectLoop)
        end
        if _G.AutoGeode then
             pcall(AutoGeodeLoop)
             pcall(AutoCrackGeode)
        end
    end
end)

-- Auto Fling / Noclip Logic (Simple Noclip)
RunService.Stepped:Connect(function()
    if AutoChestEnabled and AutoFlingEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Hide Identify Loop
task.spawn(function()
    while true do
        task.wait(1)
        if HideIdentifyEnabled then
            -- 1. Check Character
            local char = LocalPlayer.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    local oh = head:FindFirstChild("Overhead") or head:FindFirstChild("playerOverhead")
                    if oh and oh:FindFirstChild("Display") then
                        if not string.find(oh.Display.Text, "Lv. 999") then
                            oh.Display.Text = "<font color='#FFF0C8'>[Lv. 999]</font> " .. LocalPlayer.Name
                        end
                    end
                end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local att = hrp:FindFirstChild("OverheadAttachment")
                    if att then
                        local oh = att:FindFirstChild("playerOverhead")
                        if oh and oh:FindFirstChild("Display") then
                           if not string.find(oh.Display.Text, "Lv. 999") then
                                oh.Display.Text = "<font color='#FFF0C8'>[Lv. 999]</font> " .. LocalPlayer.Name
                           end
                        end
                    end
                end
            end
            
            -- 2. Check Debris (As per user dump)
            pcall(function()
                 if workspace:FindFirstChild("debris") then
                     local debrisParams = workspace.debris:GetChildren()
                     for _, obj in pairs(debrisParams) do
                         if obj.Name == LocalPlayer.Name or obj.Name == "Player" then
                             local function checkPart(part)
                                 local att = part:FindFirstChild("OverheadAttachment")
                                 if att then
                                     local oh = att:FindFirstChild("playerOverhead")
                                     if oh and oh:FindFirstChild("Display") then
                                         oh.Display.Text = "<font color='#FFF0C8'>[Lv. 999]</font> (NPN HUB)"
                                     end
                                 end
                             checkPart(obj.HumanoidRootPart)
                             end
                             
                             if obj:FindFirstChild("HumanoidRootPart") then
                             end
                             if obj:FindFirstChild("Head") then
                                  local oh = obj.Head:FindFirstChild("Overhead")
                                  if oh and oh:FindFirstChild("Display") then
                                      oh.Display.Text = "<font color='#FFF0C8'>[Lv. 999]</font> (NPN HUB)"
                                  end
                             end
                         end
                     end
                 end
            end)
        end
    end
end)

-- Anti Staff Logic
local StaffRanks = {
    [255] = "Owner",
    [254] = "Developer",
    [150] = "Community Manager",
    [130] = "Administrator",
    [121] = "Senior Moderator",
    [120] = "Moderator",
    [100] = "Content Manager",
    [50] = "Trial Moderator",
    [12] = "Content Creator",
    [6] = "Wiki Relations",
    [5] = "Tester"
}

local function CheckAntiStaff(player)
    if not AntiStaffEnabled then return end
    if player == LocalPlayer then return end
    
    local success, rank = pcall(function()
        return player:GetRankInGroup(STAFF_GROUP_ID)
    end)
    
    if success and rank then
        if StaffRanks[rank] then
             Window:Notify({
                Title="⚠️ ANTI STAFF ⚠️", 
                Content="Staff Detected: "..player.Name.." ("..StaffRanks[rank].."). KICKING!", 
                Duration=10, 
                Type="Error"
            })
            task.wait(0.5)
            LocalPlayer:Kick("Anti Staff Triggered: " .. player.Name .. " is " .. StaffRanks[rank])
        end
    end
end

local function StartAntiStaff()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function() CheckAntiStaff(player) end)
    end
    
    if AntiStaffConnection then AntiStaffConnection:Disconnect() end
    AntiStaffConnection = Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        CheckAntiStaff(player)
    end)
end

local function StopAntiStaff()
    if AntiStaffConnection then
        AntiStaffConnection:Disconnect()
        AntiStaffConnection = nil
    end
end

-- Main Loop Hook
task.spawn(function()
    while true do
        if AutoChestEnabled and not State.Busy then
            AutoChestLoop()
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if AutoRespawnEnabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    Window:Notify({Title="Auto Respawn", Content="Respawning...", Duration=2})
                    pcall(function()
                        RespawnFunc:InvokeServer("free")
                    end)
                    task.wait(2) 
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5) 
        if AutoClaimBestiaryEnabled then
            local replica = DataController:GetReplica()
            if replica and replica.Data and replica.Data.bestiary and replica.Data.bestiary.fish then
                local discovered = replica.Data.bestiary.fish.discovered
                local claimed = replica.Data.bestiary.fish.claimed or {}
                
                for fishName, _ in pairs(discovered) do
                     if not AutoClaimBestiaryEnabled then break end
                     
                     -- If not claimed
                     if not claimed[fishName] then
                         Window:Notify({Title="Bestiary", Content="Claiming: "..fishName, Duration=2})
                         
                         pcall(function()
                             ClaimRewardFunc:InvokeServer(fishName)
                         end)
                         
                         task.wait(1) 
                     end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1) 
        
        if AutoSellEnabled and not State.Selling then
            State.Selling = true -- Set IMMEDIATELY to prevent race condition
            local isFull = IsInventoryFull() 
            
            if isFull then
                local wasAutoFishing = AutoTest
                
                
                if wasAutoFishing then
                    AutoTest = false
                    -- Wait for active minigame to finish before teleporting
                    if MinigameController:IsMinigameActive() then
                        Window:Notify({Title="Auto Sell", Content="Waiting for minigame to finish...", Duration=2})
                        local waitStart = tick()
                        while MinigameController:IsMinigameActive() and (tick() - waitStart < 30) do
                            task.wait(0.5)
                        end
                        task.wait(0.5) -- Safety delay after minigame
                    end
                    -- Wait for State.Busy to clear
                    local t = 0
                    while State.Busy and t < 20 do
                        t = t + 1
                        task.wait(0.1)
                    end
                end
                
                State.Busy = true
                Window:Notify({Title="Auto Sell", Content="Inventory Full ("..SellThreshold.."%). Selling...", Duration=3})
                
                local hrp = getHRP()
                
                if hrp then
                    local currentPos = hrp.Position
                    
                    -- Dynamic Safe Spot (Nearest NPC)
                    local npcFolder = workspace:WaitForChild("Game"):WaitForChild("Interactables"):WaitForChild("Npc")
                    local bestSpot = nil
                    local bestDist = 9999999
                    
                    for _, npc in pairs(npcFolder:GetChildren()) do
                        if npc:IsA("Model") and (npc.Name == "Kraken" or npc.Name == "Merchant" or npc.Name == "Shipwright") then
                             local pivot = npc:GetPivot().Position
                             local dist = (pivot - currentPos).Magnitude
                             if dist < bestDist then
                                 bestDist = dist
                                 bestSpot = pivot + Vector3.new(0, 15, 30) -- Safe Offset
                             end
                        end
                    end
                    
                    -- Fallback to Kraken Fixed Pos if scan fails
                    if not bestSpot then 
                         bestSpot = FALLBACK_SAFE_POS
                    end
                    
                    -- Execute Sell
                    Window:Notify({Title="Auto Sell", Content="Teleporting to Safe Spot...", Duration=3})
                    
                    StealthTeleport(bestSpot)
                    
                    task.wait(1.5)
                    
                    local earned = 0
                    pcall(function()
                        if SellFishFunc then 
                            local result = SellFishFunc:InvokeServer() 
                        end
                        
                        if SellInventoryFunc then
                            local result = SellInventoryFunc:InvokeServer()
                        end

                        if UpdateAutoSellFunc then 
                            UpdateAutoSellFunc:InvokeServer() 
                        end
                    end)
                    
                    task.wait(2)
                    
                    -- Return to previous spot
                    StealthTeleport(currentPos)
                    task.wait(0.5)
                end
                
                State.Selling = false
                State.Busy = false
                if wasAutoFishing then
                    AutoTest = true
                    AutoFishLoop()
                end
            else
                -- Not full, release the lock
                State.Selling = false
            end
        end
    end
end)

do
    local FishingTab = Window:CreateTab("Fishing")

    local AutoFishingCollapsible = FishingTab:CreateCollapsible({
        Name = "Auto Fishing",
        DefaultOpen = false
    })

    local SmartFishing = FishingTab:CreateCollapsible({
        Name = "Smart Auto Fishing",
        DefaultOpen = true
    })

    SmartFishing:AddToggle({
        Name = "Smart Priority",
        Default = true,
        Callback = function(v)
            SmartPriorityEnabled = v
        end
    })

    SmartFishing:AddDropdown({
        Name = "Select Rarities",
        Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic"},
        Flag = "RaritySelects",
        MultiSelect = true,
        Callback = function(items)
            -- Convert list to lookup table for fast checking
            SelectedRarities = {}
            for v, selected in pairs(items) do
                 if selected then -- FluxUI usually returns {Option=true/false} or list of strings depending on vers.
                     -- Assuming list of strings based on user example, but protecting against k,v
                     if type(v) == "string" then SelectedRarities[v] = true 
                     else SelectedRarities[v] = true end -- Key based
                 end
            end
            
            -- User example: `items` is the list. Let's assume standard behavior:
            -- If items is {"Common", "Rare"}, then:
            if type(items) == "table" then
                 SelectedRarities = {}
                 for k, v in pairs(items) do
                     if type(k) == "string" then -- Key-Value format {Common=true}
                         if v then SelectedRarities[k] = true end
                     else -- Array format {"Common"}
                         SelectedRarities[v] = true 
                     end
                 end
            end
        end
    })

    SmartFishing:AddSlider({
        Name = "Rarity Weight",
        Min = 0.1,
        Max = 0.8,
        Default = 0.4,
        Callback = function(v) RarityWeight = v end
    })

    -- Di dalam FishingTab
    AutoFishingCollapsible:AddDropdown({
        Name = "Auto Fish Mode",
        Default = "Off",
        Options = {"Off", "Normal", "Instant", "Instant V2", "Blatant"},
        Callback = function(mode)
            FishingMode = mode
            AutoTest = (mode ~= "Off")
            
            if AutoTest then
                task.wait(0.4)
                AutoFishLoop()
            end
            
            Window:Notify({
                Title = "Mode Changed",
                Content = "Now using **" .. mode .. "**",
                Duration = 2.5,
                Type = "Success"
            })
        end
    })

    AutoFishingCollapsible:AddToggle({
        Name = "Anti-Gravity (Instant Mode Only)",
        Default = false,
        Callback = function(v)
            AntiGravityEnabled = v
            Window:Notify({
                Title = "Anti Gravity",
                Content = v and "Enabled (Bar won't fall)" or "Disabled",
                Duration = 2
            })
        end
    })

    -- Mutation Filter: Load mutation names from game presets
    local MutationNames = {}
    pcall(function()
        local mutPresets = ReplicatedStorage:WaitForChild("common"):WaitForChild("presets"):WaitForChild("fish"):WaitForChild("mutations")
        for _, obj in pairs(mutPresets:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                -- Module name = mutation name
                if not table.find(MutationNames, obj.Name) then
                    table.insert(MutationNames, obj.Name)
                end
            elseif obj:IsA("Folder") and obj.Parent == mutPresets then
                -- Top-level folder name = mutation name
                if not table.find(MutationNames, obj.Name) then
                    table.insert(MutationNames, obj.Name)
                end
            end
        end
    end)
    table.sort(MutationNames)
    
    -- Fallback if presets couldn't be loaded
    if #MutationNames == 0 then
        MutationNames = {"Cupid", "Lonely", "Toxic", "Golden", "Albino", "Frozen", "Mythical", "Shadow"}
    end
    
    _G.MutationFilter = {} -- Active mutation filter list
    
    AutoFishingCollapsible:AddDropdown({
        Name = "Mutation Filter",
        Options = MutationNames,
        Flag = "MutationFilterSelect",
        MultiSelect = true,
        Callback = function(items)
            _G.MutationFilter = {}
            if type(items) == "table" then
                for k, v in pairs(items) do
                    if type(k) == "string" then
                        if v then table.insert(_G.MutationFilter, k) end
                    else
                        table.insert(_G.MutationFilter, v)
                    end
                end
            end
            
            if #_G.MutationFilter > 0 then
                local note = table.concat(_G.MutationFilter, ", ")
                if _G.AutoQuestBigBoss then
                    note = note .. " (Big Boss has priority)"
                end
                Window:Notify({Title="Mutation Filter", Content="Targeting: " .. note, Duration=3})
            else
                Window:Notify({Title="Mutation Filter", Content="Filter disabled — catching all fish", Duration=2})
            end
        end
    })

    -- Fishing Area Dropdown: Load area names from game presets
    local FishingAreaNames = {"All"}
    pcall(function()
        local fishPresets = ReplicatedStorage:WaitForChild("common"):WaitForChild("presets"):WaitForChild("items"):WaitForChild("fish")
        for _, areaFolder in pairs(fishPresets:GetChildren()) do
            table.insert(FishingAreaNames, areaFolder.Name)
        end
    end)
    table.sort(FishingAreaNames, function(a, b)
        if a == "All" then return true end
        if b == "All" then return false end
        return a < b
    end)
    
    _G.SelectedFishingArea = "All"
    
    AutoFishingCollapsible:AddDropdown({
        Name = "Fishing Area",
        Default = "All",
        Options = FishingAreaNames,
        Callback = function(v)
            _G.SelectedFishingArea = v
            if v == "All" then
                Window:Notify({Title="Fishing Area", Content="Fishing in all areas", Duration=2})
            else
                local fishNames = {}
                pcall(function()
                    local areaFolder = ReplicatedStorage.common.presets.items.fish:FindFirstChild(v)
                    if areaFolder then
                        for _, fishItem in pairs(areaFolder:GetChildren()) do
                            table.insert(fishNames, fishItem.Name)
                        end
                    end
                end)
                local info = (#fishNames > 0) and ("Fish: " .. table.concat(fishNames, ", ")) or ""
                Window:Notify({Title="Fishing Area", Content="Area: " .. v .. "\n" .. info, Duration=4})
            end
        end
    })

    AutoFishingCollapsible:AddSlider({
        Name = "Move Speed (studs/frame)",
        Min = 1,
        Max = 10,
        Default = 2,
        Increment = 0.5,
        Callback = function(v)
            _G.TeleportMoveSpeed = v
        end
    })

    AutoFishingCollapsible:AddSlider({
        Name = "Max Speed (studs/frame)",
        Min = 1,
        Max = 15,
        Default = 5,
        Increment = 0.5,
        Callback = function(v)
            _G.TeleportMaxSpeed = v
        end
    })

    AutoFishingCollapsible:AddDivider()

    local HelperCollapsible = FishingTab:CreateCollapsible({
        Name = "Helper",
        DefaultOpen = true
    })

    HelperCollapsible:AddToggle({
        Name = "Infinite Oxygen",
        Default = false,
        Callback = function(v)
            InfiniteOxygenEnabled = v
        end
    })

    HelperCollapsible:AddToggle({
        Name = "Auto Sell", 
        Default = false, 
        Callback = function(v) 
            AutoSellEnabled = v
            Wait(0.2)
            Window:Notify({ 
                Title = "Smart Auto Sell", 
                Content = v and "Enabled (Limit: "..SellThreshold.."%)" or "Disabled", 
                Duration = 2, 
                Type = v and "Success" or "Warning" 
            }) 
        end 
    })
    
    HelperCollapsible:AddSlider({
        Name = "Sell Threshold (%)",
        Min = 10,
        Max = 100,
        Default = 80,
        Callback = function(v)
            SellThreshold = v
        end
    })

    HelperCollapsible:AddToggle({
        Name = "Oxygen Safe (Auto Rescue)", 
        Default = false, 
        Callback = function(v) 
            OxygenSafeEnabled = v
        end 
    })
end

do
    local AutoTab = Window:CreateTab("Auto")

    local ChestCollapsible = AutoTab:CreateCollapsible({Name = "Auto Unlock Chest", DefaultOpen = false})

    ChestCollapsible:AddToggle({
        Name = "Auto Unlock Chests",
        Default = false,
        Callback = function(t)
            AutoChestEnabled = t
            AutoFlingEnabled = t 
            if not t then
                State.Busy = false 
            end
        end
    })

    ChestCollapsible:AddDropdown({
        Name = "Select Tier",
        Default = "All",
        Options = {"All", "Tier 1", "Tier 2", "Tier 3"},
        Callback = function(v)
            SelectedChestTier = v
        end
    })
    
    local RespawnCollapsible = AutoTab:CreateCollapsible({Name = "Auto Respawn", DefaultOpen = false})

    RespawnCollapsible:AddToggle({
        Name = "Auto Respawn",
        Default = false,
        Callback = function(t)
            AutoRespawnEnabled = t
            Window:Notify({
                Title = "Auto Respawn",
                Content = t and "Enabled (Will Fast Respawn on Death)" or "Disabled",
                Duration = 2,
                Type = t and "Success" or "Warning"
            })
        end
    })

    local BestiaryCollapsible = AutoTab:CreateCollapsible({Name = "Auto Claim Bestiary", DefaultOpen = false})
    BestiaryCollapsible:AddToggle({
        Name = "Auto Claim Bestiary",
        Default = false,
        Callback = function(t)
            AutoClaimBestiaryEnabled = t
            Window:Notify({
                 Title = "Auto Bestiary",
                 Content = t and "Enabled (Will claim rewards)" or "Disabled",
                 Duration = 2,
                 Type = t and "Success" or "Warning"
            })
            
            if t then
                task.spawn(function()
                    while AutoClaimBestiaryEnabled do
                        pcall(function()
                             -- Loop through bestiary data if available
                             local replica = DataController:GetReplica()
                             if replica and replica.Data and replica.Data.bestiary then
                                 for catName, catData in pairs(replica.Data.bestiary) do
                                     if type(catData) == "table" then
                                         for itemName, itemData in pairs(catData) do
                                             if itemData.r and not itemData.c then -- r=reward available, c=claimed
                                                  -- Claim Logic
                                                  -- Window:Notify({Title="Bestiary", Content="Claiming: "..itemName, Duration=1})
                                                  local success, err = pcall(function()
                                                      ClaimRewardFunc:InvokeServer(catName, itemName)
                                                  end)
                                                  if success then
                                                       -- print("Claimed Bestiary: " .. itemName)
                                                       task.wait(0.5)
                                                  end
                                             end
                                         end
                                     end
                                 end
                             end
                        end)
                        task.wait(5) -- Check every 5 seconds
                    end
                end)
            end
        end
    })
    
    -- Auto Quest Feature
    local QuestCollapsible = AutoTab:CreateCollapsible({Name = "Auto Quest", DefaultOpen = false})
    
    local AutoAcceptQuestEnabled = false
    local AutoFinishQuestEnabled = false
    
    -- Global Variable (shared with AutoFishLoop)
    _G.TargetMutation = nil

    local function GetActiveQuestOptions()
        local options = {"None"}
        pcall(function()
            local replica = DataController:GetReplica()
            if replica and replica.Data and replica.Data.quests and replica.Data.quests.active then
                for npcName, _ in pairs(replica.Data.quests.active) do
                    table.insert(options, npcName .. " - Auto Detect")
                end
            end
        end)
        if #options == 1 then
            table.insert(options, "Big Boss - Auto Detect")
        end
        table.insert(options, "Scientist - Fix Teleporter")
        return options
    end

    local questOptions = GetActiveQuestOptions()

    local QuestDropdown = QuestCollapsible:AddDropdown({
        Name = "Auto Complete Quest",
        Default = "None",
        Options = questOptions,
        Callback = function(v)
            if v:find("- Auto Detect") then
                local npcName = v:split(" - Auto Detect")[1]
                _G.AutoQuestBigBoss = true
                _G._autoQuestNPC = npcName
                _G.QuestFishMutation = nil
                _G.AutoQuestCollect = false
                _G.QuestCollectTarget = nil
                _G.AutoGeode = false
                _G._lastBBStep = nil
                Window:Notify({Title="Quest Mode", Content="Smart Detect Active: " .. npcName .. " quest...", Duration=3})
            
            elseif v == "Scientist - Fix Teleporter" then
                _G.AutoQuestBigBoss = false
                _G._autoQuestNPC = nil
                _G.QuestFishMutation = nil
                _G.AutoQuestCollect = true
                _G.QuestCollectTarget = "TeleporterParts"
                _G.AutoGeode = false
                _G._lastBBStep = nil
                Window:Notify({Title="Quest Mode", Content="Auto Collecting Teleporter Parts...", Duration=3})
            else
                _G.AutoQuestBigBoss = false
                _G._autoQuestNPC = nil
                _G.QuestFishMutation = nil
                _G.AutoQuestCollect = false
                _G.QuestCollectTarget = nil
                _G.AutoGeode = false
                _G.QuestGeodeType = nil
                _G._lastBBStep = nil
                Window:Notify({Title="Quest Mode", Content="Auto Quest features disabled.", Duration=3})
            end
        end
    })
    
    QuestCollapsible:AddButton({
        Name = "Refresh Quests",
        Callback = function()
            local newOptions = GetActiveQuestOptions()
            QuestDropdown:Refresh(newOptions)

            Window:Notify({
                Title = "Quests Refreshed",
                Content = "Checked for new active quests!",
                Duration = 2
            })
        end
    })

    -- === GEODE TYPE DROPDOWN ===
    local GeodeNames = {"All"}
    pcall(function()
        local GeodePresets = ReplicatedStorage.common.presets.items.geodes
        if GeodePresets then
            for _, gModule in pairs(GeodePresets:GetChildren()) do
                table.insert(GeodeNames, gModule.Name)
            end
        end
    end)
    
    QuestCollapsible:AddDropdown({
        Name = "Geode Type",
        Default = "All",
        Options = GeodeNames,
        Callback = function(v)
            _G.SelectedGeode = v
            if v == "All" then
                Window:Notify({
                    Title = "Geode Type",
                    Content = "Will crack ALL available geodes",
                    Duration = 2
                })
            else
                -- Show geode info from preset
                local info = ""
                pcall(function()
                    local mod = ReplicatedStorage.common.presets.items.geodes:FindFirstChild(v)
                    if mod then
                        local data = require(mod)
                        local items = {}
                        for _, chance in ipairs(data.chances or {}) do
                            table.insert(items, chance.name .. " (" .. chance.chance .. "%)")
                        end
                        info = "\nPrice: " .. tostring(data.price) .. " | Duration: " .. tostring(data.duration) .. "s"
                        if #items > 0 then
                            info = info .. "\nDrops: " .. table.concat(items, ", ")
                        end
                    end
                end)
                Window:Notify({
                    Title = "Geode Type",
                    Content = "Selected: " .. v .. " Geode" .. info,
                    Duration = 4,
                    Type = "Success"
                })
            end
        end
    })
    
    -- === AUTO CRACK GEODES TOGGLE ===
    QuestCollapsible:AddToggle({
        Name = "Auto Crack Geodes",
        Default = false,
        Callback = function(t)
            _G.AutoGeode = t
            if t then
                local targetType = _G.QuestGeodeType or (_G.SelectedGeode ~= "All" and _G.SelectedGeode) or "All Types"
                Window:Notify({
                    Title = "Auto Geode",
                    Content = "Enabled - Target: " .. tostring(targetType),
                    Duration = 3,
                    Type = "Success"
                })
            else
                _G.QuestGeodeType = nil
                Window:Notify({
                    Title = "Auto Geode",
                    Content = "Disabled",
                    Duration = 2,
                    Type = "Warning"
                })
            end
        end
    })
    
    QuestCollapsible:AddToggle({
        Name = "Auto Accept/Claim Quest",
        Default = false,
        Callback = function(t)
            AutoAcceptQuestEnabled = t
            if t then
                 Window:Notify({Title="Auto Accept", Content="Trying to claim quests from nearby NPCs...", Duration=3})
            end
        end
    })
    
    QuestCollapsible:AddToggle({
        Name = "Auto Finish/Complete Quest",
        Default = false,
        Callback = function(t)
            AutoFinishQuestEnabled = t
            if t then
                 Window:Notify({Title="Auto Finish", Content="Trying to complete active quests...", Duration=3})
            end
        end
    })
    
    -- Auto Quest Logic
    task.spawn(function()
        while true do
            task.wait(2)
            if AutoAcceptQuestEnabled or AutoFinishQuestEnabled then
                local replica = DataController:GetReplica()
                
                -- Auto Accept
                if AutoAcceptQuestEnabled and LocalPlayer.Character then
                    pcall(function()
                        -- Get Quest/Interact Keys from Game Module (Smart Brute-Force)
                        local interactions = {}
                        local success, data = pcall(function() 
                            return require(game:GetService("ReplicatedStorage").common.presets.questReply)
                        end)
                        
                        if success and type(data) == "table" then
                            for key, _ in pairs(data) do
                                table.insert(interactions, key)
                            end
                        end
                        -- Add minimal defaults if module read failed
                        if #interactions == 0 then 
                            interactions = {"deliver_crates", "deliver_love_letters", "bring_item", "open_door"} 
                        end
                        
                        local npcFolder = workspace:WaitForChild("Game"):WaitForChild("Interactables"):WaitForChild("Npc")
                        for _, npc in pairs(npcFolder:GetChildren()) do
                             if not AutoAcceptQuestEnabled then break end
                             if npc:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                 local dist = (LocalPlayer.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                                 if dist < 20 then 
                                     local qs = Services:WaitForChild("QuestsService")
                                     if qs and qs:FindFirstChild("RF") then
                                         -- 1. Try Simple ClaimQuest
                                         if qs.RF:FindFirstChild("ClaimQuest") then
                                             print("Trying ClaimQuest: " .. npc.Name)
                                             qs.RF.ClaimQuest:InvokeServer(npc.Name)
                                         end
                                         
                                         -- 2. Try SubmitNpcInteract with ALL KEYS
                                         if qs.RF:FindFirstChild("SubmitNpcInteract") then
                                             for _, key in ipairs(interactions) do
                                                 print("Trying SubmitNpcInteract: " .. npc.Name .. " - " .. key)
                                                 qs.RF.SubmitNpcInteract:InvokeServer(npc.Name, key)
                                             end
                                         end

                                         -- 3. Try SubmitNpcDialogueInteract with ALL KEYS
                                          if qs.RF:FindFirstChild("SubmitNpcDialogueInteract") then
                                             for _, key in ipairs(interactions) do
                                                 qs.RF.SubmitNpcDialogueInteract:InvokeServer(npc.Name, key)
                                             end
                                         end
                                         
                                         -- 4. Try SubmitReplyCall (For Dialogue Choices like Big Boss)
                                         if qs.RF:FindFirstChild("SubmitReplyCall") then
                                             -- Try indices 1 to 5 (Blindly select options)
                                             for i = 1, 5 do
                                                 -- print("Trying SubmitReplyCall: " .. npc.Name .. " - Option " .. i)
                                                 qs.RF.SubmitReplyCall:InvokeServer(npc.Name, i)
                                             end
                                         end

                                         -- 5. Try TrackQuest (As Requested)
                                         if qs.RF:FindFirstChild("TrackQuest") then
                                             -- print("Trying TrackQuest: " .. npc.Name)
                                             qs.RF.TrackQuest:InvokeServer(npc.Name)
                                         end
                                     end
                                 end
                             end
                        end
                    end)
                end
                
                -- Auto Finish
                if AutoFinishQuestEnabled and replica and replica.Data then
                    -- print("Checking Active Quests...")
                    if replica.Data.quests and replica.Data.quests.active then
                        pcall(function()
                            for npcName, questData in pairs(replica.Data.quests.active) do
                                 -- print("Found Active Quest: " .. npcName .. " (" .. tostring(questData.name) .. ")")
                                 local qs = Services:WaitForChild("QuestsService")
                                 if qs and qs:FindFirstChild("RF") and qs.RF:FindFirstChild("FinishQuest") then
                                     qs.RF.FinishQuest:InvokeServer(npcName)
                                 end
                            end
                        end)
                    else
                        -- print("No active quests found in data.")
                    end
                end
            end
        end
    end)
end

do
    local ShopTab = Window:CreateTab("Shop & Items")
    local MerchantCollapsible = ShopTab:CreateCollapsible({Name = "Merchant", DefaultOpen = true})
    
    local SelectedMerchant = nil
    local SelectedItem = nil
    local SelectedAmount = 1
    
    local MerchantItems = {} 
    local MerchantStructure = {} 
    
    local MerchantCache = {}
    local LastMerchantRefresh = 0
    local MerchantRefreshInterval = 60

    local function RefreshMerchants(force)
        if not force and (tick() - LastMerchantRefresh < MerchantRefreshInterval) and next(MerchantCache) then
             return MerchantCache
        end
        
        local replica = DataController:GetReplica()
        local merchants = {}
        MerchantItems = {}
        MerchantStructure = {}
        
        if replica and replica.Data and replica.Data.merchant_stocks then
            for merchName, data in pairs(replica.Data.merchant_stocks) do
                table.insert(merchants, merchName)
                MerchantItems[merchName] = {}
                MerchantStructure[merchName] = {}
                
                if data.stock then
                    for index, itemData in pairs(data.stock) do
                        if itemData.item then
                            table.insert(MerchantItems[merchName], itemData.item)
                            MerchantStructure[merchName][itemData.item] = index
                        end
                    end
                end
            end
        end
        
        MerchantCache = merchants
        LastMerchantRefresh = tick()
        return merchants
    end
    local MerchantDropdown = MerchantCollapsible:AddDropdown({
        Name = "Select Merchant",
        Default = "",
        Options = RefreshMerchants(),
        Callback = function(v)
            SelectedMerchant = v
        end
    })
    
    task.spawn(function()
        while true do
            task.wait(1)
            if SelectedMerchant and MerchantItems[SelectedMerchant] then
            end
        end
    end)
    
    local ItemDropdown = MerchantCollapsible:AddDropdown({
        Name = "Select Item",
        Default = "",
        Options = {},
        Callback = function(v)
            SelectedItem = v
        end
    })

    MerchantCollapsible:AddButton({
        Name = "Refresh Items",
        Callback = function()
             local newMerchants = RefreshMerchants(true) -- Force Refresh
             pcall(function() MerchantDropdown:SetOptions(newMerchants) end)
             
             if SelectedMerchant and MerchantStructure[SelectedMerchant] then
                 local currentItems = {}
                 for itemName, _ in pairs(MerchantStructure[SelectedMerchant]) do
                     table.insert(currentItems, itemName)
                 end
                 table.sort(currentItems)
                 pcall(function() ItemDropdown:SetOptions(currentItems) end)
                 Window:Notify({Title="Lists Refreshed", Content="Items for "..SelectedMerchant.." loaded!", Duration=2})
             else
                 pcall(function() ItemDropdown:SetOptions({}) end)
                 Window:Notify({Title="Lists Refreshed", Content="Select a Merchant first!", Duration=2})
             end
        end
    })
    
    MerchantCollapsible:AddDropdown({
        Name = "Amount",
        Default = "1",
        Options = {"1", "2", "3", "4", "5", "10", "20", "50", "100"},
        Callback = function(v)
            SelectedAmount = tonumber(v) or 1
        end
    })
    
    MerchantCollapsible:AddButton({
        Name = "💰 Buy Item",
        Callback = function()
            if SelectedMerchant and SelectedItem then
                local merchStruct = MerchantStructure[SelectedMerchant]
                if merchStruct and merchStruct[SelectedItem] then
                    local index = merchStruct[SelectedItem]
                    local amount = SelectedAmount
                    
                    Window:Notify({Title="Merchant", Content="Buying "..amount.."x "..SelectedItem, Duration=2})
                    
                    pcall(function()
                        local success, err = pcall(function()
                            BuyItemFunc:InvokeServer(SelectedMerchant, index, amount)
                        end)
                        
                        if success then
                             Window:Notify({Title="Merchant", Content="Successfully bought "..amount.."x "..SelectedItem, Duration=2, Type="Success"})
                        else
                             Window:Notify({Title="Purchase Failed", Content="Error: "..tostring(err), Duration=3, Type="Error"})
                        end
                    end)
                else
                    Window:Notify({Title="Error", Content="Item not found! Refresh list?", Duration=3, Type="Error"})
                end
            else
                Window:Notify({Title="Error", Content="Select Merchant-Item!", Duration=3, Type="Error"})
            end
        end
    })
end

do
    local SettingsTab = Window:CreateTab("Settings")

    local MiscCollapsible = SettingsTab:CreateCollapsible({
        Name = "Misc",
        DefaultOpen = false
    })
    
    MiscCollapsible:AddToggle({
        Name = "Fling / Noclip (Tembus Tembok)",
        Default = false,
        Callback = function(v)
            SetNoclip(v)
            Window:Notify({
                Title = "Noclip",
                Content = v and "Enabled (Walk through walls)" or "Disabled",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })
        end
    })
    
    MiscCollapsible:AddToggle({
        Name = "Anti Staff",
        Default = false,
        Callback = function(v)
            AntiStaffEnabled = v
            if v then
                StartAntiStaff()
                Window:Notify({
                    Title = "Anti Staff",
                    Content = "Shield Active! Scanning for staff...",
                    Duration = 3,
                    Type = "Success"
                })
            else
                StopAntiStaff()
                Window:Notify({
                    Title = "Anti Staff",
                    Content = "Disabled",
                    Duration = 2,
                    Type = "Warning"
                })
            end
        end
    })
    
    local HideIdentifyCollapsible = SettingsTab:CreateCollapsible({
        Name = "Hide Identify",
        DefaultOpen = false
    })
    
    HideIdentifyCollapsible:AddToggle({
        Name = "Spoof Level 999",
        Default = false,
        Callback = function(v)
            HideIdentifyEnabled = v
             Window:Notify({
                Title = "Hide Identify",
                Content = v and "Enabled - Spoofing Overhead to Lv. 999" or "Disabled",
                Duration = 2,
                Type = v and "Success" or "Warning"
            })
        end
    })

    -- ── Developer Access ──
    local DevCollapsible = SettingsTab:CreateCollapsible({
        Name = "Developer Tools",
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

do
    local Tab3 = Window:CreateTab("Themes", "http://www.roblox.com/asset/?id=6022668955")

    Tab3:CreateLabel("Select a Theme")

    local themes = {"Modern", "Dark", "Light", "Purple", "Ocean", "Sunset", "Rose", "Emerald", "Midnight"}

    Tab3:CreateDropdown({
        Name = "Choose Theme",
        Options = themes,
        Default = "Midnight",
        Callback = function(selectedTheme)
            Window:SetTheme(selectedTheme)
            Window:Notify({
                Title = "Theme Changed",
                Content = "Applied theme: " .. selectedTheme,
                Duration = 2
            })
        end
    })

    Tab3:CreateLabel("Custom Theme Example")

    Tab3:CreateButton({
        Name = "Apply Custom 'Matrix' Theme",
        Callback = function()
            -- Add a custom theme dynamically
            Window:AddTheme("Matrix", {
                Background = Color3.fromRGB(0, 10, 0),
                Secondary = Color3.fromRGB(0, 20, 0),
                Tertiary = Color3.fromRGB(0, 30, 0),
                Accent = Color3.fromRGB(0, 255, 0),
                AccentHover = Color3.fromRGB(50, 255, 50),
                Text = Color3.fromRGB(200, 255, 200),
                TextDim = Color3.fromRGB(100, 200, 100),
                Border = Color3.fromRGB(0, 100, 0),
                AccentGradient = {Color3.fromRGB(0, 200, 0), Color3.fromRGB(0, 255, 0)}
            })
            
            Window:SetTheme("Matrix")
        end
    })
end
