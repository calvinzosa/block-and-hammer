-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local CollectionService = _services.CollectionService
local ReplicatedStorage = _services.ReplicatedStorage
local GeometryService = _services.GeometryService
local TweenService = _services.TweenService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Lighting = _services.Lighting
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local convertStudsToMeters = _utils.convertStudsToMeters
local getHammerTexture = _utils.getHammerTexture
local randomDirection = _utils.randomDirection
local isClientCube = _utils.isClientCube
local randomFloat = _utils.randomFloat
local Accessories = _utils.Accessories
local GameSetting = _utils.GameSetting
local getSetting = _utils.getSetting
local tweenTypes = _utils.tweenTypes
local playSound = _utils.playSound
local waitUntil = _utils.waitUntil
local getPartId = _utils.getPartId
local getTime = _utils.getTime
local numLerp = _utils.numLerp
local PlayerAttributes = _utils.PlayerAttributes
local getCurrentArea = _utils.getCurrentArea
local LightningBolt = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "lua", "lightning_bolt")
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
local camera = Workspace.CurrentCamera or (Workspace:WaitForChild("Camera"))
local debrisTypes = ReplicatedStorage:WaitForChild("DebrisTypes")
local sfx = ReplicatedStorage:WaitForChild("SFX")
local particlesFolder = ReplicatedStorage:WaitForChild("Particles")
local shockwaveParticle = particlesFolder:WaitForChild("Shockwave"):WaitForChild("Shockwave")
local wind = sfx:WaitForChild("wind")
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local travelGui = screenGui:WaitForChild("FastTravelGUI")
local valueInstances = GUI:WaitForChild("Values")
local canMove = valueInstances:WaitForChild("can_move")
local isSpectating = valueInstances:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local shakeIntensity = valueInstances:WaitForChild("shake_intensity")
local speedLines = screenGui:WaitForChild("SpeedLines")
local mapFolder = Workspace:WaitForChild("Map")
local blastShardsFolder = mapFolder:WaitForChild("BlastShards")
local voltShardsFolder = mapFolder:WaitForChild("VoltShards")
local nonBreakable = Workspace:WaitForChild("NonBreakable")
local effectsFolder = Workspace:WaitForChild("Effects")
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
local function createBolt(attachment0, attachment1)
	local bolt = LightningBolt.new(attachment0, attachment1, 20)
	bolt.CurveSize0 = 5
	bolt.CurveSize1 = 5
	bolt.MinRadius = 0
	bolt.MaxRadius = 2.4
	bolt.Frequency = 10
	bolt.AnimationSpeed = 15
	bolt.Thickness = 0.5
	bolt.MinThicknessMultiplier = 0.2
	bolt.MaxThicknessMultiplier = 1
	bolt.MinTransparency = 0
	bolt.MaxTransparency = 1
	bolt.PulseSpeed = 10
	bolt.PulseLength = 1000000
	bolt.FadeLength = 0.2
	bolt.ContractFrom = 0.5
	bolt.Color = Color3.fromRGB(55, 211, 92)
	bolt.ColorOffsetSpeed = 3
	return bolt
