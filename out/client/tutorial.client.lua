-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local TweenService = _services.TweenService
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local getCurrentArea = _utils.getCurrentArea
local isClientCube = _utils.isClientCube
local tweenTypes = _utils.tweenTypes
local Events = {
	PlayTutorial = ReplicatedStorage:WaitForChild("PlayTutorial"),
	EndTutorial = ReplicatedStorage:WaitForChild("EndTutorial"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local flippedGravity = ReplicatedStorage:WaitForChild("flipped_gravity")
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
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if not _result then
		return nil
	end
	local area = getCurrentArea(cube)
	if area ~= "Tutorial" then
		flippedGravity.Value = false
		Events.PlayTutorial:FireServer()
		player:SetAttribute("finished", nil)
		shadow.BackgroundTransparency = 0
		TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1,
		}):Play()
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
