import {
    ReplicatedStorage,
    UserInputService,
    HttpService,
    RunService,
    Workspace,
    Players,
	Lighting,
} from '@rbxts/services';

import { $print, $warn } from 'rbxts-transform-debug';

import {
    PlayerAttributes,
    getSettingAlias,
    getSettingOrder,
    canUseSetting,
    fixSettings,
	GameSetting,
    getSetting,
	setSetting,
    Settings,
    getTime,
} from 'shared/utils';

const Events = {
	'SetModifiersSetting': ReplicatedStorage.WaitForChild('SetModifiersSetting') as RemoteEvent,
    'LoadSettingsJSON': ReplicatedStorage.WaitForChild('LoadSettingsJSON') as RemoteEvent,
    'SaveSettingsJSON': ReplicatedStorage.WaitForChild('SaveSettingsJSON') as RemoteEvent,
    'EndTutorial': ReplicatedStorage.WaitForChild('EndTutorial') as RemoteEvent,
    'Reset': ReplicatedStorage.WaitForChild('Reset') as RemoteEvent,
	
	'StartClientTutorial': ReplicatedStorage.WaitForChild('StartClientTutorial') as BindableEvent,
	'SettingChanged': ReplicatedStorage.WaitForChild('SettingChanged') as BindableEvent,
	'ClientReset': ReplicatedStorage.WaitForChild('ClientReset') as BindableEvent,
};

const debounces = {
	reset: false
};

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const effectsFolder = Workspace.WaitForChild('Effects') as Folder;
const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const isSpectating = valueInstances.WaitForChild('is_spectating') as BoolValue;
const spectatePlayer = isSpectating.WaitForChild('player') as StringValue;
const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
const menuOpen = valueInstances.WaitForChild('menu_open') as BoolValue;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const placeVersion = screenGui.WaitForChild('PlaceVersion') as TextLabel;
const menuGui = screenGui.WaitForChild('Menu') as Frame;
const menuButtons = menuGui.WaitForChild('Buttons') as Frame;
const accessoriesGui = screenGui.WaitForChild('AccessoriesGUI') as Frame;
const spectatingGui = screenGui.WaitForChild('SpectatingGUI') as Frame;
const settingsGui = screenGui.WaitForChild('SettingsGui') as Frame;
const settingButtons = settingsGui.WaitForChild('Buttons') as ScrollingFrame;
const resetConfirmation = screenGui.WaitForChild('ResetConfirmation') as Frame;
const tutorialConfirmation = screenGui.WaitForChild('TutorialConfirmation') as Frame;
const colorChanger = screenGui.WaitForChild('ColorChanger') as Frame;
const credits = screenGui.WaitForChild('Credits') as Frame;
const questGui = screenGui.WaitForChild('QuestGUI') as Frame;
const leaderboardGui = screenGui.WaitForChild('LeaderboardGUI') as Frame;
const changelogsGui = screenGui.WaitForChild('Changelogs') as Frame;
const replaysGui = screenGui.WaitForChild('ReplaysGUI') as Frame;
const statsGui = screenGui.WaitForChild('StatsGUI') as Frame;

const clickThreshold = 0.2;
const playerList: string[] = [  ];

let lastChange = getTime();
let areSettingsSaved = true;
let previousSettings = table.clone(Settings);
let clickCount = 0;
let lastClickTime = 0;

function resetCharacter(fullReset: boolean = false) {
    let cube = Workspace.FindFirstChild(`cube${player.UserId}`) as (BasePart | undefined);
    
	if (player.GetAttribute(PlayerAttributes.InErrorLand)) {
		if (cube) cube.PivotTo(new CFrame(0, 14, 0));
		return;
    }
	
	if (player.GetAttribute(PlayerAttributes.Client.InTutorial)) {
		if (cube) {
            cube.Destroy();
            cube = undefined;
        }
		
		Events.EndTutorial.FireServer();
    }
	
	if (!cube?.IsA('BasePart') || fullReset) {
		Events.ClientReset.Fire(true);
		Events.Reset.FireServer(true);
    } else {
		Events.ClientReset.Fire(false);
		Events.Reset.FireServer(false);
		
		cube.PivotTo(new CFrame(0, 14, 0));
		cube.AssemblyLinearVelocity = Vector3.zero;
        for (const descendant of cube.GetDescendants()) {
            if (descendant.IsA('BasePart')) descendant.AssemblyLinearVelocity = Vector3.zero;
        }
    }
	
	effectsFolder.ClearAllChildren();
}

