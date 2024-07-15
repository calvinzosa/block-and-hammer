-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local HttpService = _services.HttpService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Lighting = _services.Lighting
local Players = _services.Players
local TweenService = _services.TweenService
local Icon = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "topbar-plus", "out").Icon
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local PlayerAttributes = _utils.PlayerAttributes
local getSettingAlias = _utils.getSettingAlias
local getSettingOrder = _utils.getSettingOrder
local getCurrentArea = _utils.getCurrentArea
local canUseSetting = _utils.canUseSetting
local fixSettings = _utils.fixSettings
local GameSetting = _utils.GameSetting
local getSetting = _utils.getSetting
local setSetting = _utils.setSetting
local Settings = _utils.Settings
local getTime = _utils.getTime
local update = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "mobile_buttons").update
local Events = {
	SetModifiersSetting = ReplicatedStorage:WaitForChild("SetModifiersSetting"),
	LoadSettingsJSON = ReplicatedStorage:WaitForChild("LoadSettingsJSON"),
	SaveSettingsJSON = ReplicatedStorage:WaitForChild("SaveSettingsJSON"),
	EndTutorial = ReplicatedStorage:WaitForChild("EndTutorial"),
	Reset = ReplicatedStorage:WaitForChild("Reset"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
	ClientForceReset = ReplicatedStorage:WaitForChild("ClientForceReset"),
	SettingChanged = ReplicatedStorage:WaitForChild("SettingChanged"),
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
}
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
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
local travelGui = screenGui:WaitForChild("FastTravelGUI")
local statsGui = screenGui:WaitForChild("StatsGUI")
local playerList = {}
local clickThreshold = 0.2
local menuToggle = Icon.new():setLabel("Menu"):lock()
local areaBlur = Instance.new("BlurEffect")
areaBlur.Name = "AreaBlur"
areaBlur.Size = 0
areaBlur.Parent = Lighting
local menuBlur = areaBlur:Clone()
menuBlur.Enabled = true
menuBlur.Name = "MenuBlur"
menuBlur.Parent = Lighting
local debounces = {
	reset = false,
}
local travellableAreas = { {
	name = "Level 1",
	hasArea = function()
		return true
	end,
	cameraCFrame = CFrame.new(18.589, 34.544, -45.753, -0.943, -0.167, 0.287, 0.000, 0.864, 0.503, -0.332, 0.475, -0.815),
	teleportPosition = Vector3.new(0, 14, 0),
}, {
	name = "Level 2",
	hasArea = function()
		return player:GetAttribute(PlayerAttributes.HasLevel2)
	end,
	cameraCFrame = CFrame.new(-5892.511, 19.957, -45.243, -0.923, -0.116, 0.367, 0, 0.953, 0.302, -0.385, 0.279, -0.88),
	teleportPosition = Vector3.new(-5912, 14, 0),
} }
local currentTravelIndex = 0
local openableGuis = { resetConfirmation, settingsGui, accessoriesGui, tutorialConfirmation, colorChanger, credits, questGui, leaderboardGui, changelogsGui, statsGui, replaysGui }
local previousSettings = table.clone(Settings)
local lastChange = getTime()
local areSettingsSaved = true
local clickCount = 0
local lastClickTime = 0
Icon.setDisplayOrder(999999999)
local function resetCharacter(fullReset)
	if fullReset == nil then
		fullReset = false
	end
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local prevArea = getCurrentArea(cube)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = _result
	if _condition then
		_condition = getCurrentArea(cube) == "ErrorLand"
	end
	if _condition then
		cube:PivotTo(CFrame.new(0, 14, 0))
		return nil
	end
	local _result_1 = cube
	if _result_1 ~= nil then
		_result_1 = _result_1:IsA("BasePart")
	end
	if _result_1 then
		local area = getCurrentArea(cube)
		if area == "Tutorial" then
			cube:Destroy()
			cube = nil
			Events.EndTutorial:FireServer()
		end
	end
	local _result_2 = cube
	if _result_2 ~= nil then
		_result_2 = _result_2:IsA("BasePart")
	end
	local _condition_1 = not _result_2
	if not _condition_1 then
		_condition_1 = fullReset
	end
	if _condition_1 then
		Events.ClientReset:Fire(true)
		Events.Reset:FireServer(true)
	else
		Events.ClientReset:Fire(false)
		Events.Reset:FireServer(false)
		local _condition_2 = cube:GetAttribute("scale")
		if _condition_2 == nil then
			_condition_2 = 1
		end
		local cubeScale = _condition_2
		local position = Vector3.new(0, 0, 0)
		if prevArea == "Level 2" or prevArea == "Level 2: Cave 1" then
			position = Vector3.new(-5912, 0, 0)
		end
		cube:SetAttribute("previousVelocity", Vector3.zero)
		cube:PivotTo(CFrame.new(position.X, position.Y + (if cubeScale > 10 then 400 else 14), position.Z))
		cube.AssemblyLinearVelocity = Vector3.zero
		for _, descendant in cube:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.AssemblyLinearVelocity = Vector3.zero
			end
		end
		local arm = cube:FindFirstChild("Arm")
		local _result_3 = arm
		if _result_3 ~= nil then
			_result_3 = _result_3:IsA("BasePart")
		end
		if _result_3 then
			local _cFrame = CFrame.new(cube.Position)
			local _arg0 = CFrame.fromOrientation(0, 0, math.pi / 2)
			arm.CFrame = _cFrame * _arg0
		end
	end
	effectsFolder:ClearAllChildren()
end
local function updateSettingButtons()
	menuBlur.Enabled = getSetting(GameSetting.MenuBlur)
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
					Events.SetModifiersSetting:FireServer(getSetting(name))
				elseif name == GameSetting.TimerGUI then
					(screenGui:FindFirstChild("Timer")).Visible = getSetting(name)
				elseif name == GameSetting.InvertMobileButtons then
					update()
				elseif name == GameSetting.MenuBlur then
					menuBlur.Enabled = getSetting(name)
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
	TweenService:Create(menuBlur, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = if (not canMove.Value or menuOpen.Value) then 24 else 0,
	}):Play()
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
		if currentTime - lastClickTime < clickThreshold then
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
Events.ClientForceReset.Event:Connect(resetCharacter)
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
	if travelGui.Visible then
		local mouse = UserInputService:GetMouseLocation()
		local area = travellableAreas[currentTravelIndex + 1]
		local screenHeight = camera.ViewportSize.Y
		local screenWidth = camera.ViewportSize.X
		local halfHeight = screenHeight / 2
		local halfWidth = screenWidth / 2
		local mouseRotation = CFrame.fromOrientation(math.rad(((mouse.Y - halfHeight) / screenHeight) * -5), math.rad(((mouse.X - halfWidth) / screenWidth) * -5), 0)
		camera.CFrame = camera.CFrame:Lerp(area.cameraCFrame * mouseRotation, math.clamp(dt * 25, 0, 1))
		local _value = area.hasArea()
		if _value ~= 0 and _value == _value and _value ~= "" and _value then
			areaBlur.Size = 0
			(travelGui:FindFirstChild("AreaName")).Text = area.name;
			(travelGui:FindFirstChild("Teleport")).Visible = true
		else
			areaBlur.Size = 64
			(travelGui:FindFirstChild("AreaName")).Text = "???"
			(travelGui:FindFirstChild("Teleport")).Visible = false
		end
		if area.name == "Level 1" then
			Lighting.ClockTime = 14.5
		elseif area.name == "Level 2" then
			Lighting.ClockTime = 0
		end
	else
		areaBlur.Size = 0
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
				local _condition = (cube:GetAttribute("transparency"))
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
						local _condition = (cube:GetAttribute("hammerTransparency"))
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
	if areSettingsSaved then
		for name, value in pairs(Settings) do
			if previousSettings[name] ~= value then
				lastChange = currentTime
				areSettingsSaved = false
				previousSettings[name] = value
			end
		end
	end
	if (currentTime - lastChange) > 5 and not areSettingsSaved and not settingsGui.Visible then
		print("[src/client/gui/menu.client.ts:374]", `Saved settings: {HttpService:JSONEncode(Settings)}`)
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
		warn("[src/client/gui/menu.client.ts:386]", `Unable to decode settings JSON | Error: {err}`)
		return TS.TRY_RETURN, {}
	end)
	if _exitType then
		return unpack(_returns)
	end
	for name in pairs(Settings) do
		if newSettings[name] ~= nil then
			local value = newSettings[name]
			Settings[name] = value
			previousSettings[name] = value
		end
	end
	if getSetting(GameSetting.Modifiers) then
		Events.SetModifiersSetting:FireServer(true)
	end
	if getSetting(GameSetting.MenuBlur) then
		menuBlur.Enabled = getSetting(GameSetting.MenuBlur)
	end
	updateSettingButtons()
	print("[src/client/gui/menu.client.ts:403]", `Loaded settings data: {settingsJSON}`)
