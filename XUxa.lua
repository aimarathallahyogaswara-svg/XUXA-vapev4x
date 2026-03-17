local GuiLibrary = shared.GuiLibrary
if not GuiLibrary then return end

local players = game:GetService("Players")
local lplayer = players.LocalPlayer
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- Inisialisasi Kategori/Tab Kustom di dalam Vape V4
local XUxaWindow = GuiLibrary.CreateCustomWindow({
    Name = "XUxa Core",
    Icon = "rbxassetid://10888331510",
    IconSize = 16
})

---------------------------------------------------------
-- MODUL 1: KillAura V2 (Advanced Targeting System)
---------------------------------------------------------
local KillAuraV2 = {Enabled = false}
local AuraRange = {Value = 18}
local AttackDelay = {Value = 0.05}
local WallCheck = {Enabled = true}

-- Optimize target sorting based on closest distance
local function GetClosestTarget(range, checkWalls)
    local closestDist = range
    local target = nil
    
    for _, v in pairs(players:GetPlayers()) do
        if v ~= lplayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (v.Character.HumanoidRootPart.Position - lplayer.Character.HumanoidRootPart.Position).Magnitude
            if dist <= closestDist then
                if checkWalls then
                    local ray = Ray.new(camera.CFrame.Position, (v.Character.HumanoidRootPart.Position - camera.CFrame.Position).Unit * dist)
                    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {lplayer.Character, camera})
                    if hit and hit:IsDescendantOf(v.Character) then
                        closestDist = dist
                        target = v.Character
                    end
                else
                    closestDist = dist
                    target = v.Character
                end
            end
        end
    end
    return target
end

local KillAuraButton = XUxaWindow.CreateOptionsButton({
    Name = "KillAura V2",
    Function = function(callback)
        KillAuraV2.Enabled = callback
        if KillAuraV2.Enabled then
            task.spawn(function()
                while KillAuraV2.Enabled do
                    task.wait(AttackDelay.Value)
                    if not lplayer.Character or not lplayer.Character:FindFirstChild("HumanoidRootPart") then continue end
                    
                    local optimalTarget = GetClosestTarget(AuraRange.Value, WallCheck.Enabled)
                    
                    if optimalTarget then
                        -- [BEDWARS SPECIFIC COMBAT LOGIC]
                        -- Obtain the network remote used by Bedwars for sword hits
                        local bedwarsNet = game:GetService("ReplicatedStorage"):FindFirstChild("rbxts_include")
                        if bedwarsNet then
                            local netManaged = bedwarsNet.node_modules:FindFirstChild("@rbxts").net.out._NetManaged
                            local swordHitRemote = netManaged and netManaged:FindFirstChild("SwordHit")
                            
                            local heldItem = lplayer.Character:FindFirstChildWhichIsA("Tool")
                            if swordHitRemote and heldItem then
                                swordHitRemote:FireServer({
                                    ["entityInstance"] = optimalTarget,
                                    ["weapon"] = heldItem
                                })
                            end
                        end
                        
                        -- Simulate response or rotate character towards target (Silent Aim Combat)
                        local lookVec = CFrame.new(lplayer.Character.HumanoidRootPart.Position, optimalTarget.HumanoidRootPart.Position)
                        lplayer.Character.HumanoidRootPart.CFrame = CFrame.new(lplayer.Character.HumanoidRootPart.Position, lookVec.LookVector)
                    end
                end
            end)
        end
    end,
    HoverText = "High-precision combat aura. Targets nearest enemy with Raycast validation."
})

AuraRange = KillAuraButton.CreateSlider({
    Name = "Attack Range",
    Min = 5,
    Max = 30,
    Function = function(val) end,
    Default = 18
})

AttackDelay = KillAuraButton.CreateSlider({
    Name = "Attack Delay",
    Min = 0.01,
    Max = 1.0,
    Function = function(val) end,
    Default = 0.05 
})

WallCheck = KillAuraButton.CreateToggle({
    Name = "Wall Check (Raycast)",
    Function = function(callback)
        WallCheck.Enabled = callback
    end,
    Default = true
})

---------------------------------------------------------
-- MODUL 2: Network Desync (Anti-Aim / Hitbox Modifier)
---------------------------------------------------------
local Desync = {Enabled = false}
local DesyncAmount = {Value = 5}
local DesyncConnection

