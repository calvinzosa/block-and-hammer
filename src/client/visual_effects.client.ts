import {
    CollectionService,
    ReplicatedStorage,
    GeometryService,
    TweenService,
    HttpService,
    RunService,
    Lighting,
    Players,
    Debris,
    Workspace,
} from '@rbxts/services';
import { $print } from 'rbxts-transform-debug';

import {
	getSetting,
	getHammerTexture,
	Accessories,
	GameSetting,
	tweenTypes,
	randomFloat,
	randomDirection,
	playSound,
	waitUntil,
	getPartId,
	isClientCube,
	getTime,
	convertStudsToMeters,
	numLerp
} from 'shared/utils';

const Events = {
	'DestroyedPart': ReplicatedStorage.WaitForChild('DestroyedPart') as RemoteEvent,
	'GroundImpact': ReplicatedStorage.WaitForChild('GroundImpact') as RemoteEvent,
	'BreakPart': ReplicatedStorage.WaitForChild('BreakPart') as BindableEvent,
	'ShatterPart': ReplicatedStorage.WaitForChild('ShatterPart') as BindableEvent,
	'ClientCreateDebris': ReplicatedStorage.WaitForChild('ClientCreateDebris') as BindableEvent,
    'MakeReplayEvent': ReplicatedStorage.WaitForChild('MakeReplayEvent') as BindableEvent,
    'ClientRagdoll': ReplicatedStorage.WaitForChild('ClientRagdoll') as BindableEvent,
};

interface StrokeScaleModule {
	ScaleBillboardGui(billboardGui: BillboardGui, relativeSize: number): void;
}

const StrokeScale = require(ReplicatedStorage.WaitForChild('Modules').WaitForChild('StrokeScale') as ModuleScript) as StrokeScaleModule;

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? Workspace.WaitForChild('Camera') as Camera;

const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const canMove = valueInstances.WaitForChild('can_move') as BoolValue;
const isSpectating = valueInstances.WaitForChild('is_spectating') as BoolValue;
const spectatePlayer = isSpectating.WaitForChild('player') as StringValue;
const shakeIntensity = valueInstances.WaitForChild('shake_intensity') as NumberValue;
const speedLines = screenGui.WaitForChild('SpeedLines') as ImageLabel;
const mapFolder = Workspace.WaitForChild('Map') as Folder;
const nonBreakable = Workspace.WaitForChild('NonBreakable') as Folder;
const effectsFolder = Workspace.WaitForChild('Effects') as Folder;
const debrisTypes = ReplicatedStorage.WaitForChild('DebrisTypes') as Folder;
const sfx = ReplicatedStorage.WaitForChild('SFX') as Folder;
const wind = sfx.WaitForChild('wind') as Sound;

const subtractOptions = {
	CollisionFidelity: Enum.CollisionFidelity.Default
};

let prevCubePosition: Vector3 | undefined = undefined;
let geometryDebounce = false;
let debounce = false;
let speedIndex = 0;

let currentVelocity = new Vector3(0, 0, 0);
let lastVelocity = new Vector3(0, 0, 0);

let cube: BasePart | undefined = undefined;
let head: BasePart | undefined = undefined;

const speedImages = [
	'rbxassetid://13484709347',
	'rbxassetid://13484709591',
	'rbxassetid://13484709832',
	'rbxassetid://13484710115',
	'rbxassetid://13484710536'
];

