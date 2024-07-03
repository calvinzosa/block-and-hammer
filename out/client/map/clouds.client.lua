-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local RunService = _services.RunService
local Workspace = _services.Workspace
local randomFloat = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").randomFloat
local cloudTemplate = ReplicatedStorage:WaitForChild("Cloud")
local cloudsFolder = Workspace:WaitForChild("Clouds")
local clouds = {}
for i = 1, 300 do
	local cloud = cloudTemplate:Clone()
	cloud.Position = Vector3.new(1800 - (i / 300) * 2650, 660 + randomFloat(-10, 45), randomFloat(-75, 75))
	cloud.Parent = cloudsFolder
	table.insert(clouds, cloud)
	task.wait()
end
RunService.Heartbeat:Connect(function(dt)
	local cloudOffset = Vector3.new(dt * 2, 0, 0)
	for _, cloud in clouds do
		local newPosition = cloud.Position + cloudOffset
		if newPosition.X > 1800 then
			cloud.Position = Vector3.new(-850, 660 + randomFloat(-10, 45), randomFloat(-75, 75))
		else
			cloud.Position = newPosition
		end
	end
end)
