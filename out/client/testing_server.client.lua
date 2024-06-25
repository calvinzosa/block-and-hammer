-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local isTestingServer = _utils.isTestingServer
local isMainServer = _utils.isMainServer
local GameData = _utils.GameData
local player = Players.LocalPlayer
local serverOwnerId = ReplicatedStorage:WaitForChild("PrivateServerOwnerId")
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local mainMenuGui = GUI:WaitForChild("MainMenuGui")
local testingServerGui = GUI:WaitForChild("TestingServerGui")
if serverOwnerId.Value == 0 then
	serverOwnerId.Changed:Wait()
end
if isMainServer() then
	print("[src/client/testing_server.client.ts:25]", "Server Type: Main")
	if serverOwnerId.Value == GameData.CreatorId then
		testingServerGui.Enabled = true
		mainMenuGui.Enabled = false
		screenGui.Enabled = false
	end
elseif isTestingServer() then
	print("[src/client/testing_server.client.ts:33]", "Server Type: Testing")
	local button = screenGui:WaitForChild("TestingServerWarning")
	button.Visible = true
	button.MouseButton1Click:Once(function()
		button.Visible = false
		return button.Visible
	end)
end
