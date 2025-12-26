-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "NPN Hub Premium",
    Icon = "rbxassetid://116236936447443",
    Author = "XYOURZONE",
    Folder = "RockHubExtracted",
    Size = UDim2.fromOffset(600, 360),
    Transparent = true,
    Resizable = true,
})

WindUI:AddTheme({
    Name = "My Theme", -- theme name
    
    
    -- More Soon!
    
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"), -- Accent
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
    
    Hover = Color3.fromHex("#FFFFFF"), -- Text
    BackgroundTransparency = 0,
    
    WindowBackground = Color3.fromHex("101010"), -- Background
    WindowShadow = Color3.fromHex("000000"),
    
    DialogBackground = Color3.fromHex("#101010"), -- Background
    DialogBackgroundTransparency = 0, -- BackgroundTransparency
    DialogTitle = Color3.fromHex("#FFFFFF"), -- Text
    DialogContent = Color3.fromHex("#FFFFFF"), -- Text
    DialogIcon = Color3.fromHex("#a1a1aa"), -- Icon
    
    WindowTopbarButtonIcon = Color3.fromHex("a1a1aa"), -- Icon
    WindowTopbarTitle = Color3.fromHex("FFFFFF"), -- Text
    WindowTopbarAuthor = Color3.fromHex("FFFFFF"), -- Text
    WindowTopbarIcon = Color3.fromHex("FFFFFF"), -- Text
    
    TabBackground = Color3.fromHex("#FFFFFF"), -- Text
    TabTitle = Color3.fromHex("#FFFFFF"), -- Text
    TabIcon = Color3.fromHex("a1a1aa"), -- Icon
    
    ElementBackground = Color3.fromHex("#FFFFFF"), -- Text
    ElementTitle = Color3.fromHex("#FFFFFF"), -- Text
    ElementDesc = Color3.fromHex("#FFFFFF"), -- Text
    ElementIcon = Color3.fromHex("#a1a1aa"), -- Icon
    
    PopupBackground = Color3.fromHex("#101010"), -- Background
    PopupBackgroundTransparency = 0, -- BackgroundTransparency
    PopupTitle = Color3.fromHex("#FFFFFF"), -- Text
    PopupContent = Color3.fromHex("#FFFFFF"), -- Text
    PopupIcon = Color3.fromHex("#a1a1aa"), -- Icon
    
    DialogBackground = Color3.fromHex("#101010"), -- Background
    DialogBackgroundTransparency = 0, -- Transparency
    DialogTitle = Color3.fromHex("#FFFFFF"), -- Text
    DialogContent = Color3.fromHex("#FFFFFF"), -- Text
    DialogIcon = Color3.fromHex("#a1a1aa"), -- Icon
    
    Toggle = Color3.fromHex("#52525b"), -- Button
    ToggleBar = Color3.fromHex("#FFFFFF"), -- White
    
    Checkbox = Color3.fromHex("#52525b"), -- Button
    CheckboxIcon = Color3.fromHex("#FFFFFF"), -- White
    
    Slider = Color3.fromHex("#52525b"), -- Button
    SliderThumb = Color3.fromHex("#FFFFFF"), -- White
    
})

