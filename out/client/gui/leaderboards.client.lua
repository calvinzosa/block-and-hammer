-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local HttpService = _services.HttpService
local Players = _services.Players
local getTimeUnits = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").getTimeUnits
local Events = {
	UpdateLeaderboard = ReplicatedStorage:FindFirstChild("UpdateLeaderboard"),
	UpdatePlayerTime = ReplicatedStorage:FindFirstChild("UpdatePlayerTime"),
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local playerTemplate = guiTemplates:WaitForChild("Player")
local screenGui = GUI:WaitForChild("ScreenGui")
local leaderboardGui = screenGui:WaitForChild("LeaderboardGUI")
local data = {
	GlobalLeaderboard = {},
	ModdedLeaderboard = {},
}
Events.UpdateLeaderboard.OnClientEvent:Connect(function(encodedData)
	data = HttpService:JSONDecode(encodedData)
	print("[src/client/gui/leaderboards.client.ts:31]", "Recieved new leaderboard info")
end)
leaderboardGui:GetPropertyChangedSignal("Visible"):Connect(function()
	for name, values in pairs(data) do
		local frame = leaderboardGui:WaitForChild(name)
		local list = frame:WaitForChild("List")
		for _, item in list:GetChildren() do
			if item:IsA("Frame") then
				item:Destroy()
			end
		end
		for number, data in pairs(values) do
			local userId = data[1]
			local totalTimeMilliseconds = data[2]
			local name = `[ {userId} ]`
			TS.try(function()
				name = Players:GetNameFromUserIdAsync(userId)
			end, function(err)
				warn("[src/client/gui/leaderboards.client.ts:51]", err)
			end)
			local _, minutes, seconds, milliseconds = getTimeUnits(totalTimeMilliseconds)
			local item = playerTemplate:Clone()
			item.LayoutOrder = number;
			(item:FindFirstChild("Number")).Text = tostring(number);
			(item:FindFirstChild("Username")).Text = name;
			(item:FindFirstChild("Time")).Text = string.format("%02d:%02d.%03d", minutes, seconds, milliseconds);
			(item:FindFirstChild("Icon")).Image = `https://www.roblox.com/bust-thumbnail/image?userId={userId}&width=117&height=117&format=png`
			item.Parent = list
		end
	end
end)
