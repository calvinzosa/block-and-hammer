-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local BadgeService = _services.BadgeService
local RunService = _services.RunService
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local PlayerAttributes = _utils.PlayerAttributes
local computeNameColor = _utils.computeNameColor
local accessoryList = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader").accessoryList
local Events = {
	EquipAccessory = ReplicatedStorage:WaitForChild("EquipAccessory"),
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local templates = ReplicatedStorage:WaitForChild("GUI")
local accessoryTemplate = templates:WaitForChild("AccessoryTemplate")
local screenGui = GUI:WaitForChild("ScreenGui")
local accessoriesGui = screenGui:WaitForChild("AccessoriesGUI")
local items = accessoriesGui:WaitForChild("Items")
local info = accessoriesGui:WaitForChild("Info")
local title = info:WaitForChild("Title")
local description = info:WaitForChild("Description")
local equipButton = info:WaitForChild("Equip")
local selectedAccessory = nil
local accessoryOrder = { "hammer_Texture", "cube_Hat", "cube_Face", "cube_Aura" }
local function updateGui()
	title.Text = "select an accessory!"
	description.Text = ""
	equipButton.Visible = false
	selectedAccessory = nil
	for name, accessory in pairs(accessoryList) do
		if accessory.never then
			continue
		end
		task.spawn(function()
			local accessoryButton = accessoryTemplate:Clone()
			accessoryButton.Image = accessory.icon
			accessoryButton.Name = name
			-- ▼ ReadonlyArray.findIndex ▼
			local _callback = function(accessoryType)
				return accessoryType == accessory.acc_type
			end
			local _result = -1
			for _i, _v in accessoryOrder do
				if _callback(_v, _i - 1, accessoryOrder) == true then
					_result = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			accessoryButton.LayoutOrder = _result
			local labelName = accessoryButton:FindFirstChild("LabelName")
			labelName.Text = name
			accessoryButton.Parent = items
			local outline = accessoryButton:FindFirstChild("UIStroke")
			local shadow = accessoryButton:FindFirstChild("Shadow")
			local typeIndicator = accessoryButton:FindFirstChild("Type")
			if player:GetAttribute(accessory.acc_type) == name then
				accessoryButton.LayoutOrder -= 100
				outline.Enabled = true
			end
			if accessory.copy_cube_color then
				accessoryButton.ImageColor3 = player:GetAttribute("CUBE_COLOR") or computeNameColor(player.Name)
			end
			local canEquipIt = false
			accessoryButton.Visible = true
			if accessory.badge_id ~= 0 then
				accessoryButton.Visible = false
				task.spawn(function()
					local hasBadge = false
					while true do
						local success, result = pcall(function()
							return BadgeService:UserHasBadgeAsync(player.UserId, accessory.badge_id)
						end)
						if success then
							hasBadge = result
							break
						else
							task.wait(0.5)
						end
					end
					if hasBadge then
						canEquipIt = true
						shadow.Visible = true
					else
						shadow.Text = accessory.badge_name
						if not accessory.always_show then
							accessoryButton.Visible = false
						else
							accessoryButton.Visible = true
						end
					end
				end)
			else
				canEquipIt = true
				shadow.Visible = false
			end
			if accessory.acc_type == PlayerAttributes.CubeHat then
				typeIndicator.BackgroundColor3 = Color3.fromRGB(255, 26, 26)
			elseif accessory.acc_type == PlayerAttributes.CubeFace then
				typeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 51)
			elseif accessory.acc_type == PlayerAttributes.HammerTexture then
				typeIndicator.BackgroundColor3 = Color3.fromRGB(51, 255, 128)
			elseif accessory.acc_type == PlayerAttributes.CubeAura then
				typeIndicator.BackgroundColor3 = Color3.fromRGB(51, 102, 255)
			else
				typeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			end
			local _value = accessoryButton:GetAttribute("connected")
			if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
				accessoryButton:SetAttribute("connected", true)
				accessoryButton.MouseButton1Click:Connect(function()
					selectedAccessory = accessoryButton
					title.Text = name
					local _condition = accessory.description
					if _condition == nil then
						_condition = "[ No Description Found ]"
					end
					description.Text = _condition
					equipButton.Text = "equip"
					if canEquipIt and not outline.Enabled then
						equipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						equipButton.BackgroundTransparency = 0.6
						equipButton.AutoButtonColor = true
					else
						equipButton.TextColor3 = Color3.fromRGB(175, 175, 175)
						equipButton.BackgroundTransparency = 0.5
						equipButton.AutoButtonColor = false
						if outline.Enabled then
							equipButton.Text = "already equipped"
						end
					end
					equipButton.Visible = true
				end)
			end
		end)
	end
