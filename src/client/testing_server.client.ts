import { ReplicatedStorage, Players } from '@rbxts/services';

import { isTestingServer, isMainServer, GameData } from 'shared/utils';

import { $print } from 'rbxts-transform-debug';

const player = Players.LocalPlayer;
const serverOwnerId = ReplicatedStorage.WaitForChild('PrivateServerOwnerId') as IntValue;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const mainMenuGui = GUI.WaitForChild('MainMenuGui') as ScreenGui;
const testingServerGui = GUI.WaitForChild('TestingServerGui') as ScreenGui;

if (serverOwnerId.Value === 0) serverOwnerId.Changed.Wait();

if (isMainServer()) {
	$print('Server Type: Main');

	if (GameData.CreatorIds.includes(serverOwnerId.Value)) {
		testingServerGui.Enabled = true;
		mainMenuGui.Enabled = false;
		screenGui.Enabled = false;
	}
} else if (isTestingServer()) {
	$print('Server Type: Testing');

	const button = screenGui.WaitForChild('TestingServerWarning') as TextButton;
	button.Visible = true;

	button.MouseButton1Click.Once(() => (button.Visible = false));
}