function updateSettingButtons() {
	for (const button of settingButtons.GetChildren()) {
		if (button.IsA('TextButton')) button.Destroy();
	}
	
	for (const [ name, value ] of pairs(Settings)) {
		const alias = getSettingAlias(name);
		const isUsable = canUseSetting(name);
		const order = getSettingOrder(name);
		
		const button = guiTemplates.FindFirstChild('SettingToggle')?.Clone() as TextButton;
		button.LayoutOrder = order;
		button.Name = alias;
		button.Text = `${alias}: ${value ? '✅' : '❌'}`;
		
		if (isUsable) {
			button.AutoButtonColor = true;
			button.BackgroundTransparency = 0.7;
			button.TextColor3 = Color3.fromRGB(255, 255, 255);
		} else {
			button.AutoButtonColor = false;
			button.BackgroundTransparency = 0.5;
			button.TextColor3 = Color3.fromRGB(175, 175, 175);
			button.SetAttribute('disabled', true);
		}
		
		button.Parent = settingButtons;
		
		if (isUsable) {
			button.MouseButton1Click.Connect(() => {
				const currentValue = !getSetting(name as GameSetting);
				setSetting(name as GameSetting, currentValue);
				if (name === GameSetting.Modifiers) Events.SetModifiersSetting.FireServer(getSetting(GameSetting.Modifiers));
				else if (name === GameSetting.TimerGUI) (screenGui.FindFirstChild('Timer') as TextLabel).Visible = getSetting(GameSetting.TimerGUI);
				
				button.Text = `${alias}: ${currentValue ? '✅' : '❌'}`;
			});
		}
	}
	
	fixSettings();
	player.SetAttribute(PlayerAttributes.Client.SettingsJSON, HttpService.JSONEncode(Settings));
}

UserInputService.InputBegan.Connect((input, processed) => {
	if (processed) return;
	
	if (input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
		const currentTime = getTime();
		if ((currentTime - lastClickTime) < clickThreshold) {
			clickCount++;
			
			if ((clickCount === 2 && !UserInputService.TouchEnabled) || (clickCount >= 3 && UserInputService.TouchEnabled)) {
				if (!isSpectating.Value) {
					if (canMove.Value || menuOpen.Value) {
						canMove.Value = menuOpen.Value;
						menuOpen.Value = !menuOpen.Value;
					}
				}
				clickCount = 0;
			}
		} else clickCount = 1;
		
		lastClickTime = currentTime;
	}
});

UserInputService.InputEnded.Connect((input, processed) => {
	if (input.KeyCode === Enum.KeyCode.R && UserInputService.IsKeyDown(Enum.KeyCode.LeftControl) && !processed) resetCharacter(UserInputService.IsKeyDown(Enum.KeyCode.LeftShift));
});

RunService.RenderStepped.Connect((dt) => {
	const currentTime = getTime();
	
	const alpha = dt * 15;
	
	if (menuOpen.Value) menuGui.AnchorPoint = menuGui.AnchorPoint.Lerp(new Vector2(0, 0.5), alpha);
	else menuGui.AnchorPoint = menuGui.AnchorPoint.Lerp(new Vector2(1, 0.5), alpha);
	
	const shouldHideOthers = getSetting(GameSetting.HideOthers);
	
	for (const otherPlayer of Players.GetPlayers()) {
		if (otherPlayer === player) continue;
		
		const cube = Workspace.FindFirstChild(`cube${otherPlayer.UserId}`);
		if (cube?.IsA('BasePart')) {
			const cubeTransparency = shouldHideOthers ? 1 : (cube.GetAttribute('transparency') as (number | undefined) ?? 0);
			
			cube.LocalTransparencyModifier = cubeTransparency;
			for (const part of [ cube?.FindFirstChild('Arm'), cube.FindFirstChild('Head') ]) {
				if (part?.IsA('BasePart')) {
					const transparency = shouldHideOthers ? 1 : (cube.GetAttribute('hammerTransparency') as (number | undefined) ?? 0);
					part.LocalTransparencyModifier = transparency;
				}
			}
			
			const nameDisplay = cube.FindFirstChild('NameDisplay') as (BillboardGui | undefined);
			if (nameDisplay) nameDisplay.Enabled = !shouldHideOthers;
		}
	}
	
	if (playerList.size() > 0) {
		let idx = playerList.findIndex((name) => name === spectatePlayer.Value);
		if (idx <= 0) {
			spectatePlayer.Value = playerList[0];
			idx = 0;
		}
		
		spectatePlayer.Value = playerList[idx];
	}
	
	for (const [ name, value ] of pairs(Settings)) {
		if (previousSettings[name] !== value) {
			lastChange = currentTime;
			areSettingsSaved = false;
			
			previousSettings[name] = value;
		}
	}
	
	if ((currentTime - lastChange) > 5 && !areSettingsSaved && !settingsGui.Visible) {
		$print(`Saved settings: ${HttpService.JSONEncode(Settings)}`);
		Events.SaveSettingsJSON.FireServer(Settings);
		areSettingsSaved = true;
	}
});

Events.LoadSettingsJSON.OnClientEvent.Connect((settingsJSON: string) => {
	const [ success, newSettings ] = pcall(() => HttpService.JSONDecode(settingsJSON)) as LuaTuple<[ boolean, Record<string, boolean> ]>;
	
	if (success && typeIs(newSettings, 'table')) {
		for (const [ name ] of pairs(Settings)) {
			if (name in newSettings) setSetting(name, newSettings[name]);
		}
		
		if (getSetting(GameSetting.Modifiers)) Events.SetModifiersSetting.FireServer(true);
		
		updateSettingButtons();
		
		$print(`Loaded settings data: ${settingsJSON}`);
	} else $warn('Unable to decode settings data');
});

