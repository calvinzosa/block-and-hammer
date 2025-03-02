-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local RunService = _services.RunService
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local computeNameColor = _utils.computeNameColor
local getHammerTexture = _utils.getHammerTexture
local Accessories = _utils.Accessories
local getCubeAura = _utils.getCubeAura
local getCubeHat = _utils.getCubeHat
local giveBadge = _utils.giveBadge
local Badge = _utils.Badge
local accessories = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessories").default
local accessoryList = accessories
local function emptyFunction()
	return emptyFunction
end
local hammerFunctions = {
	error = emptyFunction,
	golden = function(cube, _)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.Color = Color3.fromRGB(255, 255, 128)
		arm.Material = Enum.Material.Foil
		head.Color = Color3.fromRGB(255, 255, 128)
		head.Material = Enum.Material.Foil
		return function()
			if not arm or not head then
				return nil
			end
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	explosive = function(cube, _)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.BrickColor = BrickColor.new("Medium stone grey")
		arm.Material = Enum.Material.DiamondPlate
		head.BrickColor = BrickColor.new("Really red")
		head.Material = Enum.Material.Neon
		return function()
			if not arm or not head then
				return nil
			end
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	steelhammer = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.Color = Color3.fromRGB(65, 62, 64)
		arm.Material = Enum.Material.DiamondPlate
		head.Color = Color3.fromRGB(99, 95, 98)
		head.Material = Enum.Material.DiamondPlate
		return function()
			if not arm or not head then
				return nil
			end
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	inverterhammer = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.Color = Color3.fromRGB(7, 114, 172)
		arm.Material = Enum.Material.Neon
		head.Material = Enum.Material.DiamondPlate
		return function()
			if not arm or not head then
				return nil
			end
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.Material = Enum.Material.Plastic
		end
	end,
	long = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local _connector = cube:FindFirstChild("Head")
		if _connector ~= nil then
			_connector = _connector:FindFirstChild("ConnectionAttachment")
		end
		local connector = _connector
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = connector
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("Attachment")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		local _cFrame = connector.CFrame
		local _cFrame_1 = CFrame.new(0, -11.5, 0)
		connector.CFrame = _cFrame * _cFrame_1
		arm.Size = Vector3.new(30, 0.75, 0.75)
		return function()
			if not arm or not connector then
				return nil
			end
			local _cFrame_2 = connector.CFrame
			local _cFrame_3 = CFrame.new(0, 11.5, 0)
			connector.CFrame = _cFrame_2 * _cFrame_3
			arm.Size = Vector3.new(6.5, 0.75, 0.75)
		end
	end,
	ice = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		cube:SetAttribute("hammerTransparency", 0.25)
		arm.Color = Color3.fromRGB(36, 116, 220)
		arm.Material = Enum.Material.Glass
		arm.Transparency = 0.25
		head.Color = Color3.fromRGB(52, 194, 255)
		head.Material = Enum.Material.Glass
		head.Transparency = 0.25
		return function()
			cube:SetAttribute("hammerTransparency", nil)
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			arm.Transparency = 0
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
			head.Transparency = 0
		end
	end,
	_God = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.Color = Color3.fromRGB(255, 255, 255)
		arm.Material = Enum.Material.Neon
		head.Color = Color3.fromRGB(255, 255, 255)
		head.Material = Enum.Material.Neon
		local _result_1 = ReplicatedStorage:FindFirstChild("Particles")
		if _result_1 ~= nil then
			_result_1 = _result_1:FindFirstChild("Lighting")
			if _result_1 ~= nil then
				_result_1 = _result_1:Clone()
			end
		end
		local particles = _result_1
		particles.Parent = arm
		return function()
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
			particles:Destroy()
		end
	end,
	_realgold = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.Color = Color3.fromRGB(255, 255, 128)
		arm.Material = Enum.Material.Metal
		head.Color = Color3.fromRGB(255, 255, 128)
		head.Material = Enum.Material.Metal
		return function()
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	_mallet = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _connector = head
		if _connector ~= nil then
			_connector = _connector:FindFirstChild("ConnectionAttachment")
		end
		local connector = _connector
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
			if not _condition then
				local _result_2 = connector
				if _result_2 ~= nil then
					_result_2 = _result_2:IsA("Attachment")
				end
				_condition = not _result_2
			end
		end
		if _condition then
			return emptyFunction
		end
		local _cFrame = connector.CFrame
		local _cFrame_1 = CFrame.new(0, 1.5, 0)
		connector.CFrame = _cFrame * _cFrame_1
		arm.Size = Vector3.new(5, 0.75, 0.75)
		arm.Material = Enum.Material.DiamondPlate
		arm.Color = Color3.fromRGB(255, 255, 128)
		head.Material = Enum.Material.DiamondPlate
		head.BrickColor = BrickColor.new("Dark stone grey")
		return function()
			local _cFrame_2 = connector.CFrame
			local _cFrame_3 = CFrame.new(0, -1.5, 0)
			connector.CFrame = _cFrame_2 * _cFrame_3
			arm.Size = Vector3.new(6.5, 0.75, 0.75)
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	_platform = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		local physicalProperties = arm.CurrentPhysicalProperties
		arm.Size = Vector3.new(0.001, 0.001, 0.001)
		head.CustomPhysicalProperties = PhysicalProperties.new(0.2, 1.3, physicalProperties.Elasticity)
		head.Size = Vector3.new(1.75, 7.5, 1)
		head.CollisionGroup = "Default"
		local textures = {}
		for _, side in Enum.NormalId:GetEnumItems() do
			local texture = Instance.new("Texture")
			texture.Face = side
			texture.Texture = "rbxassetid://6028276525"
			texture.Parent = head
			table.insert(textures, texture)
		end
		return function()
			arm.Size = Vector3.new(6.5, 0.75, 0.75)
			head.CustomPhysicalProperties = physicalProperties
			head.Size = Vector3.new(1.75, 2.75, 1)
			head.CollisionGroup = "cubes"
			for _, texture in textures do
				texture:Destroy()
			end
		end
	end,
	_build = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.Color = Color3.new(1, 1, 0.5)
		head.Color = Color3.new(0.1, 0.1, 0.1)
		head.Material = Enum.Material.DiamondPlate
		return function()
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	_grapple = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.BrickColor = BrickColor.new("Black")
		arm.Material = Enum.Material.DiamondPlate
		head.BrickColor = BrickColor.new("Really black")
		head.Material = Enum.Material.DiamondPlate
		return function()
			arm.BrickColor = BrickColor.new("Brown")
			arm.Material = Enum.Material.Plastic
			head.BrickColor = BrickColor.new("Dark stone grey")
			head.Material = Enum.Material.Plastic
		end
	end,
	_shotgun = function(cube, player)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		local trail = head:FindFirstChild("Trail")
		arm.Transparency = 1
		head.CanCollide = false
		head.Transparency = 1
		trail.Enabled = false
		local _result_1 = ReplicatedStorage:FindFirstChild("Shotgun")
		if _result_1 ~= nil then
			_result_1 = _result_1:Clone()
		end
		local shotgun = _result_1
		shotgun.Parent = cube
		if RunService:IsServer() then
			for _, part in shotgun:GetDescendants() do
				if part:IsA("BasePart") then
					part:SetNetworkOwner(player)
				end
			end
		end
		local weld = Instance.new("Weld")
		weld.Part0 = shotgun:FindFirstChild("Handle")
		weld.Part1 = arm
		weld.C0 = CFrame.fromOrientation(0, math.rad(90), 0)
		weld.Parent = shotgun
		return function()
			shotgun:Destroy()
			arm.Transparency = 0
			head.CanCollide = true
			head.Transparency = 0
			trail.Enabled = true
		end
	end,
	_spring = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		arm.BrickColor = BrickColor.new("Black")
		head.BrickColor = BrickColor.new("Bright blue")
		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.new(-3, 0, 0)
		attachment.Parent = arm
		local spring = Instance.new("SpringConstraint")
		spring.Attachment0 = attachment
		spring.Attachment1 = (head:FindFirstChild("ConnectionAttachment")) or attachment
		spring.MaxForce = 0
		spring.Visible = true
		spring.Color = BrickColor.new("Bright blue")
		spring.Radius = 0.6
		spring.Coils = 8
		spring.Parent = attachment
		return function()
			attachment:Destroy()
			arm.BrickColor = BrickColor.new("Brown")
			head.BrickColor = BrickColor.new("Dark stone grey")
		end
	end,
	_hitbox = function(cube)
		local arm = cube:FindFirstChild("Arm")
		local head = cube:FindFirstChild("Head")
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return emptyFunction
		end
		cube:SetAttribute("hammerTransparency", 1)
		cube:SetAttribute("transparency", 1)
		cube.Transparency = 1
		arm.Transparency = 1
		head.Transparency = 1
		local cubeOutline = Instance.new("SelectionBox")
		cubeOutline.Color3 = cube.Color
		cubeOutline.Adornee = cube
		cubeOutline.Name = "CubeOutline"
		cubeOutline.Parent = cube
		local headOutline = cubeOutline:Clone()
		headOutline.Color3 = head.Color
		headOutline.Adornee = head
		headOutline.Name = "HeadOutline"
		headOutline.Parent = head
		local armOutline = cubeOutline:Clone()
		armOutline.Color3 = arm.Color
		armOutline.Adornee = arm
		armOutline.Name = "ArmOutline"
		armOutline.Parent = arm
		return function()
			cube:SetAttribute("hammerTransparency", 0)
			cube:SetAttribute("transparency", 0)
			cube.Transparency = 0
			arm.Transparency = 0
			head.Transparency = 0
			cubeOutline:Destroy()
			headOutline:Destroy()
			armOutline:Destroy()
		end
	end,
}
local function loadAccessories(cube, data, player, hammerRemoveFunction)
	local _binding = data
	local face = _binding.face
	local hammer = _binding.hammer
	local hat = _binding.hat
	local aura = _binding.aura
	if type(face) == "string" then
		local accessoryData = accessoryList[face]
		local _result = accessoryData
		if _result ~= nil then
			_result = _result.data
		end
		if type(_result) == "string" then
			local faceDecal = cube:FindFirstChild("Face")
			faceDecal.Texture = accessoryData.data
		end
	end
	local clonedHat = cube:FindFirstChild("CLONED_HAT")
	if clonedHat then
		clonedHat:Destroy()
		local _result = cube:FindFirstChild("HatAccessory")
		if _result ~= nil then
			_result = _result:FindFirstChild("AccessoryWelder")
		end
		local accessoryWelder = _result
		if accessoryWelder then
			accessoryWelder.Attachment1 = nil
		end
	end
	if type(hat) == "string" then
		local accessoryData = accessoryList[hat]
		if accessoryData then
			local data = accessoryData.data
			local hatPart = cube:FindFirstChild("HatAccessory")
			hatPart.Transparency = 1
			local _result = hatPart:FindFirstChild("Mesh")
			if _result ~= nil then
				_result:Destroy()
			end
			if typeof(data) == "Instance" then
				if data:IsA("BasePart") then
					local _value = data:GetAttribute("weldToCube")
					if _value ~= 0 and _value == _value and _value ~= "" and _value then
						local clone = data:Clone()
						clone:PivotTo(cube.CFrame)
						clone.Name = "CLONED_HAT"
						clone.Parent = cube
						if RunService:IsServer() and player then
							task.delay(0.5, function()
								while true do
									local _value_1 = task.wait()
									if not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1) then
										break
									end
									local canSet = clone:CanSetNetworkOwnership()
									if canSet then
										break
									end
								end
								clone:SetNetworkOwner(player)
								for _, descendant in clone:GetDescendants() do
									if descendant:IsA("BasePart") then
										descendant:SetNetworkOwner(player)
									end
								end
							end)
						end
						local accessoryWelder = hatPart:FindFirstChild("AccessoryWelder")
						accessoryWelder.Attachment1 = clone:FindFirstChild("HatWeld")
					else
						local hatAttachment = hatPart:FindFirstChild("Attachment")
						hatAttachment.CFrame = (data:FindFirstChild("HatAttachment")).CFrame
						hatPart.Transparency = 0
						hatPart.Size = data.Size
						hatPart.Color = data.Color
						hatPart.Material = data.Material
						if hat == "Free Accessory" and RunService:IsServer() then
							local _result_1 = data:FindFirstChild("SurfaceGui")
							if _result_1 ~= nil then
								_result_1 = _result_1:Clone()
							end
							local surfaceGui = _result_1
							surfaceGui.Parent = hatPart
							local clickDetector = Instance.new("ClickDetector")
							clickDetector.MaxActivationDistance = math.huge
							clickDetector.Parent = hatPart
							local debounce = {}
							clickDetector.MouseClick:Connect(function(otherPlayer)
								local _condition = otherPlayer == player
								if not _condition then
									-- ▼ ReadonlyArray.find ▼
									local _callback = function(userId)
										return userId == otherPlayer.UserId
									end
									local _result_2
									for _i, _v in debounce do
										if _callback(_v, _i - 1, debounce) == true then
											_result_2 = _v
											break
										end
									end
									-- ▲ ReadonlyArray.find ▲
									_condition = _result_2
								end
								if _condition ~= 0 and _condition == _condition and _condition then
									return nil
								end
								giveBadge(otherPlayer, Badge.FreeAccessory)
								local userId = otherPlayer.UserId
								table.insert(debounce, userId)
								task.delay(1, function()
									-- ▼ ReadonlyArray.findIndex ▼
									local _callback = function(otherUserId)
										return otherUserId == userId
									end
									local _result_2 = -1
									for _i, _v in debounce do
										if _callback(_v, _i - 1, debounce) == true then
											_result_2 = _i - 1
											break
										end
									end
									-- ▲ ReadonlyArray.findIndex ▲
									local i = _result_2
									if i >= 0 then
										table.remove(debounce, i + 1)
									end
								end)
							end)
						end
						local mesh = data:FindFirstChild("Mesh")
						if mesh then
							mesh:Clone().Parent = hatPart
						end
					end
				end
			end
		end
	end
	if type(aura) == "string" then
		local accessoryData = accessoryList[aura]
		if accessoryData then
			local data = accessoryData.data
			local auraAttachment = cube:FindFirstChild("AuraAttachment")
			if not auraAttachment then
				auraAttachment = Instance.new("Attachment")
				auraAttachment.Name = "AuraAttachment"
				auraAttachment.Parent = cube
			end
			auraAttachment:ClearAllChildren()
			auraAttachment.Position = Vector3.zero
			if typeof(data) == "Instance" then
				data:Clone().Parent = auraAttachment
			end
		end
	end
	if hammerRemoveFunction ~= nil then
		TS.try(function()
			hammerRemoveFunction()
		end, function(err) end)
	end
	if type(hammer) == "string" then
		local accessoryData = accessoryList[hammer]
		local _data = accessoryData
		if _data ~= nil then
			_data = _data.data
		end
		local data = _data
		if accessoryData and type(data) == "string" then
			local hammerFunction = hammerFunctions[data]
			if type(data) == "string" and type(hammerFunction) == "function" and player then
				return hammerFunction(cube, player)
			end
		end
	end
	return nil
