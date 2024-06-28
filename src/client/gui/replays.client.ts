import { $print, $warn } from 'rbxts-transform-debug';
$warn('Replays are not enabled yet');

// import {
//     CollectionService,
//     ReplicatedStorage,
//     UserInputService,
//     UserService,
//     RunService,
//     Workspace,
//     Players,
//     Debris,
// } from '@rbxts/services'

// import {
// 	convertStudsToMeters,
// 	roundDecimalPlaces,
// 	computeNameColor,
// 	PlayerAttributes,
// 	getPartFromId,
// 	compressData,
// 	getTimeUnits,
// 	formatBytes,
// 	GameSetting,
// 	randomFloat,
// 	getSetting,
// 	playSound,
// } from 'shared/utils';

// import {
// 	reloadAccessories,
// 	loadAccessories,
// } from 'shared/accessory_loader';

// import ReplayModule from 'shared/replays';

// const Events = {
// 	'GetPlayerReplays': ReplicatedStorage.WaitForChild('GetPlayerReplays') as RemoteFunction,
// 	'DeleteReplay': ReplicatedStorage.WaitForChild('DeleteReplay') as RemoteFunction,
// 	'RequestReplay': ReplicatedStorage.WaitForChild('RequestReplay') as RemoteFunction,
// 	'UploadReplay': ReplicatedStorage.WaitForChild('UploadReplay') as RemoteFunction,

// 	'ClientCreateDebris': ReplicatedStorage.WaitForChild('ClientCreateDebris') as BindableEvent,
// 	'MakeReplayEvent': ReplicatedStorage.WaitForChild('MakeReplayEvent') as BindableEvent,
// 	'ClientReset': ReplicatedStorage.WaitForChild('ClientReset') as BindableEvent,
// 	'ShatterPart': ReplicatedStorage.WaitForChild('ShatterPart') as BindableEvent,
// 	'BreakPart': ReplicatedStorage.WaitForChild('BreakPart') as BindableEvent,
// };

// const player = Players.LocalPlayer;
// const camera = Workspace.CurrentCamera ?? Workspace.WaitForChild('Camera') as Camera;
// const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

// const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
// const replayItemTemplate = guiTemplates.WaitForChild('ReplayItem') as Frame;
// const cubeTemplate = ReplicatedStorage.WaitForChild('Cube') as BasePart;
// const sparkParticle = ReplicatedStorage.WaitForChild('Particles').WaitForChild('spark') as BasePart;
// const mouseVisual = Workspace.WaitForChild('MouseVisual') as BasePart;
// const effectsFolder = Workspace.WaitForChild('Effects') as Folder;
// const windSFX = ReplicatedStorage.WaitForChild('SFX').WaitForChild('wind') as Sound;
// const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
// const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
// const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
// const viewGui = GUI.WaitForChild('ReplayGui') as ScreenGui;
// const replayGui = screenGui.WaitForChild('ReplaysGUI') as Frame;
// const container = replayGui.WaitForChild('Container') as Frame;
// const replayText = viewGui.WaitForChild('ReplayText') as TextLabel;
// const startRecordingButton = container.WaitForChild('StartRecording') as TextButton;
// const stopRecordingButton = container.WaitForChild('StopRecording') as TextButton;
// const uploadConfirmation = screenGui.WaitForChild('ReplayUploadConfirmation') as Frame;
// const descriptionLabel = uploadConfirmation.WaitForChild('DescriptionLabel') as TextLabel;
// const replayUploading = screenGui.WaitForChild('ReplayUploading') as Frame;
// const replayUploadingDescription = replayUploading.WaitForChild('DescriptionLabel') as TextLabel;
// const replayRequesting = screenGui.WaitForChild('ReplayRequesting') as Frame;
// const replayView = screenGui.WaitForChild('ReplayViewGUI') as Frame;
// const replayViewKey = replayView.WaitForChild('Key') as TextBox;
// const replayViewStatus = replayView.WaitForChild('StatusText') as TextLabel;
// const replayDelete = screenGui.WaitForChild('ReplayDelete') as Frame;
// const replayDeleteContainer = replayDelete.WaitForChild('Container') as Frame;
// const replayDeleting = screenGui.WaitForChild('ReplayDeleting') as Frame;
// const replayList = screenGui.WaitForChild('ReplayListGUI') as Frame;
// const replayListItems = replayList.WaitForChild('Items') as ScrollingFrame;
// const recordingIndicator = screenGui.WaitForChild('RecordingIndicator') as Frame;
// const playbackControls = viewGui.WaitForChild('PlaybackControls').WaitForChild('Controls') as Frame;
// const durationBar = viewGui.WaitForChild('PlaybackControls').WaitForChild('Duration') as Frame;
// const timeLabel = viewGui.WaitForChild('PlaybackControls').WaitForChild('Time') as TextLabel;
// const playbackSpeedInput = playbackControls.WaitForChild('PlaybackSpeed') as TextBox;
// const pauseButton = playbackControls.WaitForChild('Pause') as TextButton;
// const rewindButton = playbackControls.WaitForChild('Rewind') as TextButton;
// const forwardButton = playbackControls.WaitForChild('Forward') as TextButton;
// const rewindLong = playbackControls.WaitForChild('RewindLong') as TextButton;
// const forwardLong = playbackControls.WaitForChild('ForwardLong') as TextButton;
// const durationProgress = durationBar.WaitForChild('Progress') as Frame;
// const durationInput = durationBar.WaitForChild('Input') as TextButton;
// const exitButton = playbackControls.WaitForChild('Exit') as TextButton;
// const timerDisplay = viewGui.WaitForChild('Timer') as TextLabel;

