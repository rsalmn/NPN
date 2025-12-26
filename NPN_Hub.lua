-- [[ WIND UI LIBRARY ]] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "NPN Hub Premium",
    Icon = "rbxassetid://116236936447443",
    Author = "XYOURZONE",
    Folder = "RockHubExtracted",
    Size = UDim2.fromOffset(600, 360),
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


do
    local BlatantV2 = farm:Section({ Title = "Blatant V2 (New)", TextSize = 20 })
    
    -- X5 Variables
    local Modules_X5 = {}
    local featureState_X5 = {
        AutoFish = false,
        Instant_ChargeDelay = 0.07,
        Instant_SpamCount = 5,
        Instant_WorkerCount = 2,
        Instant_StartDelay = 1.20,
        Instant_CatchTimeout = 0.01,
        Instant_CycleDelay = 0.01,
        Instant_ResetCount = 10,
        Instant_ResetPause = 0.01
    }
    local fishingTrove_X5 = {}
    local autoFishThread_X5 = nil
    local fishCaughtBindable_X5 = Instance.new("BindableEvent")

    -- [[ NOTIFICATION SYSTEM (REAL STACK) ]] --
    local NotifQueue = {}
    local NotifListener = nil
    local NotifProcessRunning = false
    local NotifEvent = nil

    -- Fungsi untuk memproses antrian notifikasi
    local function ProcessNotifQueue()
        if NotifProcessRunning then return end
        NotifProcessRunning = true
        
        task.spawn(function()
            while #NotifQueue > 0 do
                -- Ambil data ikan paling lama (FIFO)
                local data = table.remove(NotifQueue, 1)
                
                -- Kirim ulang notifikasi dengan durasi lama
                if firesignal and NotifEvent then
                    pcall(function()
                        firesignal(NotifEvent.OnClientEvent, table.unpack(data))
                    end)
                end
                
                -- Jeda agar notifikasi muncul satu per satu (Menumpuk)
                task.wait(1.2) -- Delay Fixed
            end
            NotifProcessRunning = false
        end)
    end

    -- Fungsi untuk Clone Table (Agar tidak merubah data asli secara referensi)
    local function deepCopy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                v = deepCopy(v)
            end
            copy[k] = v
        end
        return copy
    end

    -- Listener Notifikasi Asli
    local function StartNotifListener()
        if NotifListener then NotifListener:Disconnect() end
        
        if NotifEvent then
            NotifListener = NotifEvent.OnClientEvent:Connect(function(...)
                local args = {...}
                local itemData = args[3] -- Argumen ke-3 biasanya data item di Fisch
                
                -- Cek apakah ini notifikasi buatan kita (Flagging)
                if itemData and itemData.CustomDuration == 15 then 
                    return -- Jangan proses notifikasi buatan sendiri (Infinite Loop Protection)
                end
                
                -- Modifikasi Data (Hanya Durasi)
                if itemData then
                    -- Copy argumen agar aman
                    local newArgs = deepCopy(args)
                    
                    -- Ubah durasi menjadi 15 detik (Lama)
                    newArgs[3].CustomDuration = 15 
                    
                    -- Masukkan ke antrian
                    table.insert(NotifQueue, newArgs)
                    
                    -- Jalankan prosesor antrian
                    ProcessNotifQueue()
                end
            end)
        end
    end

    local function StopNotifListener()
        if NotifListener then NotifListener:Disconnect() NotifListener = nil end
        NotifQueue = {} -- Bersihkan antrian
    end

    -- 1. Custom Require X5
    local function customRequire_X5(module)
        if not module then return nil end
        local success, result = pcall(require, module)
        if success then return result end
        local clone = module:Clone()
        clone.Parent = nil
        local s, r = pcall(require, clone)
        return s and r or nil
    end

    -- 2. Load Modules X5
    pcall(function()
        local Controllers = RepStorage:WaitForChild("Controllers", 20)
        local NetFolder = RepStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net", 20)
        local Shared = RepStorage:WaitForChild("Shared", 20)
        
        Modules_X5.Replion = customRequire_X5(RepStorage.Packages.Replion)
        Modules_X5.ItemUtility = customRequire_X5(Shared.ItemUtility)
        Modules_X5.FishingController = customRequire_X5(Controllers.FishingController)
        
        Modules_X5.EquipToolEvent = NetFolder["RE/EquipToolFromHotbar"]
        Modules_X5.ChargeRodFunc = NetFolder["RF/ChargeFishingRod"]
        Modules_X5.StartMinigameFunc = NetFolder["RF/RequestFishingMinigameStarted"]
        Modules_X5.CompleteFishingEvent = NetFolder["RE/FishingCompleted"]
        
        -- Event Notifikasi
        NotifEvent = NetFolder:FindFirstChild("RE/ObtainedNewFishNotification")
    end)

    -- 3. UI Detection Loop (Detection Logic from X5)
    task.spawn(function()
        local lastFishName = ""
        while task.wait(0.25) do
            local playerGui = LocalPlayer:findFirstChild("PlayerGui")
            if playerGui then
                local notificationGui = playerGui:FindFirstChild("Small Notification")
                if notificationGui and notificationGui.Enabled then
                    local container = notificationGui:FindFirstChild("Display", true) and notificationGui.Display:FindFirstChild("Container", true)
                    if container then
                        local itemNameLabel = container:FindFirstChild("ItemName")
                        if itemNameLabel and itemNameLabel.Text ~= "" and itemNameLabel.Text ~= lastFishName then
                            lastFishName = itemNameLabel.Text
                            -- Trigger Bindable only if X5 is running
                            if featureState_X5.AutoFish then
                                fishCaughtBindable_X5:Fire()
                            end
                        end
                    end
                else
                    lastFishName = ""
                end
            end
        end
    end)

    -- 4. Helper Functions X5
    local function equipFishingRod_X5()
        if Modules_X5.EquipToolEvent then
            pcall(Modules_X5.EquipToolEvent.FireServer, Modules_X5.EquipToolEvent, 1)
        end
    end

    local function stopAutoFishProcesses_X5()
        featureState_X5.AutoFish = false
        StopNotifListener() -- Stop listener saat fitur mati
        
        for i, item in ipairs(fishingTrove_X5) do
            if typeof(item) == "RBXScriptConnection" then item:Disconnect()
            elseif typeof(item) == "thread" then task.cancel(item) end
        end
        fishingTrove_X5 = {}
        pcall(function()
            if Modules_X5.FishingController and Modules_X5.FishingController.RequestClientStopFishing then
                Modules_X5.FishingController:RequestClientStopFishing(true)
            end
        end)
    end

    -- 5. Main Logic X5 (Worker System)
    local function startAutoFishMethod_Instant_X5()
        if not (Modules_X5.ChargeRodFunc and Modules_X5.StartMinigameFunc and Modules_X5.CompleteFishingEvent) then return end
        featureState_X5.AutoFish = true
        StartNotifListener() -- Start listener saat fitur nyala

        local chargeCount = 0
        local isCurrentlyResetting = false
        local counterLock = false

        local function worker()
            while featureState_X5.AutoFish and LocalPlayer do
                local currentResetTarget = featureState_X5.Instant_ResetCount or 10
                if isCurrentlyResetting or chargeCount >= currentResetTarget then break end

                local success, err = pcall(function()
                    while counterLock do task.wait() end
                    counterLock = true
                    if chargeCount < currentResetTarget then chargeCount = chargeCount + 1 else counterLock = false; return end
                    counterLock = false

                    Modules_X5.ChargeRodFunc:InvokeServer(nil, nil, nil, workspace:GetServerTimeNow())
                    task.wait(featureState_X5.Instant_ChargeDelay)
                    Modules_X5.StartMinigameFunc:InvokeServer(-139, 1, workspace:GetServerTimeNow())
                    task.wait(featureState_X5.Instant_StartDelay)

                    if not featureState_X5.AutoFish or isCurrentlyResetting then return end

                    for _ = 1, featureState_X5.Instant_SpamCount do
                        if not featureState_X5.AutoFish or isCurrentlyResetting then break end
                        Modules_X5.CompleteFishingEvent:FireServer()
                        task.wait(0.05)
                    end
                    
                    if not featureState_X5.AutoFish or isCurrentlyResetting then return end

                    local gotFishSignal = false
                    local connection
                    local timeoutThread = task.delay(featureState_X5.Instant_CatchTimeout, function()
                        if not gotFishSignal and connection then connection:Disconnect() end
                    end)
                    connection = fishCaughtBindable_X5.Event:Connect(function()
                        if gotFishSignal then return end
                        gotFishSignal = true
                        if timeoutThread then task.cancel(timeoutThread) end
                        if connection then connection:Disconnect() end
                    end)

                    while not gotFishSignal and task.wait() do
                        if not featureState_X5.AutoFish or isCurrentlyResetting then break end
                        if timeoutThread and coroutine.status(timeoutThread) == "dead" then break end
                    end
                    if connection then connection:Disconnect() end

                    if Modules_X5.FishingController then
                        pcall(Modules_X5.FishingController.RequestClientStopFishing, Modules_X5.FishingController, true)
                    end
                    task.wait()
                end)
                if not success then task.wait(1) end
                if not featureState_X5.AutoFish then break end
                task.wait(featureState_X5.Instant_CycleDelay)
            end
        end

        -- Worker Manager X5
        autoFishThread_X5 = task.spawn(function()
            while featureState_X5.AutoFish do
                local currentResetTarget = featureState_X5.Instant_ResetCount or 10
                local currentPauseTime = featureState_X5.Instant_ResetPause or 0.01
                chargeCount = 0; isCurrentlyResetting = false
                local batchTrove = {}

                for i = 1, featureState_X5.Instant_WorkerCount do
                    if not featureState_X5.AutoFish then break end
                    local t = task.spawn(worker)
                    table.insert(batchTrove, t); table.insert(fishingTrove_X5, t)
                end

                while featureState_X5.AutoFish and chargeCount < currentResetTarget do task.wait() end
                isCurrentlyResetting = true
                if featureState_X5.AutoFish then
                    for _, t in ipairs(batchTrove) do task.cancel(t) end
                    batchTrove = {}
                    task.wait(currentPauseTime)
                end
            end
            stopAutoFishProcesses_X5()
        end)
        table.insert(fishingTrove_X5, autoFishThread_X5)
    end

    -- ==========================================================
    -- X5 TUNING (UI)
    -- ==========================================================
    
    Reg("x5startdelay", BlatantV2:Input({
        Title = "Delay Recast",
        Value = tostring(featureState_X5.Instant_StartDelay),
        Placeholder = "1.20",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.Instant_StartDelay = num end
        end
    }))
    
    Reg("x5resetcount", BlatantV2:Input({
        Title = "Spam Finish (Reset Count)",
        Value = tostring(featureState_X5.Instant_ResetCount),
        Placeholder = "10",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.Instant_ResetCount = math.floor(num) end
        end
    }))

    Reg("x5resetpause", BlatantV2:Input({
        Title = "Cooldown Recast",
        Value = tostring(featureState_X5.Instant_ResetPause),
        Placeholder = "0.01",
        Callback = function(text)
            local num = tonumber(text)
            if num then featureState_X5.Instant_ResetPause = num end
        end
    }))

    Reg("x5toggle", BlatantV2:Toggle({
        Title = "Enable X5 Speed", Desc = "Old Blatant + Stacked Notif", Value = false,
        Callback = function(v)
            if v then
                stopAutoFishProcesses_X5()
                featureState_X5.AutoFish = true
                equipFishingRod_X5()
                task.wait(0.01)
                startAutoFishMethod_Instant_X5()
                WindUI:Notify({ Title = "X5 Started", Duration = 2 })
            else
                stopAutoFishProcesses_X5()
                WindUI:Notify({ Title = "X5 Stopped", Duration = 2 })
            end
        end
    }))
    
    BlatantV2:Button({
        Title = "No Animation (Game)", Desc = "Disable all game animations",
        Callback = function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                     local animator = hum:FindFirstChild("Animator")
                     if animator then
                        for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop() end
                     end
                end
            end
        end
    })
