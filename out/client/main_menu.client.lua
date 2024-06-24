-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local TweenService = _services.TweenService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local getTime = _utils.getTime
local getHammerTexture = _utils.getHammerTexture
local getPlayerRank = _utils.getPlayerRank
local playSound = _utils.playSound
local Accessories = _utils.Accessories
local tweenTypes = _utils.tweenTypes
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local GUI = player:WaitForChild("PlayerGui")
local canMove = GUI:WaitForChild("Values"):WaitForChild("can_move")
local menuGui = GUI:WaitForChild("MainMenuGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local playButton = menuGui:WaitForChild("Play")
local editButton = menuGui:WaitForChild("Edit")
local titleLabel = menuGui:WaitForChild("Title")
local hintLabel = menuGui:WaitForChild("Hint")
local shadow = menuGui:WaitForChild("Shadow")
local shadowTitle = shadow:WaitForChild("Title")
local shadowText = shadow:WaitForChild("Loading")
local effectsFolder = Workspace:WaitForChild("Effects")
local didClickButton = false
player.AttributeChanged:Connect(function(attr)
	local _value = attr == "isNew" and player:GetAttribute(attr)
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		(screenGui:WaitForChild("TutorialGUI")).Visible = true
		canMove.Value = false
	end
end)
menuGui.Enabled = true
screenGui.Enabled = false
while true do
	local _value = menuGui:GetAttribute("done")
	if not not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
		break
	end
	menuGui.AttributeChanged:Wait()
end
repeat
	do
		shadowText.Text = "retrieving player data" .. string.rep(".", math.round(getTime() * 5 % 3))
		task.wait()
	end
	local _value = player:GetAttribute("DATA_LOADED")
until _value ~= 0 and _value == _value and _value ~= "" and _value
shadowText.Text = "done!"
shadow:TweenSize(UDim2.fromScale(0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5)
local menuAssets = Workspace:WaitForChild("MainMenuAssets")
local hammer = menuAssets:WaitForChild("Hammer")
UserInputService.InputBegan:Once(function()
	local currentHammer = getHammerTexture()
	local arm = hammer:WaitForChild("Arm")
	local head = hammer:WaitForChild("Arm")
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
	TweenService:Create(hintLabel, tweenTypes.linear.short, {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	TweenService:Create(playButton, tweenTypes.linear.short, {
		TextTransparency = 0,
		BackgroundTransparency = 0.6,
	}):Play()
	TweenService:Create(titleLabel, tweenTypes.linear.short, {
		TextTransparency = 0,
		TextStrokeTransparency = 0,
	}):Play()
	if getPlayerRank(player) >= 1 then
		TweenService:Create(editButton, tweenTypes.linear.short, {
			TextTransparency = 0,
			BackgroundTransparency = 0.6,
		}):Play()
	else
		editButton:SetAttribute("disabled", true)
		TweenService:Create(editButton, tweenTypes.linear.short, {
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
	local _value = player:GetAttribute("in_main_menu")
	local _condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
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
	TweenService:Create(shadow, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 0,
	}):Play()
	task.wait(0.6)
	TweenService:Create(shadow, tweenTypes.linear.short, {
		Size = UDim2.fromScale(0, 0),
	}):Play()
	task.delay(1, function()
		menuGui.Enabled = false
		return menuGui.Enabled
	end)
	player:SetAttribute("in_main_menu", nil)
end)
editButton.MouseButton1Click:Once(function()
	local _value = editButton:GetAttribute("disabled")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
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
	TweenService:Create(shadow, tweenTypes.linear.short, {
		BackgroundTransparency = 0,
	}):Play()
	task.wait(1);
	(ReplicatedStorage:FindFirstChild("JoinEdit")):FireServer()
end)