(menuButtons.WaitForChild('Reset') as TextButton).MouseButton1Click.Connect(() => {
	if (debounces.reset) return;
	
	menuOpen.Value = false;
	resetConfirmation.Visible = true;
});

(resetConfirmation.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	resetConfirmation.Visible = false;
	menuOpen.Value = true;
});

(resetConfirmation.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
	canMove.Value = true;
	resetConfirmation.Visible = false;
	
	if (debounces.reset) return;
	
	debounces.reset = true;
	task.delay(1.5, () => debounces.reset = false);
	
	resetCharacter();
});

(resetConfirmation.WaitForChild('FullReset') as TextButton).MouseButton1Click.Connect(() => {
	canMove.Value = true;
	resetConfirmation.Visible = false;
	
	if (debounces.reset) return;
	
	debounces.reset = true;
	task.delay(1.5, () => debounces.reset = false);
	
	resetCharacter(true);
});

(menuButtons.WaitForChild('Settings') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	settingsGui.Visible = true;
	
	updateSettingButtons();
});

(menuButtons.WaitForChild('Accessories') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	accessoriesGui.Visible = true;
});

(accessoriesGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	accessoriesGui.Visible = false;
});

(menuButtons.WaitForChild('Spectate') as TextButton).MouseButton1Click.Connect(() => {
	isSpectating.Value = true;
	spectatingGui.Visible = true;
	menuOpen.Value = false;
});

(spectatingGui.WaitForChild('Stop') as TextButton).MouseButton1Click.Connect(() => {
	isSpectating.Value = false;
	spectatingGui.Visible = false;
	menuOpen.Value = true;
});

(spectatingGui.WaitForChild('Next') as TextButton).MouseButton1Click.Connect(() => {
	let playerIndex = playerList.findIndex((name) => name === spectatePlayer.Name);
	if (playerIndex >= 0) {
		playerIndex++;
		if (playerIndex >= playerList.size()) playerIndex = 0;
		
		spectatePlayer.Value = playerList[playerIndex];
	}
});

(spectatingGui.WaitForChild('Previous') as TextButton).MouseButton1Click.Connect(() => {
	let playerIndex = playerList.findIndex((name) => name === spectatePlayer.Name);
	if (playerIndex >= 0) {
		playerIndex--;
		if (playerIndex < 0) playerIndex = playerList.size() - 1;
		
		spectatePlayer.Value = playerList[playerIndex];
	}
});

(menuButtons.WaitForChild('Tutorial') as TextButton).MouseButton1Click.Connect(() => {
	if (player.GetAttribute(PlayerAttributes.InErrorLand)) return;
	
	menuOpen.Value = false;
	tutorialConfirmation.Visible = true;
});

(tutorialConfirmation.WaitForChild('No') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	tutorialConfirmation.Visible = false;
});

(tutorialConfirmation.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
	Events.StartClientTutorial.Fire();
	
	menuOpen.Value = false;
	tutorialConfirmation.Visible = false;
});

(menuButtons.WaitForChild('ColorChanger') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	colorChanger.Visible = true;
});

(colorChanger.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	colorChanger.Visible = false;
});

(menuButtons.WaitForChild('Credits') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	credits.Visible = true;
});

(credits.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	credits.Visible = false;
});

(settingsGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	settingsGui.Visible = false;
});

(menuButtons.WaitForChild('Quest') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	questGui.Visible = true;
});

(questGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	questGui.Visible = false;
});

(menuButtons.WaitForChild('Leaderboard') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	leaderboardGui.Visible = true;
});

(leaderboardGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	leaderboardGui.Visible = false;
});

(menuButtons.WaitForChild('Changelog') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	changelogsGui.Visible = true;
});

(changelogsGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	changelogsGui.Visible = false;
});

(menuButtons.WaitForChild('Stats') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	statsGui.Visible = true;
});

(statsGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	statsGui.Visible = false;
});

(menuButtons.WaitForChild('Replays') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = false;
	replaysGui.Visible = true;
});

(replaysGui.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
	menuOpen.Value = true;
	replaysGui.Visible = false;
});

Events.SettingChanged.Event.Connect(updateSettingButtons);

function changePlaceVersion() {
	const value = (ReplicatedStorage.FindFirstChild('PlaceVersion') as IntValue).Value;
	
	let text = tostring(value);
	if (value === -1) text = 'DEV';
	else if (value === -2) text = 'TESTING';
	
	placeVersion.Text = `block and hammer - v${value}`;
}

changePlaceVersion();
(ReplicatedStorage.WaitForChild('PlaceVersion') as IntValue).Changed.Connect(changePlaceVersion);