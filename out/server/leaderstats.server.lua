-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local defaultLeaderstats = {
	Time = "StringValue",
	Altitude = "StringValue",
}
local function playerAdded(player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	for name, className in pairs(defaultLeaderstats) do
		local value = Instance.new(className)
		value.Name = name
		value.Parent = folder
	end
end
for _, player in Players:GetPlayers() do
	playerAdded(player)
end
Players.PlayerAdded:Connect(playerAdded)
