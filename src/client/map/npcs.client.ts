import {
	ReplicatedStorage,
	UserInputService,
	ContentProvider,
	TweenService,
	Workspace,
	Players,
} from '@rbxts/services';

import { startsWith } from '@rbxts/string-utils';

import {
	randomFloat
} from 'shared/utils';

import dialog, { GameDialogChoice } from 'shared/dialog';
import { $warn } from 'rbxts-transform-debug';

const Events = {
	PickedDialogChoice: ReplicatedStorage.WaitForChild('PickedDialogChoice') as BindableEvent,
};

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? Workspace.WaitForChild('Camera') as Camera;

const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const choiceTemplate = guiTemplates.WaitForChild('ChoiceTemplate') as TextButton;
const npcsFolder = Workspace.WaitForChild('NPCs') as Folder;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
const screenGui = GUI.WaitForChild('ScreenGui');
const speedometerLabel = screenGui.WaitForChild('Speedometer') as TextLabel;
const altitudeLabel = screenGui.WaitForChild('Altitude') as TextLabel;
const dialogGUI = screenGui.WaitForChild('Dialog') as Frame;
const dialogContent = dialogGUI.WaitForChild('Content') as TextButton;
const dialogHeader = dialogContent.WaitForChild('HeaderLabel') as TextLabel;
const GameDialogChoices = dialogContent.WaitForChild('Choices') as Frame;
const dialogIcon = dialogContent.WaitForChild('Icon') as ImageLabel;
const dialogMessage = dialogContent.WaitForChild('Message') as TextLabel;
const mouseIcon = screenGui.WaitForChild('MouseIcon') as ImageLabel;

const Info = new TweenInfo(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);

let wasMouseIconVisible = false;
let targetChoice = '';
let inDialog = false;
let didSkip = false;

function getNpcAtMouse() {
	const mouse = UserInputService.GetMouseLocation();
	const ray = camera.ViewportPointToRay(mouse.X, mouse.Y);
	
	const params = new RaycastParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = [ npcsFolder ];
	
	const result = Workspace.Raycast(ray.Origin, ray.Direction.mul(1024), params);
	return result?.Instance;
}

function setMouseIcon(isVisible: boolean) {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart')) return;
	
	if (isVisible) {
		if (!wasMouseIconVisible) {
			wasMouseIconVisible = true;
			mouseIcon.AnchorPoint = new Vector2(0.9, 0.85);
			mouseIcon.Image = 'rbxassetid://13906010314';
			mouseIcon.Size = UDim2.fromScale(0.022, 1);
			mouseIcon.Visible = true;
		}
	} else {
		if (wasMouseIconVisible) {
			wasMouseIconVisible = false;
			mouseIcon.Visible = false;
		}
	}
}

task.spawn(() => {
	const ids = [  ];
	for (const [ , root ] of pairs(dialog)) {
		if (startsWith(root.talkSound, 'rbxassetid://')) ids.push(root.talkSound);
		if (startsWith(root.icon, 'rbxassetid://')) ids.push(root.icon);
	}
	
	ContentProvider.PreloadAsync(ids);
});

dialogContent.MouseButton1Click.Connect(() => didSkip = true);

