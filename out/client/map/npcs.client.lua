-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local ContentProvider = _services.ContentProvider
local TweenService = _services.TweenService
local Workspace = _services.Workspace
local Players = _services.Players
local startsWith = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "string-utils").startsWith
local randomFloat = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").randomFloat
local dialog = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "dialog").default
local Events = {
	PickedDialogChoice = ReplicatedStorage:WaitForChild("PickedDialogChoice"),
}
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local guiTemplates = ReplicatedStorage:WaitForChild("GUI")
local choiceTemplate = guiTemplates:WaitForChild("ChoiceTemplate")
local npcsFolder = Workspace:WaitForChild("NPCs")
local GUI = player:WaitForChild("PlayerGui")
local valueInstances = GUI:WaitForChild("Values")
local menuOpen = valueInstances:WaitForChild("menu_open")
local canMove = valueInstances:WaitForChild("can_move")
local screenGui = GUI:WaitForChild("ScreenGui")
local speedometerLabel = screenGui:WaitForChild("Speedometer")
local altitudeLabel = screenGui:WaitForChild("Altitude")
local dialogGUI = screenGui:WaitForChild("Dialog")
local dialogContent = dialogGUI:WaitForChild("Content")
local dialogHeader = dialogContent:WaitForChild("HeaderLabel")
local GameDialogChoices = dialogContent:WaitForChild("Choices")
local dialogIcon = dialogContent:WaitForChild("Icon")
local dialogMessage = dialogContent:WaitForChild("Message")
local mouseIcon = screenGui:WaitForChild("MouseIcon")
local Info = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local wasMouseIconVisible = false
local targetChoice = ""
local inDialog = false
local didSkip = false
local function getNpcAtMouse()
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { npcsFolder }
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 1024, params)
	local _result = result
	if _result ~= nil then
		_result = _result.Instance
	end
	return _result
end
local function setMouseIcon(isVisible)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if not _result then
		return nil
	end
	if isVisible then
		if not wasMouseIconVisible then
			wasMouseIconVisible = true
			mouseIcon.AnchorPoint = Vector2.new(0.9, 0.85)
			mouseIcon.Image = "rbxassetid://13906010314"
			mouseIcon.Size = UDim2.fromScale(0.022, 1)
			mouseIcon.Visible = true
		end
	else
		if wasMouseIconVisible then
			wasMouseIconVisible = false
			mouseIcon.Visible = false
		end
	end
