import {
	ReplicatedStorage,
	UserInputService,
	Workspace,
	Players,
} from '@rbxts/services';

import {
	getCubeTime,
	getTime,
} from './utils';

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? (Workspace.WaitForChild('Camera') as Camera);

const mouseVisual = Workspace.WaitForChild('MouseVisual') as BasePart;

export = class Replays {
	public isRecording = false;
	public forceStopRecording = undefined as (() => void) | undefined;
	public recordingData = [] as string[];
	private eventBuffer = [] as string[];
	private cubeData = [] as string[];
	private previousTime = -1;
	private startTime = undefined as number | undefined;
	private cubeStartTime = undefined as number | undefined;
	
	public startRecording() {
		this.recordingData.clear();
		this.eventBuffer.clear();
		
		const [ cubeTime ] = getCubeTime(Workspace.FindFirstChild(`cube${player.UserId}`));
		
		this.previousTime = -1;
		this.isRecording = true;
		this.startTime = undefined;
		this.cubeStartTime = cubeTime !== -1 ? math.round(cubeTime * 1000) : 0;
		this.cubeData = [
			(player.GetAttribute('cube_Hat') as string | undefined) ?? '',
			(player.GetAttribute('cube_Face') as string | undefined) ?? '',
			(player.GetAttribute('cube_Aura') as string | undefined) ?? '',
			(player.GetAttribute('hammer_Texture') as string | undefined) ?? '',
			'',
		];
		
		const color = player.GetAttribute('CUBE_COLOR');
		if (typeIs(color, 'Color3')) this.cubeData[4] = color.ToHex();
	}
	
	public stopRecording() {
		const currentTime = math.round(getTime() * 1000);
		const totalTime = currentTime - (this.startTime ?? 0);
		
		const cubeData = string.format('%s,%s,%s,%s,%s', ...this.cubeData);
		this.recordingData.insert(0, string.format('0,%d,%d,%d,%d:%s', totalTime, 60, this.cubeStartTime ?? 0, currentTime, cubeData));
		
		this.isRecording = false;
		return totalTime;
	}
	
	public newEvent(dataString: string) {
		this.eventBuffer.push(dataString);
	}
	
	public update(cube: Instance | undefined) {
		const head = cube?.FindFirstChild('Head');
		if (!cube?.IsA('BasePart') || !head?.IsA('BasePart')) return;
		
		if (!this.isRecording) return;
		
		let currentTime = math.round(getTime() * 1000);
		if (!this.startTime) this.startTime = currentTime;
		
		currentTime -= this.startTime;
		if (currentTime >= 600000 && this.forceStopRecording) {
			this.forceStopRecording();
			return;
		}
		
		if (this.previousTime === currentTime) return;
		
		this.previousTime = currentTime;
		
		const position = cube.Position;
		const velocity = cube.AssemblyLinearVelocity;
		const headAngle = math.deg(math.atan2(head.Position.Y - position.Y, head.Position.X - position.X));
		const headDistance = cube.Position.sub(head.Position).Magnitude;
		const multiplier = 1000;

		let dataString = string.format(
			'1,%d,%d,%d,%d,%d,%d,%d,%d,%d,',
			currentTime,
			math.round(position.X * multiplier),
			math.round(position.Y * multiplier),
			math.round(headAngle * multiplier),
			math.round(headDistance * multiplier),
			math.round(mouseVisual.Position.X * multiplier),
			math.round(mouseVisual.Position.Y * multiplier),
			math.round(velocity.X * multiplier),
			math.round(velocity.Y * multiplier),
		);

		const ragdollTime = (cube.GetAttribute('ragdollTime') as number | undefined) ?? 0;
		if (ragdollTime !== 0) {
			const [cubeRotationX, cubeRotationY, cubeRotationZ] = cube.CFrame.ToOrientation();
			const [headRotationX, headRotationY, headRotationZ] = head.CFrame.ToOrientation();

			dataString = string.format(
				'2,%d,%d,%d,,%d,%d,%d,%d,%d,,%d,%d,%d,%d,%d,%d,%d,',
				currentTime,
				math.round(position.X * multiplier),
				math.round(position.Y * multiplier),
				math.round(math.deg(cubeRotationX) * multiplier),
				math.round(math.deg(cubeRotationY) * multiplier),
				math.round(math.deg(cubeRotationZ) * multiplier),
				math.round(head.Position.X * multiplier),
				math.round(head.Position.Y * multiplier),
				math.round(math.deg(headRotationX) * multiplier),
				math.round(math.deg(headRotationY) * multiplier),
				math.round(math.deg(headRotationZ) * multiplier),
				math.round(mouseVisual.Position.X * multiplier),
				math.round(mouseVisual.Position.Y * multiplier),
				math.round(velocity.X * multiplier),
				math.round(velocity.Y * multiplier),
			);
		}

		if (this.eventBuffer.size() > 0) {
			dataString += ':' + this.eventBuffer.join(':');
			this.eventBuffer.clear();
		}

		this.recordingData.push(dataString);
	}
};