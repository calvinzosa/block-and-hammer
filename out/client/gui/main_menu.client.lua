-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local TweenService = _services.TweenService
local RunService = _services.RunService
local StarterGui = _services.StarterGui
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local getHammerTexture = _utils.getHammerTexture
local PlayerAttributes = _utils.PlayerAttributes
local getPlayerRank = _utils.getPlayerRank
local Accessories = _utils.Accessories
local playSound = _utils.playSound
local getTime = _utils.getTime
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or (Workspace:WaitForChild("Camera"))
local GUI = player:WaitForChild("PlayerGui")
local canMove = GUI:WaitForChild("Values"):WaitForChild("can_move")
local menuGui = GUI:WaitForChild("MainMenuGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local tutorialGui = screenGui:WaitForChild("TutorialGUI")
local playButton = menuGui:WaitForChild("Play")
local editButton = menuGui:WaitForChild("Edit")
local titleLabel = menuGui:WaitForChild("Title")
local hintLabel = menuGui:WaitForChild("Hint")
local shadow = menuGui:WaitForChild("Shadow")
local shadowTitle = shadow:WaitForChild("Title")
local shadowText = shadow:WaitForChild("Loading")
local effectsFolder = Workspace:WaitForChild("Effects")
local didClickButton = false
local _value = player:GetAttribute(PlayerAttributes.IsNew)
if _value ~= 0 and _value == _value and _value ~= "" and _value then
	tutorialGui.Visible = true
	canMove.Value = false
end
player.AttributeChanged:Connect(function(attr)
	local _value_1 = attr == PlayerAttributes.IsNew and player:GetAttribute(attr)
	if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
		tutorialGui.Visible = true
		canMove.Value = false
	end
end)
menuGui.Enabled = true
screenGui.Enabled = false
task.spawn(function()
	while true do
		local _exitType, _returns = TS.try(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
			return TS.TRY_BREAK
		end, function(err)
			task.wait(0.1)
		end)
		if _exitType then
			break
		end
	end
end)
while true do
	local _value_1 = menuGui:GetAttribute("done")
	if not not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1) then
		break
	end
	menuGui.AttributeChanged:Wait()
end
repeat
	do
		shadowText.Text = "retrieving player data" .. string.rep(".", math.round((getTime() * 5) % 3))
		task.wait()
	end
	local _value_1 = player:GetAttribute(PlayerAttributes.HasDataLoaded)
