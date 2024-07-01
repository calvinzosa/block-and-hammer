import {
	ContextActionService,
	ReplicatedStorage,
	UserInputService,
	TextChatService,
	TweenService,
	RunService,
	StarterGui,
	Workspace,
	Players,
	GuiService,
} from '@rbxts/services';

import { $print, $warn } from 'rbxts-transform-debug';

import {
	roundDecimalPlaces,
	getHammerTexture,
	PlayerAttributes,
	convertStudsToMeters,
	getTimeUnits,
	isClientCube,
	GameSetting,
	Accessories,
	randomFloat,
	getCubeTime,
	getCubeHat,
	getSetting,
	tweenTypes,
	playSound,
	waitUntil,
	Settings,
	numLerp,
	getTime,
} from 'shared/utils';

import { createMobileButton, getMobileButtonsByCategory } from 'shared/mobile_buttons';

const Events = {
	BuildingHammerPlace: ReplicatedStorage.WaitForChild('BuildingHammerPlace') as RemoteEvent,
	SaySystemMessage: ReplicatedStorage.WaitForChild('SaySystemMessage') as RemoteEvent,
	AddRagdollCount: ReplicatedStorage.WaitForChild('AddRagdollCount') as RemoteEvent,
	ShowChatBubble: ReplicatedStorage.WaitForChild('ShowChatBubble') as RemoteEvent,
	CompleteGame: ReplicatedStorage.WaitForChild('CompleteGame') as RemoteEvent,
	FlipGravity: ReplicatedStorage.WaitForChild('FlipGravity') as RemoteEvent,
	
	StartClientTutorial: ReplicatedStorage.WaitForChild('StartClientTutorial') as BindableEvent,
	ClientCreateDebris: ReplicatedStorage.WaitForChild('ClientCreateDebris') as BindableEvent,
	MakeReplayEvent: ReplicatedStorage.WaitForChild('MakeReplayEvent') as BindableEvent,
	ClientMessage: ReplicatedStorage.WaitForChild('ClientMessage') as BindableEvent,
	ClientRagdoll: ReplicatedStorage.WaitForChild('ClientRagdoll') as BindableEvent,
	ClientReset: ReplicatedStorage.WaitForChild('ClientReset') as BindableEvent,
};

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? (Workspace.WaitForChild('Camera') as Camera);

const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const shakeIntensity = valueInstances.WaitForChild('shake_intensity') as NumberValue;
const isSpectating = valueInstances.WaitForChild('is_spectating') as BoolValue;
const spectatePlayer = isSpectating.WaitForChild('player') as StringValue;
const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
const isButtonHovered = valueInstances.WaitForChild('is_button_hovered') as BoolValue;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const mobileButtons = GUI.WaitForChild('MobileButtons') as ScreenGui;
const replayGui = GUI.WaitForChild('ReplayGui') as ScreenGui;
const mouseIcon = screenGui.WaitForChild('MouseIcon') as ImageLabel;
const debugInfo = screenGui.WaitForChild('DebugInfo') as Frame;
const timerLabel = screenGui.WaitForChild('Timer') as TextLabel;
const speedometerLabel = screenGui.WaitForChild('Speedometer') as TextLabel;
const altitudeLabel = screenGui.WaitForChild('Altitude') as TextLabel;
const nonBreakable = Workspace.WaitForChild('NonBreakable') as Folder;
const mapFolder = Workspace.WaitForChild('Map') as Folder;
const platformsFolder = mapFolder.WaitForChild('Platforms') as Folder;
const propellersFolder = mapFolder.WaitForChild('Propellers') as Folder;
const mudParts = mapFolder.WaitForChild('MudParts');
const effectsFolder = Workspace.WaitForChild('Effects') as BasePart;
const winArea = mapFolder.WaitForChild('WinArea') as BasePart;
const wallPlane = Workspace.WaitForChild('Wall') as BasePart;
const flippedGravity = ReplicatedStorage.WaitForChild('flipped_gravity') as BoolValue;
const mouseVisual = Workspace.WaitForChild('MouseVisual') as BasePart;
const modifierDisablers = Workspace.WaitForChild('ForceDisableModifiers') as BasePart;
const hitboxFolder = Workspace.WaitForChild('Hitboxes') as Folder;

const AbilityCooldowns = {
	ExplosiveHammer: false,
	Shotgun: false,
	InverterHammer: false,
	BuildingHammer: false,
};

const ActionNames = {
	BuildingHammer: {
		Place: 'building_hammer-place',
		Switch: 'building_hammer-switch',
	},
	GrapplingHammer: {
		Activate: 'grappling_hammer-activate',
		Scroll: 'grappling_hammer-scroll',
	},
	ExplosiveHammer: { Explode: 'explosive_hammer-explode' },
	Shotgun: { Fire: 'shotgun-fire' },
	InverterHammer: { Invert: 'inverter_hammer-invert' },
};

const AbilityObjects = {
	GrapplingHammerRope: undefined as Instance | undefined,
};

const AbilityVariables = {
	BuildingHammer: { BuildType: 0 },
};

const cachedPropellers: Model[] = [];
const cachedParticles: ParticleEmitter[] = [];

let cube: BasePart | undefined = undefined;
let wasModifiersEnabled = false;
let previousModifiersCheck = true;
let ragdollTime = 0;
let intensity = 0;

function newPropeller(propeller: Instance) {
	if (!propeller.IsA('Model')) return;
	
	const hitbox = propeller.WaitForChild('Hitbox');
	if (!hitbox || !typeIs(propeller.GetAttribute('windVelocity'), 'number')) {
		$warn('An invalid propeller was created.');
		return;
	}
	
	cachedPropellers.push(propeller);
}