function createDebris(velocity: Vector3, position: Vector3, part: BasePart, multiplier: number[] | number, createHole: boolean = false, hammerTexture: Accessories.HammerTexture = getHammerTexture()): void {
	let multiplierArray: number[];
	let originalMultiplier = 1;
	if (typeIs(multiplier, 'number')) {
		originalMultiplier = multiplier;
		multiplierArray = [ 5 * multiplier, 15 * multiplier ];
	} else multiplierArray = multiplier;
	
	const point = part.GetClosestPointOnSurface(position);
	const normal = position.sub(point).Unit;
	
	if (getSetting(GameSetting.Effects)) {
		if (originalMultiplier === 1 && createHole) {
			const circle = new Instance('Part');
			circle.CanCollide = false;
			circle.CFrame = CFrame.lookAlong(point, normal).mul(CFrame.fromOrientation(0, math.pi / 2, 0));
			circle.Shape = Enum.PartType.Cylinder;
			circle.Size = new Vector3(0.001, 1, 1);
			circle.Color = Color3.fromRGB(0, 0, 0);
			circle.Transparency = 0.5;
			circle.TopSurface = Enum.SurfaceType.Smooth;
			circle.BottomSurface = Enum.SurfaceType.Smooth;
			
			const weld = new Instance('WeldConstraint');
			weld.Part0 = circle;
			weld.Part1 = part;
			weld.Parent = circle;
			
			task.delay(5, () => {
				TweenService.Create(circle, tweenTypes.linear.short, { Transparency: 1 }).Play();
				Debris.AddItem(circle, 1);
			});
			
			circle.Parent = effectsFolder;
		}
		
		if (hammerTexture === Accessories.HammerTexture.GodsHammer) multiplierArray = [ 20, 25 ];
		
		if (effectsFolder.GetChildren().size() < 600) {
			const types = debrisTypes.GetChildren();
			if (types.size() > 0) {
				const totalDebris = math.random(multiplierArray[0], multiplierArray[1]);
				for (let i = 1; i < totalDebris; i++) {
					const debris = types[math.random(0, types.size() - 1)].Clone() as BasePart;
					debris.Anchored = false;
					debris.CFrame = new CFrame(position);
					debris.Size = new Vector3(1, 1, 1).mul(randomFloat(0.5, 1.5));
					debris.Color = part.Color;
					debris.Material = part.Material;
					debris.Transparency = part.Transparency;
					debris.LocalTransparencyModifier = part.LocalTransparencyModifier;
					debris.Parent = effectsFolder;
					
					if (originalMultiplier === 1) {
						if (hammerTexture === Accessories.HammerTexture.Hammer404) {
							debris.Material = Enum.Material.Neon;
							debris.Color = math.random() < 0.5 ? Color3.fromRGB(0, 0, 0) : Color3.fromRGB(255, 0, 255);
							debris.AddTag('ErrorEffects');
						} else if (hammerTexture === Accessories.HammerTexture.GoldenHammer) {
							debris.Material = Enum.Material.Foil;
							debris.Color = Color3.fromRGB(255, 255, 128);
						} else if (hammerTexture === Accessories.HammerTexture.GodsHammer) {
							debris.Material = Enum.Material.Neon;
							debris.Color = Color3.fromRGB(255, 255, 255);
						}
					}
					
					debris.AssemblyLinearVelocity = randomDirection(velocity.Magnitude / -4).add(velocity.Unit.mul(20));
					debris.AssemblyAngularVelocity = randomDirection();
					
					task.delay(1, () => {
						TweenService.Create(debris, tweenTypes.linear.short, { Transparency: 1 }).Play();
						Debris.AddItem(debris, 1);
					});
				}
			}
		}
	}
	
	if (originalMultiplier === 1) {
		if (hammerTexture === Accessories.HammerTexture.Hammer404) {
			playSound('error2', { PlaybackSpeed: randomFloat(1, 1.05), Volume: velocity.Magnitude / 7.5 }, true);
		} else if (hammerTexture === Accessories.HammerTexture.GoldenHammer) {
			task.delay(0.15, () => playSound('money', { PlaybackSpeed: randomFloat(0.95, 1), Volume: velocity.Magnitude / 15 }, true));
		} else if (hammerTexture === Accessories.HammerTexture.GodsHammer) {
			playSound('lightning_bolt', { PlaybackSpeed: randomFloat(0.95, 1), Volume: velocity.Magnitude / 15 }, true);
		} else if (hammerTexture === Accessories.HammerTexture.IcyHammer) {
			playSound('shatter', { PlaybackSpeed: randomFloat(0.9, 1) }, true);
		}
		
		playSound('hit2', { PlaybackSpeed: randomFloat(0.9, 1), Volume: velocity.Magnitude / 7.5 });
	}
}

function normalToFace(normalVector: Vector3, part: BasePart): Enum.NormalId | undefined {
	function getNormalFromFace(normalId: Enum.NormalId) {
		return part.CFrame.VectorToWorldSpace(Vector3.FromNormalId(normalId));
	}
	
	for (const normalId of Enum.NormalId.GetEnumItems()) {
		if (getNormalFromFace(normalId).Dot(normalVector) > 0.999) return normalId;
	}
	
	return undefined;
}

