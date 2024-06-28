import { DataStoreService, ReplicatedStorage, RunService } from '@rbxts/services';

import { computeNameColor, getHammerTexture, Accessories, getCubeAura, getCubeHat, giveBadge } from './utils';

import { $print, $warn } from 'rbxts-transform-debug';

export type AccessoryData = {
	acc_type: Accessories.Type;
	icon: string;
	badge_id: number;
	badge_name: string;
	always_show: boolean;
	data: string | number | Instance;
	description: string;
	modifier: boolean;
	never?: boolean;

	spritesheet_data?: {
		tileWidth: number;
		tileHeight: number;
		rows: number;
		columns: number;
		loopDelay: number;
		fps: number;
	};

	copy_cube_color?: boolean;
};

export const accessoryList = require(ReplicatedStorage.WaitForChild('Modules')?.WaitForChild('Accessories') as ModuleScript) as Record<string, AccessoryData>;

function emptyFunction() {
	return emptyFunction;
}

export const hammerFunctions: Record<string, (cube: BasePart, player: Player) => () => any> = {
	error: emptyFunction,
	golden: (cube: BasePart, _) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.Color = Color3.fromRGB(255, 255, 128);
		arm.Material = Enum.Material.Foil;
		head.Color = Color3.fromRGB(255, 255, 128);
		head.Material = Enum.Material.Foil;

		return () => {
			if (!arm || !head) return;
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	explosive: (cube: BasePart, _) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.BrickColor = new BrickColor('Medium stone grey');
		arm.Material = Enum.Material.DiamondPlate;
		head.BrickColor = new BrickColor('Really red');
		head.Material = Enum.Material.Neon;

		return () => {
			if (!arm || !head) return;
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	steelhammer: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.Color = Color3.fromRGB(65, 62, 64);
		arm.Material = Enum.Material.DiamondPlate;
		head.Color = Color3.fromRGB(99, 95, 98);
		head.Material = Enum.Material.DiamondPlate;

		return () => {
			if (!arm || !head) return;
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	inverterhammer: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.Color = Color3.fromRGB(7, 114, 172);
		arm.Material = Enum.Material.Neon;
		head.Material = Enum.Material.DiamondPlate;

		return () => {
			if (!arm || !head) return;
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.Material = Enum.Material.Plastic;
		};
	},
	long: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const connector = cube.FindFirstChild('Head')?.FindFirstChild('ConnectionAttachment');
		if (!arm?.IsA('BasePart') || !connector?.IsA('Attachment')) return emptyFunction;

		connector.CFrame = connector.CFrame.mul(new CFrame(0, -11.5, 0));
		arm.Size = new Vector3(30, 0.75, 0.75);

		return () => {
			if (!arm || !connector) return;
			connector.CFrame = connector.CFrame.mul(new CFrame(0, 11.5, 0));
			arm.Size = new Vector3(6.5, 0.75, 0.75);
		};
	},
	ice: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		cube.SetAttribute('hammerTransparency', 0.25);

		arm.Color = Color3.fromRGB(36, 116, 220);
		arm.Material = Enum.Material.Glass;
		arm.Transparency = 0.25;
		head.Color = Color3.fromRGB(52, 194, 255);
		head.Material = Enum.Material.Glass;
		head.Transparency = 0.25;

		return () => {
			cube.SetAttribute('hammerTransparency', undefined);

			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			arm.Transparency = 0;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
			head.Transparency = 0;
		};
	},

	_God: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.Color = Color3.fromRGB(255, 255, 255);
		arm.Material = Enum.Material.Neon;
		head.Color = Color3.fromRGB(255, 255, 255);
		head.Material = Enum.Material.Neon;

		const particles = ReplicatedStorage.FindFirstChild('Particles')?.FindFirstChild('Lighting')?.Clone() as ParticleEmitter;
		particles.Parent = arm;

		return () => {
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;

			particles.Destroy();
		};
	},
	_realgold: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.Color = Color3.fromRGB(255, 255, 128);
		arm.Material = Enum.Material.Metal;
		head.Color = Color3.fromRGB(255, 255, 128);
		head.Material = Enum.Material.Metal;

		return () => {
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	_mallet: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		const connector = head?.FindFirstChild('ConnectionAttachment');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart') || !connector?.IsA('Attachment')) return emptyFunction;

		connector.CFrame = connector.CFrame.mul(new CFrame(0, 1.5, 0));
		arm.Size = new Vector3(5, 0.75, 0.75);

		arm.Material = Enum.Material.DiamondPlate;
		arm.Color = Color3.fromRGB(255, 255, 128);
		head.Material = Enum.Material.DiamondPlate;
		head.BrickColor = new BrickColor('Dark stone grey');

		return () => {
			connector.CFrame = connector.CFrame.mul(new CFrame(0, -1.5, 0));
			arm.Size = new Vector3(6.5, 0.75, 0.75);

			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	_platform: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		const physicalProperties = arm.CurrentPhysicalProperties;
		arm.Size = new Vector3(0.001, 0.001, 0.001);
		head.CustomPhysicalProperties = new PhysicalProperties(0.2, 1.3, physicalProperties.Elasticity);
		head.Size = new Vector3(1.75, 7.5, 1);
		head.CollisionGroup = 'Default';

		const textures: Texture[] = [];
		for (const side of Enum.NormalId.GetEnumItems()) {
			const texture = new Instance('Texture');
			texture.Face = side;
			texture.Texture = 'rbxassetid://6028276525';
			texture.Parent = head;
			textures.push(texture);
		}

		return () => {
			arm.Size = new Vector3(6.5, 0.75, 0.75);
			head.CustomPhysicalProperties = physicalProperties;
			head.Size = new Vector3(1.75, 2.75, 1);
			head.CollisionGroup = 'cubes';

			for (const texture of textures) texture.Destroy();
		};
	},
	_build: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.Color = new Color3(1, 1, 0.5);
		head.Color = new Color3(0.1, 0.1, 0.1);
		head.Material = Enum.Material.DiamondPlate;

		return () => {
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	_grapple: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.BrickColor = new BrickColor('Black');
		arm.Material = Enum.Material.DiamondPlate;
		head.BrickColor = new BrickColor('Really black');
		head.Material = Enum.Material.DiamondPlate;

		return () => {
			arm.BrickColor = new BrickColor('Brown');
			arm.Material = Enum.Material.Plastic;
			head.BrickColor = new BrickColor('Dark stone grey');
			head.Material = Enum.Material.Plastic;
		};
	},
	_shotgun: (cube: BasePart, player: Player) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		const trail = head.FindFirstChild('Trail') as Trail;

		arm.Transparency = 1;
		head.CanCollide = false;
		head.Transparency = 1;
		trail.Enabled = false;

		const shotgun = ReplicatedStorage.FindFirstChild('Shotgun')?.Clone() as Model;
		shotgun.Parent = cube;
		if (RunService.IsServer()) {
			for (const part of shotgun.GetDescendants()) {
				if (part.IsA('BasePart')) part.SetNetworkOwner(player);
			}
		}

		const weld = new Instance('Weld');
		weld.Part0 = shotgun.FindFirstChild('Handle') as BasePart;
		weld.Part1 = arm;
		weld.C0 = CFrame.fromOrientation(0, math.rad(90), 0);
		weld.Parent = shotgun;

		return () => {
			shotgun.Destroy();

			arm.Transparency = 0;
			head.CanCollide = true;
			head.Transparency = 0;
			trail.Enabled = true;
		};
	},
	_spring: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		arm.BrickColor = new BrickColor('Black');
		head.BrickColor = new BrickColor('Bright blue');

		const attachment = new Instance('Attachment');
		attachment.CFrame = new CFrame(-3, 0, 0);
		attachment.Parent = arm;

		const spring = new Instance('SpringConstraint');
		spring.Attachment0 = attachment;
		spring.Attachment1 = (head.FindFirstChild('ConnectionAttachment') as Attachment | undefined) ?? attachment;
		spring.MaxForce = 0;
		spring.Visible = true;
		spring.Color = new BrickColor('Bright blue');
		spring.Radius = 0.6;
		spring.Coils = 8;
		spring.Parent = attachment;

		return () => {
			attachment.Destroy();
			arm.BrickColor = new BrickColor('Brown');
			head.BrickColor = new BrickColor('Dark stone grey');
		};
	},
	_hitbox: (cube: BasePart) => {
		const arm = cube.FindFirstChild('Arm');
		const head = cube.FindFirstChild('Head');
		if (!arm?.IsA('BasePart') || !head?.IsA('BasePart')) return emptyFunction;

		cube.SetAttribute('hammerTransparency', 1);
		cube.SetAttribute('transparency', 1);
		cube.Transparency = 1;
		arm.Transparency = 1;
		head.Transparency = 1;

		const cubeOutline = new Instance('SelectionBox');
		cubeOutline.Color3 = cube.Color;
		cubeOutline.Adornee = cube;
		cubeOutline.Name = 'CubeOutline';
		cubeOutline.Parent = cube;

		const headOutline = cubeOutline.Clone();
		headOutline.Color3 = head.Color;
		headOutline.Adornee = head;
		headOutline.Name = 'HeadOutline';
		headOutline.Parent = head;

		const armOutline = cubeOutline.Clone();
		armOutline.Color3 = arm.Color;
		armOutline.Adornee = arm;
		armOutline.Name = 'ArmOutline';
		armOutline.Parent = arm;

		return () => {
			cube.SetAttribute('hammerTransparency', 0);
			cube.SetAttribute('transparency', 0);
			cube.Transparency = 0;
			arm.Transparency = 0;
			head.Transparency = 0;

			cubeOutline.Destroy();
			headOutline.Destroy();
			armOutline.Destroy();
		};
	},
};

