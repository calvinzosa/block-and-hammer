-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Workspace = _services.Workspace
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local giveBadge = _utils.giveBadge
local Badge = _utils.Badge
local Events = {
	PlayTutorial = ReplicatedStorage:WaitForChild("PlayTutorial"),
	EndTutorial = ReplicatedStorage:WaitForChild("EndTutorial"),
	ForceReset = ReplicatedStorage:WaitForChild("ForceReset"),
}
local mapFolder = Workspace:FindFirstChild("Map")
local tutorialFolder = mapFolder:FindFirstChild("Tutorial")
local tutorialSpawn = tutorialFolder:FindFirstChild("SpawnLocation")
Events.PlayTutorial.OnServerEvent:Connect(function(player)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if _result then
		cube:Destroy()
		Events.ForceReset:Fire(player, true)
		local newCube = Workspace:WaitForChild(`cube{player.UserId}`)
		if newCube:IsA("BasePart") then
			local _fn = newCube
			local _cFrame = tutorialSpawn.CFrame
			local _cFrame_1 = CFrame.new(0, 10, 0)
			_fn:PivotTo(_cFrame * _cFrame_1)
		end
	end
end)
Events.EndTutorial.OnServerEvent:Connect(function(player, reachedEnd)
	Events.ForceReset:Fire(player, true)
	if reachedEnd ~= 0 and reachedEnd == reachedEnd and reachedEnd ~= "" and reachedEnd then
		giveBadge(player, Badge.Learner)
	end
end)