// const Recorder = new ReplayModule();

// let finishDraggingDuration = false;
// let isDraggingDuration = false;
// let deletingReplayId = undefined as (string | undefined);
// let compressedData = undefined as (string | undefined);

// let instantCamera = false;
// let playbackSpeed = 0;
// let updateEvent = undefined as (RBXScriptConnection | undefined);
// let currentTime = 0;
// let isPlaying = false;

// replayGui.GetPropertyChangedSignal('Visible').Connect(() => {
//     if (replayGui.Visible && (player.GetAttribute(PlayerAttributes.InErrorLand) || player.GetAttribute(PlayerAttributes.InTutorial))) {
//         replayGui.Visible = false;
//         canMove.Value = true;
//     }
// });

// function formatUnixTimestamp(milliseconds: number) {
// 	const dateTable = os.date('*t', milliseconds / 1000);
// 	const months = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];

// 	const formattedDate = string.format('%s %d %d %02d:%02d:%02d', months[dateTable.month], dateTable.day, dateTable.year, dateTable.hour, dateTable.min, dateTable.sec);
// 	return formattedDate;
// }

// function startRecording() {
//     if (player.GetAttribute(PlayerAttributes.InErrorLand)) return;

// 	recordingIndicator.Visible = true;
// 	startRecordingButton.BackgroundTransparency = 0.5;
// 	startRecordingButton.TextColor3 = Color3.fromRGB(175, 175, 175);
// 	startRecordingButton.AutoButtonColor = false;
// 	startRecordingButton.SetAttribute('disabled', true);
// 	stopRecordingButton.BackgroundTransparency = 0.6;
// 	stopRecordingButton.TextColor3 = Color3.fromRGB(255, 255, 255);
// 	stopRecordingButton.AutoButtonColor = true;
// 	stopRecordingButton.SetAttribute('disabled', undefined);

//     Recorder.startRecording();

// 	replayGui.Visible = false;
// 	canMove.Value = true;
// }

// function stopRecording() {
//     if (!Recorder.isRecording) return;

// 	recordingIndicator.Visible = false
// 	startRecordingButton.BackgroundTransparency = 0.6
// 	startRecordingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
// 	startRecordingButton.SetAttribute('disabled', undefined)
// 	startRecordingButton.AutoButtonColor = true
// 	stopRecordingButton.BackgroundTransparency = 0.5
// 	stopRecordingButton.TextColor3 = Color3.fromRGB(175, 175, 175)
// 	stopRecordingButton.AutoButtonColor = false
// 	stopRecordingButton.SetAttribute('disabled', true)

// 	print(Recorder.recordingData);
// 	const totalTime = Recorder.stopRecording();
// 	compressedData = compressData(Recorder.recordingData, false);

// 	const [ , minutes, seconds, milliseconds ] = getTimeUnits(totalTime);

// 	const info = [
// 		`length: ${string.format('%02d:%02d.%03d', minutes, seconds, milliseconds)}/10:00.000`,
// 		`frames: ${Recorder.recordingData.size() - 1}`,
// 		`size: ${formatBytes(compressedData.size())}`,
// 		`fps: 60`
//     ];

// 	descriptionLabel.Text = info.join('\n');
// 	uploadConfirmation.Visible = true;

