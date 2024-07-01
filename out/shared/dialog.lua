-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local PlayerAttributes = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").PlayerAttributes
local Events = {
	FinishQuest = ReplicatedStorage:WaitForChild("FinishQuest"),
	ClientStartQuest = ReplicatedStorage:WaitForChild("ClientStartQuest"),
}
local default = {
	TestDialog = {
		icon = "",
		talkSound = "",
		talkDelay = { 0.1, 0.1 },
		dialog = {
			default = {
				message = "This is a test dialog.\n2nd line.",
				goodbyeEnabled = true,
				faceTo = "_player",
				choices = {
					["Ok."] = {
						message = "idk what top ut hereo wdkawskfw1w2qwrfs",
						goodbyeEnabled = false,
						faceTo = "_default",
						choices = {
							["no!"] = {
								message = "ok bye",
								goodbyeEnabled = true,
								faceTo = "_player",
								choices = {},
							},
						},
					},
				},
			},
			special = {},
		},
	},
	Orange = {
		icon = "",
		talkSound = "rbxassetid://7772738671",
		talkDelay = { 0.01, 0.015 },
		dialog = {
			default = {
				message = "Oh, hello!",
				goodbyeEnabled = true,
				faceTo = "_player",
				choices = {
					["Hello!"] = {
						message = "This waterfall is nice, isn\'t it?",
						goodbyeEnabled = true,
						faceTo = "_default",
						choices = {
							["It sure is!"] = {
								message = "Hey, if you get my steel hammer near the swamp, I\'ll let you have it!",
								goodbyeEnabled = false,
								faceTo = "_player",
								choices = {
									["Sure!"] = {
										message = "Cool! I\'ll wait for you here.",
										goodbyeEnabled = true,
										faceTo = "_player",
										choices = {},
										func = function(player, npc)
											return Events.ClientStartQuest:Fire("LostSteelHammer")
										end,
									},
									["Sorry, I can\'t do that right now."] = {
										message = "Okay, that\'s fine.",
										goodbyeEnabled = true,
										faceTo = "_player",
										choices = {},
									},
								},
							},
						},
					},
				},
			},
			special = { {
				condition = function(player)
					return player:GetAttribute(PlayerAttributes.ActiveQuest) == "LostSteelHammer"
				end,
				message = "I see you\'re back, have you found it yet?",
				goodbyeEnabled = false,
				faceTo = "_player",
				choices = {
					["I have found it!"] = {
						message = "Thank you! Here, you can have it.",
						goodbyeEnabled = true,
						faceTo = "_player",
						func = function()
							return Events.FinishQuest:FireServer()
						end,
						condition = function(player)
							local _condition = player:GetAttribute("hasSteelHammer")
							if _condition == nil then
								_condition = false
							end
							return _condition
						end,
						choices = {},
					},
					["Nope, not yet"] = {
						message = "Oh, okay then.",
						goodbyeEnabled = true,
						faceTo = "_player",
						choices = {},
					},
					["Where is it?"] = {
						message = "I last remember it being in the swamp area.",
						goodbyeEnabled = true,
						faceTo = "_player",
						choices = {},
					},
				},
			} },
		},
	},
}
return {
	default = default,
}
