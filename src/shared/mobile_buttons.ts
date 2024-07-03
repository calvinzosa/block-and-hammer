import {
	ReplicatedStorage,
	UserInputService,
	Workspace,
	Players,
} from '@rbxts/services';
import { GameSetting, getSetting } from './utils';

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? Workspace.WaitForChild('Camera') as Camera;

const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const mobileButtons = GUI.WaitForChild('MobileButtons') as ScreenGui;
const deviceSafeInsets = GUI.WaitForChild('DeviceSafeInsets') as ScreenGui;
const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const buttonTemplate = guiTemplates.WaitForChild('MobileButton') as ImageButton;

const callbacks = [  ] as [ ImageButton, ((action: string, state: Enum.UserInputState, input: unknown) => void) ][];

let areButtonsVisible = false;
let buttonPadding = 5;

export function createMobileButton(title: string, category: string, position: Vector2, scale: number, action: string, callback: (action: string, state: Enum.UserInputState, input: unknown) => void) {
	const button = buttonTemplate.Clone();
	button.Visible = areButtonsVisible;
	button.SetAttribute('_position', position);
	button.SetAttribute('_scale', scale);
	button.SetAttribute('_action', action);
	button.SetAttribute('_category', category);
	
	const titleLabel = button.FindFirstChild('Title') as TextLabel;
	titleLabel.Text = title;
	
	button.Parent = mobileButtons;
	
	button.Destroying.Connect(() => {
		const i = callbacks.findIndex((data) => data[0] === button);
		if (i !== -1) callbacks.remove(i);
	});
	
	button.MouseButton1Down.Connect(() => {
		callback(action, Enum.UserInputState.Begin, {
			UserInputType: Enum.UserInputType.Touch,
			UserInputState: Enum.UserInputState.Begin,
			Delta: Vector3.zero,
			Position: Vector3.zero,
		});
		
		button.SetAttribute('_pressed', true);
		
		button.Image = 'rbxassetid://15904289666';
		
		titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0);
		titleLabel.TextTransparency = 0.5;
	});
	
	callbacks.push([ button, callback ]);
	
	updateDisplay();
	
	return button;
}

export function clearMobileButtons() {
	mobileButtons.ClearAllChildren();
}

export function update() {
	updateDisplay();
}

export function getMobileButtonsByCategory(category: string) {
	const buttons = [  ] as ImageButton[];
	for (const button of mobileButtons.GetChildren()) {
		if (button.IsA('ImageButton') && button.GetAttribute('_category') === category) buttons.push(button);
	}
	
	return buttons;
}

function updateInput() {
	const lastInput = UserInputService.GetLastInputType();
	if (lastInput === Enum.UserInputType.Focus) return;
	
	areButtonsVisible = lastInput === Enum.UserInputType.Touch;
	for (const button of mobileButtons.GetChildren()) {
		if (!button.IsA('ImageButton')) continue;
		
		button.Visible = areButtonsVisible;
	}
}

function updateDisplay() {
	const invertX = getSetting(GameSetting.InvertMobileButtons);
	
	for (const button of mobileButtons.GetChildren()) {
		if (!button.IsA('ImageButton')) continue;
		
		const position = button.GetAttribute('_position') as Vector2;
		const scale = button.GetAttribute('_scale') as number;
		
		const screenSize = deviceSafeInsets.AbsoluteSize;
		const minAxis = math.min(screenSize.X, screenSize.Y);
		const isSmallScreen = minAxis <= 500;
		const jumpButtonSize = math.round((isSmallScreen ? 70 : 120) * scale);
		
		const xOffset = (jumpButtonSize * 1.5 - 10) * -1 + jumpButtonSize * position.X + buttonPadding * position.X;
        const yOffset = (isSmallScreen ? (jumpButtonSize + 20) : (jumpButtonSize * 1.75)) * -1 + jumpButtonSize * position.Y + buttonPadding * position.Y;
		
		const titleLabel = button.FindFirstChild('Title') as TextLabel;
		const padding = titleLabel.FindFirstChild('UIPadding') as UIPadding;
		
		padding.PaddingTop = new UDim(0, 10 * scale);
		padding.PaddingBottom = new UDim(0, 10 * scale);
		padding.PaddingLeft = new UDim(0, 10 * scale);
		padding.PaddingRight = new UDim(0, 10 * scale);
		
		button.Size = new UDim2(0, jumpButtonSize, 0, jumpButtonSize);
		button.Position = new UDim2(invertX ? 0 : 1, xOffset * (invertX ? -1 : 1), 1, yOffset);
	}
}

updateInput();

UserInputService.InputEnded.Connect((input, processed) => {
	if (input.UserInputType === Enum.UserInputType.Touch) {
		for (const [ button, callback ] of callbacks) {
			if (button.GetAttribute('_pressed')) {
				callback(button.GetAttribute('_action') as string, Enum.UserInputState.End, {
					UserInputType: Enum.UserInputType.Touch,
					UserInputState: Enum.UserInputState.End,
					Delta: Vector3.zero,
					Position: Vector3.zero,
				});
				
				button.Image = 'rbxassetid://15904290429';
				
				const title = button.FindFirstChild('Title');
				if (title?.IsA('TextLabel')) {
					title.TextColor3 = Color3.fromRGB(255, 255, 255);
					title.TextTransparency = 0;
				}
				
				button.SetAttribute('pressed', undefined);
			}
		}
	}
});

UserInputService.LastInputTypeChanged.Connect(updateInput);
camera.GetPropertyChangedSignal('ViewportSize').Connect(updateDisplay);