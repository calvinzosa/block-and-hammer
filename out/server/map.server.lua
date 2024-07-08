-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local GeometryService = _services.GeometryService
local HttpService = _services.HttpService
local RunService = _services.RunService
local Workspace = _services.Workspace
local startsWith = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "string-utils").startsWith
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local Badge = _utils.Badge
local giveBadge = _utils.giveBadge
local randomDirection = _utils.randomDirection
local Events = {
	PlaySound = ReplicatedStorage:FindFirstChild("PlaySound"),
}
local mapFolder = Workspace:FindFirstChild("Map")
local serverTimeLabel = ((mapFolder:FindFirstChild("ServerAgeSign")):FindFirstChild("SurfaceGui")):FindFirstChild("TextLabel")
local interactablesFolder = Workspace:FindFirstChild("Interactables")
local duck = interactablesFolder:FindFirstChild("Duck")
local untaggedParts = {}
for _, part in mapFolder:GetDescendants() do
	if not part:IsA("BasePart") then
		continue
	end
	local _exp = part:GetTags()
	-- ▼ ReadonlyArray.find ▼
	local _callback = function(tag)
		return startsWith(tag, "mapPart-")
	end
	local _result
	for _i, _v in _exp do
		if _callback(_v, _i - 1, _exp) == true then
			_result = _v
			break
		end
	end
	-- ▲ ReadonlyArray.find ▲
	if not (_result ~= "" and _result) then
		part:AddTag(`mapPart-{HttpService:GenerateGUID()}`)
		table.insert(untaggedParts, part)
	end
end
if #untaggedParts > 0 then
	warn("[src/server/map.server.ts:39]", `Found {#untaggedParts} untagged part(s):`)
	for _, part in untaggedParts do
		warn("[src/server/map.server.ts:40]", part, part:GetFullName())
	end
end
for i = 1, 300 do
	task.spawn(function()
		local vectorA = randomDirection()
		local vectorB = randomDirection()
		local debris = Instance.new("Part")
		debris.CFrame = CFrame.fromOrientation(vectorA.X * math.pi, vectorA.Y * math.pi, vectorA.Z * math.pi)
		local intersect = debris:Clone()
		intersect.CFrame = CFrame.fromOrientation(vectorB.X * math.pi, vectorB.Y * math.pi, vectorB.Z * math.pi)
		local unions = GeometryService:IntersectAsync(debris, { intersect })
		for _, union in unions do
			union.UsePartColor = true
			union.CollisionGroup = "debris"
			union.TopSurface = Enum.SurfaceType.Smooth
			union.BottomSurface = Enum.SurfaceType.Smooth
			union.Parent = ReplicatedStorage:FindFirstChild("DebrisTypes")
		end
		debris:Destroy()
		intersect:Destroy()
	end)
end
(duck:FindFirstChild("Interacted")).OnServerEvent:Connect(function(player)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = not _result
	if not _condition then
		local _position = cube.Position
		local _position_1 = duck.Position
		_condition = (_position - _position_1).Magnitude > 50
	end
	if _condition then
		return nil
	end
	Events.PlaySound:FireClient(player, "quack")
	giveBadge(player, Badge.TheDuck)
end)
RunService.Stepped:Connect(function(currentTime)
	local seconds = math.floor(currentTime % 60)
	local minutes = math.floor(currentTime / 60) % 60
	local hours = math.floor(currentTime / 3600)
	if hours > 0 then
		serverTimeLabel.Text = string.format("this server has been running for %sh, %sm, %ss", hours, minutes, seconds)
	elseif minutes > 0 then
		serverTimeLabel.Text = string.format("this server has been running for %sm, %ss", minutes, seconds)
	else
		serverTimeLabel.Text = string.format("this server has been running for %ss", seconds)
	end
end)
