local GuiLibrary = shared.GuiLibrary
local players = game:GetService("Players")
local lplayer = players.LocalPlayer
local runService = game:GetService("RunService")

if not GuiLibrary then return end

local AuraModule = {Enabled = false}
local AuraRange = {Value = 15}

local AuraButton = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
    Name = "Aura Ext",
    Function = function(callback)
        AuraModule.Enabled = callback
        if AuraModule.Enabled then
            task.spawn(function()
                while AuraModule.Enabled do
                    task.wait(0.1)
                    
                    if not lplayer.Character or not lplayer.Character:FindFirstChild("HumanoidRootPart") then continue end
                    
                    for _, v in pairs(players:GetPlayers()) do
                        if v ~= lplayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                            local distance = (lplayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            
                            if distance <= AuraRange.Value then
                                -- Core attack logic placement. This requires the specific game's remote.
                                -- e.g., game:GetService("ReplicatedStorage").MeleeRemote:FireServer(v.Character)
                            end
                        end
                    end
                end
            end)
        end
    end,
    HoverText = "Extended Aura module."
})

AuraRange = AuraButton.CreateSlider({
    Name = "Range",
    Min = 5,
    Max = 30,
    Function = function(val) end,
    Default = 15,
    HoverText = "Attack range in studs."
})