export function loadAccessories(
	cube: BasePart,
	data: { face?: string; hammer?: string; hat?: string; aura?: string },
	player: Player | undefined,
	hammerRemoveFunction: (() => void) | undefined,
) {
	const { face, hammer, hat, aura } = data;

	if (typeIs(face, 'string')) {
		const accessoryData = accessoryList[face];
		if (typeIs(accessoryData?.data, 'string')) {
			const faceDecal = cube.FindFirstChild('Face') as Decal;
			faceDecal.Texture = accessoryData.data;
		}
	}

	const clonedHat = cube.FindFirstChild('CLONED_HAT');
	if (clonedHat) {
		clonedHat.Destroy();
		const accessoryWelder = cube.FindFirstChild('HatAccessory')?.FindFirstChild('AccessoryWelder') as RigidConstraint;
		if (accessoryWelder) accessoryWelder.Attachment1 = undefined;
	}

	if (typeIs(hat, 'string')) {
		const accessoryData = accessoryList[hat];
		if (accessoryData) {
			const data = accessoryData.data;

			const hatPart = cube.FindFirstChild('HatAccessory') as BasePart;
			hatPart.Transparency = 1;
			hatPart.FindFirstChild('Mesh')?.Destroy();

			if (typeIs(data, 'Instance')) {
				if (data.IsA('BasePart')) {
					if (data.GetAttribute('weldToCube')) {
						const clone = data.Clone();
						clone.PivotTo(cube.CFrame);
						clone.Name = 'CLONED_HAT';
						clone.Parent = cube;

						if (RunService.IsServer() && player) {
							task.delay(0.5, () => {
								while (task.wait()) {
									const [canSet] = clone.CanSetNetworkOwnership();
									if (canSet) break;
								}

								clone.SetNetworkOwner(player);
								for (const descendant of clone.GetDescendants()) {
									if (descendant.IsA('BasePart')) descendant.SetNetworkOwner(player);
								}
							});
						}

						const accessoryWelder = hatPart.FindFirstChild('AccessoryWelder') as RigidConstraint;
						accessoryWelder.Attachment1 = clone.FindFirstChild('HatWeld') as Attachment;
					} else {
						const hatAttachment = hatPart.FindFirstChild('Attachment') as Attachment;
						hatAttachment.CFrame = (data.FindFirstChild('HatAttachment') as Attachment).CFrame;

						hatPart.Transparency = 0;
						hatPart.Size = data.Size;
						hatPart.Color = data.Color;
						hatPart.Material = data.Material;

						if (hat === 'Free Accessory' && RunService.IsServer()) {
							const surfaceGui = data.FindFirstChild('SurfaceGui')?.Clone() as SurfaceGui;
							surfaceGui.Parent = hatPart;

							const clickDetector = new Instance('ClickDetector');
							clickDetector.MaxActivationDistance = math.huge;
							clickDetector.Parent = hatPart;

							const debounce: number[] = [];

							clickDetector.MouseClick.Connect((otherPlayer) => {
								if (otherPlayer === player || debounce.find((userId) => userId === otherPlayer.UserId)) return;

								giveBadge(otherPlayer, 2146357550);

								const userId = otherPlayer.UserId;
								debounce.push(userId);
								task.delay(1, () => {
									const i = debounce.findIndex((otherUserId) => otherUserId === userId);
									if (i >= 0) debounce.remove(i);
								});
							});
						}

						const mesh = data.FindFirstChild('Mesh') as SpecialMesh | undefined;
						if (mesh) mesh.Clone().Parent = hatPart;
					}
				}
			}
		}
	}

	if (typeIs(aura, 'string')) {
		const accessoryData = accessoryList[aura];
		if (accessoryData) {
			const data = accessoryData.data;

			let auraAttachment = cube.FindFirstChild('AuraAttachment') as Attachment | undefined;
			if (!auraAttachment) {
				auraAttachment = new Instance('Attachment');
				auraAttachment.Name = 'AuraAttachment';
				auraAttachment.Parent = cube;
			}

			auraAttachment.ClearAllChildren();
			auraAttachment.Position = Vector3.zero;

			if (typeIs(data, 'Instance')) data.Clone().Parent = auraAttachment;
		}
	}

	if (hammerRemoveFunction !== undefined) {
		try {
			hammerRemoveFunction();
		} catch (err) {}
	}

	if (typeIs(hammer, 'string')) {
		const accessoryData = accessoryList[hammer];
		const data = accessoryData?.data;
		if (accessoryData && typeIs(data, 'string')) {
			const hammerFunction = hammerFunctions[data];
			if (typeIs(data, 'string') && typeIs(hammerFunction, 'function') && player) return hammerFunction(cube, player);
		}
	}

	return undefined;
}

