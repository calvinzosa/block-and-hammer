import { StarterGui } from '@rbxts/services';

while (true) {
	try {
		StarterGui.SetCore('ResetButtonCallback', false);
		break;
	} catch (err) {
		task.wait(0.1);
	}
}