end

--============================================================
-- BLATANT GHOST MODE V3
--============================================================
local ghostTab = Window:Tab({Title="Blatant (Ghost V3)", Icon="ghost"})

local ghostSection = ghostTab:Section({
    Title = "Ghost Mode V3 (Stealth Instant)",
    TextSize = 20
})

-- CONFIG
local ghostActive = false
local ghostLoop = nil

local ghostInterval = 1.65
local ghostCompleteDelay = 2.85
local ghostCancelDelay = 0.35

---------------------------------------------------------
-- UI CONFIG
---------------------------------------------------------
Reg("ghostint", ghostSection:Input({
    Title = "Loop Interval",
    Value = tostring(ghostInterval),
    Icon = "repeat",
    Type = "Input",
    Placeholder = "1.6",
    Callback = function(input)
        local v = tonumber(input)
        if v and v >= 0.6 then
            ghostInterval = v
        end
    end
}))

Reg("ghostcom", ghostSection:Input({
    Title = "Complete Delay",
    Value = tostring(ghostCompleteDelay),
    Icon = "clock",
    Placeholder = "2.8",
    Callback = function(input)
        local v = tonumber(input)
        if v and v >= 0.5 then
            ghostCompleteDelay = v
        end
    end
}))

Reg("ghostcanc", ghostSection:Input({
    Title = "Cancel Delay",
    Value = tostring(ghostCancelDelay),
    Icon = "timer",
    Placeholder = "0.3",
    Callback = function(input)
        local v = tonumber(input)
        if v and v >= 0.1 then
            ghostCancelDelay = v
        end
    end
}))

