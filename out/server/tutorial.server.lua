-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Workspace = _services.Workspace
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local PlayerAttributes = _utils.PlayerAttributes
local giveBadge = _utils.giveBadge
local Events = {
	PlayTutorial = ReplicatedStorage:WaitForChild("PlayTutorial"),
	EndTutorial = ReplicatedStorage:WaitForChild("EndTutorial"),
	ForceReset = ReplicatedStorage:WaitForChild("ForceReset"),
}
Events.PlayTutorial.OnServerEvent:Connect(function(player)
	player:SetAttribute(PlayerAttributes.InTutorial, true)
	local _result = Workspace:FindFirstChild(`cube{player.UserId}`)
	if _result ~= nil then
		_result:Destroy()
	end
end)
Events.EndTutorial.OnServerEvent:Connect(function(player, reachedEnd)
	player:SetAttribute(PlayerAttributes.InTutorial, nil)
	Events.ForceReset:Fire(player, true)
	if reachedEnd ~= 0 and reachedEnd == reachedEnd and reachedEnd ~= "" and reachedEnd then
		giveBadge(player, 2146706248)
	end
end)
