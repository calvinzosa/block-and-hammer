-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local PlayerAttributes = _utils.PlayerAttributes
local giveBadge = _utils.giveBadge
local Badge = _utils.Badge
local questData = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "quests").default
local Events = {
	CancelQuest = ReplicatedStorage:FindFirstChild("CancelQuest"),
	FinishQuest = ReplicatedStorage:FindFirstChild("FinishQuest"),
	StartQuest = ReplicatedStorage:FindFirstChild("StartQuest"),
}
Events.StartQuest.OnServerEvent:Connect(function(player, questName)
	local _questName = questName
	if not (type(_questName) == "string") then
		return nil
	end
	if questData[questName] ~= nil then
		player:SetAttribute(PlayerAttributes.ActiveQuest, questName)
	end
end)
Events.CancelQuest.OnServerEvent:Connect(function(player)
	player:SetAttribute(PlayerAttributes.ActiveQuest, nil)
end)
Events.FinishQuest.OnServerEvent:Connect(function(player)
	local questName = player:GetAttribute(PlayerAttributes.ActiveQuest)
	if questName == "LostSteelHammer" then
		local _value = player:GetAttribute(PlayerAttributes.HasSteelHammer)
		if _value ~= 0 and _value == _value and _value ~= "" and _value then
			giveBadge(player, Badge.MadeOfSteel)
		end
	end
	player:SetAttribute(PlayerAttributes.ActiveQuest, nil)
end)
