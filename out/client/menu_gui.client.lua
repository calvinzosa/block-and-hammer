-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local HttpService = _services.HttpService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local PlayerAttributes = _utils.PlayerAttributes
local getSettingAlias = _utils.getSettingAlias
local getSettingOrder = _utils.getSettingOrder
local canUseSetting = _utils.canUseSetting
local fixSettings = _utils.fixSettings
local GameSetting = _utils.GameSetting
local getSetting = _utils.getSetting
local setSetting = _utils.setSetting
local Settings = _utils.Settings
local getTime = _utils.getTime
local Icon = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "topbar-plus", "out").Icon
local Events = {
	SetModifiersSetting = ReplicatedStorage:WaitForChild("SetModifiersSetting"),
	LoadSettingsJSON = ReplicatedStorage:WaitForChild("LoadSettingsJSON"),
	SaveSettingsJSON = ReplicatedStorage:WaitForChild("SaveSettingsJSON"),
	EndTutorial = ReplicatedStorage:WaitForChild("EndTutorial"),
	Reset = ReplicatedStorage:WaitForChild("Reset"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
	SettingChanged = ReplicatedStorage:WaitForChild("SettingChanged"),
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
}
local debounces = {
	reset = false,
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local effectsFolder = Workspace:WaitForChild("Effects")
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local valueInstances = GUI:WaitForChild("Values")
local isSpectating = valueInstances:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local canMove = valueInstances:WaitForChild("can_move")
local menuOpen = valueInstances:WaitForChild("menu_open")
local screenGui = GUI:WaitForChild("ScreenGui")
local placeVersion = screenGui:WaitForChild("PlaceVersion")
local menuGui = screenGui:WaitForChild("Menu")
local menuButtons = menuGui:WaitForChild("Buttons")
local accessoriesGui = screenGui:WaitForChild("AccessoriesGUI")
local spectatingGui = screenGui:WaitForChild("SpectatingGUI")
local settingsGui = screenGui:WaitForChild("SettingsGui")
local settingButtons = settingsGui:WaitForChild("Buttons")
local resetConfirmation = screenGui:WaitForChild("ResetConfirmation")
local tutorialConfirmation = screenGui:WaitForChild("TutorialConfirmation")
local tutorialGui = screenGui:WaitForChild("TutorialGUI")
local colorChanger = screenGui:WaitForChild("ColorChanger")
local credits = screenGui:WaitForChild("Credits")
local questGui = screenGui:WaitForChild("QuestGUI")
local leaderboardGui = screenGui:WaitForChild("LeaderboardGUI")
local changelogsGui = screenGui:WaitForChild("Changelogs")
local replaysGui = screenGui:WaitForChild("ReplaysGUI")
local statsGui = screenGui:WaitForChild("StatsGUI")
local playerList = {}
local clickThreshold = 0.2
local menuToggle = Icon.new():setLabel("Menu"):lock()
local openableGuis = { resetConfirmation, settingsGui, accessoriesGui, spectatingGui, tutorialConfirmation, colorChanger, credits, questGui, leaderboardGui, changelogsGui, statsGui, replaysGui }
local lastChange = getTime()
local areSettingsSaved = true
local previousSettings = table.clone(Settings)
local clickCount = 0
local lastClickTime = 0
Icon.setDisplayOrder(999999999)
local function resetCharacter(fullReset)
	if fullReset == nil then
		fullReset = false
	end
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _value = player:GetAttribute(PlayerAttributes.InErrorLand)
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		if cube then
			cube:PivotTo(CFrame.new(0, 14, 0))
		end
		return nil
	end
	local _value_1 = player:GetAttribute(PlayerAttributes.InTutorial)
	if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
		if cube then
			cube:Destroy()
			cube = nil
		end
		Events.EndTutorial:FireServer()
	end
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = not _result
	if not _condition then
		_condition = fullReset
	end
	if _condition then
		Events.ClientReset:Fire(true)
		Events.Reset:FireServer(true)
	else
		Events.ClientReset:Fire(false)
		Events.Reset:FireServer(false)
		cube:PivotTo(CFrame.new(0, 14, 0))
		cube.AssemblyLinearVelocity = Vector3.zero
		for _, descendant in cube:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end
	effectsFolder:ClearAllChildren()
end
local function updateSettingButtons()
	for _, button in settingButtons:GetChildren() do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
	for name, value in pairs(Settings) do
		local alias = getSettingAlias(name)
		local isUsable = canUseSetting(name)
		local order = getSettingOrder(name)
		local _result = guiTemplates:FindFirstChild("SettingToggle")
		if _result ~= nil then
			_result = _result:Clone()
		end
		local button = _result
		button.LayoutOrder = order
		button.Name = alias
		button.Text = `{alias}: {if value then "✅" else "❌"}`
		if isUsable then
			button.AutoButtonColor = true
			button.BackgroundTransparency = 0.7
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			button.AutoButtonColor = false
			button.BackgroundTransparency = 0.5
			button.TextColor3 = Color3.fromRGB(175, 175, 175)
			button:SetAttribute("disabled", true)
		end
		button.Parent = settingButtons
		if isUsable then
			button.MouseButton1Click:Connect(function()
				local currentValue = not getSetting(name)
				setSetting(name, currentValue)
				if name == GameSetting.Modifiers then
					Events.SetModifiersSetting:FireServer(getSetting(GameSetting.Modifiers))
				elseif name == GameSetting.TimerGUI then
					(screenGui:FindFirstChild("Timer")).Visible = getSetting(GameSetting.TimerGUI)
				end
				button.Text = `{alias}: {if currentValue then "✅" else "❌"}`
			end)
		end
	end
	fixSettings()
	player:SetAttribute(PlayerAttributes.Client.SettingsJSON, HttpService:JSONEncode(Settings))
end
local function toggleMenu()
	if menuToggle.locked then
		return nil
	end
	if not isSpectating.Value and (canMove.Value or menuOpen.Value) then
		canMove.Value = menuOpen.Value
		menuOpen.Value = not menuOpen.Value
	elseif not canMove.Value and not menuOpen.Value then
		for _, gui in openableGuis do
			if gui.Visible then
				gui.Visible = false
				menuOpen.Value = true
				break
			end
		end
	end
	menuToggle:lock()
	if not canMove.Value or menuOpen.Value then
		menuToggle:select()
	else
		menuToggle:deselect()
	end
	menuToggle:unlock()
end
player.AttributeChanged:Connect(function(attr)
	local _condition = attr == PlayerAttributes.Client.InMainMenu
	if _condition then
		local _value = player:GetAttribute(attr)
		_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
	end
	if _condition then
		menuToggle:unlock()
	end
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local currentTime = getTime()
		if (currentTime - lastClickTime) < clickThreshold then
			clickCount += 1
			if clickCount == 2 then
				toggleMenu()
				clickCount = 0
			end
		else
			clickCount = 1
		end
		lastClickTime = currentTime
	end
end)
UserInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and not processed then
		resetCharacter(UserInputService:IsKeyDown(Enum.KeyCode.LeftShift))
	end
end)
menuToggle.toggled:Connect(function()
	if menuToggle.locked then
		return nil
	end
	toggleMenu()
end)
RunService.RenderStepped:Connect(function(dt)
	local currentTime = getTime()
	local alpha = dt * 15
	if menuOpen.Value then
		menuGui.AnchorPoint = menuGui.AnchorPoint:Lerp(Vector2.new(0, 0.5), alpha)
	else
		menuGui.AnchorPoint = menuGui.AnchorPoint:Lerp(Vector2.new(1, 0.5), alpha)
	end
	local shouldHideOthers = getSetting(GameSetting.HideOthers)
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer == player then
			continue
		end
		local cube = Workspace:FindFirstChild(`cube{otherPlayer.UserId}`)
		local _result = cube
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if _result then
			local _result_1
			if shouldHideOthers then
				_result_1 = 1
			else
				local _condition = cube:GetAttribute("transparency")
				if _condition == nil then
					_condition = 0
				end
				_result_1 = _condition
			end
			local cubeTransparency = _result_1
			cube.LocalTransparencyModifier = cubeTransparency
			local _result_2 = cube
			if _result_2 ~= nil then
				_result_2 = _result_2:FindFirstChild("Arm")
			end
			for _1, part in { _result_2, cube:FindFirstChild("Head") } do
				local _result_3 = part
				if _result_3 ~= nil then
					_result_3 = _result_3:IsA("BasePart")
				end
				if _result_3 then
					local _result_4
					if shouldHideOthers then
						_result_4 = 1
					else
						local _condition = cube:GetAttribute("hammerTransparency")
						if _condition == nil then
							_condition = 0
						end
						_result_4 = _condition
					end
					local transparency = _result_4
					part.LocalTransparencyModifier = transparency
				end
			end
			local nameDisplay = cube:FindFirstChild("NameDisplay")
			if nameDisplay then
				nameDisplay.Enabled = not shouldHideOthers
			end
		end
	end
	if #playerList > 0 then
		-- ▼ ReadonlyArray.findIndex ▼
		local _callback = function(name)
			return name == spectatePlayer.Value
		end
		local _result = -1
		for _i, _v in playerList do
			if _callback(_v, _i - 1, playerList) == true then
				_result = _i - 1
				break
			end
		end
		-- ▲ ReadonlyArray.findIndex ▲
		local idx = _result
		if idx <= 0 then
			spectatePlayer.Value = playerList[1]
			idx = 0
		end
		spectatePlayer.Value = playerList[idx + 1]
	end
	for name, value in pairs(Settings) do
		if previousSettings[name] ~= value then
			lastChange = currentTime
			areSettingsSaved = false
			previousSettings[name] = value
		end
	end
	if (currentTime - lastChange) > 5 and not areSettingsSaved and not settingsGui.Visible then
		print("[src/client/menu_gui.client.ts:284]", `Saved settings: {HttpService:JSONEncode(Settings)}`)
		Events.SaveSettingsJSON:FireServer(Settings)
		areSettingsSaved = true
	end
end)
Events.LoadSettingsJSON.OnClientEvent:Connect(function(settingsJSON)
	local newSettings = nil
	local _exitType, _returns = TS.try(function()
		local decodedSettings = HttpService:JSONDecode(settingsJSON)
		newSettings = decodedSettings
	end, function(err)
		warn("[src/client/menu_gui.client.ts:296]", `Unable to decode settings JSON | Error: {err}`)
		return TS.TRY_RETURN, {}
	end)
	if _exitType then
		return unpack(_returns)
	end
	for name in pairs(Settings) do
		if newSettings[name] ~= nil then
			setSetting(name, newSettings[name])
		end
	end
	previousSettings = table.clone(Settings)
	if getSetting(GameSetting.Modifiers) then
		Events.SetModifiersSetting:FireServer(true)
	end
	updateSettingButtons()
	print("[src/client/menu_gui.client.ts:310]", `Loaded settings data: {settingsJSON}`)
end);
(menuButtons:WaitForChild("Reset")).MouseButton1Click:Connect(function()
	if debounces.reset then
		return nil
	end
	menuOpen.Value = false
	resetConfirmation.Visible = true
end);
(resetConfirmation:WaitForChild("Close")).MouseButton1Click:Connect(function()
	resetConfirmation.Visible = false
	menuOpen.Value = true
end);
(resetConfirmation:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	canMove.Value = true
	resetConfirmation.Visible = false
	if debounces.reset then
		return nil
	end
	debounces.reset = true
	task.delay(1.5, function()
		debounces.reset = false
		return debounces.reset
	end)
	resetCharacter()
end);
(resetConfirmation:WaitForChild("FullReset")).MouseButton1Click:Connect(function()
	canMove.Value = true
	resetConfirmation.Visible = false
	if debounces.reset then
		return nil
	end
	debounces.reset = true
	task.delay(1.5, function()
		debounces.reset = false
		return debounces.reset
	end)
	resetCharacter(true)
end);
(menuButtons:WaitForChild("Settings")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	settingsGui.Visible = true
	updateSettingButtons()
end);
(menuButtons:WaitForChild("Accessories")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	accessoriesGui.Visible = true
end);
(accessoriesGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	accessoriesGui.Visible = false
end);
(menuButtons:WaitForChild("Spectate")).MouseButton1Click:Connect(function()
	isSpectating.Value = true
	spectatingGui.Visible = true
	menuOpen.Value = false
end);
(spectatingGui:WaitForChild("Stop")).MouseButton1Click:Connect(function()
	isSpectating.Value = false
	spectatingGui.Visible = false
	menuOpen.Value = true
end);
(spectatingGui:WaitForChild("Next")).MouseButton1Click:Connect(function()
	-- ▼ ReadonlyArray.findIndex ▼
	local _callback = function(name)
		return name == spectatePlayer.Name
	end
	local _result = -1
	for _i, _v in playerList do
		if _callback(_v, _i - 1, playerList) == true then
			_result = _i - 1
			break
		end
	end
	-- ▲ ReadonlyArray.findIndex ▲
	local playerIndex = _result
	if playerIndex >= 0 then
		playerIndex += 1
		if playerIndex >= #playerList then
			playerIndex = 0
		end
		spectatePlayer.Value = playerList[playerIndex + 1]
	end
end);
(spectatingGui:WaitForChild("Previous")).MouseButton1Click:Connect(function()
	-- ▼ ReadonlyArray.findIndex ▼
	local _callback = function(name)
		return name == spectatePlayer.Name
	end
	local _result = -1
	for _i, _v in playerList do
		if _callback(_v, _i - 1, playerList) == true then
			_result = _i - 1
			break
		end
	end
	-- ▲ ReadonlyArray.findIndex ▲
	local playerIndex = _result
	if playerIndex >= 0 then
		playerIndex -= 1
		if playerIndex < 0 then
			playerIndex = #playerList - 1
		end
		spectatePlayer.Value = playerList[playerIndex + 1]
	end
end);
(menuButtons:WaitForChild("Tutorial")).MouseButton1Click:Connect(function()
	local _value = player:GetAttribute(PlayerAttributes.InErrorLand)
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return nil
	end
	menuOpen.Value = false
	tutorialConfirmation.Visible = true
end);
(tutorialConfirmation:WaitForChild("No")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	tutorialConfirmation.Visible = false
end);
(tutorialConfirmation:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	Events.StartClientTutorial:Fire()
	menuOpen.Value = false
	tutorialConfirmation.Visible = false
end);
(tutorialGui:WaitForChild("No")).MouseButton1Click:Connect(function()
	tutorialGui.Visible = false
end);
(menuButtons:WaitForChild("ColorChanger")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	colorChanger.Visible = true
end);
(colorChanger:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	colorChanger.Visible = false
end);
(menuButtons:WaitForChild("Credits")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	credits.Visible = true
end);
(credits:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	credits.Visible = false
end);
(settingsGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	settingsGui.Visible = false
end);
(menuButtons:WaitForChild("Quest")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	questGui.Visible = true
end);
(questGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	questGui.Visible = false
end);
(menuButtons:WaitForChild("Leaderboard")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	leaderboardGui.Visible = true
end);
(leaderboardGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	leaderboardGui.Visible = false
end);
(menuButtons:WaitForChild("Changelog")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	changelogsGui.Visible = true
end);
(changelogsGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	changelogsGui.Visible = false
end);
(menuButtons:WaitForChild("Stats")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	statsGui.Visible = true
end);
(statsGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	statsGui.Visible = false
end);
(menuButtons:WaitForChild("Replays")).MouseButton1Click:Connect(function()
	menuOpen.Value = false
	replaysGui.Visible = true
end);
(replaysGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	replaysGui.Visible = false
end)
Events.SettingChanged.Event:Connect(updateSettingButtons)
Events.StartClientTutorial.Event:Connect(function()
	return menuToggle:lock():deselect():unlock()
end)
local placeVersionValue = ReplicatedStorage:WaitForChild("PlaceVersion")
if placeVersionValue.Value == 0 then
	placeVersionValue.Changed:Wait()
end
local value = (ReplicatedStorage:FindFirstChild("PlaceVersion")).Value
local text = tostring(value)
if value == -1 then
	text = "DEV"
elseif value == -2 then
	text = "TESTING"
end
placeVersion.Text = `block and hammer - v{value}`
