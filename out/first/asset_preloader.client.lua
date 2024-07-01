-- Compiled with roblox-ts v2.3.0
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local AssetIds = {
	Audios = { "rbxassetid://9076854890", "rbxassetid://5801257793", "rbxassetid://9113131247", "rbxassetid://3417831369", "rbxassetid://6239232266", "rbxassetid://6746263591", "rbxassetid://5134377245", "rbxassetid://821439273", "rbxassetid://4780469887", "rbxassetid://130976109", "rbxassetid://9118159665", "rbxassetid://134188543", "rbxassetid://836142578", "rbxassetid://2048662066", "rbxassetid://9118614718", "rbxassetid://9116910432", "rbxassetid://9113819607", "rbxassetid://17778392816", "rbxassetid://1844234702", "rbxassetid://13616520700", "rbxassetid://13639365943", "rbxassetid://13639401235", "rbxassetid://13651211094", "rbxassetid://17750941254" },
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local mainMenuGui = ReplicatedFirst:WaitForChild("MainMenuGui")
local shadow = mainMenuGui:WaitForChild("Shadow")
local shadowLoading = shadow:WaitForChild("Loading")
shadow.Visible = true
mainMenuGui.Parent = GUI
player:SetAttribute("inMainMenu", true)
ReplicatedFirst:RemoveDefaultLoadingScreen()
print("[src/first/asset_preloader.client.ts:54]", "Created loading screen")
task.spawn(function()
	while true do
		local success = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		end)
		if success then
			break
		else
			task.wait(0.1)
		end
	end
end)
for _, audioId in AssetIds.Audios do
	shadowLoading.Text = `attempting to preload asset {audioId}`
	ContentProvider:PreloadAsync({ audioId }, function(_, status)
		if status == Enum.AssetFetchStatus.Success then
			shadowLoading.Text = `preloaded asset {audioId}`
		else
			shadowLoading.Text = `asset {audioId} failed to preload with status '{status.Name}'`
		end
	end)
end
print("[src/first/asset_preloader.client.ts:76]", "Finished preloading assets")
mainMenuGui:SetAttribute("done", true)