-- [[ GLOBAL VARIABLES & SERVICES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Helper untuk Registry (Agar UI tidak error saat dipanggil Reg)
local RockHubConfig = Window.ConfigManager:CreateConfig("rockhub_extracted")
local ElementRegistry = {}
local function Reg(id, element)
    RockHubConfig:Register(id, element)
    ElementRegistry[id] = element
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

-- Remote Handling (Untuk Fishing)
local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
local function GetRemote(remotePath, name, timeout)
    local currentInstance = RepStorage
    for _, childName in ipairs(remotePath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

-- =================================================================
-- 1. TAB PLAYER & LOGIC
-- =================================================================
do
    local player = Window:Tab({ Title = "Player", Icon = "user" })
    local movement = player:Section({ Title = "Movement", TextSize = 20 })

    -- Variables
    local DEFAULT_SPEED = 16
    local DEFAULT_JUMP = 50
    local InfinityJumpConnection = nil
    
    -- WalkSpeed
    local SliderSpeed = Reg("Walkspeed", movement:Slider({
        Title = "WalkSpeed", Step = 1,
        Value = { Min = 16, Max = 200, Default = 16 },
        Callback = function(value)
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = tonumber(value) end
        end,
    }))

    -- JumpPower
    local SliderJump = Reg("slidjump", movement:Slider({
        Title = "JumpPower", Step = 1,
        Value = { Min = 50, Max = 200, Default = 50 },
        Callback = function(value)
            local hum = GetHumanoid()
            if hum then hum.JumpPower = tonumber(value) end
        end,
    }))

    -- Reset Movement
    movement:Button({
        Title = "Reset Movement", Icon = "rotate-ccw",
        Callback = function()
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = DEFAULT_SPEED
                hum.JumpPower = DEFAULT_JUMP
                SliderSpeed:Set(DEFAULT_SPEED)
                SliderJump:Set(DEFAULT_JUMP)
            end
        end
    })

    -- Freeze Player
    Reg("frezee", movement:Toggle({
        Title = "Freeze Player", Desc = "Anti-Push / Anchor Position",
        Value = false,
        Callback = function(state)
            local hrp = GetHRP()
            if hrp then
                hrp.Anchored = state
                if state then
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    hrp.Velocity = Vector3.new(0,0,0)
                end
            end
        end
    }))

    -- ABILITIES SECTION
    local ability = player:Section({ Title = "Abilities", TextSize = 20 })

    -- Infinite Jump
    Reg("infj", ability:Toggle({
        Title = "Infinite Jump", Value = false,
        Callback = function(state)
            if state then
                InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local hum = GetHumanoid()
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
            else
                if InfinityJumpConnection then InfinityJumpConnection:Disconnect() end
            end
        end
    }))

    -- No Clip
    local noclipConnection = nil
    Reg("nclip", ability:Toggle({
        Title = "No Clip", Value = false,
        Callback = function(state)
            if state then
                noclipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                        end
                    end
                end)
            else
                if noclipConnection then noclipConnection:Disconnect() end
            end
        end
    }))

    -- Fly Mode
    local flyConnection, bodyGyro, bodyVel
    local isFlying = false
    Reg("flym", ability:Toggle({
        Title = "Fly Mode", Value = false,
        Callback = function(state)
            local hrp = GetHRP()
            local hum = GetHumanoid()
            local cam = workspace.CurrentCamera
            
            if state and hrp and hum then
                isFlying = true
                bodyGyro = Instance.new("BodyGyro", hrp)
                bodyGyro.P = 9e4; bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyVel = Instance.new("BodyVelocity", hrp)
                bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9); bodyVel.Velocity = Vector3.zero
                
                flyConnection = RunService.RenderStepped:Connect(function()
                    if not isFlying or not hrp then return end
                    bodyGyro.CFrame = cam.CFrame
                    local moveDir = hum.MoveDirection
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                    bodyVel.Velocity = moveDir.Unit * 60
                end)
            else
                isFlying = false
                if flyConnection then flyConnection:Disconnect() end
                if bodyGyro then bodyGyro:Destroy() end
                if bodyVel then bodyVel:Destroy() end
            end
        end
    }))

    -- Walk on Water
    local walkWaterConn, waterPlatform
    Reg("walkwat", ability:Toggle({
        Title = "Walk on Water", Value = false,
        Callback = function(state)
            if state then
                walkWaterConn = RunService.RenderStepped:Connect(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    
                    if not waterPlatform or not waterPlatform.Parent then
                        waterPlatform = Instance.new("Part", workspace)
                        waterPlatform.Name = "WaterPlatform"; waterPlatform.Anchored = true
                        waterPlatform.CanCollide = true; waterPlatform.Transparency = 1; waterPlatform.Size = Vector3.new(15, 1, 15)
                    end
                    
                    local rayOrigin = hrp.Position + Vector3.new(0, 5, 0)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {workspace.Terrain}; rayParams.FilterType = Enum.RaycastFilterType.Include
                    rayParams.IgnoreWater = false
                    
                    local result = workspace:Raycast(rayOrigin, Vector3.new(0, -500, 0), rayParams)
                    if result and result.Material == Enum.Material.Water then
                        waterPlatform.Position = Vector3.new(hrp.Position.X, result.Position.Y, hrp.Position.Z)
                    else
                        waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
                    end
                end)
            else
                if walkWaterConn then walkWaterConn:Disconnect() end
                if waterPlatform then waterPlatform:Destroy() end
            end
        end
    }))

    -- OTHER (ESP)
    local other = player:Section({ Title = "Other", TextSize = 20 })
    local espEnabled, espConnections = false, {}
    
    local function removeESP(plr)
        if espConnections[plr] then
            pcall(function() espConnections[plr].billboard:Destroy() end)
            espConnections[plr] = nil
        end
    end

    local function createESP(target)
        if not target or not target.Character or target == LocalPlayer then return end
        removeESP(target)
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui", target.Character)
        bb.Size = UDim2.new(0, 100, 0, 40); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3, 0)
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
        txt.Text = target.DisplayName; txt.TextColor3 = Color3.new(1,0,0); txt.TextStrokeTransparency = 0
        
        espConnections[target] = {billboard = bb}
    end

    Reg("esp", other:Toggle({
        Title = "Player ESP", Value = false,
        Callback = function(state)
            espEnabled = state
            if state then
                for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
                espConnections.Added = Players.PlayerAdded:Connect(function(p) 
                    p.CharacterAdded:Connect(function() task.wait(1) if espEnabled then createESP(p) end end)
                end)
            else
                for p, _ in pairs(espConnections) do if typeof(p)=="Instance" then removeESP(p) end end
                if espConnections.Added then espConnections.Added:Disconnect() end
            end
        end
    }))
