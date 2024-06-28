import { ReplicatedStorage, UserInputService, TweenService, Workspace, Players } from '@rbxts/services';

import { PlayerAttributes, playSound } from 'shared/utils';

import { $dbg } from 'rbxts-transform-debug';

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? (Workspace.WaitForChild('Camera') as Camera);
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const mouseIcon = screenGui.WaitForChild('MouseIcon') as ImageLabel;
const interactablesFolder = Workspace.WaitForChild('Interactables') as Folder;

let wasInteracting = false;

function getMouseInteractable() {
	if (!screenGui.Enabled) return undefined;

	const mouse = UserInputService.GetMouseLocation();
	const ray = camera.ViewportPointToRay(mouse.X, mouse.Y);

	const params = new RaycastParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = [interactablesFolder];

	const result = Workspace.Raycast(ray.Origin, ray.Direction.Unit.mul(1024), params);
	return result;
}

UserInputService.InputChanged.Connect((input, processed) => {
	if (processed) return;

	if (input.UserInputType === Enum.UserInputType.MouseMovement) {
		const interactable = getMouseInteractable();
		if (interactable) {
			if (!wasInteracting) {
				wasInteracting = true;
				mouseIcon.Image = 'rbxassetid://13414586756';
				mouseIcon.AnchorPoint = new Vector2(0.5, 0.5);
				mouseIcon.Size = UDim2.fromScale(0.044, 1);
				mouseIcon.Visible = true;
			}
		} else {
			if (wasInteracting) {
				wasInteracting = false;
				mouseIcon.Visible = false;
			}
		}
	}
});

UserInputService.InputEnded.Connect((input, processed) => {
	if (processed) return;

	if (input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
		const interactable = getMouseInteractable();
		let part = interactable?.Instance;
		if (!part || !part.IsDescendantOf(interactablesFolder)) return;

		while (part.Parent !== interactablesFolder) part = part?.Parent as BasePart;

		const interactedEvent = part?.FindFirstChild('Interacted');
		if (interactedEvent?.IsA('RemoteEvent')) interactedEvent.FireServer();
	}
});

player.AttributeChanged.Connect((attr) => {
	if (attr === PlayerAttributes.HasSteelHammer) {
		const hasSteelHammer = player.GetAttribute(attr) as boolean;

		const steelHammer = interactablesFolder.FindFirstChild('SteelHammer');
		const arm = steelHammer?.FindFirstChild('Arm');
		const head = steelHammer?.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return;

		const transparency = hasSteelHammer ? 1 : 0;
		arm.Transparency = transparency;
		head.Transparency = transparency;
	} else if (attr === PlayerAttributes.GlowPhase) {
		const phase = player.GetAttribute(attr) as number;

		const glowPart = interactablesFolder.FindFirstChild('Glow');
		if (!glowPart?.IsA('BasePart')) return;

		playSound('magic', { Volume: 2 });

		let targetPosition = new Vector3(1598, 5, 5);
		if (phase === 1) targetPosition = new Vector3(335, 115, 5);
		else if (phase === 2) targetPosition = new Vector3(960, 605, 5);
		else if (phase === 3) targetPosition = new Vector3(495, 1060, 5);
		else if (phase === 4) targetPosition = new Vector3(442, 1515, 5);

		TweenService.Create(glowPart, new TweenInfo(20, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Position: targetPosition }).Play();
	}
});