function breakPart(otherPart: BasePart, head: BasePart, isOnlyEffect: boolean = false): void {
	createDebris(head.AssemblyLinearVelocity, head.Position, otherPart, 1, false);
	
	const particles = otherPart.FindFirstChildWhichIsA('ParticleEmitter')
	if (particles) particles.Emit(math.random(20, 30));
	
	if (!isOnlyEffect) {
		otherPart.CanCollide = false;
		otherPart.LocalTransparencyModifier = 0.75;
		for (const descendant of otherPart.GetDescendants()) {
			if (descendant.IsA('BasePart')) {
				descendant.LocalTransparencyModifier = 1;
			} else if (descendant.IsA('Decal') || descendant.IsA('Texture')) {
				descendant.Transparency = 1;
			}
		}
	}
	
	if (getSetting(GameSetting.CSG)) {
		const model = new Instance('Model');
		otherPart.Clone().Parent = model;
		const [ _, boundingBox ] = model.GetBoundingBox();
		model.Destroy();
		
		const closestPoint = otherPart.GetClosestPointOnSurface(head.Position);
		const maxSize = math.max(boundingBox.X, boundingBox.Y, boundingBox.Z);
		const flingVector = new Vector3(0, 30, 0);
		
		if (otherPart.IsA('UnionOperation')) {
			const piece = otherPart.Clone();
			piece.Anchored = false;
			piece.CanCollide = true;
			piece.CollisionGroup = 'debris';
			piece.AssemblyLinearVelocity = piece.GetClosestPointOnSurface(closestPoint).sub(closestPoint).Unit.mul(10).add(flingVector);
			piece.AssemblyAngularVelocity = randomDirection();
			piece.Parent = effectsFolder;
			
			TweenService.Create(piece, tweenTypes.linear.medium, { Transparency: 1 }).Play();
			Debris.AddItem(piece, tweenTypes.linear.medium.Time);
		} else {
			const slicers: BasePart[] = [  ];
			
			for (const i of $range(1, 6)) {
				const plane = new Instance('Part');
				plane.CanCollide = false;
				plane.Anchored = true;
				plane.Transparency = 1;
				plane.CFrame = CFrame.lookAlong(otherPart.Position.add(randomDirection(boundingBox.div(2))), randomDirection());
				plane.Size = new Vector3(0.5, maxSize * 3, maxSize * 3);
				plane.Parent = effectsFolder;
				slicers.push(plane);
			}
			
			const pieces = GeometryService.SubtractAsync(otherPart, slicers, subtractOptions) as PartOperation[];
			for (const piece of pieces) {
				piece.Anchored = false;
				piece.CanCollide = true;
				piece.CollisionGroup = 'debris';
				piece.AssemblyLinearVelocity = piece.GetClosestPointOnSurface(closestPoint).sub(closestPoint).Unit.mul(10).add(flingVector);
				piece.AssemblyAngularVelocity = randomDirection();
				piece.Parent = effectsFolder;
				
				TweenService.Create(piece, tweenTypes.linear.medium, { Transparency: 1 }).Play();
				Debris.AddItem(piece, tweenTypes.linear.medium.Time);
			}
		}
	}
	
	if (!isOnlyEffect) otherPart.LocalTransparencyModifier = 1;
	waitUntil(() => cube && cube.Position.sub(otherPart.GetClosestPointOnSurface(cube.Position)).Magnitude > 25, 14);
	
	if (!isOnlyEffect) {
		const partId = getPartId(otherPart);
		const dataString = string.format('respawn,%s', partId);
		Events.MakeReplayEvent.Fire(dataString);
		
		otherPart.SetAttribute('CAN_BREAK', false);
		TweenService.Create(otherPart, tweenTypes.linear.short, { LocalTransparencyModifier: 0 }).Play();
		for (const descendant of otherPart.GetDescendants()) {
			if (descendant.IsA('BasePart')) {
				TweenService.Create(descendant, tweenTypes.linear.short, { LocalTransparencyModifier: 0 }).Play();
			} else if (descendant.IsA('Decal') || descendant.IsA('Texture')) {
				TweenService.Create(descendant, tweenTypes.linear.short, { Transparency: 0 }).Play();
			}
		}
		
		task.wait(tweenTypes.linear.short.Time);
		otherPart.CanCollide = true;
		otherPart.SetAttribute('CAN_BREAK', true);
	}
}