//     Recorder.recordingData.clear();

// 	canMove.Value = false;
// 	replayGui.Visible = false;
// }

// function viewReplay(userId: number, frames: string[]) {
// 	screenGui.Enabled = false;
// 	viewGui.Enabled = true;
// 	canMove.Value = false;

// 	currentTime = 0;
// 	isPlaying = true;
// 	playbackSpeed = 1;

// 	playbackSpeedInput.Text = '1.00x';
// 	playbackSpeedInput.PlaceholderText = '1.00x';

// 	const metadataEvents = frames[0].split(':');
// 	const metadata = metadataEvents[0].split(',');

// 	const cubeMetadata = (metadataEvents[1] || ',,,,').split(',');
// 	const cubeHexColor = cubeMetadata[4];

// 	let cubeColor: Color3 | undefined = undefined;
// 	try {
// 		cubeColor = Color3.fromHex(cubeHexColor);
// 	} catch (err) {  }

// 	const timerStartTime = tonumber(metadata[3]) ?? 0;

// 	const millisecondsDuration = tonumber(metadata[1]) ?? 0;
// 	const secondsDuration = millisecondsDuration / 1000;

//     const [ , minutes, seconds, milliseconds ] = getTimeUnits(millisecondsDuration);
// 	const totalTime = string.format('%02d:%02d.%03d', minutes, seconds, milliseconds);

// 	timeLabel.Text = `00:00.000/${totalTime}`;

// 	const replayCube = cubeTemplate.Clone();
//     const replayCubeHead = replayCube.WaitForChild('Head') as BasePart;
//     const replayCubeOverheadGUI = replayCube.WaitForChild('OverheadGUI') as BillboardGui;
//     const replayCubeUsername = replayCubeOverheadGUI.WaitForChild('Username') as TextLabel;

// 	replayCube.Name = 'REPLAY_VIEW';
// 	replayCube.Anchored = true;
//     replayCubeHead.Anchored = true;
// 	replayCube.SetAttribute('isCube', undefined);
// 	replayCube.Parent = Workspace;

//     if (typeIs(cubeColor, 'Color3')) {
//         replayCube.Color = cubeColor;
//         reloadAccessories(replayCube, cubeColor, cubeMetadata[0], cubeMetadata[2], cubeMetadata[3]);
//     }

// 	loadAccessories(replayCube, {
//         'hat': cubeMetadata[0],
//         'face': cubeMetadata[1],
//         'aura': cubeMetadata[2],
//         'hammer': cubeMetadata[3],
//     }, undefined, undefined);

// 	let previousFrameIndex = 2;

//     task.spawn(() => {
//         replayText.Text = 'watching: ?';

//         let userInfo: UserInfo | undefined = undefined;
//         let existingPlayer = Players.GetPlayerByUserId(userId);
//         if (existingPlayer) {
//             userInfo = { DisplayName: existingPlayer.DisplayName, Username: existingPlayer.Name, Id: userId };
//         } else {
// 			try {
// 				userInfo = UserService.GetUserInfosByUserIdsAsync([ userId ])[0];
// 			} catch (err) {  }
//         }

// 		if (userInfo) {
// 			replayText.Text = `watching: ${userInfo.DisplayName} (@${userInfo.Username})`
// 			replayCubeUsername.Text = `${userInfo.DisplayName} (@${userInfo.Username})`

// 			if (!cubeColor) {
// 				const cubeColor = computeNameColor(userInfo.Username);
// 				replayCube.Color = cubeColor;

// 				reloadAccessories(replayCube, cubeColor, cubeMetadata[0], cubeMetadata[1], cubeMetadata[2]);
// 			}
// 		}
//     });

// 	let effectedParts = [  ] as BasePart[];
// 	let winFrameIndex = -1;
// 	let totalWinTime = -1;

//     for (const frame of frames) {
// 		const events = frame.split(':');
// 		const [ frameType, secondsTime ] = events[0].split(',');

// 		if (events.size() > 1) {
//             for (const [ j, dataString ] of pairs(events)) {
//                 if (j === 1) continue;

// 				const data = dataString.split(',');
// 				const eventName = data[0];
// 				if (eventName === 'win') {
// 					totalWinTime = tonumber(data[1]) ?? 0;
// 					winFrameIndex = j;
// 				}
// 			}
// 		}
// 	}