UserInputService.InputBegan.Connect((input, processed) => {
	if (processed) return;
	
	if (input.KeyCode !== Enum.KeyCode.Unknown) {
		if (input.KeyCode === Enum.KeyCode.Space) didSkip = true;
	} else {
		if (input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
			didSkip = true;
			if (inDialog) return;
			
			const npc = getNpcAtMouse();
			if (npc && npc.Parent === npcsFolder && npc.Name in dialog) {
				const root = dialog[npc.Name];
				
				if (!npc.GetAttribute('default_lookAt')) npc.SetAttribute('default_lookAt', npc.Position.add(npc.CFrame.LookVector));
				
				inDialog = true
				canMove.Value = false;
				altitudeLabel.Visible = false;
				speedometerLabel.Visible = false;
				
				dialogHeader.Text = npc.Name;
				dialogIcon.Image = root.icon;
				dialogGUI.Visible = true;
				
				let messageData = root.dialog.default;
				for (const specialDialog of root.dialog.special) {
					let shouldUse = false;
					try {
						shouldUse = specialDialog.condition(player, npc);
					} catch (err) {
						shouldUse = false;
					}
					
					if (shouldUse) {
						messageData = specialDialog;
						break;
					}
				}
				
				const talkSound = new Instance('Sound');
				talkSound.SoundId = root.talkSound;
				talkSound.PlayOnRemove = true;
				
				const cube = Workspace.WaitForChild(`cube${player.UserId}`) as BasePart;
				
				while (inDialog) {
					didSkip = false;
					targetChoice = '';
					
					let targetLookAt: Vector3;
					const lookAt = messageData.faceTo;
					if (lookAt === '_player') targetLookAt = cube.Position;
					else if (lookAt === '_default') targetLookAt = npc.GetAttribute('default_lookAt') as Vector3;
					else targetLookAt = lookAt;
					
					TweenService.Create(npc, Info, { CFrame: CFrame.lookAt(npc.Position, targetLookAt ?? new Vector3(0, 0, 0)) }).Play();
					for (const button of GameDialogChoices.GetChildren()) {
						if (button.IsA('TextButton')) button.Destroy();
					}
					
					const text = messageData.message;
					dialogMessage.Text = text;
					for (const i of $range(1, dialogMessage.Text.size())) {
						dialogMessage.MaxVisibleGraphemes = i;
						if (didSkip) {
							const skipSound = talkSound.Clone();
							skipSound.PlaybackSpeed = 0.9;
							skipSound.Parent = Workspace;
							skipSound.Destroy();
							break
						} else {
							const character = text.sub(i, i);
							if (character !== ' ') {
								const newTalkSound = talkSound.Clone();
								newTalkSound.PlaybackSpeed = randomFloat(0.95, 1.05);
								newTalkSound.Parent = Workspace;
								newTalkSound.Destroy();
							}
						}
						
						task.wait(randomFloat(root.talkDelay[0], root.talkDelay[1]));
					}
					
					dialogMessage.MaxVisibleGraphemes = -1;
					
					const usableChoices = [  ] as [ string, GameDialogChoice ][];
					
					for (const [ text, choice ] of pairs(messageData.choices)) {
						if (typeIs(choice.condition, 'function')) {
							let isEnabled = false;
							try {
								isEnabled = choice.condition(player, npc);
							} catch (err) {
								isEnabled = false;
							}
							
							if (!isEnabled) continue;
						}
						
						usableChoices.push([ text, choice ]);
					}
					
					const width = 1 / (usableChoices.size() + (messageData.goodbyeEnabled ? 1 : 0));
					const events = [  ] as RBXScriptConnection[];
					
					let i = 0;
					for (const [ , data ] of pairs(usableChoices)) {
						const text = data[0];
						
						const button = choiceTemplate.Clone();
						button.Text = text;
						button.Size = UDim2.fromScale(width, 1);
						button.LayoutOrder = i;
						button.Name = text;
						button.Parent = GameDialogChoices;
						
						const event = button.MouseButton1Click.Once(() => {
							if (targetChoice.size() > 0) return;
							targetChoice = text;
							
							Events.PickedDialogChoice.Fire(targetChoice, npc);
						});
						
						events.push(event);
						
						i++;
					}
					
					if (messageData.goodbyeEnabled) {
						const button = choiceTemplate.Clone();
						button.Text = 'Goodbye!';
						button.Size = UDim2.fromScale(width, 1);
						button.LayoutOrder = 999999999;
						button.Parent = GameDialogChoices;
						
						const event = button.MouseButton1Click.Once(() => {
							if (targetChoice.size() > 0) return;
							targetChoice = '_goodbye';
							
							Events.PickedDialogChoice.Fire(targetChoice, npc);
						});
						
						events.push(event);
					}
					
					Events.PickedDialogChoice.Event.Wait();
					
					for (const event of events) event.Disconnect();
					
					if (typeIs(messageData.func, 'function')) {
						try {
							messageData.func(player, npc);
						} catch (err) {
							$warn(err);
						}
					}
					
					if (targetChoice === '_goodbye') {
						inDialog = false;
					} else {
						const new_message = messageData.choices[targetChoice];
						messageData = new_message;
					}
				}
				
				dialogGUI.Visible = false;
				
				TweenService.Create(npc, Info, { CFrame: CFrame.lookAt(npc.Position, npc.GetAttribute('default_lookAt') as Vector3) }).Play();
				
				canMove.Value = true;
				altitudeLabel.Visible = true;
				speedometerLabel.Visible = true;
			}
		}
	}
});

UserInputService.InputChanged.Connect((input, processed) => {
	if (processed) return;
	
	if (input.UserInputType === Enum.UserInputType.MouseMovement) {
		const npc = getNpcAtMouse();
		if (npc && !inDialog) setMouseIcon(true);
		else setMouseIcon(false);
	}
});