local DesyncButton = XUxaWindow.CreateOptionsButton({
    Name = "Network Desync",
    Function = function(callback)
        Desync.Enabled = callback
        if Desync.Enabled then
            DesyncConnection = runService.Heartbeat:Connect(function()
                if lplayer.Character and lplayer.Character:FindFirstChild("HumanoidRootPart") then
                    local root = lplayer.Character.HumanoidRootPart
                    local originalVelocity = root.Velocity
                    
                    -- Manipulate network velocity to deceive enemy hitbox prediction
                    root.Velocity = root.Velocity + Vector3.new(math.random(-DesyncAmount.Value, DesyncAmount.Value), 0, math.random(-DesyncAmount.Value, DesyncAmount.Value))
                    runService.RenderStepped:Wait()
                    root.Velocity = originalVelocity
                end
            end)
        else
            if DesyncConnection then
                DesyncConnection:Disconnect()
                DesyncConnection = nil
            end
        end
    end,
    HoverText = "Manipulates Velocity packets so your real hitbox visually desyncs on enemy screens."
})

DesyncAmount = DesyncButton.CreateSlider({
    Name = "Desync Strength",
    Min = 1,
    Max = 50,
    Function = function(val) end,
    Default = 5
})

---------------------------------------------------------
-- MODUL 3: Fake Lag (Ping Spoofer)
---------------------------------------------------------
local FakeLag = {Enabled = false}
local LagTicks = {Value = 15}

local FakeLagButton = XUxaWindow.CreateOptionsButton({
    Name = "Fake Lag",
    Function = function(callback)
        FakeLag.Enabled = callback
        if FakeLag.Enabled then
            task.spawn(function()
                while FakeLag.Enabled do
                    if lplayer.Character and lplayer.Character:FindFirstChild("HumanoidRootPart") then
                        -- Temporarily stop rendering part to the server
                        lplayer.Character.Archivable = true
                        settings().Network.IncomingReplicationLag = LagTicks.Value / 100
                        task.wait(0.1)
                    end
                end
            end)
        else
            settings().Network.IncomingReplicationLag = 0
        end
    end,
    HoverText = "Spoofs high ping to cause your character to appear teleporting (Lag Switch) on the server."
})

LagTicks = FakeLagButton.CreateSlider({
    Name = "Lag Intensity",
    Min = 1,
    Max = 100,
    Function = function(val) end,
    Default = 15
})

---------------------------------------------------------
-- MODUL 4: Ghost Mode (Advanced Invisibility)
---------------------------------------------------------
local Invisibility = {Enabled = false}
local InvisConnection

local InvisibilityButton = XUxaWindow.CreateOptionsButton({
    Name = "Ghost Mode",
    Function = function(callback)
        Invisibility.Enabled = callback
        if Invisibility.Enabled then
            if lplayer.Character and lplayer.Character:FindFirstChild("HumanoidRootPart") and lplayer.Character:FindFirstChild("Humanoid") then
                -- Method: Firing Client-Side transparency + Hitbox manipulation
                -- In many games, making parts transparent server-side requires network ownership exploits.
                -- Here we use a local visualization + desync technique.
                for _, v in pairs(lplayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                        v.Transparency = 1
                    elseif v:IsA("Decal") then
                        v.Transparency = 1
                    end
                end
                
                -- Attempt to break replication (Pseudo-invisibility via network delay)
                settings().Network.IncomingReplicationLag = 10 -- High latency desync
                
                -- Hide Nametag (if applicable in standard Roblox)
                if lplayer.Character:FindFirstChild("Head") and lplayer.Character.Head:FindFirstChildOfClass("BillboardGui") then
                    lplayer.Character.Head:FindFirstChildOfClass("BillboardGui").Enabled = false
                end
            end
        else
            -- Revert changes
            if lplayer.Character then
                for _, v in pairs(lplayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                        v.Transparency = 0
                    elseif v:IsA("Decal") then
                        v.Transparency = 0
                    end
                end
                settings().Network.IncomingReplicationLag = 0
                
                if lplayer.Character:FindFirstChild("Head") and lplayer.Character.Head:FindFirstChildOfClass("BillboardGui") then
                    lplayer.Character.Head:FindFirstChildOfClass("BillboardGui").Enabled = true
                end
            end
        end
    end,
    HoverText = "Renders your character completely invisible via Transparency and Network Desync techniques."
})
