-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Workspace = _services.Workspace
local Players = _services.Players
local TweenService = _services.TweenService
local Debris = _services.Debris
local Accessories = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").Accessories
local _accessory_loader = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader")
local reloadAccessories = _accessory_loader.reloadAccessories
local loadAccessories = _accessory_loader.loadAccessories
local Events = {
	BuildingHammerPlace = ReplicatedStorage:FindFirstChild("BuildingHammerPlace"),
	LoadPlayerAccessories = ReplicatedStorage:FindFirstChild("LoadPlayerAccessories"),
}
local mapFolder = Workspace:FindFirstChild("Map")
local removeFunctions = {}
Events.LoadPlayerAccessories.Event:Connect(function(player, cube)
	local _player = player
	local _condition = not (typeof(_player) == "Instance")
	if not _condition then
		_condition = not player:IsA("Player")
		if not _condition then
			local _cube = cube
			_condition = not (typeof(_cube) == "Instance")
			if not _condition then
				_condition = not cube:IsA("BasePart")
			end
		end
	end
	if _condition then
		return nil
	end
	while true do
		local _value = player:GetAttribute("DATA_LOADED")
		if not not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
			break
		end
		task.wait()
	end
	if cube.Parent ~= Workspace then
		return nil
	end
	local hasRemoveFunction = (removeFunctions[player.UserId] ~= nil)
	local hammerRemoveFunction = loadAccessories(cube, {
		face = player:GetAttribute("cube_Face"),
		hammer = player:GetAttribute("hammer_Texture"),
		hat = player:GetAttribute("cube_Hat"),
		aura = player:GetAttribute("cube_Aura"),
	}, player, if hasRemoveFunction then removeFunctions[player.UserId] else nil)
	if removeFunctions[player.UserId] ~= nil then
		removeFunctions[player.UserId] = nil
	end
	if type(hammerRemoveFunction) == "function" then
		removeFunctions[player.UserId] = hammerRemoveFunction
	end
	reloadAccessories(cube, player)
end)
Events.BuildingHammerPlace.OnServerEvent:Connect(function(player, position, buildType)
	local _condition = player:GetAttribute("hammer_Texture") ~= Accessories.HammerTexture.BuilderHammer
	if not _condition then
		local _position = position
		_condition = not (typeof(_position) == "Vector3")
		if not _condition then
			local _buildType = buildType
			_condition = not (type(_buildType) == "number")
		end
	end
	if _condition then
		return nil
	end
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _head = cube
	if _head ~= nil then
		_head = _head:FindFirstChild("Head")
	end
	local head = _head
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition_1 = not _result
	if not _condition_1 then
		local _result_1 = head
		if _result_1 ~= nil then
			_result_1 = _result_1:IsA("BasePart")
		end
		_condition_1 = not _result_1
	end
	if _condition_1 then
		return nil
	end
	local part = Instance.new("Part")
	part.Name = `part\{player.UserId\}`
	part.Anchored = true
	part.Position = position
	part.BrickColor = BrickColor.random()
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = mapFolder
	if buildType == 0 then
		part.Size = Vector3.new(7, 1, 7)
	elseif buildType == 1 then
		part.Size = Vector3.new(1, 7, 7)
	end
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.fromScale(1.5, 1.5)
	billboardGui.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Text = "20.0s"
	label.TextSize = 20
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.BuilderSansBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.BackgroundTransparency = 1
	label.Parent = billboardGui
	billboardGui.Parent = part
	TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Transparency = 0,
	}):Play()
	TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		TextTransparency = 0,
		TextStrokeTransparency = 0,
	}):Play()
	local timer = 25
	part:SetAttribute("timer", timer)
	while timer > 0 do
		local dt = task.wait()
		timer -= dt
		part:SetAttribute("timer", timer)
		label.Text = string.format("%.1fs", timer)
	end
	label.Text = "0.0s"
	TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Transparency = 1,
	}):Play()
	TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	Debris:AddItem(part, 1)
end)
Players.PlayerRemoving:Connect(function(player)
	removeFunctions[player.UserId] = nil
end)