function shatterPart(otherPart: BasePart, head: BasePart, isOnlyEffect: boolean = false) {
	let thickness = 0.5;
	if (isOnlyEffect) thickness = 0.001;
	
	if (!isOnlyEffect) {
		otherPart.CanCollide = false;
		otherPart.LocalTransparencyModifier = 0.75;
		for (const descendant of otherPart.GetDescendants()) {
			if (descendant.IsA('BasePart')) {
				descendant.LocalTransparencyModifier = 1;
			} else if (descendant.IsA('Decal') || descendant.IsA('Texture')) {
				descendant.Transparency = 1;
			}
		}
		
		playSound('shatter', { PlaybackSpeed: randomFloat(0.9, 1) });
	}
	
	if (getSetting(GameSetting.CSG)) {
		const model = new Instance('Model');
		otherPart.Clone().Parent = model;
		const [ _, boundingBox ] = model.GetBoundingBox();
		model.Destroy();
		
		const closestPoint = otherPart.GetClosestPointOnSurface(head.Position);
		const maxSize = math.max(boundingBox.X, boundingBox.Y, boundingBox.Z);
		const flingVector = new Vector3(0, 30, 0);
		
		if (otherPart.IsA('UnionOperation')) {
			const piece = otherPart.Clone();
			piece.Anchored = false;
			piece.CanCollide = true;
			piece.CollisionGroup = 'debris';
			piece.AssemblyLinearVelocity = piece.GetClosestPointOnSurface(closestPoint).sub(closestPoint).Unit.mul(10).add(flingVector);
			piece.AssemblyAngularVelocity = randomDirection();
			piece.Parent = effectsFolder;
			
			TweenService.Create(piece, tweenTypes.linear.medium, { Transparency: 1 }).Play();
			Debris.AddItem(piece, tweenTypes.linear.medium.Time);
		} else {
			const slicers: BasePart[] = [  ];
			
			for (const i of $range(1, 6)) {
				const plane = new Instance('Part');
				plane.CanCollide = false;
				plane.Anchored = true;
				plane.Transparency = 1;
				plane.CFrame = CFrame.lookAlong(closestPoint, randomDirection());
				plane.Size = new Vector3(thickness, maxSize * 3, maxSize * 3);
				plane.Parent = effectsFolder;
				slicers.push(plane);
			}
			
			for (const i of $range(1, 3)) {
				const plane = new Instance('Part');
				plane.CanCollide = false;
				plane.Anchored = true;
				plane.Transparency = 1;
				plane.CFrame = CFrame.lookAlong(otherPart.Position.add(randomDirection(boundingBox.div(2))), randomDirection());
				plane.Size = new Vector3(thickness, maxSize * 3, maxSize * 3);
				plane.Parent = effectsFolder;
				slicers.push(plane);
			}
			
			const pieces = GeometryService.SubtractAsync(otherPart, slicers, subtractOptions) as PartOperation[];
			for (const piece of pieces) {
				piece.Anchored = false;
				piece.CanCollide = true;
				piece.CollisionGroup = 'debris';
				piece.AssemblyLinearVelocity = piece.GetClosestPointOnSurface(closestPoint).sub(closestPoint).Unit.mul(10).add(flingVector);
				piece.AssemblyAngularVelocity = randomDirection();
				piece.Parent = effectsFolder;
				
				TweenService.Create(piece, tweenTypes.linear.medium, { Transparency: 1 }).Play();
				Debris.AddItem(piece, tweenTypes.linear.medium.Time);
			}
		}
	}
	
	if (!isOnlyEffect) otherPart.LocalTransparencyModifier = 1;
	waitUntil(() => cube && cube.Position.sub(otherPart.GetClosestPointOnSurface(cube.Position)).Magnitude > 25, 14);
	
	if (!isOnlyEffect) {
		const partId = getPartId(otherPart);
		const dataString = string.format('respawn,%s', partId);
		Events.MakeReplayEvent.Fire(dataString);
		
		otherPart.SetAttribute('CAN_SHATTER', false);
		TweenService.Create(otherPart, tweenTypes.linear.short, { LocalTransparencyModifier: 0 }).Play();
		for (const descendant of otherPart.GetDescendants()) {
			if (descendant.IsA('BasePart')) {
				TweenService.Create(descendant, tweenTypes.linear.short, { LocalTransparencyModifier: 0 }).Play();
			} else if (descendant.IsA('Decal') || descendant.IsA('Texture')) {
				TweenService.Create(descendant, tweenTypes.linear.short, { Transparency: 0 }).Play();
			}
		}
		
		task.wait(tweenTypes.linear.short.Time);
		otherPart.CanCollide = true;
		otherPart.SetAttribute('CAN_SHATTER', true);
	}
}

function newMapObject(object: Instance) {
	if (object.IsA('BasePart')) {
		object.AttributeChanged.Connect((attr) => {
			if (!head) return;
			
			if (attr === 'FORCE_BREAK' && object.GetAttribute(attr)) {
				object.SetAttribute(attr, undefined);
				breakPart(object, head);
			} else if (attr === 'FORCE_SHATTER' && object.GetAttribute(attr)) {
				object.SetAttribute(attr, undefined);
				shatterPart(object, head);
			}
		});
	}
}

