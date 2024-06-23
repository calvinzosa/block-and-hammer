-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local CollectionService = _services.CollectionService
local ReplicatedStorage = _services.ReplicatedStorage
local GeometryService = _services.GeometryService
local TweenService = _services.TweenService
local RunService = _services.RunService
local Lighting = _services.Lighting
local Players = _services.Players
local Debris = _services.Debris
local Workspace = _services.Workspace
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local getSetting = _utils.getSetting
local getHammerTexture = _utils.getHammerTexture
local Accessories = _utils.Accessories
local GameSetting = _utils.GameSetting
local tweenTypes = _utils.tweenTypes
local randomFloat = _utils.randomFloat
local randomDirection = _utils.randomDirection
local playSound = _utils.playSound
local waitUntil = _utils.waitUntil
local getPartId = _utils.getPartId
local isClientCube = _utils.isClientCube
local getTime = _utils.getTime
local convertStudsToMeters = _utils.convertStudsToMeters
local numLerp = _utils.numLerp
local Events = {
	DestroyedPart = ReplicatedStorage:WaitForChild("DestroyedPart"),
	GroundImpact = ReplicatedStorage:WaitForChild("GroundImpact"),
	BreakPart = ReplicatedStorage:WaitForChild("BreakPart"),
	ShatterPart = ReplicatedStorage:WaitForChild("ShatterPart"),
	ClientCreateDebris = ReplicatedStorage:WaitForChild("ClientCreateDebris"),
	MakeReplayEvent = ReplicatedStorage:WaitForChild("MakeReplayEvent"),
	ClientRagdoll = ReplicatedStorage:WaitForChild("ClientRagdoll"),
}
local StrokeScale = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("StrokeScale"))
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local valueInstances = GUI:WaitForChild("Values")
local canMove = valueInstances:WaitForChild("can_move")
local isSpectating = valueInstances:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local shakeIntensity = valueInstances:WaitForChild("shake_intensity")
local speedLines = screenGui:WaitForChild("SpeedLines")
local mapFolder = Workspace:WaitForChild("Map")
local nonBreakable = Workspace:WaitForChild("NonBreakable")
local effectsFolder = Workspace:WaitForChild("Effects")
local debrisTypes = ReplicatedStorage:WaitForChild("DebrisTypes")
local sfx = ReplicatedStorage:WaitForChild("SFX")
local wind = sfx:WaitForChild("wind")
local subtractOptions = {
	CollisionFidelity = Enum.CollisionFidelity.Default,
}
local prevCubePosition = nil
local geometryDebounce = false
local debounce = false
local speedIndex = 0
local currentVelocity = Vector3.new(0, 0, 0)
local lastVelocity = Vector3.new(0, 0, 0)
local cube = nil
local head = nil
local speedImages = { "rbxassetid://13484709347", "rbxassetid://13484709591", "rbxassetid://13484709832", "rbxassetid://13484710115", "rbxassetid://13484710536" }
local function createDebris(velocity, position, part, multiplier, createHole, hammerTexture)
	if createHole == nil then
		createHole = false
	end
	if hammerTexture == nil then
		hammerTexture = getHammerTexture()
	end
	local multiplierArray
	local originalMultiplier = 1
	local _multiplier = multiplier
	if type(_multiplier) == "number" then
		originalMultiplier = multiplier
		multiplierArray = { 5 * multiplier, 15 * multiplier }
	else
		multiplierArray = multiplier
	end
	local point = part:GetClosestPointOnSurface(position)
	local normal = (position - point).Unit
	if getSetting(GameSetting.Effects) then
		if originalMultiplier == 1 and createHole then
			local circle = Instance.new("Part")
			circle.CanCollide = false
			local _exp = CFrame.lookAlong(point, normal)
			local _arg0 = CFrame.fromOrientation(0, math.pi / 2, 0)
			circle.CFrame = _exp * _arg0
			circle.Shape = Enum.PartType.Cylinder
			circle.Size = Vector3.new(0.001, 1, 1)
			circle.Color = Color3.fromRGB(0, 0, 0)
			circle.Transparency = 0.5
			circle.TopSurface = Enum.SurfaceType.Smooth
			circle.BottomSurface = Enum.SurfaceType.Smooth
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = circle
			weld.Part1 = part
			weld.Parent = circle
			task.delay(5, function()
				TweenService:Create(circle, tweenTypes.linear.short, {
					Transparency = 1,
				}):Play()
				Debris:AddItem(circle, 1)
			end)
			circle.Parent = effectsFolder
		end
		if hammerTexture == Accessories.HammerTexture.GodsHammer then
			multiplierArray = { 20, 25 }
		end
		if #effectsFolder:GetChildren() < 600 then
			local types = debrisTypes:GetChildren()
			if #types > 0 then
				local totalDebris = math.random(multiplierArray[1], multiplierArray[2])
				do
					local i = 1
					local _shouldIncrement = false
					while true do
						if _shouldIncrement then
							i += 1
						else
							_shouldIncrement = true
						end
						if not (i < totalDebris) then
							break
						end
						local debris = types[math.random(0, #types - 1) + 1]:Clone()
						debris.Anchored = false
						debris.CFrame = CFrame.new(position)
						local _vector3 = Vector3.new(1, 1, 1)
						local _arg0 = randomFloat(0.5, 1.5)
						debris.Size = _vector3 * _arg0
						debris.Color = part.Color
						debris.Material = part.Material
						debris.Transparency = part.Transparency
						debris.LocalTransparencyModifier = part.LocalTransparencyModifier
						debris.Parent = effectsFolder
						if originalMultiplier == 1 then
							if hammerTexture == Accessories.HammerTexture.Hammer404 then
								debris.Material = Enum.Material.Neon
								debris.Color = if math.random() < 0.5 then Color3.fromRGB(0, 0, 0) else Color3.fromRGB(255, 0, 255)
								debris:AddTag("ErrorEffects")
							elseif hammerTexture == Accessories.HammerTexture.GoldenHammer then
								debris.Material = Enum.Material.Foil
								debris.Color = Color3.fromRGB(255, 255, 128)
							elseif hammerTexture == Accessories.HammerTexture.GodsHammer then
								debris.Material = Enum.Material.Neon
								debris.Color = Color3.fromRGB(255, 255, 255)
							end
						end
						local _exp = randomDirection(velocity.Magnitude / -4)
						local _arg0_1 = velocity.Unit * 20
						debris.AssemblyLinearVelocity = _exp + _arg0_1
						debris.AssemblyAngularVelocity = randomDirection()
						task.delay(1, function()
							TweenService:Create(debris, tweenTypes.linear.short, {
								Transparency = 1,
							}):Play()
							Debris:AddItem(debris, 1)
						end)
					end
				end
			end
		end
	end
	if originalMultiplier == 1 then
		if hammerTexture == Accessories.HammerTexture.Hammer404 then
			playSound("error2", {
				PlaybackSpeed = randomFloat(1, 1.05),
				Volume = velocity.Magnitude / 7.5,
			}, true)
		elseif hammerTexture == Accessories.HammerTexture.GoldenHammer then
			task.delay(0.15, function()
				return playSound("money", {
					PlaybackSpeed = randomFloat(0.95, 1),
					Volume = velocity.Magnitude / 15,
				}, true)
			end)
		elseif hammerTexture == Accessories.HammerTexture.GodsHammer then
			playSound("lightning_bolt", {
				PlaybackSpeed = randomFloat(0.95, 1),
				Volume = velocity.Magnitude / 15,
			}, true)
		elseif hammerTexture == Accessories.HammerTexture.IcyHammer then
			playSound("shatter", {
				PlaybackSpeed = randomFloat(0.9, 1),
			}, true)
		end
		playSound("hit2", {
			PlaybackSpeed = randomFloat(0.9, 1),
			Volume = velocity.Magnitude / 7.5,
		})
	end
end
local function normalToFace(normalVector, part)
	local function getNormalFromFace(normalId)
		return part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(normalId))
	end
	for _, normalId in Enum.NormalId:GetEnumItems() do
		if getNormalFromFace(normalId):Dot(normalVector) > 0.999 then
			return normalId
		end
	end
	return nil
end
local function breakPart(otherPart, head, isOnlyEffect)
	if isOnlyEffect == nil then
		isOnlyEffect = false
	end
	createDebris(head.AssemblyLinearVelocity, head.Position, otherPart, 1, false)
	local particles = otherPart:FindFirstChildWhichIsA("ParticleEmitter")
	if particles then
		particles:Emit(math.random(20, 30))
	end
	if not isOnlyEffect then
		otherPart.CanCollide = false
		otherPart.LocalTransparencyModifier = 0.75
		for _, descendant in otherPart:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = 1
			end
		end
	end
	if getSetting(GameSetting.CSG) then
		local model = Instance.new("Model")
		otherPart:Clone().Parent = model
		local _, boundingBox = model:GetBoundingBox()
		model:Destroy()
		local closestPoint = otherPart:GetClosestPointOnSurface(head.Position)
		local maxSize = math.max(boundingBox.X, boundingBox.Y, boundingBox.Z)
		local flingVector = Vector3.new(0, 30, 0)
		if otherPart:IsA("UnionOperation") then
			local piece = otherPart:Clone()
			piece.Anchored = false
			piece.CanCollide = true
			piece.CollisionGroup = "debris"
			piece.AssemblyLinearVelocity = (piece:GetClosestPointOnSurface(closestPoint) - closestPoint).Unit * 10 + flingVector
			piece.AssemblyAngularVelocity = randomDirection()
			piece.Parent = effectsFolder
			TweenService:Create(piece, tweenTypes.linear.medium, {
				Transparency = 1,
			}):Play()
			Debris:AddItem(piece, tweenTypes.linear.medium.Time)
		else
			local slicers = {}
			for i = 1, 6 do
				local plane = Instance.new("Part")
				plane.CanCollide = false
				plane.Anchored = true
				plane.Transparency = 1
				local _fn = CFrame
				local _position = otherPart.Position
				local _arg0 = randomDirection(boundingBox / 2)
				plane.CFrame = _fn.lookAlong(_position + _arg0, randomDirection())
				plane.Size = Vector3.new(0.5, maxSize * 3, maxSize * 3)
				plane.Parent = effectsFolder
				table.insert(slicers, plane)
			end
			local pieces = GeometryService:SubtractAsync(otherPart, slicers, subtractOptions)
			for _1, piece in pieces do
				piece.Anchored = false
				piece.CanCollide = true
				piece.CollisionGroup = "debris"
				piece.AssemblyLinearVelocity = (piece:GetClosestPointOnSurface(closestPoint) - closestPoint).Unit * 10 + flingVector
				piece.AssemblyAngularVelocity = randomDirection()
				piece.Parent = effectsFolder
				TweenService:Create(piece, tweenTypes.linear.medium, {
					Transparency = 1,
				}):Play()
				Debris:AddItem(piece, tweenTypes.linear.medium.Time)
			end
		end
	end
	if not isOnlyEffect then
		otherPart.LocalTransparencyModifier = 1
	end
	waitUntil(function()
		local _condition = cube
		if _condition then
			local _position = cube.Position
			local _arg0 = otherPart:GetClosestPointOnSurface(cube.Position)
			_condition = (_position - _arg0).Magnitude > 25
		end
		return _condition
	end, 14)
	if not isOnlyEffect then
		local partId = getPartId(otherPart)
		local dataString = string.format("respawn,%s", partId)
		Events.MakeReplayEvent:Fire(dataString)
		otherPart:SetAttribute("CAN_BREAK", false)
		TweenService:Create(otherPart, tweenTypes.linear.short, {
			LocalTransparencyModifier = 0,
		}):Play()
		for _, descendant in otherPart:GetDescendants() do
			if descendant:IsA("BasePart") then
				TweenService:Create(descendant, tweenTypes.linear.short, {
					LocalTransparencyModifier = 0,
				}):Play()
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				TweenService:Create(descendant, tweenTypes.linear.short, {
					Transparency = 0,
				}):Play()
			end
		end
		task.wait(tweenTypes.linear.short.Time)
		otherPart.CanCollide = true
		otherPart:SetAttribute("CAN_BREAK", true)
	end
end
local function shatterPart(otherPart, head, isOnlyEffect)
	if isOnlyEffect == nil then
		isOnlyEffect = false
	end
	local thickness = 0.5
	if isOnlyEffect then
		thickness = 0.001
	end
	if not isOnlyEffect then
		otherPart.CanCollide = false
		otherPart.LocalTransparencyModifier = 0.75
		for _, descendant in otherPart:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = 1
			end
		end
		playSound("shatter", {
			PlaybackSpeed = randomFloat(0.9, 1),
		})
	end
	if getSetting(GameSetting.CSG) then
		local model = Instance.new("Model")
		otherPart:Clone().Parent = model
		local _, boundingBox = model:GetBoundingBox()
		model:Destroy()
		local closestPoint = otherPart:GetClosestPointOnSurface(head.Position)
		local maxSize = math.max(boundingBox.X, boundingBox.Y, boundingBox.Z)
		local flingVector = Vector3.new(0, 30, 0)
		if otherPart:IsA("UnionOperation") then
			local piece = otherPart:Clone()
			piece.Anchored = false
			piece.CanCollide = true
			piece.CollisionGroup = "debris"
			piece.AssemblyLinearVelocity = (piece:GetClosestPointOnSurface(closestPoint) - closestPoint).Unit * 10 + flingVector
			piece.AssemblyAngularVelocity = randomDirection()
			piece.Parent = effectsFolder
			TweenService:Create(piece, tweenTypes.linear.medium, {
				Transparency = 1,
			}):Play()
			Debris:AddItem(piece, tweenTypes.linear.medium.Time)
		else
			local slicers = {}
			for i = 1, 6 do
				local plane = Instance.new("Part")
				plane.CanCollide = false
				plane.Anchored = true
				plane.Transparency = 1
				plane.CFrame = CFrame.lookAlong(closestPoint, randomDirection())
				plane.Size = Vector3.new(thickness, maxSize * 3, maxSize * 3)
				plane.Parent = effectsFolder
				table.insert(slicers, plane)
			end
			for i = 1, 3 do
				local plane = Instance.new("Part")
				plane.CanCollide = false
				plane.Anchored = true
				plane.Transparency = 1
				local _fn = CFrame
				local _position = otherPart.Position
				local _arg0 = randomDirection(boundingBox / 2)
				plane.CFrame = _fn.lookAlong(_position + _arg0, randomDirection())
				plane.Size = Vector3.new(thickness, maxSize * 3, maxSize * 3)
				plane.Parent = effectsFolder
				table.insert(slicers, plane)
			end
			local pieces = GeometryService:SubtractAsync(otherPart, slicers, subtractOptions)
			for _1, piece in pieces do
				piece.Anchored = false
				piece.CanCollide = true
				piece.CollisionGroup = "debris"
				piece.AssemblyLinearVelocity = (piece:GetClosestPointOnSurface(closestPoint) - closestPoint).Unit * 10 + flingVector
				piece.AssemblyAngularVelocity = randomDirection()
				piece.Parent = effectsFolder
				TweenService:Create(piece, tweenTypes.linear.medium, {
					Transparency = 1,
				}):Play()
				Debris:AddItem(piece, tweenTypes.linear.medium.Time)
			end
		end
	end
	if not isOnlyEffect then
		otherPart.LocalTransparencyModifier = 1
	end
	waitUntil(function()
		local _condition = cube
		if _condition then
			local _position = cube.Position
			local _arg0 = otherPart:GetClosestPointOnSurface(cube.Position)
			_condition = (_position - _arg0).Magnitude > 25
		end
		return _condition
	end, 14)
	if not isOnlyEffect then
		local partId = getPartId(otherPart)
		local dataString = string.format("respawn,%s", partId)
		Events.MakeReplayEvent:Fire(dataString)
		otherPart:SetAttribute("CAN_SHATTER", false)
		TweenService:Create(otherPart, tweenTypes.linear.short, {
			LocalTransparencyModifier = 0,
		}):Play()
		for _, descendant in otherPart:GetDescendants() do
			if descendant:IsA("BasePart") then
				TweenService:Create(descendant, tweenTypes.linear.short, {
					LocalTransparencyModifier = 0,
				}):Play()
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				TweenService:Create(descendant, tweenTypes.linear.short, {
					Transparency = 0,
				}):Play()
			end
		end
		task.wait(tweenTypes.linear.short.Time)
		otherPart.CanCollide = true
		otherPart:SetAttribute("CAN_SHATTER", true)
	end
end
local function newMapObject(object)
	if object:IsA("BasePart") then
		object.AttributeChanged:Connect(function(attr)
			if not head then
				return nil
			end
			local _value = attr == "FORCE_BREAK" and object:GetAttribute(attr)
			if _value ~= 0 and _value == _value and _value ~= "" and _value then
				object:SetAttribute(attr, nil)
				breakPart(object, head)
			else
				local _value_1 = attr == "FORCE_SHATTER" and object:GetAttribute(attr)
				if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
					object:SetAttribute(attr, nil)
					shatterPart(object, head)
				end
			end
		end)
	end
end
local function newPart(part)
	local _value = part:GetAttribute("isCube")
	local _condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
	if not _condition then
		_condition = part:GetAttribute("processed")
		if not (_condition ~= 0 and _condition == _condition and _condition ~= "" and _condition) then
			_condition = not part:IsA("BasePart")
		end
	end
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		return nil
	end
	part:SetAttribute("processed", true)
	print("[src/client/visual_effects.client.ts:411]", `Cube added: {part.Name} (Client: cube{player.UserId})`)
	StrokeScale:ScaleBillboardGui(part:WaitForChild("OverheadGUI"), 950)
	if not isClientCube(part) then
		return nil
	end
	print("[src/client/visual_effects.client.ts:417]", "> Client cube respawned")
	cube = part
	head = cube:WaitForChild("Head")
	head.Touched:Connect(function(otherPart)
		if not head or not cube then
			return nil
		end
		local _condition_1 = debounce or not otherPart or not otherPart.CanCollide
		if not _condition_1 then
			_condition_1 = otherPart:GetAttribute("notCollidable")
			if not (_condition_1 ~= 0 and _condition_1 == _condition_1 and _condition_1 ~= "" and _condition_1) then
				local _condition_2 = cube:GetAttribute("ragdollTime")
				if _condition_2 == nil then
					_condition_2 = 0
				end
				_condition_1 = _condition_2 ~= 0
			end
		end
		if _condition_1 ~= 0 and _condition_1 == _condition_1 and _condition_1 ~= "" and _condition_1 then
			return nil
		end
		RunService.Stepped:Wait()
		local hammerTexture = getHammerTexture()
		local otherVelocity = otherPart.AssemblyLinearVelocity
		local minSpeed = 175
		if otherPart:IsDescendantOf(mapFolder) then
			local _exp = currentVelocity - otherVelocity
			local _assemblyLinearVelocity = cube.AssemblyLinearVelocity
			local newVelocity = ((_exp - _assemblyLinearVelocity) / 4).Magnitude
			local _value_1 = player:GetAttribute("ERROR_LAND")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				newVelocity *= 2
			end
			if hammerTexture == Accessories.HammerTexture.SteelHammer and getSetting(GameSetting.Modifiers) then
				newVelocity *= 1.5
			end
			if newVelocity > 165 then
				if otherPart.Material ~= Enum.Material.DiamondPlate then
					Events.DestroyedPart:FireServer(otherPart)
					local partId = getPartId(otherPart)
					local dataString = nil
					local removeBreaks = hammerTexture == Accessories.HammerTexture.SteelHammer and getSetting(GameSetting.Modifiers)
					local canBreak = otherPart:GetAttribute("CAN_BREAK")
					local canShatter = otherPart:GetAttribute("CAN_SHATTER")
					local _condition_2 = canBreak
					if _condition_2 ~= 0 and _condition_2 == _condition_2 and _condition_2 ~= "" and _condition_2 then
						_condition_2 = not removeBreaks
					end
					if _condition_2 ~= 0 and _condition_2 == _condition_2 and _condition_2 ~= "" and _condition_2 then
						task.spawn(breakPart, otherPart, head)
						dataString = string.format("break,%s", partId)
					else
						local _condition_3 = canShatter
						if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 ~= "" and _condition_3 then
							_condition_3 = not removeBreaks
						end
						if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 ~= "" and _condition_3 then
							task.spawn(shatterPart, otherPart, head)
							dataString = string.format("shatter,%s", partId)
						else
							local velocity = head.AssemblyLinearVelocity
							local position = otherPart:GetClosestPointOnSurface(head.Position)
							createDebris(velocity, position, otherPart, 1, true)
							dataString = string.format("destroy,%d,%d,%d,%d,%d,%d,%s", math.round(position.X * 1000), math.round(position.Y * 1000), math.round(position.Z * 1000), math.round(velocity.X * 1000), math.round(velocity.Y * 1000), math.round(velocity.Z * 1000), partId)
						end
					end
					if dataString ~= "" and dataString then
						Events.MakeReplayEvent:Fire(dataString)
					end
					if hammerTexture == Accessories.HammerTexture.Hammer404 and getSetting(GameSetting.Effects) then
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Include
						params.FilterDescendantsInstances = { otherPart }
						local _fn = Workspace
						local _exp_1 = head.Position
						local _position = otherPart.Position
						local _position_1 = head.Position
						local result = _fn:Raycast(_exp_1, _position - _position_1, params)
						if result then
							local normal = normalToFace(result.Normal, otherPart)
							if normal then
								local texture = Instance.new("Texture")
								texture.Texture = "rbxassetid://9994130132"
								texture.Face = normal
								texture.Name = "ERROR_TEXTURE"
								texture.Parent = otherPart
								task.spawn(function()
									local currentTime = getTime()
									local startTime = currentTime
									local endTime = startTime + 1
									while currentTime < endTime do
										currentTime = getTime()
										local totalTime = currentTime - startTime
										texture.Transparency = math.clamp(totalTime * 2, 0, 1)
										texture.OffsetStudsU = math.random() * 2 - 1
										texture.OffsetStudsV = math.random() * 2 - 1
										RunService.RenderStepped:Wait()
									end
									texture:Destroy()
								end)
							end
						end
					elseif hammerTexture == Accessories.HammerTexture.SteelHammer and getSetting(GameSetting.Modifiers) and not otherPart:IsA("UnionOperation") then
						if geometryDebounce or otherPart.Size.Magnitude > 750 then
							return nil
						end
						geometryDebounce = true
						local area = Instance.new("Part")
						area.Size = Vector3.one * 9
						area.Position = head.Position
						area.Shape = Enum.PartType.Ball
						area.Color = otherPart.Color
						local params = OverlapParams.new()
						params.FilterType = Enum.RaycastFilterType.Include
						params.FilterDescendantsInstances = { mapFolder }
						local options = {
							SplitApart = false,
							CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
						}
						local subtractedPart = (GeometryService:SubtractAsync(otherPart, { area }, options))[2]
						if subtractedPart then
							subtractedPart.Anchored = false
							subtractedPart:SetAttribute("steelHammered", true)
							subtractedPart.Parent = otherPart.Parent
							local weld = Instance.new("Weld")
							weld.Part0 = subtractedPart
							weld.Part1 = otherPart
							local _value_2 = otherPart:IsA("PartOperation") and otherPart:GetAttribute("steelHammered")
							if _value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2 then
								local original = otherPart:FindFirstChild("original")
								if not original then
									subtractedPart:Destroy()
									return nil
								end
								original.Parent = subtractedPart
								otherPart:Destroy()
								weld.Part1 = original.Value
							else
								local objectValue = Instance.new("ObjectValue")
								objectValue.Name = "original"
								objectValue.Value = otherPart
								objectValue.Parent = subtractedPart
								otherPart.Transparency = 1
								otherPart.CanCollide = false
								otherPart:SetAttribute("broken", true)
							end
							weld.Parent = subtractedPart
							task.delay(15, function()
								local value = subtractedPart:FindFirstChild("original")
								local _condition_3 = subtractedPart.Parent
								if _condition_3 then
									local _result = value
									if _result ~= nil then
										_result = _result.Value
										if _result ~= nil then
											_result = _result:GetAttribute("broken")
										end
									end
									_condition_3 = _result
								end
								if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 ~= "" and _condition_3 then
									local originalPart = value.Value
									originalPart:SetAttribute("broken", nil)
									originalPart.Transparency = 0
									originalPart.CanCollide = true
									subtractedPart:Destroy()
								end
							end)
							area:Destroy()
							geometryDebounce = false
						else
							otherPart.Transparency = 1
							otherPart.CanCollide = false
							otherPart:SetAttribute("broken", true)
							task.delay(15, function()
								otherPart:SetAttribute("broken", nil)
								otherPart.Transparency = 0
								otherPart.CanCollide = true
							end)
							geometryDebounce = false
						end
					elseif hammerTexture == Accessories.HammerTexture.IcyHammer and getSetting(GameSetting.Modifiers) then
						local arm = cube:FindFirstChild("Arm")
						local trail = head:FindFirstChild("Trail")
						local _value_2 = not arm or not trail or cube:GetAttribute("shatteredHammer")
						if _value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2 then
							return nil
						end
						arm.CanCollide = false
						head.CanCollide = false
						trail.Enabled = false
						canMove.Value = false
						cube:SetAttribute("shatteredHammer", true)
						cube:SetAttribute("hammerTransparency", 1)
						cube:SetAttribute("instantHammerTransparent", 1)
						task.spawn(shatterPart, arm, head, true)
						task.spawn(shatterPart, head, head, true)
						task.delay(5, function()
							canMove.Value = true
							local _result = cube
							if _result ~= nil then
								_result = _result.Parent
							end
							local _condition_3 = not _result
							if not _condition_3 then
								_condition_3 = not head or not arm or not trail
							end
							if _condition_3 then
								return nil
							end
							if getHammerTexture() == Accessories.HammerTexture.IcyHammer then
								cube:SetAttribute("hammerTransparency", 0.25)
							else
								cube:SetAttribute("hammerTransparency", nil)
							end
							cube:SetAttribute("shatteredHammer", nil)
							arm.CFrame = cube.CFrame
							head.CanCollide = true
							trail.Enabled = true
						end)
					end
				else
					local headVelocity = head.AssemblyLinearVelocity
					local point = otherPart:GetClosestPointOnSurface(head.Position)
					local _position = otherPart.Position
					local _position_1 = head.Position
					local normal = (_position - _position_1).Unit
					if getSetting(GameSetting.Effects) then
						local _result = ReplicatedStorage:FindFirstChild("Particles")
						if _result ~= nil then
							_result = _result:FindFirstChild("spark")
						end
						local sparkTemplate = _result
						if sparkTemplate then
							local circle = Instance.new("Part")
							circle.CanCollide = false
							local _exp_1 = CFrame.lookAlong(point, normal)
							local _arg0 = CFrame.fromOrientation(0, math.pi / 2, 0)
							circle.CFrame = _exp_1 * _arg0
							circle.Size = Vector3.new(0.001, 1, 1)
							circle.Shape = Enum.PartType.Cylinder
							circle.Color = Color3.fromRGB(0, 0, 0)
							circle.Transparency = 0.5
							circle.TopSurface = Enum.SurfaceType.Smooth
							circle.BottomSurface = Enum.SurfaceType.Smooth
							circle.Parent = effectsFolder
							local spark = sparkTemplate:Clone()
							spark.CFrame = CFrame.lookAlong(point, headVelocity.Unit * (-1))
							spark.Parent = effectsFolder
							local particleEmitter = spark:FindFirstChild("ParticleEmitter")
							task.delay(0.15, function()
								particleEmitter.Enabled = false
								return particleEmitter.Enabled
							end)
							Debris:AddItem(spark, 5)
						end
					end
					local dataString = string.format("spark,%d,%d,,,%d,%d,,", math.round(point.X * 1000), math.round(point.Y * 1000), math.round(headVelocity.X * 1000), math.round(headVelocity.Y * 1000))
					Events.MakeReplayEvent:Fire(dataString)
					playSound("hit1", {
						PlaybackSpeed = randomFloat(0.7, 0.8),
						Volume = headVelocity.Magnitude / 15,
					}, true)
				end
				shakeIntensity.Value = math.clamp(head.AssemblyLinearVelocity.Magnitude / 45, 0.5, 1)
				if hammerTexture == Accessories.HammerTexture.ExplosiveHammer then
					if getSetting(GameSetting.Modifiers) then
						local _assemblyLinearVelocity_1 = cube.AssemblyLinearVelocity
						local _position = cube.Position
						local _position_1 = head.Position
						local _arg0 = (_position - _position_1).Unit * 250
						cube.AssemblyLinearVelocity = _assemblyLinearVelocity_1 + _arg0
					end
					if getSetting(GameSetting.Effects) then
						createDebris(head.AssemblyLinearVelocity * 10, head.Position, otherPart, 2.5)
						local explosion = Instance.new("Explosion")
						explosion.Position = head.Position
						explosion.BlastRadius = 0
						explosion.BlastPressure = 0
						explosion.Parent = effectsFolder
						local dataString = string.format("explosion,%d,%d,%d", math.round(head.Position.X * 1000), math.round(head.Position.Y * 1000), math.round(head.Position.Z * 1000), math.round((head.AssemblyLinearVelocity.Magnitude / 5) * 1000))
						Events.MakeReplayEvent:Fire(dataString)
					end
					playSound("explosion", {
						PlaybackSpeed = randomFloat(0.9, 1),
						Volume = head.AssemblyLinearVelocity.Magnitude / 5,
					}, true)
					shakeIntensity.Value = 2
				end
			elseif newVelocity > 50 then
				local point = otherPart:GetClosestPointOnSurface(head.Position)
				local _position = otherPart.Position
				local _position_1 = head.Position
				local normal = _position - _position_1
				local headVelocity = head.AssemblyLinearVelocity
				local unitVelocity = headVelocity.Unit
				if getSetting(GameSetting.Effects) then
					local _result = ReplicatedStorage:FindFirstChild("Particles")
					if _result ~= nil then
						_result = _result:FindFirstChild("spark")
					end
					local sparkTemplate = _result
					if sparkTemplate then
						local spark = sparkTemplate:Clone()
						spark.CFrame = CFrame.lookAlong(point, unitVelocity * (-1))
						spark.Parent = effectsFolder
						Debris:AddItem(spark, 5)
						local particleEmitter = spark:FindFirstChild("ParticleEmitter")
						task.delay(0.1, function()
							particleEmitter.Enabled = false
							return particleEmitter.Enabled
						end)
					end
				end
				local dataString = string.format("spark,%d,%d,,%d,%d,", math.round(point.X * 1000), math.round(point.Y * 1000), math.round(headVelocity.X * 1000), math.round(headVelocity.Y * 1000))
				Events.MakeReplayEvent:Fire(dataString)
				playSound("hit1", {
					PlaybackSpeed = randomFloat(0.9, 1),
					Volume = headVelocity.Magnitude / 30,
				}, true)
			end
			debounce = true
			task.delay(0.25, function()
				debounce = false
				return debounce
			end)
		elseif otherPart:IsDescendantOf(nonBreakable) then
			local newVelocity = (currentVelocity - otherVelocity).Magnitude
			local _value_1 = player:GetAttribute("ERROR_LAND")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				newVelocity *= 2
			end
			if newVelocity > 50 then
				playSound("fabric_hit", {
					PlaybackSpeed = randomFloat(0.9, 1),
					Volume = head.AssemblyLinearVelocity.Magnitude / 30,
				})
			end
			debounce = true
			task.delay(0.25, function()
				debounce = false
				return debounce
			end)
		end
	end)
end
Events.BreakPart.Event:Connect(breakPart)
Events.ShatterPart.Event:Connect(shatterPart)
Events.ClientCreateDebris.Event:Connect(createDebris)
for _, descendant in mapFolder:GetDescendants() do
	newMapObject(descendant)
end
mapFolder.DescendantAdded:Connect(newMapObject)
for _, part in Workspace:GetChildren() do
	task.spawn(newPart, part)
end
Workspace.ChildAdded:Connect(newPart)
RunService.Stepped:Connect(function(_, dt)
	if not head or not cube then
		return nil
	end
	local targetCube = cube
	if isSpectating.Value then
		local otherPlayer = Players:FindFirstChild(spectatePlayer.Value)
		if otherPlayer then
			targetCube = Workspace:FindFirstChild(`cube{otherPlayer.UserId}`) or targetCube
		end
	end
	targetCube = Workspace:FindFirstChild("REPLAY_VIEW") or targetCube
	local _value = player:GetAttribute("ERROR_LAND")
	if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
		Workspace:SetAttribute("default_gravity", 196.2)
		local targetTime = 14.5
		local _binding = convertStudsToMeters(targetCube.Position.Y - 1.9)
		local altitude = _binding[1]
		if altitude < 100 then
			targetTime = 14.5
		elseif altitude < 200 then
			targetTime = 6.4
		elseif altitude < 300 then
			targetTime = 12
		elseif altitude < 400 then
			targetTime = 5
		elseif altitude < 500 then
			targetTime = 3
		else
			local percent = math.clamp((altitude - 700) / 100, -1, 1)
			targetTime += 9.5 * (percent + 1) / 2
			Workspace:SetAttribute("default_Gravity", 88.1 * (1 - percent) + 20)
		end
		Lighting.ClockTime = numLerp(Lighting.ClockTime, targetTime, dt * 2)
	end
	local velocity = targetCube.AssemblyLinearVelocity
	local _value_1 = player:GetAttribute("in_main_menu")
	local _condition = not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1)
	if _condition then
		_condition = screenGui.Enabled
	end
	if _condition then
		camera.FieldOfView = 70 + math.max(velocity.Magnitude - 100, 0) / 5
		local percent = if getSetting(GameSetting.Sounds) then math.max((velocity.Magnitude - 100) / 300, 0) else 0
		wind.Volume = percent * 3
	end
	lastVelocity = currentVelocity
	currentVelocity = head.AssemblyLinearVelocity
	local previousVelocity = cube:GetAttribute("lastVelocity")
	if typeof(previousVelocity) == "Vector3" then
		local _assemblyLinearVelocity = cube.AssemblyLinearVelocity
		local _lastVelocity = lastVelocity
		local relativeVelocity = _assemblyLinearVelocity - _lastVelocity
		if relativeVelocity.Magnitude > 300 then
			Events.GroundImpact:FireServer(relativeVelocity, cube.Position)
			if getSetting(GameSetting.Effects) then
				createDebris(relativeVelocity * 3.5, cube.Position, cube, 6)
				local explosion = Instance.new("Explosion")
				explosion.Position = cube.Position
				explosion.BlastRadius = 0
				explosion.BlastPressure = 0
				explosion.Parent = effectsFolder
				local dataString = string.format("explosion,%d,%d,,%d", math.round(cube.Position.X * 1000), math.round(cube.Position.Y * 1000), math.round((cube.AssemblyLinearVelocity.Magnitude / 10) * 1000))
				Events.MakeReplayEvent:Fire(dataString)
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Include
				params.FilterDescendantsInstances = { mapFolder }
				local createdParts = {}
				local Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				local radius = 10 * (relativeVelocity.Magnitude / 300)
				local _one = Vector3.one
				local _arg0 = 6 * math.sqrt(radius / 10)
				local debrisSize = _one * _arg0
				local step = (debrisSize.Magnitude / radius) * 35
				for angle = 0, 360, step or 1 do
					local radians = math.rad(angle)
					local axis = CFrame.fromAxisAngle(relativeVelocity.Unit, radians)
					local _cFrame = CFrame.new(radius, 0, 0)
					local relativePosition = (axis * _cFrame).Position
					local result = Workspace:Raycast(cube.Position + relativePosition, relativeVelocity * (-4), params)
					if result then
						local part = Instance.new("Part")
						part.Anchored = true
						part.CanCollide = false
						part.Size = Vector3.zero
						part.CFrame = CFrame.lookAlong(result.Position, randomDirection())
						part.Material = result.Material
						part.Color = result.Instance.Color
						part.TopSurface = Enum.SurfaceType.Smooth
						part.BottomSurface = Enum.SurfaceType.Smooth
						part.Parent = effectsFolder
						TweenService:Create(part, Info, {
							Size = debrisSize,
						}):Play()
						table.insert(createdParts, part)
					end
				end
				task.delay(Info.Time + 5, function()
					local OuterInfo = TweenInfo.new(math.min(relativeVelocity.Magnitude / 30, 10), Enum.EasingStyle.Linear)
					for _1, part in createdParts do
						TweenService:Create(part, OuterInfo, {
							Size = Vector3.zero,
							Transparency = 1,
						}):Play()
						Debris:AddItem(part, Info.Time)
					end
				end)
			end
			Events.ClientRagdoll:Fire(1.4)
			shakeIntensity.Value = 4
			playSound("explosion", {
				PlaybackSpeed = randomFloat(0.9, 1),
				Volume = cube.AssemblyLinearVelocity.Magnitude / 10,
			})
		elseif relativeVelocity.Magnitude > 165 then
			Events.GroundImpact:FireServer(relativeVelocity, cube.Position)
			if getSetting(GameSetting.Effects) then
				createDebris(cube.AssemblyLinearVelocity * 3.5, cube.Position, cube, 6)
				local explosion = Instance.new("Explosion")
				explosion.Position = cube.Position
				explosion.BlastRadius = 0
				explosion.BlastPressure = 0
				explosion.Parent = effectsFolder
				local dataString = string.format("explosion,%d,%d,,%d", math.round(cube.Position.X * 1000), math.round(cube.Position.Y * 1000), math.round((cube.AssemblyLinearVelocity.Magnitude / 10) * 1000))
				Events.MakeReplayEvent:Fire(dataString)
			end
			Events.ClientRagdoll:Fire(1.4)
			shakeIntensity.Value = 4
			playSound("explosion", {
				PlaybackSpeed = randomFloat(0.9, 1),
				Volume = cube.AssemblyLinearVelocity.Magnitude / 10,
			})
		end
	end
	for _1, part in CollectionService:GetTagged("ErrorEffects") do
		if part:IsA("BasePart") then
			part.Color = if math.random() < 0.5 then Color3.fromRGB(0, 0, 0) else Color3.fromRGB(255, 0, 255)
			local _exp = randomDirection()
			local _vector3 = Vector3.new(0.5, 0.5, 0.5)
			part.Size = _exp + _vector3
		end
	end
	prevCubePosition = cube.Position
	cube:SetAttribute("lastVelocity", cube.AssemblyLinearVelocity)
end)
print("[src/client/visual_effects.client.ts:904]", "Started running visual_effects.client.ts")
while true do
	local _value = task.wait(0.05)
	if not (_value ~= 0 and _value == _value and _value) then
		break
	end
	speedIndex = (speedIndex + 1) % #speedImages
	speedLines.Image = speedImages[speedIndex + 1]
	if not cube then
		continue
	end
	local targetCube = cube
	if isSpectating.Value then
		local otherPlayer = Players:FindFirstChild(spectatePlayer.Value)
		if otherPlayer then
			targetCube = Workspace:FindFirstChild(`cube\{otherPlayer.UserId\}`) or targetCube
		end
	end
	targetCube = Workspace:FindFirstChild("REPLAY_VIEW") or targetCube
	if targetCube then
		local fieldOfView = 70 + math.max(targetCube.AssemblyLinearVelocity.Magnitude - 100, 0) / 5
		local size = math.clamp((110 - fieldOfView) / 10, 1, 6)
		speedLines.Size = UDim2.fromScale(size, size)
		speedLines.Visible = true
	end
end