end
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
				task.delay(1, function()
					return circle:Destroy()
				end)
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
							task.delay(1, function()
								return debris:Destroy()
							end)
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
		local volume = velocity.Magnitude / 7.5
		local speed = randomFloat(0.9, 1)
		playSound("hit2", {
			PlaybackSpeed = speed,
			Volume = volume,
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
	task.spawn(function()
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
				task.delay(2.5, function()
					return piece:Destroy()
				end)
			else
				local slicers = {}
				for _ = 1, 6 do
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
					task.delay(2.5, function()
						return piece:Destroy()
					end)
				end
			end
		end
		if not isOnlyEffect then
			otherPart.LocalTransparencyModifier = 1
		end
	end)
	local _result = cube
	if _result ~= nil then
		_result = _result:GetAttribute("scale")
	end
	local _condition = _result
	if _condition == nil then
		_condition = 1
	end
	local cubeScale = _condition
	waitUntil(function()
		local _condition_1 = cube
		if _condition_1 then
			local _position = cube.Position
			local _arg0 = otherPart:GetClosestPointOnSurface(cube.Position)
			_condition_1 = (_position - _arg0).Magnitude > 25 * cubeScale
		end
		return _condition_1
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
	task.spawn(function()
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
				task.delay(2.5, function()
					return piece:Destroy()
				end)
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
					task.delay(2.5, function()
						return piece:Destroy()
					end)
				end
			end
		end
		if not isOnlyEffect then
			otherPart.LocalTransparencyModifier = 1
		end
	end)
	local _result = cube
	if _result ~= nil then
		_result = _result:GetAttribute("scale")
	end
	local _condition = _result
	if _condition == nil then
		_condition = 1
	end
	local cubeScale = _condition
	waitUntil(function()
		local _condition_1 = cube
		if _condition_1 then
			local _position = cube.Position
			local _arg0 = otherPart:GetClosestPointOnSurface(cube.Position)
			_condition_1 = (_position - _arg0).Magnitude > 25 * cubeScale
		end
		return _condition_1
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
	print("[src/client/visual_effects.client.ts:476]", `Cube added: {part.Name} (Client: cube{player.UserId})`)
	StrokeScale:ScaleBillboardGui(part:WaitForChild("OverheadGUI"), 950)
	if not isClientCube(part) then
		return nil
	end
	print("[src/client/visual_effects.client.ts:482]", "> Client cube respawned")
	cube = part
	head = cube:WaitForChild("Head", 30)
	if not head then
		return nil
	end
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
		local _condition_2 = (cube:GetAttribute("scale"))
		if _condition_2 == nil then
			_condition_2 = 1
		end
		local cubeScale = _condition_2
		local hammerTexture = getHammerTexture()
		local otherVelocity = otherPart.AssemblyLinearVelocity
		if otherPart:IsDescendantOf(mapFolder) then
			local _exp = currentVelocity - otherVelocity
			local _arg0 = cube.AssemblyLinearVelocity / 4
			local newVelocity = (_exp - _arg0).Magnitude
			if getCurrentArea(cube) == "ErrorLand" then
				newVelocity *= 2
			end
			if hammerTexture == Accessories.HammerTexture.SteelHammer and getSetting(GameSetting.Modifiers) then
				newVelocity *= 1.5
			end
			newVelocity /= cubeScale
			if newVelocity > 165 then
				if otherPart.Material ~= Enum.Material.DiamondPlate then
					Events.DestroyedPart:FireServer(otherPart)
					local partId = getPartId(otherPart)
					local dataString = nil
					local removeBreaks = hammerTexture == Accessories.HammerTexture.SteelHammer and getSetting(GameSetting.Modifiers)
					local canBreak = otherPart:GetAttribute("CAN_BREAK")
					local canShatter = otherPart:GetAttribute("CAN_SHATTER")
					local _condition_3 = canBreak
					if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 ~= "" and _condition_3 then
						_condition_3 = not removeBreaks
					end
					if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 ~= "" and _condition_3 then
						task.spawn(breakPart, otherPart, head)
						dataString = string.format("break,%s", partId)
					else
						local _condition_4 = canShatter
						if _condition_4 ~= 0 and _condition_4 == _condition_4 and _condition_4 ~= "" and _condition_4 then
							_condition_4 = not removeBreaks
						end
						if _condition_4 ~= 0 and _condition_4 == _condition_4 and _condition_4 ~= "" and _condition_4 then
							task.spawn(shatterPart, otherPart, head)
							dataString = string.format("shatter,%s", partId)
						else
							local velocity = head.AssemblyLinearVelocity
							local position = head.Position
							createDebris(velocity, position, otherPart, 1, true)
							dataString = string.format("destroy,%d,%d,,%d,%d,,%s", math.round(position.X * 1000), math.round(position.Y * 1000), math.round(velocity.X * 1000), math.round(velocity.Y * 1000), partId)
						end
					end
					if dataString ~= "" and dataString then
						Events.MakeReplayEvent:Fire(dataString)
					end
					if otherPart:IsDescendantOf(blastShardsFolder) then
						Events.ClientRagdoll:Fire(3)
						local _position = cube.Position
						local _position_1 = otherPart.Position
						cube.AssemblyLinearVelocity = (_position - _position_1).Unit * 250
						playSound("electric_explosion", {
							Volume = 2,
						})
						local explosion = Instance.new("Explosion")
						explosion.Position = head.Position
						explosion.BlastRadius = 0
						explosion.BlastPressure = 0
						explosion.Parent = effectsFolder
						local shockwave = shockwaveParticle:Clone()
						shockwave.Parent = otherPart
						shockwave.Shockwave:Emit(1)
						task.delay(shockwave.Shockwave.Lifetime.Max, function()
							return shockwave:Destroy()
						end)
					elseif otherPart:IsDescendantOf(voltShardsFolder) then
						Events.ClientRagdoll:Fire(3.5)
						local highlight = Instance.new("Highlight")
						highlight.Adornee = cube
						highlight.DepthMode = Enum.HighlightDepthMode.Occluded
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						highlight.OutlineTransparency = 0
						highlight.FillColor = Color3.fromRGB(74, 204, 105)
						highlight.FillTransparency = 0.75
						highlight.Parent = cube
						for _, descendant in cube:GetDescendants() do
							if descendant:IsA("BasePart") then
								local descendantHighlight = highlight:Clone()
								descendantHighlight.Adornee = descendant
								descendantHighlight.Parent = highlight
							end
						end
						task.delay(2, function()
							return highlight:Destroy()
						end)
						if getSetting(GameSetting.Effects) then
							local rootAttachment = cube:FindFirstChild("CenterAttachment")
							local headAttachment = head:FindFirstChild("ArmAttachment")
							local _result = rootAttachment
							if _result ~= nil then
								_result = _result:IsA("Attachment")
							end
							local _condition_4 = _result
							if _condition_4 then
								local _result_1 = headAttachment
								if _result_1 ~= nil then
									_result_1 = _result_1:IsA("Attachment")
								end
								_condition_4 = _result_1
							end
							if _condition_4 then
								local targetAttachment = Instance.new("Attachment")
								targetAttachment.Position = otherPart:GetClosestPointOnSurface(head.Position)
								targetAttachment.Parent = Workspace:FindFirstChild("Terrain")
								local bolt1 = createBolt(rootAttachment, headAttachment)
								local bolt2 = createBolt(headAttachment, targetAttachment)
								task.delay(2, function()
									bolt1:Destroy()
									bolt2:Destroy()
									targetAttachment:Destroy()
								end)
							end
						end
						local _position = head.Position
						local _position_1 = otherPart.Position
						head.AssemblyLinearVelocity = (_position - _position_1).Unit * 25
						task.delay(0.25, function()
							local startTime = time()
							while (time() - startTime) < 1.75 and cube ~= nil and head ~= nil do
								head.AssemblyLinearVelocity = randomDirection(randomFloat(0.5, 25))
								cube.AssemblyLinearVelocity = randomDirection(randomFloat(0.5, 25))
								head.AssemblyAngularVelocity = Vector3.zero
								cube.AssemblyAngularVelocity = Vector3.zero
								task.wait()
							end
						end)
						playSound("zap2", {
							Volume = 1,
						})
						playSound("shock", {
							Volume = 1,
							PlaybackSpeed = 1.384,
						})
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
					elseif hammerTexture == Accessories.HammerTexture.SteelHammer and getSetting(GameSetting.Modifiers) and not otherPart:IsA("UnionOperation") and false then
						-- TODO: fix steel hammer modifier
						-- if (geometryDebounce || otherPart.Size.Magnitude > 750) return;
						-- geometryDebounce = true;
						-- const area = new Instance('Part');
						-- area.Size = Vector3.one.mul(9);
						-- area.Position = head.Position;
						-- area.Shape = Enum.PartType.Ball;
						-- area.Color = otherPart.Color;
						-- const params = new OverlapParams();
						-- params.FilterType = Enum.RaycastFilterType.Include;
						-- params.FilterDescendantsInstances = [ mapFolder ];
						-- const options = {
						-- 	SplitApart: false,
						-- 	CollisionFidelity: Enum.CollisionFidelity.PreciseConvexDecomposition
						-- }
						-- const subtractedPart = (GeometryService.SubtractAsync(otherPart, [ area ], options) as PartOperation[])[1] as (PartOperation | undefined);
						-- if (subtractedPart) {
						-- 	subtractedPart.Anchored = false;
						-- 	subtractedPart.SetAttribute('steelHammered', true);
						-- 	subtractedPart.Parent = otherPart.Parent;
						-- 	const weld = new Instance('Weld');
						-- 	weld.Part0 = subtractedPart;
						-- 	weld.Part1 = otherPart;
						-- 	if (otherPart.IsA('PartOperation') && otherPart.GetAttribute('steelHammered')) {
						-- 		const original = otherPart.FindFirstChild('original') as (ObjectValue | undefined);
						-- 		if (!original) {
						-- 			subtractedPart.Destroy();
						-- 			return;
						-- 		}
						-- 		original.Parent = subtractedPart;
						-- 		otherPart.Destroy();
						-- 		weld.Part1 = original.Value as BasePart;
						-- 	} else {
						-- 		const objectValue = new Instance('ObjectValue');
						-- 		objectValue.Name = 'original';
						-- 		objectValue.Value = otherPart;
						-- 		objectValue.Parent = subtractedPart;
						-- 		otherPart.Transparency = 1;
						-- 		otherPart.CanCollide = false;
						-- 		otherPart.SetAttribute('broken', true);
						-- 	}
						-- 	weld.Parent = subtractedPart;
						-- 	task.delay(15, () => {
						-- 		const value = subtractedPart.FindFirstChild('original') as (ObjectValue | undefined);
						-- 		if (subtractedPart.Parent && value?.Value?.GetAttribute('broken')) {
						-- 			const originalPart = value.Value as BasePart;
						-- 			originalPart.SetAttribute('broken', undefined);
						-- 			originalPart.Transparency = 0;
						-- 			originalPart.CanCollide = true;
						-- 			subtractedPart.Destroy();
						-- 		}
						-- 	})
						-- 	area.Destroy();
						-- 	geometryDebounce = false;
						-- } else {
						-- 	otherPart.Transparency = 1;
						-- 	otherPart.CanCollide = false;
						-- 	otherPart.SetAttribute('broken', true);
						-- 	task.delay(15, () => {
						-- 		otherPart.SetAttribute('broken', undefined);
						-- 		otherPart.Transparency = 0;
						-- 		otherPart.CanCollide = true;
						-- 	});
						-- 	geometryDebounce = false;
						-- }
					elseif hammerTexture == Accessories.HammerTexture.IcyHammer and getSetting(GameSetting.Modifiers) then
						local arm = cube:FindFirstChild("Arm")
						local trail = head:FindFirstChild("Trail")
						local _value_1 = not arm or not trail or cube:GetAttribute("shatteredHammer")
						if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
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
							local _condition_4 = not _result
							if not _condition_4 then
								_condition_4 = not head or not arm or not trail
							end
							if _condition_4 then
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
							local _arg0_1 = CFrame.fromOrientation(0, math.pi / 2, 0)
							circle.CFrame = _exp_1 * _arg0_1
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
							task.delay(particleEmitter.Lifetime.Max + 0.1, function()
								return spark:Destroy()
							end)
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
					local _position = cube.Position
					local _position_1 = head.Position
					local direction = _position - _position_1
					if direction.Magnitude == 0 then
						return nil
					end
					if getSetting(GameSetting.Modifiers) then
						local _condition_3 = (cube:GetAttribute("scale"))
						if _condition_3 == nil then
							_condition_3 = 1
						end
						local cubeScale = _condition_3
						local _assemblyLinearVelocity = cube.AssemblyLinearVelocity
						local _unit = direction.Unit
						local _arg0_1 = 250 * cubeScale
						cube.AssemblyLinearVelocity = _assemblyLinearVelocity + (_unit * _arg0_1)
					end
					if getSetting(GameSetting.Effects) then
						local velocity = head.AssemblyLinearVelocity * 10
						if velocity.Magnitude == 0 then
							return nil
						end
						head.Color = Color3.fromRGB(128, 128, 0)
						task.delay(0.01, function()
							if head then
								TweenService:Create(head, tweenTypes.linear.short, {
									Color = Color3.fromRGB(255, 0, 0),
								}):Play()
							end
						end)
						createDebris(velocity, head.Position, otherPart, 2.5)
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
				local headVelocity = head.AssemblyLinearVelocity
				local unitVelocity = headVelocity.Unit
				local dataString = string.format("spark,%d,%d,,%d,%d,", math.round(point.X * 1000), math.round(point.Y * 1000), math.round(headVelocity.X * 1000), math.round(headVelocity.Y * 1000))
				Events.MakeReplayEvent:Fire(dataString)
				local volume = headVelocity.Magnitude / 30
				local speed = randomFloat(0.9, 1)
				if otherPart.Material == Enum.Material.Wood or otherPart.Material == Enum.Material.WoodPlanks then
					playSound("wood_hit", {
						PlaybackSpeed = speed,
						Volume = volume * 0.4,
					}, true)
				elseif otherPart.Material == Enum.Material.Plastic then
					playSound("plastic_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				elseif otherPart.Material == Enum.Material.Grass or otherPart.Material == Enum.Material.LeafyGrass then
					playSound("grass_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				elseif otherPart.Material == Enum.Material.Ground then
					playSound("dirt_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				elseif otherPart.Material == Enum.Material.Slate or otherPart.Material == Enum.Material.Concrete or otherPart.Material == Enum.Material.Marble then
					playSound("stone_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				elseif otherPart.Material == Enum.Material.Glass then
					playSound("glass_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				elseif otherPart.Material == Enum.Material.Brick then
					playSound("brick_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				elseif otherPart.Material == Enum.Material.Sand then
					playSound("sand_hit", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				else
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
							local particleEmitter = spark:FindFirstChild("ParticleEmitter")
							task.delay(0.1, function()
								particleEmitter.Enabled = false
								return particleEmitter.Enabled
							end)
							task.delay(particleEmitter.Lifetime.Max + 0.1, function()
								return particleEmitter:Destroy()
							end)
						end
					end
					playSound("hit1", {
						PlaybackSpeed = speed,
						Volume = volume,
					}, true)
				end
			end
			debounce = true
			task.delay(0.25, function()
				debounce = false
				return debounce
			end)
		elseif otherPart:IsDescendantOf(nonBreakable) then
			local newVelocity = (currentVelocity - otherVelocity).Magnitude
			if getCurrentArea(cube) == "ErrorLand" then
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
			targetCube = (Workspace:FindFirstChild(`cube{otherPlayer.UserId}`)) or targetCube
		end
	end
	targetCube = (Workspace:FindFirstChild("REPLAY_VIEW")) or targetCube
	local area = getCurrentArea(cube)
	if area ~= "ErrorLand" and not travelGui.Visible then
		Workspace:SetAttribute("default_gravity", 196.2)
		local targetTime = 14.5
		if area == "Level 1" then
			local _binding = convertStudsToMeters(targetCube.Position.Y, true)
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
				targetTime += (9.5 * (percent + 1)) / 2
				Workspace:SetAttribute("default_gravity", 88.1 * (1 - percent) + 20)
			end
		elseif area == "Level 2" then
			local _binding = convertStudsToMeters(targetCube.Position.Y, true)
			local altitude = _binding[1]
			targetTime = 11.9
		elseif area == "Level 2: Entrance" then
			Workspace:SetAttribute("default_gravity", 120)
			targetTime = 6
		elseif area == "Level 2: Cave 1" then
			targetTime = 0
		end
		Lighting.ClockTime = numLerp(Lighting.ClockTime, targetTime, dt * 2)
	end
	local _condition = (cube:GetAttribute("scale"))
	if _condition == nil then
		_condition = 1
	end
	local cubeScale = _condition
	local velocity = targetCube.AssemblyLinearVelocity / cubeScale
	local _value = player:GetAttribute(PlayerAttributes.Client.InMainMenu)
	local _condition_1 = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
	if _condition_1 then
		_condition_1 = screenGui.Enabled
	end
	if _condition_1 then
		if getSetting(GameSetting.OrthographicView) then
			camera.FieldOfView = 1
		else
			camera.FieldOfView = 70 + math.max(velocity.Magnitude - 100, 0) / 5
		end
		local percent = if getSetting(GameSetting.Sounds) then math.max((velocity.Magnitude - 100) / 300, 0) else 0
		wind.Volume = percent * 3
	end
	lastVelocity = currentVelocity
	currentVelocity = head.AssemblyLinearVelocity
	local previousVelocity = cube:GetAttribute("lastVelocity")
	if typeof(previousVelocity) == "Vector3" then
		local relativeVelocity = (cube.AssemblyLinearVelocity - previousVelocity) / cubeScale
		if relativeVelocity.Magnitude > 360 then
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
						task.delay(OuterInfo.Time, function()
							return part:Destroy()
						end)
					end
				end)
			end
			Events.ClientRagdoll:Fire(1.4)
			shakeIntensity.Value = 4
			playSound("explosion", {
				PlaybackSpeed = randomFloat(0.9, 1),
				Volume = cube.AssemblyLinearVelocity.Magnitude / 10,
			})
		elseif relativeVelocity.Magnitude > 230 then
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
Workspace.Terrain.Touched:Connect(function(otherPart)
	if not cube then
		return nil
	end
	if otherPart == cube or (otherPart:IsDescendantOf(cube) and (otherPart.Name == "Head" or otherPart.Name == "Arm")) then
		local _value = otherPart:GetAttribute("waterSplashDebounce")
		if _value ~= 0 and _value == _value and _value ~= "" and _value then
			return nil
		end
		otherPart:SetAttribute("waterSplashDebounce", true)
		task.delay(0.2, function()
			return otherPart:SetAttribute("waterSplashDebounce", nil)
		end)
		playSound("water_splash", {
			PlaybackSpeed = randomFloat(0.9, 1),
			Volume = math.clamp(otherPart.AssemblyLinearVelocity.Magnitude / 10, 1, 1.5),
		})
	end
end)
print("[src/client/visual_effects.client.ts:1111]", "Started running visual_effects.client.ts")
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
			targetCube = (Workspace:FindFirstChild(`cube\{otherPlayer.UserId\}`)) or targetCube
		end
	end
	targetCube = (Workspace:FindFirstChild("REPLAY_VIEW")) or targetCube
	if targetCube then
		local _condition = (targetCube:GetAttribute("scale"))
		if _condition == nil then
			_condition = 1
		end
		local cubeScale = _condition
		local fieldOfView = 70 + math.max((targetCube.AssemblyLinearVelocity / cubeScale).Magnitude - 100, 0) / 5
		local size = math.clamp((110 - fieldOfView) / 10, 1, 6)
		speedLines.Size = UDim2.fromScale(size, size)
		speedLines.Visible = true
	end
end