function updatePropellers(cube: BasePart, head: BasePart, dt: number) {
	for (const [i, propeller] of pairs(cachedPropellers)) {
		const blades = propeller.FindFirstChild('Blades');
		if (!blades?.IsA('BasePart')) {
			$warn('A propeller has broke!');
			cachedPropellers.remove(i);
			break;
		}
		
		for (const descendant of propeller.GetDescendants()) {
			if (descendant.IsA('ParticleEmitter')) descendant.Enabled = blades.AssemblyAngularVelocity.Magnitude >= 5;
		}
	}
	
	const usedPropellers: Model[] = [];
	
	let totalCubeForce = Vector3.zero;
	let totalHeadForce = Vector3.zero;
	
	const params = new OverlapParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = cachedPropellers;
	
	for (const [i, part] of pairs([cube, cube.FindFirstChild('Head')])) {
		if (!part?.IsA('BasePart')) return;
		
		for (const touching of Workspace.GetPartsInPart(part, params)) {
			const propeller = touching.FindFirstAncestorWhichIsA('Model');
			if (!propeller || usedPropellers.findIndex((otherPropeller) => otherPropeller === propeller) >= 0 || propeller.GetAttribute('jammed')) continue;
			
			if (propeller.GetAttribute('noStack') && usedPropellers.size() !== 0) continue;
			
			const hitbox = propeller.FindFirstChild('Hitbox') as BasePart;
			const blades = propeller.FindFirstChild('Blades') as BasePart;
			if (blades.AssemblyAngularVelocity.Magnitude < 5) {
				propeller.SetAttribute('jammed', true);
				blades.Anchored = true;
				task.delay(5, () => {
					blades.Anchored = false;
					task.delay(0.5, () => propeller.SetAttribute('jammed', undefined));
				});
				
				continue;
			}
			
			const velocity = propeller.GetAttribute('windVelocity') as number;
			const result = hitbox.CFrame.RightVector.mul(velocity);
			
			if (i === 1) totalCubeForce = totalCubeForce.sub(result);
			else if (i === 2) totalHeadForce = totalHeadForce.sub(result);
			
			usedPropellers.push(propeller);
		}
	}
	
	const gravity = (Workspace.GetAttribute('default_gravity') as number | undefined) ?? 196.2;
	
	let cubeMultiplier = 0.1;
	let headMultiplier = 0.1;
	
	params.FilterDescendantsInstances = [mudParts];
	
	for (const [i, part] of pairs([cube, cube.FindFirstChild('Head')])) {
		if (part?.IsA('BasePart') && Workspace.GetPartsInPart(part, params).size() > 0) {
			if (i === 1) cubeMultiplier = 0.2;
			else headMultiplier = 0.2;
		}
	}
	
	cube.AssemblyLinearVelocity = cube.AssemblyLinearVelocity.add(totalCubeForce.mul(gravity).mul(dt * cubeMultiplier));
	head.AssemblyLinearVelocity = head.AssemblyLinearVelocity.add(totalHeadForce.mul(gravity).mul(dt * headMultiplier));
}

function updatePlatforms(cube: BasePart, head: BasePart) {
	for (const platform of platformsFolder.GetChildren()) {
		if (!platform.IsA('BasePart')) continue;
		
		const cubeCollision = (platform.FindFirstChild('CubeCollision') as NoCollisionConstraint | undefined) ?? new Instance('NoCollisionConstraint');
		cubeCollision.Name = 'CubeCollision';
		cubeCollision.Part0 = platform;
		cubeCollision.Part1 = cube;
		cubeCollision.Enabled = platform.Position.Y + platform.Size.Y / 2 > cube.Position.Y - cube.Size.Y / 2 + 0.25;
		cubeCollision.Parent = platform;
		
		const headCollision = (platform.FindFirstChild('HeadCollision') as NoCollisionConstraint | undefined) ?? new Instance('NoCollisionConstraint');
		headCollision.Name = 'HeadCollision';
		headCollision.Part0 = platform;
		headCollision.Part1 = head;
		headCollision.Enabled = platform.Position.Y + platform.Size.Y / 2 > head.Position.Y;
		headCollision.Parent = platform;
		
		platform.SetAttribute('notCollidable', headCollision.Enabled);
	}
}

function updateMud(cube: BasePart, head: BasePart, dt: number) {
	const slowdownFactor = math.clamp(1 - dt * 15, 0.01, 1);
	
	const params = new OverlapParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = [mudParts];
	
	for (const part of [cube, head]) {
		if (Workspace.GetPartsInPart(part, params).size() > 0) part.AssemblyLinearVelocity = part.AssemblyLinearVelocity.mul(slowdownFactor);
	}
}

function saySystemMessage(message: unknown, color: unknown, font: unknown, size: unknown) {
	if (!typeIs(message, 'string')) return;
	
	if (!typeIs(color, 'Color3')) color = Color3.fromRGB(255, 255, 255);
	if (!typeIs(font, 'EnumItem') || !font.IsA('Font')) font = Enum.Font.BuilderSans;
	if (!typeIs(size, 'number')) size = undefined;
	
	StarterGui.SetCore('ChatMakeSystemMessage', {
		Text: message,
		Color: color as Color3,
		Font: font as Enum.Font,
		TextSize: size as number,
	});
}

function formatDebugWorldNumber(num: number) {
	const [integer, decimal] = math.modf(math.abs(num));
	return string.format('%s%05d%s', integer >= 0 ? '+' : '-', integer, string.format('%.3f', decimal).sub(2));
}

function mouseRaycast(distance: number) {
	const mouse = UserInputService.GetMouseLocation();
	const ray = camera.ViewportPointToRay(mouse.X, mouse.Y);
	
	const params = new RaycastParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = [wallPlane];
	
	const resultA = Workspace.Raycast(ray.Origin, ray.Direction.Unit.mul(distance), params);
	
	params.FilterType = Enum.RaycastFilterType.Exclude;
	params.FilterDescendantsInstances = [mouseVisual, modifierDisablers, effectsFolder]; // Workspace.FindFirstChild('ray_part')
	
	const resultB = Workspace.Raycast(ray.Origin, ray.Direction.Unit.mul(distance), params);
	return $tuple(resultA?.Position, resultB?.Position, resultB?.Instance !== wallPlane);
}

function getBuildPosition(headCFrame: CFrame) {
	let offset: Vector3 = new Vector3(0, 0, 0);
	
	const buildType = AbilityVariables.BuildingHammer.BuildType;
	if (buildType === 0) offset = headCFrame.LookVector.mul(new Vector3(1, 2, 1));
	else if (buildType === 1) offset = headCFrame.LookVector.mul(new Vector3(2, 1, 1));
	
	return headCFrame.Position.add(offset);
}

function getBuildSize() {
	let size = Vector3.zero;
	
	const buildType = AbilityVariables.BuildingHammer.BuildType;
	if (buildType === 0) size = new Vector3(7, 1, 7);
	else if (buildType === 1) size = new Vector3(1, 7, 7);
	
	return size;
}

