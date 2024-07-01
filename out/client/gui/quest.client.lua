-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Players = _services.Players
local quests = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "quests").default
local PlayerAttributes = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").PlayerAttributes
local Events = {
	CancelQuest = ReplicatedStorage:FindFirstChild("CancelQuest"),
	FinishQuest = ReplicatedStorage:FindFirstChild("FinishQuest"),
	StartQuest = ReplicatedStorage:FindFirstChild("StartQuest"),
	ClientStartQuest = ReplicatedStorage:FindFirstChild("ClientStartQuest"),
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local questGui = screenGui:WaitForChild("QuestGUI")
local questCancelConfirmation = screenGui:WaitForChild("QuestCancelConfirmation")
local questAlreadyStarted = screenGui:WaitForChild("QuestAlreadyStarted")
local questStartConfirmation = screenGui:WaitForChild("QuestStartConfirmation")
local activeQuest = questGui:WaitForChild("ActiveQuest")
local activeQuestInfo = activeQuest:WaitForChild("Info")
local infoTitle = activeQuestInfo:WaitForChild("Title")
local infoDescription = activeQuestInfo:WaitForChild("Description")
local infoNone = activeQuest:WaitForChild("None");
(activeQuestInfo:WaitForChild("Cancel")).MouseButton1Click:Connect(function()
	questGui.Visible = false
	questCancelConfirmation.Visible = true
end);
(questAlreadyStarted:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	questAlreadyStarted.Visible = false
	questGui.Visible = true
end);
(questCancelConfirmation:WaitForChild("No")).MouseButton1Click:Connect(function()
	questCancelConfirmation.Visible = false
	questGui.Visible = true
end);
(questCancelConfirmation:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	questCancelConfirmation.Visible = false
	questGui.Visible = true
	Events.CancelQuest:FireServer()
end);
(questStartConfirmation:WaitForChild("No")).MouseButton1Click:Connect(function()
	questStartConfirmation.Visible = false
	questGui.Visible = true
end);
(questStartConfirmation:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	questStartConfirmation.Visible = false
	questGui.Visible = true
	Events.StartQuest:FireServer((questStartConfirmation:GetAttribute("questName")))
end)
questGui:GetPropertyChangedSignal("Visible"):Connect(function()
	local questName = player:GetAttribute(PlayerAttributes.ActiveQuest)
	if type(questName) == "string" and quests[questName] ~= nil then
		local data = quests[questName]
		infoTitle.Text = data.name
		infoTitle.Visible = true
		infoDescription.Text = data.description
		activeQuestInfo.Visible = true
		infoNone.Visible = false
	else
		activeQuestInfo.Visible = false
		infoNone.Visible = true
	end
end)
Events.ClientStartQuest.Event:Connect(function(questName)
	local currentQuest = player:GetAttribute("quest")
	if not (currentQuest ~= 0 and currentQuest == currentQuest and currentQuest ~= "" and currentQuest) then
		Events.StartQuest:FireServer(questName)
	elseif currentQuest == questName then
		questAlreadyStarted.Visible = true
	else
		questAlreadyStarted:SetAttribute("questName", questName)
		questAlreadyStarted.Visible = true
	end
end)