// 	updateEvent = RunService.RenderStepped.Connect((dt) => {
// 		let mouse = UserInputService.GetMouseLocation();

// 		if (isPlaying) {
// 			currentTime += dt * playbackSpeed;
// 			if (currentTime > secondsDuration) {
// 				currentTime = secondsDuration;
// 				isPlaying = false;
// 				pauseButton.Text = '►';
// 			}
// 		}

// 		if (isDraggingDuration) {
// 			if (finishDraggingDuration) {
// 				isDraggingDuration = false;
// 				finishDraggingDuration = false;
// 				isPlaying = true;
// 				pauseButton.Text = '||';
//             } else {
// 				let percent = math.clamp((mouse.X - durationBar.AbsolutePosition.X) / durationBar.AbsoluteSize.X, 0, 1);
// 				currentTime = secondsDuration * percent;
// 				isPlaying = false;
// 				pauseButton.Text = '►';
// 			}
// 		}

// 		let currentFrame = undefined as (string | undefined);
// 		let currentFrameIndex = undefined as (number | undefined);
//         for (const [ i, frame ] of pairs(frames)) {
// 			const [ frameType, secondsTime ] = frame.split(':')[0].split(',');
// 			if ((frameType === '1' || frameType === '2') && ((tonumber(secondsTime) ?? 0) / 1000) > currentTime) {
// 				currentFrame = frames[i - 1];
// 				if (tonumber(currentFrame.split(',')[0]) !== 1) currentFrame = frame;
// 				currentFrameIndex = i;

// 				break;
// 			}
// 		}

// 		durationProgress.Size = UDim2.fromScale(currentTime / secondsDuration, 1);
// 		timerDisplay.TextColor3 = Color3.fromRGB(255, 255, 255);

// 		let [ , minutes, seconds, milliseconds ] = getTimeUnits(timerStartTime + currentTime * 1000);
// 		if (winFrameIndex && totalWinTime && currentFrameIndex && currentFrameIndex >= winFrameIndex) {
// 			[ , minutes, seconds, milliseconds ] = getTimeUnits(totalWinTime);
// 			timerDisplay.TextColor3 = Color3.fromRGB(255, 255, 128);
// 		}

// 		timerDisplay.Text = string.format('%02d:%02d.%d', minutes, seconds, math.floor(milliseconds / 100));

// 		if (currentFrame && currentFrameIndex) {
// 			if (isPlaying && previousFrameIndex < currentFrameIndex) {
//                 for (const i of $range(previousFrameIndex, currentFrameIndex)) {
// 					const otherFrame = frames[i - 1];

// 					const events = otherFrame.split(':');
// 					const [ frameType, secondsTime ] = events[0].split(',');

// 					if (events.size() > 1 && (tonumber(secondsTime) ?? 0) / 1000 > currentTime) {
//                         for (const [ i, dataString ] of pairs(events)) {
//                             if (i === 1) continue;

// 							const data = dataString.split(',');
// 							const eventName = data[0];
// 							if (eventName === 'sound') {
// 								let soundName = data[1];

// 								let properties: Record<string, any> = {  };
//                                 for (const i of $range(3, data.size())) {
//                                     const [ property, value ] = data[i - 1].split('=');
// 									const number = tonumber(value);
//                                     if (number !== undefined) properties[property] = number / 1000;
//                                     else properties[property] = value;
//                                 }

//                                 playSound(soundName, properties, true);
// 							} else if (eventName === 'spark') {
// 								let divider = 1000;
// 								if (data[0].find('%.')) divider = 1;

// 								const velocity = new Vector3(tonumber(data[4]), tonumber(data[5]), tonumber(data[6])).div(divider);
// 								const point = new Vector3(tonumber(data[1]), tonumber(data[2]), tonumber(data[3])).div(divider);

// 								playSound('hit1', { PlaybackSpeed: math.random(90, 100) / 100, Volume: velocity.Magnitude / 30 }, true);

// 								const spark = sparkParticle.Clone();
// 								spark.CFrame = CFrame.lookAlong(point, velocity.Unit.mul(-1));
// 								spark.Parent = effectsFolder;
// 								Debris.AddItem(spark, 5);

// 								const particleEmitter = spark.WaitForChild('ParticleEmitter') as ParticleEmitter;
// 								task.delay(0.1, () => particleEmitter.Enabled = false);
// 							} else if (eventName === 'destroy') {
// 								let divider = 1000;
// 								if (data[1].find('%.')) divider = 1;