function updateModifiers() {
	for (const hitbox of hitboxFolder.GetChildren()) {
		if (hitbox.IsA('SelectionBox')) hitbox.Adornee?.SetAttribute('hitboxOutline', undefined);
	}
	
	hitboxFolder.ClearAllChildren();
	
	const modifierCategory = 'ModifierAbilities';
	getMobileButtonsByCategory(modifierCategory).forEach((button) => button.Destroy());
	
	for (const [ , actions ] of pairs(ActionNames)) {
		for (const [ , actionName ] of pairs(actions)) {
			ContextActionService.UnbindAction(actionName as string);
		}
	}
	
	if (AbilityObjects.GrapplingHammerRope !== undefined) {
		AbilityObjects.GrapplingHammerRope.Destroy();
		AbilityObjects.GrapplingHammerRope = undefined;
	}
	
	const currentHammer = getHammerTexture();
	
	if (getSetting(GameSetting.Modifiers)) {
		if (currentHammer === Accessories.HammerTexture.BuilderHammer) {
			function place(action: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube) return;
				
				if (action === ActionNames.BuildingHammer.Place) {
					if (state === Enum.UserInputState.Begin && !AbilityCooldowns.BuildingHammer) {
						const head = cube.FindFirstChild('Head') as BasePart | undefined;
						if (!head?.IsA('BasePart')) return;
						
						head.AssemblyAngularVelocity = Vector3.zero;
						Events.BuildingHammerPlace.FireServer(getBuildPosition(head.CFrame), AbilityVariables.BuildingHammer.BuildType);
						
						AbilityCooldowns.BuildingHammer = true;
						task.delay(0.4, () => (AbilityCooldowns.BuildingHammer = false));
					}
				}
			}
			
			function switchType(action: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube) return;
				
				if (action === ActionNames.BuildingHammer.Switch) {
					if (state === Enum.UserInputState.Begin) {
						let newType = AbilityVariables.BuildingHammer.BuildType + 1;
						if (newType > 1) newType = 0;
						
						AbilityVariables.BuildingHammer.BuildType = newType;
					}
				}
			}
			
			ContextActionService.BindAction(ActionNames.BuildingHammer.Place, place, false, Enum.KeyCode.E);
			ContextActionService.BindAction(ActionNames.BuildingHammer.Switch, switchType, false, Enum.KeyCode.E);
			
			createMobileButton('🧱', modifierCategory, Vector2.zero, 1, ActionNames.BuildingHammer.Place, (action, state, input) => {
				place(action, state, input as InputObject);
			});
			
			createMobileButton('➡️', modifierCategory, Vector2.yAxis.mul(-1), 0.5, ActionNames.BuildingHammer.Switch, (action, state, input) => {
				switchType(action, state, input as InputObject);
			});
		} else if (currentHammer === Accessories.HammerTexture.GrapplingHammer) {
			function activate(action: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube || !isClientCube(cube)) return;

				if (AbilityObjects.GrapplingHammerRope) {
					AbilityObjects.GrapplingHammerRope.Destroy();
					AbilityObjects.GrapplingHammerRope = undefined;
				}

				if (action === ActionNames.GrapplingHammer.Activate) {
					const head = cube.FindFirstChild('Head');
					const arm = cube.FindFirstChild('Arm');
					const axisLock = Workspace.FindFirstChild('AxisLock');
					const rightAttachment = head?.FindFirstChild('RightAttachment');
					if (!head?.IsA('BasePart') || !arm?.IsA('BasePart') || !axisLock?.IsA('BasePart') || !rightAttachment?.IsA('Attachment')) return;

					if (state === Enum.UserInputState.Begin) {
						const params = new RaycastParams();
						params.FilterType = Enum.RaycastFilterType.Exclude;

						const filter = [];
						for (const object of Workspace.GetChildren()) {
							if (object !== mapFolder && object !== nonBreakable) filter.push(object);
						}

						for (const propeller of propellersFolder.GetChildren()) {
							const hitbox = propeller.FindFirstChild('Hitbox');
							if (hitbox?.IsA('BasePart')) filter.push(hitbox);
						}

						params.FilterDescendantsInstances = filter;

						const result = Workspace.Raycast(head.Position, arm.CFrame.RightVector.mul(6144), params);
						if (!result) return;

						const target = new Instance('Attachment');
						target.CFrame = new CFrame(result.Position);
						target.Parent = axisLock;

						const rope = new Instance('RopeConstraint');
						rope.Visible = true;
						rope.Length = math.max(result.Distance, 1);
						rope.Attachment0 = rightAttachment;
						rope.Attachment1 = target;
						rope.Parent = head;
						AbilityObjects.GrapplingHammerRope = rope;

						head.Massless = false;

						playSound('grapple', {
							PlaybackSpeed: randomFloat(0.9, 1.1),
						});
					} else if (state === Enum.UserInputState.End) {
						head.Massless = true;
					}
				}
			}

			function scroll(action: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube || !isClientCube(cube)) return;

				if (action === ActionNames.GrapplingHammer.Scroll) {
					if (state === Enum.UserInputState.Change) {
						const head = cube.FindFirstChild('Head');
						const rope = AbilityObjects.GrapplingHammerRope;
						if (!head || !head.IsA('BasePart') || !rope || !rope.IsA('RopeConstraint')) return;

						let delta = math.sign(input.Position.Z);
						if (UserInputService.IsKeyDown(Enum.KeyCode.LeftShift)) delta *= 10;

						const newLength = math.clamp(rope.Length + delta * 10, 1, 6144);
						TweenService.Create(rope, new TweenInfo(0.2), {
							Length: newLength,
						}).Play();
					}
				}
			}
			
			ContextActionService.BindAction(ActionNames.GrapplingHammer.Activate, activate, false, Enum.KeyCode.E);
			ContextActionService.BindAction(ActionNames.GrapplingHammer.Scroll, scroll, false, Enum.UserInputType.MouseWheel);
			
			createMobileButton('🪢', modifierCategory, Vector2.zero, 1, ActionNames.GrapplingHammer.Activate, (action, state, input) => {
				activate(action, state, input as InputObject);
			});
		} else if (currentHammer === Accessories.HammerTexture.Shotgun) {
			function fire(action: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube || !isClientCube(cube)) return;
				
				if (action === ActionNames.Shotgun.Fire && !AbilityCooldowns.Shotgun) {
					if (state === Enum.UserInputState.Begin) {
						const arm = cube.FindFirstChild('Arm');
						const shotgun = cube.FindFirstChild('Shotgun');
						if (!arm?.IsA('BasePart') || !shotgun?.IsA('Model')) return;
						
						AbilityCooldowns.Shotgun = true;
						task.delay(1.5, () => (AbilityCooldowns.Shotgun = false));
						
						const velocity = cube.AssemblyAngularVelocity;
						const force = arm.CFrame.RightVector.mul(Workspace.Gravity * -0.7);
						cube.AssemblyAngularVelocity = velocity.add(force);
						
						playSound('shotgun_fire');
						
						const params = new RaycastParams();
						params.FilterDescendantsInstances = [cube];
						
						const result = Workspace.Raycast(arm.Position.add(arm.CFrame.RightVector.mul(4)), arm.CFrame.RightVector.mul(512), params);
						if (result) {
							const part = result.Instance;
							Events.ClientCreateDebris.Fire(result.Normal.mul(30), result.Position, part, 1, true);
							
							if (part.GetAttribute('CAN_BREAK')) part.SetAttribute('FORCE_BREAK', true);
							else if (part.GetAttribute('CAN_SHATTER')) part.SetAttribute('FORCE_SHATTER', true);
							
							const bulletTrail = new Instance('Part');
							bulletTrail.Anchored = true;
							bulletTrail.CanCollide = false;
							bulletTrail.CFrame = CFrame.lookAt(arm.Position.Lerp(result.Position, 0.5), result.Position);
							bulletTrail.Size = new Vector3(0.1, 0.1, arm.Position.sub(result.Position).Magnitude);
							bulletTrail.Color = Color3.fromRGB(255, 255, 0);
							bulletTrail.Material = Enum.Material.Neon;
							bulletTrail.Parent = effectsFolder;
							
							task.delay(0.1, () => bulletTrail.Destroy());
						}
						
						const image1 = shotgun.FindFirstChild('Flash1')?.FindFirstChild('BillboardGui')?.FindFirstChild('ImageLabel');
						const image2 = shotgun.FindFirstChild('Flash2')?.FindFirstChild('BillboardGui')?.FindFirstChild('ImageLabel');
						if (!image1?.IsA('ImageLabel') || !image2?.IsA('ImageLabel')) return;
						
						image1.Visible = true;
						image2.Visible = true;
						task.delay(0.1, () => {
							image1.Visible = false;
							image2.Visible = false;
						});
					}
				}
			}
			
			ContextActionService.BindAction(ActionNames.Shotgun.Fire, fire, false, Enum.KeyCode.E);
			
			createMobileButton('🔫', modifierCategory, Vector2.zero, 1, ActionNames.Shotgun.Fire, (action, state, input) => {
				fire(action, state, input as InputObject);
			});
		} else if (currentHammer === Accessories.HammerTexture.ExplosiveHammer) {
			function explode(name: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube || !isClientCube(cube)) return;
				
				if (name === ActionNames.ExplosiveHammer.Explode && !AbilityCooldowns.ExplosiveHammer) {
					if (state === Enum.UserInputState.Begin) {
						const head = cube.FindFirstChild('Head');
						if (!head?.IsA('BasePart')) return;
						
						AbilityCooldowns.ExplosiveHammer = true;
						
						let didSet = false;
						task.delay(2, () => {
							if (!didSet) {
								didSet = true;
								AbilityCooldowns.ExplosiveHammer = false;
							}
						});
						
						task.spawn(() => {
							waitUntil(() => !AbilityCooldowns.ExplosiveHammer);
							
							if (!didSet) head.Color = Color3.fromRGB(255, 0, 0);
							didSet = true;
						});
						
						head.Color = Color3.fromRGB(255, 175, 0);
						TweenService.Create(head, new TweenInfo(2, Enum.EasingStyle.Linear), { Color: Color3.fromRGB(255, 0, 0) }).Play();
						
						const cubeScale = (cube.GetAttribute('scale') as number | undefined) ?? 1;
						
						const velocity = cube.AssemblyLinearVelocity;
						const force = cube.Position.sub(head.Position).Unit.mul(600 * cubeScale);
						if (force.X === force.X && force.Y === force.Y && force.Z === force.Z) cube.AssemblyLinearVelocity = velocity.add(force);

						const explosion = new Instance('Explosion');
						explosion.Position = head.Position;
						explosion.BlastRadius = 0;
						explosion.BlastPressure = 0;
						explosion.Parent = effectsFolder;
						
						for (const i of $range(1, 15)) playSound('explosion', { PlaybackSpeed: randomFloat(0.9, 1), Volume: head.AssemblyAngularVelocity.Magnitude / 50 });
					}
				}
			}
			
			ContextActionService.BindAction(ActionNames.ExplosiveHammer.Explode, explode, false, Enum.KeyCode.E);
			
			createMobileButton('💥', modifierCategory, Vector2.zero, 1, ActionNames.Shotgun.Fire, (action, state, input) => {
				explode(action, state, input as InputObject);
			});
		} else if (currentHammer === Accessories.HammerTexture.InverterHammer) {
			function invert(action: string, state: Enum.UserInputState, input: InputObject) {
				if (!cube || !isClientCube(cube)) return;
				
				if (action === ActionNames.InverterHammer.Invert && !AbilityCooldowns.InverterHammer) {
					if (state === Enum.UserInputState.Begin) {
						const head = cube.FindFirstChild('Head');
						const arm = cube.FindFirstChild('Arm');
						if (!head?.IsA('BasePart') || !arm?.IsA('BasePart')) return;
						
						AbilityCooldowns.InverterHammer = true;
						task.delay(0.5, () => (AbilityCooldowns.InverterHammer = false));
						
						arm.Color = Color3.fromRGB(0, 0, 0);
						TweenService.Create(arm, tweenTypes.linear.short, {
							Color: Color3.fromRGB(7, 114, 172),
						}).Play();
						
						flippedGravity.Value = !flippedGravity.Value;
						
						playSound('invert');
					}
				}
			}
			
			ContextActionService.BindAction(ActionNames.InverterHammer.Invert, invert, false, Enum.KeyCode.E);
			
			createMobileButton('⤴️', modifierCategory, Vector2.zero, 1, ActionNames.InverterHammer.Invert, (action, state, input) => {
				invert(action, state, input as InputObject);
			});
		} else if (currentHammer === Accessories.HammerTexture.HitboxHammer) {
			for (const descendant of [ ...mapFolder.GetDescendants(), ...nonBreakable.GetDescendants() ]) {
				if (descendant.IsA('BasePart') && !descendant.GetAttribute('hitboxOutline')) {
					descendant.SetAttribute('hitboxOutline', true);
					
					const outline = new Instance('SelectionBox');
					outline.Adornee = descendant;
					outline.Color3 = descendant.IsA('Part') && descendant.Shape === Enum.PartType.Block ? Color3.fromRGB(255, 0, 0) : Color3.fromRGB(0, 0, 255);
					outline.Transparency = math.min(descendant.Transparency, 0.5);
					outline.Parent = hitboxFolder;
				}
			}
		}
	}
}

