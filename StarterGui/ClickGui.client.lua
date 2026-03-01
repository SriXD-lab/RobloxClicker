local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local clickEvent = ReplicatedStorage:WaitForChild("ClickEvent")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.fromOffset(220, 80)
clickButton.Position = UDim2.new(0.5, -110, 1, -180)
clickButton.Text = "Click"
clickButton.TextScaled = true
clickButton.Parent = screenGui

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Size = UDim2.fromOffset(220, 60)
rebirthButton.Position = UDim2.new(0.5, -110, 1, -90)
rebirthButton.Text = "Rebirth (100 Clicks)"
rebirthButton.TextScaled = true
rebirthButton.Parent = screenGui

clickButton.MouseButton1Click:Connect(function()
	clickEvent:FireServer()
end)

rebirthButton.MouseButton1Click:Connect(function()
	clickEvent:FireServer("Rebirth")
end)