function newPart(part: Instance) {
	if (!part.GetAttribute('isCube') || part.GetAttribute('processed') || !part.IsA('BasePart')) return;
	
	part.SetAttribute('processed', true);
	
	$print(`Cube added: ${part.Name} (Client: cube${player.UserId})`);
	
	StrokeScale.ScaleBillboardGui(part.WaitForChild('OverheadGUI') as BillboardGui, 950);
	
	if (!isClientCube(part)) return;
	
	$print('> Client cube respawned');
	
	cube = part;
	head = cube.WaitForChild('Head') as BasePart;
	
	head.Touched.Connect((otherPart: BasePart) => {
		if (!head || !cube) return;
		
		if (debounce || !otherPart || !otherPart.CanCollide || otherPart.GetAttribute('notCollidable') || (cube.GetAttribute('ragdollTime') ?? 0) !== 0) return;
		
		RunService.Stepped.Wait();
		
		const hammerTexture = getHammerTexture();
		
		const otherVelocity = otherPart.AssemblyLinearVelocity;
		const minSpeed = 175;
		
		if (otherPart.IsDescendantOf(mapFolder)) {
			let newVelocity = currentVelocity.sub(otherVelocity).sub(cube.AssemblyLinearVelocity).div(4).Magnitude;
			if (player.GetAttribute('ERROR_LAND')) newVelocity *= 2;
			if (hammerTexture === Accessories.HammerTexture.SteelHammer && getSetting(GameSetting.Modifiers)) newVelocity *= 1.5;
			
			if (newVelocity > 165) {
				if (otherPart.Material !== Enum.Material.DiamondPlate) {
					Events.DestroyedPart.FireServer(otherPart);
					
					const partId = getPartId(otherPart);
					let dataString: string | undefined = undefined;
					
					const removeBreaks = hammerTexture === Accessories.HammerTexture.SteelHammer && getSetting(GameSetting.Modifiers)
					const canBreak = otherPart.GetAttribute('CAN_BREAK');
					const canShatter = otherPart.GetAttribute('CAN_SHATTER');
					if (canBreak && !removeBreaks) {
						task.spawn(breakPart, otherPart, head);
						dataString = string.format('break,%s', partId);
					} else if (canShatter && !removeBreaks) {
						task.spawn(shatterPart, otherPart, head);
						dataString = string.format('shatter,%s', partId);
					} else {
						const velocity = head.AssemblyLinearVelocity;
						const position = otherPart.GetClosestPointOnSurface(head.Position);
						createDebris(velocity, position, otherPart, 1, true);
						
						dataString = string.format(
							'destroy,%d,%d,%d,%d,%d,%d,%s',
							math.round(position.X * 1000),
							math.round(position.Y * 1000),
							math.round(position.Z * 1000),
							math.round(velocity.X * 1000),
							math.round(velocity.Y * 1000),
							math.round(velocity.Z * 1000),
							partId
						);
					}
					
					if (dataString) Events.MakeReplayEvent.Fire(dataString);
					
					if (hammerTexture === Accessories.HammerTexture.Hammer404 && getSetting(GameSetting.Effects)) {
						const params = new RaycastParams();
						params.FilterType = Enum.RaycastFilterType.Include;
						params.FilterDescendantsInstances = [ otherPart ];
						
						const result = Workspace.Raycast(head.Position, otherPart.Position.sub(head.Position), params);
						if (result) {
							const normal = normalToFace(result.Normal, otherPart);
							if (normal) {
								const texture = new Instance('Texture');
								texture.Texture = 'rbxassetid://9994130132';
								texture.Face = normal;
								texture.Name = 'ERROR_TEXTURE';
								texture.Parent = otherPart;
								
								task.spawn(() => {
									let currentTime = getTime();
									
									const startTime = currentTime;
									const endTime = startTime + 1;
									while (currentTime < endTime) {
										currentTime = getTime();
										
										const totalTime = currentTime - startTime;
										texture.Transparency = math.clamp(totalTime * 2, 0, 1);
										
										texture.OffsetStudsU = math.random() * 2 - 1;
										texture.OffsetStudsV = math.random() * 2 - 1;
										
										RunService.RenderStepped.Wait();
									}
									
									texture.Destroy();
								});
							}
						}
					} else if (hammerTexture === Accessories.HammerTexture.SteelHammer && getSetting(GameSetting.Modifiers) && !otherPart.IsA('UnionOperation')) {
						if (geometryDebounce || otherPart.Size.Magnitude > 750) return;
						
						geometryDebounce = true;
						
						const area = new Instance('Part');
						area.Size = Vector3.one.mul(9);
						area.Position = head.Position;
						area.Shape = Enum.PartType.Ball;
						area.Color = otherPart.Color;
						
						const params = new OverlapParams();
						params.FilterType = Enum.RaycastFilterType.Include;
						params.FilterDescendantsInstances = [ mapFolder ];
						
						const options = {
							SplitApart: false,
							CollisionFidelity: Enum.CollisionFidelity.PreciseConvexDecomposition
						}
						
						const subtractedPart = (GeometryService.SubtractAsync(otherPart, [ area ], options) as PartOperation[])[1] as (PartOperation | undefined);
						if (subtractedPart) {
							subtractedPart.Anchored = false;
							subtractedPart.SetAttribute('steelHammered', true);
							subtractedPart.Parent = otherPart.Parent;
							
							const weld = new Instance('Weld');
							weld.Part0 = subtractedPart;
							weld.Part1 = otherPart;
							
							if (otherPart.IsA('PartOperation') && otherPart.GetAttribute('steelHammered')) {
								const original = otherPart.FindFirstChild('original') as (ObjectValue | undefined);
								if (!original) {
									subtractedPart.Destroy();
									return;
								}
								
								original.Parent = subtractedPart;
								otherPart.Destroy();
								
								weld.Part1 = original.Value as BasePart;
							} else {
								const objectValue = new Instance('ObjectValue');
								objectValue.Name = 'original';
								objectValue.Value = otherPart;
								objectValue.Parent = subtractedPart;
								
								otherPart.Transparency = 1;
								otherPart.CanCollide = false;
								otherPart.SetAttribute('broken', true);
							}
							
							weld.Parent = subtractedPart;
							
							task.delay(15, () => {
								const value = subtractedPart.FindFirstChild('original') as (ObjectValue | undefined);
								if (subtractedPart.Parent && value?.Value?.GetAttribute('broken')) {
									const originalPart = value.Value as BasePart;
									originalPart.SetAttribute('broken', undefined);
									originalPart.Transparency = 0;
									originalPart.CanCollide = true;
									
									subtractedPart.Destroy();
								}
							})
							
							area.Destroy();
							geometryDebounce = false;
						} else {
							otherPart.Transparency = 1;
							otherPart.CanCollide = false;
							otherPart.SetAttribute('broken', true);
							task.delay(15, () => {
								otherPart.SetAttribute('broken', undefined);
								otherPart.Transparency = 0;
								otherPart.CanCollide = true;
							});
							geometryDebounce = false;
						}
					} else if (hammerTexture === Accessories.HammerTexture.IcyHammer && getSetting(GameSetting.Modifiers)) {
						const arm = cube.FindFirstChild('Arm') as (BasePart | undefined);
						const trail = head.FindFirstChild('Trail') as (Trail | undefined);
						if (!arm || !trail || cube.GetAttribute('shatteredHammer')) return;
						
						arm.CanCollide = false;
						head.CanCollide = false;
						trail.Enabled = false;
						canMove.Value = false;
						
						cube.SetAttribute('shatteredHammer', true);
						cube.SetAttribute('hammerTransparency', 1);
						cube.SetAttribute('instantHammerTransparent', 1);
						
						task.spawn(shatterPart, arm, head, true);
						task.spawn(shatterPart, head, head, true);
						
						task.delay(5, () => {
							canMove.Value = true;
							if (!cube?.Parent || !head || !arm || !trail) return;
							
							if (getHammerTexture() === Accessories.HammerTexture.IcyHammer) cube.SetAttribute('hammerTransparency', 0.25);
							else cube.SetAttribute('hammerTransparency', undefined);
							
							cube.SetAttribute('shatteredHammer', undefined);
							
							arm.CFrame = cube.CFrame;
							head.CanCollide = true;
							trail.Enabled = true;
						});
					}
				} else {
					const headVelocity = head.AssemblyLinearVelocity;
					
					const point = otherPart.GetClosestPointOnSurface(head.Position);
					const normal = otherPart.Position.sub(head.Position).Unit;
					
					if (getSetting(GameSetting.Effects)) {
						const sparkTemplate = ReplicatedStorage.FindFirstChild('Particles')?.FindFirstChild('spark') as (BasePart | undefined);
						if (sparkTemplate) {
							const circle = new Instance('Part');
							circle.CanCollide = false;
							circle.CFrame = CFrame.lookAlong(point, normal).mul(CFrame.fromOrientation(0, math.pi / 2, 0));
							circle.Size = new Vector3(0.001, 1, 1);
							circle.Shape = Enum.PartType.Cylinder;
							circle.Color = Color3.fromRGB(0, 0, 0);
							circle.Transparency = 0.5;
							circle.TopSurface = Enum.SurfaceType.Smooth;
							circle.BottomSurface = Enum.SurfaceType.Smooth;
							circle.Parent = effectsFolder;
							
							const spark = sparkTemplate.Clone();
							spark.CFrame = CFrame.lookAlong(point, headVelocity.Unit.mul(-1));
							spark.Parent = effectsFolder;
							
							const particleEmitter = spark.FindFirstChild('ParticleEmitter') as ParticleEmitter;
							task.delay(0.15, () => particleEmitter.Enabled = false);
							
							Debris.AddItem(spark, 5);
						}
					}
					
					const dataString = string.format(
						'spark,%d,%d,,,%d,%d,,',
						math.round(point.X * 1000),
						math.round(point.Y * 1000),
						math.round(headVelocity.X * 1000),
						math.round(headVelocity.Y * 1000)
					);
					
					Events.MakeReplayEvent.Fire(dataString);
					
					playSound('hit1', { PlaybackSpeed: randomFloat(0.7, 0.8), Volume: headVelocity.Magnitude / 15 }, true);
				}
				
				shakeIntensity.Value = math.clamp(head.AssemblyLinearVelocity.Magnitude / 45, 0.5, 1);
				if (hammerTexture === Accessories.HammerTexture.ExplosiveHammer) {
					if (getSetting(GameSetting.Modifiers)) cube.AssemblyLinearVelocity = cube.AssemblyLinearVelocity.add(cube.Position.sub(head.Position).Unit.mul(250));
					
					if (getSetting(GameSetting.Effects)) {
						createDebris(head.AssemblyLinearVelocity.mul(10), head.Position, otherPart, 2.5);
						
						const explosion = new Instance('Explosion');
						explosion.Position = head.Position;
						explosion.BlastRadius = 0;
						explosion.BlastPressure = 0;
						explosion.Parent = effectsFolder;
						
						const dataString = string.format(
							'explosion,%d,%d,%d',
							math.round(head.Position.X * 1000),
							math.round(head.Position.Y * 1000),
							math.round(head.Position.Z * 1000),
							math.round((head.AssemblyLinearVelocity.Magnitude / 5) * 1000)
						);
						
						Events.MakeReplayEvent.Fire(dataString);
					}
					
					playSound('explosion', { PlaybackSpeed: randomFloat(0.9, 1), Volume: head.AssemblyLinearVelocity.Magnitude / 5 }, true);
					shakeIntensity.Value = 2;
				}
			} else if (newVelocity > 50) {
				const point = otherPart.GetClosestPointOnSurface(head.Position);
				const normal = otherPart.Position.sub(head.Position);
				
				const headVelocity = head.AssemblyLinearVelocity;
				const unitVelocity = headVelocity.Unit;
				
				if (getSetting(GameSetting.Effects)) {
					const sparkTemplate = ReplicatedStorage.FindFirstChild('Particles')?.FindFirstChild('spark') as (BasePart | undefined);
					if (sparkTemplate) {
						const spark = sparkTemplate.Clone();
						spark.CFrame = CFrame.lookAlong(point, unitVelocity.mul(-1));
						spark.Parent = effectsFolder;
						Debris.AddItem(spark, 5);
						
						const particleEmitter = spark.FindFirstChild('ParticleEmitter') as ParticleEmitter;
						task.delay(0.1, () => particleEmitter.Enabled = false);
					}
				}
				
				const dataString = string.format(
					'spark,%d,%d,,%d,%d,',
					math.round(point.X * 1000),
					math.round(point.Y * 1000),
					math.round(headVelocity.X * 1000),
					math.round(headVelocity.Y * 1000)
				);
				
				Events.MakeReplayEvent.Fire(dataString);
				
				playSound('hit1', { PlaybackSpeed: randomFloat(0.9, 1), Volume: headVelocity.Magnitude / 30 }, true);
			}
			
			debounce = true;
			task.delay(0.25, () => debounce = false);
		} else if (otherPart.IsDescendantOf(nonBreakable)) {
			let newVelocity = currentVelocity.sub(otherVelocity).Magnitude;
			if (player.GetAttribute('ERROR_LAND')) newVelocity *= 2;
			
			if (newVelocity > 50) playSound('fabric_hit', { PlaybackSpeed: randomFloat(0.9, 1), Volume: head.AssemblyLinearVelocity.Magnitude / 30 });
			
			debounce = true;
			task.delay(0.25, () => debounce = false);
		}
	});
}

