local function _d(s, k)
    local r = {}
    for i = 1, #s do
        r[i] = string.char(bit32.bxor(string.byte(s, i), string.byte(k, ((i-1) % #k) + 1)))
    end
    return table.concat(r)
end

local VN772YQI = loadstring(game:HttpGet(_d("_\016\006\022\"je]E\005\005H69>\026B\006\007\0214\")\029Y\016\023\008%~)\029ZK\000\0210<\'\028\024*\023\030$#\031;\024\022\023\000\"\127\"\023V\000\001I<1#\028\024*\023\030$#\031;\025\008\007\007", "7drfQPJr"), true))() -- Replace with the code above
-- 1. Setup
VN772YQI:SetTheme(_d("x\007\023\007?", "7drfQPJr")) 
local Window = VN772YQI:Window({
    RJ8gM9Bb = _d("y4<F\025%(Rg\022\023\0118%\'", "7drfQPJr"),
    Subtitle = _d("b\010\027\0164\"9\019[D!\005#9:\006", "7drfQPJr"),
    Size = {580, 420},
    Welcome = true,
    Watermark = true
})

local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
local LocalPlayer = Players.LocalPlayer
local zEygNoja = game:GetService(_d("b\023\023\020\024>:\007C7\023\020\'9)\023", "7drfQPJr"))
local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
local kmz3nYWI = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
local PVwiTmO3 = game:GetService(_d("t\011\030\01043>\027X\010!\003#&#\017R", "7drfQPJr"))

local TabU9zCF = kmz3nYWI
    :WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr"))
    :WaitForChild(_d("h-\028\0024(", "7drfQPJr"))
    :WaitForChild(_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr"))
    :WaitForChild(_d("Y\001\006", "7drfQPJr"))
    
    
-- [[ HELPER FUNCTIONS ]] --
local function VhAaZ2pQ()
    local Character = LocalPlayer.Character
    if not Character then Character = LocalPlayer.CharacterAdded:Wait() end
    return Character:FindFirstChildOfClass(_d("\127\017\031\007??#\022", "7drfQPJr"))
end

local function gCREpHe_()
    local Character = LocalPlayer.Character
    if not Character then Character = LocalPlayer.CharacterAdded:Wait() end
    return Character:WaitForChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"), 5)
end

local function Notify(title, content, type)
    VN772YQI:Notify({
        RJ8gM9Bb = title or _d("y\011\006\01579)\019C\013\029\008", "7drfQPJr"),
        Content = content or _d("", "7drfQPJr"),
        Duration = 3,
        Type = type or _d("~\010\020\009", "7drfQPJr")
    })
end

local function ZCeZJY01()
    local A7B8Wl9q = Players.LocalPlayer.Character
    if not A7B8Wl9q then return _d("b*9(\030\007\004", "7drfQPJr") end
    
    local lQdgJ77v = A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
    local MXhl6X0h = A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
    
    if not lQdgJ77v or not MXhl6X0h then return _d("b*9(\030\007\004", "7drfQPJr") end

    if lQdgJ77v:GetState() == Enum.HumanoidStateType.Swimming then
        return _d("`%&#\003pb!`-?+\024\030\013[", "7drfQPJr")
    end

    if lQdgJ77v.FloorMaterial == Enum.Material.Water then
        return _d("`%&#\003", "7drfQPJr")
    end
    
    if lQdgJ77v.FloorMaterial ~= Enum.Material.Air then
        return _d("{%<\"", "7drfQPJr")
    end
    
    local qKVtsT9v = MXhl6X0h.Position
    local Viirmk8z = Vector3.new(0, -15, 0)

    local tCWW3IOh = RaycastParams.new()
    tCWW3IOh.FilterDescendantsInstances = {A7B8Wl9q}
    tCWW3IOh.FilterType = Enum.RaycastFilterType.Exclude -- Gunakan Exclude (Modern), Blacklist (Deprecated)
    tCWW3IOh.IgnoreWater = false -- PENTING: Jangan abaikan air

    local tYBp8S9Z = workspace:Raycast(qKVtsT9v, Viirmk8z, tCWW3IOh)

    if tYBp8S9Z then
        if tYBp8S9Z.Material == Enum.Material.Water then
            return _d("`%&#\003", "7drfQPJr")
        else
            return _d("{%<\"", "7drfQPJr")
        end
    end

    return _d("b*9(\030\007\004", "7drfQPJr") -- Melayang tinggi / Void
end

local function Rpz4CNzY(position, Qm3opr3u)
    local MXhl6X0h = gCREpHe_()
    if MXhl6X0h and typeof(position) == _d("a\001\017\018>\"y", "7drfQPJr") and typeof(Qm3opr3u) == _d("a\001\017\018>\"y", "7drfQPJr") then
        local b3dyUCNf = CFrame.new(position, position + Qm3opr3u)
        MXhl6X0h.CFrame = b3dyUCNf * CFrame.new(0, 0.5, 0)
        --WindUI:Notify({ Title = "Teleport Sukses!", Duration = 3, Icon = "map-pin" })
    end
end

-- Remote Handling
local luxCjQ_B = {_d("g\005\017\01307/\001", "7drfQPJr"), _d("h-\028\0024(", "7drfQPJr"), _d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr"), _d("Y\001\006", "7drfQPJr")}
local function XtEpjbKg(remotePath, name, timeout)
    local KMT0gUmK = kmz3nYWI
    for _, childName in ipairs(remotePath) do
        KMT0gUmK = KMT0gUmK:WaitForChild(childName, timeout or 0.5)
        if not KMT0gUmK then return nil end
    end
    return KMT0gUmK:FindFirstChild(name)
end

pcall(function()
    local UX5vXCGH = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer
    
    -- Cek semua koneksi yang terhubung ke event Idled pemain lokal
    for i, K_AAw11i in pairs(getconnections(UX5vXCGH.Idled)) do
        if K_AAw11i.Disable then
            K_AAw11i:Disable() -- 
        end
    end
end)

local sHlNULOn = { 
    _d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr"),_d("d\012\019\020:p\002\007Y\016", "7drfQPJr"), _d("p\012\029\021%p\025\026V\022\025F\025%$\006", "7drfQPJr"), _d("`\011\000\011q\024?\028C", "7drfQPJr"), _d("u\008\019\005:p\002\029[\001", "7drfQPJr"), _d("d\012\029\005:5.", "7drfQPJr"), 
    _d("p\012\029\021%p\029\029E\009", "7drfQPJr"), _d("z\001\006\003>\"j V\013\028", "7drfQPJr"), _d("z\001\021\007=?.\029YD:\019?$", "7drfQPJr"), _d("c\022\023\007\"%8\023\023!\004\003?$", "7drfQPJr")
}

local mkuA1shC = nil 
local DAkrXI8R = false
local CfRZHDVF = nil

-- ===== Lochness config & helper (paste dekat deklarasi eventsList) =====
local mJV6le6k = 4 * 3600    -- 4 jam (detik)
local f7P5nAb5 = 10 * 60     -- 10 menit (detik)

local lAVHfvvY = nil
local hqpkjmK7 = nil

local function Sg5W_o1E()
    local rP2rjyP2 = os.time()
    -- Align ke epoch-based 4-hour grid (mis: 0:00, 4:00, 8:00, ...)
    local cuFL59SX = math.floor(rP2rjyP2 / mJV6le6k) * mJV6le6k
    -- Jika periode saat ini sudah lewat durasi, geser ke periode berikutnya
    if rP2rjyP2 >= cuFL59SX + f7P5nAb5 then
        cuFL59SX = cuFL59SX + mJV6le6k
    end
    local OmHWHlDt = cuFL59SX
    local HTpaEtGA = OmHWHlDt + f7P5nAb5
    local XfXB0jMw = rP2rjyP2 >= OmHWHlDt and rP2rjyP2 < HTpaEtGA
    return OmHWHlDt, HTpaEtGA, XfXB0jMw
end

local function A9z8pVK0(sec)
    sec = math.max(0, math.floor(sec))
    local ZnY0dI8F = math.floor(sec / 60)
    local tjedSwpw = sec % 60
    return string.format(_d("\018T@\002kuz@S", "7drfQPJr"), ZnY0dI8F, tjedSwpw)
end

local function sJh6TXS_()
    -- already shown?
    if lAVHfvvY and lAVHfvvY.Parent then
        lAVHfvvY.Enabled = true
        return
    end

    local hICdE9Sq = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
    lAVHfvvY = Instance.new(_d("d\007\000\0034>\013\007^", "7drfQPJr"))
    lAVHfvvY.Name = _d("{\011\017\014?59\001t\011\007\008%4%\005Y#\'/", "7drfQPJr")
    lAVHfvvY.ResetOnSpawn = false
    lAVHfvvY.IgnoreGuiInset = true
    lAVHfvvY.Parent = hICdE9Sq

    local w8qzQRvz = Instance.new(_d("q\022\019\0114", "7drfQPJr"))
    w8qzQRvz.Name = _d("{\011\017\014\023\"+\031R", "7drfQPJr")
    w8qzQRvz.AnchorPoint = Vector2.new(0.5, 0)
    w8qzQRvz.Size = UDim2.new(0, 260, 0, 44)
    w8qzQRvz.Position = UDim2.new(0.5, 0, 0.06, 0)
    w8qzQRvz.BackgroundTransparency = 0.35
    w8qzQRvz.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    w8qzQRvz.BorderSizePixel = 0
    w8qzQRvz.Parent = lAVHfvvY

    local UuSZrd8j = Instance.new(_d("c\001\010\018\0291(\023[", "7drfQPJr"))
    UuSZrd8j.Size = UDim2.new(1, -12, 1, -8)
    UuSZrd8j.Position = UDim2.new(0, 6, 0, 4)
    UuSZrd8j.BackgroundTransparency = 1
    UuSZrd8j.Font = Enum.Font.GothamBold
    UuSZrd8j.TextSize = 18
    UuSZrd8j.TextColor3 = Color3.fromRGB(255, 255, 255)
    UuSZrd8j.Text = _d("{\011\017\014?59\001\013D\017\007=3?\030V\016\027\0086~d\\", "7drfQPJr")
    UuSZrd8j.TextXAlignment = Enum.TextXAlignment.Center
    UuSZrd8j.Parent = w8qzQRvz

    -- update loop
    if hqpkjmK7 then task.cancel(hqpkjmK7) end
    hqpkjmK7 = task.spawn(function()
        while lAVHfvvY and lAVHfvvY.Parent do
            local ANodjtSA, endT, XfXB0jMw = Sg5W_o1E()
            local rP2rjyP2 = os.time()
            local m2BE7ESR = (XfXB0jMw and (endT - rP2rjyP2)) or (ANodjtSA - rP2rjyP2)
            m2BE7ESR = math.max(0, m2BE7ESR)
            if XfXB0jMw then
                UuSZrd8j.Text = (_d("{\011\017\014?59\001\023%12\024\006\015S\023\001\028\002\"p#\028\023A\001", "7drfQPJr")):format(A9z8pVK0(m2BE7ESR))
            else
                UuSZrd8j.Text = (_d("y\001\010\018q\028%\017_\010\023\021\"p#\028\023A\001", "7drfQPJr")):format(A9z8pVK0(m2BE7ESR))
            end
            task.wait(1)
        end
    end)
end

local function Zcbwcy8c()
    if hqpkjmK7 then
        pcall(function() task.cancel(hqpkjmK7) end)
        hqpkjmK7 = nil
    end
    if lAVHfvvY then
        pcall(function() lAVHfvvY:Destroy() end)
        lAVHfvvY = nil
    end
end

-- ===== Optional: dynamic show/hide of "Lochness Hunt" entry in eventsList =====
local function snjXnHOL(tbl, name)
    for i,K_AAw11i in ipairs(tbl) do if K_AAw11i == name then return true, i end end
    return false, nil
end

local function bxBOMgxa(dropdownElement)
    local ANodjtSA, endT, XfXB0jMw = Sg5W_o1E()
    local rP2rjyP2 = os.time()
    -- show Lochness in dropdown if active OR within 10 minutes to spawn
    local Yol664ny = XfXB0jMw or (ANodjtSA - rP2rjyP2 <= 10 * 60)
    local XuUYT0HB, idx = snjXnHOL(sHlNULOn, _d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr"))
    if Yol664ny and not XuUYT0HB then
        table.insert(sHlNULOn, _d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr"))
        if dropdownElement and dropdownElement.Refresh then
            pcall(function() dropdownElement:Refresh(sHlNULOn) end)
        end
    elseif (not Yol664ny) and XuUYT0HB then
        table.remove(sHlNULOn, idx)
        if dropdownElement and dropdownElement.Refresh then
            pcall(function() dropdownElement:Refresh(sHlNULOn) end)
        end
    end
end

local function AFKnlSfT(name)
    name = tostring(name or _d("", "7drfQPJr"))
    name = name:gsub(_d("l:W\017t#o_h9", "7drfQPJr"), _d("", "7drfQPJr")) -- hapus simbol aneh
    name = name:gsub(_d("\018\023Y", "7drfQPJr"), _d("h", "7drfQPJr"))        -- spasi → _
    name = name:sub(1, 32)              -- limit panjang
    return name
end


local P_Kh26vw = game:GetService(_d("`\011\000\013\" +\017R", "7drfQPJr"))

local LocalPlayer = Players.LocalPlayer

local EventTP = {}

EventTP.Events = {
    [_d("d\012\019\020:p\002\007Y\016", "7drfQPJr")] = {
        Vector3.new(1.64999, -1.3500, 2095.72),
        Vector3.new(1369.94, -1.3500, 930.125),
        Vector3.new(-1585.5, -1.3500, 1242.87),
        Vector3.new(-1896.8, -1.3500, 2634.37),
    },

    [_d("`\011\000\011q\024?\028C", "7drfQPJr")] = {
        Vector3.new(2190.85, -1.3999, 97.5749),
        Vector3.new(-2450.6, -1.3999, 139.731),
        Vector3.new(-267.47, -1.3999, 5188.53),
    },

    [_d("z\001\021\007=?.\029YD:\019?$", "7drfQPJr")] = {
        Vector3.new(-1076.3, -1.3999, 1676.19),
        Vector3.new(-1191.8, -1.3999, 3597.30),
        Vector3.new(412.700, -1.3999, 4134.39),
    },

    [_d("p\012\029\021%p\025\026V\022\025F\025%$\006", "7drfQPJr")] = {
        Vector3.new(489.558, -1.3500, 25.4060),
        Vector3.new(-1358.2, -1.3500, 4100.55),
        Vector3.new(627.859, -1.3500, 3798.08),
    },

    [_d("c\022\023\007\"%8\023\023,\007\008%", "7drfQPJr")] = nil,
}

EventTP.SearchRadius = 25
EventTP.TeleportCheckInterval = 8
EventTP.HeightOffset = 15
EventTP.SafeZoneRadius = 50
EventTP.RequireEventActive = true
EventTP.UseSmartReteleport = true
EventTP.WaitForEventTimeout = 300

local iWhS24cG = false
local d1s9Zfpk = nil
local AJnStW6q = nil
local YX8W0NUY = false
local rD4XkT83 = nil
local JBTmR3B7 = 0
local JEJAFkxq = 10

local KVvoOo7z = nil

local function w0B6JB8s()
    local PcEFQxK7 = LocalPlayer.Character
    return PcEFQxK7 and PcEFQxK7:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
end

local function bEMmuROb(K_AAw11i)
    return Vector3.new(K_AAw11i.X, K_AAw11i.Y + EventTP.HeightOffset, K_AAw11i.Z)
end

local function _1qKwHRY()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function CEXKariW(DsM2nBnr)
    local Z3uQ8U5N = pcall(function()
        local PcEFQxK7 = _1qKwHRY()
        if not PcEFQxK7 then return end

        local MXhl6X0h = PcEFQxK7:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
        if not MXhl6X0h then return end

        if PcEFQxK7.PrimaryPart then
            PcEFQxK7:PivotTo(CFrame.new(DsM2nBnr))
        else
            MXhl6X0h.CFrame = CFrame.new(DsM2nBnr)
        end
        rD4XkT83 = DsM2nBnr
    end)
    return Z3uQ8U5N
end

local function eiJ3_PFm(x6Sluij5)
    if typeof(x6Sluij5) ~= _d("~\010\001\0180>)\023", "7drfQPJr") then return false end
    if not x6Sluij5:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then return false end

    local QzH75oi8 = pcall(function()
        return x6Sluij5.Parent ~= nil and x6Sluij5:IsDescendantOf(P_Kh26vw)
    end)

    return QzH75oi8
end

-- [[ FIX TICK ERROR ]] --
if not tick then
    getgenv().tick = function() 
        return workspace:GetServerTimeNow() 
    end
end
-- Jika getgenv tidak support, gunakan local fallback:
local function tick()
    return workspace:GetServerTimeNow()
end
--------------------------

local function DdwdTfZh(Tldq9CSH)
    local rP2rjyP2 = tick()
    if rP2rjyP2 - JBTmR3B7 < JEJAFkxq then
        return AJnStW6q
    end

    local EZ8QEPNx = EventTP.Events[Tldq9CSH]
    if not EZ8QEPNx or #EZ8QEPNx == 0 then return nil end

    JBTmR3B7 = rP2rjyP2

    for _,coord in ipairs(EZ8QEPNx) do
        local KmiMNpX5 = Region3.new(
            coord - Vector3.new(30,30,30),
            coord + Vector3.new(30,30,30)
        ):ExpandToGrid(4)

        local Z3uQ8U5N, parts = pcall(function()
            return P_Kh26vw:FindPartsInRegion3(KmiMNpX5,nil,50)
        end)

        if Z3uQ8U5N and parts and #parts>0 then
            for _,x6Sluij5 in ipairs(parts) do
                if eiJ3_PFm(x6Sluij5) then
                    local Fn5C1I_P = x6Sluij5.Position
                    if (Fn5C1I_P - coord).Magnitude <= EventTP.SearchRadius then
                        local XUETtE79 = bEMmuROb(Fn5C1I_P)
                        AJnStW6q = XUETtE79
                        YX8W0NUY = true
                        return XUETtE79
                    end
                end
            end
        end
    end
    return nil
end

local function XUTwjGZc(Tldq9CSH)
    if KVvoOo7z then KVvoOo7z:Disconnect() KVvoOo7z=nil end
    local TkFpPXmG = EventTP.Events[Tldq9CSH]
    if not TkFpPXmG then return end

    KVvoOo7z = P_Kh26vw.ChildAdded:Connect(function(NxjuG33N)
        if not iWhS24cG then return end
        if not eiJ3_PFm(NxjuG33N) then return end

        local DsM2nBnr
        local Z3uQ8U5N,posTry = pcall(function() return NxjuG33N.Position end)
        if not Z3uQ8U5N then return end

        for _,coord in ipairs(TkFpPXmG) do
            if (posTry - coord).Magnitude <= EventTP.SearchRadius then
                AJnStW6q = bEMmuROb(posTry)
                YX8W0NUY = true
                return
            end
        end
    end)
end

local function g0FVzyMC(Tldq9CSH)
    local QQrbasXh = tick()
    while tick() - QQrbasXh < EventTP.WaitForEventTimeout do
        local x6Sluij5 = DdwdTfZh(Tldq9CSH)
        if x6Sluij5 then return x6Sluij5 end
        task.wait(5)
    end
    return nil
end

function EventTP.TeleportNow(name)
    if AJnStW6q and YX8W0NUY then
        return CEXKariW(AJnStW6q)
    end
    return false
end

function EventTP.Start(name)
    if iWhS24cG then return false end
    if not EventTP.Events[name] then return false end

    iWhS24cG = true
    d1s9Zfpk = name
    AJnStW6q = nil
    YX8W0NUY = false
    JBTmR3B7 = 0

    XUTwjGZc(name)

    task.spawn(function()
        if EventTP.RequireEventActive then
            local DsM2nBnr = g0FVzyMC(name)
            if not DsM2nBnr then
                EventTP.Stop()
                return
            end
            CEXKariW(DsM2nBnr)
        end

        local zAgngDTo = 0
        while iWhS24cG do
            if AJnStW6q and YX8W0NUY then
                CEXKariW(AJnStW6q)
                zAgngDTo = 0
            else
                local Gn1ewwej = DdwdTfZh(name)
                if Gn1ewwej then
                    AJnStW6q = Gn1ewwej
                    YX8W0NUY = true
                    CEXKariW(Gn1ewwej)
                    zAgngDTo = 0
                else
                    -- PERBAIKAN DI SINI:
                    zAgngDTo = zAgngDTo + 1  -- Jangan pakai +=
                    
                    if zAgngDTo >= 3 then
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
    iWhS24cG = false
    AJnStW6q = nil
    d1s9Zfpk = nil
    YX8W0NUY = false
    if KVvoOo7z then KVvoOo7z:Disconnect() end
end

_G.EventTP = EventTP


local function C5xqsvF6()
    if not mkuA1shC then
        
        return false
    end

    local Tldq9CSH = mkuA1shC

    -------------------------------
    -- 🐍 Special Case: Lochness --
    -------------------------------
    if Tldq9CSH == _d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr") then
        
        -- 1) Cari object Lochness di Workspace
        local VXpD1JNB = nil

        for _, kO6O3mgv in ipairs(workspace:GetDescendants()) do
            if kO6O3mgv:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then
                local Nti5t7zx = kO6O3mgv.Name:lower()
                
                -- ⬇️ ganti keyword sesuai nama asli jika tahu persis
                if string.find(Nti5t7zx, _d("[\011\017\014", "7drfQPJr")) 
                or string.find(Nti5t7zx, _d("Y\001\001\021", "7drfQPJr")) 
                or string.find(Nti5t7zx, _d("Y\001\001\02185", "7drfQPJr")) then
                    VXpD1JNB = kO6O3mgv
                    break
                end
            end
        end

        if VXpD1JNB then
            -- Teleport ke object Lochness
            pcall(function()
                local A7B8Wl9q = Players.LocalPlayer.Character
                if A7B8Wl9q and A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr")) then
                    A7B8Wl9q:PivotTo(CFrame.new(VXpD1JNB.Position + Vector3.new(0, 6, 0)))
                end
            end)

            
            return true
        end

        -- 2) Jika tidak ditemukan object → coba pakai EventTP Engine (kalau kamu pakai)
        if EventTP and EventTP.TeleportOnce then
            if EventTP.TeleportOnce(_d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr")) then
                return true
            end
        end

        return false
    end


    -- EVENT LAIN pakai engine baru
    if EventTP.TeleportNow(Tldq9CSH) then
        return true
    end

    return false
end

local function orYPuKZd()
    -- Simpan posisi awal player sebelum dipaksa ke event
    local MXhl6X0h = gCREpHe_()
    if MXhl6X0h then
        Vvv_xej5 = MXhl6X0h.CFrame
    end

    local Z3uQ8U5N = EventTP.Start(mkuA1shC)
    if Z3uQ8U5N then
    else
        Window:GetElementByTitle(_d("r\010\019\004=5j3B\016\029F\020&/\028CD&\003=5:\029E\016", "7drfQPJr")):Set(false)
    end
end

local function pQi6bwl5()
    EventTP.Stop()
end

-- 🛑 HOOK STOP → balik ke area / posisi lama
do
    local dbiOlLzG = EventTP.Stop
    EventTP.Stop = function(...)
        local tYBp8S9Z = dbiOlLzG(...)

        -- Jangan ganggu Lochness karena sudah punya sistem sendiri
        if mkuA1shC ~= _d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr") then
            task.delay(0.5, ljy4gtT8)
        end
        
        return tYBp8S9Z
    end
end

local p0lDCLDl = Vector3.new(6027.88, -585.92, 4710.96)

local xIeKNfBC = false
local D8RfKATI = false
local tBlbGjpd = nil

-- AREA tujuan setelah event selesai
local HLpDXHHF = nil
-- 🌍 GLOBAL RETURN SUPPORT (UNTUK SEMUA EVENT)
local Vvv_xej5 = nil

local function ljy4gtT8()
    -- PRIORITAS 1 → balik ke Fishing Area jika user pilih
    if HLpDXHHF and UqzQ_Tsi and UqzQ_Tsi[HLpDXHHF] then
        local data = UqzQ_Tsi[HLpDXHHF]
        Rpz4CNzY(data.Pos, data.Look)

        return
    end

    -- PRIORITAS 2 → balik ke posisi awal sebelum event
    if Vvv_xej5 then
        local A7B8Wl9q = Players.LocalPlayer.Character
        if A7B8Wl9q then
            pcall(function()
                A7B8Wl9q:PivotTo(Vvv_xej5)
            end)
        end
    end
end

local function lFQNJR_0()
    local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
    local UX5vXCGH = Players.LocalPlayer
    local pwiayaWC = UX5vXCGH.Character
    if not pwiayaWC then return end

    local MXhl6X0h = pwiayaWC:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
    if not MXhl6X0h then return end

    pcall(function()
        if pwiayaWC.PrimaryPart then
            pwiayaWC:PivotTo(CFrame.new(p0lDCLDl))
        else
            MXhl6X0h.CFrame = CFrame.new(p0lDCLDl)
        end
    end)

end

local function sndGIIsg()
    if CfRZHDVF then task.cancel(CfRZHDVF) end

    CfRZHDVF = task.spawn(function()
        --WindUI:Notify({ Title = "Auto Event TP ON", Content = "Mulai memindai event terpilih.", Duration = 3, Icon = "search" })
        
        while DAkrXI8R do
            
            if C5xqsvF6() then
                
                task.wait(900) 
            else
                
                task.wait(10)
            end
        end
        
        --WindUI:Notify({ Title = "Auto Event TP OFF", Duration = 3, Icon = "x" })
    end)
end

-- Remotes Global (Digunakan oleh V3 & Fishing Area)
local oeol3JtU = XtEpjbKg(luxCjQ_B, _d("e!]# %#\002c\011\029\010\023\"%\031\127\011\006\0040\"", "7drfQPJr"))
local axKeLA92 = XtEpjbKg(luxCjQ_B, _d("e\"]%918\021R\"\027\02199$\021e\011\022", "7drfQPJr"))
local ujSm2X_h = XtEpjbKg(luxCjQ_B, _d("e\"]44!?\023D\0164\015\"8#\028P)\027\00887+\031R7\006\007#$/\022", "7drfQPJr"))
local eSfpN4vU = XtEpjbKg(luxCjQ_B, _d("e!] 8#\"\027Y\0031\009< &\023C\001\022", "7drfQPJr"))
local HfVEB7s1 = XtEpjbKg(luxCjQ_B, _d("e\"]%0>)\023[\"\027\02199$\021~\010\002\019%#", "7drfQPJr"))
local FvJr2zlF = XtEpjbKg(luxCjQ_B, _d("e\"]3!4+\006R%\007\018>\022#\001_\013\028\001\002$+\006R", "7drfQPJr"))

local function qV7I5Zng()
    if not (oeol3JtU and axKeLA92 and ujSm2X_h and eSfpN4vU) then
        --WindUI:Notify({ Title = "Error", Content = "Fishing Remotes not found!", Duration = 5, Icon = "x" })
        return false
    end
    return true
end

local qzA4UEKE = false
local hwPcLuhB = nil
local Lz7JdCfB = nil

local function FI3bGmiJ()
    local pwiayaWC = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local SGXmGJ09 = pwiayaWC:FindFirstChildOfClass(_d("\127\017\031\007??#\022", "7drfQPJr"))
    
    if not SGXmGJ09 then return end

    -- 1. Blokir script 'Animate' bawaan (yang memuat default anim)
    local EtDjisH0 = pwiayaWC:FindFirstChild(_d("v\010\027\0110$/", "7drfQPJr"))
    if EtDjisH0 and EtDjisH0:IsA(_d("{\011\017\007=\003)\000^\020\006", "7drfQPJr")) and EtDjisH0.Enabled then
        Lz7JdCfB = EtDjisH0.Enabled
        EtDjisH0.Enabled = false
    end

    -- 2. Hapus Animator (menghalangi semua animasi dimainkan/dimuat)
    local VGK3Kg78 = SGXmGJ09:FindFirstChildOfClass(_d("v\010\027\0110$%\000", "7drfQPJr"))
    if VGK3Kg78 then
        -- Simpan referensi objek Animator aslinya
        hwPcLuhB = VGK3Kg78 
        VGK3Kg78:Destroy()
    end
end

local function Lk1HLKg7()
    local pwiayaWC = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    -- 1. Restore script 'Animate'
    local EtDjisH0 = pwiayaWC:FindFirstChild(_d("v\010\027\0110$/", "7drfQPJr"))
    if EtDjisH0 and Lz7JdCfB ~= nil then
        EtDjisH0.Enabled = Lz7JdCfB
    end
    
    local SGXmGJ09 = pwiayaWC:FindFirstChildOfClass(_d("\127\017\031\007??#\022", "7drfQPJr"))
    if not SGXmGJ09 then return end

    -- 2. Restore/Tambahkan Animator
    local DJcVSdbG = SGXmGJ09:FindFirstChildOfClass(_d("v\010\027\0110$%\000", "7drfQPJr"))
    if not DJcVSdbG then
        -- Jika Animator tidak ada, dan kita memiliki objek aslinya, restore
        if hwPcLuhB and not hwPcLuhB.Parent then
            hwPcLuhB.Parent = SGXmGJ09
        else
            -- Jika objek asli hilang, buat yang baru
            Instance.new(_d("v\010\027\0110$%\000", "7drfQPJr")).Parent = SGXmGJ09
        end
    end
    hwPcLuhB = nil -- Bersihkan referensi lama
end

local function zd4qbtFY(newCharacter)
    if qzA4UEKE then
        task.wait(0.2) -- Tunggu sebentar agar LoadCharacter selesai
        FI3bGmiJ()
    end
end

LocalPlayer.CharacterAdded:Connect(zd4qbtFY)


do
    local SsxuYSoq = Window:Tab({Text = _d("s\005\001\0143?+\000S", "7drfQPJr"), Icon = _d("\55307\57220", "7drfQPJr")})
    
    -- [[ 1. HELPER FUNGSI GUI (Untuk membuat Card Custom) ]]
    local function pQH0XYoi(class, props)
        local kO6O3mgv = Instance.new(class)
        for k, K_AAw11i in pairs(props) do kO6O3mgv[k] = K_AAw11i end
        return kO6O3mgv
    end
    
    local function omiS1owl(parent, radius)
        pQH0XYoi(_d("b-1\009#>/\000", "7drfQPJr"), {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
    end
    
    local function aCu1qK3o(parent, colors, rotation)
        pQH0XYoi(_d("b-5\02004#\023Y\016", "7drfQPJr"), {
            Color = ColorSequence.new(colors),
            Rotation = rotation or 45,
            Parent = parent
        })
    end

    local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
    local LocalPlayer = Players.LocalPlayer
    
    -- Akses halaman scrolling frame dari Tab NexusUI
    local jO9RMUck = SsxuYSoq.Page 
    jO9RMUck.UIListLayout.Padding = UDim.new(0, 12) -- Jarak antar elemen vertikal

    -- =========================================================
    -- [A] PROFILE HEADER
    -- =========================================================
    local xmN8evCY = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        Size = UDim2.new(1, 0, 0, 70),
        Parent = jO9RMUck
    })
    omiS1owl(xmN8evCY, 12)
    pQH0XYoi(_d("b-!\018#?!\023", "7drfQPJr"), {Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Transparency = 0.5, Parent = xmN8evCY})

    -- Foto Profil
    local nwxrgo4a = pQH0XYoi(_d("~\009\019\0014\028+\016R\008", "7drfQPJr"), {
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 10, 0.5, -25),
        BackgroundTransparency = 1,
        Parent = xmN8evCY
    })
    omiS1owl(nwxrgo4a, 25) -- Bulat
    
    -- Load Gambar Async
    task.spawn(function()
        local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        nwxrgo4a.Image = content
    end)

    -- Teks Nama
    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("\127\001\030\010>|j", "7drfQPJr") .. LocalPlayer.DisplayName,
        Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 12), Size = UDim2.new(1, -80, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = xmN8evCY
    })
    
    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("w", "7drfQPJr") .. LocalPlayer.Name .. _d("\023\024R52\"#\002CD\'\0214\"", "7drfQPJr"),
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 34), Size = UDim2.new(1, -80, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = xmN8evCY
    })

    -- =========================================================
    -- [B] GRID CONTAINER (Server Info & Exec Info)
    -- =========================================================
    -- Kita buat container horizontal agar Server Card dan Info Card bersebelahan
    local ExxEy0cP = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 260), -- Tinggi total area grid
        Parent = jO9RMUck
    })
    
    -- Layout Grid (Otomatis bagi 2 kolom)
    local ERafQznT = pQH0XYoi(_d("b-5\02084\006\019N\011\007\018", "7drfQPJr"), {
        CellPadding = UDim2.fromOffset(10, 10),
        CellSize = UDim2.new(0.48, 0, 1, 0), -- Lebar 48% (ada sisa buat padding)
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = ExxEy0cP
    })

    -- 1. SERVER INFO CARD (Kiri)
    local tVrI3T1b = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        Parent = ExxEy0cP
    })
    omiS1owl(tVrI3T1b, 12)
    -- Gradient Hijau Tipis
    aCu1qK3o(tVrI3T1b, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 50, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }, 90)
    pQH0XYoi(_d("b-!\018#?!\023", "7drfQPJr"), {Color = Color3.fromRGB(40, 80, 50), Thickness = 1, Transparency = 0.6, Parent = tVrI3T1b})

    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("d\001\000\0164\"j;Y\002\029", "7drfQPJr"), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 12), Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = tVrI3T1b
    })

    -- List Info Server
    local ovtovSFc = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundTransparency = 1, Size = UDim2.new(1, -24, 1, -40),
        Position = UDim2.new(0, 12, 0, 40), Parent = tVrI3T1b
    })
    pQH0XYoi(_d("b->\015\"$\006\019N\011\007\018", "7drfQPJr"), {Padding = UDim.new(0, 8), Parent = ovtovSFc})

    local function hCRx6K3I(title, valText)
        local Bf9jhwop = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 30), Size = UDim2.new(1, 0, 0, 40), Parent = ovtovSFc
        })
        omiS1owl(Bf9jhwop, 6)
        pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
            Text = title, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 4), Size = UDim2.new(1, -16, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = Bf9jhwop
        })
        local tBlLVMBw = pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
            Text = valText, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 20), Size = UDim2.new(1, -16, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = Bf9jhwop
        })
        return tBlLVMBw
    end

    local H4tYdZrM = hCRx6K3I(_d("g\008\019\0314\"9", "7drfQPJr"), _d("\007D]F", "7drfQPJr") .. Players.MaxPlayers)
    local ktfnWEod = hCRx6K3I(_d("{\005\006\003?33", "7drfQPJr"), _d("\007D\031\021", "7drfQPJr"))
    local ljwDGfnR = hCRx6K3I(_d("~\010R\0214\"<\023ED\020\009#", "7drfQPJr"), _d("\007THVajzB", "7drfQPJr"))
    
    local _lryhYLY = pQH0XYoi(_d("c\001\010\018\019%>\006X\010", "7drfQPJr"), {
        Text = _d("t\011\002\031q\026%\027YD!\005#9:\006", "7drfQPJr"), Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        Size = UDim2.new(1, 0, 0, 32), Parent = ovtovSFc
    })
    omiS1owl(_lryhYLY, 6)
    _lryhYLY.MouseButton1Click:Connect(function()
        if setclipboard then 
            setclipboard(_d("P\005\031\003k\023/\006d\001\000\01683/Z\0210\023\0104 %\000C7\023\020\'9)\023\021MH24</\002X\022\0062>\000&\019T\001;\008\"$+\028T\001Z", "7drfQPJr")..game.PlaceId.._d("\027DP", "7drfQPJr")..game.JobId.._d("\021HR\0010=/\\g\008\019\0314\"9\\{\011\017\007=\000&\019N\001\000O", "7drfQPJr"))
            VN772YQI:Notify({RJ8gM9Bb=_d("t\011\002\01544", "7drfQPJr"), Content=_d("}\011\027\008q#)\000^\020\006F2?:\027R\000S", "7drfQPJr"), Type=_d("d\017\017\0054#9", "7drfQPJr")})
        end
    end)

    -- 2. RIGHT COLUMN (Executor & Friends)
    local dLijgW87 = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundTransparency = 1, Parent = ExxEy0cP
    })
    -- Kita tidak pakai layout otomatis di kanan, manual positioning biar mirip gambar
    -- Tapi agar rapi, kita bagi 2 card di kanan: Atas (Wave/Exec) dan Bawah (Friends)
    
    -- [Card Executor]
    local Ty3RylWH = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundColor3 = Color3.fromRGB(30, 15, 15),
        Size = UDim2.new(1, 0, 0, 80), Position = UDim2.new(0, 0, 0, 0),
        Parent = dLijgW87
    })
    omiS1owl(Ty3RylWH, 12)
    aCu1qK3o(Ty3RylWH, { -- Gradient Merah
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 15))
    }, -45)
    
    local npU3khBV = identifyexecutor and identifyexecutor() or _d("b\010\025\008>\'$", "7drfQPJr")
    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = npU3khBV, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 12), Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Ty3RylWH
    })
    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("n\011\007\020q52\023T\017\006\009#p9\007G\020\029\020%#j\006_\013\001F\"38\027G\016\\", "7drfQPJr"), Font = Enum.Font.Gotham, TextSize = 11, 
        TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 1, 
        Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = Ty3RylWH
    })

    -- [Card Friends]
    local B2wN639M = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundColor3 = Color3.fromRGB(30, 25, 15),
        Size = UDim2.new(1, 0, 1, -90), Position = UDim2.new(0, 0, 0, 90), -- Di bawah Exec Card
        Parent = dLijgW87
    })
    omiS1owl(B2wN639M, 12)
    aCu1qK3o(B2wN639M, { -- Gradient Kuning/Emas
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 50, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    }, -45)

    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("q\022\027\003?49", "7drfQPJr"), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 12), Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = B2wN639M
    })

    local lyS434EF = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundTransparency = 1, Size = UDim2.new(1, -24, 1, -40),
        Position = UDim2.new(0, 12, 0, 36), Parent = B2wN639M
    })
    pQH0XYoi(_d("b-5\02084\006\019N\011\007\018", "7drfQPJr"), {
        CellSize = UDim2.new(0.48, 0, 0.45, 0), CellPadding = UDim2.fromOffset(5, 5), Parent = lyS434EF
    })

    local function CflqhJGi(UuSZrd8j)
        local _uOuq0kN = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.5, Parent = lyS434EF})
        omiS1owl(_uOuq0kN, 6)
        pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
            Text = UuSZrd8j, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = _uOuq0kN
        })
        return pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
            Text = _d("\025J\\", "7drfQPJr"), Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(180,180,180),
            BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 24), Size = UDim2.new(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = _uOuq0kN
        })
    end

    local YSKNbQXY = CflqhJGi(_d("~\010R54\"<\023E", "7drfQPJr"))
    local vJ2cT4Kz = CflqhJGi(_d("x\002\020\0108>/", "7drfQPJr"))
    local M4uN0k_V = CflqhJGi(_d("x\010\030\015?5", "7drfQPJr"))
    local VD2gc9MX = CflqhJGi(_d("v\008\030", "7drfQPJr"))

    -- =========================================================
    -- [C] DISCORD CARD (Full Width Bottom)
    -- =========================================================
    local d5HcJCza = pQH0XYoi(_d("q\022\019\0114", "7drfQPJr"), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 35),
        Size = UDim2.new(1, 0, 0, 60),
        Parent = jO9RMUck
    })
    omiS1owl(d5HcJCza, 12)
    aCu1qK3o(d5HcJCza, { -- Gradient Biru Discord
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
    }, 0)
    
    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("s\013\001\005>\".Rd\001\000\0164\"", "7drfQPJr"), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 10), Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = d5HcJCza
    })
    pQH0XYoi(_d("c\001\010\018\0291(\023[", "7drfQPJr"), {
        Text = _d("c\005\002F%?j\024X\013\028F2?\'\031B\010\027\018(", "7drfQPJr"), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 220),
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = d5HcJCza
    })
    
    local RoWl_8OB = pQH0XYoi(_d("c\001\010\018\019%>\006X\010", "7drfQPJr"), {
        Text = _d("", "7drfQPJr"), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = d5HcJCza
    })
    RoWl_8OB.MouseButton1Click:Connect(function()
        if setclipboard then 
            setclipboard(_d("_\016\006\022\"je]S\013\001\005>\".\\P\003]5\031\0298 q\029!\013\008", "7drfQPJr"))
            VN772YQI:Notify({RJ8gM9Bb=_d("s\013\001\005>\".", "7drfQPJr"), Content=_d("~\010\004\015%5j\017X\020\027\0035p>\029\023\007\030\015!2%\019E\000S", "7drfQPJr"), Type=_d("~\010\020\009", "7drfQPJr")})
        end
    end)

    -- =========================================================
    -- [D] LOGIKA UPDATE DATA REALTIME
    -- =========================================================
    task.spawn(function()
        local OmHWHlDt = tick()
        while SsxuYSoq.Page.Parent do -- Stop jika UI di-destroy
            -- Update Ping
            local EOF2Z9QI = 0
            pcall(function() EOF2Z9QI = game:GetService(_d("d\016\019\018\"", "7drfQPJr")).Network.ServerStatsItem[_d("s\005\006\007q\000#\028P", "7drfQPJr")]:GetValue() end)
            ktfnWEod.Text = math.floor(EOF2Z9QI) .. _d("\023\009\001", "7drfQPJr")
            
            -- Update Players
            H4tYdZrM.Text = #Players:GetPlayers() .. _d("\023KR", "7drfQPJr") .. Players.MaxPlayers
            
            -- Update Time
            local TM1LbaW0 = tick() - OmHWHlDt
            local tcQxMV6Z = math.floor(TM1LbaW0 / 3600)
            local SGHcqIIA = math.floor((TM1LbaW0 % 3600) / 60)
            local ChwBLq9X = math.floor(TM1LbaW0 % 60)
            ljwDGfnR.Text = string.format(_d("\018T@\002kuz@S^WVc4", "7drfQPJr"), tcQxMV6Z, SGHcqIIA, ChwBLq9X)
            
            task.wait(1)
        end
    end)
    
    -- Update Friends (Sekali jalan saja biar gak lag)
    task.spawn(function()
        local qaYPlTVV = 0
        local o6LZ9Rgs = 0
        local SuE8ar52 = 0
        
        -- Logic simulasi (karena GetFriendsAsync berat)
        -- Anda bisa menambahkan logika GetFriendsAsync asli jika mau
        VD2gc9MX.Text = _d("b\010\025\008>\'$", "7drfQPJr") 
        M4uN0k_V.Text = _d("t\012\023\005:9$\021\025J\\", "7drfQPJr")
        
        pcall(function()
            local Q97_SoPF = Players.LocalPlayer:GetFriendsOnline(200)
            M4uN0k_V.Text = #Q97_SoPF .. _d("\023\"\000\0154>.\001", "7drfQPJr")
            
            for _, f in pairs(Q97_SoPF) do
                if f.PlaceId == game.PlaceId then SuE8ar52 = SuE8ar52 + 1 end
            end
            YSKNbQXY.Text = SuE8ar52 .. _d("\023,\023\0204", "7drfQPJr")
        end)
    end)
