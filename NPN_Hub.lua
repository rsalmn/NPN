    --============================================================
    -- BLATANT V4 — PERFECT ENGINE BASED ON V2 (GUARANTEED WORK)
    --============================================================
    local v4Section = farm:Section({
        Title = "Blatant V4 (Stable Advanced)",
        TextSize = 20
    })

    local v4Active = false
    local v4Loop = nil
    local v4EquipLoop = nil

    -- DEFAULT SETTINGS
    local V4_DELAY = 1.25
    local V4_CATCH_DELAY = 2.2
    local V4_COMPLETE_DELAY = 0.22


    ---------------------------------------------------------
    -- UI
    ---------------------------------------------------------
    Reg("v4delay", v4Section:Input({
        Title = "Blatant V4 Delay",
        Value = tostring(V4_DELAY),
        Placeholder = "1.25",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0.3 then
                V4_DELAY = n
            end
        end
    }))

    Reg("v4catch", v4Section:Input({
        Title = "Catch Delay",
        Value = tostring(V4_CATCH_DELAY),
        Placeholder = "2.2",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0.5 then
                V4_CATCH_DELAY = n
            end
        end
    }))

    Reg("v4comp", v4Section:Input({
        Title = "Completely Delay",
        Value = tostring(V4_COMPLETE_DELAY),
        Placeholder = "0.22",
        Callback = function(v)
            local n = tonumber(v)
            if n and n >= 0.05 then
                V4_COMPLETE_DELAY = n
            end
        end
    }))


    ---------------------------------------------------------
    -- AUTO EQUIP
    ---------------------------------------------------------
    local function StartV4Equip()
        v4EquipLoop = task.spawn(function()
            while v4Active do
                pcall(function()
                    RE_EquipToolFromHotbar:FireServer(1)
                end)
                task.wait(0.08)
            end
        end)
    end


    ---------------------------------------------------------
    -- THROW ENGINE (COPY STYLE V2 — 100% VALID)
    ---------------------------------------------------------
    local function V4Throw()
        task.spawn(function()
            local timestamp = os.time() + os.clock()

            -- charge
            pcall(function()
                RF_ChargeFishingRod:InvokeServer(timestamp)
            end)

            task.wait(0.01)

            -- start mini-game (PERSIS DARI KODE KAMU SENDIRI)
            pcall(function()
                RF_RequestFishingMinigameStarted:InvokeServer(-139.6379699707, 0.99647927980797)
            end)
        end)
    end


    ---------------------------------------------------------
    -- FULL FISHING CYCLE (ENGINE V2)
    ---------------------------------------------------------
    local function V4Cycle()
        task.spawn(function()

            -- tunggu seolah sedang mempermainkan minigame agar server percaya
            task.wait(V4_CATCH_DELAY)

            -- fishing complete
            pcall(function()
                RE_FishingCompleted:FireServer()
            end)

            task.wait(V4_COMPLETE_DELAY)

            -- cancel inputs
            pcall(function()
                RF_CancelFishingInputs:InvokeServer()
            end)

            -- langsung lempar ulang cepat
            task.wait(0.05)
            V4Throw()
        end)
    end


    ---------------------------------------------------------
    -- MAIN LOOP
    ---------------------------------------------------------
    local function StartV4Loop()
        v4Loop = task.spawn(function()
            while v4Active do
                V4Cycle()
                task.wait(V4_DELAY)
            end
        end)
    end


    ---------------------------------------------------------
    -- TOGGLE
    ---------------------------------------------------------
    Reg("v4toggle", v4Section:Toggle({
        Title = "Enable Blatant V4",
        Value = false,
        Callback = function(state)
            StopNotifListener()
            if not checkFishingRemotes() then
                WindUI:Notify({
                    Title = "V4 Failed",
                    Content = "Fishing Remotes Missing",
                    Duration = 3
                })
                return
            end

            v4Active = state

            if state then
                
                ------------- MATIKAN MODE LAIN -------------
                if normal ~= nil then normal=false end
                if blatantInstantState ~= nil then blatantInstantState=false end
                if v3Active ~= nil then v3Active=false end
                if v3proActive ~= nil then v3proActive=false end
                if hyperActive ~= nil then hyperActive=false end
                if SetBlatantState then SetBlatantState(false) end


                ------------- START ENGINE -------------
                StartV4Equip()
                StartV4Loop()

                ---------- DOUBLE CAST REAL ----------
                V4Throw()
                task.wait(0.1)
                V4Throw()

                WindUI:Notify({
                    Title="Blatant V4 ON",
                    Content="Stable Advanced Engine Running",
                    Duration=4,
                    Icon="zap"
                })

            else
                v4Active = false

                if v4Loop then task.cancel(v4Loop) v4Loop=nil end
                if v4EquipLoop then task.cancel(v4EquipLoop) v4EquipLoop=nil end

                pcall(function()
                    RF_UpdateAutoFishingState:InvokeServer(false)
                end)

                WindUI:Notify({
                    Title="V4 Stopped",
                    Duration=2
                })
            end
        end
    }))