export function reloadAccessories(
	cube: BasePart,
	b: Color3 | Player,
	hatAccessory: string = Accessories.CubeHat.NoHat,
	auraAccessory: string = Accessories.CubeAura.NoAura,
	hammerAccessory: string = Accessories.HammerTexture.NoHammerTexture,
) {
	let cubeColor: Color3;
	if (typeIs(b, 'Instance') && b.IsA('Player')) {
		cubeColor = (b.GetAttribute('CUBE_COLOR') as Color3) ?? computeNameColor(b.Name);
		hatAccessory = getCubeHat(b);
		auraAccessory = getCubeAura(b);
		hammerAccessory = getHammerTexture(b);
	} else cubeColor = b;

	const hat = cube.FindFirstChild('CLONED_HAT') as BasePart | undefined;
	const aura = cube.FindFirstChild('AuraAttachment') as Attachment | undefined;

	try {
		if (hatAccessory === Accessories.CubeHat.InstantGyro && hat?.IsA('BasePart')) hat.Color = new Color3(1 - cubeColor.R, 1 - cubeColor.G, 1 - cubeColor.B);
	} catch (err) {}

	try {
		if (auraAccessory === Accessories.CubeAura.Glow && aura) (aura.FindFirstChild('Glow')?.FindFirstChild('Glow') as ParticleEmitter).Color = new ColorSequence(cubeColor);
	} catch (err) {}

	try {
		if ((hammerAccessory = Accessories.HammerTexture.HitboxHammer)) (cube.FindFirstChild('CubeOutline') as SelectionBox).Color3 = cubeColor;
	} catch (err) {}

	$print(`Updated accessories for ${cube.Name}`);
}
