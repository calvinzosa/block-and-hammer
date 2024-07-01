import {
	ReplicatedStorage,
	RunService,
	Workspace,
} from '@rbxts/services';

import {
	randomFloat,
} from 'shared/utils';

const cloudTemplate = ReplicatedStorage.WaitForChild('Cloud') as BasePart;
const cloudsFolder = Workspace.WaitForChild('Clouds');

const clouds = [  ] as BasePart[];

for (const i of $range(1, 300)) {
	const cloud = cloudTemplate.Clone();
	cloud.Position = new Vector3(1800 - (i / 300) * 2650, 660 + randomFloat(-10, 45), randomFloat(-75, 75));
	cloud.Parent = cloudsFolder;
	
	clouds.push(cloud);
	task.wait();
}

RunService.Heartbeat.Connect((dt) => {
	const cloudOffset = new Vector3(dt * 2, 0, 0);
	for (const cloud of clouds) {
		const newPosition = cloud.Position.add(cloudOffset);
		
		if (newPosition.X > 1800) cloud.Position = new Vector3(-850, 660 + randomFloat(-10, 45), randomFloat(-75, 75));
		else cloud.Position = newPosition;
	}
});