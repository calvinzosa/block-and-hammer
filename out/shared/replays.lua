-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local getCubeTime = _utils.getCubeTime
local getTime = _utils.getTime
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or (Workspace:WaitForChild("Camera"))
local mouseVisual = Workspace:WaitForChild("MouseVisual")
local _class
do
	local Replays = setmetatable({}, {
		__tostring = function()
			return "Replays"
		end,
	})
	Replays.__index = Replays
	function Replays.new(...)
		local self = setmetatable({}, Replays)
		return self:constructor(...) or self
	end
	function Replays:constructor()
		self.isRecording = false
		self.forceStopRecording = nil
		self.recordingData = {}
		self.eventBuffer = {}
		self.cubeData = {}
		self.previousTime = -1
		self.startTime = nil
		self.cubeStartTime = nil
	end
	function Replays:startRecording()
		table.clear(self.recordingData)
		table.clear(self.eventBuffer)
		local cubeTime = getCubeTime(Workspace:FindFirstChild(`cube{player.UserId}`))
		self.previousTime = -1
		self.isRecording = true
		self.startTime = nil
		self.cubeStartTime = if cubeTime ~= -1 then math.round(cubeTime * 1000) else 0
		local _condition = (player:GetAttribute("cube_Hat"))
		if _condition == nil then
			_condition = ""
		end
		local _condition_1 = (player:GetAttribute("cube_Face"))
		if _condition_1 == nil then
			_condition_1 = ""
		end
		local _condition_2 = (player:GetAttribute("cube_Aura"))
		if _condition_2 == nil then
			_condition_2 = ""
		end
		local _condition_3 = (player:GetAttribute("hammer_Texture"))
		if _condition_3 == nil then
			_condition_3 = ""
		end
		self.cubeData = { _condition, _condition_1, _condition_2, _condition_3, "" }
		local color = player:GetAttribute("CUBE_COLOR")
		if typeof(color) == "Color3" then
			self.cubeData[5] = color:ToHex()
		end
	end
	function Replays:stopRecording()
		local currentTime = math.round(getTime() * 1000)
		local _condition = self.startTime
		if _condition == nil then
			_condition = 0
		end
		local totalTime = currentTime - _condition
		local cubeData = string.format("%s,%s,%s,%s,%s", unpack(self.cubeData))
		local _recordingData = self.recordingData
		local _fn = string
		local _condition_1 = self.cubeStartTime
		if _condition_1 == nil then
			_condition_1 = 0
		end
		local _arg1 = _fn.format("0,%d,%d,%d,%d:%s", totalTime, 60, _condition_1, currentTime, cubeData)
		table.insert(_recordingData, 1, _arg1)
		self.isRecording = false
		return totalTime
	end
	function Replays:newEvent(dataString)
		local _eventBuffer = self.eventBuffer
		local _dataString = dataString
		table.insert(_eventBuffer, _dataString)
	end
	function Replays:update(cube)
		local _head = cube
		if _head ~= nil then
			_head = _head:FindFirstChild("Head")
		end
		local head = _head
		local _result = cube
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
			return nil
		end
		if not self.isRecording then
			return nil
		end
		local currentTime = math.round(getTime() * 1000)
		local _value = self.startTime
		if not (_value ~= 0 and _value == _value and _value) then
			self.startTime = currentTime
		end
		currentTime -= self.startTime
		if currentTime >= 600000 and self.forceStopRecording then
			self.forceStopRecording()
			return nil
		end
		if self.previousTime == currentTime then
			return nil
		end
		self.previousTime = currentTime
		local position = cube.Position
		local velocity = cube.AssemblyLinearVelocity
		local headAngle = math.deg(math.atan2(head.Position.Y - position.Y, head.Position.X - position.X))
		local _position = cube.Position
		local _position_1 = head.Position
		local headDistance = (_position - _position_1).Magnitude
		local multiplier = 1000
		local dataString = string.format("1,%d,%d,%d,%d,%d,%d,%d,%d,%d,", currentTime, math.round(position.X * multiplier), math.round(position.Y * multiplier), math.round(headAngle * multiplier), math.round(headDistance * multiplier), math.round(mouseVisual.Position.X * multiplier), math.round(mouseVisual.Position.Y * multiplier), math.round(velocity.X * multiplier), math.round(velocity.Y * multiplier))
		local _condition_1 = (cube:GetAttribute("ragdollTime"))
		if _condition_1 == nil then
			_condition_1 = 0
		end
		local ragdollTime = _condition_1
		if ragdollTime ~= 0 then
			local cubeRotationX, cubeRotationY, cubeRotationZ = cube.CFrame:ToOrientation()
			local headRotationX, headRotationY, headRotationZ = head.CFrame:ToOrientation()
			dataString = string.format("2,%d,%d,%d,,%d,%d,%d,%d,%d,,%d,%d,%d,%d,%d,%d,%d,", currentTime, math.round(position.X * multiplier), math.round(position.Y * multiplier), math.round(math.deg(cubeRotationX) * multiplier), math.round(math.deg(cubeRotationY) * multiplier), math.round(math.deg(cubeRotationZ) * multiplier), math.round(head.Position.X * multiplier), math.round(head.Position.Y * multiplier), math.round(math.deg(headRotationX) * multiplier), math.round(math.deg(headRotationY) * multiplier), math.round(math.deg(headRotationZ) * multiplier), math.round(mouseVisual.Position.X * multiplier), math.round(mouseVisual.Position.Y * multiplier), math.round(velocity.X * multiplier), math.round(velocity.Y * multiplier))
		end
		if #self.eventBuffer > 0 then
			dataString ..= ":" .. table.concat(self.eventBuffer, ":")
			table.clear(self.eventBuffer)
		end
		local _recordingData = self.recordingData
		local _dataString = dataString
		table.insert(_recordingData, _dataString)
	end
	_class = Replays
end
return _class