// 								let position = new Vector3(tonumber(data[1]), tonumber(data[2]), tonumber(data[3])).div(divider);
// 								let velocity = new Vector3(tonumber(data[4]), tonumber(data[5]), tonumber(data[6])).div(divider);

// 								let otherPart = getPartFromId(data[7]);
// 								if (otherPart) Events.ClientCreateDebris.Fire(velocity, position, otherPart, 1, true, cubeMetadata[3]);
// 							} else if (eventName === 'explosion') {
// 								let position = new Vector3(tonumber(data[1]), tonumber(data[2]), tonumber(data[3])).div(1000);
// 								let volume = math.clamp((tonumber(data[4]) ?? 700) / 1000, 0, 2);

// 								playSound('explosion', { PlaybackSpeed: randomFloat(0.9, 1), Volume: volume }, true);

// 								let explosion = new Instance('Explosion');
// 								explosion.BlastRadius = 0;
// 								explosion.BlastPressure = 0;
// 								explosion.Position = position;
// 								explosion.Parent = effectsFolder;
// 							} else if (eventName === 'break') {
// 								let part = CollectionService.GetTagged(data[1])[0];
// 								if (part?.IsA('BasePart')) {
// 									part.CollisionGroup = 'collidableDebris';
// 									part.LocalTransparencyModifier = 0.75;

// 									Events.BreakPart.Fire(part, replayCubeHead, true);
// 									effectedParts.push(part);
// 								}

// 								playSound('hit2', { PlaybackSpeed: randomFloat(0.9, 1), Volume: 0.5 }, true);
// 							} else if (eventName === 'shatter') {
// 								const part = CollectionService.GetTagged(data[1])[0]
// 								if (part?.IsA('BasePart')) {
// 									part.CollisionGroup = 'collidableDebris';
// 									part.LocalTransparencyModifier = 0.75;

// 									Events.ShatterPart.Fire(part, replayCubeHead, true);
// 									effectedParts.push(part);
// 								}

// 								playSound('shatter', { PlaybackSpeed: randomFloat(0.9, 1) });
// 							} else if (eventName === 'respawn') {
// 								let part = CollectionService.GetTagged(data[1])[0];
// 								if (part?.IsA('BasePart')) {
// 									part.CollisionGroup = 'Map';
// 									part.LocalTransparencyModifier = 0;
// 									const i = effectedParts.findIndex((otherPart) => otherPart === part);
// 									if (i !== -1) effectedParts.remove(i);
// 								}
// 							}
// 						}
// 					}
// 				}
// 			}

// 			let events = currentFrame.split(':');
// 			let data = events[0].split(',');
// 			let [ frameType, , cubeX, cubeY, headAngle, headDistance, mouseX, mouseY, velocityX, velocityY ] = data;

// 			if (frameType === '2') {
// 				cubeX = '';
// 				cubeY = '';
// 				headAngle = '';
// 				headDistance = '';
// 				mouseX = data[16];
// 				mouseY = data[17];
// 				velocityX = '';
// 				velocityY = '';
// 			}

// 			let divider = 1000;
// 			if (cubeX.find('%.')[0]) divider = 1;

// 			const finalCubeX = (tonumber(cubeX) ?? 0) / divider;
// 			const finalCubeY = (tonumber(cubeY) ?? 0) / divider;
// 			const finalHeadAngle = (tonumber(headAngle) ?? 0) / divider;
// 			const finalHeadDistance = (tonumber(headDistance) ?? 0) / divider;
// 			const finalMouseX = (tonumber(mouseX) ?? 0) / divider;
// 			const finalMouseY = (tonumber(mouseY) ?? 0) / divider;
// 			const finalVelocityX = (tonumber(velocityX) ?? 0) / divider;
// 			const finalVelocityY = (tonumber(velocityY) ?? 0) / divider;

// 			let headPositionX = finalCubeX + math.cos(math.rad(finalHeadAngle)) * finalHeadDistance;
// 			let headPositionY = finalCubeY + math.sin(math.rad(finalHeadAngle)) * finalHeadDistance;
// 			let headCFrame = CFrame.lookAt(new Vector3(headPositionX, headPositionY, 0), replayCube.Position).mul(CFrame.fromOrientation(math.pi, 0, 0));

// 			let cubeVelocity = new Vector3(finalVelocityX, finalVelocityY, 0);
// 			let cubeCFrame = new CFrame(finalCubeX, finalCubeY, 0);

