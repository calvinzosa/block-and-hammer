-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").ReplicatedStorage
local accessoryModels = ReplicatedStorage:WaitForChild("AccessoryModels")
local default = {
	["Default Face"] = {
		modifier = false,
		badge_id = 0,
		badge_name = "",
		acc_type = "cube_Face",
		always_show = true,
		icon = "rbxassetid://8645894586",
		data = "rbxassetid://8645894586",
		description = "the default face",
	},
	Tsu = {
		modifier = false,
		badge_id = 0,
		badge_name = "",
		acc_type = "cube_Face",
		always_show = true,
		icon = "rbxassetid://10276551565",
		data = "rbxassetid://10276551565",
		description = "ツ",
	},
	["Upside-down"] = {
		modifier = false,
		badge_id = 2146247056,
		badge_name = "flipped",
		acc_type = "cube_Face",
		always_show = true,
		icon = "rbxassetid://11095319213",
		data = "rbxassetid://11095319213",
		description = "what happened there?",
	},
	Sad = {
		modifier = false,
		badge_id = 2146259996,
		badge_name = "trapped",
		acc_type = "cube_Face",
		always_show = true,
		icon = "rbxassetid://3868600",
		data = "rbxassetid://3868600",
		description = ":(",
	},
	Si = {
		modifier = false,
		badge_id = 2146538368,
		badge_name = "speedrunner!",
		acc_type = "cube_Face",
		always_show = true,
		icon = "rbxassetid://13615361065",
		data = "rbxassetid://13615361065",
		description = "シ",
	},
	["No Hat"] = {
		modifier = false,
		badge_id = 0,
		badge_name = "",
		acc_type = "cube_Hat",
		always_show = true,
		icon = "rbxassetid://6790887263",
		data = 0,
		description = "when you don\'t wanna hav a hat",
	},
	Tophat = {
		modifier = false,
		badge_id = 2146295992,
		badge_name = "pacifist",
		acc_type = "cube_Hat",
		always_show = true,
		icon = "rbxassetid://446791469",
		data = accessoryModels:WaitForChild("TopHat"),
		description = "quite stylish",
	},
	Duck = {
		modifier = false,
		badge_id = 2146289079,
		badge_name = "the duck",
		acc_type = "cube_Hat",
		always_show = true,
		icon = "rbxassetid://12877054",
		data = accessoryModels:WaitForChild("Duck"),
		description = "quack",
	},
	["404 TopHat"] = {
		modifier = false,
		badge_id = 2146357550,
		badge_name = "errorland",
		acc_type = "cube_Hat",
		always_show = false,
		icon = "rbxassetid://13576145304",
		data = accessoryModels:WaitForChild("ErrorTopHat"),
		description = "404 Not Found",
	},
	["Free Accessory"] = {
		modifier = false,
		badge_id = 2146441455,
		badge_name = "free accessory",
		acc_type = "cube_Hat",
		always_show = true,
		icon = "rbxassetid://13594356579",
		data = accessoryModels:WaitForChild("FreeAccessorySign"),
		description = "it\'s free! (maybe)",
	},
	["Party Hat"] = {
		modifier = false,
		badge_id = 2146588764,
		badge_name = "1k visits!!",
		acc_type = "cube_Hat",
		always_show = false,
		icon = "rbxassetid://13624672409",
		data = accessoryModels:WaitForChild("PartyHat"),
		description = "wooo 1k visits!!!",
	},
	["Instant Gyro"] = {
		modifier = false,
		badge_id = 2146508969,
		badge_name = "explosive",
		acc_type = "cube_Hat",
		always_show = true,
		icon = "rbxassetid://17740911909",
		data = accessoryModels:WaitForChild("InstantGyro"),
		description = "i feel more... stable (modifier: anti ragdoll)",
	},
	["Astronaut Helmet"] = {
		modifier = false,
		badge_id = 1719451122385638,
		badge_name = "free floater",
		acc_type = "cube_Hat",
		always_show = true,
		icon = "rbxassetid://17780195771",
		data = accessoryModels:WaitForChild("AstronautHelmet"),
		description = "am i in space? (passive modifier: lowered gravity)",
	},
	["35k Trophy"] = {
		modifier = false,
		badge_id = 4410861265533965,
		badge_name = "35K VISITS!!!!!!!!!!!!!!!!!!",
		acc_type = "cube_Hat",
		always_show = false,
		icon = "rbxassetid://17861553776",
		data = accessoryModels:WaitForChild("Trophy35k"),
		description = "no way!!!",
	},
	["No Aura"] = {
		modifier = false,
		badge_id = 0,
		badge_name = "",
		acc_type = "cube_Aura",
		always_show = true,
		icon = "rbxassetid://6790887263",
		data = 0,
		description = "when you don't want to have an aura",
	},
	Fire = {
		modifier = false,
		badge_id = 2146180612,
		badge_name = "crash landing",
		acc_type = "cube_Aura",
		always_show = true,
		icon = "rbxassetid://13563416875",
		data = accessoryModels:WaitForChild("Auras"):WaitForChild("Fire"),
		description = "my cube is on 🔥!",
	},
	Glow = {
		modifier = false,
		badge_id = 254003402602004,
		badge_name = "glowing",
		acc_type = "cube_Aura",
		always_show = true,
		icon = "rbxassetid://18102551584",
		data = accessoryModels:WaitForChild("Auras"):WaitForChild("Glow"),
		description = "🔴",
		copy_cube_color = true,
		spritesheet_data = {
			tileHeight = 341,
			tileWidth = 341,
			columns = 3,
			rows = 3,
			fps = 30,
			loopDelay = 0.5,
		},
	},
	["No Hammer Texture"] = {
		modifier = false,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = true,
		icon = "rbxassetid://6790887263",
		data = 0,
		description = "when you don\'t want to have a hammer texture",
	},
	["Golden Hammer"] = {
		modifier = false,
		badge_id = 2146411244,
		badge_name = "professional climber I",
		acc_type = "hammer_Texture",
		always_show = true,
		icon = "rbxassetid://13604331169",
		data = "golden",
		description = "shiny",
	},
	["Steel Hammer"] = {
		modifier = false,
		badge_id = 4010328408057079,
		badge_name = "made of steel!",
		acc_type = "hammer_Texture",
		always_show = true,
		icon = "rbxassetid://17749276456",
		data = "steelhammer",
		description = "very metallic (passive modifier: 1.5x hammer strength + create a hole in the map when you hit something) [MODIFIER TEMP DISABLED]",
	},
	["Spring Hammer"] = {
		modifier = false,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_spring",
		description = "boioioing",
		never = true,
	},
	["404 Hammer"] = {
		modifier = true,
		badge_id = 2146308286,
		badge_name = "404",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "rbxassetid://13588879827",
		data = "error",
		description = "404 Not Found (ability modifier: 0.5x time)",
	},
	["Grappling Hammer"] = {
		modifier = true,
		badge_id = 2146687990,
		badge_name = "ultra speed!",
		acc_type = "hammer_Texture",
		always_show = true,
		icon = "rbxassetid://13645594163",
		data = "_grapple",
		description = "spiderman (ability modifier: grapple)",
	},
	["Explosive Hammer"] = {
		modifier = true,
		badge_id = 4279006041653694,
		badge_name = "METEOR!",
		acc_type = "hammer_Texture",
		always_show = true,
		icon = "rbxassetid://13608636138",
		data = "explosive",
		description = "that\'s... too op (passive modifier: explode on ground smash, ability modifier: explode mid-air with a 2s cooldown)",
	},
	["Inverter Hammer"] = {
		modifier = true,
		badge_id = 2146247056,
		badge_name = "flipped",
		acc_type = "hammer_Texture",
		always_show = true,
		icon = "rbxassetid://17759701868",
		data = "inverterhammer",
		description = "wait i\'m upside down again? (ability modifier: flip gravity with 0.5s cooldown)",
	},
	["Long Hammer"] = {
		modifier = true,
		badge_id = 2479031288528448,
		badge_name = "longshot",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "rbxassetid://17787573906",
		data = "long",
		description = "no comment (passive modifier: like around 3x more range)",
	},
	["Icy Hammer"] = {
		modifier = true,
		badge_id = 2512066188170235,
		badge_name = "freezing misfortune",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "rbxassetid://17861579303",
		data = "ice",
		description = "🧊 (passive modifier: no friction + breaks for 3s when smashed onto the ground)",
	},
	["God\'s Hammer"] = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_God",
	},
	["REAL Golden Hammer"] = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_realgold",
	},
	Mallet = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_mallet",
	},
	Platform = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_platform",
	},
	["Builder Hammer"] = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_build",
	},
	Shotgun = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_shotgun",
	},
	["Hitbox Hammer"] = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "hammer_Texture",
		always_show = false,
		icon = "",
		data = "_hitbox",
	},
	["Propeller Hat"] = {
		modifier = true,
		never = true,
		badge_id = 0,
		badge_name = "",
		acc_type = "cube_Hat",
		always_show = false,
		icon = "",
		data = accessoryModels:WaitForChild("PropellerHat"),
	},
}
return {
	default = default,
}
