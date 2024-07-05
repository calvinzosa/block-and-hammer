import {
	ReplicatedStorage,
	TweenService,
	Workspace,
	Players,
} from '@rbxts/services';

import {
	computeNameColor,
	getCurrentArea,
	isClientCube,
	tweenTypes,
	getTime,
} from 'shared/utils';

const Events = {
	PlayTutorial: ReplicatedStorage.WaitForChild('PlayTutorial') as RemoteEvent,
	EndTutorial: ReplicatedStorage.WaitForChild('EndTutorial') as RemoteEvent,

	StartClientTutorial: ReplicatedStorage.WaitForChild('StartClientTutorial') as BindableEvent,
};

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const flippedGravity = ReplicatedStorage.WaitForChild('flipped_gravity') as BoolValue;
const mapFolder = Workspace.WaitForChild('Map') as Folder;
const tutorialFolder = mapFolder.WaitForChild('Tutorial') as Folder;
const orb = tutorialFolder.WaitForChild('Orb') as BasePart;
const cubeTemplate = ReplicatedStorage.WaitForChild('Cube') as BasePart;
const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const tutorialGui = screenGui.WaitForChild('TutorialGUI') as Frame;
const shadow = screenGui.WaitForChild('Shadow') as Frame;

function start() {
	tutorialGui.Visible = false;
	canMove.Value = true;
	
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart')) return;
	
	const area = getCurrentArea(cube);
	if (area !== 'Tutorial') {
		flippedGravity.Value = false;
		
		Events.PlayTutorial.FireServer();
		player.SetAttribute('finished', undefined);
		
		shadow.BackgroundTransparency = 0;
		TweenService.Create(shadow, new TweenInfo(0.5, Enum.EasingStyle.Linear), { BackgroundTransparency: 1 }).Play();
	}
}

Events.StartClientTutorial.Event.Connect(start);
(tutorialGui.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(start);

orb.Touched.Connect((otherPart) => {
	if (isClientCube(otherPart)) {
		Events.EndTutorial.FireServer(true);
		otherPart.Destroy();
		
		shadow.BackgroundTransparency = 0;
		TweenService.Create(shadow, tweenTypes.linear.short, { BackgroundTransparency: 1 }).Play();
	}
});