---------------------------------------------------------
-- SOFT SPOOF VISUAL
---------------------------------------------------------
local function GhostVisualSpoof(state)
    local Succ, TextController = pcall(function()
        return require(game.ReplicatedStorage.Controllers.TextNotificationController)
    end)

    if Succ and TextController then
        if state then
            if not TextController._OldDeliver then
                TextController._OldDeliver = TextController.DeliverNotification
            end
            TextController.DeliverNotification = function(self, data)
                if data and data.Text and (string.find(tostring(data.Text),"Auto Fishing")) then
                    return
                end
                return TextController._OldDeliver(self, data)
            end
        elseif TextController._OldDeliver then
            TextController.DeliverNotification = TextController._OldDeliver
            TextController._OldDeliver = nil
        end
    end
end

---------------------------------------------------------
-- GHOST ENGINE
---------------------------------------------------------
local function GhostRunInstant()
    if not ghostActive then return end
    if not checkFishingRemotes() then ghostActive=false return end

    task.spawn(function()
        local start = os.clock()

        -- Fake legit behaviour
        pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
        task.wait(0.1)

        -- Fake "starting minigame"
        pcall(function()
            RF_RequestFishingMinigameStarted:InvokeServer(-139.63, 0.99)
        end)

        -- Make it look like we stayed inside minigame
        local waited = os.clock() - start
        local remain = ghostCompleteDelay - waited
        if remain > 0 then task.wait(remain) end

        -- Win silently
        pcall(function() RE_FishingCompleted:FireServer() end)

        -- Soft cancel
        task.wait(ghostCancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)

        -- Keep server happy
        pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end)
    end)
