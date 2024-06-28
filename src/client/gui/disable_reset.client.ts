import { StarterGui } from '@rbxts/services';

while (true) {
	try {
		StarterGui.SetCore('ResetButtonCallback', false);
		break;
	} catch (err) {}
}
