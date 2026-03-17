local GuiLibrary = shared.GuiLibrary
if not GuiLibrary then return end

-- Create a new Custom Tab/Window in Vape
local CustomWindow = GuiLibrary.CreateCustomWindow({
    Name = "XUxa Tab",
    Icon = "rbxassetid://10888331510",
    IconSize = 16
})

local players = game:GetService("Players")
local lplayer = players.LocalPlayer

-- Custom Module 1: Aura
local AuraExtension = {Enabled = false}
local AuraRange = {Value = 15}

local AuraButton = CustomWindow.CreateOptionsButton({
    Name = "Aura Ext",
    Function = function(callback)
        AuraExtension.Enabled = callback
        if AuraExtension.Enabled then
            task.spawn(function()
                while AuraExtension.Enabled do
                    task.wait(0.1)
                    if not lplayer.Character or not lplayer.Character:FindFirstChild("HumanoidRootPart") then continue end
                    
                    for _, v in pairs(players:GetPlayers()) do
                        if v ~= lplayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                            local distance = (lplayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            
                            if distance <= AuraRange.Value then
                                -- Core attack logic
                                -- Insert appropriate Remote Event Here
                            end
                        end
                    end
                end
            end)
        end
    end,
    HoverText = "Extended Combat Aura"
})

AuraRange = AuraButton.CreateSlider({
    Name = "Range",
    Min = 5,
    Max = 30,
    Function = function(val) end,
    Default = 15
})

-- Custom Module 2: Velocity
local VelocityExt = {Enabled = false}
local VelocityMultiplier = {Value = 1}

local VelocityButton = CustomWindow.CreateOptionsButton({
    Name = "Velocity Ext",
    Function = function(callback)
        VelocityExt.Enabled = callback
        if VelocityExt.Enabled then
            task.spawn(function()
                while VelocityExt.Enabled do
                    task.wait(0.1)
                    if lplayer.Character and lplayer.Character:FindFirstChild("HumanoidRootPart") then
                         lplayer.Character.HumanoidRootPart.Velocity = lplayer.Character.HumanoidRootPart.Velocity * VelocityMultiplier.Value
                    end
                end
            end)
        end
    end,
    HoverText = "Modifies character velocity."
})

VelocityMultiplier = VelocityButton.CreateSlider({
    Name = "Multiplier",
    Min = 1,
    Max = 5,
    Function = function(val) end,
    Default = 2
})