// 			if (frameType === '2') {
// 				const cubeRotationX = tonumber(data[5]) ?? 0;
// 				const cubeRotationY = tonumber(data[6]) ?? 0;
// 				const cubeRotationZ = tonumber(data[7]) ?? 0;
// 				const headRotationX = tonumber(data[12]) ?? 0;
// 				const headRotationY = tonumber(data[13]) ?? 0;
// 				const headRotationZ = tonumber(data[14]) ?? 0;

// 				let cubeRotation = CFrame.fromOrientation(math.rad(cubeRotationX / divider), math.rad(cubeRotationY / divider), math.rad(cubeRotationZ / divider));
// 				let headRotation = CFrame.fromOrientation(math.rad(headRotationX / divider), math.rad(headRotationY / divider), math.rad(headRotationZ / divider));

// 				cubeCFrame = new CFrame((tonumber(data[2]) ?? 0) / divider, (tonumber(data[3]) ?? 0) / divider, 0).mul(cubeRotation);
// 				headCFrame = new CFrame((tonumber(data[9]) ?? 0) / divider, (tonumber(data[9]) ?? 0) / divider, 0).mul(headRotation);
// 			}

// 			const alpha = math.min(dt * 27.5, 1);
// 			replayCube.CFrame = replayCube.CFrame.Lerp(cubeCFrame, alpha);
// 			replayCubeHead.CFrame = replayCubeHead.CFrame.Lerp(headCFrame, alpha);

// 			mouseVisual.Position = new Vector3(finalMouseX, finalMouseY, 0);

// 			let zoom = 37.5;
//             if (cubeMetadata[3] === 'Long Hammer') zoom = 70;
//             else if (cubeMetadata[3] === 'Grappling Hammer') zoom = 50;
//             else if (cubeMetadata[3] === 'Explosive Hammer') zoom = 65;

// 			let cameraCFrame = CFrame.lookAt(replayCube.Position.sub(new Vector3(0, 0, zoom)), replayCube.Position, Vector3.yAxis);
// 			if (instantCamera) {
// 				instantCamera = false;
// 				camera.CFrame = cameraCFrame;
// 			} else {
// 				if (camera.CFrame.Position.sub(cameraCFrame.Position).Magnitude > 50) camera.CFrame = camera.CFrame.Lerp(cameraCFrame, 0.5);
// 				else camera.CFrame = camera.CFrame.Lerp(cameraCFrame, math.clamp(dt * 15, 0, 1));
// 			}

//             const [ , minutes, seconds, milliseconds ] = getTimeUnits(currentTime * 1000);
//             const [ , altitudeLabel ] = convertStudsToMeters(cubeCFrame.Y - 1.9);
//             const [ , speedLabel ] = convertStudsToMeters(cubeVelocity.Magnitude);

// 			(viewGui.FindFirstChild('Altitude') as TextLabel).Text = altitudeLabel;
// 			(viewGui.FindFirstChild('Speedometer') as TextLabel).Text = speedLabel;
// 			timeLabel.Text = `${string.format('%02d:%02d.%03d', minutes, seconds, milliseconds)}/${totalTime}`;

// 			replayCube.AssemblyLinearVelocity = cubeVelocity;

// 			camera.FieldOfView = 70 + math.max(cubeVelocity.Magnitude - 100, 0) / 5;

// 			let percent = getSetting(GameSetting.Sounds) ? math.max((cubeVelocity.Magnitude - 100) / 300, 0) : 0;

// 			windSFX.Volume = percent * 3;
// 			previousFrameIndex = currentFrameIndex;
// 		}
// 	});

// 	exitButton.MouseButton1Click.Wait();

// 	replayCube.Destroy();
// 	updateEvent.Disconnect();
// 	screenGui.Enabled = true;
// 	viewGui.Enabled = false;

//     for (const part of effectedParts) {
//         if (part.IsA('BasePart')) {
//             part.LocalTransparencyModifier = 0;
//             part.CollisionGroup = 'Map';
//         }
//     }
// }

// function loadReplayList() {
// 	const replayData = Events.GetPlayerReplays.InvokeServer() as ([ string, number, number, number, string[], number, string ][] | -1);
// 	if (replayData === -1) return;

// 	for (const [ , data ] of pairs(replayData)) {
// 		let [ id, userId, chunks, size, frames, dateCreated, key ] = data;

// 		const metadataEvents = frames[0].split(':');
// 		const metadata = metadataEvents[0].split(',');