end

-- =================================================================
-- 2. TAB FISHING & LOGIC
-- =================================================================
do
    local farm = Window:Tab({ Title = "Fishing", Icon = "fish" })
    
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
    local autofish = farm:Section({ Title = "Auto Fishing", TextSize = 20 })

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

    -- [[ BLATANT MODE V2 (STABLE LOOP) ]] --
    -- Versi ini lebih ringan dan stabil untuk Ping tinggi/Event Farming
    local blatantv2 = farm:Section({ Title = "Blatant Mode V2 (Stable)", TextSize = 20 })

    local v2Delay = 2.5
    local v2State = false
    local v2Thread = nil
    
    -- Slider Kecepatan
    Reg("blatantv2speed", blatantv2:Slider({
        Title = "Catch Delay (Seconds)",
        Desc = "Waktu tunggu sebelum menarik ikan. (Rendah = Cepat)",
        Step = 0.1,
        Value = { Min = 0.1, Max = 5.0, Default = 2.5 },
        Callback = function(v)
            v2Delay = tonumber(v)
        end
    }))

    -- Toggle V2
    Reg("blatantv2tog", blatantv2:Toggle({
        Title = "Enable Blatant V2",
        Desc = "Mode spam loop sederhana. Lebih stabil untuk AFK lama.",
        Value = false,
        Callback = function(state)
            -- Cek Remote
            if not checkFishingRemotes() then return end
            
            -- Matikan Mode Lain Manual (Supaya tidak bentrok)
            if state then
                -- Matikan Legit
                local tLegit = farm:GetElementByTitle("Auto Fish (Legit)")
                if tLegit and tLegit.Value then tLegit:Set(false) end
                
                -- Matikan Normal
                local tNorm = farm:GetElementByTitle("Normal Instant Fish")
                if tNorm and tNorm.Value then tNorm:Set(false) end
                
                -- Matikan Blatant Old
                local tOld = farm:GetElementByTitle("Instant Fishing (Blatant Old)")
                if tOld and tOld.Value then tOld:Set(false) end
                
                -- Matikan Blatant V5 (Bawaan)
                local tV5 = farm:GetElementByTitle("Instant Fishing (Blatant)")
                if tV5 and tV5.Value then tV5:Set(false) end
            end

            v2State = state
            
            if state then
                -- Update Server State (Biar server tau kita mancing)
                if RF_UpdateAutoFishingState then 
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end) 
                end

                v2Thread = task.spawn(function()
                    while v2State do
                        -- 1. Charge & Cast (Simulasi Lempar)
                        local timestamp = os.time() + os.clock()
                        pcall(function() RF_ChargeFishingRod:InvokeServer(timestamp) end)
                        pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6, 0.99) end)
                        
                        -- 2. Tunggu (Delay Tangkap)
                        task.wait(v2Delay)
                        
                        -- 3. Catch (Tangkap)
                        pcall(function() RE_FishingCompleted:FireServer() end)
                        
                        -- 4. Cleanup & Re-Equip (Anti-Bug)
                        task.wait(0.2)
                        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                        
                        -- Jeda dikit sebelum loop ulang
                        task.wait(0.1)
                    end
                end)
                
                WindUI:Notify({ Title = "Blatant V2 ON", Content = "Running Stable Loop...", Duration = 3, Icon = "zap" })
            else
                -- Matikan Thread
                if v2Thread then task.cancel(v2Thread) v2Thread = nil end
                
                -- Reset Server State
                if RF_UpdateAutoFishingState then 
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end) 
                end
                
                WindUI:Notify({ Title = "Blatant V2 OFF", Duration = 3 })
            end
        end
    }))

    -- [[ BLATANT MODE (OLD / KILLER LOGIC) ]] --
    local blatant = farm:Section({ Title = "Blatant Mode (Old)", TextSize = 20, })

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

    -- [[ BLATANT MODE V3 (SMART PING SYNC) ]] --
    local blatantv3 = farm:Section({ Title = "Blatant V3 (Smart Sync)", TextSize = 20 })

    local v3State = false
    local v3Thread = nil
    
    -- Config V3
    local v3BaseDelay = 1.8 -- Waktu dasar minimal (detik)
    local v3Jitter = true   -- Randomizer on/off

    -- Helper: Get Player Ping
    local function GetPing()
        local stats = game:GetService("Stats")
        if stats and stats:FindFirstChild("Network") then
             -- Mengembalikan ping dalam satuan detik (misal 100ms -> 0.1s)
            return stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end
        return 0.1 -- Default fallback
    end

    Reg("blatantv3delay", blatantv3:Slider({
        Title = "Base Delay",
        Desc = "Waktu tunggu dasar (makin kecil makin berisiko).",
        Step = 0.1,
        Value = { Min = 1.0, Max = 4.0, Default = 1.8 },
        Callback = function(v) v3BaseDelay = tonumber(v) end
    }))

    Reg("blatantv3jitter", blatantv3:Toggle({
        Title = "Enable Humanized Jitter",
        Desc = "Menambah jeda acak agar tidak terdeteksi sebagai bot murni.",
        Value = true,
        Callback = function(v) v3Jitter = v end
    }))

    Reg("blatantv3run", blatantv3:Toggle({
        Title = "Enable Blatant V3",
        Desc = "Mode pintar yang menyesuaikan kecepatan dengan Ping internetmu.",
        Value = false,
        Callback = function(state)
            if not checkFishingRemotes() then return end
            
            -- Matikan Mode Lain
            if state then
                local modes = {"Auto Fish (Legit)", "Normal Instant Fish", "Instant Fishing (Blatant Old)", "Enable Blatant V2"}
                for _, title in ipairs(modes) do
                    local el = farm:GetElementByTitle(title)
                    if el and el.Value then el:Set(false) end
                end
            end

            v3State = state
            
            if state then
                -- Update Server State
                if RF_UpdateAutoFishingState then 
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end) 
                end

                v3Thread = task.spawn(function()
                    while v3State do
                        -- 1. Hitung Delay Cerdas
                        local currentPing = GetPing()
                        -- Rumus: Delay Dasar + (Ping x 2) untuk kompensasi lag
                        local safeDelay = v3BaseDelay + (currentPing * 1.5)
                        
                        -- Tambah Jitter (Acak)
                        if v3Jitter then
                            safeDelay = safeDelay + (math.random(10, 150) / 1000)
                        end

                        -- 2. Action: Cast
                        local timestamp = os.time() + os.clock()
                        pcall(function() RF_ChargeFishingRod:InvokeServer(timestamp) end)
                        pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6, 0.99) end)
                        
                        -- 3. Tunggu Waktu Aman
                        task.wait(safeDelay)
                        
                        -- 4. Action: Catch
                        pcall(function() RE_FishingCompleted:FireServer() end)
                        
                        -- 5. Quick Reset (Anim Cancel)
                        -- Kita un-equip dan equip tool dengan sangat cepat untuk memotong animasi "mengangkat ikan"
                        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                        
                        -- Jeda ultra pendek sebelum re-equip (tergantung ping)
                        task.wait(0.05 + currentPing) 
                        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                        
                        -- Tunggu rod siap dipakai
                        task.wait(0.15)
                    end
                end)
                WindUI:Notify({ Title = "Blatant V3 Active", Content = "Syncing with Ping...", Duration = 3, Icon = "wifi" })
            else
                if v3Thread then task.cancel(v3Thread) v3Thread = nil end
                if RF_UpdateAutoFishingState then 
                    pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end) 
                end
                WindUI:Notify({ Title = "Blatant V3 Stopped", Duration = 2 })
            end
        end
    }))

    -- FISHING AREA SECTION
    farm:Divider()
    local areafish = farm:Section({ Title = "Fishing Area", TextSize = 20 })
    
    local FishingAreas = {
        ["Classic Island"] = {Pos = Vector3.new(1440.8, 46.0, 2777.1), Look = Vector3.new(0.9, 0, 0.3)},
        ["Coral Reef"] = {Pos = Vector3.new(-3207.5, 6.0, 2011.0), Look = Vector3.new(0.9, 0, 0.2)},
        ["Ancient Jungle"] = {Pos = Vector3.new(1535.6, 3.1, -193.3), Look = Vector3.new(0.5, 0, 0.8)},
        ["Roslit"] = {Pos = Vector3.new(-1518.5, 2.8, 1916.1), Look = Vector3.new(0.04, 0, 0.99)},
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

    local MiscSection = SettingsTab:Section({
        Title = "Misc. Area",
        TextSize = 20,
    })

    -- [[ DEPENDENCIES & VARIABLES ]] --
    local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
    local function GetRemote(remotePath, name, timeout)
        local currentInstance = game:GetService("ReplicatedStorage")
        for _, childName in ipairs(remotePath) do
            currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
            if not currentInstance then return nil end
        end
        return currentInstance:FindFirstChild(name)
    end

    local RunService = game:GetService("RunService")
    local LocalPlayer = game:GetService("Players").LocalPlayer

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
            
            if not SmallNotification then
                -- Coba cari sebentar jika belum load
                SmallNotification = PlayerGui:WaitForChild("Small Notification", 5)
            end

            if not SmallNotification then 
                WindUI:Notify({ Title = "Error", Content = "GUI Notifikasi tidak ditemukan.", Duration = 3, Icon = "x" })
                return 
            end

            if state then
                -- Paksa disable setiap frame agar tidak muncul kembali
                DisableNotificationConnection = RunService.RenderStepped:Connect(function()
                    if SmallNotification then SmallNotification.Enabled = false end
                end)
                WindUI:Notify({ Title = "Notif Diblokir", Duration = 2, Icon = "check" })
            else
                if DisableNotificationConnection then
                    DisableNotificationConnection:Disconnect()
                    DisableNotificationConnection = nil
                end
                SmallNotification.Enabled = true
                WindUI:Notify({ Title = "Notif Normal", Duration = 2, Icon = "check" })
            end
        end
    })

    -- 2. ENABLE FISHING RADAR
    local RF_UpdateFishingRadar = GetRemote(RPath, "RF/UpdateFishingRadar")
    MiscSection:Toggle({
        Title = "Enable Fishing Radar",
        Desc = "Menampilkan radar ikan di HUD.",
        Value = false,
        Icon = "radar",
        Callback = function(state)
            if not RF_UpdateFishingRadar then
                WindUI:Notify({ Title = "Error", Content = "Remote Radar tidak ditemukan.", Duration = 3, Icon = "x" })
                return
            end
            pcall(function() RF_UpdateFishingRadar:InvokeServer(state) end)
            
            if state then
                WindUI:Notify({ Title = "Radar ON", Duration = 2, Icon = "check" })
            else
                WindUI:Notify({ Title = "Radar OFF", Duration = 2, Icon = "x" })
            end
        end
    })

    -- 3. NO ANIMATION
    local isNoAnimationActive = false
    local originalAnimator = nil
    local originalAnimateScript = nil

    local function ToggleAnimations(disable)
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end

        if disable then
            -- Disable Animate Script
            local animScript = character:FindFirstChild("Animate")
            if animScript and animScript:IsA("LocalScript") and animScript.Enabled then
                originalAnimateScript = animScript.Enabled
                animScript.Enabled = false
            end
            -- Destroy Animator
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                originalAnimator = animator
                animator:Destroy()
            end
        else
            -- Restore
            local animScript = character:FindFirstChild("Animate")
            if animScript and originalAnimateScript ~= nil then
                animScript.Enabled = originalAnimateScript
            end
            local existingAnimator = humanoid:FindFirstChildOfClass("Animator")
            if not existingAnimator then
                Instance.new("Animator", humanoid)
            end
        end
    end

    MiscSection:Toggle({
        Title = "No Animation",
        Desc = "Mematikan animasi karakter (mengurangi lag).",
        Value = false,
        Icon = "activity",
        Callback = function(state)
            isNoAnimationActive = state
            ToggleAnimations(state)
            if state then
                WindUI:Notify({ Title = "No Anim ON", Duration = 2, Icon = "check" })
            else
                WindUI:Notify({ Title = "No Anim OFF", Duration = 2, Icon = "x" })
            end
        end
    })
    
    -- Handle Respawn for No Animation
    LocalPlayer.CharacterAdded:Connect(function()
        if isNoAnimationActive then
            task.wait(0.5)
            ToggleAnimations(true)
        end
    end)

    -- 4. REMOVE SKIN EFFECT
    -- Load Controller (Safe Call)
    local VFXControllerModule = nil
    local originalVFXHandle = nil
    pcall(function()
        VFXControllerModule = require(game:GetService("ReplicatedStorage").Controllers.VFXController)
        originalVFXHandle = VFXControllerModule.Handle
    end)

    MiscSection:Toggle({
        Title = "Remove Skin Effect",
        Desc = "Menghilangkan efek partikel/aura skin rod.",
        Value = false,
        Icon = "sparkles",
        Callback = function(state)
            if not VFXControllerModule then 
                WindUI:Notify({ Title = "Error", Content = "VFX Controller tidak ditemukan.", Duration = 3, Icon = "x" })
                return 
            end

            if state then
                -- Override Handle function to do nothing
                VFXControllerModule.Handle = function(...) end
                -- Optional: Clear existing effects
                local cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
                if cosmeticFolder then pcall(function() cosmeticFolder:ClearAllChildren() end) end
                WindUI:Notify({ Title = "Skin FX OFF", Duration = 2 })
            else
                -- Restore original function
                if originalVFXHandle then
                    VFXControllerModule.Handle = originalVFXHandle
                end
                WindUI:Notify({ Title = "Skin FX ON", Duration = 2 })
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
        -- Hook Function (Permanent Hook with Toggle Check)
        CutsceneController.Play = function(self, ...)
            if isNoCutsceneActive then return end -- Block if active
            return OldPlayCutscene(self, ...)
        end
    end

    MiscSection:Toggle({
        Title = "No Cutscene",
        Desc = "Melewati animasi sinematik saat menangkap ikan.",
        Value = false,
        Icon = "film",
        Callback = function(state)
            isNoCutsceneActive = state
            if state then
                WindUI:Notify({ Title = "No Cutscene ON", Duration = 2 })
            else
                WindUI:Notify({ Title = "No Cutscene OFF", Duration = 2 })
            end
        end
    })

    -- 6. DISABLE 3D RENDERING
    MiscSection:Toggle({
        Title = "Disable 3D Rendering",
        Desc = "Mematikan render dunia 3D (Layar Hitam) untuk hemat CPU/GPU.",
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
                    _G.BlackScreenGUI.DisplayOrder = -999
                    _G.BlackScreenGUI.Parent = PlayerGui
                    
                    local Frame = Instance.new("Frame", _G.BlackScreenGUI)
                    Frame.Size = UDim2.new(1,0,1,0)
                    Frame.BackgroundColor3 = Color3.new(0,0,0)
                    
                    local Label = Instance.new("TextLabel", Frame)
                    Label.Size = UDim2.new(1,0,0.1,0)
                    Label.BackgroundTransparency = 1
                    Label.Text = "3D Rendering Disabled (Saver Mode)"
                    Label.TextColor3 = Color3.new(1,1,1)
                    Label.TextSize = 20
                end
                _G.BlackScreenGUI.Enabled = true
                _G.OldCamType = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(0, 100000, 0)
            else
                if _G.BlackScreenGUI then _G.BlackScreenGUI.Enabled = false end
                if _G.OldCamType then Camera.CameraType = _G.OldCamType else Camera.CameraType = Enum.CameraType.Custom end
                if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
            end
        end
    })

    -- 7. FPS ULTRA BOOST
    local originalLighting = {}
    local function ToggleFPSBoost(enable)
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        
        if enable then
            -- Save Originals
            if not next(originalLighting) then
                originalLighting = {
                    GlobalShadows = Lighting.GlobalShadows,
                    FogEnd = Lighting.FogEnd,
                    Brightness = Lighting.Brightness
                }
            end
            
            -- Apply Boost
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0
            
            -- Disable Effects
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                elseif v:IsA("Texture") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
            
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterTransparency = 1
                Terrain.Decoration = false
            end
            
            setfpscap(60) -- Stabilize
        else
            -- Restore
            if originalLighting.GlobalShadows ~= nil then
                Lighting.GlobalShadows = originalLighting.GlobalShadows
                Lighting.FogEnd = originalLighting.FogEnd
                Lighting.Brightness = originalLighting.Brightness
            end
        end
    end

    MiscSection:Toggle({
        Title = "FPS Ultra Boost",
        Desc = "Menurunkan kualitas grafik ekstrem untuk FPS maksimal.",
        Value = false,
        Icon = "zap",
        Callback = function(state)
            ToggleFPSBoost(state)
            if state then
                WindUI:Notify({ Title = "FPS Boost ON", Duration = 2, Icon = "zap" })
            else
                WindUI:Notify({ Title = "FPS Boost OFF", Duration = 2, Icon = "rotate-ccw" })
            end
        end
    })
end

WindUI:Notify({ Title = "Extracted Script Loaded", Content = "Player & Fishing Tabs Only", Duration = 5, Icon = "check" })


