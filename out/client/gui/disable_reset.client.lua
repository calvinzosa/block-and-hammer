-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local StarterGui = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").StarterGui
while true do
	local _exitType, _returns = TS.try(function()
		StarterGui:SetCore("ResetButtonCallback", false)
		return TS.TRY_BREAK
	end, function(err) end)
	if _exitType then
		break
	end
end