// 		const [ , minutes, seconds, milliseconds ] = getTimeUnits(tonumber(metadata[1]) ?? 0);

// 		const item = replayItemTemplate.Clone();

// 		const right = item.FindFirstChild('Right') as Frame;
// 		const left = item.FindFirstChild('Left') as Frame;
// 		(left.WaitForChild('Id').WaitForChild('Id') as TextBox).Text = id;
// 		(left.WaitForChild('Key').WaitForChild('Key') as TextBox).Text = '*******';
// 		(left.WaitForChild('Chunks') as TextLabel).Text = `chunks: ${chunks}`;
// 		(left.WaitForChild('Length') as TextLabel).Text = `length: ${string.format('%02d:%02d.%03d', minutes, seconds, milliseconds)}`;
// 		(left.WaitForChild('RSize') as TextLabel).Text = `size: ${formatBytes(size)}`;
// 		(left.WaitForChild('FPS') as TextLabel).Text = `fps: ${tonumber(metadata[2]) ?? 60}`;
// 		(left.WaitForChild('Date') as TextLabel).Text = `date: ${formatUnixTimestamp(dateCreated)}`;
// 		item.Parent = replayListItems;

// 		if (!key) {
// 			key = 'no key found was found, this was probably created before keys were added';
// 			(left.WaitForChild('Key').WaitForChild('Key') as TextBox).Text = key;
// 		}

// 		(right.WaitForChild('View') as TextButton).MouseButton1Click.Connect(() => viewReplay(userId, frames));

// 		(right.WaitForChild('Key') as TextButton).MouseButton1Click.Connect(() => {
// 			(left.WaitForChild('Key').WaitForChild('Key') as TextBox).Text = key;
// 		});

// 		(right.WaitForChild('Delete') as TextButton).MouseButton1Click.Connect(() => {
// 			for (const display of replayDeleteContainer.GetChildren()) {
// 				if (display.IsA('Frame')) display.Destroy();
// 			}

// 			deletingReplayId = id;

// 			const display = item.Clone();
// 			display.WaitForChild('Right').Destroy();
// 			display.Size = UDim2.fromScale(1, 1);
// 			display.Parent = replayDeleteContainer;

// 			replayList.Visible = false;
// 			replayDelete.Visible = true;
// 		});
// 	}
// }

// startRecordingButton.MouseButton1Click.Connect(startRecording);
// stopRecordingButton.MouseButton1Click.Connect(stopRecording);

// Recorder.forceStopRecording = stopRecording;

// (uploadConfirmation.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
// 	if (!compressedData) return;

// 	uploadConfirmation.Visible = false;
// 	replayUploading.Visible = true;

// 	replayUploadingDescription.Text = 'starting upload...';
// 	task.wait(0.1);

// 	Events.UploadReplay.InvokeServer(0);

// 	let chunkSize = 3000;

// 	let totalChunks = compressedData.size();
// 	let chunkNumber = 1;

// 	for (const i of $range(1, compressedData?.size(), chunkSize)) {
// 		const j = i + chunkSize - 1;
// 		const chunk = compressedData?.sub(i, j);

// 		replayUploadingDescription.Text = `sending chunk ${chunkNumber}/${totalChunks} to server`;
// 		Events.UploadReplay.InvokeServer(1, chunk);

// 		chunkNumber += 1;
// 	}

// 	replayUploadingDescription.Text = 'waiting for server to save data...';
// 	task.wait(0.1);

// 	Events.UploadReplay.InvokeServer(2);

// 	compressedData = undefined;

// 	replayUploading.Visible = false;
// 	replayGui.Visible = true;
// });

// (uploadConfirmation.WaitForChild('No') as TextButton).MouseButton1Click.Connect(() => {
// 	if (!compressedData) return;

// 	$print(`Deleting ${compressedData.size()} characters of replay data`)

// 	compressedData = undefined

// 	uploadConfirmation.Visible = false
// 	replayGui.Visible = true
// });

// (container.WaitForChild('ViewReplay') as TextButton).MouseButton1Click.Connect(() => {
// 	replayGui.Visible = false;
// 	replayViewStatus.Text = '';
// 	replayView.Visible = true;
// });

// (replayView.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
// 	replayView.Visible = false;
// 	replayGui.Visible = true;
// });

// (replayView.WaitForChild('View') as TextButton).MouseButton1Click.Connect(() => {
// 	replayView.Visible = false;
// 	replayRequesting.Visible = true;

