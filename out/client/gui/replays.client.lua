-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local CollectionService = _services.CollectionService
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local UserService = _services.UserService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local Debris = _services.Debris
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local convertStudsToMeters = _utils.convertStudsToMeters
local roundDecimalPlaces = _utils.roundDecimalPlaces
local computeNameColor = _utils.computeNameColor
local getPartFromId = _utils.getPartFromId
local compressData = _utils.compressData
local getTimeUnits = _utils.getTimeUnits
local formatBytes = _utils.formatBytes
local GameSetting = _utils.GameSetting
local randomFloat = _utils.randomFloat
local getSetting = _utils.getSetting
local playSound = _utils.playSound
local getCurrentArea = _utils.getCurrentArea
local _accessory_loader = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader")
local reloadAccessories = _accessory_loader.reloadAccessories
local loadAccessories = _accessory_loader.loadAccessories
local ReplayModule = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "replays")
local Events = {
	GetPlayerReplays = ReplicatedStorage:WaitForChild("GetPlayerReplays"),
	DeleteReplay = ReplicatedStorage:WaitForChild("DeleteReplay"),
	RequestReplay = ReplicatedStorage:WaitForChild("RequestReplay"),
	UploadReplay = ReplicatedStorage:WaitForChild("UploadReplay"),
	ClientCreateDebris = ReplicatedStorage:WaitForChild("ClientCreateDebris"),
	MakeReplayEvent = ReplicatedStorage:WaitForChild("MakeReplayEvent"),
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
	ShatterPart = ReplicatedStorage:WaitForChild("ShatterPart"),
	BreakPart = ReplicatedStorage:WaitForChild("BreakPart"),
}
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local GUI = player:WaitForChild("PlayerGui")
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local replayItemTemplate = guiTemplates:WaitForChild("ReplayItem")
local cubeTemplate = ReplicatedStorage:WaitForChild("Cube")
local sparkParticle = ReplicatedStorage:WaitForChild("Particles"):WaitForChild("spark")
local mouseVisual = Workspace:WaitForChild("MouseVisual")
local effectsFolder = Workspace:WaitForChild("Effects")
local windSFX = ReplicatedStorage:WaitForChild("SFX"):WaitForChild("wind")
local valueInstances = GUI:WaitForChild("Values")
local canMove = valueInstances:WaitForChild("can_move")
local screenGui = GUI:WaitForChild("ScreenGui")
local viewGui = GUI:WaitForChild("ReplayGui")
local replayGui = screenGui:WaitForChild("ReplaysGUI")
local container = replayGui:WaitForChild("Container")
local replayText = viewGui:WaitForChild("ReplayText")
local startRecordingButton = container:WaitForChild("StartRecording")
local stopRecordingButton = container:WaitForChild("StopRecording")
local uploadConfirmation = screenGui:WaitForChild("ReplayUploadConfirmation")
local descriptionLabel = uploadConfirmation:WaitForChild("DescriptionLabel")
local replayUploading = screenGui:WaitForChild("ReplayUploading")
local replayUploadingDescription = replayUploading:WaitForChild("DescriptionLabel")
local replayRequesting = screenGui:WaitForChild("ReplayRequesting")
local replayView = screenGui:WaitForChild("ReplayViewGUI")
local replayViewKey = replayView:WaitForChild("Key")
local replayViewStatus = replayView:WaitForChild("StatusText")
local replayDelete = screenGui:WaitForChild("ReplayDelete")
local replayDeleteContainer = replayDelete:WaitForChild("Container")
local replayDeleting = screenGui:WaitForChild("ReplayDeleting")
local replayList = screenGui:WaitForChild("ReplayListGUI")
local replayListItems = replayList:WaitForChild("Items")
local recordingIndicator = screenGui:WaitForChild("RecordingIndicator")
local playbackControls = viewGui:WaitForChild("PlaybackControls"):WaitForChild("Controls")
local durationBar = viewGui:WaitForChild("PlaybackControls"):WaitForChild("Duration")
local timeLabel = viewGui:WaitForChild("PlaybackControls"):WaitForChild("Time")
local playbackSpeedInput = playbackControls:WaitForChild("PlaybackSpeed")
local pauseButton = playbackControls:WaitForChild("Pause")
local rewindButton = playbackControls:WaitForChild("Rewind")
local forwardButton = playbackControls:WaitForChild("Forward")
local rewindLong = playbackControls:WaitForChild("RewindLong")
local forwardLong = playbackControls:WaitForChild("ForwardLong")
local durationProgress = durationBar:WaitForChild("Progress")
local durationInput = durationBar:WaitForChild("Input")
local exitButton = playbackControls:WaitForChild("Exit")
local timerDisplay = viewGui:WaitForChild("Timer")
local Recorder = ReplayModule.new()
local finishDraggingDuration = false
local isDraggingDuration = false
local deletingReplayId = nil
local compressedData = nil
local instantCamera = false
local playbackSpeed = 0
local updateEvent = nil
local currentTime = 0
local isPlaying = false
replayGui:GetPropertyChangedSignal("Visible"):Connect(function()
	local currentArea = getCurrentArea(Workspace:FindFirstChild(`cube{player.UserId}`))
	if replayGui.Visible and (currentArea == "ErrorLand" or currentArea == "Tutorial") then
		replayGui.Visible = false
		canMove.Value = true
	end
end)
local function formatUnixTimestamp(milliseconds)
	local dateTable = os.date("*t", milliseconds / 1000)
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	local formattedDate = string.format("%s %d %d %02d:%02d:%02d", months[dateTable.month + 1], dateTable.day, dateTable.year, dateTable.hour, dateTable.min, dateTable.sec)
	return formattedDate