end
task.spawn(function()
	local ids = {}
	for _, root in pairs(dialog) do
		if startsWith(root.talkSound, "rbxassetid://") then
			local _talkSound = root.talkSound
			table.insert(ids, _talkSound)
		end
		if startsWith(root.icon, "rbxassetid://") then
			local _icon = root.icon
			table.insert(ids, _icon)
		end
	end
	ContentProvider:PreloadAsync(ids)
end)
dialogContent.MouseButton1Click:Connect(function()
	didSkip = true
	return didSkip
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		if input.KeyCode == Enum.KeyCode.Space then
			didSkip = true
		end
	else
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			didSkip = true
			if inDialog or menuOpen.Value then
				return nil
			end
			local npc = getNpcAtMouse()
			if npc and npc.Parent == npcsFolder and dialog[npc.Name] ~= nil then
				local root = dialog[npc.Name]
				local _value = npc:GetAttribute("default_lookAt")
				if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
					local _fn = npc
					local _position = npc.Position
					local _lookVector = npc.CFrame.LookVector
					_fn:SetAttribute("default_lookAt", _position + _lookVector)
				end
				inDialog = true
				canMove.Value = false
				altitudeLabel.Visible = false
				speedometerLabel.Visible = false
				dialogHeader.Text = npc.Name
				dialogIcon.Image = root.icon
				dialogGUI.Visible = true
				local messageData = root.dialog.default
				for _, specialDialog in root.dialog.special do
					local shouldUse = false
					TS.try(function()
						shouldUse = specialDialog.condition(player, npc)
					end, function(err)
						shouldUse = false
					end)
					if shouldUse then
						messageData = specialDialog
						break
					end
				end
				local talkSound = Instance.new("Sound")
				talkSound.SoundId = root.talkSound
				talkSound.PlayOnRemove = true
				local cube = Workspace:WaitForChild(`cube{player.UserId}`)
				while inDialog do
					didSkip = false
					targetChoice = ""
					local targetLookAt
					local lookAt = messageData.faceTo
					if lookAt == "_player" then
						targetLookAt = cube.Position
					elseif lookAt == "_default" then
						targetLookAt = npc:GetAttribute("default_lookAt")
					else
						targetLookAt = lookAt
					end
					TweenService:Create(npc, Info, {
						CFrame = CFrame.lookAt(npc.Position, targetLookAt or Vector3.new(0, 0, 0)),
					}):Play()
					for _, button in GameDialogChoices:GetChildren() do
						if button:IsA("TextButton") then
							button:Destroy()
						end
					end
					local text = messageData.message
					dialogMessage.Text = text
					for i = 1, #dialogMessage.Text do
						dialogMessage.MaxVisibleGraphemes = i
						if didSkip then
							local skipSound = talkSound:Clone()
							skipSound.PlaybackSpeed = 0.9
							skipSound.Parent = Workspace
							skipSound:Destroy()
							break
						else
							local character = string.sub(text, i, i)
							if character ~= " " then
								local newTalkSound = talkSound:Clone()
								newTalkSound.PlaybackSpeed = randomFloat(0.95, 1.05)
								newTalkSound.Parent = Workspace
								newTalkSound:Destroy()
							end
						end
						task.wait(randomFloat(root.talkDelay[1], root.talkDelay[2]))
					end
					dialogMessage.MaxVisibleGraphemes = -1
					local usableChoices = {}
					for text, choice in pairs(messageData.choices) do
						local _condition = choice.condition
						if type(_condition) == "function" then
							local isEnabled = false
							TS.try(function()
								isEnabled = choice.condition(player, npc)
							end, function(err)
								isEnabled = false
							end)
							if not isEnabled then
								continue
							end
						end
						local _arg0 = { text, choice }
						table.insert(usableChoices, _arg0)
					end
					local width = 1 / (#usableChoices + (if messageData.goodbyeEnabled then 1 else 0))
					local events = {}
					local i = 0
					for _, data in pairs(usableChoices) do
						local text = data[1]
						local button = choiceTemplate:Clone()
						button.Text = text
						button.Size = UDim2.fromScale(width, 1)
						button.LayoutOrder = i
						button.Name = text
						button.Parent = GameDialogChoices
						local event = button.MouseButton1Click:Once(function()
							if #targetChoice > 0 then
								return nil
							end
							targetChoice = text
							Events.PickedDialogChoice:Fire(targetChoice, npc)
						end)
						table.insert(events, event)
						i += 1
					end
					if messageData.goodbyeEnabled then
						local button = choiceTemplate:Clone()
						button.Text = "Goodbye!"
						button.Size = UDim2.fromScale(width, 1)
						button.LayoutOrder = 999999999
						button.Parent = GameDialogChoices
						local event = button.MouseButton1Click:Once(function()
							if #targetChoice > 0 then
								return nil
							end
							targetChoice = "_goodbye"
							Events.PickedDialogChoice:Fire(targetChoice, npc)
						end)
						table.insert(events, event)
					end
					Events.PickedDialogChoice.Event:Wait()
					for _, event in events do
						event:Disconnect()
					end
					local _func = messageData.func
					if type(_func) == "function" then
						TS.try(function()
							messageData.func(player, npc)
						end, function(err)
							warn("[src/client/map/npcs.client.ts:249]", err)
						end)
					end
					if targetChoice == "_goodbye" then
						inDialog = false
					else
						local new_message = messageData.choices[targetChoice]
						messageData = new_message
					end
				end
				dialogGUI.Visible = false
				TweenService:Create(npc, Info, {
					CFrame = CFrame.lookAt(npc.Position, npc:GetAttribute("default_lookAt")),
				}):Play()
				canMove.Value = true
				altitudeLabel.Visible = true
				speedometerLabel.Visible = true
			end
		end
	end
end)
UserInputService.InputChanged:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local npc = getNpcAtMouse()
		if npc and not inDialog and not menuOpen.Value then
			setMouseIcon(true)
		else
			setMouseIcon(false)
		end
	end
end)