// 	const [ data, message ] = Events.RequestReplay.InvokeServer(replayViewKey.ContentText) as [ [ number, string[] ] | undefined, string ];
// 	if (!data) {
// 		replayRequesting.Visible = false;
// 		replayViewStatus.Text = message ?? 'no message from server';
// 		replayView.Visible = true;
// 		return;
// 	}

// 	replayRequesting.Visible = false;
// 	replayView.Visible = true;

// 	const userId = data[0];
// 	const replayData = data[1];
// 	viewReplay(userId, replayData);
// });

// replayList.GetPropertyChangedSignal('Visible').Connect(() => {
// 	for (const replayItem of replayListItems.GetChildren()) {
// 		if (replayItem.IsA('Frame')) replayItem.Destroy();
// 	}
// });

// (container.WaitForChild('MyReplays') as TextButton).MouseButton1Click.Connect(() => {
// 	replayGui.Visible = false;
// 	replayList.Visible = true;

// 	loadReplayList();
// });

// (replayList.WaitForChild('Close') as TextButton).MouseButton1Click.Connect(() => {
// 	replayGui.Visible = true;
// 	replayList.Visible = false;
// });

// (replayDelete.WaitForChild('No') as TextButton).MouseButton1Click.Connect(() => {
// 	replayDelete.Visible = false;
// 	replayList.Visible = true;
// });

// (replayDelete.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
// 	if (!deletingReplayId) return;

// 	replayDelete.Visible = false;
// 	replayDeleting.Visible = true;

// 	Events.DeleteReplay.InvokeServer(deletingReplayId);
// 	deletingReplayId = undefined;

// 	replayDeleting.Visible = false;
// 	replayList.Visible = true;

// 	loadReplayList();
// });

// pauseButton.MouseButton1Click.Connect(() => {
// 	isPlaying = !isPlaying;
// 	pauseButton.Text = isPlaying ? '||' : '►';
// });

// rewindButton.MouseButton1Click.Connect(() => {
// 	currentTime = math.max(currentTime - 5, 0);
// 	instantCamera = true;
// });

// forwardButton.MouseButton1Click.Connect(() => {
// 	currentTime += 5;
// 	instantCamera = true;
// });

// rewindLong.MouseButton1Click.Connect(() => {
// 	currentTime = math.max(currentTime - 15, 0);
// 	instantCamera = true;
// });

// forwardLong.MouseButton1Click.Connect(() => {
// 	currentTime += 15;
// 	instantCamera = true;
// });

// playbackSpeedInput.FocusLost.Connect(() => {
// 	playbackSpeed = math.clamp(roundDecimalPlaces(tonumber(playbackSpeedInput.ContentText) || 1, 2), 0.01, 5);

// 	const text = string.format('%.2fx', playbackSpeed);
// 	playbackSpeedInput.Text = text;
// 	playbackSpeedInput.PlaceholderText = text;
// })

// durationInput.MouseButton1Down.Connect(() => {
// 	isDraggingDuration = true;
// });

// UserInputService.InputEnded.Connect((input) => {
// 	if (input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
// 		if (isDraggingDuration) finishDraggingDuration = true;
// 	}
// })

// Events.ClientReset.Event.Connect((fullReset: boolean) => {
// 	if (!Recorder.isRecording) return;

// 	if (fullReset) {
// 		const event = Workspace.ChildAdded.Connect((part) => {
// 			if (part.Name === `cube${player.UserId}` && part.GetAttribute('isCube')) {
// 				event.Disconnect();
// 				while (!part.GetAttribute('start_time')) part.AttributeChanged.Wait();
// 				Recorder.startRecording();
// 			}
// 		});
// 	} else {
// 		let cube = Workspace.WaitForChild(`cube${player.UserId}`);

// 		const event = cube.AttributeChanged.Connect((attr) => {
// 			if (attr === 'start_time') {
// 				event.Disconnect();
// 				Recorder.startRecording();
// 			}
// 		});
// 	}
// });

// Events.MakeReplayEvent.Event.Connect((dataString: string) => {
// 	if (!typeIs(dataString, 'string')) return;

// 	if (Recorder.isRecording) Recorder.newEvent(dataString);
// });

// while (task.wait(1 / 60)) {
// 	try {
// 		if (Recorder.isRecording) {
// 			const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
// 			Recorder.update(cube);
// 		}
// 	} catch (err) {
// 		$warn(err);
// 	}
// }
