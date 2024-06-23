import {
    ContextActionService,
    ReplicatedStorage,
    UserInputService,
    TweenService,
    RunService,
	StarterGui,
	Workspace,
    Players,
} from '@rbxts/services';
import { $print } from 'rbxts-transform-debug';

import {
	numLerp,
	getSetting,
	GameSetting,
	getHammerTexture,
	Accessories,
	isClientCube,
	playSound,
	randomFloat,
	waitUntil,
	tweenTypes,
	getCubeHat,
	convertStudsToMeters,
	getTime,
	Settings,
	roundDecimalPlaces,
	getCubeTime
} from 'shared/utils';

const Events = {
    'BuildingHammerPlace': ReplicatedStorage.WaitForChild('BuildingHammerPlace') as RemoteEvent,
    'AddRagdollCount': ReplicatedStorage.WaitForChild('AddRagdollCount') as RemoteEvent,
    'CompleteGame': ReplicatedStorage.WaitForChild('CompleteGame') as RemoteEvent,
    'MakeReplayEvent': ReplicatedStorage.WaitForChild('MakeReplayEvent') as BindableEvent,
    'StartClientTutorial': ReplicatedStorage.WaitForChild('StartClientTutorial') as BindableEvent,
    'ClientReset': ReplicatedStorage.WaitForChild('ClientReset') as BindableEvent,
    'ClientRagdoll': ReplicatedStorage.WaitForChild('ClientRagdoll') as BindableEvent,
    'ClientCreateDebris': ReplicatedStorage.WaitForChild('ClientCreateDebris') as BindableEvent,
};

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? Workspace.WaitForChild('Camera') as Camera;

const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const shakeIntensity = valueInstances.WaitForChild('shake_intensity') as NumberValue;
const isSpectating = valueInstances.WaitForChild('is_spectating') as BoolValue;
const spectatePlayer = isSpectating.WaitForChild('player') as StringValue;
const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const mapFolder = Workspace.WaitForChild('Map');
const mudParts = mapFolder.WaitForChild('MudParts');
const effectsFolder = Workspace.WaitForChild('Effects') as BasePart;
const goalPart = mapFolder.WaitForChild('end_area') as BasePart;
const wallPlane = Workspace.WaitForChild('Wall') as BasePart;
const flippedGravity = ReplicatedStorage.WaitForChild('flipped_gravity') as BoolValue;
const mouseVisual = Workspace.WaitForChild('MouseVisual') as BasePart;
const modifierDisablers = Workspace.WaitForChild('ForceDisableModifiers');

let cube: BasePart | undefined = undefined;

const cooldowns = {
    'explosiveHammer': false,
    'shotgun': false,
    'inverterHammer': false
};

const actionNames = {
    'BuildingHammer': { 'Place': 'building_hammer-place', 'Switch': 'building_hammer-switch' },
    'GrapplingHammer': { 'Activate': 'grappling_hammer-activate', 'Scroll': 'grappling_hammer-scroll' },
    'ExplosiveHammer': { 'Explode': 'explosive_hammer-explode' },
    'Shotgun': { 'Fire': 'shotgun-fire' },
    'InverterHammer': { 'Invert': 'inverter_hammer-invert' }
};

const abilityObjects = {
    'grapplingHammerRope': undefined as (Instance | undefined)
};

let wasModifiersEnabled = false;
let previousModifiersCheck = true;
let ragdollTime = 0;
let intensity = 0;

function formatDebugWorldNumber(num: number) {
	const [ integer, decimal ] = math.modf(math.abs(num));
    return string.format('%s%05d%s', integer >= 0 ? '+' : '-', integer, string.format('%.3f', decimal).sub(2));
}

function mouseRaycast() {
	const mouse = UserInputService.GetMouseLocation();
	const ray = camera.ViewportPointToRay(mouse.X, mouse.Y);
	
	const params = new RaycastParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = [ wallPlane ];
	
	const resultA = Workspace.Raycast(ray.Origin, ray.Direction.Unit.mul(512), params);
	
	params.FilterType = Enum.RaycastFilterType.Exclude;
	params.FilterDescendantsInstances = [ mouseVisual, modifierDisablers, effectsFolder ]; // Workspace.FindFirstChild('ray_part')
	
	const resultB = Workspace.Raycast(ray.Origin, ray.Direction.Unit.mul(512), params)
	return [ resultA?.Position, resultB?.Position, resultB?.Instance !== wallPlane ];
}