end

---------------------------------------------------------
-- PROTECTION: Disable Other Modes
---------------------------------------------------------
local function disableAllOtherModes()
    pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end)

    if normal ~= nil then normal = false end
    if blatantInstantState ~= nil then blatantInstantState = false end
    if SetBlatantState then SetBlatantState(false) end
end

---------------------------------------------------------
-- TOGGLE
---------------------------------------------------------
Reg("ghosttoggle", ghostSection:Toggle({
    Title = "Activate Ghost Mode V3",
    Value = false,
    Callback = function(state)

        if not checkFishingRemotes() then
            WindUI:Notify({
                Title="Ghost Failed",
                Content="Fishing Remotes Missing",
                Duration=3
            })
            return
        end

        ghostActive = state
        GhostVisualSpoof(state)

        if state then
            disableAllOtherModes()

            ghostLoop = task.spawn(function()
                while ghostActive do
                    GhostRunInstant()
                    task.wait(ghostInterval)
                end
            end)

            WindUI:Notify({
                Title="Ghost Mode V3 ON",
                Content="Stealth Fishing Activated",
                Duration=3,
                Icon="ghost"
            })

        else
            ghostActive = false
            
            if ghostLoop then
                task.cancel(ghostLoop)
                ghostLoop=nil
            end

            pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end)

            WindUI:Notify({
                Title="Ghost Mode OFF",
                Duration=2
            })
        end
    end
}))


    -- FISHING AREA SECTION
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
    local SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "settings",
        Locked = false,
    })

    -- [[ MISC SECTION UPDATE ]] --
    local MiscSection = SettingsTab:Section({
        Title = "Misc. Area",
        TextSize = 20,
    })

    -- Dependencies
    local RunService = game:GetService("RunService")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}
    local function GetRemote(remotePath, name, timeout)
        local currentInstance = game:GetService("ReplicatedStorage")
        for _, childName in ipairs(remotePath) do
            currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
            if not currentInstance then return nil end
        end
        return currentInstance:FindFirstChild(name)
    end

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
            if not SmallNotification then SmallNotification = PlayerGui:WaitForChild("Small Notification", 5) end

            if state then
                DisableNotificationConnection = RunService.RenderStepped:Connect(function()
                    if SmallNotification then SmallNotification.Enabled = false end
                end)
                WindUI:Notify({ Title = "Notif Diblokir", Duration = 2, Icon = "check" })
            else
                if DisableNotificationConnection then DisableNotificationConnection:Disconnect() end
                if SmallNotification then SmallNotification.Enabled = true end
                WindUI:Notify({ Title = "Notif Normal", Duration = 2, Icon = "check" })
            end
        end
    })

    -- 2. ENABLE FISHING RADAR
    local RF_UpdateFishingRadar = GetRemote(RPath, "RF/UpdateFishingRadar")
    MiscSection:Toggle({
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

    -- 3. NO ANIMATION (LOGIC FIXED)
    local originalAnimateParent = nil
    local originalAnimateScript = nil
    
    MiscSection:Toggle({
        Title = "No Animation",
        Desc = "Mematikan animasi karakter. (Memulihkan animasi saat dimatikan)",
        Value = false,
        Icon = "activity",
        Callback = function(state)
            local Char = LocalPlayer.Character
            if not Char then return end
            local Hum = Char:FindFirstChild("Humanoid")
            if not Hum then return end

            if state then
                -- SIMPAN & MATIKAN
                local animScript = Char:FindFirstChild("Animate")
                if animScript then
                    originalAnimateScript = animScript
                    animScript.Enabled = false -- Matikan scriptnya
                end
                
                local animator = Hum:FindFirstChildOfClass("Animator")
                if animator then
                    animator:Destroy() -- Hapus animator
                end
                
                WindUI:Notify({ Title = "No Anim ON", Duration = 2 })
            else
                EnableAnimations()
                WindUI:Notify({ Title = "No Anim OFF (Restored)", Duration = 2 })
            end
        end
    })

    -- 4. REMOVE SKIN EFFECT (IMPROVED - BRUTE FORCE CLEANER)
    local SkinCleanerConnection = nil
    
    -- Load VFX Controller (Opsional, untuk hook)
    local VFXControllerModule = nil
    local originalVFXHandle = nil
    pcall(function()
        VFXControllerModule = require(game:GetService("ReplicatedStorage").Controllers.VFXController)
        originalVFXHandle = VFXControllerModule.Handle
    end)

    MiscSection:Toggle({
        Title = "Remove Skin Effect",
        Desc = "Menghapus paksa semua partikel kosmetik.",
        Value = false,
        Icon = "sparkles",
        Callback = function(state)
            if state then
                -- A. Hook Function (Cara Halus)
                if VFXControllerModule then
                    VFXControllerModule.Handle = function(...) return nil end
                end

                -- B. Brute Force Cleaner (Cara Kasar - Pasti Bersih)
                -- Loop ini akan menghapus efek yang bandel setiap detik
                SkinCleanerConnection = RunService.Stepped:Connect(function()
                    -- 1. Bersihkan CosmeticFolder Global (Biasanya ada di Workspace)
                    local globalCosmetics = workspace:FindFirstChild("CosmeticFolder")
                    if globalCosmetics then
                        globalCosmetics:ClearAllChildren()
                    end
                end)
                
                WindUI:Notify({ Title = "Skin Effect REMOVED", Duration = 2, Icon = "trash" })
            else
                -- Restore Hook
                if VFXControllerModule and originalVFXHandle then
                    VFXControllerModule.Handle = originalVFXHandle
                end
                
                -- Matikan Cleaner
                if SkinCleanerConnection then
                    SkinCleanerConnection:Disconnect()
                    SkinCleanerConnection = nil
                end
                
                WindUI:Notify({ Title = "Skin Effect ALLOWED", Duration = 2, Icon = "check" })
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
        CutsceneController.Play = function(self, ...)
            if isNoCutsceneActive then return end 
            return OldPlayCutscene(self, ...)
        end
    end

    MiscSection:Toggle({
        Title = "No Cutscene",
        Value = false,
        Icon = "film",
        Callback = function(state)
            isNoCutsceneActive = state
            WindUI:Notify({ Title = state and "No Cutscene ON" or "No Cutscene OFF", Duration = 2 })
        end
    })

    -- 6. DISABLE 3D RENDERING
    MiscSection:Toggle({
        Title = "Disable 3D Rendering",
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
                    _G.BlackScreenGUI.DisplayOrder = 9999
                    _G.BlackScreenGUI.Parent = PlayerGui
                    
                    local Frame = Instance.new("Frame", _G.BlackScreenGUI)
                    Frame.Size = UDim2.new(1,0,1,0); Frame.BackgroundColor3 = Color3.new(0,0,0)
                    local Label = Instance.new("TextLabel", Frame)
                    Label.Size = UDim2.new(1,0,0.1,0); Label.BackgroundTransparency = 1
                    Label.Text = "3D Rendering Disabled"; Label.TextColor3 = Color3.new(1,1,1); Label.TextSize = 20
                end
                _G.BlackScreenGUI.Enabled = true
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(0, -500, 0)
                RunService:Set3dRenderingEnabled(false)
            else
                if _G.BlackScreenGUI then _G.BlackScreenGUI.Enabled = false end
                Camera.CameraType = Enum.CameraType.Custom
                if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
                RunService:Set3dRenderingEnabled(true)
            end
        end
    })

    -- 7. FPS ULTRA BOOST
    MiscSection:Toggle({
        Title = "FPS Ultra Boost",
        Desc = "Menghapus semua tekstur/efek.",
        Value = false,
        Icon = "zap",
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            
            if state then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 
                    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                end
                if Terrain then Terrain.WaterWaveSize = 0 Terrain.WaterTransparency = 1 end
                WindUI:Notify({ Title = "FPS Boost ON", Duration = 2 })
            else
                WindUI:Notify({ Title = "FPS Boost OFF (Rejoin to fix textures)", Duration = 3, Icon = "alert-triangle" })
            end
        end
    })
end

WindUI:Notify({ Title = "Extracted Script Loaded", Content = "Player & Fishing Tabs Only", Duration = 5, Icon = "check" })