end)
menuOpen:GetPropertyChangedSignal("Value"):Connect(function()
	if not menuOpen.Value and canMove.Value then
		TweenService:Create(menuBlur, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = 0,
		}):Play()
	end
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
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = _result
	if _condition then
		_condition = getCurrentArea(cube) == "ErrorLand"
	end
	if _condition then
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
end);
(menuButtons:WaitForChild("FastTravel")).MouseButton1Click:Connect(function()
	menuBlur.Size = 0
	menuOpen.Value = false
	travelGui.Visible = true
	currentTravelIndex = 0
	local _cameraCFrame = travellableAreas[currentTravelIndex + 1].cameraCFrame
	local _arg0 = CFrame.fromOrientation(0, math.pi * 0.5, 0)
	camera.CFrame = _cameraCFrame * _arg0
end);
(travelGui:WaitForChild("Close")).MouseButton1Click:Connect(function()
	menuOpen.Value = true
	travelGui.Visible = false
end);
(travelGui:WaitForChild("Next")).MouseButton1Click:Connect(function()
	currentTravelIndex += 1
	if currentTravelIndex > #travellableAreas - 1 then
		currentTravelIndex = 0
	end
	local _cameraCFrame = travellableAreas[currentTravelIndex + 1].cameraCFrame
	local _arg0 = CFrame.fromOrientation(0, math.pi * 0.5, 0)
	camera.CFrame = _cameraCFrame * _arg0
end);
(travelGui:WaitForChild("Previous")).MouseButton1Click:Connect(function()
	currentTravelIndex -= 1
	if currentTravelIndex < 0 then
		currentTravelIndex = #travellableAreas - 1
	end
	local _cameraCFrame = travellableAreas[currentTravelIndex + 1].cameraCFrame
	local _arg0 = CFrame.fromOrientation(0, math.pi * 0.5, 0)
	camera.CFrame = _cameraCFrame * _arg0
end);
(travelGui:WaitForChild("Teleport")).MouseButton1Click:Connect(function()
	local area = travellableAreas[currentTravelIndex + 1]
	local cube = Workspace:WaitForChild(`cube{player.UserId}`)
	local _condition = not cube:IsA("BasePart")
	if not _condition then
		local _value = area.hasArea()
		_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
	end
	if _condition then
		return nil
	end
	menuOpen.Value = false
	canMove.Value = true
	travelGui.Visible = false
	resetCharacter()
	task.wait(0.05)
	cube:PivotTo(CFrame.new(travellableAreas[currentTravelIndex + 1].teleportPosition))
end)
Events.SettingChanged.Event:Connect(updateSettingButtons)
Events.StartClientTutorial.Event:Connect(function()
	menuToggle:lock():deselect():unlock()
	TweenService:Create(menuBlur, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = 0,
	}):Play()
end)
for _, otherPlayer in Players:GetPlayers() do
	if otherPlayer ~= player then
		local _name = otherPlayer.Name
		table.insert(playerList, _name)
	end
end
Players.PlayerAdded:Connect(function(otherPlayer)
	if otherPlayer ~= player then
		local _name = otherPlayer.Name
		table.insert(playerList, _name)
	end
end)
Players.PlayerRemoving:Connect(function(otherPlayer)
	-- ▼ ReadonlyArray.findIndex ▼
	local _callback = function(playerName)
		return playerName == otherPlayer.Name
	end
	local _result = -1
	for _i, _v in playerList do
		if _callback(_v, _i - 1, playerList) == true then
			_result = _i - 1
			break
		end
	end
	-- ▲ ReadonlyArray.findIndex ▲
	local i = _result
	if i ~= -1 then
		table.remove(playerList, i + 1)
	end
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