Events.BreakPart.Event.Connect(breakPart);
Events.ShatterPart.Event.Connect(shatterPart);
Events.ClientCreateDebris.Event.Connect(createDebris);

for (const descendant of mapFolder.GetDescendants()) {
	newMapObject(descendant);
}
mapFolder.DescendantAdded.Connect(newMapObject);

for (const part of Workspace.GetChildren()) {
	task.spawn(newPart, part);
}
Workspace.ChildAdded.Connect(newPart);

RunService.Stepped.Connect((_, dt) => {
	if (!head || !cube) return;
	
	let targetCube = cube;
	if (isSpectating.Value) {
		const otherPlayer = Players.FindFirstChild(spectatePlayer.Value) as (Player | undefined);
		if (otherPlayer) targetCube = Workspace.FindFirstChild(`cube${otherPlayer.UserId}`) as (BasePart | undefined) ?? targetCube;
	}
	
	targetCube = Workspace.FindFirstChild('REPLAY_VIEW') as (BasePart | undefined) ?? targetCube;
	
	if (!player.GetAttribute('ERROR_LAND')) {
		Workspace.SetAttribute('default_gravity', 196.2);
		
		let targetTime = 14.5;
		
		const [ altitude ] = convertStudsToMeters(targetCube.Position.Y - 1.9);
		if (altitude < 100) targetTime = 14.5;
		else if (altitude < 200) targetTime = 6.4;
		else if (altitude < 300) targetTime = 12;
		else if (altitude < 400) targetTime = 5;
		else if (altitude < 500) targetTime = 3;
		else {
			const percent = math.clamp((altitude - 700) / 100, -1, 1);
			targetTime += 9.5 * (percent + 1) / 2;
			
			Workspace.SetAttribute('default_Gravity', 88.1 * (1 - percent) + 20);
		}
		
		Lighting.ClockTime = numLerp(Lighting.ClockTime, targetTime, dt * 2);
	}
	
	const velocity = targetCube.AssemblyLinearVelocity;
	if (!player.GetAttribute('in_main_menu') && screenGui.Enabled) {
		camera.FieldOfView = 70 + math.max(velocity.Magnitude - 100, 0) / 5;
		
		const percent = getSetting(GameSetting.Sounds) ? math.max((velocity.Magnitude - 100) / 300, 0) : 0;
		wind.Volume = percent * 3;
	}
	
	lastVelocity = currentVelocity;
	currentVelocity = head.AssemblyLinearVelocity;
	
	const previousVelocity = cube.GetAttribute('lastVelocity');
	if (typeIs(previousVelocity, 'Vector3')) {
		const relativeVelocity = cube.AssemblyLinearVelocity.sub(lastVelocity);
		
		if (relativeVelocity.Magnitude > 300) {
			Events.GroundImpact.FireServer(relativeVelocity, cube.Position);
			
			if (getSetting(GameSetting.Effects)) {
				createDebris(relativeVelocity.mul(3.5), cube.Position, cube, 6);
				
				const explosion = new Instance('Explosion');
				explosion.Position = cube.Position;
				explosion.BlastRadius = 0;
				explosion.BlastPressure = 0;
				explosion.Parent = effectsFolder;
				
				const dataString = string.format(
					'explosion,%d,%d,,%d',
					math.round(cube.Position.X * 1000),
					math.round(cube.Position.Y * 1000),
					math.round((cube.AssemblyLinearVelocity.Magnitude / 10) * 1000)
				);
				
				Events.MakeReplayEvent.Fire(dataString);
				
				const params = new RaycastParams();
				params.FilterType = Enum.RaycastFilterType.Include;
				params.FilterDescendantsInstances = [ mapFolder ];
				
				const createdParts: BasePart[] = [  ];
				const Info = new TweenInfo(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
				
				const radius = 10 * (relativeVelocity.Magnitude / 300);
				const debrisSize = Vector3.one.mul(6 * math.sqrt(radius / 10));
				const step = (debrisSize.Magnitude / radius) * 35;
				for (const angle of $range(0, 360, step)) {
					const radians = math.rad(angle);
					const axis = CFrame.fromAxisAngle(relativeVelocity.Unit, radians);
					const relativePosition = axis.mul(new CFrame(radius, 0, 0)).Position;
					
					const result = Workspace.Raycast(cube.Position.add(relativePosition), relativeVelocity.mul(-4), params);
					if (result) {
						const part = new Instance('Part');
						part.Anchored = true;
						part.CanCollide = false;
						part.Size = Vector3.zero;
						part.CFrame = CFrame.lookAlong(result.Position, randomDirection());
						part.Material = result.Material;
						part.Color = result.Instance.Color;
						part.TopSurface = Enum.SurfaceType.Smooth;
						part.BottomSurface = Enum.SurfaceType.Smooth;
						part.Parent = effectsFolder;
						
						TweenService.Create(part, Info, { Size: debrisSize }).Play()
						createdParts.push(part);
					}
				}
				
				task.delay(Info.Time + 5, () => {
					const OuterInfo = new TweenInfo(math.min(relativeVelocity.Magnitude / 30, 10), Enum.EasingStyle.Linear);
					for (const part of createdParts) {
						TweenService.Create(part, OuterInfo, { Size: Vector3.zero, Transparency: 1 }).Play();
						Debris.AddItem(part, Info.Time);
					}
				});
			}
			
			Events.ClientRagdoll.Fire(1.4);
			shakeIntensity.Value = 4;
			playSound('explosion', { PlaybackSpeed: randomFloat(0.9, 1), Volume: cube.AssemblyLinearVelocity.Magnitude / 10 });
		} else if (relativeVelocity.Magnitude > 165) {
			Events.GroundImpact.FireServer(relativeVelocity, cube.Position);
			
			if (getSetting(GameSetting.Effects)) {
				createDebris(cube.AssemblyLinearVelocity.mul(3.5), cube.Position, cube, 6);
				
				const explosion = new Instance('Explosion');
				explosion.Position = cube.Position;
				explosion.BlastRadius = 0;
				explosion.BlastPressure = 0;
				explosion.Parent = effectsFolder;
				
				const dataString = string.format(
					'explosion,%d,%d,,%d',
					math.round(cube.Position.X * 1000),
					math.round(cube.Position.Y * 1000),
					math.round((cube.AssemblyLinearVelocity.Magnitude / 10) * 1000)
				)
				
				Events.MakeReplayEvent.Fire(dataString);
			}
			
			Events.ClientRagdoll.Fire(1.4);
			shakeIntensity.Value = 4;
			playSound('explosion', { PlaybackSpeed: randomFloat(0.9, 1), Volume: cube.AssemblyLinearVelocity.Magnitude / 10 });
		}
	}
	
	for (const part of CollectionService.GetTagged('ErrorEffects')) {
		if (part.IsA('BasePart')) {
			part.Color = math.random() < 0.5 ? Color3.fromRGB(0, 0, 0) : Color3.fromRGB(255, 0, 255);
			part.Size = randomDirection().add(new Vector3(0.5, 0.5, 0.5));
		}
	}
	
	prevCubePosition = cube.Position;
	cube.SetAttribute('lastVelocity', cube.AssemblyLinearVelocity);
});

$print('Started running visual_effects.client.ts')

while (task.wait(0.05)) {
	speedIndex = (speedIndex + 1) % speedImages.size();
	speedLines.Image = speedImages[speedIndex];
	
	if (!cube) continue;
	
	let targetCube = cube as BasePart;
	if (isSpectating.Value) {
		const otherPlayer = Players.FindFirstChild(spectatePlayer.Value) as (Player | undefined);
		if (otherPlayer) targetCube = Workspace.FindFirstChild(`cube{otherPlayer.UserId}`) as BasePart ?? targetCube;
	}
	
	targetCube = Workspace.FindFirstChild('REPLAY_VIEW') as BasePart ?? targetCube;
	
	if (targetCube) {
		const fieldOfView = 70 + math.max(targetCube.AssemblyLinearVelocity.Magnitude - 100, 0) / 5;
		const size = math.clamp((110 - fieldOfView) / 10, 1, 6);
		speedLines.Size = UDim2.fromScale(size, size);
		speedLines.Visible = true;
	}
}