end
local function startRecording()
	if getCurrentArea(Workspace:FindFirstChild(`cube{player.UserId}`)) == "ErrorLand" then
		return nil
	end
	recordingIndicator.Visible = true
	startRecordingButton.BackgroundTransparency = 0.5
	startRecordingButton.TextColor3 = Color3.fromRGB(175, 175, 175)
	startRecordingButton.AutoButtonColor = false
	startRecordingButton:SetAttribute("disabled", true)
	stopRecordingButton.BackgroundTransparency = 0.6
	stopRecordingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopRecordingButton.AutoButtonColor = true
	stopRecordingButton:SetAttribute("disabled", nil)
	Recorder:startRecording()
	replayGui.Visible = false
	canMove.Value = true
end
local function stopRecording()
	if not Recorder.isRecording then
		return nil
	end
	recordingIndicator.Visible = false
	startRecordingButton.BackgroundTransparency = 0.6
	startRecordingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	startRecordingButton:SetAttribute("disabled", nil)
	startRecordingButton.AutoButtonColor = true
	stopRecordingButton.BackgroundTransparency = 0.5
	stopRecordingButton.TextColor3 = Color3.fromRGB(175, 175, 175)
	stopRecordingButton.AutoButtonColor = false
	stopRecordingButton:SetAttribute("disabled", true)
	local totalTime = Recorder:stopRecording()
	compressedData = compressData(Recorder.recordingData, false)
	print("[src/client/gui/replays.client.ts:161]", Recorder.recordingData)
	local _, minutes, seconds, milliseconds = getTimeUnits(totalTime)
	local info = { `length: {string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)}/10:00.000`, `frames: {#Recorder.recordingData - 1}`, `size: {formatBytes(#compressedData)}`, `fps: 60` }
	descriptionLabel.Text = table.concat(info, "\n")
	uploadConfirmation.Visible = true
	table.clear(Recorder.recordingData)
	canMove.Value = false
	replayGui.Visible = false
