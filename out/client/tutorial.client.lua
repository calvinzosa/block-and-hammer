-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Players = _services.Players
local TweenService = _services.TweenService
local Workspace = _services.Workspace
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local computeNameColor = _utils.computeNameColor
local getTime = _utils.getTime
local isClientCube = _utils.isClientCube
local PlayerAttributes = _utils.PlayerAttributes
local tweenTypes = _utils.tweenTypes
local Events = {
	PlayTutorial = ReplicatedStorage:WaitForChild("PlayTutorial"),
	EndTutorial = ReplicatedStorage:WaitForChild("EndTutorial"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local mapFolder = Workspace:WaitForChild("Map")
local tutorialFolder = mapFolder:WaitForChild("Tutorial")
local orb = tutorialFolder:WaitForChild("Orb")
local cubeTemplate = ReplicatedStorage:WaitForChild("Cube")
local valueInstances = GUI:WaitForChild("Values")
local canMove = valueInstances:WaitForChild("can_move")
local screenGui = GUI:WaitForChild("ScreenGui")
local tutorialGui = screenGui:WaitForChild("TutorialGUI")
local shadow = screenGui:WaitForChild("Shadow")
local function start()
	tutorialGui.Visible = false
	canMove.Value = true
	local _value = player:GetAttribute(PlayerAttributes.InTutorial)
	if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
		Events.PlayTutorial:FireServer()
		player:SetAttribute("finished", nil)
		shadow.BackgroundTransparency = 0
		TweenService:Create(shadow, tweenTypes.linear.short, {
			BackgroundTransparency = 1,
		}):Play()
		task.wait(1)
		local cube = cubeTemplate:Clone()
		cube:PivotTo(CFrame.new(2532, 10, 0))
		cube.Name = `cube{player.UserId}`
		cube.Color = computeNameColor(player.Name)
		cube:SetAttribute("start_time", getTime())
		local overheadGui = cube:WaitForChild("OverheadGUI")
		local usernameLabel = overheadGui:WaitForChild("Username")
		local icons = overheadGui:WaitForChild("Icons")
		usernameLabel.Text = `{player.DisplayName} (@{player.Name})`
		icons.Visible = false
		cube.Parent = Workspace
	end
end
Events.StartClientTutorial.Event:Connect(start);
(tutorialGui:WaitForChild("Yes")).MouseButton1Click:Connect(start)
orb.Touched:Connect(function(otherPart)
	if isClientCube(otherPart) then
		Events.EndTutorial:FireServer(true)
		otherPart:Destroy()
		shadow.BackgroundTransparency = 0
		TweenService:Create(shadow, tweenTypes.linear.short, {
			BackgroundTransparency = 1,
		}):Play()
	end
end)