task.spawn(updateModifiers);

for (const propeller of propellersFolder.GetChildren()) task.spawn(newPropeller, propeller);
propellersFolder.ChildAdded.Connect(newPropeller);

player.AttributeChanged.Connect((attr) => {
	if (attr === PlayerAttributes.HammerTexture || attr === PlayerAttributes.Client.SettingsJSON) updateModifiers();
});

Events.ClientRagdoll.Event.Connect((seconds: number) => {
	const previousRagdollTime = ragdollTime;
	ragdollTime = seconds;

	const currentHat = getCubeHat();
	if (currentHat !== Accessories.CubeHat.InstantGyro && previousRagdollTime === 0) Events.AddRagdollCount.FireServer();
});

RunService.Heartbeat.Connect((dt) => {
	if (player.GetAttribute(PlayerAttributes.Client.InMainMenu)) return;

	for (const otherPlayer of Players.GetPlayers()) {
		const leaderstats = otherPlayer.FindFirstChild('leaderstats');
		const altitudeValue = leaderstats?.FindFirstChild('Altitude');
		const timeValue = leaderstats?.FindFirstChild('Time');
		if (altitudeValue?.IsA('StringValue') && timeValue?.IsA('StringValue')) {
			const otherCube = Workspace.FindFirstChild(`cube${otherPlayer.UserId}`);

			let newAltitudeValue = '--';
			let newTimeValue = '--';

			if (otherCube?.IsA('BasePart')) {
				const [, altitudeString] = convertStudsToMeters(otherCube.Position.Y - 1.9);
				newAltitudeValue = altitudeString;

				const [cubeTime] = getCubeTime(otherCube);
				const [, minutes, seconds, milliseconds] = getTimeUnits(cubeTime * 1000);
				newTimeValue = string.format('%02d:%02d.%d', minutes, seconds, math.floor(milliseconds / 100));
			}

			if (player.GetAttribute(PlayerAttributes.InErrorLand) || otherPlayer.GetAttribute(PlayerAttributes.InErrorLand)) newAltitudeValue = '--';

			timeValue.Value = newTimeValue;
			altitudeValue.Value = newAltitudeValue;
		}
	}

	const currentHammer = getHammerTexture();
	const cubeHat = getCubeHat();

	Workspace.Gravity = (Workspace.GetAttribute('default_gravity') as number | undefined) ?? 0;
	if (getSetting(GameSetting.Modifiers)) {
		if (cubeHat === Accessories.CubeHat.AstronautHelmet) {
			Workspace.Gravity = 5;
		} else if (currentHammer === Accessories.HammerTexture.Hammer404 || player.GetAttribute(PlayerAttributes.InErrorLand)) {
			Workspace.Gravity /= 2;
		}
	}

	let spectatingCube: BasePart | undefined = undefined;
	const otherPlayer = Players.FindFirstChild(spectatePlayer.Value) as Player | undefined;
	if (isSpectating.Value && otherPlayer?.IsA('Player')) {
		const otherCube = Workspace.FindFirstChild(`cube${otherPlayer.UserId}`);
		if (otherCube?.IsA('BasePart')) spectatingCube = otherCube;
	}

	if (!cube || cube.Parent !== Workspace) {
		const localCube = Workspace.FindFirstChild(`cube${player.UserId}`);
		if (!localCube?.IsA('BasePart')) return;

		cube = localCube;
	}

	if (spectatingCube || cube) {
		const targetPlayer = otherPlayer ?? player;
		const targetCube = spectatingCube ?? cube;

		const [altitude, altitudeString] = convertStudsToMeters(targetCube.Position.Y - 1.9);
		const [speed, speedString] = convertStudsToMeters(targetCube.AssemblyLinearVelocity.Magnitude);
		const [cubeTime] = getCubeTime(targetCube);

		const [hours, minutes, seconds, milliseconds] = getTimeUnits(math.round(cubeTime * 1000));

		timerLabel.Text = string.format('%02d:%02d.%d', minutes, seconds, math.floor(milliseconds / 100));
		altitudeLabel.Text = altitudeString;
		speedometerLabel.Text = `${speedString}/s`;

		timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
		if (targetCube.GetAttribute('used_modifiers')) {
			timerLabel.TextColor3 = Color3.fromRGB(179, 77, 77);
			if (targetPlayer.GetAttribute(PlayerAttributes.CompletedGame)) timerLabel.TextColor3 = Color3.fromRGB(255, 128, 128);
		} else if (targetPlayer.GetAttribute(PlayerAttributes.CompletedGame)) {
			timerLabel.TextColor3 = Color3.fromRGB(255, 255, 128);
		} else {
			const timeValue = targetPlayer.FindFirstChild('leaderstats')?.FindFirstChild('Time');
			if (timeValue?.IsA('StringValue') && timeValue.Value === '--') timerLabel.TextColor3 = Color3.fromRGB(179, 179, 179);
		}
	} else {
		timerLabel.Text = '--:--.-';
		altitudeLabel.Text = '--';
		speedometerLabel.Text = '--';
	}

	if (cube) {
		const head = cube.FindFirstChild('Head');
		const arm = cube.FindFirstChild('Arm');
		const centerAttachment = cube.FindFirstChild('CenterAttachment');
		const alignOrientation = cube.FindFirstChild('AlignOrientation');
		const armAlignPosition = arm?.FindFirstChild('AlignPosition');
		const armAlignOrientation = arm?.FindFirstChild('AlignOrientation');
		const startTime = cube.GetAttribute('start_time');
		const armCFrame = cube.FindFirstChild('ArmCFrame');
		const armRotation = cube.FindFirstChild('ArmRotation');

		if (!head?.IsA('BasePart') || !arm?.IsA('BasePart') || !centerAttachment?.IsA('Attachment')) return;
		if (!alignOrientation?.IsA('AlignOrientation') || !armAlignPosition?.IsA('AlignPosition') || !armAlignOrientation?.IsA('AlignOrientation')) return;
		if (!armCFrame?.IsA('Attachment') || !armRotation?.IsA('Attachment')) return;
		if (!typeIs(startTime, 'number')) return;

		const cubeScale = (cube.GetAttribute('scale') as number | undefined) ?? 1;

		const [altitude] = convertStudsToMeters(cube.Position.Y - 1.9);

		const range = cube.FindFirstChild('Range');
		if (range?.IsA('BasePart')) range.Transparency = getSetting(GameSetting.ShowRange) ? 0.75 : 1;

		const windForce = cube.FindFirstChild('WindForce');
		if (windForce?.IsA('VectorForce')) {
			if (altitude > 400 && altitude < 500) windForce.Force = new Vector3(750, 0, 0);
			else windForce.Force = Vector3.zero;
		}

		if (getTime() - startTime < 0.1) ragdollTime = 0;

		head.CustomPhysicalProperties = new PhysicalProperties(0.7, 0.6, 0, 100, 1);
		if (getSetting(GameSetting.Modifiers)) {
			if (currentHammer === Accessories.HammerTexture.IcyHammer) head.CustomPhysicalProperties = new PhysicalProperties(0.7, 0, 0, 100, 1);
		}

		cube.CollisionGroup = 'clientCube';
		for (const descendant of cube.GetDescendants()) {
			if (descendant.IsA('BasePart') && descendant.CollisionGroup === 'cubes') descendant.CollisionGroup = 'clientCube';
		}

		let previousRagdollTime = ragdollTime;
		ragdollTime = math.max(ragdollTime - dt, 0);
		cube.SetAttribute('ragdollTime', ragdollTime);

		if (getSetting(GameSetting.Modifiers) && cubeHat === Accessories.CubeHat.InstantGyro) {
			ragdollTime = 0;
			previousRagdollTime = 0;
		}

		if (ragdollTime > 0 && (!getSetting(GameSetting.Modifiers) || cubeHat !== Accessories.CubeHat.InstantGyro)) {
			alignOrientation.Enabled = false;
			arm.CanCollide = true;
			arm.Massless = false;
			armAlignPosition.Enabled = false;
			armAlignOrientation.Enabled = false;
		} else {
			alignOrientation.Enabled = true;
			arm.CanCollide = false;
			arm.Massless = true;
			armAlignPosition.Enabled = true;
			armAlignOrientation.Enabled = true;
		}

		if (ragdollTime === 0 && previousRagdollTime > 0) {
			$print('Pivot hammer back to cube');
			arm.CFrame = new CFrame(cube.Position).mul(CFrame.fromOrientation(0, 0, math.pi / 2));
		}

		const cubeTransparency = (cube.GetAttribute('transparency') as number | undefined) ?? 0;
		const hammerTransparency = (cube.GetAttribute('hammerTransparency') as number | undefined) ?? 0;

		cube.Transparency = numLerp(cube.Transparency, cubeTransparency, dt * 15);
		for (const part of [head, arm]) {
			let alpha = dt * 15;
			if (cube.GetAttribute('instantHammerTransparency')) {
				alpha = 1;
				cube.SetAttribute('instantHammerTransparent', undefined);
			}

			part.Transparency = numLerp(part.Transparency, hammerTransparency, alpha);
			for (const descendant of part.GetDescendants()) {
				if (descendant.IsA('Decal') || descendant.IsA('Texture')) descendant.Transparency = part.Transparency;
			}
		}

		intensity = shakeIntensity.Value;
		if (isSpectating.Value && otherPlayer) {
			intensity = 0;
			const label = screenGui.FindFirstChild('SpectatingGUI')?.FindFirstChild('PlayerName') as TextLabel | undefined;
			if (label) label.Text = otherPlayer.DisplayName;
		}

		if (flippedGravity.Value) {
			alignOrientation.CFrame = CFrame.fromOrientation(0, 0, math.pi);
			if (!cube.FindFirstChild('upsidedown_gravity')) {
				const force = new Instance('VectorForce');
				force.RelativeTo = Enum.ActuatorRelativeTo.World;
				force.Attachment0 = centerAttachment;
				force.Name = 'upsidedown_gravity';
				force.Parent = cube;
			}
			const force = cube.FindFirstChild('upsidedown_gravity') as VectorForce;
			force.Force = new Vector3(0, Workspace.Gravity * cube.AssemblyMass * 2, 0);
		} else {
			alignOrientation.CFrame = CFrame.fromOrientation(0, 0, 0);
			cube.FindFirstChild('upsidedown_gravity')?.Destroy();
		}

		if (time() > 1) {
			const params = new OverlapParams();
			params.FilterType = Enum.RaycastFilterType.Include;
			params.FilterDescendantsInstances = [modifierDisablers];

			if (!wasModifiersEnabled && previousModifiersCheck) {
				updateModifiers();
				previousModifiersCheck = false;
			} else if (wasModifiersEnabled && !previousModifiersCheck) {
				updateModifiers();
				previousModifiersCheck = true;
			}

			wasModifiersEnabled = Settings.modifiers;
			if (Workspace.GetPartsInPart(cube, params).size() > 0) {
				wasModifiersEnabled = false;
				if (flippedGravity.Value) flippedGravity.Value = false;
			}
		}

		let cubePosition = cube.Position;
		let cubeVelocity = cube.AssemblyAngularVelocity;
		if (spectatingCube) {
			cubePosition = spectatingCube.Position;
			cubeVelocity = spectatingCube.AssemblyAngularVelocity;
		}

		if (!getSetting(GameSetting.ScreenShake)) intensity = 0;

		let cameraPosition = cubePosition;
		if (intensity > 0) cameraPosition = cameraPosition.add(new Vector3((math.random(0, 1) * 2 - 1) * intensity, (math.random(0, 1) * 2 - 1) * intensity, 0));

		const velocity = math.clamp(cubeVelocity.Magnitude - 50, 0, 100) / 15;
		const up = flippedGravity.Value ? Vector3.yAxis.mul(-1) : Vector3.yAxis;

		let zoom = 37.5;
		if (getSetting(GameSetting.Modifiers)) {
			if (currentHammer === Accessories.HammerTexture.LongHammer) zoom = 70;
			else if (currentHammer === Accessories.HammerTexture.GrapplingHammer) zoom = 50;
			else if (currentHammer === Accessories.HammerTexture.ExplosiveHammer) zoom = 65;
		}
		
		if (cubeScale !== 1) zoom *= cubeScale;
		
		wallPlane.Transparency = 1;

		if (getSetting(GameSetting.OrthographicView)) {
			wallPlane.Transparency = 0.75;
			
			zoom *= 64;
			
			for (const [ i, particle ] of pairs(cachedParticles)) {
				if (!particle.IsDescendantOf(Workspace)) cachedParticles.remove(i - 1);

				if (!particle.Enabled || particle.GetAttribute('__emitDebounce')) continue;

				if (particle.Rate < math.huge) {
					particle.SetAttribute('__emitDebounce', true);
					task.delay(1 / particle.Rate, () => particle.SetAttribute('__emitDebounce', undefined));
				}

				particle.Emit(1);
			}
		}

		const cameraCFrame = CFrame.lookAt(cameraPosition.sub(new Vector3(0, 0, zoom + velocity)), cameraPosition, up);

		const start = cube.Position;

		const params = new OverlapParams();
		params.FilterType = Enum.RaycastFilterType.Include;
		params.FilterDescendantsInstances = [mapFolder];

		for (const obstructingPart of Workspace.GetPartBoundsInBox(new CFrame(start.X, start.Y, 0), new Vector3(10, 10, 4096), params)) {
			if (obstructingPart.GetAttribute('CAMERA_TRANSPARENT')) {
				const transparency = (obstructingPart.GetAttribute('CAMERA_TRANSPARENCY') as number) ?? 0.9;
				obstructingPart.LocalTransparencyModifier = numLerp(obstructingPart.LocalTransparencyModifier, transparency, dt * 5);
				TweenService.Create(obstructingPart, tweenTypes.linear.short, {
					LocalTransparencyModifier: 0,
				}).Play();
			}
		}

		if (!replayGui.Enabled) {
			if (camera.CFrame.Position.sub(cameraCFrame.Position).Magnitude > 50) camera.CFrame = camera.CFrame.Lerp(cameraCFrame, 0.5);
			else camera.CFrame = camera.CFrame.Lerp(cameraCFrame, math.clamp(dt * 15, 0, 1));
		}

		if (camera.CameraType !== Enum.CameraType.Scriptable) camera.CameraType = Enum.CameraType.Scriptable;
		if (isSpectating.Value) return;

		shakeIntensity.Value = math.max(intensity - dt * 3, 0);
		wallPlane.Position = cubePosition;

		updatePropellers(cube, head, dt);
		updateMud(cube, head, dt);
		updatePlatforms(cube, head);

		const [position, nonFiltered, hitPart] = mouseRaycast(zoom + 512);
		if (!typeIs(position, 'Vector3') || !typeIs(nonFiltered, 'Vector3')) return;

		if (screenGui.Enabled) {
			mouseVisual.Position = nonFiltered;
			const highlight = mouseVisual.FindFirstChild('Highlight') as Highlight | undefined;
			if (highlight) highlight.FillTransparency = hitPart ? 0 : 1;
		}

		const hammerAngle = math.atan2(position.Y - cube.Position.Y, position.X - cube.Position.X);
		const hammerDistance = cube.Position.sub(position).Magnitude;

		armAlignPosition.MaxForce = 12500;
		armAlignPosition.Responsiveness = 80;
		armAlignOrientation.Responsiveness = 200;

		let maxRange = 13;
		if (getSetting(GameSetting.Modifiers)) {
			if (currentHammer === Accessories.HammerTexture.LongHammer) {
				armAlignPosition.MaxForce = 25000;
				maxRange = 40;
			} else if (currentHammer === Accessories.HammerTexture.Hammer404) {
				armAlignPosition.MaxForce = 6250;
				armAlignPosition.Responsiveness = 40;
				armAlignOrientation.Responsiveness = 100;

				for (const effect of effectsFolder.GetDescendants()) {
					if (effect.IsA('ParticleEmitter')) effect.TimeScale *= 0.5;
				}
			} else if (currentHammer === Accessories.HammerTexture.Mallet) {
				armAlignPosition.MaxForce = 18750;
				maxRange = 8.5;
			} else if (currentHammer === Accessories.HammerTexture.BuilderHammer) {
				maxRange = 15;

				if (AbilityCooldowns.BuildingHammer) head.Color = Color3.fromRGB(255, 128, 128);
				else head.Color = Color3.fromRGB(26, 26, 26);

				const part = new Instance('Part');
				part.Anchored = true;
				part.CanCollide = false;
				part.Position = getBuildPosition(head.CFrame);
				part.Size = getBuildSize();
				part.Transparency = 0.7;
				part.Color = Color3.fromRGB(0, 0, 0);
				part.TopSurface = Enum.SurfaceType.Smooth;
				part.BottomSurface = Enum.SurfaceType.Smooth;
				part.Parent = Workspace;

				task.spawn(() => {
					RunService.Heartbeat.Wait();
					part.Destroy();
				});
			} else if (currentHammer === Accessories.HammerTexture.GodsHammer) {
				armAlignPosition.MaxForce = math.huge;
				armAlignPosition.Responsiveness = math.huge;
			} else if (currentHammer === Accessories.HammerTexture.RealGoldenHammer) {
				armAlignPosition.MaxForce = 560;
			} else if (currentHammer === Accessories.HammerTexture.Platform) {
				head.CollisionGroup = 'cubes';
				maxRange = 18;
			}
		}

		if (cubeScale !== 1) maxRange *= cubeScale;

		if (player.GetAttribute(PlayerAttributes.InErrorLand)) {
			armAlignPosition.MaxForce = 6250;
			armAlignPosition.Responsiveness = 40;
			armAlignOrientation.Responsiveness = 100;

			for (const effect of effectsFolder.GetDescendants()) {
				if (effect.IsA('ParticleEmitter')) effect.TimeScale *= 0.5;
			}
		}

		const rangeDisplay = cube.FindFirstChild('Range');
		if (rangeDisplay?.IsA('BasePart')) rangeDisplay.Size = new Vector3(0, maxRange * 2, maxRange * 2);

		const distanceLimit = cube.FindFirstChild('DistanceLimit');
		if (distanceLimit?.IsA('RopeConstraint')) distanceLimit.Length = maxRange;

		const actualHammerDistance = math.min(hammerDistance, maxRange);
		const rotationOffset = CFrame.fromOrientation(math.pi / 2, math.pi / 2, 0);

		const hammerPosition = cube.Position.add(new Vector3(math.cos(hammerAngle) * actualHammerDistance, math.sin(hammerAngle) * actualHammerDistance));
		const plane = new Vector3(1, 1, 0);

		const mouse = UserInputService.GetMouseLocation();

		const trail = head.FindFirstChild('Trail');
		if (trail?.IsA('Trail')) {
			const isMouseIconVisible = mouseIcon.Visible;
			if (isMouseIconVisible) {
				if (trail.Enabled) {
					const Info = new TweenInfo(0.2, Enum.EasingStyle.Linear);
					TweenService.Create(arm, Info, { LocalTransparencyModifier: 0.75 }).Play();
					TweenService.Create(head, Info, { LocalTransparencyModifier: 0.75 }).Play();
					trail.Enabled = false;
				}
				
				mouseIcon.Position = UDim2.fromOffset(mouse.X, mouse.Y);
			} else {
				if (!trail.Enabled) {
					const Info = new TweenInfo(0.2, Enum.EasingStyle.Linear);
					TweenService.Create(arm, Info, { LocalTransparencyModifier: 0 }).Play();
					TweenService.Create(head, Info, { LocalTransparencyModifier: 0 }).Play();
					trail.Enabled = true;
				}
			}
			
			const hideMouse = player.GetAttribute(PlayerAttributes.Client.HideMouse);
			if (hideMouse === true) UserInputService.MouseIconEnabled = true;
			else UserInputService.MouseIconEnabled = !isMouseIconVisible;
			
			mouseVisual.Transparency = isMouseIconVisible ? 1 : 0;
		}
		
		if (canMove.Value) {
			const [ inset ] = GuiService.GetGuiInset();
			
			let canMove = true;
			
			for (const gui of GUI.GetGuiObjectsAtPosition(mouse.X - inset.X, mouse.Y - inset.Y)) {
				if (gui.IsDescendantOf(mobileButtons)) {
					canMove = false;
					break;
				}
			}
			
			if (canMove) {
				armCFrame.WorldCFrame = CFrame.lookAt(hammerPosition.mul(plane), cube.Position.mul(plane), Vector3.zAxis);
				if (currentHammer === Accessories.HammerTexture.Platform) armRotation.WorldCFrame = CFrame.fromOrientation(0, 0, math.pi / 2);
				else armRotation.WorldCFrame = CFrame.lookAt(cube.Position.mul(plane), head.Position.mul(plane), Vector3.zAxis).mul(rotationOffset);
			}
		}
		
		if (cubeScale !== 1) {
			armAlignPosition.MaxForce *= (cubeScale - 1) ** 3 + 1;
			if (cubeScale > 1) {
				armAlignPosition.Responsiveness *= (cubeScale - 1) ** 2 + 1;
				armAlignOrientation.Responsiveness *= (cubeScale - 1) ** 2 + 1;
			}
		}
		
		const densityMultiplier = 1 - math.log(math.min(cubeScale, 2));
		
		const cubeProperties = cube.CurrentPhysicalProperties;
		const headProperties = head.CurrentPhysicalProperties;
		const armProperties = arm.CurrentPhysicalProperties;
		
		cube.CustomPhysicalProperties = new PhysicalProperties(
			0.5 * densityMultiplier,
			cubeProperties.Friction,
			cubeProperties.Elasticity,
			cubeProperties.FrictionWeight,
			cubeProperties.ElasticityWeight
		);
		
		head.CustomPhysicalProperties = new PhysicalProperties(
			0.7 * densityMultiplier,
			headProperties.Friction,
			headProperties.Elasticity,
			headProperties.FrictionWeight,
			headProperties.ElasticityWeight
		);
		
		arm.CustomPhysicalProperties = new PhysicalProperties(
			0.7 * densityMultiplier,
			armProperties.Friction,
			armProperties.Elasticity,
			armProperties.FrictionWeight,
			armProperties.ElasticityWeight
		);
		
		// Workspace.Gravity *= math.log(math.abs(cubeScale - 1) + 1) * -1 + 1;

		mouseVisual.Size = new Vector3(0.5, 0.5, 0.5).mul(cubeScale);

		if (debugInfo.Visible) {
			const left = debugInfo.FindFirstChild('Left') as Frame;
			const right = debugInfo.FindFirstChild('Right') as Frame;

			(left.FindFirstChild('FPS') as TextLabel).Text = string.format('FPS: %.3f', 1 / dt);

			(left.FindFirstChild('CPosition') as TextLabel).Text = string.format(
				'Position: X%s Y%s Z%s',
				formatDebugWorldNumber(roundDecimalPlaces(cube.Position.X)),
				formatDebugWorldNumber(roundDecimalPlaces(cube.Position.Y)),
				formatDebugWorldNumber(roundDecimalPlaces(cube.Position.Z))
			);

			(left.FindFirstChild('CVelocity') as TextLabel).Text = string.format(
				'Velocity: X%s Y%s Z%s',
				formatDebugWorldNumber(roundDecimalPlaces(cube.AssemblyLinearVelocity.X)),
				formatDebugWorldNumber(roundDecimalPlaces(cube.AssemblyLinearVelocity.Y)),
				formatDebugWorldNumber(roundDecimalPlaces(cube.AssemblyLinearVelocity.Z))
			);

			(left.FindFirstChild('RagdollTime') as TextLabel).Text = string.format('RagdollTime: %.3fs', ragdollTime);

			(left.FindFirstChild('CameraShake') as TextLabel).Text = string.format('CameraShake: %.3fs studs', intensity);

			let totalSounds = 0;
			for (const sound of Workspace.GetChildren()) {
				if (sound.IsA('Sound') && sound.Volume > 0 && sound.IsPlaying) totalSounds++;
			}

			(left.FindFirstChild('TotalSounds') as TextLabel).Text = string.format('Total Sounds Playing: %d', totalSounds);

			(left.FindFirstChild('DestroyedCounter') as TextLabel).Text = string.format(
				'Destroyed Counter: %d',
				(cube.GetAttribute('destroyed_counter') as number | undefined) ?? 0
			);

			let unanchoredParts = 0;
			for (const descendant of Workspace.GetDescendants()) {
				if (descendant.IsA('BasePart') && !descendant.IsA('Terrain') && !descendant.Anchored) unanchoredParts++;
			}

			(left.FindFirstChild('UnanchoredParts') as TextLabel).Text = string.format('Unanchored Parts: %d', unanchoredParts);

			if (cube.AssemblyAngularVelocity.Magnitude > 0) {
				(right.FindFirstChild('VelocityDisplay') as Frame).Rotation = 180 + math.deg(math.atan2(cube.AssemblyLinearVelocity.Y, cube.AssemblyLinearVelocity.X));
				(right.FindFirstChild('VelocityDisplay') as Frame).Visible = true;
			} else (right.FindFirstChild('VelocityDisplay') as Frame).Visible = false;

			(right.FindFirstChild('HammerDisplay') as Frame).Rotation = math.deg(math.atan2(cube.Position.Y - head.Position.Y, cube.Position.X - head.Position.X));
		}
	}
});

