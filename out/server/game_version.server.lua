-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local isTestingServer = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").isTestingServer
local placeVersion = ReplicatedStorage:FindFirstChild("PlaceVersion")
if isTestingServer() then
	placeVersion.Value = -2
else
	placeVersion.Value = game.PlaceVersion
end