end
local function viewReplay(userId, frames)
	screenGui.Enabled = false
	viewGui.Enabled = true
	canMove.Value = false
	currentTime = 0
	isPlaying = true
	playbackSpeed = 1
	playbackSpeedInput.Text = "1.00x"
	playbackSpeedInput.PlaceholderText = "1.00x"
	local metadataEvents = string.split(frames[1], ":")
	local metadata = string.split(metadataEvents[1], ",")
	local _condition = metadataEvents[2]
	if not (_condition ~= "" and _condition) then
		_condition = ",,,,"
	end
	local cubeMetadata = string.split(_condition, ",")
	local cubeHexColor = cubeMetadata[5]
	print("[src/client/gui/replays.client.ts:198]", frames)
	local cubeColor = nil
	TS.try(function()
		cubeColor = Color3.fromHex(cubeHexColor)
	end, function(err) end)
	local _condition_1 = tonumber(metadata[4])
	if _condition_1 == nil then
		_condition_1 = 0
	end
	local timerStartTime = _condition_1
	local _condition_2 = tonumber(metadata[2])
	if _condition_2 == nil then
		_condition_2 = 0
	end
	local millisecondsDuration = _condition_2
	local secondsDuration = millisecondsDuration / 1000
	local _, minutes, seconds, milliseconds = getTimeUnits(millisecondsDuration)
	local totalTime = string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
	timeLabel.Text = `00:00.000/{totalTime}`
	local replayCube = cubeTemplate:Clone()
	local replayCubeHead = replayCube:WaitForChild("Head")
	local replayCubeOverheadGUI = replayCube:WaitForChild("OverheadGUI")
	local replayCubeUsername = replayCubeOverheadGUI:WaitForChild("Username")
	replayCube.Name = "REPLAY_VIEW"
	replayCube.Anchored = true
	replayCubeHead.Anchored = true
	replayCube:SetAttribute("isCube", nil)
	replayCube.Parent = Workspace
	local _cubeColor = cubeColor
	if typeof(_cubeColor) == "Color3" then
		replayCube.Color = cubeColor
		reloadAccessories(replayCube, cubeColor, cubeMetadata[1], cubeMetadata[3], cubeMetadata[4])
	end
	loadAccessories(replayCube, {
		hat = cubeMetadata[1],
		face = cubeMetadata[2],
		aura = cubeMetadata[3],
		hammer = cubeMetadata[4],
	}, player, nil)
	local previousFrameIndex = 2
	task.spawn(function()
		replayText.Text = "watching: ?"
		local userInfo = nil
		local existingPlayer = Players:GetPlayerByUserId(userId)
		if existingPlayer then
			userInfo = {
				DisplayName = existingPlayer.DisplayName,
				Username = existingPlayer.Name,
				Id = userId,
			}
		else
			TS.try(function()
				userInfo = UserService:GetUserInfosByUserIdsAsync({ userId })[1]
			end, function(err) end)
		end
		if userInfo then
			replayText.Text = `watching: {userInfo.DisplayName} (@{userInfo.Username})`
			replayCubeUsername.Text = `{userInfo.DisplayName} (@{userInfo.Username})`
			if not cubeColor then
				local cubeColor = computeNameColor(userInfo.Username)
				replayCube.Color = cubeColor
				reloadAccessories(replayCube, cubeColor, cubeMetadata[1], cubeMetadata[2], cubeMetadata[3])
			end
		end
	end)
	local effectedParts = {}
	local winFrameIndex = nil
	local totalWinTime = nil
	for _1, frame in frames do
		local events = string.split(frame, ":")
		local _binding = string.split(events[1], ",")
		local frameType = _binding[1]
		local secondsTime = _binding[2]
		if #events > 1 then
			for j, dataString in pairs(events) do
				if j == 1 then
					continue
				end
				local data = string.split(dataString, ",")
				local eventName = data[1]
				if eventName == "win" then
					local _condition_3 = tonumber(data[2])
					if _condition_3 == nil then
						_condition_3 = 0
					end
					totalWinTime = _condition_3
					winFrameIndex = j
				end
			end
		end
	end
	updateEvent = RunService.Heartbeat:Connect(function(dt)
		local mouse = UserInputService:GetMouseLocation()
		if isPlaying then
			currentTime += dt * playbackSpeed
			if currentTime > secondsDuration then
				currentTime = secondsDuration
				isPlaying = false
				pauseButton.Text = "►"
			end
		end
		if isDraggingDuration then
			if finishDraggingDuration then
				isDraggingDuration = false
				finishDraggingDuration = false
				isPlaying = true
				pauseButton.Text = "||"
			else
				local percent = math.clamp((mouse.X - durationBar.AbsolutePosition.X) / durationBar.AbsoluteSize.X, 0, 1)
				currentTime = secondsDuration * percent
				isPlaying = false
				pauseButton.Text = "►"
			end
		end
		local currentFrame = nil
		local currentFrameIndex = nil
		for i, frame in pairs(frames) do
			local _binding = string.split(string.split(frame, ":")[1], ",")
			local frameType = _binding[1]
			local secondsTime = _binding[2]
			local _condition_3 = (frameType == "1" or frameType == "2")
			if _condition_3 then
				local _condition_4 = tonumber(secondsTime)
				if _condition_4 == nil then
					_condition_4 = 0
				end
				_condition_3 = (_condition_4 / 1000) > currentTime
			end
			if _condition_3 then
				currentFrame = frames[i]
				if tonumber(string.split(currentFrame, ",")[1]) ~= 1 then
					currentFrame = frame
				end
				currentFrameIndex = i
				break
			end
		end
		durationProgress.Size = UDim2.fromScale(currentTime / secondsDuration, 1)
		timerDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
		local _1, minutes, seconds, milliseconds = getTimeUnits(timerStartTime + currentTime * 1000)
		local _condition_3 = winFrameIndex
		if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 then
			_condition_3 = totalWinTime
			if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 then
				_condition_3 = currentFrameIndex
				if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 then
					_condition_3 = currentFrameIndex >= winFrameIndex
				end
			end
		end
		if _condition_3 ~= 0 and _condition_3 == _condition_3 and _condition_3 then
			_2, minutes, seconds, milliseconds = getTimeUnits(totalWinTime)
			timerDisplay.TextColor3 = Color3.fromRGB(255, 255, 128)
		end
		timerDisplay.Text = string.format("%02d:%02d.%d", minutes, seconds, math.floor(milliseconds / 100))
		local _condition_4 = currentFrame
		if _condition_4 ~= "" and _condition_4 then
			_condition_4 = currentFrameIndex
		end
		if _condition_4 ~= 0 and _condition_4 == _condition_4 and _condition_4 ~= "" and _condition_4 then
			if isPlaying and previousFrameIndex < currentFrameIndex then
				for i = previousFrameIndex, currentFrameIndex do
					local otherFrame = frames[i]
					local events = string.split(otherFrame, ":")
					local _binding = string.split(events[1], ",")
					local frameType = _binding[1]
					local secondsTime = _binding[2]
					local _condition_5 = #events > 1
					if _condition_5 then
						local _condition_6 = tonumber(secondsTime)
						if _condition_6 == nil then
							_condition_6 = 0
						end
						_condition_5 = _condition_6 / 1000 > currentTime
					end
					if _condition_5 then
						for i, dataString in pairs(events) do
							if i == 1 then
								continue
							end
							local data = string.split(dataString, ",")
							local eventName = data[1]
							if eventName == "sound" then
								local soundName = data[2]
								local properties = {}
								for i = 3, #data do
									local _binding_1 = string.split(data[i], "=")
									local property = _binding_1[1]
									local value = _binding_1[2]
									local number = tonumber(value)
									if number ~= nil then
										properties[property] = number / 1000
									else
										properties[property] = value
									end
								end
								playSound(soundName, properties, true)
							elseif eventName == "spark" then
								local divider = 1000
								if { string.find(data[1], "%.") } then
									divider = 1
								end
								local _vector3 = Vector3.new(tonumber(data[5]), tonumber(data[6]), tonumber(data[7]))
								local _divider = divider
								local velocity = _vector3 / _divider
								local _vector3_1 = Vector3.new(tonumber(data[2]), tonumber(data[3]), tonumber(data[4]))
								local _divider_1 = divider
								local point = _vector3_1 / _divider_1
								playSound("hit1", {
									PlaybackSpeed = math.random(90, 100) / 100,
									Volume = velocity.Magnitude / 30,
								}, true)
								local spark = sparkParticle:Clone()
								spark.CFrame = CFrame.lookAlong(point, velocity.Unit * (-1))
								spark.Parent = effectsFolder
								Debris:AddItem(spark, 5)
								local particleEmitter = spark:WaitForChild("ParticleEmitter")
								task.delay(0.1, function()
									particleEmitter.Enabled = false
									return particleEmitter.Enabled
								end)
							elseif eventName == "destroy" then
								local divider = 1000
								if { string.find(data[2], "%.") } then
									divider = 1
								end
								local _vector3 = Vector3.new(tonumber(data[2]), tonumber(data[3]), tonumber(data[4]))
								local _divider = divider
								local position = _vector3 / _divider
								local _vector3_1 = Vector3.new(tonumber(data[5]), tonumber(data[6]), tonumber(data[7]))
								local _divider_1 = divider
								local velocity = _vector3_1 / _divider_1
								local otherPart = getPartFromId(data[8])
								if otherPart then
									Events.ClientCreateDebris:Fire(velocity, position, otherPart, 1, true, cubeMetadata[4])
								end
							elseif eventName == "explosion" then
								local position = Vector3.new(tonumber(data[2]), tonumber(data[3]), tonumber(data[4])) / 1000
								local _fn = math
								local _condition_6 = tonumber(data[5])
								if _condition_6 == nil then
									_condition_6 = 700
								end
								local volume = _fn.clamp(_condition_6 / 1000, 0, 2)
								playSound("explosion", {
									PlaybackSpeed = randomFloat(0.9, 1),
									Volume = volume,
								}, true)
								local explosion = Instance.new("Explosion")
								explosion.BlastRadius = 0
								explosion.BlastPressure = 0
								explosion.Position = position
								explosion.Parent = effectsFolder
							elseif eventName == "break" then
								local part = CollectionService:GetTagged(data[2])[1]
								local _result = part
								if _result ~= nil then
									_result = _result:IsA("BasePart")
								end
								if _result then
									part.CollisionGroup = "collidableDebris"
									part.LocalTransparencyModifier = 0.75
									Events.BreakPart:Fire(part, replayCubeHead, true)
									local _effectedParts = effectedParts
									local _part = part
									table.insert(_effectedParts, _part)
								end
								playSound("hit2", {
									PlaybackSpeed = randomFloat(0.9, 1),
									Volume = 0.5,
								}, true)
							elseif eventName == "shatter" then
								local part = CollectionService:GetTagged(data[2])[1]
								local _result = part
								if _result ~= nil then
									_result = _result:IsA("BasePart")
								end
								if _result then
									part.CollisionGroup = "collidableDebris"
									part.LocalTransparencyModifier = 0.75
									Events.ShatterPart:Fire(part, replayCubeHead, true)
									table.insert(effectedParts, part)
								end
								playSound("shatter", {
									PlaybackSpeed = randomFloat(0.9, 1),
								})
							elseif eventName == "respawn" then
								local part = CollectionService:GetTagged(data[2])[1]
								local _result = part
								if _result ~= nil then
									_result = _result:IsA("BasePart")
								end
								if _result then
									part.CollisionGroup = "Map"
									part.LocalTransparencyModifier = 0
									-- ▼ ReadonlyArray.findIndex ▼
									local _callback = function(otherPart)
										return otherPart == part
									end
									local _result_1 = -1
									for _i, _v in effectedParts do
										if _callback(_v, _i - 1, effectedParts) == true then
											_result_1 = _i - 1
											break
										end
									end
									-- ▲ ReadonlyArray.findIndex ▲
									local i = _result_1
									if i ~= -1 then
										table.remove(effectedParts, i + 1)
									end
								end
							end
						end
					end
				end
			end
			local events = string.split(currentFrame, ":")
			local data = string.split(events[1], ",")
			local _binding = data
			local frameType = _binding[1]
			local cubeX = _binding[3]
			local cubeY = _binding[4]
			local headAngle = _binding[5]
			local headDistance = _binding[6]
			local mouseX = _binding[7]
			local mouseY = _binding[8]
			local velocityX = _binding[9]
			local velocityY = _binding[10]
			if frameType == "2" then
				cubeX = ""
				cubeY = ""
				headAngle = ""
				headDistance = ""
				mouseX = data[17]
				mouseY = data[18]
				velocityX = ""
				velocityY = ""
			end
			local divider = 1000
			local _value = (string.find(cubeX, "%."))
			if _value ~= 0 and _value == _value and _value then
				divider = 1
			end
			local _condition_5 = tonumber(cubeX)
			if _condition_5 == nil then
				_condition_5 = 0
			end
			local finalCubeX = _condition_5 / divider
			local _condition_6 = tonumber(cubeY)
			if _condition_6 == nil then
				_condition_6 = 0
			end
			local finalCubeY = _condition_6 / divider
			local _condition_7 = tonumber(headAngle)
			if _condition_7 == nil then
				_condition_7 = 0
			end
			local finalHeadAngle = _condition_7 / divider
			local _condition_8 = tonumber(headDistance)
			if _condition_8 == nil then
				_condition_8 = 0
			end
			local finalHeadDistance = _condition_8 / divider
			local _condition_9 = tonumber(mouseX)
			if _condition_9 == nil then
				_condition_9 = 0
			end
			local finalMouseX = _condition_9 / divider
			local _condition_10 = tonumber(mouseY)
			if _condition_10 == nil then
				_condition_10 = 0
			end
			local finalMouseY = _condition_10 / divider
			local _condition_11 = tonumber(velocityX)
			if _condition_11 == nil then
				_condition_11 = 0
			end
			local finalVelocityX = _condition_11 / divider
			local _condition_12 = tonumber(velocityY)
			if _condition_12 == nil then
				_condition_12 = 0
			end
			local finalVelocityY = _condition_12 / divider
			local headPositionX = finalCubeX + math.cos(math.rad(finalHeadAngle)) * finalHeadDistance
			local headPositionY = finalCubeY + math.sin(math.rad(finalHeadAngle)) * finalHeadDistance
			local _exp = CFrame.lookAt(Vector3.new(headPositionX, headPositionY, 0), replayCube.Position)
			local _arg0 = CFrame.fromOrientation(math.pi, 0, 0)
			local headCFrame = _exp * _arg0
			local cubeVelocity = Vector3.new(finalVelocityX, finalVelocityY, 0)
			local cubeCFrame = CFrame.new(finalCubeX, finalCubeY, 0)
			if frameType == "2" then
				local _condition_13 = tonumber(data[6])
				if _condition_13 == nil then
					_condition_13 = 0
				end
				local cubeRotationX = _condition_13
				local _condition_14 = tonumber(data[7])
				if _condition_14 == nil then
					_condition_14 = 0
				end
				local cubeRotationY = _condition_14
				local _condition_15 = tonumber(data[8])
				if _condition_15 == nil then
					_condition_15 = 0
				end
				local cubeRotationZ = _condition_15
				local _condition_16 = tonumber(data[13])
				if _condition_16 == nil then
					_condition_16 = 0
				end
				local headRotationX = _condition_16
				local _condition_17 = tonumber(data[14])
				if _condition_17 == nil then
					_condition_17 = 0
				end
				local headRotationY = _condition_17
				local _condition_18 = tonumber(data[15])
				if _condition_18 == nil then
					_condition_18 = 0
				end
				local headRotationZ = _condition_18
				local cubeRotation = CFrame.fromOrientation(math.rad(cubeRotationX / divider), math.rad(cubeRotationY / divider), math.rad(cubeRotationZ / divider))
				local headRotation = CFrame.fromOrientation(math.rad(headRotationX / divider), math.rad(headRotationY / divider), math.rad(headRotationZ / divider))
				local _condition_19 = tonumber(data[3])
				if _condition_19 == nil then
					_condition_19 = 0
				end
				local _exp_1 = _condition_19 / divider
				local _condition_20 = tonumber(data[4])
				if _condition_20 == nil then
					_condition_20 = 0
				end
				local _cFrame = CFrame.new(_exp_1, _condition_20 / divider, 0)
				local _cubeRotation = cubeRotation
				cubeCFrame = _cFrame * _cubeRotation
				local _condition_21 = tonumber(data[10])
				if _condition_21 == nil then
					_condition_21 = 0
				end
				local _exp_2 = _condition_21 / divider
				local _condition_22 = tonumber(data[10])
				if _condition_22 == nil then
					_condition_22 = 0
				end
				local _cFrame_1 = CFrame.new(_exp_2, _condition_22 / divider, 0)
				local _headRotation = headRotation
				headCFrame = _cFrame_1 * _headRotation
			end
			local alpha = math.min(dt * 27.5, 1)
			replayCube.CFrame = replayCube.CFrame:Lerp(cubeCFrame, alpha)
			replayCubeHead.CFrame = replayCubeHead.CFrame:Lerp(headCFrame, alpha)
			mouseVisual.Position = Vector3.new(finalMouseX, finalMouseY, 0)
			local zoom = 37.5
			if cubeMetadata[4] == "Long Hammer" then
				zoom = 70
			elseif cubeMetadata[4] == "Grappling Hammer" then
				zoom = 50
			elseif cubeMetadata[4] == "Explosive Hammer" then
				zoom = 65
			end
			local _fn = CFrame
			local _position = replayCube.Position
			local _vector3 = Vector3.new(0, 0, zoom)
			local cameraCFrame = _fn.lookAt(_position - _vector3, replayCube.Position, Vector3.yAxis)
			if instantCamera then
				instantCamera = false
				camera.CFrame = cameraCFrame
			else
				local _position_1 = camera.CFrame.Position
				local _position_2 = cameraCFrame.Position
				if (_position_1 - _position_2).Magnitude > 50 then
					camera.CFrame = camera.CFrame:Lerp(cameraCFrame, 0.5)
				else
					camera.CFrame = camera.CFrame:Lerp(cameraCFrame, math.clamp(dt * 15, 0, 1))
				end
			end
			local _2, minutes, seconds, milliseconds = getTimeUnits(currentTime * 1000)
			local _binding_1 = convertStudsToMeters(cubeCFrame.Y - 1.9)
			local altitudeLabel = _binding_1[2]
			local _binding_2 = convertStudsToMeters(cubeVelocity.Magnitude)
			local speedLabel = _binding_2[2];
			(viewGui:FindFirstChild("Altitude")).Text = altitudeLabel;
			(viewGui:FindFirstChild("Speedometer")).Text = speedLabel
			timeLabel.Text = `{string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)}/{totalTime}`
			replayCube.AssemblyLinearVelocity = cubeVelocity
			camera.FieldOfView = 70 + math.max(cubeVelocity.Magnitude - 100, 0) / 5
			local percent = if getSetting(GameSetting.Sounds) then math.max((cubeVelocity.Magnitude - 100) / 300, 0) else 0
			windSFX.Volume = percent * 3
			previousFrameIndex = currentFrameIndex
		end
	end)
	exitButton.MouseButton1Click:Wait()
	replayCube:Destroy()
	updateEvent:Disconnect()
	screenGui.Enabled = true
	viewGui.Enabled = false
	for _1, part in effectedParts do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 0
			part.CollisionGroup = "Map"
		end
	end