function getBuildPosition(headCFrame: CFrame) {
	let offset: Vector3 = new Vector3(0, 0, 0);
    
	const buildType = player.GetAttribute('build_type') ?? 0;
	if (buildType === 0) offset = headCFrame.LookVector.mul(new Vector3(1, 2, 1));
    else if (buildType === 1) offset = headCFrame.LookVector.mul(new Vector3(2, 1, 1));
	
	return headCFrame.Position.add(offset);
}

function getBuildSize(buildType: number) {
	let size = Vector3.zero;
    if (buildType === 0) size = new Vector3(7, 1, 7);
    else if (buildType === 1) size = new Vector3(1, 7, 7);
    
	return size;
}

function updateModifiers() {
    for (const [ hammer, actions ] of pairs(actionNames)) {
        for (const [ abilityName, actionName ] of pairs(actions)) {
            ContextActionService.UnbindAction(actionName as string);
        }
    }
	
    if (abilityObjects.grapplingHammerRope !== undefined) {
        abilityObjects.grapplingHammerRope.Destroy();
        abilityObjects.grapplingHammerRope = undefined;
    }
	
	const currentHammer = getHammerTexture();
	
    if (getSetting(GameSetting.Modifiers)) {
        if (currentHammer === Accessories.HammerTexture.BuilderHammer) {
            function place(action: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube) return;
                
                if (action === actionNames.BuildingHammer.Place) {
                    if (state === Enum.UserInputState.Begin && !player.GetAttribute('place_cooldown')) {
                        const head = cube.FindFirstChild('Head') as (BasePart | undefined);
                        if (!head?.IsA('BasePart')) return;
                        
                        head.AssemblyAngularVelocity = Vector3.zero;
                        Events.BuildingHammerPlace.FireServer(getBuildPosition(head.CFrame), player.GetAttribute('build_type') ?? 0);
                        
                        player.SetAttribute('place_cooldown', true);
                        task.delay(0.4, () => player.SetAttribute('place_cooldown', undefined));
                    }
                }
            }
            
            function switchType(action: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube) return;
                
                if (action === actionNames.BuildingHammer.Switch) {
                    if (state === Enum.UserInputState.Begin) {
                        let newType = ((player.GetAttribute('build_type') as number | undefined) ?? 0) + 1;
                        if (newType > 1) newType = 0;
                        
                        player.SetAttribute('build_type', newType);
                    }
                }
            }
            
            ContextActionService.BindAction(actionNames.BuildingHammer.Place, place, true, Enum.KeyCode.E);
            ContextActionService.SetTitle(actionNames.BuildingHammer.Place, 'Place');
            
            ContextActionService.BindAction(actionNames.BuildingHammer.Switch, switchType, true, Enum.KeyCode.E);
            ContextActionService.SetTitle(actionNames.BuildingHammer.Switch, 'switch');
        } else if (currentHammer === Accessories.HammerTexture.GrapplingHammer) {
            function activate(action: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube || !isClientCube(cube)) return;
                
                if (abilityObjects.grapplingHammerRope) {
                    abilityObjects.grapplingHammerRope.Destroy();
                    abilityObjects.grapplingHammerRope = undefined;
                }
                
                if (action === actionNames.GrapplingHammer.Activate) {
                    const head = cube.FindFirstChild('Head');
                    const axisLock = Workspace.FindFirstChild('AxisLock');
                    const rightAttachment = head?.FindFirstChild('RightAttachment');
                    if (!head?.IsA('BasePart') || !axisLock?.IsA('BasePart') || !rightAttachment?.IsA('Attachment')) return;
                    
                    if (state === Enum.UserInputState.Begin) {
                        const params = new RaycastParams();
                        params.FilterType = Enum.RaycastFilterType.Exclude;
                        
                        const filter = [  ];
                        for (const object of Workspace.GetChildren()) {
                            if (object !== Workspace.FindFirstChild('Map') && object !== Workspace.FindFirstChild('NonBreakable')) filter.push(object);
                        }
                        
                        const propellers = Workspace.FindFirstChild('Propellers') as (Folder | undefined);
                        if (propellers) {
                            for (const propeller of propellers.GetChildren()) {
                                const hitbox = propeller.FindFirstChild('Hitbox') as (BasePart | undefined);
                                if (hitbox) filter.push(hitbox);
                            }
                        }
                        
                        params.FilterDescendantsInstances = filter;
                        
                        const result = Workspace.Raycast(head.Position, head.CFrame.LookVector.mul(6144), params);
                        if (!result) return;
                        
                        const target = new Instance('Attachment');
                        target.WorldCFrame = new CFrame(result.Position);
                        target.Parent = axisLock;
                        
                        const rope = new Instance('RopeConstraint');
                        rope.Visible = true;
                        rope.Length = math.max(result.Distance, 1);
                        rope.Attachment0 = rightAttachment;
                        rope.Attachment1 = target;
                        rope.Parent = head;
                        abilityObjects.grapplingHammerRope = rope;
                        
                        head.Massless = false;
                        
                        playSound('grapple', { PlaybackSpeed: randomFloat(0.9, 1.1) });
                    } else if (state === Enum.UserInputState.End) {
                        head.Massless = true;
                    }
                }
            }
            
            function scroll(action: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube || !isClientCube(cube)) return;
                
                if (action === actionNames.GrapplingHammer.Scroll) {
                    if (state === Enum.UserInputState.Change) {
                        const head = cube.FindFirstChild('Head');
                        const rope = abilityObjects.grapplingHammerRope;
                        if (!head || !head.IsA('BasePart') || !rope || !rope.IsA('RopeConstraint')) return;
                        
                        let delta = math.sign(input.Position.Z);
                        if (UserInputService.IsKeyDown(Enum.KeyCode.LeftShift)) delta *= 10;
                        
                        const newLength = math.clamp(rope.Length + delta * 10, 1, 6144);
                        TweenService.Create(rope, tweenTypes.linear.short, { Length: newLength }).Play();
                    }
                }
            }
            
            ContextActionService.BindAction(actionNames.GrapplingHammer.Activate, activate, true, Enum.KeyCode.E);
            ContextActionService.SetTitle(actionNames.GrapplingHammer.Activate, 'Grapple');
            
            ContextActionService.BindAction(actionNames.GrapplingHammer.Activate, scroll, false, Enum.UserInputType.MouseWheel);
        } else if (currentHammer === Accessories.HammerTexture.Shotgun) {
            function fire(action: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube || !isClientCube(cube)) return;
                
                if (action === actionNames.Shotgun.Fire && !cooldowns.shotgun) {
                    if (state === Enum.UserInputState.Begin) {
                        const arm = cube.FindFirstChild('Arm')
                        const shotgun = cube.FindFirstChild('Shotgun');
                        if (!arm?.IsA('BasePart') || !shotgun?.IsA('Model')) return;
                        
                        cooldowns.shotgun = true;
                        task.delay(1.5, () => cooldowns.shotgun = false);
                        
                        const velocity = cube.AssemblyAngularVelocity;
                        const force = arm.CFrame.RightVector.mul(Workspace.Gravity * -0.7);
                        cube.AssemblyAngularVelocity = velocity.add(force);
                        
                        playSound('shotgun_fire');
                        
                        const params = new RaycastParams();
                        params.FilterDescendantsInstances = [ cube ];
                        
                        const result = Workspace.Raycast(arm.Position.add(arm.CFrame.RightVector.mul(4)), arm.CFrame.RightVector.mul(512), params);
                        if (result) {
                            const part = result.Instance
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
							image1.Visible = false
							image2.Visible = false
                        });
                    }
                }
            }
            
            ContextActionService.BindAction(actionNames.Shotgun.Fire, fire, true, Enum.KeyCode.E);
            ContextActionService.SetTitle(actionNames.Shotgun.Fire, 'Fire');
        } else if (currentHammer === Accessories.HammerTexture.ExplosiveHammer) {
            function explode(name: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube || !isClientCube(cube)) return;
                
                if (name === actionNames.ExplosiveHammer.Explode && !cooldowns.explosiveHammer) {
                    if (state === Enum.UserInputState.Begin) {
                        const head = cube.FindFirstChild('Head');
                        if (!head?.IsA('BasePart')) return;
                        
                        let didSet = false;
                        cooldowns.explosiveHammer = true;
                        task.delay(2, () => {
                            if (!didSet) {
                                didSet = true;
                                cooldowns.explosiveHammer = false;
                            }
                        });
                        
                        task.spawn(() => {
                            waitUntil(() => !cooldowns.explosiveHammer);
                            
                            if (!didSet) TweenService.Create(head, new TweenInfo(0), { Color: Color3.fromRGB(255, 0, 0) });
                            didSet = true;
                        });
                        
                        const velocity = cube.AssemblyAngularVelocity;
                        const force = cube.Position.sub(head.Position).Unit.mul(600);
                        cube.AssemblyAngularVelocity = velocity.add(force);
                        
                        const explosion = new Instance('Explosion');
                        explosion.Position = head.Position;
                        explosion.BlastRadius = 0;
                        explosion.BlastPressure = 0;
                        explosion.Parent = Workspace.FindFirstChild('Effects');
                        
						for (const i of $range(1, 15)) playSound('explosion', { PlaybackSpeed: randomFloat(0.9, 1), Volume: head.AssemblyAngularVelocity.Magnitude / 50 });
                    }
                }
            }
            
            ContextActionService.BindAction(actionNames.ExplosiveHammer.Explode, explode, true, Enum.KeyCode.E);
            ContextActionService.SetTitle(actionNames.ExplosiveHammer.Explode, '💥');
        } else if (currentHammer === Accessories.HammerTexture.InverterHammer) {
            function invert(action: string, state: Enum.UserInputState, input: InputObject) {
                if (!cube || !isClientCube(cube)) return;
                
                if (action === actionNames.InverterHammer.Invert && !cooldowns.inverterHammer) {
                    if (state === Enum.UserInputState.Begin) {
                        const head = cube.FindFirstChild('Head');
                        const arm = cube.FindFirstChild('Arm');
                        if (!head?.IsA('BasePart') || !arm?.IsA('BasePart')) return;
                        
                        cooldowns.inverterHammer = true;
                        task.delay(0.5, () => cooldowns.inverterHammer = false);
                        
                        arm.Color = Color3.fromRGB(0, 0, 0);
                        TweenService.Create(arm, tweenTypes.linear.short, { Color: Color3.fromRGB(7, 114, 172) }).Play();
                        
                        flippedGravity.Value = !flippedGravity.Value;
                        ContextActionService.SetTitle(actionNames.InverterHammer.Invert, flippedGravity.Value ? '⬇️' : '⬆️');
                        
                        playSound('invert');
                    }
                }
            }
			
			ContextActionService.BindAction(actionNames.InverterHammer.Invert, invert, true, Enum.KeyCode.E)
			ContextActionService.SetTitle(actionNames.InverterHammer.Invert, '⬆️')
        }
    }
}