end
local function reloadAccessories(cube, b, hatAccessory, auraAccessory, hammerAccessory)
	if hatAccessory == nil then
		hatAccessory = Accessories.CubeHat.NoHat
	end
	if auraAccessory == nil then
		auraAccessory = Accessories.CubeAura.NoAura
	end
	if hammerAccessory == nil then
		hammerAccessory = Accessories.HammerTexture.NoHammerTexture
	end
	local cubeColor
	local _b = b
	local _condition = typeof(_b) == "Instance"
	if _condition then
		_condition = b:IsA("Player")
	end
	if _condition then
		cubeColor = (b:GetAttribute("CUBE_COLOR")) or computeNameColor(b.Name)
		hatAccessory = getCubeHat(b)
		auraAccessory = getCubeAura(b)
		hammerAccessory = getHammerTexture(b)
	else
		cubeColor = b
	end
	local hat = cube:FindFirstChild("CLONED_HAT")
	local aura = cube:FindFirstChild("AuraAttachment")
	TS.try(function()
		local _condition_1 = hatAccessory == Accessories.CubeHat.InstantGyro
		if _condition_1 then
			local _result = hat
			if _result ~= nil then
				_result = _result:IsA("BasePart")
			end
			_condition_1 = _result
		end
		if _condition_1 then
			hat.Color = Color3.new(1 - cubeColor.R, 1 - cubeColor.G, 1 - cubeColor.B)
		end
	end, function(err) end)
	TS.try(function()
		if auraAccessory == Accessories.CubeAura.Glow and aura then
			local _result = aura:FindFirstChild("Glow")
			if _result ~= nil then
				_result = _result:FindFirstChild("Glow")
			end
			_result.Color = ColorSequence.new(cubeColor)
		end
	end, function(err) end)
	TS.try(function()
		hammerAccessory = Accessories.HammerTexture.HitboxHammer
		if hammerAccessory then
			(cube:FindFirstChild("CubeOutline")).Color3 = cubeColor
		end
	end, function(err) end)
	print("[src/shared/accessory_loader.ts:560]", `Updated accessories for {cube.Name}`)
end
return {
	loadAccessories = loadAccessories,
	reloadAccessories = reloadAccessories,
	accessoryList = accessoryList,
	hammerFunctions = hammerFunctions,
}