end
local function loadReplayList()
	local replayData = Events.GetPlayerReplays:InvokeServer()
	if replayData == -1 then
		return nil
	end
	for _, data in pairs(replayData) do
		local _binding = data
		local id = _binding[1]
		local userId = _binding[2]
		local chunks = _binding[3]
		local size = _binding[4]
		local frames = _binding[5]
		local dateCreated = _binding[6]
		local key = _binding[7]
		local metadataEvents = string.split(frames[1], ":")
		local metadata = string.split(metadataEvents[1], ",")
		local _condition = tonumber(metadata[2])
		if _condition == nil then
			_condition = 0
		end
		local _1, minutes, seconds, milliseconds = getTimeUnits(_condition)
		local item = replayItemTemplate:Clone()
		local right = item:FindFirstChild("Right")
		local left = item:FindFirstChild("Left");
		(left:WaitForChild("Id"):WaitForChild("Id")).Text = id;
		(left:WaitForChild("Key"):WaitForChild("Key")).Text = "*******"
		(left:WaitForChild("Chunks")).Text = `chunks: {chunks}`
		(left:WaitForChild("Length")).Text = `length: {string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)}`
		(left:WaitForChild("RSize")).Text = `size: {formatBytes(size)}`
		local _condition_1 = tonumber(metadata[3])
		if _condition_1 == nil then
			_condition_1 = 60
		end
		(left:WaitForChild("FPS")).Text = `fps: {_condition_1}`
		(left:WaitForChild("Date")).Text = `date: {formatUnixTimestamp(dateCreated)}`
		item.Parent = replayListItems
		if not (key ~= "" and key) then
			key = "no key found was found, this was probably created before keys were added"
			(left:WaitForChild("Key"):WaitForChild("Key")).Text = key
		end
		(right:WaitForChild("View")).MouseButton1Click:Connect(function()
			return viewReplay(userId, frames)
		end);
		(right:WaitForChild("Key")).MouseButton1Click:Connect(function()
			(left:WaitForChild("Key"):WaitForChild("Key")).Text = key
		end);
		(right:WaitForChild("Delete")).MouseButton1Click:Connect(function()
			for _2, display in replayDeleteContainer:GetChildren() do
				if display:IsA("Frame") then
					display:Destroy()
				end
			end
			deletingReplayId = id
			local display = item:Clone()
			display:WaitForChild("Right"):Destroy()
			display.Size = UDim2.fromScale(1, 1)
			display.Parent = replayDeleteContainer
			replayList.Visible = false
			replayDelete.Visible = true
		end)
	end
