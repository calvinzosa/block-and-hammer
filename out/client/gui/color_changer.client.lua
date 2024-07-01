-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local RunService = _services.RunService
local Players = _services.Players
local GuiService = _services.GuiService
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local computeNameColor = _utils.computeNameColor
local PlayerAttributes = _utils.PlayerAttributes
local Events = {
	SetColor = ReplicatedStorage:WaitForChild("SetColor"),
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local colorChanger = screenGui:WaitForChild("ColorChanger")
local container = colorChanger:WaitForChild("Container")
local colorInput = container:WaitForChild("ColorInput")
local svMap = colorInput:WaitForChild("SVMap")
local location = svMap:WaitForChild("Location")
local saturationMap = svMap:WaitForChild("SaturationMap")
local saturationGradient = saturationMap:WaitForChild("UIGradient")
local hueSlider = colorInput:WaitForChild("HueSlider")
local hueInput = hueSlider:WaitForChild("Input")
local result = colorInput:WaitForChild("Result")
local resultColor = result:WaitForChild("Color")
local resultHex = result:WaitForChild("Hex")
local resetColor = container:WaitForChild("Reset")
local setColor = container:WaitForChild("Set")
local defaultColor = computeNameColor(player.Name)
local currentColor = defaultColor
local isDraggingSV = false
local isDraggingHue = false
local currentHue = 0
local currentSaturation = 1
local currentValue = 1
while true do
	local _value = player:GetAttribute(PlayerAttributes.HasDataLoaded)
	if not not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
		break
	end
	player.AttributeChanged:Wait()
end
local function updateResult()
	currentColor = Color3.fromHSV(currentHue, currentSaturation, currentValue)
	location.Position = UDim2.fromScale(currentSaturation, 1 - currentValue)
	hueInput.Position = UDim2.fromScale(0, 1 - currentHue)
	saturationGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(currentHue, 1, 1)) })
	resultColor.BackgroundColor3 = currentColor
	resultHex.Text = string.upper(currentColor:ToHex())
end
local loadedColor = player:GetAttribute(PlayerAttributes.CubeColor)
if typeof(loadedColor) == "Color3" then
	currentColor = loadedColor
end
resultHex.Text = string.upper(currentColor:ToHex())
resultHex.PlaceholderText = resultHex.Text
resultHex.FocusLost:Connect(function()
	local inputColor = nil
	TS.try(function()
		inputColor = Color3.fromHex(resultHex.ContentText)
	end, function(err) end)
	local _inputColor = inputColor
	if typeof(_inputColor) == "Color3" then
		local hue, saturation, value = inputColor:ToHSV()
		location.Position = UDim2.fromScale(saturation, 1 - value)
		hueInput.Position = UDim2.fromScale(0, 1 - hue)
		currentHue = hue
		currentSaturation = saturation
		currentValue = value
		updateResult()
	else
		resultHex.Text = string.upper(resultColor.BackgroundColor3:ToHex())
	end
end)
RunService.RenderStepped:Connect(function()
	local inset = GuiService:GetGuiInset()
	local mouseLocation = UserInputService:GetMouseLocation() - inset
	local _value = svMap:GetAttribute("isDragging")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		local _absolutePosition = svMap.AbsolutePosition
		local _exp = (mouseLocation - _absolutePosition):Max(Vector2.zero):Min(svMap.AbsoluteSize)
		local _absoluteSize = svMap.AbsoluteSize
		local position = _exp / _absoluteSize
		currentSaturation = position.X
		currentValue = 1 - position.Y
		updateResult()
	else
		local _value_1 = hueSlider:GetAttribute("isDragging")
		if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
			local value = math.clamp(mouseLocation.Y - hueSlider.AbsolutePosition.Y, 0, hueSlider.AbsoluteSize.Y) / hueSlider.AbsoluteSize.Y
			hueInput.Position = UDim2.fromScale(0, value)
			currentHue = 1 - value
			updateResult()
		end
	end
end)
resetColor.MouseButton1Click:Connect(function()
	currentHue, currentSaturation, currentValue = defaultColor:ToHSV()
	updateResult()
end)
setColor.MouseButton1Click:Connect(function()
	Events.SetColor:FireServer(currentColor)
end)