until _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1
shadowText.Text = "done!"
shadow:TweenSize(UDim2.fromScale(0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5)
local menuAssets = Workspace:WaitForChild("MainMenuAssets")
local hammer = menuAssets:WaitForChild("Hammer")
UserInputService.InputBegan:Once(function()
	local currentHammer = getHammerTexture()
	local arm = hammer:WaitForChild("Arm")
	local head = hammer:WaitForChild("Head")
	if currentHammer == Accessories.HammerTexture.Hammer404 then
		for _, part in { head, arm } do
			for _1, face in Enum.NormalId:GetEnumItems() do
				local texture = Instance.new("Texture")
				texture.Face = face
				texture.Texture = "rbxassetid://9994130132"
				texture.Name = "ERROR_TEXTURE"
				texture.Parent = part
			end
		end
	elseif currentHammer == Accessories.HammerTexture.ExplosiveHammer then
		arm.BrickColor = BrickColor.new("Medium stone grey")
		arm.Material = Enum.Material.DiamondPlate
		head.BrickColor = BrickColor.new("Really red")
		head.Material = Enum.Material.Neon
	end
	local start = hammer:GetPivot()
	local goal = (menuAssets:WaitForChild("EndAnim")).CFrame
	for i = 0, 1, 0.1 do
		hammer:PivotTo(start:Lerp(goal, i))
		task.wait()
	end
	hammer:PivotTo(goal)
	playButton.Visible = true
	-- menuGui.Edit.Visible = true
	titleLabel.Visible = true
	local Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
	TweenService:Create(hintLabel, Info, {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	TweenService:Create(playButton, Info, {
		TextTransparency = 0,
		BackgroundTransparency = 0.6,
	}):Play()
	TweenService:Create(titleLabel, Info, {
		TextTransparency = 0,
		TextStrokeTransparency = 0,
	}):Play()
	if getPlayerRank(player) >= 1 then
		TweenService:Create(editButton, Info, {
			TextTransparency = 0,
			BackgroundTransparency = 0.6,
		}):Play()
	else
		editButton:SetAttribute("disabled", true)
		TweenService:Create(editButton, Info, {
			TextTransparency = 0.4,
			BackgroundTransparency = 0.4,
		}):Play()
	end
	local spark = ReplicatedStorage:WaitForChild("Particles"):WaitForChild("spark"):Clone()
	spark.CFrame = CFrame.lookAt((menuAssets:WaitForChild("SparkPosition")).Position, head.Position);
	(spark:FindFirstChild("ParticleEmitter")).Rate = math.huge
	spark.Parent = effectsFolder
	task.delay(0.15, function()
		local _exp = (spark:FindFirstChild("ParticleEmitter"))
		_exp.Enabled = false
		return _exp.Enabled
	end)
	playSound("hit1", {
		PlaybackSpeed = 0.8,
		Volume = 0.5,
	})
	if currentHammer == Accessories.HammerTexture.Hammer404 then
		playSound("error2", {
			PlaybackSpeed = 1,
			Volume = 1.5,
		})
		playSound("hit2", {
			PlaybackSpeed = 0.8,
			Volume = 1.5,
		})
	elseif currentHammer == Accessories.HammerTexture.ExplosiveHammer then
		playSound("explosion", {
			Volume = 1.5,
		})
		playSound("hit2", {
			Volume = 1.5,
		})
		Instance.new("Explosion", Workspace).Position = head.Position
	end
end)
local connection = nil
connection = RunService.RenderStepped:Connect(function()
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	if cube then
		cube.Anchored = true
	end
	local _value_1 = player:GetAttribute(PlayerAttributes.Client.InMainMenu)
	local _condition = not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1)
	if _condition then
		_condition = connection
	end
	if _condition then
		connection:Disconnect()
		screenGui.Enabled = true
		menuGui.Enabled = false
		if cube then
			cube.Anchored = false
		end
		while true do
			local _exitType, _returns = TS.try(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				return TS.TRY_BREAK
			end, function(err)
				task.wait(0.1)
			end)
			if _exitType then
				break
			end
		end
		return nil
	end
	camera.FieldOfView = 70
	camera.CFrame = (menuAssets:FindFirstChild("CameraCFrame")).CFrame
end)
playButton.MouseButton1Click:Once(function()
	if didClickButton then
		return nil
	end
	didClickButton = true
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.BackgroundTransparency = 1
	shadowTitle.Visible = false
	shadowText.Visible = false
	local Info = TweenInfo.new(0.6, Enum.EasingStyle.Linear)
	TweenService:Create(shadow, Info, {
		BackgroundTransparency = 0,
	}):Play()
	task.wait(0.6)
	TweenService:Create(shadow, Info, {
		Size = UDim2.fromScale(0, 0),
	}):Play()
	task.delay(1, function()
		menuGui.Enabled = false
		return menuGui.Enabled
	end)
	player:SetAttribute(PlayerAttributes.Client.InMainMenu, nil)
end)
editButton.MouseButton1Click:Once(function()
	local _value_1 = editButton:GetAttribute("disabled")
	if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
		return nil
	end
	if not didClickButton then
		return nil
	end
	didClickButton = true
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.BackgroundTransparency = 1
	titleLabel.Visible = false
	shadowText.Visible = false
	local Info = TweenInfo.new(0.6, Enum.EasingStyle.Linear)
	TweenService:Create(shadow, Info, {
		BackgroundTransparency = 0,
	}):Play()
	task.wait(1);
	(ReplicatedStorage:FindFirstChild("JoinEdit")):FireServer()
end)
