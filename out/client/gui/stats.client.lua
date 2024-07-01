-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local getTimeUnits = _utils.getTimeUnits
local getTime = _utils.getTime
local player = Players.LocalPlayer
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local itemTemplate = guiTemplates:WaitForChild("StatItem")
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local statsGui = screenGui:WaitForChild("StatsGUI")
local statsTitle = statsGui:WaitForChild("Title")
local list = statsGui:WaitForChild("List")
local function formatTime(totalSeconds)
	local hours, minutes, seconds = getTimeUnits(totalSeconds * 1000)
	local result = {}
	if hours > 0 then
		local _result = result
		local _arg0 = `{hours} hour{if hours == 1 then "" else "s"}`
		table.insert(_result, _arg0)
	end
	if minutes > 0 then
		local _result = result
		local _arg0 = `{minutes} minute{if minutes == 1 then "" else "s"}`
		table.insert(_result, _arg0)
	end
	local _result = result
	local _arg0 = `{seconds} second{if seconds == 1 then "" else "s"}`
	table.insert(_result, _arg0)
	return table.concat(result, ", ")
end
statsGui:GetPropertyChangedSignal("Visible"):Connect(function()
	if not statsGui.Visible then
		return nil
	end
	statsTitle.Text = `player stats for {player.DisplayName} (@{player.Name})`
	local currentTime = getTime()
	local _condition = player:GetAttribute("serverJoinTime")
	if _condition == nil then
		_condition = currentTime
	end
	local _exp = `total time played: {formatTime(currentTime - _condition)}`
	local _condition_1 = player:GetAttribute("timesJoined")
	if _condition_1 == nil then
		_condition_1 = 1
	end
	local _exp_1 = `total times joined: {_condition_1}`
	local _condition_2 = player:GetAttribute("totalWins")
	if _condition_2 == nil then
		_condition_2 = 0
	end
	local _exp_2 = `total wins: {_condition_2}`
	local _condition_3 = player:GetAttribute("totalModdedWins")
	if _condition_3 == nil then
		_condition_3 = 0
	end
	local _exp_3 = `total modded wins: {_condition_3}`
	local _condition_4 = player:GetAttribute("totalRestarts")
	if _condition_4 == nil then
		_condition_4 = 0
	end
	local _exp_4 = `total resets: {_condition_4}`
	local _condition_5 = player:GetAttribute("totalRagdolls")
	if _condition_5 == nil then
		_condition_5 = 0
	end
	local data = { _exp, _exp_1, _exp_2, _exp_3, _exp_4, `amount of times ragdolled: {_condition_5}` }
	for _, item in list:GetChildren() do
		if item:IsA("TextLabel") then
			item:Destroy()
		end
	end
	for _, text in data do
		local item = itemTemplate:Clone()
		item.Text = text
		item.Parent = list
	end
end)
