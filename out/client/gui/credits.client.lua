-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Players = _services.Players
local isTestingServer = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").isTestingServer
local player = Players.LocalPlayer
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local itemTemplate = guiTemplates:WaitForChild("ChangelogItem")
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local changelogs = screenGui:WaitForChild("Changelogs")
local items = changelogs:WaitForChild("Items")
local content = items:WaitForChild("Content")
local text = content.Text
if isTestingServer() then
	text = "nuh uh!!"
end
for i, line in pairs(string.split(text, "\n")) do
	local result = ""
	local word = ""
	for j, char in pairs(string.split(line, "")) do
		if char == " " or j == #line then
			if char ~= " " then
				word = word .. char
			end
			if word == "-" then
				result ..= "•"
			elseif string.sub(word, 1, 1) == "*" and string.sub(string.reverse(word), 1, 1) == "*" then
				if string.sub(word, 2, 2) == "*" and string.sub(string.reverse(word), 2, 2) == "*" then
					local _word = word
					local _arg1 = #word - 2
					result ..= `<b>{string.sub(_word, 3, _arg1)}</b>`
				else
					local _word = word
					local _arg1 = #word - 1
					result ..= `<i>{string.sub(_word, 2, _arg1)}</i>`
				end
			else
				result ..= word
			end
			word = ""
			result ..= " "
		else
			word ..= char
		end
	end
	local item = itemTemplate:Clone()
	local _result = result
	local _arg1 = #result - 1
	item.Text = `<stroke thickness="1">{string.sub(_result, 1, _arg1)}</stroke>`
	item.LayoutOrder = i
	item.Parent = items
end
content:Destroy()