end
updateGui()
accessoriesGui:GetPropertyChangedSignal("Visible"):Connect(function()
	if accessoriesGui.Visible then
		updateGui()
	end
end)
equipButton.MouseButton1Click:Connect(function()
	local _outline = selectedAccessory
	if _outline ~= nil then
		_outline = _outline:FindFirstChild("UIStroke")
	end
	local outline = _outline
	local _condition = not selectedAccessory
	if not _condition then
		local _result = outline
		if _result ~= nil then
			_result = _result:IsA("UIStroke")
		end
		_condition = not _result
		if not _condition then
			_condition = not outline.Enabled
		end
	end
	if _condition then
		return nil
	end
	local name = selectedAccessory.Name
	if not (accessoryList[name] ~= nil) then
		return nil
	end
	local accessory = accessoryList[name]
	local didEquip = Events.EquipAccessory:InvokeServer(name)
	if didEquip ~= 0 and didEquip == didEquip and didEquip ~= "" and didEquip then
		outline.Enabled = true
		-- ▼ ReadonlyArray.findIndex ▼
		local _callback = function(accessoryType)
			return accessoryType == accessory.acc_type
		end
		local _result = -1
		for _i, _v in accessoryOrder do
			if _callback(_v, _i - 1, accessoryOrder) == true then
				_result = _i - 1
				break
			end
		end
		-- ▲ ReadonlyArray.findIndex ▲
		selectedAccessory.LayoutOrder = _result - 100
		for otherName, otherAccessory in pairs(accessoryList) do
			if otherName ~= name and otherAccessory.acc_type == accessory.acc_type then
				local button = items:FindFirstChild(otherName)
				local _otherOutline = button
				if _otherOutline ~= nil then
					_otherOutline = _otherOutline:FindFirstChild("UIStroke")
				end
				local otherOutline = _otherOutline
				local _result_1 = button
				if _result_1 ~= nil then
					_result_1 = _result_1:IsA("ImageButton")
				end
				local _condition_1 = _result_1
				if _condition_1 then
					local _result_2 = otherOutline
					if _result_2 ~= nil then
						_result_2 = _result_2:IsA("UIStroke")
					end
					_condition_1 = _result_2
				end
				if _condition_1 then
					otherOutline.Enabled = false
					-- ▼ ReadonlyArray.findIndex ▼
					local _callback_1 = function(accessoryType)
						return accessoryType == otherAccessory.acc_type
					end
					local _result_2 = -1
					for _i, _v in accessoryOrder do
						if _callback_1(_v, _i - 1, accessoryOrder) == true then
							_result_2 = _i - 1
							break
						end
					end
					-- ▲ ReadonlyArray.findIndex ▲
					button.LayoutOrder = _result_2
				end
			end
		end
		equipButton.TextColor3 = Color3.fromRGB(175, 175, 175)
		equipButton.BackgroundTransparency = 0.5
		equipButton.AutoButtonColor = false
		equipButton.Text = "already equipped"
	end
end)
RunService.RenderStepped:Connect(function()
	if not accessoriesGui.Visible then
		for _, button in items:GetChildren() do
			local _condition = not button:IsA("ImageButton")
			if not _condition then
				_condition = button:GetAttribute("loopDebounce")
				if not (_condition ~= 0 and _condition == _condition and _condition ~= "" and _condition) then
					_condition = not (accessoryList[button.Name] ~= nil)
				end
			end
			if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
				continue
			end
			local data = accessoryList[button.Name]
			if data.spritesheet_data then
				local tileWidth = data.spritesheet_data.tileWidth
				local tileHeight = data.spritesheet_data.tileHeight
				local maxRow = data.spritesheet_data.rows
				local maxColumn = data.spritesheet_data.columns
				local loopDelay = data.spritesheet_data.loopDelay
				local fps = data.spritesheet_data.fps
				local currentTime = time()
				local _condition_1 = button:GetAttribute("lastChange")
				if _condition_1 == nil then
					_condition_1 = (currentTime - 1)
				end
				local lastChange = _condition_1
				if (currentTime - lastChange) < (1 / fps) then
					continue
				end
				button:SetAttribute("lastChange", currentTime)
				local _condition_2 = button:GetAttribute("spritesheetX")
				if _condition_2 == nil then
					_condition_2 = -tileWidth
				end
				local x = _condition_2
				local _condition_3 = button:GetAttribute("spritesheetY")
				if _condition_3 == nil then
					_condition_3 = 0
				end
				local y = _condition_3
				x += tileWidth
				if x >= maxColumn * tileWidth then
					y += tileHeight
					x = 0
					if y >= maxRow * tileHeight then
						y = 0
						if loopDelay > 0 then
							button:SetAttribute("loopDebounce", true)
							task.delay(loopDelay, function()
								return button:SetAttribute("loopDebounce", nil)
							end)
						end
					end
				end
				button:SetAttribute("spritesheetX", x)
				button:SetAttribute("spritesheetY", y)
				button.ImageRectSize = Vector2.new(tileWidth, tileHeight)
				button.ImageRectOffset = Vector2.new(x, y)
			end
		end
	end
end)