task.spawn(updateModifiers);

player.AttributeChanged.Connect((attr) => {
    if (attr === 'hammer_Texture' || attr === 'client_settings_json') updateModifiers();
});

Events.ClientRagdoll.Event.Connect((seconds:number) => {
	const previousRagdollTime = ragdollTime;
	ragdollTime = seconds;
	
	const currentHat = getCubeHat();
	if (currentHat !== Accessories.CubeHat.InstantGyro && previousRagdollTime === 0) Events.AddRagdollCount.FireServer();
});

RunService.RenderStepped.Connect((dt) => {
	if (player.GetAttribute('in_main_menu')) return;
	
	const currentHammer = getHammerTexture();
	const cubeHat = getCubeHat();
	
	Workspace.Gravity = (Workspace.GetAttribute('default_gravity') as number | undefined) ?? 0;
	if (getSetting(GameSetting.Modifiers)) {
		if (cubeHat === Accessories.CubeHat.AstronautHelmet) {
			Workspace.Gravity = 5;
		} else if (currentHammer === Accessories.HammerTexture.Hammer404 || player.GetAttribute('ERROR_LAND')) {
			Workspace.Gravity /= 2;
		}
	}
	
	let spectatingCube: BasePart | undefined = undefined;
	const otherPlayer = Players.FindFirstChild(spectatePlayer.Value) as Player | undefined;
	if (isSpectating.Value && otherPlayer?.IsA('Player')) {
		const otherCube = Workspace.FindFirstChild(`cube${otherPlayer.UserId}`);
		if (otherCube?.IsA('BasePart')) spectatingCube = otherCube;
	}
	
	if (!cube) {
		const localCube = Workspace.FindFirstChild(`cube${player.UserId}`);
		if (!localCube?.IsA('BasePart')) return;
		
		cube = localCube;
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
		
		const [ altitude ] = convertStudsToMeters(cube.Position.Y - 1.9);
		
		const windForce = cube.FindFirstChild('WindForce')
		if (windForce?.IsA('VectorForce')) {
			if (altitude > 400 && altitude < 500) windForce.Force = new Vector3(750, 0, 0);
			else windForce.Force = Vector3.zero;
		}
		
		if (!getSetting(GameSetting.Modifiers) && flippedGravity.Value) flippedGravity.Value = false;
		
		if (getTime() - startTime < 0.1) ragdollTime = 0;
		
		head.CustomPhysicalProperties = new PhysicalProperties(0.7, 0.6, 0, 100, 1);
		if (getSetting(GameSetting.Modifiers)) {
			if (currentHammer === Accessories.HammerTexture.IcyHammer) head.CustomPhysicalProperties = new PhysicalProperties(0.7, 0, 0, 100, 1);
		}
		
		cube.CollisionGroup = 'clientCube';
		for (const descendant of cube.GetDescendants()) {
			if (descendant.IsA('BasePart') && descendant.CollisionGroup === 'cubes') descendant.CollisionGroup = 'clientCube'
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
			armAlignPosition.Enabled = true
			armAlignOrientation.Enabled = true;
		}
		
		ragdollTime = math.max(ragdollTime - dt, 0);
		
		cube.SetAttribute('ragdollTime', ragdollTime);
		
		const cubeTransparency = (cube.GetAttribute('transparency') as number | undefined) ?? 0;
		const hammerTransparency = (cube.GetAttribute('hammerTransparency') as number | undefined) ?? 0;
		
		cube.Transparency = numLerp(cube.Transparency, cubeTransparency, dt * 15);
		for (const part of [ head, arm ]) {
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
			params.FilterDescendantsInstances = [ modifierDisablers ];
			if (!wasModifiersEnabled && previousModifiersCheck) {
				updateModifiers();
				previousModifiersCheck = false;
			} else if (wasModifiersEnabled && !previousModifiersCheck) {
				updateModifiers();
				previousModifiersCheck = true;
			}
			
			wasModifiersEnabled = Settings.modifiers;
			if (Workspace.GetPartsInPart(cube, params).size() > 0) wasModifiersEnabled = false;
		}
		
		let cubePosition = cube.Position;
		let cubeVelocity = cube.AssemblyAngularVelocity;
		if (spectatingCube) {
			cubePosition = spectatingCube.Position;
			cubeVelocity = spectatingCube.AssemblyAngularVelocity;
		}
		
		const cameraPosition = cubePosition.add(new Vector3((math.random() < 0.5 ? 1 : -1) * intensity, (math.random() < 0.5 ? 1 : -1) * intensity, 0));
		const velocity = math.clamp(cubeVelocity.Magnitude - 50, 0, 100) / 15;
		const up = flippedGravity.Value ? Vector3.yAxis.mul(-1) : Vector3.yAxis;
		
		let zoom = 37.5;
		if (getSetting(GameSetting.Modifiers)) {
			if (currentHammer === Accessories.HammerTexture.LongHammer) zoom = 70;
			else if (currentHammer === Accessories.HammerTexture.GrapplingHammer) zoom = 50;
			else if (currentHammer === Accessories.HammerTexture.ExplosiveHammer) zoom = 65;
		}
		
		const cameraCFrame = CFrame.lookAt(cameraPosition.sub(new Vector3(0, 0, zoom + velocity)), cameraPosition, up);
		
		const start = cube.Position;
		const goal = cameraCFrame.Position;
		
		const distance = start.sub(goal).Magnitude;
		
		// let part = Workspace.FindFirstChild('ray_part') as BasePart | undefined;
		// if (!part) {
		// 	part = new Instance('Part');
		// 	part.CanCollide = false;
		// 	part.Anchored = true;
		// 	part.Transparency = 1;
		// 	part.Name = 'ray_part';
		// 	part.Parent = Workspace;
		// }
		
		// part.Position = new Vector3(start.X, start.Y, distance / -2);
		// part.Size = new Vector3(10, 10, distance);
		
		const params = new OverlapParams();
		params.FilterType = Enum.RaycastFilterType.Include;
		params.FilterDescendantsInstances = [ mapFolder ];
		
		for (const obstructingPart of Workspace.GetPartBoundsInBox(new CFrame(start.X, start.Y, distance / -2), new Vector3(10, 10, distance), params)) {
			if (obstructingPart.GetAttribute('CAMERA_TRANSPARENT')) {
				obstructingPart.LocalTransparencyModifier = numLerp(obstructingPart.LocalTransparencyModifier, 0.9, dt * 5);
				TweenService.Create(obstructingPart, tweenTypes.linear.short, { LocalTransparencyModifier: 0 }).Play();
			}
		}
		
		const replayGui = GUI.FindFirstChild('ReplayGui');
		if (!replayGui?.IsA('ScreenGui') || !replayGui.Enabled) {
			if (camera.CFrame.Position.sub(cameraCFrame.Position).Magnitude > 50) camera.CFrame = camera.CFrame.Lerp(cameraCFrame, 0.5);
			else camera.CFrame = camera.CFrame.Lerp(cameraCFrame, math.clamp(dt * 15, 0, 1));
		}
		
		if (camera.CameraType !== Enum.CameraType.Scriptable) camera.CameraType = Enum.CameraType.Scriptable;
		if (isSpectating.Value) return;
		
		shakeIntensity.Value = math.max(intensity - dt * 3, 0);
		wallPlane.Position = cubePosition;
		
		const [ position, nonFiltered, hitPart ] = mouseRaycast();
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
				
				if (player.GetAttribute('place_cooldown')) head.Color = Color3.fromRGB(255, 128, 128);
				else head.Color = Color3.fromRGB(26, 26, 26);
				
				const part = new Instance('Part');
				part.Anchored = true;
				part.CanCollide = false;
				part.Position = getBuildPosition(head.CFrame);
				part.Size = getBuildSize((player.GetAttribute('build_type') as number | undefined) ?? 0);
				part.Transparency = 0.7;
				part.Color = Color3.fromRGB(0, 0, 0);
				part.TopSurface = Enum.SurfaceType.Smooth;
				part.BottomSurface = Enum.SurfaceType.Smooth;
				part.Parent = Workspace;
				
				task.spawn(() => {
					RunService.RenderStepped.Wait();
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
		
		if (player.GetAttribute('ERROR_LAND')) {
			armAlignPosition.MaxForce = 6250;
			armAlignPosition.Responsiveness = 40;
			armAlignOrientation.Responsiveness = 100;
			
			for (const effect of effectsFolder.GetDescendants()) {
				if (effect.IsA('ParticleEmitter')) effect.TimeScale *= 0.5;
			}
		}
		
		const rangeDispaly = cube.FindFirstChild('Range');
		if (rangeDispaly?.IsA('BasePart')) rangeDispaly.Size = new Vector3(0.001, maxRange * 2, maxRange * 2);
		
		const distanceLimit = cube.FindFirstChild('DistanceLimit');
		if (distanceLimit?.IsA('RopeConstraint')) distanceLimit.Length = maxRange;
		
		const actualHammerDistance = math.min(hammerDistance, maxRange);
		
		const hammerPosition = cube.Position.add(new Vector3(math.cos(hammerAngle) * actualHammerDistance, math.sin(hammerAngle) * actualHammerDistance));
		const plane = new Vector3(1, 1, 0);
		
		if (canMove.Value) {
			const rotationOffset = CFrame.fromOrientation(math.pi / 2, math.pi / 2, 0);
			
			const mouse = UserInputService.GetMouseLocation();
			for (const gui of StarterGui.GetGuiObjectsAtPosition(mouse.X, mouse.Y)) {
				if (gui.Name === 'ContextButtonFrame') return;
			}
			
			armCFrame.WorldCFrame = CFrame.lookAt(hammerPosition.mul(plane), cube.Position.mul(plane), Vector3.zAxis);
			if (currentHammer === Accessories.HammerTexture.Platform) armRotation.WorldCFrame = CFrame.fromOrientation(0, 0, math.pi / 2);
			else armRotation.WorldCFrame = CFrame.lookAt(cube.Position.mul(plane), head.Position.mul(plane), Vector3.zAxis).mul(rotationOffset);
		}
		
		const debugInfo = screenGui.FindFirstChild('DebugInfo') as Frame | undefined;
		if (debugInfo && debugInfo.Visible) {
			const left = debugInfo.FindFirstChild('Left') as Frame;
			const right = debugInfo.FindFirstChild('Right') as Frame;
			
			(left.FindFirstChild('FPS') as TextLabel).Text = string.format(
				'FPS: %.3f',
				1 / dt
			);
			
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
			
			(left.FindFirstChild('RagdollTime') as TextLabel).Text = string.format(
				'RagdollTime: %.3fs',
				ragdollTime
			);
			
			(left.FindFirstChild('CameraShake') as TextLabel).Text = string.format(
				'CameraShake: %.3fs studs',
				intensity
			);
			
			let totalSounds = 0;
			for (const sound of Workspace.GetChildren()) {
				if (sound.IsA('Sound') && sound.Volume > 0 && sound.IsPlaying) totalSounds++;
			}
			
			(left.FindFirstChild('TotalSounds') as TextLabel).Text = string.format(
				'Total Sounds Playing: %d',
				totalSounds
			);
			
			(left.FindFirstChild('DestroyedCounter') as TextLabel).Text = string.format(
				'Destroyed Counter: %d',
				(cube.GetAttribute('destroyed_counter') as number | undefined) ?? 0
			);
			
			let unanchoredParts = 0;
			for (const descendant of Workspace.GetDescendants()) {
				if (descendant.IsA('BasePart') && !descendant.IsA('Terrain') && !descendant.Anchored) unanchoredParts++;
			}
			
			(left.FindFirstChild('UnanchoredParts') as TextLabel).Text = string.format(
				'Unanchored Parts: %d',
				unanchoredParts
			);
			
			if (cube.AssemblyAngularVelocity.Magnitude > 0) {
				(right.FindFirstChild('VelocityDisplay') as Frame).Rotation = 180 + math.deg(math.atan2(cube.AssemblyLinearVelocity.Y, cube.AssemblyAngularVelocity.X));
				(right.FindFirstChild('VelocityDisplay') as Frame).Visible = true;
			} else (right.FindFirstChild('VelocityDisplay') as Frame).Visible = false;
			
			(right.FindFirstChild('HammerDisplay') as Frame).Rotation = math.deg(math.atan2(cube.Position.Y - head.Position.Y, cube.Position.X - head.Position.X));
		}
	}
});

goalPart.Touched.Connect((otherPart) => {
	if (otherPart.GetAttribute('isCube') && isClientCube(otherPart) && !player.GetAttribute('finished')) {
		player.SetAttribute('finished', true);
		
		const [ totalTime ] = getCubeTime(otherPart);
		$print(`Completed game in ${totalTime} seconds`);
		
		Events.CompleteGame.FireServer(totalTime);
		Events.MakeReplayEvent.Fire(string.format('win,%d', totalTime * 1000));
	}
});

Events.ClientReset.Event.Connect(() => {
	player.SetAttribute('finished', undefined);
	
	for (const [ key ] of pairs(cooldowns)) cooldowns[key] = false;
	
	ragdollTime = 0;
});

Events.StartClientTutorial.Event.Connect(() => {
	task.delay(0.1, updateModifiers);
});

UserInputService.InputBegan.Connect((input, processed) => {
	if (processed) return;
	
	if (input.KeyCode === Enum.KeyCode.I && UserInputService.IsKeyDown(Enum.KeyCode.LeftControl)) {
		const debugInfo = screenGui.FindFirstChild('DebugInfo') as Frame | undefined;
		if (debugInfo) debugInfo.Visible = !debugInfo.Visible
	}
});

RunService.Heartbeat.Connect((step) => {
	if (!cube || player.GetAttribute('ERROR_LAND')) return;
	
	const slowdownFactor = math.clamp(1 - (step * 40), 0.01, 1);
	const touching = [ cube, cube.FindFirstChild('Head') ];
	
	const params = new OverlapParams();
	params.FilterType = Enum.RaycastFilterType.Include;
	params.FilterDescendantsInstances = [ mudParts ];
	
	for (const part of touching) {
		if (!part?.IsA('BasePart')) return;
		
		if (Workspace.GetPartsInPart(part, params).size() > 0) part.AssemblyLinearVelocity = part.AssemblyLinearVelocity.mul(slowdownFactor);
	}
});