winArea.Touched.Connect((otherPart) => {
	if (otherPart.GetAttribute('isCube') && isClientCube(otherPart) && !player.GetAttribute(PlayerAttributes.CompletedGame)) {
		player.SetAttribute(PlayerAttributes.CompletedGame, true);

		const [totalTime] = getCubeTime(otherPart);
		$print(`Completed game in ${totalTime} seconds`);

		Events.CompleteGame.FireServer(totalTime);
		Events.MakeReplayEvent.Fire(string.format('win,%d', totalTime * 1000));
	}
});

Events.ClientReset.Event.Connect((fullReset: boolean) => {
	player.SetAttribute(PlayerAttributes.CompletedGame, undefined);
	for (const [key] of pairs(AbilityCooldowns)) AbilityCooldowns[key] = false;

	flippedGravity.Value = false;
	ragdollTime = 0;

	if (!fullReset && getSetting(GameSetting.Modifiers)) updateModifiers();
});

Events.StartClientTutorial.Event.Connect(() => {
	task.delay(0.1, updateModifiers);
});

Events.ShowChatBubble.OnClientEvent.Connect((bubbleAttachment: BasePart, content: string) => {
	TextChatService.DisplayBubble(bubbleAttachment, content);
});

Events.FlipGravity.OnClientEvent.Connect((isFlipped: boolean | undefined) => {
	if (typeIs(isFlipped, 'boolean')) flippedGravity.Value = isFlipped;
	else flippedGravity.Value = !flippedGravity.Value;
});

UserInputService.InputBegan.Connect((input, processed) => {
	if (processed) return;

	if (input.KeyCode === Enum.KeyCode.I && UserInputService.IsKeyDown(Enum.KeyCode.LeftControl)) debugInfo.Visible = !debugInfo.Visible;
});

for (const descendant of Workspace.GetDescendants()) {
	if (descendant.IsA('ParticleEmitter')) cachedParticles.push(descendant);
}

Workspace.DescendantAdded.Connect((descendant) => {
	if (descendant.IsA('ParticleEmitter')) cachedParticles.push(descendant);
});

Events.SaySystemMessage.OnClientEvent.Connect(saySystemMessage);
Events.ClientMessage.Event.Connect(saySystemMessage);