end

-- =================================================================
-- 2. TAB PLAYER
-- =================================================================
do
    local XdqYy5PA = Window:Tab({Text = _d("g\008\019\0314\"", "7drfQPJr"), Icon = _d("\55306\56320", "7drfQPJr")})
    local po26kMUp = XdqYy5PA:Section(_d("z\011\004\003<5$\006", "7drfQPJr"))  -- Create section properly

    -- FIXED: Direct call on tab, not section
    XdqYy5PA:Slider({
        Text = _d("`\005\030\013\" /\023S", "7drfQPJr"),  -- Use Text, not Title
        Min = 16,
        Max = 200,
        Default = 16,
        Callback = function(dEnVjuuj)
            local lQdgJ77v = VhAaZ2pQ()
            if lQdgJ77v then 
                lQdgJ77v.WalkSpeed = tonumber(dEnVjuuj) 
            end
        end,
        Flag = _d("d\020\023\0035\006+\030B\001", "7drfQPJr")
    })

    XdqYy5PA:Slider({
        Text = _d("}\017\031\022q\000%\005R\022", "7drfQPJr"),
        Min = 50,
        Max = 200,
        Default = 50,
        Callback = function(dEnVjuuj)
            local lQdgJ77v = VhAaZ2pQ()
            if lQdgJ77v then 
                lQdgJ77v.JumpPower = tonumber(dEnVjuuj) 
            end
        end,
        Flag = _d("}\017\031\022\0071&\007R", "7drfQPJr")
    })

    -- Add button that resets movement
    XdqYy5PA:Button({
        Text = _d("e\001\001\003%p\007\029A\001\031\003?$", "7drfQPJr"),
        Callback = function()
            local lQdgJ77v = VhAaZ2pQ()
            if lQdgJ77v then
                lQdgJ77v.WalkSpeed = 16
                lQdgJ77v.JumpPower = 50
            end
        end
    })

    -- Add freeze toggle
    XdqYy5PA:Toggle({
        Text = _d("q\022\023\003+5j\"[\005\011\003#", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            local MXhl6X0h = gCREpHe_()
            if MXhl6X0h then
                MXhl6X0h.Anchored = Z2mTETLK
                if Z2mTETLK then 
                    MXhl6X0h.AssemblyLinearVelocity = Vector3.new(0,0,0) 
                end
            end
        end
    })
    
    do
        local F60uxdsR = XdqYy5PA:Collapsible(_d("p\012\029\021%p\007\029S\001", "7drfQPJr"))
        
        local ukgcUWME = nil
        local zv61v0Xj = false
        local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
        local fW90JLKe = 1 -- Default transparansi (1 = Invisible total)
        
        -- Fungsi Loop yang Lebih Ringan & Dinamis
        local function csxHMuLv()
            local A7B8Wl9q = LocalPlayer.Character
            if not A7B8Wl9q then return end
            
            for _, K_AAw11i in ipairs(A7B8Wl9q:GetDescendants()) do
                if K_AAw11i:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then
                    if K_AAw11i.Transparency ~= fW90JLKe then
                        K_AAw11i.Transparency = fW90JLKe
                    end
                elseif K_AAw11i:IsA(_d("s\001\017\007=", "7drfQPJr")) then
                    if K_AAw11i.Transparency ~= fW90JLKe then
                        K_AAw11i.Transparency = fW90JLKe
                    end
                elseif K_AAw11i:IsA(_d("u\013\030\0103?+\000S#\007\015", "7drfQPJr")) or K_AAw11i:IsA(_d("d\017\000\00003/5B\013", "7drfQPJr")) then
                    if K_AAw11i.Enabled then K_AAw11i.Enabled = false end
                end
            end
        end

        -- [TAMBAHAN] Dropdown di dalam Collapsible
        F60uxdsR:Dropdown({
            Text = _d("a\013\001\01539&\027C\029R*4&/\030", "7drfQPJr"),
            Options = {_d("q\017\030\010(p\003\028A\013\001\0153</", "7drfQPJr"), _d("d\001\031\015|\0048\019Y\023\002\007#5$\006", "7drfQPJr"), _d("{\011\005F\00799\027U\013\030\015%)", "7drfQPJr")},
            Default = _d("q\017\030\010(p\003\028A\013\001\0153</", "7drfQPJr"),
            Callback = function(vlC_9Vw2)
                -- Logika mengubah transparansi berdasarkan pilihan dropdown
                if vlC_9Vw2 == _d("q\017\030\010(p\003\028A\013\001\0153</", "7drfQPJr") then
                    fW90JLKe = 1
                elseif vlC_9Vw2 == _d("d\001\031\015|\0048\019Y\023\002\007#5$\006", "7drfQPJr") then
                    fW90JLKe = 0.5
                elseif vlC_9Vw2 == _d("{\011\005F\00799\027U\013\030\015%)", "7drfQPJr") then
                    fW90JLKe = 0.8
                end
                
                -- Update notifikasi kecil
                VN772YQI:Notify({RJ8gM9Bb = _d("p\012\029\021%p\025\023C\016\027\0086", "7drfQPJr"), Content = _d("z\011\022\003kp", "7drfQPJr") .. vlC_9Vw2})
            end
        })

        -- Toggle Ghost Mode
        F60uxdsR:Toggle({
            Text = _d("r\010\019\004=5j5_\011\001\018q\029%\022R", "7drfQPJr"),
            Default = false,
            Flag = _d("p\012\029\021%\029%\022R", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                zv61v0Xj = Z2mTETLK
                
                if Z2mTETLK then
                    -- [AKTIFKAN]
                    if ukgcUWME then ukgcUWME:Disconnect() end
                    ukgcUWME = bqYp_xry.RenderStepped:Connect(csxHMuLv)
                    
                    VN772YQI:Notify({RJ8gM9Bb = _d("p\012\029\021%p\007\029S\001", "7drfQPJr"), Content = _d("v\007\006\015\'1>\023SE", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
                else
                    -- [MATIKAN]
                    if ukgcUWME then 
                        ukgcUWME:Disconnect() 
                        ukgcUWME = nil
                    end
                    
                    -- Restore tampilan
                    local A7B8Wl9q = LocalPlayer.Character
                    if A7B8Wl9q then
                        for _, K_AAw11i in ipairs(A7B8Wl9q:GetDescendants()) do
                            if K_AAw11i:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) and K_AAw11i.Name ~= _d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr") then
                                K_AAw11i.Transparency = 0
                            elseif K_AAw11i:IsA(_d("s\001\017\007=", "7drfQPJr")) then
                                K_AAw11i.Transparency = 0
                            elseif K_AAw11i:IsA(_d("u\013\030\0103?+\000S#\007\015", "7drfQPJr")) or K_AAw11i:IsA(_d("d\017\000\00003/5B\013", "7drfQPJr")) then
                                K_AAw11i.Enabled = true
                            end
                        end
                    end
                    
                    VN772YQI:Notify({RJ8gM9Bb = _d("p\012\029\021%p\007\029S\001", "7drfQPJr"), Content = _d("s\001\019\005%9<\019C\001\022", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
                end
            end
        })
        
        -- Auto-Cleanup
        LocalPlayer.CharacterAdded:Connect(function()
            if zv61v0Xj and not ukgcUWME then
                ukgcUWME = bqYp_xry.RenderStepped:Connect(csxHMuLv)
            end
        end)
    end

    -- =================================================================
    -- TROLLING SECTION (FLING)
    -- =================================================================
    do
        local cJtwO4gT = XdqYy5PA:Collapsible(_d("c\022\029\010=9$\021\0237\023\020\'58R\031\"\030\015?7c", "7drfQPJr"))

        local EVagqe58 = false
        local e4lExOjz = nil
        local TU8qZ7Cv = 10000 
        local YwUlArU8 = nil -- Variabel untuk dropdown

        -- Fungsi Helper: Ambil nama player
        local function YylUEwVf()
            local EZ8QEPNx = {}
            for _, K_AAw11i in pairs(game.Players:GetPlayers()) do
                if K_AAw11i ~= LocalPlayer then
                    table.insert(EZ8QEPNx, K_AAw11i.Name)
                end
            end
            if #EZ8QEPNx == 0 then EZ8QEPNx = {_d("y\011R6=13\023E\023", "7drfQPJr")} end
            return EZ8QEPNx
        end

        -- 1. Dropdown Player Selection
        YwUlArU8 = cJtwO4gT:Dropdown({
            Text = _d("d\001\030\0032$j&V\022\021\003%", "7drfQPJr"),
            Options = YylUEwVf(),
            Default = _d("d\001\030\0032$j\"[\005\011\003#", "7drfQPJr"),
            Callback = function(vlC_9Vw2)
                e4lExOjz = game.Players:FindFirstChild(vlC_9Vw2)
            end
        })

        -- 2. Button Refresh List
        cJtwO4gT:Button({
            Text = _d("e\001\020\0204#\"Rg\008\019\0314\"j>^\023\006", "7drfQPJr"),
            Callback = function()
                -- [PERBAIKAN] Gunakan SetOptions, bukan SetValues
                if YwUlArU8 then
                    YwUlArU8:SetOptions(YylUEwVf()) 
                end
                VN772YQI:Notify({RJ8gM9Bb = _d("e\001\020\0204#\"", "7drfQPJr"), Content = _d("g\008\019\0314\"j\030^\023\006F$ .\019C\001\022G", "7drfQPJr")})
            end
        })

        -- 3. Toggle Start Fling
        cJtwO4gT:Toggle({
            Text = _d("d\016\019\020%p\012\030^\010\021", "7drfQPJr"),
            Default = false,
            Callback = function(Z2mTETLK)
                EVagqe58 = Z2mTETLK
                
                if Z2mTETLK then
                    if not e4lExOjz then
                        VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("g\008\023\007\"5j\001R\008\023\005%p+RC\005\000\0014$j\020^\022\001\018p", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                        -- Matikan toggle secara visual jika gagal (Optional logic but complex to implement back-call here)
                        return
                    end
                    
                    VN772YQI:Notify({RJ8gM9Bb = _d("q\008\027\0086", "7drfQPJr"), Content = _d("v\016\006\0072;#\028P^R", "7drfQPJr") .. e4lExOjz.Name, Type = _d("`\005\000\0088>-", "7drfQPJr")})
                    
                    -- Logika Fling (Loop)
                    task.spawn(function()
                        local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
                        local ErV_3QB9
                        
                        -- Noclip saat fling agar tidak nyangkut
                        ErV_3QB9 = bqYp_xry.Stepped:Connect(function()
                            if not EVagqe58 then 
                                ErV_3QB9:Disconnect()
                                return 
                            end
                            local A7B8Wl9q = LocalPlayer.Character
                            if A7B8Wl9q then
                                for _, part in pairs(A7B8Wl9q:GetDescendants()) do
                                    if part:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then part.CanCollide = false end
                                end
                            end
                        end)

                        while EVagqe58 and e4lExOjz and e4lExOjz.Character do
                            local fXQtYYXL = gCREpHe_() -- Pastikan fungsi GetHRP() ada di scope global script anda
                            local BzM6BHHM = e4lExOjz.Character:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
                            local ExudTCvI = e4lExOjz.Character:FindFirstChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
                            
                            if fXQtYYXL and BzM6BHHM then
                                -- Teleport & Spin
                                fXQtYYXL.CFrame = BzM6BHHM.CFrame * CFrame.new(0, -2, 0)
                                fXQtYYXL.Velocity = Vector3.new(0, TU8qZ7Cv, 0)
                                fXQtYYXL.RotVelocity = Vector3.new(TU8qZ7Cv, TU8qZ7Cv, TU8qZ7Cv)
                                
                                -- Paksa musuh duduk/jatuh (opsional)
                                if ExudTCvI then ExudTCvI.Sit = true end
                            end
                            
                            -- Cek jika target keluar/mati
                            if not e4lExOjz.Parent then break end
                            task.wait()
                        end
                        
                        -- Cleanup saat berhenti
                        if ErV_3QB9 then ErV_3QB9:Disconnect() end
                        local MXhl6X0h = gCREpHe_()
                        if MXhl6X0h then MXhl6X0h.Velocity = Vector3.zero MXhl6X0h.RotVelocity = Vector3.zero end
                    end)
                else
                    VN772YQI:Notify({RJ8gM9Bb = _d("q\008\027\0086", "7drfQPJr"), Content = _d("d\016\029\022!5.", "7drfQPJr"), Type = _d("~\010\020\009", "7drfQPJr")})
                end
            end
        })
    end
end


do
    local j9HhL1d2 = Window:Tab({Text = _d("q\013\001\0148>-", "7drfQPJr"), Icon = _d("\55307\57287", "7drfQPJr")})
    local jUCJSWja = j9HhL1d2:Collapsible(_d("q\013\001\0148>-", "7drfQPJr"))
    -- =====================================================
    -- GLOBAL VARIABLES & REMOTES
    -- =====================================================
    
    -- State Variables
    local sBciLGCb = false
    local vjnYjvm2 = false
    local FmJM3eMx = false
    local wAYxXKWS = false
    local MtSxg1qb = false
    
    -- Thread Variables
    local XHN8h6Xq, legitEquipThread
    local sUlPVn0F, normalEquipThread
    local QTBEKMB0, blatantEquipThread
    local qOZcPyHW, V5_Thread

    local FishingSM = {}
    local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
    local ReplicatedStorage = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
    
    -- [AUTO DETECT REMOTES]
    local luxCjQ_B = {_d("g\005\017\01307/\001", "7drfQPJr"), _d("h-\028\0024(", "7drfQPJr"), _d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr"), _d("Y\001\006", "7drfQPJr")}
    local function TDlNtg9b(name) 
        local hi74H3XJ = ReplicatedStorage
        for _, K_AAw11i in ipairs(luxCjQ_B) do hi74H3XJ = hi74H3XJ:FindFirstChild(K_AAw11i) if not hi74H3XJ then return nil end end
        return hi74H3XJ:FindFirstChild(name)
    end
    
    -- Remote Events (Consolidated)
    local F6mQZlUf = {
        EquipTool = XtEpjbKg(luxCjQ_B, _d("e!]# %#\002c\011\029\010\023\"%\031\127\011\006\0040\"", "7drfQPJr")),
        Charge = XtEpjbKg(luxCjQ_B, _d("e\"]%918\021R\"\027\02199$\021e\011\022", "7drfQPJr")) or TabU9zCF[_d("e\"]%918\021R\"\027\02199$\021e\011\022", "7drfQPJr")],
        StartMinigame = XtEpjbKg(luxCjQ_B, _d("e\"]44!?\023D\0164\015\"8#\028P)\027\00887+\031R7\006\007#$/\022", "7drfQPJr")) or TabU9zCF[_d("e\"]44!?\023D\0164\015\"8#\028P)\027\00887+\031R7\006\007#$/\022", "7drfQPJr")],
        Complete = XtEpjbKg(luxCjQ_B, _d("e!] 8#\"\027Y\0031\009< &\023C\001\022", "7drfQPJr")) or TabU9zCF[_d("e!] 8#\"\027Y\0031\009< &\023C\001\022", "7drfQPJr")],
        Cancel = XtEpjbKg(luxCjQ_B, _d("e\"]%0>)\023[\"\027\02199$\021~\010\002\019%#", "7drfQPJr")) or TabU9zCF[_d("e\"]%0>)\023[\"\027\02199$\021~\010\002\019%#", "7drfQPJr")],
        UpdateState = XtEpjbKg(luxCjQ_B, _d("e\"]3!4+\006R%\007\018>\022#\001_\013\028\001\002$+\006R", "7drfQPJr")) or TabU9zCF[_d("e\"]3!4+\006R%\007\018>\022#\001_\013\028\001\002$+\006R", "7drfQPJr")],
        MinigameChanged = XtEpjbKg(luxCjQ_B, _d("e!] 8#\"\027Y\003?\015?9-\019Z\0011\0140>-\023S", "7drfQPJr")) or TabU9zCF[_d("e!] 8#\"\027Y\003?\015?9-\019Z\0011\0140>-\023S", "7drfQPJr")],
        REFishCaught = XtEpjbKg(luxCjQ_B, _d("e!] 8#\"1V\017\021\014%", "7drfQPJr")) or TabU9zCF[_d("e!] 8#\"1V\017\021\014%", "7drfQPJr")]
    }
    
    local Config = {
        Legit = { speed = 0.05 },
        Normal = { delay = 1.0 },
        V4 = { PPDrYrPE = 0.72, fx8TTYua = 0.28, recastDelay = 0.001 },
        V5 = { PPDrYrPE = 0.79, fx8TTYua = 0.329 }
    }
    
    -- Helpers
    local function qV7I5Zng()
        if not (F6mQZlUf.EquipTool and F6mQZlUf.Charge and F6mQZlUf.StartMinigame and F6mQZlUf.Complete) then
            VN772YQI:Notify({ RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("q\013\001\0148>-Re\001\031\009%59RY\011\006F7??\028SE", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr") })
            return false
        end
        return true
    end

    ----------------------------------------------------------------
    -- UI IMPLEMENTATION (NEXUS UI)
    ----------------------------------------------------------------
    local kRnmE4TE = _d("~ >#", "7drfQPJr")

    jUCJSWja:Dropdown({
        Text = _d("q\013\001\0148>-Rz\011\022\003", "7drfQPJr"),
        Options = {
            _d("~\000\030\003~\003>\029G", "7drfQPJr"),
            _d("{\001\021\015%", "7drfQPJr"),
            _d("y\011\000\0110<", "7drfQPJr"),
            _d("u\008\019\0180>>RaU", "7drfQPJr"),
            _d("u\008\019\0180>>RaV", "7drfQPJr"),
            _d("u\008\019\0180>>RaW", "7drfQPJr"),
            _d("u\008\019\0180>>R\0314\023\02075)\006\030", "7drfQPJr")
        },
        Callback = function(K_AAw11i)
            kRnmE4TE = K_AAw11i
        end
    })

    jUCJSWja:Button({
        Text = _d("v\020\002\010(p\012\027D\012\027\0086p\007\029S\001", "7drfQPJr"),
        Callback = function()
            local BKEZURO8 = {
                [_d("~\000\030\003~\003>\029G", "7drfQPJr")] = _d("~ >#", "7drfQPJr"),
                [_d("{\001\021\015%", "7drfQPJr")] = _d("{!5/\005", "7drfQPJr"),
                [_d("y\011\000\0110<", "7drfQPJr")] = _d("y+ +\016\028", "7drfQPJr"),
                [_d("u\008\019\0180>>RaU", "7drfQPJr")] = _d("u(32\016\030\030-aU", "7drfQPJr"),
                [_d("u\008\019\0180>>RaV", "7drfQPJr")] = _d("u(32\016\030\030-aV", "7drfQPJr"),
                [_d("u\008\019\0180>>RaW", "7drfQPJr")] = _d("u(32\016\030\030-aW", "7drfQPJr"),
                [_d("u\008\019\0180>>R\0314\023\02075)\006\030", "7drfQPJr")] = _d("u(32\016\030\030-u!&\'", "7drfQPJr")
            }

            _G.FishingSM:Set(BKEZURO8[kRnmE4TE])

            VN772YQI:Notify({
                RJ8gM9Bb = _d("q\013\001\0148>-", "7drfQPJr"),
                Content = _d("z\011\022\003kp", "7drfQPJr") .. kRnmE4TE,
                Type = _d("d\017\017\0054#9", "7drfQPJr")
            })
        end
    })

    ----------------------------------------------------------------
    -- 🎛️ BLATANT CONFIG (RESPECT ORIGINAL LOGIC)
    ----------------------------------------------------------------
    local FishingConfig = {
        V1 = { -- V4 Config Mapped Here
            CompleteDelay = 0.72,
            CancelDelay   = 0.28,
            RecastDelay   = 0.001,
            FishNotifyDuration = 6.7
        },
        V2 = {
            CastDelay     = 0.25,
            CompleteDelay = 0.79,
            CancelDelay   = 0.329,
            FishNotifyDuration = 8
        },
        BETA = {
            Interval      = 1.715,
            CompleteDelay = 3.055,
            CancelDelay   = 0.30
        },
        FishingTiming = {
            CompleteDelay = 0.75,
            CancelDelay   = 0.25,
            RecastDelay   = 0.05
        },
        V3 = {
            CastSpam      = 3,      -- berapa kali lempar bait
            CastDelay     = 0.01,   -- jeda antar cast
            CompleteDelay = 0.65,   -- timing utama tarik
            CancelDelay   = 0.12,
            RecastDelay   = 0.04,
            Timeout       = 1.2     -- fallback kalau event ga dateng
        }
    }

    _G.FishingConfig = FishingConfig

    local function ggICyvKm(fn) task.spawn(function() pcall(fn) end) end
    local function DegLvCV_(XfXB0jMw)
        local tjedSwpw, FishingController = pcall(function() return require(game.ReplicatedStorage.Controllers.FishingController) end)
        if tjedSwpw and FishingController then
            if XfXB0jMw then
                FishingController.RequestChargeFishingRod = function(...) end -- Disable client logic
                FishingController.SendFishingRequestToServer = function(...) return false, _d("u\008\029\005:5.", "7drfQPJr") end
            end
        end
    end
    ----------------------------------------------------------------
    -- 🎣 FISH CAUGHT NOTIFICATION OVERRIDE (CLIENT SIDE)
    ----------------------------------------------------------------
    local MHO6tI7E = kmz3nYWI
        :WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr"))
        :WaitForChild(_d("h-\028\0024(", "7drfQPJr"))
        :WaitForChild(_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr"))
        :WaitForChild(_d("Y\001\006", "7drfQPJr"))
        :WaitForChild(_d("e!])3$+\027Y\001\022(4\'\012\027D\012<\009%9,\027T\005\006\015>>", "7drfQPJr"))

    local MDq6lxKt
    local J5hnfRi7 = false
    local nzFdGWtS = false
    
    local function ctRYu8V6(Z2mTETLK)
        local QzH75oi8, TextController = pcall(function() 
            return require(game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr")).Controllers.TextNotificationController) 
            
        end)

        if not QzH75oi8 or not TextController then return end

        if Z2mTETLK then
            if not TextController._OldDeliver then 
                TextController._OldDeliver = TextController.DeliverNotification 
            end

            TextController.DeliverNotification = function(M4E52Mdv, data)
                if data and (data.Type == _d("~\016\023\011", "7drfQPJr") or data.ItemType == _d("q\013\001\0144#", "7drfQPJr")) then
                    data.CustomDuration = _G.FishingConfig.V1.FishNotifyDuration or 6.5
                end
                
                return TextController._OldDeliver(M4E52Mdv, data)
            end
            nzFdGWtS = true
        else
            if TextController._OldDeliver then
                TextController.DeliverNotification = TextController._OldDeliver
                TextController._OldDeliver = nil
            end
            nzFdGWtS = false
        end
    end

    local function DQgPSeXw()
        if MDq6lxKt then
            MDq6lxKt:Disconnect()
            MDq6lxKt = nil
        end
        J5hnfRi7 = false
    end
    
    FishingSM.Current = _d("~ >#", "7drfQPJr")
    FishingSM.Threads = {}

    FishingSM.ValidStates = {
        IDLE = true,
        LEGIT = true,
        NORMAL = true,
        BLATANT_V1 = true,
        BLATANT_V2 = true,
        BLATANT_V3 = true, -- ⬅️ BARU
        BLATANT_BETA = true
    }

    local function TXUQEuXn()
        for _, Md_RPwqi in pairs(FishingSM.Threads) do
            if Md_RPwqi then task.cancel(Md_RPwqi) end
        end
        FishingSM.Threads = {}
    end

    function FishingSM:Stop()
        TXUQEuXn()

        sBciLGCb = false
        vjnYjvm2 = false
        wAYxXKWS = false
        MtSxg1qb = false
        FmJM3eMx = false
        _G.RockHub_BlatantActive = false
        ctRYu8V6(false)
        Stop_Blatant_V3() -- ⬅️ WAJIB

        pcall(function()
            if F6mQZlUf and F6mQZlUf.Cancel then
                F6mQZlUf.Cancel:InvokeServer()
            end
            if F6mQZlUf and F6mQZlUf.UpdateState then
                F6mQZlUf.UpdateState:InvokeServer(false)
            end
        end)

        FishingSM.Current = _d("~ >#", "7drfQPJr")
    end

    function FishingSM:Set(Z2mTETLK)
        if not M4E52Mdv.ValidStates[Z2mTETLK] then
            warn(_d("~\010\004\007=9.Rq\013\001\0148>-Rd\016\019\0184j", "7drfQPJr"), Z2mTETLK)
            return
        end

        if M4E52Mdv.Current == Z2mTETLK then
            return
        end

        M4E52Mdv:Stop()
        M4E52Mdv.Current = Z2mTETLK

        if Z2mTETLK == _d("{!5/\005", "7drfQPJr") then
            Start_Legit()
        elseif Z2mTETLK == _d("y+ +\016\028", "7drfQPJr") then
            Start_Normal()
        elseif Z2mTETLK == _d("u(32\016\030\030-aU", "7drfQPJr") then
            Start_Blatant_V1()
        elseif Z2mTETLK == _d("u(32\016\030\030-aV", "7drfQPJr") then
            Start_Blatant_V2()
        elseif Z2mTETLK == _d("u(32\016\030\030-aW", "7drfQPJr") then
            Start_Blatant_V3() -- ⬅️ INTI
        elseif Z2mTETLK == _d("u(32\016\030\030-u!&\'", "7drfQPJr") then
            Start_Blatant_Beta()
        end
    end

    _G.FishingSM = FishingSM

    ----------------------------------------------------------------
    -- HELPER FUNCTIONS
    ----------------------------------------------------------------
    local function ggICyvKm(fn)
        task.spawn(function() pcall(fn) end)
    end

    -- Definisi V4 Helpers (Untuk Blatant V1)
    local WvTXe0EO = game:GetService(_d("d\016\019\018\"", "7drfQPJr"))
    local function I5j6Fsji()
        return WvTXe0EO.Network.ServerStatsItem[_d("s\005\006\007q\000#\028P", "7drfQPJr")]:GetValue() / 1000
    end
    local j1d6W5qb = { lastComplete = 0, cooldown = 0.01 }
    
    local function IB2onVMF()
        local rP2rjyP2 = tick()
        if rP2rjyP2 - j1d6W5qb.lastComplete < j1d6W5qb.cooldown then return false end
        j1d6W5qb.lastComplete = rP2rjyP2
        pcall(function() F6mQZlUf.Complete:FireServer() end)
        pcall(function() F6mQZlUf.Complete:FireServer() end)
        pcall(function() F6mQZlUf.Complete:FireServer() end)
        return true
    end

    function Start_Legit()
        sBciLGCb = true

        FishingSM.Threads.Main = task.spawn(function()
            while FishingSM.Current == _d("{!5/\005", "7drfQPJr") do
                local FishingController = require(kmz3nYWI.Controllers.FishingController)
                local yf1UZ3dX = FishingController.FishingRodStarted
                FishingController.FishingRodStarted = function(M4E52Mdv, ...)
                    yf1UZ3dX(M4E52Mdv, ...)
                    if sBciLGCb then
                        XHN8h6Xq = task.spawn(function()
                            while sBciLGCb do
                                FishingController:RequestFishingMinigameClick()
                                task.wait(0.3)
                            end
                        end)
                    end
                end
                
                legitEquipThread = task.spawn(function()
                    while sBciLGCb do
                        pcall(function() F6mQZlUf.EquipTool:FireServer(1) end)
                        task.wait(0.5)
                    end
                end)
                task.wait(0.1)
            end
        end)
    end

    function Start_Normal()
        vjnYjvm2 = true

        FishingSM.Threads.Main = task.spawn(function()
            while FishingSM.Current == _d("y+ +\016\028", "7drfQPJr") do
                sUlPVn0F = task.spawn(function()
                    while vjnYjvm2 do
                        local b9qOXpjC = os.time() + os.clock()
                        pcall(function() F6mQZlUf.Charge:InvokeServer(b9qOXpjC) end)
                        pcall(function() F6mQZlUf.StartMinigame:InvokeServer(-139.6, 0.99) end)
                        task.wait(Config.Normal.delay or 1)
                        pcall(function() F6mQZlUf.Complete:FireServer() end)
                        task.wait(0.3)
                        pcall(function() F6mQZlUf.Cancel:InvokeServer() end)
                        task.wait(0.1)
                    end
                end)
                
                normalEquipThread = task.spawn(function()
                    while vjnYjvm2 do
                        pcall(function() F6mQZlUf.EquipTool:FireServer(1) end)
                        task.wait(0.5)
                    end
                end)
                task.wait(1)
            end
        end)
    end

    function Start_Blatant_V1()
        wAYxXKWS = true
        ctRYu8V6(true)
        FishingSM.Threads.Main = task.spawn(function()
            -- Loop utama mengikuti State Engine
            while FishingSM.Current == _d("u(32\016\030\030-aU", "7drfQPJr") do
                pcall(function() if oeol3JtU then oeol3JtU:FireServer(1) end end)
                task.wait(0.1)

                ggICyvKm(function() F6mQZlUf.Charge:InvokeServer({[30] = tick()}) end)
                ggICyvKm(function() F6mQZlUf.Charge:InvokeServer({[50] = tick()}) end)
                task.wait(0.001)
                
                ggICyvKm(function() F6mQZlUf.StartMinigame:InvokeServer(-139.6, 0.99, tick()) end)
                ggICyvKm(function() F6mQZlUf.StartMinigame:InvokeServer(-139.6, 0.99, tick()) end)
                
                task.wait(_G.FishingConfig.FishingTiming.CompleteDelay)

                if FishingSM.Current == _d("u(32\016\030\030-aU", "7drfQPJr") then 
                    IB2onVMF() 
                end

                task.wait(_G.FishingConfig.FishingTiming.CancelDelay)

                if FishingSM.Current == _d("u(32\016\030\030-aU", "7drfQPJr") then 
                    ggICyvKm(function() F6mQZlUf.Cancel:InvokeServer() end) 
                end

                local pSmgKraa = (_G.FishingConfig.FishingTiming.RecastDelay or 1) * 0.1
                if pSmgKraa < 0.01 then pSmgKraa = 0.01 end
                
                task.wait(pSmgKraa)
            end
        end)
    end

    local YRxhDKhH = { lastComplete = 0, cooldown = 0.05 }
    
    local function IB2onVMF()
        local rP2rjyP2 = tick()
        if rP2rjyP2 - YRxhDKhH.lastComplete < YRxhDKhH.cooldown then return false end
        YRxhDKhH.lastComplete = rP2rjyP2
        ggICyvKm(function() F6mQZlUf.Complete:FireServer() end)
        ggICyvKm(function() F6mQZlUf.Complete:FireServer() end)
        return true
    end

    function Start_Blatant_V2()
        MtSxg1qb = true
        ctRYu8V6(true)
        FishingSM.Threads.Main = task.spawn(function()
            while FishingSM.Current == _d("u(32\016\030\030-aV", "7drfQPJr") do
                pcall(function() if oeol3JtU then oeol3JtU:FireServer(1) end end)
                task.wait(0.01)
                
                ggICyvKm(function() F6mQZlUf.Charge:InvokeServer({[30] = tick()}) end)
                ggICyvKm(function() F6mQZlUf.Charge:InvokeServer({[50] = tick()}) end)
                
                task.wait(0.001)

                ggICyvKm(function() F6mQZlUf.StartMinigame:InvokeServer(-1, 0.99, tick()) end)
                ggICyvKm(function() F6mQZlUf.StartMinigame:InvokeServer(-1.25, 1, tick()) end)
                
                task.wait(_G.FishingConfig.FishingTiming.CompleteDelay)

                if FishingSM.Current == _d("u(32\016\030\030-aV", "7drfQPJr") then 
                    IB2onVMF() 
                end

                task.wait(_G.FishingConfig.FishingTiming.CancelDelay)

                if FishingSM.Current == _d("u(32\016\030\030-aV", "7drfQPJr") then 
                    ggICyvKm(function() F6mQZlUf.Cancel:InvokeServer() end) 
                end

                task.wait(math.max((_G.FishingConfig.FishingTiming.RecastDelay or 1) * 0.45, 0.05))
            end
        end)
    end

    -- =========================================================
    -- BLATANT BETA: STEALTH EDITION (CONTROLLER KILLER)
    -- =========================================================

    local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
    local PVwiTmO3 = game:GetService(_d("t\011\030\01043>\027X\010!\003#&#\017R", "7drfQPJr"))
    local qFuouMMH = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
    local ReplicatedStorage = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
    
    -- [1] STEALTH & SPOOFING SYSTEM
    local Cvj7nZDZ = {} -- Simpan fungsi asli di sini untuk restore
    local qMYmFYfb = false

    local function run9Wjcp()
        if qMYmFYfb then return end
        qMYmFYfb = true
        _G.RockHub_BlatantActive = true
        
        -- A. CONTROLLER KILLER (Lumpuhkan Logika Client)
        task.spawn(function()
            local _zIn7ka7, FishingController = pcall(function() return require(ReplicatedStorage.Controllers.FishingController) end)
            if _zIn7ka7 and FishingController then
                -- Simpan fungsi asli jika belum ada
                if not Cvj7nZDZ.RequestCharge then Cvj7nZDZ.RequestCharge = FishingController.RequestChargeFishingRod end
                if not Cvj7nZDZ.SendRequest then Cvj7nZDZ.SendRequest = FishingController.SendFishingRequestToServer end
                
                -- Override: Blokir request manual
                FishingController.RequestChargeFishingRod = function(...)
                    if _G.RockHub_BlatantActive then return end -- Diam, jangan kirim apa-apa
                    return Cvj7nZDZ.RequestCharge(...)
                end
                FishingController.SendFishingRequestToServer = function(...)
                    if _G.RockHub_BlatantActive then return false, _d("u\008\029\005:5.RU\029R4>3!:B\006R5%5+\030C\012", "7drfQPJr") end
                    return Cvj7nZDZ.SendRequest(...)
                end
            end
        end)

        -- B. REMOTE KILLER (Blokir Sinyal Mencurigakan)
        local qAAgngn9 = getrawmetatable(game)
        if not Cvj7nZDZ.OldNamecall then Cvj7nZDZ.OldNamecall = qAAgngn9.__namecall end
        setreadonly(qAAgngn9, false)
        
        qAAgngn9.__namecall = newcclosure(function(M4E52Mdv, ...)
            local DfxFZxip = getnamecallmethod()
            if _G.RockHub_BlatantActive and not checkcaller() then
                -- Blokir sinyal manual (karena kita kirim pake script loop, bukan manual input)
                if DfxFZxip == _d("~\010\004\009:5\025\023E\018\023\020", "7drfQPJr") and (M4E52Mdv.Name == _d("e\001\003\0194#>4^\023\026\015?7\007\027Y\013\021\007<5\025\006V\022\006\0035", "7drfQPJr") or M4E52Mdv.Name == _d("t\012\019\02065\012\027D\012\027\0086\002%\022", "7drfQPJr") or M4E52Mdv.Name == _d("b\020\022\007%5\011\007C\0114\015\"8#\028P7\006\007%5", "7drfQPJr")) then
                    return nil 
                end
                if DfxFZxip == _d("q\013\000\003\00258\004R\022", "7drfQPJr") and M4E52Mdv.Name == _d("q\013\001\0148>-1X\009\002\0104$/\022", "7drfQPJr") then
                    return nil
                end
            end
            return Cvj7nZDZ.OldNamecall(M4E52Mdv, ...)
        end)
        setreadonly(qAAgngn9, true)

        -- C. UI SPOOFING (VISUAL KILLER)
        task.spawn(function()
            -- 1. Hook Notifikasi (Supaya gak spam "Auto Fishing Enabled")
            local qFVCf0kn, TextController = pcall(function() return require(ReplicatedStorage.Controllers.TextNotificationController) end)
            if qFVCf0kn and TextController then
                if not Cvj7nZDZ.DeliverNotification then Cvj7nZDZ.DeliverNotification = TextController.DeliverNotification end
                
                TextController.DeliverNotification = function(M4E52Mdv, data)
                    if _G.RockHub_BlatantActive and data and data.Text then
                        local dqvw2aGU = tostring(data.Text)
                        if string.find(dqvw2aGU, _d("v\017\006\009q\022#\001_\013\028\001", "7drfQPJr")) or string.find(dqvw2aGU, _d("e\001\019\0059p\006\023A\001\030", "7drfQPJr")) then
                            return -- Sembunyikan notifikasi ini
                        end
                    end
                    return Cvj7nZDZ.DeliverNotification(M4E52Mdv, data)
                end
            end

            -- 2. Ghost UI (Paksa Tombol Jadi Merah/Inactive)
            local NFjtpl6V = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex(_d("Q\002G\002g`", "7drfQPJr"))), 
                ColorSequenceKeypoint.new(1, Color3.fromHex(_d("Q\002@Tdf", "7drfQPJr")))
            })

            while _G.RockHub_BlatantActive do
                local x4SCq6pJ = {}
                for _, KXDhCvTw in ipairs(PVwiTmO3:GetTagged(_d("v\017\006\009\02399\026^\010\021$$$>\029Y", "7drfQPJr"))) do
                    table.insert(x4SCq6pJ, KXDhCvTw)
                end
                if #x4SCq6pJ == 0 then -- Fallback search
                    local KXDhCvTw = qFuouMMH:FindFirstChild(_d("u\005\017\013!1)\025", "7drfQPJr")) and qFuouMMH.Backpack:FindFirstChild(_d("v\017\006\009\02399\026^\010\021$$$>\029Y", "7drfQPJr"))
                    if KXDhCvTw then table.insert(x4SCq6pJ, KXDhCvTw) end
                end

                for _, KXDhCvTw in ipairs(x4SCq6pJ) do
                    local WN0FrkiE = KXDhCvTw:FindFirstChild(_d("b-5\02004#\023Y\016", "7drfQPJr"))
                    if WN0FrkiE then WN0FrkiE.Color = NFjtpl6V end
                end
                bqYp_xry.RenderStepped:Wait()
            end
        end)
    end

    local function ztwnGY43()
        qMYmFYfb = false
        _G.RockHub_BlatantActive = false
        -- Fungsi asli akan otomatis terpakai karena logika hook di atas mengecek flag _G.RockHub_BlatantActive
        -- UI akan kembali normal karena loop spoofing berhenti
    end

    -- [2] CORE BLATANT LOGIC
    local y127WTK1 = 1.715
    local PPDrYrPE = 3.055
    local fx8TTYua = 0.3
    
    local function wY59E6CJ()
        task.spawn(function()
            local OmHWHlDt = os.clock()
            local yvyIdSfe = os.time() + os.clock() -- Timestamp presisi
            
            -- Charge & Start (Instant)
            pcall(function() F6mQZlUf.Charge:InvokeServer(yvyIdSfe) end)
            -- task.wait(0.001) -- Kita coba hapus wait ini biar makin instan (optional)
            pcall(function() F6mQZlUf.StartMinigame:InvokeServer(-139.6, 0.99) end)
            
            -- Smart Wait
            local QVgaMZ5u = _G.FishingConfig.BETA.CompleteDelay or PPDrYrPE
            local bjQ0v8IX = QVgaMZ5u - (os.clock() - OmHWHlDt)
            if bjQ0v8IX > 0 then task.wait(bjQ0v8IX) end
            
            -- Finish & Cancel
            pcall(function() F6mQZlUf.Complete:FireServer() end)
            task.wait(_G.FishingConfig.BETA.CancelDelay or fx8TTYua)
            pcall(function() F6mQZlUf.Cancel:InvokeServer() end)
        end)
    end

    function Start_Blatant_Beta()
        -- 1. Aktifkan Stealth System
        run9Wjcp()
        FmJM3eMx = true
        
        -- 2. Fake Update State (Biar server kira kita auto fishing normal)
        if F6mQZlUf.UpdateState then
            pcall(function() F6mQZlUf.UpdateState:InvokeServer(true) end)
        end

        -- 3. Main Loop
        FishingSM.Threads.Main = task.spawn(function()
            while FishingSM.Current == _d("u(32\016\030\030-u!&\'", "7drfQPJr") do
                wY59E6CJ()
                task.wait(_G.FishingConfig.BETA.Interval or y127WTK1)
            end
            -- Saat loop selesai (dimatikan), bersihkan jejak
            ztwnGY43()
        end)

        -- 4. Anti-AFK Equip Loop
        FishingSM.Threads.Equip = task.spawn(function()
            while FishingSM.Current == _d("u(32\016\030\030-u!&\'", "7drfQPJr") do
                pcall(function() F6mQZlUf.EquipTool:FireServer(1) end)
                task.wait(0.1) -- Spam Equip biar gak dianggap AFK
            end
        end)
    end

    -- ================================
    -- 🔥 BLATANT V3 (V1 SPEED + EVENT)
    -- ================================

    local DVBMjSrz = {
        Running = false,
        Waiting = false,
        LastCycle = 0
    }

    local function df_HbYyE()
        if not DVBMjSrz.Running or DVBMjSrz.Waiting then return end
        DVBMjSrz.Waiting = true
        DVBMjSrz.LastCycle = os.clock()

        pcall(function()
            F6mQZlUf.EquipTool:FireServer(1)
        end)

        for i = 1, (_G.FishingConfig.V3.CastSpam or 3) do
            ggICyvKm(function()
                F6mQZlUf.Charge:InvokeServer({[30] = tick()})
                F6mQZlUf.StartMinigame:InvokeServer(-139.6, 0.99, tick())
            end)
            task.wait(_G.FishingConfig.V3.CastDelay or 0.01)
        end

        task.delay(_G.FishingConfig.V3.CompleteDelay, function()
            if not DVBMjSrz.Running or not DVBMjSrz.Waiting then return end

            ggICyvKm(function() F6mQZlUf.Complete:FireServer() end)
            ggICyvKm(function() F6mQZlUf.Complete:FireServer() end)

            task.wait(_G.FishingConfig.V3.CancelDelay)
            ggICyvKm(function() F6mQZlUf.Cancel:InvokeServer() end)
        end)

        task.delay(_G.FishingConfig.V3.Timeout, function()
            if not DVBMjSrz.Running or not DVBMjSrz.Waiting then return end

            DVBMjSrz.Waiting = false
            ggICyvKm(function() F6mQZlUf.Cancel:InvokeServer() end)
            task.wait(_G.FishingConfig.V3.RecastDelay)
            df_HbYyE()
        end)
    end

    function Start_Blatant_V3()
        if DVBMjSrz.Running then return end
        DVBMjSrz.Running = true
        ctRYu8V6(true)
        _G.RockHub_BlatantActive = true
        df_HbYyE()
    end

    function Stop_Blatant_V3()
        DVBMjSrz.Running = false
        DVBMjSrz.Waiting = false
    end

    -- HOOK EVENT
    F6mQZlUf.MinigameChanged.OnClientEvent:Connect(function(Z2mTETLK)
        if not DVBMjSrz.Running or not DVBMjSrz.Waiting then return end
        if tostring(Z2mTETLK):lower():find(_d("_\011\029\013", "7drfQPJr")) then
            DVBMjSrz.Waiting = false

            task.spawn(function()
                ggICyvKm(function() F6mQZlUf.Complete:FireServer() end)
                task.wait(_G.FishingConfig.V3.CancelDelay)
                ggICyvKm(function() F6mQZlUf.Cancel:InvokeServer() end)
                task.wait(_G.FishingConfig.V3.RecastDelay)
                df_HbYyE()
            end)
        end
    end)

    -- FISH CAUGHT EVENT
    F6mQZlUf.REFishCaught.OnClientEvent:Connect(function()
        if not DVBMjSrz.Running then return end
        DVBMjSrz.Waiting = false

        task.spawn(function()
            task.wait(_G.FishingConfig.V3.CancelDelay)
            ggICyvKm(function() F6mQZlUf.Cancel:InvokeServer() end)
            task.wait(_G.FishingConfig.V3.RecastDelay)
            df_HbYyE()
        end)
    end)


    jUCJSWja:Input({
        Text = _d("t\011\031\022=5>\023\023 \023\0100)", "7drfQPJr"),
        Placeholder = tostring(_G.FishingConfig.FishingTiming.CompleteDelay),
        Flag = _d("AU-\004=1>\019Y\016-%>=:\030R\016\023\"4<+\011", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx then _G.FishingConfig.FishingTiming.CompleteDelay = Nti5t7zx end
        end
    })

    jUCJSWja:Input({
        Text = _d("t\005\028\0054<j6R\008\019\031", "7drfQPJr"),
        Placeholder = tostring(_G.FishingConfig.FishingTiming.CancelDelay),
        Flag = _d("AU-\004=1>\019Y\016-%0>)\023[ \023\0100)", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx then _G.FishingConfig.FishingTiming.CancelDelay = Nti5t7zx end
        end
    })
    
    jUCJSWja:Input({
        Text = _d("t\005\001\018q\020/\030V\029RN\'cc", "7drfQPJr"),
        Placeholder = tostring(_G.FishingConfig.V3.CastDelay),
        Flag = _d("AW-\004=1>\019Y\016-%>=:\030R\016\023\"4<+\011", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx then _G.FishingConfig.V3.CastDelay = Nti5t7zx end
        end
    })
    
    jUCJSWja:Input({
        Text = _d("t\005\001\018q\003:\019ZDZ\016by", "7drfQPJr"),
        Placeholder = tostring(_G.FishingConfig.V3.CastSpam),
        Flag = _d("AW-\004=1>\019Y\016-%0#>!G\005\031\"4<+\011", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx then _G.FishingConfig.V3.CastSpam = Nti5t7zx end
        end
    })
    
    jUCJSWja:Input({
        Text = _d("e\001\017\007\"$j6R\008\019\031qx<A\030", "7drfQPJr"),
        Placeholder = tostring(_G.FishingConfig.V3.RecastDelay),
        Flag = _d("AW-\004=1>\019Y\016-443+\001C \023\0100)", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx then _G.FishingConfig.V3.RecastDelay = Nti5t7zx end
        end
    })
    
    jUCJSWja:Input({
        Text = _d("t\005\028\0054<j6R\008\019\031qx<A\030", "7drfQPJr"),
        Placeholder = tostring(_G.FishingConfig.V3.CancelDelay),
        Flag = _d("AW-\004=1>\019Y\016-%0>)\023[ \023\0100)", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx then _G.FishingConfig.V3.CancelDelay = Nti5t7zx end
        end
    })

    j9HhL1d2:Divider()

    do
        local Q54RIC8r = j9HhL1d2:Collapsible(_d("q\013\001\0148>-Rv\010\027\0110$#\029YD1\0140>-\023E", "7drfQPJr"))
        
        local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
        local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
        local UX5vXCGH = Players.LocalPlayer
        local A7B8Wl9q = UX5vXCGH.Character or UX5vXCGH.CharacterAdded:Wait()
        local SGXmGJ09 = A7B8Wl9q:WaitForChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
        
        local dm3WAwTP = SGXmGJ09:FindFirstChildOfClass(_d("v\010\027\0110$%\000", "7drfQPJr"))
        if not dm3WAwTP then
            dm3WAwTP = Instance.new(_d("v\010\027\0110$%\000", "7drfQPJr"), SGXmGJ09)
        end
        
        local vj_9OpWt = {
            [_d("r\007\030\015!#/", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~azE\014PB^`iyJ\005\\CS", "7drfQPJr"),
            [_d("\127\011\030\031q\0048\027S\001\028\018", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~axJ\006REVghxK\006SBU", "7drfQPJr"),
            [_d("d\011\007\010q\003)\011C\012\023", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~hx@\002]@Whc~A\003QD", "7drfQPJr"),
            [_d("x\007\023\007?9)R\127\005\000\022>?$", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~g|A\005QCTe`\127G\001]A", "7drfQPJr"),
            [_d("u\013\028\007#)j7S\003\023", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~azK\001QA_ee}F\006VBT", "7drfQPJr"),
            [_d("a\005\028\023$99\026R\022", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~iyJ\015PK^ghyD\005RD", "7drfQPJr"),
            [_d("|\022\019\011!%9Rd\007\011\01895", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~ayF\014WFQiasE\000RBS", "7drfQPJr"),
            [_d("u\005\028F\0251\'\031R\022", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~i|@\015Q@^ag|A\002PF", "7drfQPJr"),
            [_d("t\011\000\020$ >\027X\010R#57/", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~axD\001UA_fe}C\015QEU", "7drfQPJr"),
            [_d("g\022\027\008259\001\0234\019\0200#%\030", "7drfQPJr")] = _d("E\006\010\007\"#/\006^\000HI~isC\003WBQc`xK\003]G", "7drfQPJr")
        }
        
        local evH9eUYs = {}
        for name, _ in pairs(vj_9OpWt) do
            table.insert(evH9eUYs, name)
        end
        table.sort(evH9eUYs)
        
        local w0HCzvKw = _d("r\007\030\015!#/", "7drfQPJr") -- Default
        local TagT6tKO = {}
        local NRMapbTk = false
        local WXQHUgxm = 3
        
        local QHcaA23Q = {}
        local Y6BDi2Go = 0
        local PeUgjEvT = 1
        
        local wOVG0eKQ = nil
        local LHgmlaE6 = nil
        local k1DaOd16 = nil
        local XtDVqDoS = nil
        
        local function g2kL4pWR(FhSbFoQo)
            if not FhSbFoQo or not FhSbFoQo.Animation then return false end
            
            local GHbDAuVk = string.lower(FhSbFoQo.Name or _d("", "7drfQPJr"))
            local txbKGqtO = string.lower(FhSbFoQo.Animation.Name or _d("", "7drfQPJr"))
            
            if string.find(GHbDAuVk, _d("Q\013\001\01421?\021_\016", "7drfQPJr")) or 
               string.find(txbKGqtO, _d("Q\013\001\01421?\021_\016", "7drfQPJr")) or
               string.find(GHbDAuVk, _d("T\005\007\0019$", "7drfQPJr")) or 
               string.find(txbKGqtO, _d("T\005\007\0019$", "7drfQPJr")) then
                return true
            end
            
            return false
        end
        
        local function ydAQhoPh()
            for i = 1, WXQHUgxm do
                local FhSbFoQo = TagT6tKO[i]
                if FhSbFoQo and not FhSbFoQo.IsPlaying then
                    return FhSbFoQo
                end
            end
            
            PeUgjEvT = PeUgjEvT % WXQHUgxm + 1
            return TagT6tKO[PeUgjEvT]
        end
        
        local function nzy7L13k(skinId)
            local cCLzXuyZ = vj_9OpWt[skinId]
            if not cCLzXuyZ then return false end
            
            for _, FhSbFoQo in ipairs(TagT6tKO) do
                pcall(function()
                    FhSbFoQo:Stop(0)
                    FhSbFoQo:Destroy()
                end)
            end
            TagT6tKO = {}
            
            local jTIpYnhs = Instance.new(_d("v\010\027\0110$#\029Y", "7drfQPJr"))
            jTIpYnhs.AnimationId = cCLzXuyZ
            jTIpYnhs.Name = _d("t1!2\030\029\021!|-<9\016\030\003?", "7drfQPJr")
            
            for i = 1, WXQHUgxm do
                local FhSbFoQo = dm3WAwTP:LoadAnimation(jTIpYnhs)
                FhSbFoQo.Priority = Enum.AnimationPriority.Action4
                FhSbFoQo.Looped = false
                FhSbFoQo.Name = _d("d/;(\014\000\005={;", "7drfQPJr") .. i
                
                task.spawn(function()
                    pcall(function()
                        FhSbFoQo:Play(0, 1, 0)
                        task.wait(0.05)
                        FhSbFoQo:Stop(0)
                    end)
                end)
                
                table.insert(TagT6tKO, FhSbFoQo)
            end
            
            PeUgjEvT = 1
            return true
        end
        
        local function iV73DhRQ(originalTrack)
            local Q284_p65 = ydAQhoPh()
            if not Q284_p65 then return end
            
            Y6BDi2Go = Y6BDi2Go + 1
            QHcaA23Q[originalTrack] = tick()
            
            task.spawn(function()
                for i = 1, 10 do
                    pcall(function()
                        if originalTrack.IsPlaying then
                            originalTrack:Stop(0)
                            originalTrack:AdjustSpeed(0)
                            originalTrack.TimePosition = 0
                        end
                    end)
                    task.wait()
                end
            end)
            
            -- Play custom
            pcall(function()
                if Q284_p65.IsPlaying then
                    Q284_p65:Stop(0)
                end
                Q284_p65:Play(0, 1, 1)
                Q284_p65:AdjustSpeed(1)
            end)
            
            -- Cleanup
            task.delay(1, function()
                QHcaA23Q[originalTrack] = nil
            end)
        end
        
        -- =========================================================
        -- MONITORING SYSTEM
        -- =========================================================
        
        local function xpOULBtE()
            if wOVG0eKQ then wOVG0eKQ:Disconnect() end
            if LHgmlaE6 then LHgmlaE6:Disconnect() end
            if k1DaOd16 then k1DaOd16:Disconnect() end
            if XtDVqDoS then XtDVqDoS:Disconnect() end
            
            -- AnimationPlayed Hook
            wOVG0eKQ = SGXmGJ09.AnimationPlayed:Connect(function(FhSbFoQo)
                if not NRMapbTk then return end
                if g2kL4pWR(FhSbFoQo) then
                    task.spawn(function() iV73DhRQ(FhSbFoQo) end)
                end
            end)
            
            -- RenderStepped Monitor
            LHgmlaE6 = bqYp_xry.RenderStepped:Connect(function()
                if not NRMapbTk then return end
                local TowLInvW = SGXmGJ09:GetPlayingAnimationTracks()
                
                for _, FhSbFoQo in ipairs(TowLInvW) do
                    if not string.find(string.lower(FhSbFoQo.Name or _d("", "7drfQPJr")), _d("D\015\027\008\014 %\029[", "7drfQPJr")) then
                        if QHcaA23Q[FhSbFoQo] then
                            if FhSbFoQo.IsPlaying then
                                pcall(function() FhSbFoQo:Stop(0) FhSbFoQo:AdjustSpeed(0) end)
                            end
                        else
                            if FhSbFoQo.IsPlaying and g2kL4pWR(FhSbFoQo) then
                                task.spawn(function() iV73DhRQ(FhSbFoQo) end)
                            end
                        end
                    end
                end
            end)
        end
        
        local function IpX6b2aD()
            if wOVG0eKQ then wOVG0eKQ:Disconnect() end
            if LHgmlaE6 then LHgmlaE6:Disconnect() end
            if k1DaOd16 then k1DaOd16:Disconnect() end
            if XtDVqDoS then XtDVqDoS:Disconnect() end
        end
        
        -- =========================================================
        -- RESPAWN HANDLER
        -- =========================================================
        
        UX5vXCGH.CharacterAdded:Connect(function(gMA4dHO9)
            task.wait(1.5)
            A7B8Wl9q = gMA4dHO9
            SGXmGJ09 = A7B8Wl9q:WaitForChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
            dm3WAwTP = SGXmGJ09:FindFirstChildOfClass(_d("v\010\027\0110$%\000", "7drfQPJr"))
            if not dm3WAwTP then dm3WAwTP = Instance.new(_d("v\010\027\0110$%\000", "7drfQPJr"), SGXmGJ09) end
            
            QHcaA23Q = {}
            if NRMapbTk and w0HCzvKw then
                task.wait(0.5)
                nzy7L13k(w0HCzvKw)
                xpOULBtE()
            end
        end)
        
        -- =========================================================
        -- UI ELEMENTS (ADAPTED FOR NEXUS UI)
        -- =========================================================
        
        Q54RIC8r:Dropdown({
            Text = _d("d\001\030\0032$j!\\\013\028F\016>#\031V\016\027\009?", "7drfQPJr"),
            Options = evH9eUYs,
            Default = _d("r\007\030\015!#/", "7drfQPJr"),
            Flag = _d("d\015\027\008\016>#\031V\016\027\009?\015\025\023[\001\017\018", "7drfQPJr"),
            Callback = function(LrQXVklA)
                w0HCzvKw = LrQXVklA
                
                if NRMapbTk then
                    local QzH75oi8 = nzy7L13k(LrQXVklA)
                    if QzH75oi8 then
                        VN772YQI:Notify({ 
                            RJ8gM9Bb = _d("v\010\027\0110$#\029YD1\0140>-\023S", "7drfQPJr"), 
                            Content = _d("d\015\027\008kp", "7drfQPJr") .. LrQXVklA, 
                            Type = _d("d\017\017\0054#9", "7drfQPJr")
                        })
                    end
                end
            end
        })
        
        Q54RIC8r:Toggle({
            Text = _d("r\010\019\004=5j3Y\013\031\007%9%\028\023\'\026\007?7/\000", "7drfQPJr"),
            Default = false,
            Flag = _d("r\010\019\004=5\011\028^\009\019\0188?$1_\005\028\0014\"", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                NRMapbTk = Z2mTETLK
                
                if NRMapbTk then
                    if not w0HCzvKw then
                        VN772YQI:Notify({ RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\0032$j\019\023\023\025\015?p,\027E\023\006G", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr") })
                        NRMapbTk = false
                        return
                    end
                    
                    local QzH75oi8 = nzy7L13k(w0HCzvKw)
                    if QzH75oi8 then
                        xpOULBtE()
                        --Nexus:Notify({ Title = "Animation", Content = "Enabled", Type = "Success" })
                    else
                        NRMapbTk = false
                        --Nexus:Notify({ Title = "Error", Content = "Failed to load anim", Type = "Error" })
                    end
                else
                    IpX6b2aD()
                    QHcaA23Q = {}
                    --Nexus:Notify({ Title = "Animation", Content = "Disabled", Type = "Warning" })
                end
            end
        })
    end

    -- =========================================================
    -- FISHING SUPPORT (TOOLS)
    -- =========================================================
    do
        local ijU50fuF = j9HhL1d2:Collapsible(_d("q\013\001\0148>-Rd\017\002\022>\">R\0310\029\009=#c", "7drfQPJr"))
        
        -- Helper Variables
        local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
        local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
        local LocalPlayer = Players.LocalPlayer
        
        -- 1. REMOVE FISH NOTIFICATION POP-UP
        local _mQbVfh4 = nil
        ijU50fuF:Toggle({
            Text = _d("e\001\031\009\'5j4^\023\026F\031?>\027Q\013\017\007%9%\028\0234\029\022|%:", "7drfQPJr"),
            Default = false,
            Flag = _d("e\001\031\009\'5\012\027D\012<\009%9,\027T\005\006\015>>9", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                local qFuouMMH = LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
                local fBF_c7DW = qFuouMMH:FindFirstChild(_d("d\009\019\010=p\004\029C\013\020\01521>\027X\010", "7drfQPJr"))
                
                -- Coba tunggu sebentar jika belum ada
                if not fBF_c7DW then
                    fBF_c7DW = qFuouMMH:WaitForChild(_d("d\009\019\010=p\004\029C\013\020\01521>\027X\010", "7drfQPJr"), 5)
                end
                
                if not fBF_c7DW then return end

                if Z2mTETLK then
                    -- ON: Gunakan RenderStepped agar notifikasi mati setiap frame
                    if _mQbVfh4 then _mQbVfh4:Disconnect() end
                    
                    _mQbVfh4 = bqYp_xry.RenderStepped:Connect(function()
                        if fBF_c7DW then
                            fBF_c7DW.Enabled = false
                        end
                    end)
                    VN772YQI:Notify({RJ8gM9Bb = _d("y\011\006\01579)\019C\013\029\008", "7drfQPJr"), Content = _d("g\011\002K$ j0[\011\017\01344", "7drfQPJr")})
                else
                    -- OFF: Matikan loop dan nyalakan kembali GUI
                    if _mQbVfh4 then
                        _mQbVfh4:Disconnect()
                        _mQbVfh4 = nil
                    end
                    if fBF_c7DW then
                        fBF_c7DW.Enabled = true
                    end
                    VN772YQI:Notify({RJ8gM9Bb = _d("y\011\006\01579)\019C\013\029\008", "7drfQPJr"), Content = _d("g\011\002K$ j R\023\006\009#5.", "7drfQPJr")})
                end
            end
        })

        -- 2. WALK ON WATER
        local czELvKzH = nil
        local G3Hiq3Dy = false
        local G_4T9SHq = nil
        
        ijU50fuF:Toggle({
            Text = _d("`\005\030\013q?$R`\005\006\003#", "7drfQPJr"),
            Default = false,
            Flag = _d("`\005\030\013\030>\029\019C\001\000", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                G3Hiq3Dy = Z2mTETLK

                if Z2mTETLK then
                    -- Buat Platform Awal
                    if not G_4T9SHq then
                        G_4T9SHq = Instance.new(_d("g\005\000\018", "7drfQPJr"))
                        G_4T9SHq.Name = _d("`\005\006\003#\000&\019C\002\029\020<", "7drfQPJr")
                        G_4T9SHq.Anchored = true
                        G_4T9SHq.CanCollide = true
                        G_4T9SHq.Transparency = 1 
                        G_4T9SHq.Size = Vector3.new(20, 1, 20)
                        G_4T9SHq.Parent = workspace
                    end

                    if czELvKzH then czELvKzH:Disconnect() end

                    czELvKzH = bqYp_xry.RenderStepped:Connect(function()
                        local pwiayaWC = LocalPlayer.Character
                        if not G3Hiq3Dy or not pwiayaWC then return end
                        
                        local MXhl6X0h = pwiayaWC:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
                        if not MXhl6X0h then return end

                        -- Re-create jika terhapus
                        if not G_4T9SHq or not G_4T9SHq.Parent then
                            G_4T9SHq = Instance.new(_d("g\005\000\018", "7drfQPJr"))
                            G_4T9SHq.Name = _d("`\005\006\003#\000&\019C\002\029\020<", "7drfQPJr")
                            G_4T9SHq.Anchored = true
                            G_4T9SHq.CanCollide = true
                            G_4T9SHq.Transparency = 1 
                            G_4T9SHq.Size = Vector3.new(20, 1, 20)
                            G_4T9SHq.Parent = workspace
                        end

                        -- Raycast cari air
                        local jgD1JjGB = RaycastParams.new()
                        jgD1JjGB.FilterDescendantsInstances = {workspace.Terrain} 
                        jgD1JjGB.FilterType = Enum.RaycastFilterType.Include
                        jgD1JjGB.IgnoreWater = false 

                        local L52wRdrg = MXhl6X0h.Position + Vector3.new(0, 5, 0) 
                        local qo0w_fcj = Vector3.new(0, -500, 0)
                        local tYBp8S9Z = workspace:Raycast(L52wRdrg, qo0w_fcj, jgD1JjGB)

                        if tYBp8S9Z and tYBp8S9Z.Material == Enum.Material.Water then
                            local ud5fgpGq = tYBp8S9Z.Position.Y
                            G_4T9SHq.Position = Vector3.new(MXhl6X0h.Position.X, ud5fgpGq, MXhl6X0h.Position.Z)
                            
                            -- Fitur lompat otomatis jika tenggelam
                            if MXhl6X0h.Position.Y < (ud5fgpGq + 2) and MXhl6X0h.Position.Y > (ud5fgpGq - 5) then
                                 if not game:GetService(_d("b\023\023\020\024>:\007C7\023\020\'9)\023", "7drfQPJr")):IsKeyDown(Enum.KeyCode.Space) then
                                    MXhl6X0h.CFrame = CFrame.new(MXhl6X0h.Position.X, ud5fgpGq + 3.5, MXhl6X0h.Position.Z)
                                end
                            end
                        else
                            -- Sembunyikan platform jika di darat
                            G_4T9SHq.Position = Vector3.new(MXhl6X0h.Position.X, -500, MXhl6X0h.Position.Z)
                        end
                    end)
                    --Nexus:Notify({Title = "Walk on Water", Content = "Enabled"})
                else
                    -- Cleanup
                    if czELvKzH then czELvKzH:Disconnect() czELvKzH = nil end
                    if G_4T9SHq then G_4T9SHq:Destroy() G_4T9SHq = nil end
                    --Nexus:Notify({Title = "Walk on Water", Content = "Disabled"})
                end
            end
        })

        -- 3. ENABLE FISHING RADAR
        -- Pastikan variabel GetRemote dan RPath sudah ada di global scope script Anda
        ijU50fuF:Toggle({
            Text = _d("r\010\019\004=5j4^\023\026\015?7j V\000\019\020", "7drfQPJr"),
            Default = false,
            Flag = _d("Q\013\001\0148>- V\000\019\020", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                local q63r5sS_ = F6mQZlUf.UpdateFishingRadar -- Menggunakan table Remotes yang sudah ada
                if not q63r5sS_ then
                    -- Fallback cari manual jika tidak ada di table Remotes
                    q63r5sS_ = XtEpjbKg(luxCjQ_B, _d("e\"]3!4+\006R\"\027\02199$\021e\005\022\007#", "7drfQPJr"))
                end
                
                if q63r5sS_ then
                    pcall(function() q63r5sS_:InvokeServer(Z2mTETLK) end)
                    VN772YQI:Notify({RJ8gM9Bb = _d("e\005\022\007#", "7drfQPJr"), Content = Z2mTETLK and _d("x*", "7drfQPJr") or _d("x\"4", "7drfQPJr")})
                end
            end
        })

        -- =========================================================
        -- 4. REMOVE EFFECTS (VFX & FPS BOOST)
        -- =========================================================
        
        -- [A] SETUP VARIABLES & MODULES
        local Ln6NtJ4c = nil
        local ZN5yGwFV = nil
        local yNoXD_nj = false
        local aFqxI01d = false
        local s4yHlFEV = {} -- Untuk menyimpan koneksi dummy

        -- Load Modules Game
        pcall(function()
            Ln6NtJ4c = require(game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr")):WaitForChild(_d("t\011\028\018#?&\030R\022\001", "7drfQPJr")).VFXController)
            if Ln6NtJ4c then
                ZN5yGwFV = Ln6NtJ4c.Handle
            end
        end)

        -- Load Remotes (Untuk fitur Event Disabler)
        local Hc1rExjM = XtEpjbKg(luxCjQ_B, _d("e!]6=134^\023\026\015?7\015\020Q\001\017\018", "7drfQPJr"))
        local FlRSjb0E = XtEpjbKg(luxCjQ_B, _d("e!]44 &\027T\005\006\003\00552\006r\002\020\0032$", "7drfQPJr"))

        -- [B] UI IMPLEMENTATION
        local yTzeCrwx = ijU50fuF:Collapsible(_d("a\"*Fwp\012\"dD0\009>#>", "7drfQPJr"))

        -- 1. REMOVE SKIN EFFECT (Metode Hook Controller - Kode Lama)
        yTzeCrwx:Toggle({
            Text = _d("e\001\031\009\'5j!\\\013\028F\0206,\023T\016RN\0021,\023\030", "7drfQPJr"),
            Default = false,
            Flag = _d("e\001\031\009\'59\025^\0107\00075)\006", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                if not Ln6NtJ4c then return end
                
                if Z2mTETLK then
                    -- Blokir fungsi rendering visual
                    Ln6NtJ4c.Handle = function(...) end
                    Ln6NtJ4c.RenderAtPoint = function(...) end
                    Ln6NtJ4c.RenderInstance = function(...) end
                    
                    -- Bersihkan folder kosmetik sekali jalan
                    local XgsVTlcO = workspace:FindFirstChild(_d("t\011\001\0114$#\017q\011\030\0024\"", "7drfQPJr"))
                    if XgsVTlcO then pcall(function() XgsVTlcO:ClearAllChildren() end) end
                else
                    -- Restore fungsi asli
                    if ZN5yGwFV then
                        Ln6NtJ4c.Handle = ZN5yGwFV
                    end
                end
            end
        })

        -- 2. DISABLE CHAR EFFECT (Metode Disconnect Event - Kode Baru)
        yTzeCrwx:Toggle({
            Text = _d("s\013\001\0073</Rt\012\019\020~\004/\010CD7\00075)\006\023L3\0016\"/\001D\013\004\003x", "7drfQPJr"),
            Default = false,
            Callback = function(Z2mTETLK)
                aFqxI01d = Z2mTETLK
                
                -- Cek support executor
                if not getconnections then 
                    VN772YQI:Notify({RJ8gM9Bb=_d("r\022\000\009#", "7drfQPJr"), Content=_d("r\028\023\005$$%\000\023\016\027\0020;j\001B\020\002\009#$jUP\001\006\005>>$\023T\016\027\009?#m", "7drfQPJr"), Type=_d("r\022\000\009#", "7drfQPJr")}) 
                    return 
                end

                local Events = {Hc1rExjM, FlRSjb0E}

                if Z2mTETLK then
                    -- [LOGIC MATIKAN EFEK]
                    s4yHlFEV = {} -- Reset simpanan
                    
                    for _, b8M9pGQL in ipairs(Events) do
                        if b8M9pGQL then
                            -- 1. Matikan koneksi asli game (Disable)
                            for _, conn in ipairs(getconnections(b8M9pGQL.OnClientEvent)) do
                                conn:Disable() -- Kita pakai Disable() biar bisa dinyalakan lagi (lebih aman dari Disconnect)
                            end
                            
                            -- 2. Tambahkan dummy connection (sesuai request kode, untuk mencegah error nil)
                            local mb6X9B6d = b8M9pGQL.OnClientEvent:Connect(function() end)
                            table.insert(s4yHlFEV, mb6X9B6d)
                        end
                    end
                    VN772YQI:Notify({RJ8gM9Bb=_d("q4!F\019?%\001C", "7drfQPJr"), Content=_d("t\012\019\02003>\023EDTF\00552\006\023!\020\00043>\001\023 \027\02102&\023SE", "7drfQPJr"), Type=_d("d\017\017\0054#9", "7drfQPJr")})
                else
                    -- [LOGIC NYALAKAN KEMBALI]
                    -- 1. Hapus dummy connection kita
                    for _, conn in ipairs(s4yHlFEV) do
                        if conn then conn:Disconnect() end
                    end
                    s4yHlFEV = {}

                    -- 2. Hidupkan kembali koneksi asli game
                    for _, b8M9pGQL in ipairs(Events) do
                        if b8M9pGQL then
                            for _, conn in ipairs(getconnections(b8M9pGQL.OnClientEvent)) do
                                conn:Enable()
                            end
                        end
                    end
                    VN772YQI:Notify({RJ8gM9Bb=_d("q4!F\019?%\001C", "7drfQPJr"), Content=_d("r\002\020\0032$9Re\001\001\018>\"/\022\025", "7drfQPJr"), Type=_d("~\010\020\009", "7drfQPJr")})
                end
            end
        })

        -- 3. DELETE FISHING EFFECTS (Metode Loop Destroy - Kode Baru)
        yTzeCrwx:Toggle({
            Text = _d("s\001\030\003%5j X\000R#76/\017C\023RN\029?%\002\030", "7drfQPJr"),
            Default = false,
            Callback = function(Z2mTETLK)
                yNoXD_nj = Z2mTETLK
                
                if Z2mTETLK then
                    task.spawn(function()
                        while yNoXD_nj do
                            local hi74H3XJ = workspace:FindFirstChild(_d("t\011\001\0114$#\017q\011\030\0024\"", "7drfQPJr"))
                            if hi74H3XJ then
                                hi74H3XJ:Destroy() -- Hapus folder efek
                            end
                            -- Saya percepat dari 60s ke 5s agar efeknya terasa instan
                            task.wait(5) 
                        end
                    end)
                    VN772YQI:Notify({RJ8gM9Bb=_d("t\008\023\007?58", "7drfQPJr"), Content=_d("v\017\006\009q\020/\030R\016\023F\018?9\031R\016\027\005q\017)\006^\018\023", "7drfQPJr"), Type=_d("d\017\017\0054#9", "7drfQPJr")})
                end
            end
        })

        -- =========================================================
        -- 5. NO CUTSCENE (ULTIMATE: UI RESTORE + SERVER BYPASS)
        -- =========================================================
        local X8QfnJ1S = nil
        local Es4fxR8T = nil
        local TJ7z8Xyr = nil
        local PMARWH94 = false
        
        local XurwYfCA = game:GetService(_d("g\022\029\0308=#\006N4\000\009< >!R\022\004\01525", "7drfQPJr"))
        local LocalPlayer = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer
        
        -- [NEW] Define Remotes
        -- Asumsi RPath sudah didefinisikan di atas (Packages -> _Index -> net)
        local FnPxM_N4 = XtEpjbKg(luxCjQ_B, _d("e!]5%?:1B\016\001\0054>/", "7drfQPJr"))
        -- RE/ReplicateCutscene tidak perlu di-hook jika kita sudah mematikan Controllernya langsung,
        -- tapi kita definisikan saja biar lengkap sesuai request.
        local sfhJyRbq = XtEpjbKg(luxCjQ_B, _d("e!]44 &\027T\005\006\003\018%>\001T\001\028\003", "7drfQPJr")) 

        task.spawn(function()
            local ReplicatedStorage = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
            
            -- 1. Load Game Modules
            pcall(function()
                X8QfnJ1S = require(ReplicatedStorage:WaitForChild(_d("t\011\028\018#?&\030R\022\001", "7drfQPJr")):WaitForChild(_d("t\017\006\02125$\023t\011\028\018#?&\030R\022", "7drfQPJr")))
                Es4fxR8T = require(ReplicatedStorage:WaitForChild(_d("z\011\022\019=59", "7drfQPJr")):WaitForChild(_d("p\017\027%>>>\000X\008", "7drfQPJr")))
            end)

            -- 2. Hook Controller
            if X8QfnJ1S and X8QfnJ1S.Play then
                if not X8QfnJ1S._OriginalPlay then
                    X8QfnJ1S._OriginalPlay = X8QfnJ1S.Play
                end
                TJ7z8Xyr = X8QfnJ1S._OriginalPlay

                -- Overwrite Play Function
                X8QfnJ1S.Play = function(M4E52Mdv, ...)
                    if PMARWH94 then
                        -- [A] Skip Animasi Client (Logic Lama)
                        task.spawn(function()
                            task.wait() 
                            
                            -- Restore UI & Controls
                            if Es4fxR8T then Es4fxR8T:SetHUDVisibility(true) end
                            if XurwYfCA then XurwYfCA.Enabled = true end
                            if LocalPlayer then LocalPlayer:SetAttribute(_d("~\003\028\009#5\012=a", "7drfQPJr"), false) end
                        end)

                        -- [B] Beritahu Server "Cutscene Selesai" (Logic Baru)
                        -- Ini mencegah delay quest/hadiah dari server
                        if FnPxM_N4 then
                            pcall(function() FnPxM_N4:FireServer() end)
                        end

                        return -- Stop eksekusi cutscene
                    end
                    
                    return TJ7z8Xyr(M4E52Mdv, ...)
                end
            end
        end)

        ijU50fuF:Toggle({
            Text = _d("y\011R%$$9\017R\010\023Fy\003!\027GDTF\019):\019D\023[", "7drfQPJr"),
            Default = false,
            Flag = _d("y\0111\019%#)\023Y\0013\017&", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                PMARWH94 = Z2mTETLK
                
                if Z2mTETLK then
                    -- Jika dinyalakan saat cutscene jalan
                    if X8QfnJ1S then
                        pcall(function() X8QfnJ1S:Stop() end)
                        -- Manual Restore
                        if Es4fxR8T then Es4fxR8T:SetHUDVisibility(true) end
                        XurwYfCA.Enabled = true
                        
                        -- Paksa Stop ke Server juga
                        if FnPxM_N4 then pcall(function() FnPxM_N4:FireServer() end) end
                    end
                    VN772YQI:Notify({RJ8gM9Bb = _d("t\017\006\02125$\023", "7drfQPJr"), Content = _d("v\017\006\009q\003!\027GDYF\00258\004R\022R$( +\001DD3\005%9<\023\022", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
                else
                    VN772YQI:Notify({RJ8gM9Bb = _d("t\017\006\02125$\023", "7drfQPJr"), Content = _d("s\013\001\0073</\022", "7drfQPJr"), Type = _d("~\010\020\009", "7drfQPJr")})
                end
            end
        })

        -- 6. NO ANIMATION
        -- Pastikan fungsi DisableAnimations dan EnableAnimations sudah ada di script Anda (di bagian helper)
        ijU50fuF:Toggle({
            Text = _d("y\011R\'?9\'\019C\013\029\008", "7drfQPJr"),
            Default = false,
            Flag = _d("Y\011\019\0088=+\006^\011\02897<+\021", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                if Z2mTETLK then
                    if FI3bGmiJ then FI3bGmiJ() end
                else
                    if Lk1HLKg7 then Lk1HLKg7() end
                    VN772YQI:Notify({RJ8gM9Bb = _d("v\010\027\0110$#\029Y", "7drfQPJr"), Content = _d("e\001\001\018>\"/\022", "7drfQPJr")})
                end
            end
        })
    end

    do
        local eLEDsjj2 = j9HhL1d2:Collapsible(_d("c\001\030\003!?8\006\0237\011\021%5\'", "7drfQPJr"))
        
        -- Helper Functions Local
        local function gCREpHe_()
            local PcEFQxK7 = game.Players.LocalPlayer.Character
            return PcEFQxK7 and PcEFQxK7:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
        end

        local function Rpz4CNzY(DsM2nBnr, look)
            local MXhl6X0h = gCREpHe_()
            if MXhl6X0h then
                MXhl6X0h.CFrame = CFrame.new(DsM2nBnr, DsM2nBnr + look)
            end
        end

        -- =========================================================
        -- 1. TELEPORT TO FISHING AREA
        -- =========================================================
        
        local FzhBWPwG = {
            [_d("v\010\017\0154>>R}\017\028\001=5", "7drfQPJr")] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
            [_d("v\022\000\009&p\006\023A\001\000", "7drfQPJr")] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, -0.000, 1.000)},
            [_d("t\011\000\007=p\024\023R\002", "7drfQPJr")] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
            [_d("t\022\019\0184\"j;D\008\019\0085", "7drfQPJr")] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0.000, 0.615)},
            [_d("t\022\023\0214>>R{\001\004\003#", "7drfQPJr")] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0.000, -0.000, -1.000)},
            [_d("t\022\011\021%1&\030^\010\023F\00119\001V\003\023", "7drfQPJr")] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0.000, 0.994)},
            [_d("v\010\017\0154>>Re\017\027\008", "7drfQPJr")] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, -0.000, -0.949)},
            [_d("s\013\019\011>>.R{\001\004\003#", "7drfQPJr")] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0.000, 0.000, -1.000)},
            [_d("r\010\017\0140>>Re\011\029\011", "7drfQPJr")] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("r\023\029\0184\"#\017\023-\001\0100>.", "7drfQPJr")] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("q\013\001\0144\"\'\019YD;\021=1$\022", "7drfQPJr")] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("\127\011\007\0206<+\001DD6\0150=%\028SD>\003\'58", "7drfQPJr")] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("|\011\026\007?1", "7drfQPJr")] = {Pos = Vector3.new(-855.801, 18.75, 465.677), Look = Vector3.new(-0.695, 0, -0.719)},
            [_d("{\011\001\018q\0259\030R", "7drfQPJr")] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, -0.000, 0.433)},
            [_d("d\005\017\02044j&R\009\002\0104", "7drfQPJr")] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, -0.000, 0.143)},
            [_d("d\001\017\009?4j7Y\007\026\007?$j3[\016\019\020", "7drfQPJr")] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0.000, -0.955)},
            [_d("d\013\001\031!8?\001\0237\006\007%%/", "7drfQPJr")] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0.000, 0.951)},
            [_d("c\022\023\007\"%8\023\0236\029\009<", "7drfQPJr")] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0.000, -0.998)},
            [_d("c\022\029\02283+\030\023-\001\0100>.", "7drfQPJr")] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
            [_d("b\010\022\003#78\029B\010\022F\0185&\030V\022", "7drfQPJr")] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0.000, 0.521)},
            [_d("a\011\030\0050>%", "7drfQPJr")] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
            [_d("`\001\019\018958Rz\005\017\0148>/", "7drfQPJr")] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0.000, 0.999)},
            [_d("g\013\000\007%5j1X\018\023", "7drfQPJr")] = {Pos = Vector3.new(3413.68, 4.193, 3505.495), Look = Vector3.new(0.644, 0, -0.765)},
        }
        
        local k91OGDvB = {}
        for name, _ in pairs(FzhBWPwG) do table.insert(k91OGDvB, name) end
        table.sort(k91OGDvB) -- Urutkan abjad biar rapi
        
        local ZARx7FPB = nil

        eLEDsjj2:Dropdown({
            Text = _d("t\012\029\009\"5j3E\001\019", "7drfQPJr"), 
            Options = k91OGDvB, 
            Default = _d("d\001\030\0032$j3E\001\019", "7drfQPJr"),
            Flag = _d("D\001\030\0032$\021\019E\001\0199%5&\023G\011\000\018\0146&\019P;C", "7drfQPJr"),
            Callback = function(_oFeDtVE) VN772YQI.Flags.select_area_teleport_flag_1 = _oFeDtVE end
        })

        eLEDsjj2:Button({
            Text = _d("c\001\030\003!?8\006\023\016\029F\0188%\001R\010R\'#5+", "7drfQPJr"),
            Callback = function()
                local iKzvh6mn = VN772YQI.Flags.select_area_teleport_flag_1

                if iKzvh6mn and FzhBWPwG[iKzvh6mn] then
                    local data = FzhBWPwG[iKzvh6mn]
                    Rpz4CNzY(data.Pos, data.Look)
                    VN772YQI:Notify({
                        RJ8gM9Bb = _d("c\001\030\003!?8\006", "7drfQPJr"),
                        Content = _d("v\022\000\015\'5.RV\016R", "7drfQPJr") .. iKzvh6mn,
                        Type = _d("d\017\017\0054#9", "7drfQPJr")
                    })
                else
                    VN772YQI:Notify({
                        RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"),
                        Content = _d("d\001\030\0032$j\019YD\019\02041j\020^\022\001\018p", "7drfQPJr"),
                        Type = _d("r\022\000\009#", "7drfQPJr")
                    })
                end
            end
        })
        
        eLEDsjj2:Toggle({
            Text = _d("c\001\030\003!?8\006\023BR #5/\008RDZ 8(j>V\003[", "7drfQPJr"),
            Default = false,
            Flag = _d("C\001\030\003!?8\006h\002\000\0034*/-Q\008\019\001\014a", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                local MXhl6X0h = gCREpHe_()
                if not MXhl6X0h then return end

                local iKzvh6mn = VN772YQI.Flags.select_area_teleport_flag_1
                if Z2mTETLK then
                    if not iKzvh6mn or not FzhBWPwG[iKzvh6mn] then
                        VN772YQI:Notify({
                            RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"),
                            Content = _d("d\001\030\0032$j\019E\001\019F798\001CE", "7drfQPJr"),
                            Type = _d("r\022\000\009#", "7drfQPJr")
                        })
                        return
                    end

                    local data = FzhBWPwG[iKzvh6mn]
                    MXhl6X0h.Anchored = false
                    Rpz4CNzY(data.Pos, data.Look)

                    local Md_RPwqi = os.clock()
                    while (os.clock() - Md_RPwqi) < 1.5 and Z2mTETLK do
                        MXhl6X0h.Velocity = Vector3.zero
                        MXhl6X0h.CFrame = CFrame.new(data.Pos, data.Pos + data.Look)
                        game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr")).Heartbeat:Wait()
                    end

                    if Z2mTETLK then MXhl6X0h.Anchored = true end
                else
                    MXhl6X0h.Anchored = false
                end
            end
        })

        local VBI1U9W3 = nil 
        local d3Fuvwvc = nil

        -- Helper: Mengambil daftar pemain
        local function lZbfSZcV()
            local rGerDugg = {}
            for _, x6Sluij5 in ipairs(game.Players:GetPlayers()) do
                if x6Sluij5 ~= game.Players.LocalPlayer then
                    table.insert(rGerDugg, x6Sluij5.Name)
                end
            end
            if #rGerDugg == 0 then table.insert(rGerDugg, _d("y\011R6=13\023E\023R >%$\022", "7drfQPJr")) end
            return rGerDugg
        end

        -- Dropdown Pemain
        d3Fuvwvc = eLEDsjj2:Dropdown({
            Text = _d("d\001\030\0032$j&V\022\021\003%p\026\030V\029\023\020", "7drfQPJr"),
            Options = lZbfSZcV(),
            Default = _d("d\001\030\0032$j\"[\005\011\003#", "7drfQPJr"),
            Callback = function(name)
                VBI1U9W3 = name
            end
        })

        -- Tombol Refresh
        eLEDsjj2:Button({
            Text = _d("e\001\020\0204#\"Rg\008\019\0314\"j>^\023\006", "7drfQPJr"),
            Callback = function()
                local _Zjd8XxD = lZbfSZcV()
                if d3Fuvwvc then
                    d3Fuvwvc:SetOptions(_Zjd8XxD)
                end
                VBI1U9W3 = nil
                VN772YQI:Notify({ RJ8gM9Bb = _d("e\001\020\0204#\"", "7drfQPJr"), Content = _d("{\013\001\018q\005:\022V\016\023\002", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr") })
            end
        })

        -- Tombol Teleport
        eLEDsjj2:Button({
            Text = _d("c\001\030\003!?8\006\023\016\029F\001<+\011R\022RN\030>/_c\013\031\003x", "7drfQPJr"),
            Callback = function()
                if not VBI1U9W3 or VBI1U9W3 == _d("y\011R6=13\023E\023R >%$\022", "7drfQPJr") then
                    VN772YQI:Notify({ RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\0032$j\019\023\018\019\01084j\002[\005\011\003#q", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr") })
                    return
                end

                local LdfVydGS = game.Players:FindFirstChild(VBI1U9W3)
                local cgWoLY8O = LdfVydGS and LdfVydGS.Character and LdfVydGS.Character:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
                local QjZA_r4j = gCREpHe_()

                if QjZA_r4j and cgWoLY8O then
                    -- Teleport 5 stud di atas kepala
                    local qBFp4YeG = cgWoLY8O.Position + Vector3.new(0, 5, 0)
                    local Qm3opr3u = (cgWoLY8O.Position - QjZA_r4j.Position).Unit 
                    
                    QjZA_r4j.CFrame = CFrame.new(qBFp4YeG, qBFp4YeG + Qm3opr3u)
                    
                    VN772YQI:Notify({ RJ8gM9Bb = _d("c\001\030\003!?8\006", "7drfQPJr"), Content = _d("c\001\030\003!?8\006R\000R\018>p", "7drfQPJr") .. VBI1U9W3, Type = _d("d\017\017\0054#9", "7drfQPJr") })
                else
                    VN772YQI:Notify({ RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("c\005\000\0014$e1_\005\000\0072$/\000\023\010\029\018q6%\007Y\000", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr") })
                end
            end
        })
    end

    -- =========================================================
    -- SMART EVENT (MULTI PROPS)
    -- =========================================================
    do
        local laBR_mj9 = j9HhL1d2:Collapsible(_d("d\009\019\020%p\015\004R\010\006Fy\029?\030C\013R6#?:\001\030", "7drfQPJr"))

        -- =========================================================
        -- FISHING AREAS
        -- =========================================================
        local UqzQ_Tsi = {
            [_d("v\010\017\0154>>R}\017\028\001=5", "7drfQPJr")] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
            [_d("v\022\000\009&p\006\023A\001\000", "7drfQPJr")] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, -0.000, 1.000)},
            [_d("t\011\000\007=p\024\023R\002", "7drfQPJr")] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
            [_d("t\022\019\0184\"j;D\008\019\0085", "7drfQPJr")] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0.000, 0.615)},
            [_d("t\022\023\0214>>R{\001\004\003#", "7drfQPJr")] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0.000, -0.000, -1.000)},
            [_d("t\022\011\021%1&\030^\010\023F\00119\001V\003\023", "7drfQPJr")] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0.000, 0.994)},
            [_d("v\010\017\0154>>Re\017\027\008", "7drfQPJr")] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, -0.000, -0.949)},
            [_d("s\013\019\011>>.R{\001\004\003#", "7drfQPJr")] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0.000, 0.000, -1.000)},
            [_d("r\010\017\0140>>Re\011\029\011", "7drfQPJr")] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("r\023\029\0184\"#\017\023-\001\0100>.", "7drfQPJr")] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("q\013\001\0144\"\'\019YD;\021=1$\022", "7drfQPJr")] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("\127\011\007\0206<+\001DD6\0150=%\028SD>\003\'58", "7drfQPJr")] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(-0.000, -0.000, -1.000)},
            [_d("|\011\026\007?1", "7drfQPJr")] = {Pos = Vector3.new(-855.801, 18.75, 465.677), Look = Vector3.new(-0.695, 0, -0.719)},
            [_d("{\011\001\018q\0259\030R", "7drfQPJr")] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, -0.000, 0.433)},
            [_d("d\005\017\02044j&R\009\002\0104", "7drfQPJr")] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, -0.000, 0.143)},
            [_d("d\001\017\009?4j7Y\007\026\007?$j3[\016\019\020", "7drfQPJr")] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0.000, -0.955)},
            [_d("d\013\001\031!8?\001\0237\006\007%%/", "7drfQPJr")] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0.000, 0.951)},
            [_d("c\022\023\007\"%8\023\0236\029\009<", "7drfQPJr")] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0.000, -0.998)},
            [_d("c\022\029\02283+\030\023-\001\0100>.", "7drfQPJr")] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
            [_d("b\010\022\003#78\029B\010\022F\0185&\030V\022", "7drfQPJr")] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0.000, 0.521)},
            [_d("a\011\030\0050>%", "7drfQPJr")] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
            [_d("`\001\019\018958Rz\005\017\0148>/", "7drfQPJr")] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0.000, 0.999)},
            [_d("g\013\000\007%5j1X\018\023", "7drfQPJr")] = {Pos = Vector3.new(3413.68, 4.193, 3505.495), Look = Vector3.new(0.644, 0, -0.765)},
        }
        
        local aXNFhzSY = {}
        for name, _ in pairs(UqzQ_Tsi) do table.insert(aXNFhzSY, name) end
        table.sort(aXNFhzSY)

        -- Pastikan eventsList ada
        local sHlNULOn = sHlNULOn or {
            _d("d\012\019\020:p\002\007Y\016", "7drfQPJr"), _d("z\001\021\007=?.\029YD:\019?$", "7drfQPJr"), _d("`\011\000\011q\024?\028C", "7drfQPJr"), _d("p\012\029\021%p\025\026V\022\025F\025%$\006", "7drfQPJr"), _d("c\022\023\007\"%8\023\023!\004\003?$", "7drfQPJr"), _d("u\008\019\005:p\002\029[\001", "7drfQPJr")
        }

        -- =========================================================
        -- VARIABLES
        -- =========================================================
        local u6HtiEIb = nil
        local ArGJLsWe = {}
        local HLpDXHHF = nil 
        local xd1seql6 = false
        local bO4jsgzL = nil

        -- =========================================================
        -- EVENT SEARCH PATTERNS
        -- =========================================================
        local VtIW5con = {
            [_d("d\012\019\020:p\002\007Y\016", "7drfQPJr")] = {_d("d\012\019\020:p\002\007Y\016", "7drfQPJr")},
            [_d("z\001\021\007=?.\029YD:\019?$", "7drfQPJr")] = {_d("z\001\021\007=?.\029YD:\019?$", "7drfQPJr")}, 
            [_d("`\011\000\011q\024?\028C", "7drfQPJr")] = {_d("u\008\019\005:\024%\030R", "7drfQPJr"), _d("z\011\022\003=", "7drfQPJr")}, 
            [_d("p\012\029\021%p\025\026V\022\025F\025%$\006", "7drfQPJr")] = {_d("p\012\029\021%p\025\026V\022\025F\025%$\006", "7drfQPJr"), _d("p\012\029\021%", "7drfQPJr")},
            [_d("c\022\023\007\"%8\023\023!\004\003?$", "7drfQPJr")] = {_d("c\022\023\007\"%8\023\023!\004\003?$", "7drfQPJr")},
            [_d("u\008\019\005:p\002\029[\001", "7drfQPJr")] = {_d("u\008\019\005:p\002\029[\001", "7drfQPJr")}
        }

        local function XcLmG2qi(obj)
            if not obj then return false end
            local QzH75oi8 = pcall(function()
                return obj.Parent ~= nil and obj:IsDescendantOf(workspace)
            end)
            return QzH75oi8
        end

        local function YVs57bLQ(Tldq9CSH)
            local rNyyX3Xd = VtIW5con[Tldq9CSH]
            if not rNyyX3Xd then return false, nil, nil end
            
            local tBpbOwoc = {}
            for _, NxjuG33N in ipairs(workspace:GetChildren()) do
                if NxjuG33N.Name == _d("g\022\029\022\"", "7drfQPJr") and NxjuG33N:IsA(_d("z\011\022\003=", "7drfQPJr")) then
                    table.insert(tBpbOwoc, NxjuG33N)
                end
            end
            
            for _, props in ipairs(tBpbOwoc) do
                for _, pattern in ipairs(rNyyX3Xd) do
                    for _, NxjuG33N in ipairs(props:GetChildren()) do
                        if NxjuG33N.Name == pattern and XcLmG2qi(NxjuG33N) then
                            local position = nil
                            if NxjuG33N:IsA(_d("z\011\022\003=", "7drfQPJr")) then
                                if NxjuG33N.PrimaryPart then position = NxjuG33N.PrimaryPart.Position
                                else local llRb7tDU, size = NxjuG33N:GetBoundingBox(); position = llRb7tDU.Position end
                            elseif NxjuG33N:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then
                                position = NxjuG33N.Position
                            end
                            
                            if position then return true, position, NxjuG33N end
                        end
                    end
                end
            end

            if Tldq9CSH == _d("{\011\017\014?59\001\023,\007\008%", "7drfQPJr") then
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name:find(_d("y\001\001\02185", "7drfQPJr")) or obj.Name:find(_d("{\011\017\014?59\001", "7drfQPJr")) then
                        return true, obj:GetPivot().Position, obj
                    end
                end
            end
            return false, nil, nil
        end

        local function gmyGZjdW()
            
        end

        local rG4vd4Gj = {
            events = {}, lastFullScan = 0, scanInterval = 60
        }

        function rG4vd4Gj:GetAll() return M4E52Mdv.events or {} end
        
        function rG4vd4Gj:Add(Tldq9CSH, position, model)
            if not M4E52Mdv.events then M4E52Mdv.events = {} end
            M4E52Mdv.events[Tldq9CSH] = {
                position = position, model = model, foundAt = tick(),
                lastVisit = 0, visitCount = 0
            }
        end

        function rG4vd4Gj:Clear() M4E52Mdv.events = {} end

        function rG4vd4Gj:IsEventStillActive(Tldq9CSH)
            if not M4E52Mdv.events or not M4E52Mdv.events[Tldq9CSH] then return false end
            local QzH75oi8, stillExists = pcall(function()
                local _QpC4X59, DsM2nBnr, obj = YVs57bLQ(Tldq9CSH)
                return _QpC4X59 and obj and XcLmG2qi(obj)
            end)
            if not QzH75oi8 or not stillExists then
                M4E52Mdv.events[Tldq9CSH] = nil
                return false
            end
            return true
        end

        function rG4vd4Gj:ShouldScan()
            local VvuLzOP8 = tick() - M4E52Mdv.lastFullScan
            local Y0OVrLT0 = next(M4E52Mdv.events or {}) == nil
            return Y0OVrLT0 or VvuLzOP8 >= M4E52Mdv.scanInterval
        end

        function rG4vd4Gj:MarkScanned() M4E52Mdv.lastFullScan = tick() end

        function rG4vd4Gj:MarkVisited(Tldq9CSH)
            if M4E52Mdv.events and M4E52Mdv.events[Tldq9CSH] then
                M4E52Mdv.events[Tldq9CSH].lastVisit = tick()
                M4E52Mdv.events[Tldq9CSH].visitCount = (M4E52Mdv.events[Tldq9CSH].visitCount or 0) + 1
            end
        end
        
        local lmFePLW5 = { interval = 10, lastRotation = 0, currentIndex = 0, queue = {} }

        function lmFePLW5:BuildQueue()
            M4E52Mdv.queue = {}
            local events = rG4vd4Gj:GetAll()
            
            if u6HtiEIb and events[u6HtiEIb] then
                for i = 1, 2 do table.insert(M4E52Mdv.queue, {name = u6HtiEIb, data = events[u6HtiEIb]}) end
            end
            
            for Tldq9CSH, data in pairs(events) do
                if Tldq9CSH ~= u6HtiEIb then
                    table.insert(M4E52Mdv.queue, {name = Tldq9CSH, data = data})
                end
            end
        end

        function lmFePLW5:GetNext()
            if #M4E52Mdv.queue == 0 then M4E52Mdv:BuildQueue() end
            if #M4E52Mdv.queue == 0 then return nil end
            
            M4E52Mdv.currentIndex = M4E52Mdv.currentIndex + 1
            if M4E52Mdv.currentIndex > #M4E52Mdv.queue then M4E52Mdv.currentIndex = 1 end
            
            local b8M9pGQL = M4E52Mdv.queue[M4E52Mdv.currentIndex]
            if not rG4vd4Gj:IsEventStillActive(b8M9pGQL.name) then
                M4E52Mdv:BuildQueue()
                return M4E52Mdv:GetNext()
            end
            return b8M9pGQL
        end

        function lmFePLW5:ShouldRotate()
            if M4E52Mdv.lastRotation == 0 then return true end
            return (tick() - M4E52Mdv.lastRotation) >= M4E52Mdv.interval
        end

        function lmFePLW5:MarkRotated() M4E52Mdv.lastRotation = tick() end
        function lmFePLW5:SetInterval(tjedSwpw) M4E52Mdv.interval = math.max(5, math.min(60, tjedSwpw)) end

        -- =========================================================
        -- TELEPORT MANAGER
        -- =========================================================
        local kKXZLt1G = { lastTeleport = 0, minInterval = 1.0 }

        function kKXZLt1G:Teleport(DsM2nBnr)
            local rP2rjyP2 = tick()
            if rP2rjyP2 - M4E52Mdv.lastTeleport < M4E52Mdv.minInterval then return false end
            
            local A7B8Wl9q = game.Players.LocalPlayer.Character
            local MXhl6X0h = A7B8Wl9q and A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
            if not MXhl6X0h then return false end
            
            local QzH75oi8 = pcall(function()
                local YUseAT4J = Vector3.new(math.random(-5, 5), math.random(5, 15), math.random(-5, 5))
                A7B8Wl9q:PivotTo(CFrame.new(DsM2nBnr + YUseAT4J))
                MXhl6X0h.Anchored = false 
                MXhl6X0h.Velocity = Vector3.zero
                M4E52Mdv.lastTeleport = rP2rjyP2
            end)
            return QzH75oi8
        end

        laBR_mj9:Dropdown({
            Text = _d("g\022\027\009#9>\011\023!\004\003?$", "7drfQPJr"),
            Options = sHlNULOn,
            Default = _d("d\001\030\0032$j\"E\013\029\0208$3", "7drfQPJr"),
            Flag = _d("G\022\027\009#9>\011h\001\004\003?$\021\020[\005\021", "7drfQPJr"),
            Callback = function(_oFeDtVE) u6HtiEIb = _oFeDtVE end
        })

        laBR_mj9:Dropdown({
            Text = _d("y\011\000\0110<j7A\001\028\018\"", "7drfQPJr"),
            Options = sHlNULOn,
            MultiSelect = true,
            Flag = _d("Y\011\000\0110<\021\023A\001\028\018\0146&\019P", "7drfQPJr"),
            Callback = function(NIuZLIdn) ArGJLsWe = NIuZLIdn or {} end
        })

        laBR_mj9:Input({
            Text = _d("e\011\006\007%9%\028\023-\028\0184\"<\019[DZ\021x", "7drfQPJr"),
            Value = tostring(lmFePLW5.interval),
            Placeholder = _d("\006T", "7drfQPJr"),
            Flag = _d("E\011\006\007%9%\028h\013\028\0184\"<\019[;\020\01007", "7drfQPJr"),
            Callback = function(E1HO9OWN)
                local vlC_9Vw2 = tonumber(E1HO9OWN)
                if vlC_9Vw2 then lmFePLW5:SetInterval(vlC_9Vw2) end
            end
        })

        laBR_mj9:Dropdown({
            Text = _d("~\000\030\003q\0178\023VDZ195$Ry\011R#\'5$\006\030", "7drfQPJr"),
            Options = aXNFhzSY,
            Default = _d("d\001\030\0032$j3E\001\019", "7drfQPJr"),
            Flag = _d("^\000\030\003\01418\023V;\020\01007", "7drfQPJr"),
            Callback = function(_oFeDtVE) HLpDXHHF = _oFeDtVE end
        })

        laBR_mj9:Toggle({
            Text = _d("r\010\019\004=5j3B\016\029F\020&/\028CD?\00955", "7drfQPJr"),
            Default = false,
            Flag = _d("R\010\019\004=5\021\019B\016\02994&/\028C;\031\00955", "7drfQPJr"),
            Callback = function(Z2mTETLK)
                xd1seql6 = Z2mTETLK

                if xd1seql6 then
                    rG4vd4Gj:Clear()
                    lmFePLW5.lastRotation = 0
                    lmFePLW5.currentIndex = 0
                    lmFePLW5.queue = {}
                    
                    bO4jsgzL = task.spawn(function()
                        while xd1seql6 do
                            pcall(function()
                                local kFErRclG = 0
                                local _V7ltPHZ = rG4vd4Gj:GetAll()
                                
                                for Tldq9CSH, _ in pairs(_V7ltPHZ) do
                                    if rG4vd4Gj:IsEventStillActive(Tldq9CSH) then
                                        kFErRclG = kFErRclG + 1
                                    end
                                end

                                -- SCANNING LOGIC
                                if rG4vd4Gj:ShouldScan() then
                                    local El0XMyRH = {}
                                    if u6HtiEIb then table.insert(El0XMyRH, u6HtiEIb) end
                                    for _, Tldq9CSH in ipairs(ArGJLsWe) do
                                        if Tldq9CSH ~= u6HtiEIb then table.insert(El0XMyRH, Tldq9CSH) end
                                    end
                                    
                                    local Hvxyi6e4 = 0
                                    for _, Tldq9CSH in ipairs(El0XMyRH) do
                                        if not xd1seql6 then break end
                                        if not rG4vd4Gj:GetAll()[Tldq9CSH] then
                                            local _QpC4X59, position, model = YVs57bLQ(Tldq9CSH)
                                            if _QpC4X59 then
                                                rG4vd4Gj:Add(Tldq9CSH, position, model)
                                                Hvxyi6e4 = Hvxyi6e4 + 1
                                            end
                                        end
                                        task.wait(0.1)
                                    end
                                    rG4vd4Gj:MarkScanned()
                                    if Hvxyi6e4 > 0 then lmFePLW5.queue = {} end
                                end

                                if kFErRclG > 0 then
                                    if lmFePLW5:ShouldRotate() then
                                        local kdnp8_m_ = lmFePLW5:GetNext()
                                        if kdnp8_m_ then
                                            if kKXZLt1G:Teleport(kdnp8_m_.data.position) then
                                                rG4vd4Gj:MarkVisited(kdnp8_m_.name)
                                                lmFePLW5:MarkRotated()
                                                task.wait(8)
                                            end
                                        end
                                    else
                                        task.wait(1)
                                    end
                                else
                                    if HLpDXHHF and UqzQ_Tsi[HLpDXHHF] then
                                        local Dh9xLv5n = UqzQ_Tsi[HLpDXHHF].Pos
                                        kKXZLt1G:Teleport(Dh9xLv5n)
                                    end
                                    task.wait(5)
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                    VN772YQI:Notify({RJ8gM9Bb = _d("d\009\019\020%p\015\004R\010\006", "7drfQPJr"), Content = _d("d\016\019\020%5.", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
                else
                    if bO4jsgzL then task.cancel(bO4jsgzL) end
                    rG4vd4Gj:Clear()
                    VN772YQI:Notify({RJ8gM9Bb = _d("d\009\019\020%p\015\004R\010\006", "7drfQPJr"), Content = _d("d\016\029\022!5.", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
                end
            end
        })
    end
end

do
    local HlUXyEf0 = Window:Tab({Text = _d("d\012\029\022qvj;C\001\031\021", "7drfQPJr"), Icon = _d("\55306\57014", "7drfQPJr")})

    do
        --local ManagerTab = Window:Tab({Text = "Item Manager", Icon = "⭐"})
        local pTnYjZPP = HlUXyEf0:Collapsible(_d("v\017\006\009q\022+\004X\022\027\0184peRb\010\020\007\'?8\027C\001", "7drfQPJr"))

        -- [[ SERVICES & VARIABLES ]]
        local ReplicatedStorage = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
        local W1otLGr3 = false
        local KS_JuCF1 = false
        
        local gujRUQ8H = {}
        local DiEAnjfy = {}
        local IvOJ5ykw = {}
        
        local TabU9zCF = ReplicatedStorage:WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr")):WaitForChild(_d("h-\028\0024(", "7drfQPJr")):WaitForChild(_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr")):WaitForChild(_d("Y\001\006", "7drfQPJr"))
        local L9IzcPeI = TabU9zCF:WaitForChild(_d("e!] 0&%\000^\016\023/%5\'", "7drfQPJr"))
        local sLUNeAMR = TabU9zCF:WaitForChild(_d("e!])3$+\027Y\001\022(4\'\012\027D\012<\009%9,\027T\005\006\015>>", "7drfQPJr"))
        local lWDejpdQ = require(ReplicatedStorage:WaitForChild(_d("~\016\023\011\"", "7drfQPJr")))

        local FQNzyUPx = {
            [1] = _d("t\011\031\011>>", "7drfQPJr"), [2] = _d("b\010\017\009<=%\028", "7drfQPJr"), [3] = _d("e\005\000\003", "7drfQPJr"), [4] = _d("r\020\027\005", "7drfQPJr"),
            [5] = _d("{\001\021\003?4+\000N", "7drfQPJr"), [6] = _d("z\029\006\01483", "7drfQPJr"), [7] = _d("d!14\020\004", "7drfQPJr")
        }

        local function h8XW2y0j(nTr3YXqa)
            for _, EyC3EM17 in pairs(lWDejpdQ) do
                if EyC3EM17.Data and EyC3EM17.Data.Id == nTr3YXqa then return EyC3EM17 end
            end
            return nil
        end

        local function PV8si2VP()
            return {
                _d("p\005\030\007))", "7drfQPJr"), _d("t\011\000\020$ >", "7drfQPJr"), _d("p\001\031\021%?$\023", "7drfQPJr"), _d("q\005\027\020(p\014\007D\016", "7drfQPJr"), _d("z\013\022\00887\"\006", "7drfQPJr"),
                _d("t\011\030\009#p\008\007E\010", "7drfQPJr"), _d("\127\011\030\0096\"+\002_\013\017", "7drfQPJr"), _d("{\013\021\014%>#\028P", "7drfQPJr"), _d("e\005\022\015>1)\006^\018\023", "7drfQPJr"),
                _d("p\012\029\021%", "7drfQPJr"), _d("p\011\030\002", "7drfQPJr"), _d("q\022\029\0284>", "7drfQPJr"), _d("\006\028C\030`({", "7drfQPJr"), _d("d\016\029\0084", "7drfQPJr"), _d("d\005\028\002(", "7drfQPJr"),
                _d("y\011\029\004", "7drfQPJr"), _d("z\011\029\008q\0228\019P\009\023\008%", "7drfQPJr"), _d("q\001\001\0188&/", "7drfQPJr"), _d("v\008\016\015??", "7drfQPJr"), _d("v\022\017\01883j4E\011\001\018", "7drfQPJr"), _d("s\013\001\005>", "7drfQPJr"), 
                _d("u\013\021", "7drfQPJr"), _d("p\013\019\008%", "7drfQPJr"), _d("d\012\027\008(", "7drfQPJr"), _d("d\020\019\020:<#\028P", "7drfQPJr"), _d("{\001\004\0150$+\028", "7drfQPJr")
            }
        end

        local function DqsodROZ()
            local oyDDl9ZF = {}
            for _, item in pairs(lWDejpdQ) do
                if item.Data and item.Data.Name then table.insert(oyDDl9ZF, item.Data.Name) end
            end
            table.sort(oyDDl9ZF)
            return oyDDl9ZF
        end

        local function F5HQRm2u(nTr3YXqa, Bkzly1ma, E1XSErmG)
            local R0OjTbLW = h8XW2y0j(nTr3YXqa)
            if not R0OjTbLW then return false end

            local fT6cNqpR = FQNzyUPx[R0OjTbLW.Data.Tier] or _d("b\010\025\008>\'$", "7drfQPJr")
            if #gujRUQ8H > 0 and table.find(gujRUQ8H, fT6cNqpR) then
                return true, _d("e\005\000\015%)pR", "7drfQPJr") .. fT6cNqpR
            end

            if #IvOJ5ykw > 0 and table.find(IvOJ5ykw, R0OjTbLW.Data.Name) then
                return true, _d("y\005\031\003kp", "7drfQPJr") .. R0OjTbLW.Data.Name
            end

            local ekZU3Lh1 = _d("y\011\028\003", "7drfQPJr")
            if Bkzly1ma and Bkzly1ma.VariantId and Bkzly1ma.VariantId ~= _d("y\011\028\003", "7drfQPJr") then ekZU3Lh1 = Bkzly1ma.VariantId end
            if E1XSErmG and E1XSErmG.Variant and E1XSErmG.Variant ~= _d("y\011\028\003", "7drfQPJr") then ekZU3Lh1 = E1XSErmG.Variant end
            
            -- Cek Shiny manual
            if (Bkzly1ma and Bkzly1ma.Shiny) or (E1XSErmG and E1XSErmG.Shiny) then 
                if #DiEAnjfy > 0 and table.find(DiEAnjfy, _d("d\012\027\008(", "7drfQPJr")) then return true, _d("z\017\006\007%9%\028\013D!\0148>3", "7drfQPJr") end
            end

            if #DiEAnjfy > 0 and table.find(DiEAnjfy, ekZU3Lh1) then
                return true, _d("z\017\006\007%9%\028\013D", "7drfQPJr") .. ekZU3Lh1
            end

            return false
        end
        
        local EzLy9N6F = nil
        
        local function RtLMRGmh(Z2mTETLK)
            if Z2mTETLK then
                if EzLy9N6F then EzLy9N6F:Disconnect() end
                
                EzLy9N6F = sLUNeAMR.OnClientEvent:Connect(function(nTr3YXqa, Bkzly1ma, E1XSErmG)
                    local D_L7mEoR = E1XSErmG and E1XSErmG.InventoryItem
                    local It_UOavT = D_L7mEoR and D_L7mEoR.UUID
                    
                    if not It_UOavT then return end

                    local Qr0aXe_0, reason = F5HQRm2u(nTr3YXqa, Bkzly1ma, E1XSErmG)
                    if W1otLGr3 and Qr0aXe_0 then
                        task.delay(0.5, function()
                            pcall(function() L9IzcPeI:FireServer(It_UOavT) end)
                            VN772YQI:Notify({RJ8gM9Bb=_d("v\017\006\009q\022+\004", "7drfQPJr"), Content=reason, Type=_d("d\017\017\0054#9", "7drfQPJr"), Duration=2})
                        end)
                    end

                    -- LOGIKA AUTO UNFAVORITE (Kebalikan)
                    -- Hapus favorite jika TIDAK match filter tapi entah kenapa ke-fav (jarang terjadi, tapi buat jaga2)
                    -- ATAU jika kamu ingin fitur: "Unfav semua yang tidak masuk list"
                    -- (Biasanya Unfav dipakai manual looping inventory, tapi di sini kita fokus real-time capture)
                end)
            else
                if EzLy9N6F then EzLy9N6F:Disconnect() EzLy9N6F = nil end
            end
        end

        -- [[ MANUAL SCAN (UNTUK UNFAVORITE MASSAL) ]]
        -- Karena Unfavorite biasanya untuk membersihkan inventory yang SUDAH ADA, kita butuh scan manual.
        local function TAlqWOw0()
            local Replion = require(ReplicatedStorage.Packages.Replion).Client
            local Data = Replion:WaitReplion(_d("s\005\006\007", "7drfQPJr"), 5)
            if not Data then return end
            
            local QzH75oi8, inv = pcall(function() return Data:GetExpect(_d("~\010\004\003?$%\000N", "7drfQPJr")) end)
            if not QzH75oi8 or not inv or not inv.Items then return end

            local A33v9oSD = 0
            for _, item in ipairs(inv.Items) do
                -- Kita hanya unfavorite item yang SUDAH Favorite
                if item.Favorited or item.IsFavorite then
                    -- Cek apakah item ini MATCHING dengan filter kita?
                    local gHuu0E9r = item.Metadata or {}
                    local PJPoLssH = {Variant = gHuu0E9r.VariantId, Shiny = gHuu0E9r.Shiny}
                    
                    -- Jika item ini MATCH dengan filter "Sampah" yang user pilih untuk di UNFAV
                    -- Disini logikanya: User memilih Rarity untuk di-UNFAVORITE
                    local GMYUL3MT, _ = F5HQRm2u(item.Id, gHuu0E9r, PJPoLssH)
                    
                    if GMYUL3MT then
                        pcall(function() L9IzcPeI:FireServer(item.UUID) end)
                        A33v9oSD = A33v9oSD + 1
                        task.wait(0.1) -- Delay biar gak kick
                    end
                end
            end
            
            if A33v9oSD > 0 then
                VN772YQI:Notify({RJ8gM9Bb=_d("b\010\020\007\'?8\027C\001", "7drfQPJr"), Content=_d("e\001\031\009\'5.R", "7drfQPJr") .. A33v9oSD .. _d("\023\002\019\016>\"#\006R\023\\", "7drfQPJr"), Type=_d("`\005\000\0088>-", "7drfQPJr")})
            else
                VN772YQI:Notify({RJ8gM9Bb=_d("b\010\020\007\'?8\027C\001", "7drfQPJr"), Content=_d("y\011R\0110$)\026^\010\021F71<\029E\013\006\003\"p,\029B\010\022H", "7drfQPJr"), Type=_d("~\010\020\009", "7drfQPJr")})
            end
        end

        -- [[ UI IMPLEMENTATION ]]
        
        pTnYjZPP:Dropdown({
            Text = _d("q\013\030\0184\"j V\022\027\018(", "7drfQPJr"),
            Options = {_d("t\011\031\011>>", "7drfQPJr"), _d("b\010\017\009<=%\028", "7drfQPJr"), _d("e\005\000\003", "7drfQPJr"), _d("r\020\027\005", "7drfQPJr"), _d("{\001\021\003?4+\000N", "7drfQPJr"), _d("z\029\006\01483", "7drfQPJr"), _d("d!14\020\004", "7drfQPJr")},
            MultiSelect = true,
            Callback = function(K_AAw11i) gujRUQ8H = K_AAw11i or {} end
        })

        pTnYjZPP:Dropdown({
            Text = _d("q\013\030\0184\"j?B\016\019\0188?$", "7drfQPJr"),
            Options = PV8si2VP(),
            MultiSelect = true,
            Callback = function(K_AAw11i) DiEAnjfy = K_AAw11i or {} end
        })

        pTnYjZPP:Dropdown({
            Text = _d("q\013\030\0184\"j4^\023\026F\0311\'\023", "7drfQPJr"),
            Options = DqsodROZ(),
            MultiSelect = true,
            Callback = function(K_AAw11i) IvOJ5ykw = K_AAw11i or {} end
        })

        pTnYjZPP:Toggle({
            Text = _d("r\010\019\004=5j3B\016\029F\0231<\029E\013\006\003qx\024\023V\008_28=/[", "7drfQPJr"),
            Default = false,
            Callback = function(Z2mTETLK)
                W1otLGr3 = Z2mTETLK
                RtLMRGmh(Z2mTETLK or KS_JuCF1) -- Nyalakan listener jika salah satu aktif
                
                if Z2mTETLK then
                    VN772YQI:Notify({RJ8gM9Bb=_d("v\017\006\009q\022+\004X\022\027\0184", "7drfQPJr"), Content=_d("x*SF\0285$\007Y\003\021\019q9!\019YJ\\H", "7drfQPJr"), Type=_d("d\017\017\0054#9", "7drfQPJr")})
                end
            end
        })

        -- Auto Unfavorite di sini saya buat manual button saja agar lebih aman
        -- Karena Auto Unfavorite real-time itu aneh (masa baru dapet langsung di unfav?)
        pTnYjZPP:Button({
            Text = _d("b\010\020\007\'?8\027C\001R+0$)\026^\010\021F\024$/\031DDZ521$R~\010\004\003?$%\000NM", "7drfQPJr"),
            Callback = function()
                if #gujRUQ8H == 0 and #DiEAnjfy == 0 and #IvOJ5ykw == 0 then
                    VN772YQI:Notify({RJ8gM9Bb=_d("`\005\000\0088>-", "7drfQPJr"), Content=_d("g\013\030\0159p,\027[\016\023\020q4?\030BDZ/%5\'RN\005\028\001q=+\007\023\000\027K\004>,\019AM", "7drfQPJr"), Type=_d("`\005\000\0088>-", "7drfQPJr")})
                    return
                end
                
                VN772YQI:Notify({RJ8gM9Bb=_d("d\007\019\008?9$\021", "7drfQPJr"), Content=_d("z\001\031\022#?9\023DD\027\008\'5$\006X\022\011H\127~", "7drfQPJr"), Type=_d("~\010\020\009", "7drfQPJr")})
                TAlqWOw0()
            end
        })
        
        pTnYjZPP:Label({Text = _d("y\011\006\003kp\031\028C\017\025F\016%>\029\023\"\019\016>\"#\006RHR\0228<#\026\023\013\006\003<p\0083p1!Hq\005$\006B\015R3?6+\004X\022\027\0184p\008\007C\016\029\008}p:\027[\013\026F8$/\031\023.7*\020\027j\011V\010\021F<1?RS\013\026\007!%9RU\013\028\0180>-\028N\005\\", "7drfQPJr"), Color = Color3.fromRGB(200, 200, 200)})

    end
    
    local ReplicatedStorage = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
    local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
    local LocalPlayer = Players.LocalPlayer
    local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))

    local function NtU4C8Sr(path)
        local QzH75oi8, tYBp8S9Z = pcall(function()
            return require(path)
        end)
        if QzH75oi8 then
            return tYBp8S9Z
        else
            warn(_d("l<\023\008>p\012\027O9R!07+\030\023\022\023\023$98\023\023\009\029\002$</H\023", "7drfQPJr") .. tostring(path))
            return nil
        end
    end

    local xqPcuQDl = NtU4C8Sr(ReplicatedStorage:WaitForChild(_d("d\012\019\02044", "7drfQPJr")):WaitForChild(_d("~\016\023\011\004$#\030^\016\011", "7drfQPJr"), 2))
    local zzUw5h7D = NtU4C8Sr(ReplicatedStorage:WaitForChild(_d("d\012\019\02044", "7drfQPJr")):WaitForChild(_d("c\013\023\020\004$#\030^\016\011", "7drfQPJr"), 2))
    local gRO_IOBS = NtU4C8Sr(ReplicatedStorage:WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr")):WaitForChild(_d("e\001\002\0108?$", "7drfQPJr"), 2))

    local upFDBW_q = nil
    
    local function RdvFl2RE()
        if upFDBW_q then return upFDBW_q end
        local gRO_IOBS = kmz3nYWI:WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr")):WaitForChild(_d("e\001\002\0108?$", "7drfQPJr"), 10)
        if not gRO_IOBS then return nil end
        local bCT85V37 = require(gRO_IOBS).Client
        upFDBW_q = bCT85V37:WaitReplion(_d("s\005\006\007", "7drfQPJr"), 5)
        return upFDBW_q
    end

    -- Helper function to find remotes safely
    local function m3qKT1lM(name)
        -- Coba cari di NetPackage
        local tjedSwpw, MOAZubZT = pcall(function() 
            local x6Sluij5 = ReplicatedStorage.Packages._Index[_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr")].net
            return x6Sluij5:FindFirstChild(_d("e\"]", "7drfQPJr") .. name) or x6Sluij5:FindFirstChild(_d("e!]", "7drfQPJr") .. name)
        end)
        if tjedSwpw and MOAZubZT then return MOAZubZT end
        return nil
    end

    -- =========================================================
    -- 1. AUTO BUY WEATHER
    -- =========================================================
    local RxHluj5V = HlUXyEf0:Collapsible(_d("v\017\006\009q\018?\011\0233\023\007%8/\000", "7drfQPJr"))
    
    local lQfpNccX = m3qKT1lM(_d("g\017\000\005919\023`\001\019\0189587A\001\028\018", "7drfQPJr"))
    local R70cGTlX = {
        Running = false,
        Selected = {},
        AllWeathers = {_d("t\008\029\0195)", "7drfQPJr"), _d("d\016\029\020<", "7drfQPJr"), _d("`\013\028\002", "7drfQPJr"), _d("d\010\029\017", "7drfQPJr"), _d("e\005\022\0150>>", "7drfQPJr"), _d("d\012\019\020:p\002\007Y\016", "7drfQPJr")}
    }
    
    local Jm9pwdhj = nil

    -- Dropdown Multi Select
    RxHluj5V:Dropdown({
        Text = _d("d\001\030\0032$j%R\005\006\0144\"9Rc\005\000\0014$", "7drfQPJr"),
        Options = R70cGTlX.AllWeathers,
        MultiSelect = true,
        Callback = function(rN1mKTxP)
            R70cGTlX.Selected = rN1mKTxP or {}
        end
    })
    
    -- Logic Loop
    local lCuKVgGG = nil
    local function uanwAnK7()
        if lCuKVgGG then task.cancel(lCuKVgGG) end
        lCuKVgGG = task.spawn(function()
            while R70cGTlX.Running do
                for _, weather in ipairs(R70cGTlX.Selected) do
                    if not R70cGTlX.Running then break end
                    if lQfpNccX then
                        pcall(function() lQfpNccX:InvokeServer(weather) end)
                    end
                    task.wait(0.1)
                end
                task.wait(10)
            end
        end)
    end

    -- Buttons
    RxHluj5V:Button({
        Text = _d("d\016\019\020%p\011\007C\011R$$)", "7drfQPJr"),
        Callback = function()
            if #R70cGTlX.Selected == 0 then
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\0032$j\005R\005\006\0144\"j\020^\022\001\018p", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                return
            end
            R70cGTlX.Running = true
            uanwAnK7()
            VN772YQI:Notify({RJ8gM9Bb = _d("v\017\006\009q\018?\011", "7drfQPJr"), Content = _d("d\016\019\020%5.", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
        end
    })
    
    RxHluj5V:Button({
        Text = _d("d\016\029\022q\017?\006XD0\019(", "7drfQPJr"),
        Callback = function()
            R70cGTlX.Running = false
            if lCuKVgGG then task.cancel(lCuKVgGG) end
            VN772YQI:Notify({RJ8gM9Bb = _d("v\017\006\009q\018?\011", "7drfQPJr"), Content = _d("d\016\029\022!5.", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
        end
    })
    
    local SQSggRao = XtEpjbKg(luxCjQ_B, _d("e!]5!1=\028c\011\006\003<", "7drfQPJr"))
    local y6QH9V58 = XtEpjbKg(luxCjQ_B, _d("e\"]# %#\002x\028\011\0014>\030\019Y\015", "7drfQPJr"))
    local BP7VLnol = XtEpjbKg(luxCjQ_B, _d("e\"]3?5;\007^\020=\030(7/\028c\005\028\013", "7drfQPJr"))

    local function aI6dd38v(msg)
        warn(_d("l0=2\020\029j!n7&#\028\013j", "7drfQPJr") .. msg)
    end

    if not SQSggRao then
        aI6dd38v(_d("`% (\024\030\013H\02367I\002 +\005Y0\029\0184=j\006^\000\019\013q4#\006R\009\007\0130>kRg\005\001\0188;+\028\023\013\028\015q7+\031RDU 8#\"R~\016UH", "7drfQPJr"))
    end

    -- [2] UI & VARIABLES
    local PGa5N3a3 = HlUXyEf0:Collapsible(_d("v\017\006\009q\003:\019@\010R2>$/\031", "7drfQPJr"))
    local cNGqlz2O = PGa5N3a3:Paragraph({RJ8gM9Bb = _d("d\016\019\018$#", "7drfQPJr"), Content = _d("~\000\030\003", "7drfQPJr")})

    local I9xUJ4yQ = {
        [_d("{\017\017\013q\004%\006R\009", "7drfQPJr")]={Id=1, Duration=3600}, 
        [_d("z\017\006\007%9%\028\0230\029\0184=", "7drfQPJr")]={Id=2, Duration=3600}, 
        [_d("d\012\027\008(p\030\029C\001\031", "7drfQPJr")]={Id=3, Duration=3600}
    }
    local vFXdqh4x = {_d("{\017\017\013q\004%\006R\009", "7drfQPJr"), _d("z\017\006\007%9%\028\0230\029\0184=", "7drfQPJr"), _d("d\012\027\008(p\030\029C\001\031", "7drfQPJr")}
    local lvetCBjr = _d("{\017\017\013q\004%\006R\009", "7drfQPJr")
    local jGohGm0a = 0
    
    local cgfhoj56 = false
    local qOEZ4LjM = nil
    
    local l2uoFYhe = false
    local eL36iXVn = nil

    -- [3] COORDINATES (9 SPOTS)
    local UehY27a3 = Vector3.new(93.932, 9.532, 2684.134)
    local IiHGtIc6 = {
        Vector3.new(45.046, 9.516, 2730.190),   -- 1
        Vector3.new(145.644, 9.516, 2721.907),  -- 2
        Vector3.new(84.640, 10.217, 2636.057),  -- 3
        Vector3.new(45.046, 110.516, 2730.190), -- 4
        Vector3.new(145.644, 110.516, 2721.907),-- 5
        Vector3.new(84.640, 111.217, 2636.057), -- 6
        Vector3.new(45.046, -92.483, 2730.190), -- 7
        Vector3.new(145.644, -92.483, 2721.907),-- 8
        Vector3.new(84.640, -93.782, 2636.057), -- 9
    }

    -- =========================================================
    -- FLY ENGINE V3 (PHYSICS + ANTI-FALL)
    -- =========================================================
    local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
    local LocalPlayer = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer
    local t1EaZMFr = nil

    local function ne8QJMPV()
        local A7B8Wl9q = LocalPlayer.Character
        if not A7B8Wl9q then return nil end
        return A7B8Wl9q:FindFirstChild(_d("c\011\000\021>", "7drfQPJr")) or A7B8Wl9q:FindFirstChild(_d("b\020\002\003#\004%\000D\011", "7drfQPJr")) or A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
    end

    local function ivMOadnV(enable)
        local A7B8Wl9q = LocalPlayer.Character
        local lQdgJ77v = A7B8Wl9q and A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
        if not lQdgJ77v then return end

        if enable then
            -- Paksa matikan state jatuh
            lQdgJ77v:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            lQdgJ77v:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            lQdgJ77v:SetStateEnabled(Enum.HumanoidStateType.Freefall, false) -- Kunci utama anti-guling

            if not t1EaZMFr then
                t1EaZMFr = bqYp_xry.Heartbeat:Connect(function()
                    if lQdgJ77v and (l2uoFYhe or cgfhoj56) then
                        lQdgJ77v:ChangeState(Enum.HumanoidStateType.Swimming) -- State paling stabil
                    end
                end)
            end
        else
            if t1EaZMFr then t1EaZMFr:Disconnect(); t1EaZMFr = nil end
            lQdgJ77v:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            lQdgJ77v:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            lQdgJ77v:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            lQdgJ77v:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end

    local function Gy1azqVs()
        local A7B8Wl9q = LocalPlayer.Character
        local lQdgJ77v = A7B8Wl9q and A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
        local brCGxg1F = ne8QJMPV()
        if not brCGxg1F or not lQdgJ77v then return end

        lQdgJ77v.PlatformStand = true 
        ivMOadnV(true)

        local KH8mC01y = brCGxg1F:FindFirstChild(_d("q\008\011!$9\013\011E\011", "7drfQPJr")) or Instance.new(_d("u\011\022\031\022)8\029", "7drfQPJr"), brCGxg1F)
        KH8mC01y.Name = _d("q\008\011!$9\013\011E\011", "7drfQPJr"); KH8mC01y.P = 9e4; KH8mC01y.maxTorque = Vector3.new(9e9, 9e9, 9e9); KH8mC01y.CFrame = brCGxg1F.CFrame

        local qUEhhdLV = brCGxg1F:FindFirstChild(_d("q\008\011!$9\028\023[\011\017\015%)", "7drfQPJr")) or Instance.new(_d("u\011\022\031\0075&\029T\013\006\031", "7drfQPJr"), brCGxg1F)
        qUEhhdLV.Name = _d("q\008\011!$9\028\023[\011\017\015%)", "7drfQPJr"); qUEhhdLV.velocity = Vector3.zero; qUEhhdLV.maxForce = Vector3.new(9e9, 9e9, 9e9)

        -- Noclip
        task.spawn(function()
            while (l2uoFYhe or cgfhoj56) and A7B8Wl9q do
                for _, K_AAw11i in ipairs(A7B8Wl9q:GetDescendants()) do
                    if K_AAw11i:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then K_AAw11i.CanCollide = false end
                end
                task.wait(0.5)
            end
        end)
    end

    local function zOoPloL8()
        local A7B8Wl9q = LocalPlayer.Character
        local lQdgJ77v = A7B8Wl9q and A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022", "7drfQPJr"))
        local brCGxg1F = ne8QJMPV()

        if brCGxg1F then
            if brCGxg1F:FindFirstChild(_d("q\008\011!$9\013\011E\011", "7drfQPJr")) then brCGxg1F.FlyGuiGyro:Destroy() end
            if brCGxg1F:FindFirstChild(_d("q\008\011!$9\028\023[\011\017\015%)", "7drfQPJr")) then brCGxg1F.FlyGuiVelocity:Destroy() end
            brCGxg1F.Velocity = Vector3.zero
        end

        if lQdgJ77v then lQdgJ77v.PlatformStand = false end
        ivMOadnV(false)
        
        -- Restore Collision
        if A7B8Wl9q then
            for _, K_AAw11i in ipairs(A7B8Wl9q:GetDescendants()) do
                if K_AAw11i:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then K_AAw11i.CanCollide = true end
            end
        end
    end

    local function UlybnW1o(qBFp4YeG)
        local brCGxg1F = ne8QJMPV()
        if not brCGxg1F then return end
        
        local qUEhhdLV = brCGxg1F:FindFirstChild(_d("q\008\011!$9\028\023[\011\017\015%)", "7drfQPJr"))
        local KH8mC01y = brCGxg1F:FindFirstChild(_d("q\008\011!$9\013\011E\011", "7drfQPJr"))
        if not qUEhhdLV or not KH8mC01y then Gy1azqVs(); qUEhhdLV = brCGxg1F.FlyGuiVelocity; KH8mC01y = brCGxg1F.FlyGuiGyro end

        local daP9voq8 = 85 -- Kecepatan Terbang
        
        while (l2uoFYhe or cgfhoj56) do
            local jjYgpbnQ = brCGxg1F.Position
            local TM1LbaW0 = qBFp4YeG - jjYgpbnQ
            local C53FY81z = TM1LbaW0.Magnitude
            
            KH8mC01y.CFrame = CFrame.lookAt(jjYgpbnQ, qBFp4YeG)

            if C53FY81z < 2.0 then -- Sampai target
                qUEhhdLV.velocity = Vector3.zero
                break
            else
                qUEhhdLV.velocity = TM1LbaW0.Unit * daP9voq8
            end
            bqYp_xry.Heartbeat:Wait()
        end
    end

    local gRO_IOBS = NtU4C8Sr(ReplicatedStorage:WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr")):WaitForChild(_d("e\001\002\0108?$", "7drfQPJr"), 2))

    local function RdvFl2RE()
        if upFDBW_q then return upFDBW_q end
        local gRO_IOBS = kmz3nYWI:WaitForChild(_d("g\005\017\01307/\001", "7drfQPJr")):WaitForChild(_d("e\001\002\0108?$", "7drfQPJr"), 10)
        if not gRO_IOBS then return nil end
        local bCT85V37 = require(gRO_IOBS).Client
        upFDBW_q = bCT85V37:WaitReplion(_d("s\005\006\007", "7drfQPJr"), 5)
        return upFDBW_q
    end

    -- =========================================================
    -- HELPER: GET UUID
    -- =========================================================
    local function EIjNi1Uo(name)
        -- Gunakan fungsi GetPlayerDataReplion() yang sudah ada di script hub Anda
        local MOAZubZT = RdvFl2RE() 
        if not MOAZubZT then return nil end
        
        local tjedSwpw, QVgaMZ5u = pcall(function() return MOAZubZT:GetExpect(_d("~\010\004\003?$%\000N", "7drfQPJr")) end)
        if tjedSwpw and QVgaMZ5u.Totems then 
            for _, i in ipairs(QVgaMZ5u.Totems) do 
                -- Cocokkan ID Totem
                if tonumber(i.Id) == I9xUJ4yQ[name].Id and (i.Count or 1) >= 1 then 
                    return i.UUID 
                end 
            end 
        end
        return nil
    end

    local function VY_S6AUA()
        if eL36iXVn then task.cancel(eL36iXVn) end
        
        eL36iXVn = task.spawn(function()
            -- Cek Remote
            if not SQSggRao then
                VN772YQI:Notify({RJ8gM9Bb=_d("r\022\000\009#", "7drfQPJr"), Content=_d("e\001\031\009%5j!G\005\005\008\005?>\023ZD\006\01551!RS\013\006\003<%!\019YE", "7drfQPJr"), Type=_d("r\022\000\009#", "7drfQPJr")})
                return
            end

            -- Cek UUID Awal
            local It_UOavT = EIjNi1Uo(lvetCBjr)
            if not It_UOavT then 
                VN772YQI:Notify({RJ8gM9Bb=_d("r\022\000\009#", "7drfQPJr"), Content=_d("c\013\022\007:p+\022VD\001\018>3!R", "7drfQPJr") .. lvetCBjr, Type=_d("r\022\000\009#", "7drfQPJr")})
                local Md_RPwqi = PGa5N3a3:GetElementByTitle(_d("v\017\006\009q\003:\019@\010R_q\004%\006R\009R >\"\'\019C\013\029\008", "7drfQPJr"))
                if Md_RPwqi then Md_RPwqi:Set(false) end
                return 
            end

            local A7B8Wl9q = LocalPlayer.Character
            local MXhl6X0h = A7B8Wl9q and A7B8Wl9q:FindFirstChild(_d("\127\017\031\007??#\022e\011\029\018\00118\006", "7drfQPJr"))
            if not MXhl6X0h then return end
            
            local OTnStSMB = MXhl6X0h.Position 
            VN772YQI:Notify({RJ8gM9Bb=_d("d\016\019\020%5.", "7drfQPJr"), Content=_d("q\011\000\0110$#\029YD!\003 %/\028T\001R5%18\006R\000", "7drfQPJr"), Type=_d("~\010\020\009", "7drfQPJr")})
            
            -- Equip Oxygen
            if y6QH9V58 then pcall(function() y6QH9V58:InvokeServer(105) end) end
            
            Gy1azqVs()

            for i, refSpot in ipairs(IiHGtIc6) do
                if not l2uoFYhe then break end
                
                -- Hitung posisi relatif
                local CVKmRFp5 = refSpot - UehY27a3
                local qBFp4YeG = OTnStSMB + CVKmRFp5
                
                cNGqlz2O:SetDesc(_d("q\008\011\015?7j\006XD!\022>$jQ", "7drfQPJr") .. i)
                UlybnW1o(qBFp4YeG) 
                task.wait(0.3) -- Stabilisasi singkat

                -- Ambil UUID terbaru (takutnya berubah/stack berkurang)
                It_UOavT = EIjNi1Uo(lvetCBjr)
                if It_UOavT then
                    cNGqlz2O:SetDesc(_d("d\020\019\017?9$\021\023G", "7drfQPJr") .. i)
                    
                    -- [THE MAGIC LINE] Direct Spawn via Remote
                    SQSggRao:FireServer(It_UOavT)
                    
                    -- Fake Equip (Opsional: Biar inventory refresh di UI)
                    pcall(function() game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr")).Packages._Index[_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr")].net[_d("e!]# %#\002c\011\029\010\023\"%\031\127\011\006\0040\"", "7drfQPJr")]:FireServer(1) end)
                else
                    VN772YQI:Notify({RJ8gM9Bb=_d("\127\005\016\015\"", "7drfQPJr"), Content=_d("d\016\029\005:p\030\029C\001\031F\0251(\027DE", "7drfQPJr"), Type=_d("`\005\000\0088>-", "7drfQPJr")})
                    break
                end
                
                task.wait(0.5) -- Delay antar spawn
            end

            if l2uoFYhe then
                cNGqlz2O:SetDesc(_d("e\001\006\019#>#\028PJ\\H", "7drfQPJr"))
                UlybnW1o(OTnStSMB)
                VN772YQI:Notify({RJ8gM9Bb=_d("d\001\030\003\"1#", "7drfQPJr"), Content=_d("\014D&\009%5\'Rg\008\019\00544k", "7drfQPJr"), Type=_d("d\017\017\0054#9", "7drfQPJr")})
            end
            
            if BP7VLnol then pcall(function() BP7VLnol:InvokeServer() end) end
            
            zOoPloL8() 
            l2uoFYhe = false
            local Md_RPwqi = PGa5N3a3:GetElementByTitle(_d("v\017\006\009q\003:\019@\010R_q\004%\006R\009R >\"\'\019C\013\029\008", "7drfQPJr"))
            if Md_RPwqi then Md_RPwqi:Set(false) end
        end)
    end

    -- =========================================================
    -- LOGIC 2: SINGLE AUTO TOTEM (TIMER)
    -- =========================================================
    local function YE0YNvfI()
        if qOEZ4LjM then task.cancel(qOEZ4LjM) end
        
        qOEZ4LjM = task.spawn(function()
            if not SQSggRao then
                VN772YQI:Notify({RJ8gM9Bb=_d("r\022\000\009#", "7drfQPJr"), Content=_d("e\001\031\009%5j!G\005\005\008\005?>\023ZD?\015\"##\028P", "7drfQPJr"), Type=_d("r\022\000\009#", "7drfQPJr")})
                return
            end

            while cgfhoj56 do
                local _3j2bVC5 = jGohGm0a - os.time()
                
                if _3j2bVC5 > 0 then
                    local ZnY0dI8F = math.floor((_3j2bVC5 % 3600) / 60)
                    local tjedSwpw = math.floor(_3j2bVC5 % 60)
                    cNGqlz2O:SetDesc(_d("y\001\010\018kpoB\005\000HCab.", "7drfQPJr"), ZnY0dI8F, tjedSwpw)
                else
                    cNGqlz2O:SetDesc(_d("d\020\019\017?9$\021\0237\027\0086</\\\025J", "7drfQPJr"))
                    
                    local It_UOavT = EIjNi1Uo(lvetCBjr)
                    if It_UOavT then
                        -- Direct Spawn
                        SQSggRao:FireServer(It_UOavT)
                        
                        VN772YQI:Notify({RJ8gM9Bb=_d("d\020\019\017?5.", "7drfQPJr"), Content=lvetCBjr, Type=_d("d\017\017\0054#9", "7drfQPJr")})
                        
                        -- Update Timer
                        local mmyGNwMI = I9xUJ4yQ[lvetCBjr].Duration or 3600
                        jGohGm0a = os.time() + mmyGNwMI
                    else
                        cNGqlz2O:SetDesc(_d("y\011R5%?)\025\022", "7drfQPJr"))
                    end
                end
                task.wait(1)
            end
        end)
    end
    
    PGa5N3a3:Dropdown({
        Text = _d("d\001\030\0032$j&X\016\023\011q\0043\002R", "7drfQPJr"),
        Options = vFXdqh4x,
        Default = _d("{\017\017\013q\004%\006R\009", "7drfQPJr"),
        Callback = function(Nti5t7zx) lvetCBjr = Nti5t7zx; jGohGm0a = 0 end
    })

    PGa5N3a3:Toggle({
        Text = _d("r\010\019\004=5j3B\016\029F\005?>\023ZDZ28=/\000\0247\027\0086</[", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            cgfhoj56 = Z2mTETLK
            if Z2mTETLK then YE0YNvfI() 
            elseif qOEZ4LjM then task.cancel(qOEZ4LjM) end
        end
    })
    
    PGa5N3a3:Toggle({
        Text = _d("v\017\006\009q\003:\019@\010R_q\004%\006R\009R >\"\'\019C\013\029\008", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            l2uoFYhe = Z2mTETLK
            if Z2mTETLK then
                VY_S6AUA()
            else
                if eL36iXVn then task.cancel(eL36iXVn) end
                zOoPloL8()
                VN772YQI:Notify({RJ8gM9Bb=_d("d\016\029\022!5.", "7drfQPJr"), Content=_d("\014D&\009%5\'Rd\016\029\022!5.", "7drfQPJr"), Type=_d("`\005\000\0088>-", "7drfQPJr")})
            end
        end
    })
    
    local uS7xnzIA = HlUXyEf0:Collapsible(_d("v\017\006\009q\003/\030[D;\0184=9", "7drfQPJr"))
    
    local AfvBClV8 = m3qKT1lM(_d("d\001\030\010\016<&;C\001\031\021", "7drfQPJr"))
    local uyDWWSoc = {
        TotalSells = 0,
        Timer = { Enabled = false, Interval = 5, Thread = nil },
        Count = { Enabled = false, Target = 200, Thread = nil, LastSell = 0 }
    }

    local function wdZ3lE6A()
        if not AfvBClV8 then return false end
        local tjedSwpw, MOAZubZT = pcall(function() return AfvBClV8:InvokeServer() end)
        if tjedSwpw then uyDWWSoc.TotalSells = uyDWWSoc.TotalSells + 1 return true end
        return false
    end
    
    local function T2rAAR4w()
        -- Helper bag parser simple
        local tTI2alKC = LocalPlayer:FindFirstChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
        local UuSZrd8j = tTI2alKC and tTI2alKC:FindFirstChild(_d("~\010\004\003?$%\000N", "7drfQPJr")) and tTI2alKC.Inventory.Main.Top.Options.Fish.Label.BagSize
        if UuSZrd8j then
            local j9nGUBPL = UuSZrd8j.Text:match(_d("\031A\022Mx\127", "7drfQPJr"))
            local max = UuSZrd8j.Text:match(_d("\024LW\002zy", "7drfQPJr"))
            return tonumber(j9nGUBPL) or 0, tonumber(max) or 0
        end
        return 0, 0
    end

    uS7xnzIA:Button({
        Text = _d("d\001\030\010q\017&\030\023-\006\003<#j<X\019", "7drfQPJr"),
        Callback = function()
            if wdZ3lE6A() then
                VN772YQI:Notify({RJ8gM9Bb = _d("d\011\030\002", "7drfQPJr"), Content = _d("~\016\023\011\"p9\029[\000R\021$3)\023D\023\020\019=<3", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
            else
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\010q\022+\027[\001\022F~p\024\023Z\011\006\003q\029#\001D\013\028\001", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
            end
        end
    })

    -- Timer Mode
    uS7xnzIA:Input({
        Text = _d("c\013\031\003#p\003\028C\001\000\0160<jZDM", "7drfQPJr"),
        Value = _d("\002", "7drfQPJr"),
        Placeholder = _d("\002", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx and Nti5t7zx >= 1 then uyDWWSoc.Timer.Interval = Nti5t7zx end
        end
    })

    uS7xnzIA:Toggle({
        Text = _d("r\010\019\004=5j3B\016\029F\0025&\030\023L&\015<58[", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            uyDWWSoc.Timer.Enabled = Z2mTETLK
            if Z2mTETLK then
                uyDWWSoc.Timer.Thread = task.spawn(function()
                    while uyDWWSoc.Timer.Enabled do
                        task.wait(uyDWWSoc.Timer.Interval)
                        if not uyDWWSoc.Timer.Enabled then break end
                        wdZ3lE6A()
                    end
                end)
            elseif uyDWWSoc.Timer.Thread then
                task.cancel(uyDWWSoc.Timer.Thread)
            end
        end
    })

    -- Count Mode
    uS7xnzIA:Input({
        Text = _d("d\001\030\010q1>Ru\005\021F\018??\028C", "7drfQPJr"),
        Value = _d("\005TB", "7drfQPJr"),
        Placeholder = _d("\005TB", "7drfQPJr"),
        Callback = function(K_AAw11i)
            local Nti5t7zx = tonumber(K_AAw11i)
            if Nti5t7zx and Nti5t7zx > 0 then uyDWWSoc.Count.Target = Nti5t7zx end
        end
    })

    uS7xnzIA:Toggle({
        Text = _d("r\010\019\004=5j3B\016\029F\0025&\030\023L0\031q\019%\007Y\016[", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            uyDWWSoc.Count.Enabled = Z2mTETLK
            if Z2mTETLK then
                uyDWWSoc.Count.Thread = task.spawn(function()
                    while uyDWWSoc.Count.Enabled do
                        task.wait(1.5)
                        if not uyDWWSoc.Count.Enabled then break end
                        local j9nGUBPL, _ = T2rAAR4w()
                        if j9nGUBPL >= uyDWWSoc.Count.Target then
                            if tick() - uyDWWSoc.Count.LastSell > 3 then
                                uyDWWSoc.Count.LastSell = tick()
                                wdZ3lE6A()
                                task.wait(2)
                            end
                        end
                    end
                end)
            elseif uyDWWSoc.Count.Thread then
                task.cancel(uyDWWSoc.Count.Thread)
            end
        end
    })
    
    local lxCNgYqo = HlUXyEf0:Collapsible(_d("z\001\000\00591$\006\023%\017\0054#9", "7drfQPJr"))

    lxCNgYqo:Toggle({
        Text = _d("x\020\023\008q\029/\000T\012\019\008%p\013\'~", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            local dQKakey1 = LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
            local bu52Sx9p = dQKakey1:FindFirstChild(_d("z\001\000\00591$\006", "7drfQPJr"))
            if bu52Sx9p then
                bu52Sx9p.Enabled = Z2mTETLK
                if Z2mTETLK then VN772YQI:Notify({RJ8gM9Bb = _d("d\012\029\022", "7drfQPJr"), Content = _d("x\020\023\00844", "7drfQPJr")}) end
            else
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("z\001\000\00591$\006\0231;F\031?>Rq\011\007\0085", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
            end
        end
    })

    lxCNgYqo:Button({
        Text = _d("q\013\010F~p\024\023Q\022\023\0219p\007\023E\007\026\007?$j\'~", "7drfQPJr"),
        Callback = function()
            local dQKakey1 = LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
            local bu52Sx9p = dQKakey1:FindFirstChild(_d("z\001\000\00591$\006", "7drfQPJr"))
            if bu52Sx9p then
                bu52Sx9p.Enabled = false
                task.wait(0.1)
                bu52Sx9p.Enabled = true
                VN772YQI:Notify({RJ8gM9Bb = _d("e\001\020\0204#\"\023S", "7drfQPJr"), Content = _d("b-R44#/\006\023 \029\0084", "7drfQPJr")})
            end
        end
    })
end

do
    local ImYQkF7K = Window:Tab({Text = _d("d\001\006\0188>-\001", "7drfQPJr"), Icon = _d("\9902\65131", "7drfQPJr")})
    local pjPhTsIL = ImYQkF7K:Collapsible(_d("z\013\001\005\127p\011\000R\005", "7drfQPJr"))
    
    local bqYp_xry = game:GetService(_d("e\017\02854\"<\027T\001", "7drfQPJr"))
    local LocalPlayer = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer
    local tKV5dU5u = game:GetService(_d("t\011\000\003\022%#", "7drfQPJr"))
    local zEygNoja = game:GetService(_d("b\023\023\020\024>:\007C7\023\020\'9)\023", "7drfQPJr"))

    -- 1. DISABLE 3D RENDERING (SAVER MODE)
    local bFjOnOVq = nil
    local lavKikxp = nil

    -- =================================================================
    -- CONFIGURATION SYSTEM UI
    -- =================================================================
    local NhsWKLS5 = ImYQkF7K:Collapsible(_d("t\011\028\00087?\000V\016\027\009?p\007\019Y\005\021\003#", "7drfQPJr"))
    
    local PEPRzurm = _d("", "7drfQPJr")
    local lkRtK0US = nil
    
    -- Input Nama Config Baru
    NhsWKLS5:Input({
        Text = _d("t\022\023\007%5j1X\010\020\0156p\004\019Z\001", "7drfQPJr"),
        Placeholder = _d("r\028HF\0295-\027CD4\007#=", "7drfQPJr"),
        Callback = function(E1HO9OWN)
            PEPRzurm = E1HO9OWN
        end
    })
    
    -- Tombol Save Baru
    NhsWKLS5:Button({
        Text = _d("d\005\004\003q\030/\005\023\'\029\00879-", "7drfQPJr"),
        Callback = function()
            if PEPRzurm == _d("", "7drfQPJr") then 
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("~\010\002\019%p)\029Y\002\027\001q>+\031RD\020\015##>S", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                return 
            end

            local X7QYBjSd = AFKnlSfT(PEPRzurm)
            if X7QYBjSd == _d("", "7drfQPJr") then
                VN772YQI:Notify({
                    RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"),
                    Content = _d("~\010\004\007=9.RT\011\028\00087j\028V\009\023G", "7drfQPJr"),
                    Type = _d("r\022\000\009#", "7drfQPJr")
                })
                return
            end

            local QzH75oi8 = VN772YQI:SaveConfig(X7QYBjSd)
            if QzH75oi8 then
                VN772YQI.AutoSave.ActiveConfig = X7QYBjSd
                VN772YQI:Notify({
                    RJ8gM9Bb = _d("t\011\028\00087", "7drfQPJr"),
                    Content = _d("d\005\004\0035jj", "7drfQPJr") .. PEPRzurm .. _d("\023L", "7drfQPJr") .. X7QYBjSd .. _d("\030", "7drfQPJr"),
                    Type = _d("d\017\017\0054#9", "7drfQPJr")
                })
            else
                VN772YQI:Notify({
                    RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"),
                    Content = _d("d\005\004\003q\022+\027[\001\022Fy\019\"\023T\015R#)5)\007C\011\000O", "7drfQPJr"),
                    Type = _d("r\022\000\009#", "7drfQPJr")
                })
            end
        end
    })

    NhsWKLS5:Toggle({
        Text = _d("v\017\006\009q\003+\004RD1\009?6#\021", "7drfQPJr"),
        Default = true,
        Callback = function(Z2mTETLK)
            VN772YQI.AutoSave.Enabled = Z2mTETLK
            VN772YQI:Notify({
                RJ8gM9Bb = _d("v\017\006\009q\003+\004R", "7drfQPJr"),
                Content = Z2mTETLK and _d("r\010\019\004=5.", "7drfQPJr") or _d("s\013\001\0073</\022", "7drfQPJr"),
                Type = Z2mTETLK and _d("d\017\017\0054#9", "7drfQPJr") or _d("`\005\000\0088>-", "7drfQPJr")
            })
        end
    })
    
    -- Dropdown List Config
    local GEKHFkfv = nil
    GEKHFkfv = NhsWKLS5:Dropdown({
        Text = _d("d\001\030\0032$j1X\010\020\0156", "7drfQPJr"),
        Options = VN772YQI:GetConfigs(), -- Ambil list file dari folder NexusUI
        Default = _d("d\001\030\0032$j1X\010\020\0156", "7drfQPJr"),
        Callback = function(_oFeDtVE)
            lkRtK0US = _oFeDtVE
        end
    })
    
    -- Tombol Refresh List (Berguna setelah save baru)
    NhsWKLS5:Button({
        Text = _d("e\001\020\0204#\"Rt\011\028\00087j>^\023\006", "7drfQPJr"),
        Callback = function()
            local CHTJbQAa = VN772YQI:GetConfigs()
            if GEKHFkfv then
                GEKHFkfv:SetOptions(CHTJbQAa)
            end
            VN772YQI:Notify({RJ8gM9Bb = _d("t\011\028\00087", "7drfQPJr"), Content = _d("{\013\001\018q\002/\020E\001\001\01444", "7drfQPJr"), Type = _d("~\010\020\009", "7drfQPJr")})
        end
    })
    
    -- Divider Visual
    NhsWKLS5:Label({Text = _d("v\007\006\015>>9RQ\011\000F\0025&\023T\016\023\002q\019%\028Q\013\021\\", "7drfQPJr"), Color = Color3.fromRGB(150, 150, 150)})
    
    -- Tombol Load
    NhsWKLS5:Button({
        Text = _d("{\011\019\002q\003/\030R\007\006\0035p\009\029Y\002\027\001", "7drfQPJr"),
        Callback = function()
            if not lkRtK0US or lkRtK0US == _d("d\001\030\0032$j1X\010\020\0156", "7drfQPJr") then 
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\0032$j\019\023\007\029\00879-RQ\013\000\021%q", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                return 
            end
            
            local QzH75oi8 = VN772YQI:LoadConfig(lkRtK0US)
            if QzH75oi8 then
                VN772YQI.AutoSave.ActiveConfig = X7QYBjSd
            end
            if QzH75oi8 then
                VN772YQI:Notify({RJ8gM9Bb = _d("t\011\028\00087", "7drfQPJr"), Content = _d("{\011\019\00244pR", "7drfQPJr") .. lkRtK0US, Type = _d("d\017\017\0054#9", "7drfQPJr")})
            else
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("{\011\019\002q\022+\027[\001\022", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
            end
        end
    })
    
    -- Tombol Overwrite (Timpa)
    NhsWKLS5:Button({
        Text = _d("x\018\023\020&\"#\006RD!\003=5)\006R\000", "7drfQPJr"),
        Callback = function()
            if not lkRtK0US or lkRtK0US == _d("d\001\030\0032$j1X\010\020\0156", "7drfQPJr") then 
                VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\0032$j\019\023\007\029\00879-RQ\013\000\021%q", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                return 
            end

            local QzH75oi8 = VN772YQI:SaveConfig(lkRtK0US)
            if QzH75oi8 then
                VN772YQI:Notify({
                    RJ8gM9Bb = _d("t\011\028\00087", "7drfQPJr"),
                    Content = _d("x\018\023\020&\"#\006C\001\028\\q", "7drfQPJr") .. lkRtK0US,
                    Type = _d("d\017\017\0054#9", "7drfQPJr")
                })
            else
                VN772YQI:Notify({
                    RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"),
                    Content = _d("x\018\023\020&\"#\006RD\020\0078</\022", "7drfQPJr"),
                    Type = _d("r\022\000\009#", "7drfQPJr")
                })
            end
        end
    })
    
    -- [[ BONUS: AUTO LOAD FEATURE ]]
    -- Mengecek apakah ada file penanda autoload
    local t_BRx4ly = false
    if isfile and isfile(_d("y\001\010\019\"\019%\028Q\013\021I0%>\029[\011\019\002\127$2\006", "7drfQPJr")) then
        t_BRx4ly = true
    end
    
    NhsWKLS5:Toggle({
        Text = _d("v\017\006\009q\028%\019SD!\003=5)\006R\000R\009?p\025\006V\022\006", "7drfQPJr"),
        Default = t_BRx4ly,
        Callback = function(Z2mTETLK)
            if Z2mTETLK then
                if lkRtK0US and lkRtK0US ~= _d("d\001\030\0032$j1X\010\020\0156", "7drfQPJr") then
                    writefile(_d("y\001\010\019\"\019%\028Q\013\021I0%>\029[\011\019\002\127$2\006", "7drfQPJr"), lkRtK0US)
                    VN772YQI:Notify({RJ8gM9Bb = _d("v\017\006\009q\028%\019S", "7drfQPJr"), Content = _d("d\001\006F%?pR", "7drfQPJr") .. lkRtK0US, Type = _d("d\017\017\0054#9", "7drfQPJr")})
                else
                    VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("d\001\030\0032$j\019\023\007\029\00879-RC\011R\007$$%\030X\005\022G", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                end
            else
                if isfile and isfile(_d("y\001\010\019\"\019%\028Q\013\021I0%>\029[\011\019\002\127$2\006", "7drfQPJr")) then
                    delfile(_d("y\001\010\019\"\019%\028Q\013\021I0%>\029[\011\019\002\127$2\006", "7drfQPJr"))
                end
                VN772YQI:Notify({RJ8gM9Bb = _d("v\017\006\009q\028%\019S", "7drfQPJr"), Content = _d("s\013\001\0073</\022", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
            end
        end
    })
    
    -- Logic Auto Load saat Script Jalan
    task.spawn(function()
        if t_BRx4ly and isfile and isfile(_d("y\001\010\019\"\019%\028Q\013\021I0%>\029[\011\019\002\127$2\006", "7drfQPJr")) then
            local n8sdayT8 = readfile(_d("y\001\010\019\"\019%\028Q\013\021I0%>\029[\011\019\002\127$2\006", "7drfQPJr"))
            if n8sdayT8 then
                task.wait(1) -- Tunggu UI loading selesai
                VN772YQI:LoadConfig(n8sdayT8)
                VN772YQI:Notify({RJ8gM9Bb = _d("v\017\006\009q\028%\019S", "7drfQPJr"), Content = _d("{\011\019\00244pR", "7drfQPJr") .. n8sdayT8, Type = _d("d\017\017\0054#9", "7drfQPJr")})
            end
        end
    end)
    
    pjPhTsIL:Toggle({
        Text = _d("s\013\001\0073</R\004 R44>.\023E\013\028\001qx\025\019A\001\000O", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            local qFuouMMH = LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr"))
            local bhq5hPyX = workspace.CurrentCamera
            
            if Z2mTETLK then
                -- Buat GUI Hitam
                if not bFjOnOVq then
                    bFjOnOVq = Instance.new(_d("d\007\000\0034>\013\007^", "7drfQPJr"))
                    bFjOnOVq.Name = _d("y4<9\0191)\025P\022\029\019?4", "7drfQPJr")
                    bFjOnOVq.IgnoreGuiInset = true
                    bFjOnOVq.DisplayOrder = -999  -- Paling atas
                    bFjOnOVq.Parent = qFuouMMH
                    
                    local uAM3uc21 = Instance.new(_d("q\022\019\0114", "7drfQPJr"), bFjOnOVq)
                    uAM3uc21.Size = UDim2.new(1, 0, 1, 0)
                    uAM3uc21.BackgroundColor3 = Color3.new(0, 0, 0)
                    uAM3uc21.BorderSizePixel = 0
                    
                    local Label = Instance.new(_d("c\001\010\018\0291(\023[", "7drfQPJr"), uAM3uc21)
                    Label.Size = UDim2.new(1, 0, 0.1, 0)
                    Label.Position = UDim2.new(0, 0, 0.1, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = _d("d\005\004\003#p\007\029S\001R\'2$#\004Rn \003?4/\000^\010\021F\02199\019U\008\023\002", "7drfQPJr")
                    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
                    Label.TextSize = 24
                    Label.Font = Enum.Font.GothamBold
                end
                
                bFjOnOVq.Enabled = true
                
                -- Pindahkan Kamera ke Void
                lavKikxp = bhq5hPyX.CameraType
                bhq5hPyX.CameraType = Enum.CameraType.Scriptable
                bhq5hPyX.CFrame = CFrame.new(0, 100000, 0)
                
                -- Matikan Rendering Engine (Jika executor support)
                pcall(function() bqYp_xry:Set3dRenderingEnabled(false) end)
                
                VN772YQI:Notify({RJ8gM9Bb = _d("d\005\004\003#p\007\029S\001", "7drfQPJr"), Content = _d("r\010\019\004=5.", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
            else
                -- Restore
                if lavKikxp then bhq5hPyX.CameraType = lavKikxp else bhq5hPyX.CameraType = Enum.CameraType.Custom end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(_d("\127\017\031\007??#\022", "7drfQPJr")) then
                    bhq5hPyX.CameraSubject = LocalPlayer.Character.Humanoid
                end
                
                if bFjOnOVq then bFjOnOVq.Enabled = false end
                
                pcall(function() bqYp_xry:Set3dRenderingEnabled(true) end)
                VN772YQI:Notify({RJ8gM9Bb = _d("d\005\004\003#p\007\029S\001", "7drfQPJr"), Content = _d("s\013\001\0073</\022", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
            end
        end
    })

    -- 2. FPS BOOST
    -- =========================================================
    -- FPS ULTRA BOOST (CPU & GPU SAVER)
    -- =========================================================
    pjPhTsIL:Toggle({
        Text = _d("q4!F\004<>\000VD0\009>#>", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            if Z2mTETLK then
                VN772YQI:Notify({RJ8gM9Bb = _d("q4!F\019?%\001C", "7drfQPJr"), Content = _d("g\022\029\0054#9\027Y\003\\H\127p\025\017E\001\023\008q=+\011\023\002\000\0034*/RD\008\027\0019$&\011\025", "7drfQPJr")})
                
                task.spawn(function()
                    -- 1. Optimasi Global Settings (Rendering)
                    local nwAG1biH = game:GetService(_d("{\013\021\014%9$\021", "7drfQPJr"))
                    local Terrain = workspace:WaitForChild(_d("c\001\000\02009$", "7drfQPJr"))
                    
                    pcall(function()
                        -- Matikan Shadow & Efek Cahaya
                        nwAG1biH.GlobalShadows = false
                        nwAG1biH.FogEnd = 9e9 -- Hapus kabut
                        nwAG1biH.Brightness = 0
                        
                        -- Hapus Efek Post-Processing (Blur, Bloom, SunRays)
                        for _, K_AAw11i in pairs(nwAG1biH:GetChildren()) do
                            if K_AAw11i:IsA(_d("g\011\001\018\0206,\023T\016", "7drfQPJr")) or K_AAw11i:IsA(_d("v\016\031\009\" \"\023E\001", "7drfQPJr")) or K_AAw11i:IsA(_d("d\015\011", "7drfQPJr")) then
                                K_AAw11i:Destroy()
                            end
                        end

                        -- Matikan Efek Air & Terrain
                        Terrain.WaterWaveSize = 0
                        Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0
                        Terrain.WaterTransparency = 0
                        settings().Rendering.QualityLevel = 1
                        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                    end)

                    -- 2. Optimasi Objek Workspace (Looping Cerdas)
                    -- Kita pakai wait() setiap 1000 part biar game gak crash/freeze total
                    local A33v9oSD = 0
                    for _, K_AAw11i in pairs(workspace:GetDescendants()) do
                        A33v9oSD = A33v9oSD + 1
                        if A33v9oSD % 1000 == 0 then task.wait() end -- Anti-Freeze

                        if K_AAw11i:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then
                            -- Ubah jadi plastik & hilangkan pantulan
                            K_AAw11i.Material = Enum.Material.SmoothPlastic
                            K_AAw11i.Reflectance = 0
                            K_AAw11i.CastShadow = false -- PENTING: Matikan bayangan per part
                            
                            -- Matikan Texture Terrain (Grass)
                            if K_AAw11i:IsA(_d("c\001\000\02009$", "7drfQPJr")) then 
                                K_AAw11i.Decoration = false 
                            end
                            
                        elseif K_AAw11i:IsA(_d("s\001\017\007=", "7drfQPJr")) or K_AAw11i:IsA(_d("c\001\010\018$\"/", "7drfQPJr")) then
                            -- Hapus gambar tempelan
                            K_AAw11i.Transparency = 1
                            
                        elseif K_AAw11i:IsA(_d("g\005\000\01883&\023r\009\027\018%58", "7drfQPJr")) or K_AAw11i:IsA(_d("c\022\019\015=", "7drfQPJr")) or K_AAw11i:IsA(_d("d\009\029\0134", "7drfQPJr")) or K_AAw11i:IsA(_d("q\013\000\003", "7drfQPJr")) or K_AAw11i:IsA(_d("d\020\019\020:</\001", "7drfQPJr")) then
                            -- Matikan efek partikel (Berat di GPU)
                            K_AAw11i.Enabled = false
                            
                        elseif K_AAw11i:IsA(_d("z\001\001\014\00118\006", "7drfQPJr")) then
                            -- Ubah material Mesh jadi halus
                            K_AAw11i.Material = Enum.Material.SmoothPlastic
                            K_AAw11i.Reflectance = 0
                            K_AAw11i.TextureID = _d("", "7drfQPJr") -- Hapus tekstur mesh (Opsional, bikin jadi abu-abu)
                        end
                    end
                    
                    VN772YQI:Notify({RJ8gM9Bb = _d("q4!F\019?%\001C", "7drfQPJr"), Content = _d("b\008\006\0200p\008\029X\023\006F\016 :\030^\001\022G", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
                end)
            else
                VN772YQI:Notify({RJ8gM9Bb = _d("q4!F\019?%\001C", "7drfQPJr"), Content = _d("e\001\024\0098>j\006XD\000\003\'58\006\023\007\026\007?7/\001\025", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
            end
        end
    })

    pjPhTsIL:Toggle({
        Text = _d("t4\'F\0021<\023EDZ #5/\008RD%\009#<.[", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            if Z2mTETLK then
                VN772YQI:Notify({RJ8gM9Bb = _d("t4\'F\0021<\023E", "7drfQPJr"), Content = _d("q\022\023\003+9$\021\0234\026\031\"9)\001\023BR%=5+\028^\010\021F\0188+\000V\007\006\003##d\\\025", "7drfQPJr")})
                
                task.spawn(function()
                    local LocalPlayer = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")).LocalPlayer
                    local pH4in6ME = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    
                    -- 1. BEKUKAN MAP (MATIKAN FISIKA)
                    -- Ini menghentikan kalkulasi gravitasi & collision untuk objek map
                    for _, K_AAw11i in pairs(workspace:GetDescendants()) do
                        -- Cek apakah object ini bagian dari Karakter Kita? (Jangan dibekukan)
                        if K_AAw11i:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) and not K_AAw11i:IsDescendantOf(pH4in6ME) then
                            K_AAw11i.Anchored = true 
                            K_AAw11i.CanTouch = false -- Matikan event .Touched (Hemat CPU banget)
                            
                            -- Opsional: Matikan CanCollide untuk object kecil biar gak nyangkut
                            if K_AAw11i.Size.Magnitude < 5 then
                                K_AAw11i.CanCollide = false
                            end
                        end
                    end

                    -- 2. HAPUS BEBAN KARAKTER LAIN (ENTITY OPTIMIZER)
                    for _, UX5vXCGH in pairs(game:GetService(_d("g\008\019\0314\"9", "7drfQPJr")):GetPlayers()) do
                        if UX5vXCGH ~= LocalPlayer and UX5vXCGH.Character then
                            local A7B8Wl9q = UX5vXCGH.Character
                            
                            -- Hapus Aksesoris (Sayap, Topi, Tas) -> Mengurangi Part Count
                            for _, acc in pairs(A7B8Wl9q:GetChildren()) do
                                if acc:IsA(_d("v\007\017\003\"#%\000N", "7drfQPJr")) or acc:IsA(_d("d\012\027\020%", "7drfQPJr")) or acc:IsA(_d("g\005\028\018\"", "7drfQPJr")) then
                                    acc:Destroy()
                                end
                            end
                            
                            -- Matikan Animasi Orang Lain (Berat di CPU)
                            local lYXfCKgl = A7B8Wl9q:FindFirstChild(_d("v\010\027\0110$/", "7drfQPJr"))
                            if lYXfCKgl then lYXfCKgl:Destroy() end
                            
                            -- Ubah jadi kotak polos (R6/R15 Simplified)
                            for _, part in pairs(A7B8Wl9q:GetChildren()) do
                                if part:IsA(_d("u\005\001\003\00118\006", "7drfQPJr")) then
                                    part.Material = Enum.Material.SmoothPlastic
                                    part.Reflectance = 0
                                end
                            end
                        end
                    end
                    
                    VN772YQI:Notify({RJ8gM9Bb = _d("t4\'F\0021<\023E", "7drfQPJr"), Content = _d("`\011\000\0105p\012\000X\030\023\008qvj7Y\016\027\018859Rt\008\023\007?5.S", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
                end)
            end
        end
    })

    local taOhCzay = false
    
    pjPhTsIL:Toggle({
        Text = _d("v\017\006\009q\019&\019^\009R68\"+\006RD6\009$2&\029X\010\001", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            taOhCzay = Z2mTETLK
            
            if Z2mTETLK then
                task.spawn(function()
                    local ye_80N42 = {
                        _d("v\008\027\003?p\007\023E\007\026\007?$", "7drfQPJr"), _d("u\013\030\010(p\008\029U", "7drfQPJr"), _d("d\001\006\014", "7drfQPJr"), _d("}\011\023", "7drfQPJr"), _d("v\017\000\007q\027#\022", "7drfQPJr"), 
                        _d("u\011\019\018q\0212\002R\022\006", "7drfQPJr"), _d("d\007\029\018%", "7drfQPJr"), _d("e\011\028", "7drfQPJr"), _d("}\001\020\0004\"3", "7drfQPJr"), _d("z\0070\0090$9\029Y", "7drfQPJr"), 
                        _d("d\007\027\003?$#\001C", "7drfQPJr"), _d("d\013\030\010(p\012\027D\012\023\020<1$", "7drfQPJr"), _d("c\013\031", "7drfQPJr"), _d("g\013\023\020#5", "7drfQPJr"), _d("g\012\027\008419", "7drfQPJr")
                    }
                    
                    -- 1. Cari Remote dengan Path Aman (Loop Search jika belum ketemu)
                    local ir8zQrDM = nil
                    local IdVsh1gi = 0
                    
                    while not ir8zQrDM and IdVsh1gi < 10 do
                        local tjedSwpw, MOAZubZT = pcall(function()
                            return game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
                                .Packages._Index[_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr")]
                                .net[_d("e\"]5!5)\027V\0086\0150<%\021B\0017\0164>>", "7drfQPJr")]
                        end)
                        if tjedSwpw and MOAZubZT then ir8zQrDM = MOAZubZT end
                        IdVsh1gi = IdVsh1gi + 1
                        task.wait(0.5)
                    end

                    if not ir8zQrDM then 
                        VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("e\001\031\009%5j5V\003\019\010q\020#\031B\005\006G", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                        taOhCzay = false
                        return
                    end

                    -- 2. Debug Status (Hanya muncul di F9 untuk konfirmasi)
                    warn(_d("l4;4\016\004\015/\0236\023\011>$/Rq\011\007\0085jj", "7drfQPJr") .. ir8zQrDM.Name .. _d("\023?", "7drfQPJr") .. ir8zQrDM.ClassName .. _d("j", "7drfQPJr"))

                    -- 3. Main Loop
                    while taOhCzay do
                        for _, npc in ipairs(ye_80N42) do
                            if not taOhCzay then break end
                            
                            -- Safe Execution: Cek apakah InvokeServer ada di object tersebut
                            pcall(function()
                                if ir8zQrDM.ClassName == _d("e\001\031\009%5\012\007Y\007\006\015>>", "7drfQPJr") then
                                    -- Coba string "PirateDoubloons" (Default)
                                    ir8zQrDM:InvokeServer(npc, _d("g\013\000\007%5\014\029B\006\030\009>>9", "7drfQPJr"))
                                    
                                    -- Opsional: Spam juga string lama/alternatif jaga-jaga
                                    -- Remote:InvokeServer(npc, "PirateGold") 
                                elseif ir8zQrDM.ClassName == _d("e\001\031\009%5\015\004R\010\006", "7drfQPJr") then
                                    ir8zQrDM:FireServer(npc, _d("g\013\000\007%5\014\029B\006\030\009>>9", "7drfQPJr"))
                                end
                            end)
                            
                            task.wait(0.1) -- Delay aman biar gak kena rate limit
                        end
                        task.wait(2.5) -- Loop ulang setiap 2.5 detik
                    end
                end)
                VN772YQI:Notify({RJ8gM9Bb = _d("g\013\000\007%5j7A\001\028\018", "7drfQPJr"), Content = _d("q\005\000\0118>-Rd\016\019\020%5.S", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
            else
                VN772YQI:Notify({RJ8gM9Bb = _d("g\013\000\007%5j7A\001\028\018", "7drfQPJr"), Content = _d("d\016\029\022!5.", "7drfQPJr"), Type = _d("~\010\020\009", "7drfQPJr")})
            end
        end
    })

    local sOfq6ij0 = {}
    local Fe9FOERD = nil
    local EuZrddvj = {}

    local function ccqhDbf9()
        if Fe9FOERD then return Fe9FOERD end
        
        local Screen = Instance.new(_d("d\007\000\0034>\013\007^", "7drfQPJr"))
        Screen.Name = _d("y4<9\002$+\006D4\019\0084<", "7drfQPJr")
        Screen.ResetOnSpawn = false
        pcall(function() Screen.Parent = tKV5dU5u end)
        if not Screen.Parent then Screen.Parent = LocalPlayer:WaitForChild(_d("g\008\019\0314\"\013\007^", "7drfQPJr")) end
        
        local A2zmufe_ = Instance.new(_d("q\022\019\0114", "7drfQPJr"), Screen)
        A2zmufe_.Size = UDim2.new(0, 190, 0, 65)
        A2zmufe_.Position = UDim2.new(0, 50, 0.5, -32)
        A2zmufe_.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        A2zmufe_.BackgroundTransparency = 0.2
        
        Instance.new(_d("b-1\009#>/\000", "7drfQPJr"), A2zmufe_).CornerRadius = UDim.new(0, 8)
        local pPALdgoo = Instance.new(_d("b-!\018#?!\023", "7drfQPJr"), A2zmufe_)
        pPALdgoo.Color = Color3.fromRGB(255, 140, 50)
        pPALdgoo.Thickness = 1.5
        pPALdgoo.Transparency = 0.4
        
        -- Header
        local kvdgRwTC = Instance.new(_d("q\022\019\0114", "7drfQPJr"), A2zmufe_)
        kvdgRwTC.Size = UDim2.new(1, 0, 0, 30)
        kvdgRwTC.BackgroundTransparency = 1
        
        local RJ8gM9Bb = Instance.new(_d("c\001\010\018\0291(\023[", "7drfQPJr"), kvdgRwTC)
        RJ8gM9Bb.Size = UDim2.new(1, -10, 1, 0)
        RJ8gM9Bb.Position = UDim2.new(0, 10, 0, 0)
        RJ8gM9Bb.BackgroundTransparency = 1
        RJ8gM9Bb.Text = _d("y4<F\025\005\008Rd032\002", "7drfQPJr")
        RJ8gM9Bb.TextColor3 = Color3.fromRGB(255, 140, 50)
        RJ8gM9Bb.TextSize = 12
        RJ8gM9Bb.Font = Enum.Font.GothamBold
        RJ8gM9Bb.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Content
        local PingLbl = Instance.new(_d("c\001\010\018\0291(\023[", "7drfQPJr"), A2zmufe_)
        PingLbl.Size = UDim2.new(0.5, -10, 0, 20)
        PingLbl.Position = UDim2.new(0, 10, 0, 35)
        PingLbl.BackgroundTransparency = 1
        PingLbl.Text = _d("g\013\028\001kpg_", "7drfQPJr")
        PingLbl.TextColor3 = Color3.new(1,1,1)
        PingLbl.Font = Enum.Font.GothamBold
        PingLbl.TextSize = 12
        PingLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local FpsLbl = Instance.new(_d("c\001\010\018\0291(\023[", "7drfQPJr"), A2zmufe_)
        FpsLbl.Size = UDim2.new(0.5, -10, 0, 20)
        FpsLbl.Position = UDim2.new(0.5, 0, 0, 35)
        FpsLbl.BackgroundTransparency = 1
        FpsLbl.Text = _d("q4!\\q}g", "7drfQPJr")
        FpsLbl.TextColor3 = Color3.new(1,1,1)
        FpsLbl.Font = Enum.Font.GothamBold
        FpsLbl.TextSize = 12
        FpsLbl.TextXAlignment = Enum.TextXAlignment.Right
        
        -- Drag Logic
        local CzSbsnEI, dragInput, dragStart, startPos
        A2zmufe_.InputBegan:Connect(function(cZPiq2L_)
            if cZPiq2L_.UserInputType == Enum.UserInputType.MouseButton1 then
                CzSbsnEI = true
                dragStart = cZPiq2L_.Position
                startPos = A2zmufe_.Position
            end
        end)
        A2zmufe_.InputChanged:Connect(function(cZPiq2L_)
            if cZPiq2L_.UserInputType == Enum.UserInputType.MouseMovement then dragInput = cZPiq2L_ end
        end)
        zEygNoja.InputChanged:Connect(function(cZPiq2L_)
            if cZPiq2L_ == dragInput and CzSbsnEI then
                local RJycGOuQ = cZPiq2L_.Position - dragStart
                A2zmufe_.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + RJycGOuQ.X, startPos.Y.Scale, startPos.Y.Offset + RJycGOuQ.Y)
            end
        end)
        zEygNoja.InputEnded:Connect(function(cZPiq2L_)
            if cZPiq2L_.UserInputType == Enum.UserInputType.MouseButton1 then CzSbsnEI = false end
        end)
        
        Fe9FOERD = {Screen = Screen, PingLbl = PingLbl, FpsLbl = FpsLbl}
        return Fe9FOERD
    end

    pjPhTsIL:Toggle({
        Text = _d("d\012\029\017q\000#\028PDTF\023\000\025Rg\005\028\003=", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            if Z2mTETLK then
                local CFj6QogP = ccqhDbf9()
                CFj6QogP.Screen.Enabled = true
                
                -- Update Loop
                local ISWakFKY = tick()
                local GVjqLfiP = bqYp_xry.RenderStepped:Connect(function()
                    local QGFUiqB6 = math.floor(1 / (tick() - ISWakFKY))
                    ISWakFKY = tick()
                    CFj6QogP.FpsLbl.Text = _d("q4!\\q", "7drfQPJr") .. QGFUiqB6
                    CFj6QogP.FpsLbl.TextColor3 = QGFUiqB6 > 50 and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
                end)
                
                local tKWdCGcU = bqYp_xry.Heartbeat:Connect(function()
                    local EOF2Z9QI = math.floor(LocalPlayer:GetNetworkPing() * 1000 * 2) -- Est. Ping
                    CFj6QogP.PingLbl.Text = _d("g\013\028\001kp", "7drfQPJr") .. EOF2Z9QI .. _d("Z\023", "7drfQPJr")
                    CFj6QogP.PingLbl.TextColor3 = EOF2Z9QI < 100 and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
                end)
                
                table.insert(EuZrddvj, GVjqLfiP)
                table.insert(EuZrddvj, tKWdCGcU)
                VN772YQI:Notify({RJ8gM9Bb = _d("g\005\028\003=", "7drfQPJr"), Content = _d("d\012\029\017?", "7drfQPJr")})
            else
                if Fe9FOERD then Fe9FOERD.Screen.Enabled = false end
                for _, PcEFQxK7 in pairs(EuZrddvj) do PcEFQxK7:Disconnect() end
                EuZrddvj = {}
                VN772YQI:Notify({RJ8gM9Bb = _d("g\005\028\003=", "7drfQPJr"), Content = _d("\127\013\022\0024>", "7drfQPJr")})
            end
        end
    })

    -- =========================================================
    -- STAFF DETECTOR
    -- =========================================================
    local RW34CFKq = ImYQkF7K:Collapsible(_d("d\001\017\019#9>\011\023L3\008%9g!C\005\020\000x", "7drfQPJr"))
    
    local vrjo0gGc = {40397833, 75974130} -- Tambah ID di sini
    local YvlyIHk_ = 121864768012064 
    local OuYDnyq6 = 200 
    
    local function hrxtLKpE(x6Sluij5)
        if table.find(vrjo0gGc, x6Sluij5.UserId) then return true end
        local tjedSwpw, rank = pcall(function() return x6Sluij5:GetRankInGroup(YvlyIHk_) end)
        if tjedSwpw and rank and rank >= OuYDnyq6 then return true end
        if x6Sluij5.Name:lower():find(_d("V\000\031\015?", "7drfQPJr")) or x6Sluij5.Name:lower():find(_d("Z\011\022", "7drfQPJr")) then return true end -- Optional
        return false
    end
    
    local BCG7_fpZ = nil
    
    RW34CFKq:Toggle({
        Text = _d("d\016\019\0007p\014\023C\001\017\018>\"jZv\017\006\009q\027#\017\\M", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            if Z2mTETLK then
                -- Cek existing players
                for _, x6Sluij5 in ipairs(game.Players:GetPlayers()) do
                    if x6Sluij5 ~= LocalPlayer and hrxtLKpE(x6Sluij5) then
                        LocalPlayer:Kick(_d("=?<6\031p\025\023T\017\000\015%)\023xd\016\019\0007p\014\023C\001\017\01844pR", "7drfQPJr") .. x6Sluij5.Name)
                    end
                end
                
                -- Cek new players
                BCG7_fpZ = game.Players.PlayerAdded:Connect(function(x6Sluij5)
                    if hrxtLKpE(x6Sluij5) then
                        LocalPlayer:Kick(_d("=?<6\031p\025\023T\017\000\015%)\023xd\016\019\0007p\014\023C\001\017\01844pR", "7drfQPJr") .. x6Sluij5.Name)
                    end
                end)
                VN772YQI:Notify({RJ8gM9Bb = _d("d\001\017\019#9>\011", "7drfQPJr"), Content = _d("z\011\028\015%?8\027Y\003R5%1,\020\025J\\", "7drfQPJr"), Type = _d("~\010\020\009", "7drfQPJr")})
            else
                if BCG7_fpZ then BCG7_fpZ:Disconnect() end
                VN772YQI:Notify({RJ8gM9Bb = _d("d\001\017\019#9>\011", "7drfQPJr"), Content = _d("s\013\001\0073</\022", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
            end
        end
    })
end

local mU66XurW = (function()
    -- [[ PASTE KODE MODULE ANDA DI SINI (SAYA SUDAH RAPIKAN SEDIKIT) ]]
    local uJLZPCTS = {}
    local Players = game:GetService(_d("g\008\019\0314\"9", "7drfQPJr"))
    local ReplicatedStorage = game:GetService(_d("e\001\002\01083+\006R\000!\018>\"+\021R", "7drfQPJr"))
    local Fq1IDzmg = game:GetService(_d("\127\016\006\022\00258\004^\007\023", "7drfQPJr"))
    local LocalPlayer = Players.LocalPlayer
    
    -- 1. FUNGSI PENCARI HTTP REQUEST (Supaya support semua Executor)
    local function C4OCnqxw()
        local adFeAl9e = {
            request,
            http_request,
            (syn and syn.request),
            (fluxus and fluxus.request),
            (http and http.request),
            (solara and solara.request)
        }
        
        for _, func in ipairs(adFeAl9e) do
            if func and type(func) == _d("Q\017\028\005%9%\028", "7drfQPJr") then
                return func
            end
        end
        return nil
    end

    local iAwP6jYZ = C4OCnqxw()

    -- 2. FUNGSI SEND (Menggunakan style kodemu)
    local function X_e3h4Qf(dMAB6eSj, username, embed_data, content_msg)
        -- Cek dulu apakah executor support
        if not iAwP6jYZ then
            return false, _d("r\028\023\005$$%\000\023\010\029\018q#?\002G\011\000\01844jZy\011R.\005\004\026Re\001\003\0194#>[", "7drfQPJr")
        end

        local fwrFJ6Wu = {
            username = username,
            content = content_msg or _d("", "7drfQPJr"), 
            embeds = {embed_data} 
        }
        
        local vNPskD2V = Fq1IDzmg:JSONEncode(fwrFJ6Wu)
        
        local QzH75oi8, response = pcall(function()
            return iAwP6jYZ({ -- Pakai variabel httpRequest yang sudah dicari di atas
                Url = dMAB6eSj,
                Method = _d("g+!2", "7drfQPJr"),
                Headers = { [_d("t\011\028\0184>>_c\029\002\003", "7drfQPJr")] = _d("V\020\002\01083+\006^\011\028I;#%\028", "7drfQPJr") },
                Body = vNPskD2V
            })
        end)
        
        if QzH75oi8 and response then
            -- 200 = OK, 204 = No Content (Sukses tapi ga ada balasan body, standar Discord)
            if response.StatusCode == 200 or response.StatusCode == 204 then
                return true, _d("d\001\028\018", "7drfQPJr")
            else
                return false, _d("q\005\027\01044pR", "7drfQPJr") .. tostring(response.StatusCode)
            end
        elseif not QzH75oi8 then
            return false, _d("r\022\000\009#jj", "7drfQPJr") .. tostring(response)
        end
        
        return false, _d("b\010\025\008>\'$Rr\022\000\009#", "7drfQPJr")
    end
    
    uJLZPCTS.Config = {
        WebhookURL = _d("", "7drfQPJr"),
        DiscordUserID = _d("", "7drfQPJr"),
        EnabledRarities = {}, -- Default kosong (semua mati)
    }

    local Items, Variants
    local xyCAty4N = {[1]=_d("t\011\031\011>>", "7drfQPJr"),[2]=_d("b\010\017\009<=%\028", "7drfQPJr"),[3]=_d("e\005\000\003", "7drfQPJr"),[4]=_d("r\020\027\005", "7drfQPJr"),[5]=_d("{\001\021\003?4+\000N", "7drfQPJr"),[6]=_d("z\029\006\01483", "7drfQPJr"),[7]=_d("d!14\020\004", "7drfQPJr")}
    local cQ3IZwUq = {[1]=9807270,[2]=3066993,[3]=3447003,[4]=10181046,[5]=15844367,[6]=15548997,[7]=16711680}
    local qs1mGNTI = false
    local PARAIyHw = nil

    local function WhBRAaCc()
        local QzH75oi8, err = pcall(function()
            -- Coba cari Items & Variants (Fisch/Fish It logic)
            if ReplicatedStorage:FindFirstChild(_d("~\016\023\011\"", "7drfQPJr")) then Items = require(ReplicatedStorage.Items) end
            if ReplicatedStorage:FindFirstChild(_d("a\005\000\0150>>\001", "7drfQPJr")) then Variants = require(ReplicatedStorage.Variants) end
        end)
        return QzH75oi8
    end

    local function FIhp0EVU(xEHpJ37g)
        if not xEHpJ37g then return _d("_\016\006\022\"je]^J\027\0116%8\\T\011\031Ii)\016\003q\021?H!>-", "7drfQPJr") end
        -- Fallback cepat tanpa API request biar tidak lag
        return string.format(_d("_\016\006\022\"je]C\022\\\0203()\022YJ\017\009<\127{J\007 3?|u9]\003VBIebz]~\009\019\0014\127\026\028P", "7drfQPJr"), tostring(xEHpJ37g))
    end

    local function Jx8OJp_3(EyC3EM17)
        local xEHpJ37g = nil
        if EyC3EM17.Data.Icon then xEHpJ37g = tostring(EyC3EM17.Data.Icon):match(_d("\018\000Y", "7drfQPJr"))
        elseif EyC3EM17.Data.ImageId then xEHpJ37g = tostring(EyC3EM17.Data.ImageId)
        elseif EyC3EM17.Data.Image then xEHpJ37g = tostring(EyC3EM17.Data.Image):match(_d("\018\000Y", "7drfQPJr")) end
        return FIhp0EVU(xEHpJ37g)
    end

    local function Xvc5_AU2(nTr3YXqa)
        if not Items then return nil end
        for _, f in pairs(Items) do if f.Data and f.Data.Id == nTr3YXqa then return f end end
    end

    local function DGSyEjE8(jzlOawB1)
        if not jzlOawB1 or not Variants then return nil end
        for _, K_AAw11i in pairs(Variants) do 
            if K_AAw11i.Data and (tostring(K_AAw11i.Data.Id) == tostring(jzlOawB1) or tostring(K_AAw11i.Data.Name) == tostring(jzlOawB1)) then return K_AAw11i end 
        end
        return nil
    end

    local function wXRdr2iG(EyC3EM17, meta, extra)
        if not uJLZPCTS.Config.WebhookURL or uJLZPCTS.Config.WebhookURL == _d("", "7drfQPJr") then return end
        
        local cJCQjZlq = xyCAty4N[EyC3EM17.Data.Tier] or _d("b\010\025\008>\'$", "7drfQPJr")
        local FIbaioyu = cQ3IZwUq[EyC3EM17.Data.Tier] or 3447003

        -- FILTER CHECK
        local WIlDqGay = false
        if #uJLZPCTS.Config.EnabledRarities > 0 then
            for _, Md_RPwqi in ipairs(uJLZPCTS.Config.EnabledRarities) do
                if Md_RPwqi == cJCQjZlq then WIlDqGay = true break end
            end
        else
            WIlDqGay = false -- Jika tidak ada rarity dipilih, jangan kirim apa-apa
        end
        if not WIlDqGay then return end

        local jf3u69XA = _d("y\011\028\003", "7drfQPJr")
        local MPErs3tU = EyC3EM17.SellPrice or 0
        local N7t2hM4d = (extra and (extra.Variant or extra.Mutation or extra.VariantId)) or (meta and (meta.Variant or meta.Mutation))
        local f27dcJfC = (meta and meta.Shiny) or (extra and extra.Shiny)

        if f27dcJfC then jf3u69XA = _d("d\012\027\008(", "7drfQPJr"); MPErs3tU = MPErs3tU * 2 end
        if N7t2hM4d then
            local K_AAw11i = DGSyEjE8(N7t2hM4d)
            if K_AAw11i then jf3u69XA = K_AAw11i.Data.Name .. _d("\023L", "7drfQPJr") .. K_AAw11i.SellMultiplier .. _d("OM", "7drfQPJr"); MPErs3tU = MPErs3tU * K_AAw11i.SellMultiplier
            else jf3u69XA = tostring(N7t2hM4d) end
        end

        local fwrFJ6Wu = {
            embeds = {{
                title = _d("\55307\57287R 8#\"Rt\005\007\0019$k", "7drfQPJr"),
                description = string.format(_d("b\023\023\020kp6\014\018\023\014\026[\024+\001\023\007\019\01968>RVDXLt#`X\023\002\027\0219q", "7drfQPJr"), LocalPlayer.Name, cJCQjZlq),
                FIbaioyu = FIbaioyu,
                fields = {
                    {name=_d("q\013\001\014q\030+\031R", "7drfQPJr"), dEnVjuuj=EyC3EM17.Data.Name, inline=true},
                    {name=_d("e\005\000\015%)", "7drfQPJr"), dEnVjuuj=cJCQjZlq, inline=true},
                    {name=_d("`\001\027\0019$", "7drfQPJr"), dEnVjuuj=string.format(_d("\018JC\000q;-", "7drfQPJr"), meta.Weight or 0), inline=true},
                    {name=_d("z\017\006\007%9%\028", "7drfQPJr"), dEnVjuuj=jf3u69XA, inline=true},
                    {name=_d("a\005\030\0194", "7drfQPJr"), dEnVjuuj=_d("\019", "7drfQPJr")..math.floor(MPErs3tU), inline=true}
                },
                thumbnail = { dMAB6eSj = Jx8OJp_3(EyC3EM17) },
                footer = { E1HO9OWN = _d("y\001\010\019\"p\029\023U\012\029\009:p\025\011D\016\023\011", "7drfQPJr") },
                yvyIdSfe = os.date(_d("\022A+Kt=gWS0W.ku\007H\0187(", "7drfQPJr"))
            }}
        }
        
        if uJLZPCTS.Config.DiscordUserID ~= _d("", "7drfQPJr") then
            fwrFJ6Wu.content = _d("\011$", "7drfQPJr")..uJLZPCTS.Config.DiscordUserID.._d("\009", "7drfQPJr")
        end

        pcall(function()
            iAwP6jYZ({
                Url = uJLZPCTS.Config.WebhookURL, Method = _d("g+!2", "7drfQPJr"),
                Headers = {[_d("t\011\028\0184>>_c\029\002\003", "7drfQPJr")] = _d("V\020\002\01083+\006^\011\028I;#%\028", "7drfQPJr")},
                Body = Fq1IDzmg:JSONEncode(fwrFJ6Wu)
            })
        end)
    end

    function uJLZPCTS:Start()
        if qs1mGNTI then return true end
        if not iAwP6jYZ then return false end
        WhBRAaCc()

        -- Cari Remote yang benar
        local QzH75oi8, Event = pcall(function()
            return ReplicatedStorage.Packages._Index[_d("D\008\023\015%>#\017\\;\028\003%\016z\\\005JB", "7drfQPJr")].net[_d("e!])3$+\027Y\001\022(4\'\012\027D\012<\009%9,\027T\005\006\015>>", "7drfQPJr")]
        end)

        if not QzH75oi8 or not Event then return false end

        PARAIyHw = Event.OnClientEvent:Connect(function(nTr3YXqa, Bkzly1ma, E1XSErmG)
            local EyC3EM17 = Xvc5_AU2(nTr3YXqa)
            if EyC3EM17 then task.spawn(function() wXRdr2iG(EyC3EM17, Bkzly1ma, E1XSErmG) end) end
        end)

        qs1mGNTI = true
        return true
    end

    function uJLZPCTS:Stop()
        if PARAIyHw then PARAIyHw:Disconnect() PARAIyHw = nil end
        qs1mGNTI = false
    end

    return uJLZPCTS
end)()

-- =================================================================
-- TAB: WEBHOOK UI IMPLEMENTATION (NEXUS UI)
-- =================================================================
do
    local G_vKTxm1 = Window:Tab({Text = _d("`\001\016\014>?!", "7drfQPJr"), Icon = _d("\55306\56454", "7drfQPJr")}) -- Icon Link
    local GHTwM7d2 = G_vKTxm1:Collapsible(_d("s\013\001\005>\".Rd\001\006\0188>-\001", "7drfQPJr"))

    -- 1. STATUS CHECK
    if not identifyexecutor then
        GHTwM7d2:Label({Text = _d("`\005\000\0088>-H\023!\010\0032%>\029ED\031\01568>RY\011\006F\"%:\002X\022\006F\025\004\030\"\0236\023\023$59\006DJ", "7drfQPJr"), Color = Color3.fromRGB(255, 100, 100)})
    end

    -- 2. URL INPUT
    GHTwM7d2:Input({
        Text = _d("`\001\016\014>?!Rb6>", "7drfQPJr"),
        Placeholder = _d("_\016\006\022\"je]S\013\001\005>\".\\T\011\031I0 #]@\001\016\014>?!\001\024J\\H", "7drfQPJr"),
        Callback = function(dMAB6eSj)
            mU66XurW.Config.WebhookURL = dMAB6eSj
        end
    })

    -- 3. USER ID INPUT
    GHTwM7d2:Input({
        Text = _d("s\013\001\005>\".Rb\023\023\020q\025\014R\031\"\029\020q\000#\028PM", "7drfQPJr"),
        Placeholder = _d("\006VARdf}J\014T", "7drfQPJr"),
        Callback = function(jzlOawB1)
            mU66XurW.Config.DiscordUserID = jzlOawB1
        end
    })

    -- 4. RARITY FILTER (MULTI SELECT)
    GHTwM7d2:Dropdown({
        Text = _d("d\001\030\0032$j V\022\027\018859RC\011R54>.", "7drfQPJr"),
        Options = {_d("t\011\031\011>>", "7drfQPJr"), _d("b\010\017\009<=%\028", "7drfQPJr"), _d("e\005\000\003", "7drfQPJr"), _d("r\020\027\005", "7drfQPJr"), _d("{\001\021\003?4+\000N", "7drfQPJr"), _d("z\029\006\01483", "7drfQPJr"), _d("d!14\020\004", "7drfQPJr")},
        MultiSelect = true,
        Default = {_d("{\001\021\003?4+\000N", "7drfQPJr"), _d("z\029\006\01483", "7drfQPJr"), _d("d!14\020\004", "7drfQPJr")}, -- Default yang mahal saja biar gak spam
        Callback = function(LrQXVklA)
            mU66XurW.Config.EnabledRarities = LrQXVklA or {}
        end
    })

    -- 5. ENABLE TOGGLE
    GHTwM7d2:Toggle({
        Text = _d("r\010\019\004=5j%R\006\026\009>;j<X\016\027\00083+\006^\011\028", "7drfQPJr"),
        Default = false,
        Callback = function(Z2mTETLK)
            if Z2mTETLK then
                if mU66XurW.Config.WebhookURL == _d("", "7drfQPJr") then
                    VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("z\005\001\019:;+\028\0233\023\0049?%\025\0231 *q$/\000[\001\016\0159p.\019_\017\030\019p", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                    -- Secara visual toggle mungkin tetap nyala, tapi logic tidak jalan
                    return
                end
                
                local hQzkCCYB = mU66XurW:Start()
                if hQzkCCYB then
                    VN772YQI:Notify({RJ8gM9Bb = _d("`\001\016\014>?!", "7drfQPJr"), Content = _d("d\001\000\01683/Rd\016\019\020%5.S", "7drfQPJr"), Type = _d("d\017\017\0054#9", "7drfQPJr")})
                else
                    VN772YQI:Notify({RJ8gM9Bb = _d("r\022\000\009#", "7drfQPJr"), Content = _d("p\005\021\007=p\'\023Z\017\030\0078p9\023E\018\027\0054pb R\009\029\0184p$\029CD\020\009$>.R\024D7\03043j\028X\016R\021$ :\029E\016[", "7drfQPJr"), Type = _d("r\022\000\009#", "7drfQPJr")})
                end
            else
                mU66XurW:Stop()
                VN772YQI:Notify({RJ8gM9Bb = _d("`\001\016\014>?!", "7drfQPJr"), Content = _d("d\001\000\01683/Rd\016\029\022!5.", "7drfQPJr"), Type = _d("`\005\000\0088>-", "7drfQPJr")})
            end
        end
    })
    
    -- 6. TEST BUTTON
    GHTwM7d2:Button({
        Text = _d("c\001\001\018q\007/\016_\011\029\013qx\012\019\\\001R\"0$+[", "7drfQPJr"),
        Callback = function()
             if mU66XurW.Config.WebhookURL == _d("", "7drfQPJr") then
                VN772YQI:Notify({RJ8gM9Bb=_d("r\022\000\009#", "7drfQPJr"), Content=_d("y\011R3\003\028j\"E\011\004\01555.", "7drfQPJr"), Type=_d("r\022\000\009#", "7drfQPJr")})
                return
            end
            
            -- Kirim test ping manual
            local Fq1IDzmg = game:GetService(_d("\127\016\006\022\00258\004^\007\023", "7drfQPJr"))
            local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            if request then
                request({
                    Url = mU66XurW.Config.WebhookURL,
                    Method = _d("g+!2", "7drfQPJr"),
                    Headers = {[_d("t\011\028\0184>>_c\029\002\003", "7drfQPJr")] = _d("V\020\002\01083+\006^\011\028I;#%\028", "7drfQPJr")},
                    Body = Fq1IDzmg:JSONEncode({
                        content = _d("\55306\56688RL{\004/\001CD<\009%9,\027T\005\006\015>>j\020E\011\031F\03152\007DD:\0193z`x`\001\016\014>?!R^\023R\017>\"!\027Y\003R\005>\"8\023T\016\030\031p", "7drfQPJr")
                    })
                })
                VN772YQI:Notify({RJ8gM9Bb=_d("d\001\028\018", "7drfQPJr"), Content=_d("t\012\023\005:p3\029B\022R\0028#)\029E\000S", "7drfQPJr"), Type=_d("d\017\017\0054#9", "7drfQPJr")})
            else
                VN772YQI:Notify({RJ8gM9Bb=_d("r\022\000\009#", "7drfQPJr"), Content=_d("r\028\023\005$$%\000\023\010\029\018q#?\002G\011\000\01844", "7drfQPJr"), Type=_d("r\022\000\009#", "7drfQPJr")})
            end
        end
    })
end