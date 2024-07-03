-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local GameSetting = _utils.GameSetting
local getSetting = _utils.getSetting
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local GUI = player:WaitForChild("PlayerGui")
local mobileButtons = GUI:WaitForChild("MobileButtons")
local deviceSafeInsets = GUI:WaitForChild("DeviceSafeInsets")
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local buttonTemplate = guiTemplates:WaitForChild("MobileButton")
local callbacks = {}
local areButtonsVisible = false
local buttonPadding = 5
local updateDisplay
local function createMobileButton(title, category, position, scale, action, callback)
	local button = buttonTemplate:Clone()
	button.Visible = areButtonsVisible
	button:SetAttribute("_position", position)
	button:SetAttribute("_scale", scale)
	button:SetAttribute("_action", action)
	button:SetAttribute("_category", category)
	local titleLabel = button:FindFirstChild("Title")
	titleLabel.Text = title
	button.Parent = mobileButtons
	button.Destroying:Connect(function()
		-- ▼ ReadonlyArray.findIndex ▼
		local _callback = function(data)
			return data[1] == button
		end
		local _result = -1
		for _i, _v in callbacks do
			if _callback(_v, _i - 1, callbacks) == true then
				_result = _i - 1
				break
			end
		end
		-- ▲ ReadonlyArray.findIndex ▲
		local i = _result
		if i ~= -1 then
			table.remove(callbacks, i + 1)
		end
	end)
	button.MouseButton1Down:Connect(function()
		callback(action, Enum.UserInputState.Begin, {
			UserInputType = Enum.UserInputType.Touch,
			UserInputState = Enum.UserInputState.Begin,
			Delta = Vector3.zero,
			Position = Vector3.zero,
		})
		button:SetAttribute("_pressed", true)
		button.Image = "rbxassetid://15904289666"
		titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		titleLabel.TextTransparency = 0.5
	end)
	local _arg0 = { button, callback }
	table.insert(callbacks, _arg0)
	updateDisplay()
	return button
end
local function clearMobileButtons()
	mobileButtons:ClearAllChildren()
end
local function update()
	updateDisplay()
end
local function getMobileButtonsByCategory(category)
	local buttons = {}
	for _, button in mobileButtons:GetChildren() do
		if button:IsA("ImageButton") and button:GetAttribute("_category") == category then
			table.insert(buttons, button)
		end
	end
	return buttons
end
local function updateInput()
	local lastInput = UserInputService:GetLastInputType()
	if lastInput == Enum.UserInputType.Focus then
		return nil
	end
	areButtonsVisible = lastInput == Enum.UserInputType.Touch
	for _, button in mobileButtons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end
		button.Visible = areButtonsVisible
	end
end
function updateDisplay()
	local invertX = getSetting(GameSetting.InvertMobileButtons)
	for _, button in mobileButtons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end
		local position = button:GetAttribute("_position")
		local scale = button:GetAttribute("_scale")
		local screenSize = deviceSafeInsets.AbsoluteSize
		local minAxis = math.min(screenSize.X, screenSize.Y)
		local isSmallScreen = minAxis <= 500
		local jumpButtonSize = math.round((if isSmallScreen then 70 else 120) * scale)
		local xOffset = (jumpButtonSize * 1.5 - 10) * -1 + jumpButtonSize * position.X + buttonPadding * position.X
		local yOffset = (if isSmallScreen then (jumpButtonSize + 20) else (jumpButtonSize * 1.75)) * -1 + jumpButtonSize * position.Y + buttonPadding * position.Y
		local titleLabel = button:FindFirstChild("Title")
		local padding = titleLabel:FindFirstChild("UIPadding")
		padding.PaddingTop = UDim.new(0, 10 * scale)
		padding.PaddingBottom = UDim.new(0, 10 * scale)
		padding.PaddingLeft = UDim.new(0, 10 * scale)
		padding.PaddingRight = UDim.new(0, 10 * scale)
		button.Size = UDim2.new(0, jumpButtonSize, 0, jumpButtonSize)
		button.Position = UDim2.new(if invertX then 0 else 1, xOffset * (if invertX then -1 else 1), 1, yOffset)
	end
end
updateInput()
UserInputService.InputEnded:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch then
		for _, _binding in callbacks do
			local button = _binding[1]
			local callback = _binding[2]
			local _value = button:GetAttribute("_pressed")
			if _value ~= 0 and _value == _value and _value ~= "" and _value then
				callback(button:GetAttribute("_action"), Enum.UserInputState.End, {
					UserInputType = Enum.UserInputType.Touch,
					UserInputState = Enum.UserInputState.End,
					Delta = Vector3.zero,
					Position = Vector3.zero,
				})
				button.Image = "rbxassetid://15904290429"
				local title = button:FindFirstChild("Title")
				local _result = title
				if _result ~= nil then
					_result = _result:IsA("TextLabel")
				end
				if _result then
					title.TextColor3 = Color3.fromRGB(255, 255, 255)
					title.TextTransparency = 0
				end
				button:SetAttribute("pressed", nil)
			end
		end
	end
end)
UserInputService.LastInputTypeChanged:Connect(updateInput)
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateDisplay)
return {
	createMobileButton = createMobileButton,
	clearMobileButtons = clearMobileButtons,
	update = update,
	getMobileButtonsByCategory = getMobileButtonsByCategory,
}