end
startRecordingButton.MouseButton1Click:Connect(startRecording)
stopRecordingButton.MouseButton1Click:Connect(stopRecording)
Recorder.forceStopRecording = stopRecording;
(uploadConfirmation:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	if not (compressedData ~= "" and compressedData) then
		return nil
	end
	uploadConfirmation.Visible = false
	replayUploading.Visible = true
	replayUploadingDescription.Text = "starting upload..."
	task.wait(0.1)
	Events.UploadReplay:InvokeServer(0)
	local chunkSize = 3000
	local totalChunks = math.ceil(#compressedData / chunkSize)
	local chunkNumber = 1
	local _result = compressedData
	if _result ~= nil then
		_result = #_result
	end
	for i = 1, _result, chunkSize or 1 do
		local j = i + chunkSize - 1
		local _chunk = compressedData
		if _chunk ~= nil then
			_chunk = string.sub(_chunk, i, j)
		end
		local chunk = _chunk
		replayUploadingDescription.Text = `sending chunk {chunkNumber}/{totalChunks} to server`
		Events.UploadReplay:InvokeServer(1, chunk)
		chunkNumber += 1
	end
	replayUploadingDescription.Text = "waiting for server to save data..."
	task.wait(0.1)
	Events.UploadReplay:InvokeServer(2)
	compressedData = nil
	replayUploading.Visible = false
	replayGui.Visible = true
end);
(uploadConfirmation:WaitForChild("No")).MouseButton1Click:Connect(function()
	if not (compressedData ~= "" and compressedData) then
		return nil
	end
	print("[src/client/gui/replays.client.ts:633]", `Deleting {#compressedData} characters of replay data`)
	compressedData = nil
	uploadConfirmation.Visible = false
	replayGui.Visible = true
end);
(container:WaitForChild("ViewReplay")).MouseButton1Click:Connect(function()
	-- replayGui.Visible = false;
	-- replayViewStatus.Text = '';
	-- replayView.Visible = true;
end);
(replayView:WaitForChild("Close")).MouseButton1Click:Connect(function()
	replayView.Visible = false
	replayGui.Visible = true
end);
(replayView:WaitForChild("View")).MouseButton1Click:Connect(function()
	replayView.Visible = false
	replayRequesting.Visible = true
	local _binding = Events.RequestReplay:InvokeServer(replayViewKey.ContentText)
	local data = _binding[1]
	local message = _binding[2]
	if not data then
		replayRequesting.Visible = false
		local _condition = message
		if _condition == nil then
			_condition = "no message from server"
		end
		replayViewStatus.Text = _condition
		replayView.Visible = true
		return nil
	end
	replayRequesting.Visible = false
	replayView.Visible = true
	local userId = data[1]
	local replayData = data[2]
	viewReplay(userId, replayData)
end)
replayList:GetPropertyChangedSignal("Visible"):Connect(function()
	for _, replayItem in replayListItems:GetChildren() do
		if replayItem:IsA("Frame") then
			replayItem:Destroy()
		end
	end
end);
(container:WaitForChild("MyReplays")).MouseButton1Click:Connect(function()
	replayGui.Visible = false
	replayList.Visible = true
	loadReplayList()
end);
(replayList:WaitForChild("Close")).MouseButton1Click:Connect(function()
	replayGui.Visible = true
	replayList.Visible = false
end);
(replayDelete:WaitForChild("No")).MouseButton1Click:Connect(function()
	replayDelete.Visible = false
	replayList.Visible = true
end);
(replayDelete:WaitForChild("Yes")).MouseButton1Click:Connect(function()
	if not (deletingReplayId ~= "" and deletingReplayId) then
		return nil
	end
	replayDelete.Visible = false
	replayDeleting.Visible = true
	Events.DeleteReplay:InvokeServer(deletingReplayId)
	deletingReplayId = nil
	replayDeleting.Visible = false
	replayList.Visible = true
	loadReplayList()
end)
pauseButton.MouseButton1Click:Connect(function()
	isPlaying = not isPlaying
	pauseButton.Text = if isPlaying then "||" else "►"
end)
rewindButton.MouseButton1Click:Connect(function()
	currentTime = math.max(currentTime - 5, 0)
	instantCamera = true
end)
forwardButton.MouseButton1Click:Connect(function()
	currentTime += 5
	instantCamera = true
end)
rewindLong.MouseButton1Click:Connect(function()
	currentTime = math.max(currentTime - 15, 0)
	instantCamera = true
end)
forwardLong.MouseButton1Click:Connect(function()
	currentTime += 15
	instantCamera = true
end)
playbackSpeedInput.FocusLost:Connect(function()
	local _fn = math
	local _condition = tonumber(playbackSpeedInput.ContentText)
	if not (_condition ~= 0 and _condition == _condition and _condition) then
		_condition = 1
	end
	playbackSpeed = _fn.clamp(roundDecimalPlaces(_condition, 2), 0.01, 5)
	local text = string.format("%.2fx", playbackSpeed)
	playbackSpeedInput.Text = text
	playbackSpeedInput.PlaceholderText = text
end)
durationInput.MouseButton1Down:Connect(function()
	isDraggingDuration = true
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if isDraggingDuration then
			finishDraggingDuration = true
		end
	end
end)
Events.ClientReset.Event:Connect(function(fullReset)
	if not Recorder.isRecording then
		return nil
	end
	if fullReset then
		local event
		event = Workspace.ChildAdded:Connect(function(part)
			local _value = part.Name == `cube{player.UserId}` and part:GetAttribute("isCube")
			if _value ~= 0 and _value == _value and _value ~= "" and _value then
				event:Disconnect()
				while true do
					local _value_1 = part:GetAttribute("start_time")
					if not not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1) then
						break
					end
					part.AttributeChanged:Wait()
				end
				Recorder:startRecording()
			end
		end)
	else
		local cube = Workspace:WaitForChild(`cube{player.UserId}`)
		local event
		event = cube.AttributeChanged:Connect(function(attr)
			if attr == "start_time" then
				event:Disconnect()
				Recorder:startRecording()
			end
		end)
	end
end)
Events.MakeReplayEvent.Event:Connect(function(dataString)
	local _dataString = dataString
	if not (type(_dataString) == "string") then
		return nil
	end
	if Recorder.isRecording then
		Recorder:newEvent(dataString)
	end
end)
while true do
	local _value = task.wait(1 / 60)
	if not (_value ~= 0 and _value == _value and _value) then
		break
	end
	TS.try(function()
		if Recorder.isRecording then
			local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
			Recorder:update(cube)
		end
	end, function(err)
		warn("[src/client/gui/replays.client.ts:789]", err)
	end)
end
