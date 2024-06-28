import { CollectionService, ReplicatedStorage, BadgeService, HttpService, RunService, Workspace, Players } from '@rbxts/services';

import str from '@rbxts/string-utils';
import { $print, $warn } from 'rbxts-transform-debug';

import * as TextCompression from './lua/text_compression';
import admins from './admins';

const Events = {
	SettingChanged: ReplicatedStorage.WaitForChild('SettingChanged') as BindableEvent,
	MakeReplayEvent: ReplicatedStorage.WaitForChild('MakeReplayEvent') as BindableEvent,
};

const player = Players.LocalPlayer;
const GUI = player?.WaitForChild('PlayerGui') as PlayerGui | undefined;

const forceTestingServer = ReplicatedStorage.WaitForChild('ForceTestingServer') as BoolValue;
const placeId = game.PlaceId;

const RNG = new Random();

export type DictKey = string | number | symbol;
export type DictValue = string | number | symbol;

export namespace GameData {
	export const CreatorId = 156926145;

	export const MainPlaceId = 13458875976;
	export const TestingPlaceId = 17837400665;
}

export namespace PlayerAttributes {
	export const HasDataLoaded = 'DataLoaded';
	export const InErrorLand = 'inErrorLand';
	export const HasModifiers = 'modifiers';
	export const Impacts = 'impacts';
	export const IsNew = 'isNew';

	export const HammerTexture = 'hammer_Texture';
	export const CompletedGame = 'completedGame';
	export const InTutorial = 'inTutorial';
	export const CubeColor = 'cubeColor';
	export const CubeFace = 'cube_Face';
	export const CubeAura = 'cube_Aura';
	export const CubeHat = 'cube_Hat';

	export const TotalModdedWins = 'totalModdedWins';
	export const TotalRagdolls = 'totalRagdolls';
	export const TotalRestarts = 'totalRestarts';
	export const TotalTime = 'totalTime';
	export const TotalWins = 'totalWins';

	export const GravityFlipDebounce = 'gravityFlipDebounce';
	export const BadgeDebounce = 'badgeDebounce';

	export const HasCrashLandingBadge = 'hasCrashLandingBadge';
	export const HasExplosiveBadge = 'hasExplosiveBadge';
	export const HasGravityBadge = 'hasGravityBadge';
	export const HasSpeedBadge = 'hasSpeedBadge';

	export const ActiveQuest = 'activeQuest';
	export const GlowPhase = 'glowPhase';
	export const HasSteelHammer = 'hasSteelHammer';

	export const Device = 'device';

	export enum Client {
		SettingsJSON = 'clientSettingsJSON',
		InMainMenu = 'inMainMenu',
	}
}

export namespace Accessories {
	export type Type = 'hammer_Texture' | 'cube_Hat' | 'cube_Face' | 'cube_Aura';

	export enum HammerTexture {
		NoHammerTexture = 'No Hammer Texture',
		RealGoldenHammer = 'REAL Golden Hammer',
		GoldenHammer = 'Golden Hammer',
		InverterHammer = 'Inverter Hammer',
		BattleAxe = 'Battle Axe',
		BuilderHammer = 'Builder Hammer',
		SpringHammer = 'Spring Hammer',
		Shotgun = 'Shotgun',
		Platform = 'Platform',
		Hammer404 = '404 Hammer',
		HitboxHammer = 'Hitbox Hammer',
		Mallet = 'Mallet',
		GodsHammer = "God's Hammer",
		IcyHammer = 'Icy Hammer',
		ExplosiveHammer = 'Explosive Hammer',
		GrapplingHammer = 'Grappling Hammer',
		SteelHammer = 'Steel Hammer',
		LongHammer = 'Long Hammer',
	}

	export enum CubeHat {
		NoHat = 'No Hat',
		TopHat404 = '404 TopHat',
		PropellerHat = 'Propeller Hat',
		AstronautHelmet = 'Astronaut Helmet',
		Trophy35k = '35k Trophy',
		InstantGyro = 'Instant Gyro',
		Duck = 'Duck',
		PartyHat = 'Party Hat',
		Tophat = 'Tophat',
		FreeAccessory = 'Free Accessory',
	}

	export enum CubeFace {
		DefaultFace = 'Default Face',
		UpsideDown = 'Upside-down',
		Sad = 'Sad',
		Si = 'Si',
		Tsu = 'Tsu',
	}

	export enum CubeAura {
		NoAura = 'No Aura',
		Glow = 'Glow',
		Fire = 'Fire',
	}
}

export enum GameSetting {
	'HideOthers' = 'hideothers',
	'ShowRange' = 'showrange',
	'Effects' = 'effects',
	'ScreenShake' = 'screenshake',
	'Sounds' = 'sounds',
	'Music' = 'music',
	'TimerGUI' = 'timergui',
	'Modifiers' = 'modifiers',
	'CSG' = 'csg',
	'OrthographicView' = 'orthographic',
}

export type BaseSettings = Record<GameSetting, boolean>;

export const Settings: BaseSettings = {
	hideothers: false,
	showrange: false,
	effects: true,
	screenshake: true,
	sounds: true,
	music: true,
	timergui: true,
	modifiers: false,
	csg: true,
	orthographic: false,
};

export const DefaultSettings = table.clone(Settings);

export const tweenTypes = {
	linear: {
		short: new TweenInfo(1, Enum.EasingStyle.Linear),
		medium: new TweenInfo(2.5, Enum.EasingStyle.Linear),
		long: new TweenInfo(5, Enum.EasingStyle.Linear),
	},
	instant: new TweenInfo(0),
};

export const filterFunctions = {
	startsWith: (value: string, _: unknown, pattern: string) => str.startsWith(value, pattern),
};

const settingAlias: Record<GameSetting, string> = {
	[GameSetting.HideOthers]: 'Hide Others',
	[GameSetting.ShowRange]: 'Show Range',
	[GameSetting.Effects]: 'Effects',
	[GameSetting.ScreenShake]: 'Screen Shake',
	[GameSetting.Sounds]: 'Sounds',
	[GameSetting.Music]: 'Music',
	[GameSetting.TimerGUI]: 'Timer GUI',
	[GameSetting.Modifiers]: 'Modifiers',
	[GameSetting.CSG]: 'CSG',
	[GameSetting.OrthographicView]: 'Orthographic View',
};

const settingOrder: Record<GameSetting, number> = {
	[GameSetting.Modifiers]: 1,
	[GameSetting.Music]: 2,
	[GameSetting.Sounds]: 3,
	[GameSetting.Effects]: 4,
	[GameSetting.CSG]: 5,
	[GameSetting.ScreenShake]: 6,
	[GameSetting.ShowRange]: 7,
	[GameSetting.HideOthers]: 8,
	[GameSetting.TimerGUI]: 9,
	[GameSetting.OrthographicView]: 10,
};

export function numLerp(a: number, b: number, t: number) {
	return a + (b - a) * t;
}

export function getPartId(part: BasePart): string {
	const tags = part.GetTags();
	for (const tag of tags) {
		if (str.startsWith(tag, 'mapPart-')) return tag;
	}

	return '';
}

export function getPartFromId(id: string): BasePart | undefined {
	if (!id) return undefined;
	return CollectionService.GetTagged(id)[1] as BasePart;
}

export function getTime(): number {
	return Workspace.GetServerTimeNow();
}

export function roundDecimalPlaces(x: number, decimalPlaces: number = 3): number {
	const multiplier = 10 ^ decimalPlaces;
	return math.round(x * multiplier) / multiplier;
}

export function randomFloat(min: number, max: number): number {
	return math.random() * (max - min) + min;
}

export function randomDirection(length: number | Vector3 = 1) {
	return RNG.NextUnitVector().mul(length);
}

export function waitUntil(callback: () => boolean | undefined, maxTime: number = math.huge): void {
	const startTime = time();
	while (!callback() && time() - startTime < maxTime) task.wait();
}

export function canUseSetting(name: string): boolean {
	if (name === 'modifiers') {
		const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as BasePart | undefined;

		const params = new OverlapParams();
		params.FilterType = Enum.RaycastFilterType.Include;

		const modifierDisablers = Workspace.FindFirstChild('ForceDisableModifiers') as Instance | undefined;
		if (modifierDisablers !== undefined) params.FilterDescendantsInstances = [modifierDisablers];

		const areaCondition = player.GetAttribute(PlayerAttributes.InErrorLand) || player.GetAttribute(PlayerAttributes.InTutorial);
		if (areaCondition || (player && cube && Workspace.GetPartsInPart(cube, params).size() > 0)) return false;
	}

	if (name === 'hideothers' && GUI?.FindFirstChild('ReplayGui') && (GUI.FindFirstChild('ReplayGui') as ScreenGui | undefined)?.Enabled) return true;

	return true;
}

export function getSetting(name: GameSetting): boolean {
	if (!canUseSetting(name)) return false;

	const value = Settings[name];
	if (value === undefined) return DefaultSettings[name];
	return value;
}

export function setSetting(name: GameSetting, value: boolean): void {
	if (!canUseSetting(name)) return;

	Settings[name] = value;
	Events.SettingChanged.Fire(name, value);
}

export function getSettingAlias(name: GameSetting): string {
	return settingAlias[name] ?? name;
}

export function getSettingOrder(name: GameSetting): number {
	return settingOrder[name] ?? -1;
}

export function fixSettings(): void {
	for (const [name, value] of pairs(DefaultSettings)) Settings[name] = Settings[name] ?? value;
}

export function getHammerTexture(player: Player | undefined = undefined): Accessories.HammerTexture {
	if (player === undefined) player = Players.LocalPlayer;

	if (player.GetAttribute(PlayerAttributes.InTutorial)) return Accessories.HammerTexture.NoHammerTexture;
	return (player.GetAttribute(PlayerAttributes.HammerTexture) as Accessories.HammerTexture) ?? Accessories.HammerTexture.NoHammerTexture;
}

export function getCubeFace(player: Player | undefined = undefined): Accessories.CubeFace {
	if (player === undefined) player = Players.LocalPlayer;

	if (player.GetAttribute(PlayerAttributes.InTutorial)) return Accessories.CubeFace.DefaultFace;
	return (player.GetAttribute(PlayerAttributes.CubeFace) as Accessories.CubeFace) ?? Accessories.CubeFace.DefaultFace;
}

export function getCubeHat(player: Player | undefined = undefined): Accessories.CubeHat {
	if (player === undefined) player = Players.LocalPlayer;

	if (player.GetAttribute(PlayerAttributes.InTutorial)) return Accessories.CubeHat.NoHat;
	return (player.GetAttribute(PlayerAttributes.CubeHat) as Accessories.CubeHat) ?? Accessories.CubeHat.NoHat;
}

export function getCubeAura(player: Player | undefined): Accessories.CubeAura {
	if (player === undefined) player = Players.LocalPlayer;

	if (player.GetAttribute(PlayerAttributes.InTutorial)) return Accessories.CubeAura.NoAura;
	return (player.GetAttribute(PlayerAttributes.CubeAura) as Accessories.CubeAura) ?? Accessories.CubeAura.NoAura;
}

export function isClientCube(cube: BasePart | undefined): boolean {
	return cube?.Name === `cube${player.UserId}`;
}

export function playSound(name: string, properties: Record<string, DictValue> = {}, ignoreReplay: boolean = false): void {
	if (!getSetting(GameSetting.Sounds)) properties.Volume = 0;

	let dataString = `sound,${name}`;

	const sound = ReplicatedStorage.FindFirstChild('SFX')?.FindFirstChild(name)?.Clone() as Sound | undefined;
	if (sound === undefined) return;
	sound.PlayOnRemove = false;
	if (properties) {
		for (const [name, value] of pairs(properties)) {
			try {
				(sound as unknown as Record<string, DictValue>)[name] = value;
			} catch (err) {}

			if (typeIs(value, 'number')) dataString += `,${name}=${math.round(value * 1000)}`;
			else dataString += `,${name}=${tostring(value)}`;
		}
	}

	if (player.GetAttribute(PlayerAttributes.InErrorLand)) sound.PlaybackSpeed *= 0.5;
	sound.Volume = math.min(sound.Volume, 1.5);
	sound.Parent = Workspace;

	if (!ignoreReplay) Events.MakeReplayEvent.Fire(dataString);

	if (player.GetAttribute(PlayerAttributes.HammerTexture) === '404 Hammer' && getSetting(GameSetting.Modifiers)) {
		sound.PlaybackSpeed *= 0.5;

		const pitchShift = new Instance('PitchShiftSoundEffect');
		pitchShift.Octave = 2;
		pitchShift.Parent = sound;
	}

	sound.Play();
	sound.Ended.Connect(() => sound.Destroy());
}

export function getCubeTime(cube: Instance | undefined): LuaTuple<[number, number]> {
	if (!cube?.IsA('BasePart') || !cube.GetAttribute('isCube')) return $tuple(-1, -1);

	const currentTime = getTime();

	const finishTotalTime = cube.GetAttribute('finishTotalTime');
	if (typeIs(finishTotalTime, 'number')) return $tuple(finishTotalTime, getTime() - finishTotalTime);

	let extraTime = cube.GetAttribute('extra_time');
	if (!typeIs(extraTime, 'number')) extraTime = 0;

	let startTime = cube.GetAttribute('start_time');
	if (!typeIs(startTime, 'number')) startTime = 0;

	return $tuple(math.min(currentTime - startTime + extraTime, 3599), startTime);
}

export function getTimeUnits(ms: number): LuaTuple<[number, number, number, number]> {
	const hours = math.floor(ms / (1000 * 60 * 60));
	const minutes = math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
	const seconds = math.floor((ms % (1000 * 60)) / 1000);
	const milliseconds = ms % 1000;

	return $tuple(hours, minutes, seconds, milliseconds);
}

export function formatBytes(bytes: number): string {
	const units = ['bytes', 'kb', 'mb', 'gb', 'tb'];
	const scale = 1024;

	let unitIndex = 1;
	while (bytes >= scale && unitIndex < units.size()) {
		bytes /= scale;
		unitIndex++;
	}

	const roundedBytes = string.format(bytes % 1 === 0 ? '%d' : '%.1f', bytes);
	return `${roundedBytes} ${units[unitIndex]}`;
}

export function computeNameColor(playerName: string): Color3 {
	const nameColors = [
		Color3.fromRGB(253, 41, 67),
		Color3.fromRGB(1, 162, 255),
		Color3.fromRGB(2, 184, 87),
		new BrickColor('Bright violet').Color,
		new BrickColor('Bright orange').Color,
		new BrickColor('Bright yellow').Color,
		new BrickColor('Light reddish violet').Color,
		new BrickColor('Brick yellow').Color,
	];

	const nameLength = playerName.size();

	let value = 0;
	for (let i = 1; i <= nameLength; i++) {
		let [cValue] = string.byte(playerName.sub(i, i));
		let reverseIndex = nameLength - i + 1;

		if (nameLength % 2 === 1) reverseIndex--;
		if (reverseIndex % 4 >= 2) cValue *= -1;

		value += cValue;
	}

	return nameColors[value % nameColors.size()];
}

export function convertStudsToMeters(studs: number): [number, string] {
	const meters = studs * 0.28;
	const kilometers = meters / 1000;
	const megameters = kilometers / 1000;
	const gigameters = megameters / 1000;
	const terameters = gigameters / 1000;

	if (terameters >= 1) return [meters, string.format('%.1fTm', terameters)];
	else if (gigameters >= 1) return [meters, string.format('%.1fGm', gigameters)];
	else if (megameters >= 1) return [meters, string.format('%.1fMm', megameters)];
	else if (kilometers >= 1) return [meters, string.format('%.1fkm', kilometers)];

	return [meters, string.format('%.1fm', meters)];
}

export function convertMetersToStuds(meters: number): number {
	return roundDecimalPlaces(meters / 0.28);
}

export function getPlayerRank(player: Player): number {
	if (player.UserId === GameData.CreatorId || player.UserId <= 0) return 2;
	else if (admins.findIndex((userId) => userId === player.UserId)) return 1;

	return 0;
}

export function encodeObjectToJSON(object: unknown): unknown {
	if (typeIs(object, 'Vector3'))
		return {
			datatype: 'Vector3',
			value: [roundDecimalPlaces(object.X), roundDecimalPlaces(object.Y), roundDecimalPlaces(object.Z)],
		};
	else if (typeIs(object, 'CFrame')) return { datatype: 'CFrame', value: [...object.GetComponents()] };
	else if (typeIs(object, 'Color3')) return { datatype: 'Color3', value: object.ToHex() };
	else if (typeIs(object, 'table')) {
		const dict = object as Record<DictKey, DictValue>;
		for (const [key, value] of pairs(dict)) dict[key] = encodeObjectToJSON(value) as DictValue;
	}

	return object;
}

export function decodeJSONObject(object: unknown): unknown {
	if (typeIs(object, 'table')) {
		const dictTable = object as Record<DictKey, DictValue>;
		const datatype = dictTable.datatype;
		const value = dictTable.value as number[] | string;

		if (typeIs(value, 'string')) {
			if (datatype === 'Color3') {
				try {
					return Color3.fromHex(value);
				} catch (err) {
					return undefined;
				}
			}
		} else if (value === undefined) {
			for (const [key, value] of pairs(dictTable)) dictTable[key] = decodeJSONObject(value) as DictValue;
		} else {
			if (datatype === 'Vector3') return new Vector3(...value);
			else if (datatype === 'CFrame') return new CFrame(...(value as [number, number, number, number, number, number, number, number, number, number, number, number]));
		}
	}

	return object;
}

export function compressData(data: object, isJSON: boolean): string {
	if (isJSON) data = encodeObjectToJSON(data) as object;
	return TextCompression.compress(HttpService.JSONEncode(data));
}

export function decompressData(data: string, isJSON: boolean): unknown {
	const decompressedData = HttpService.JSONDecode(TextCompression.decompress(data));
	if (isJSON) return decodeJSONObject(decompressedData);
	return decompressedData;
}

export function giveBadge(player: Player, badgeId: number): void {
	if (!RunService.IsServer()) return;

	if (isTestingServer()) {
		$warn(`Badges are disabled in the Testing Server | Attempted to give badge ${badgeId} to ${player.Name}`);
		return;
	}

	const userId = player.UserId;
	task.spawn(() => {
		while (player.GetAttribute(PlayerAttributes.BadgeDebounce)) player.AttributeChanged.Wait();
		player.SetAttribute(PlayerAttributes.BadgeDebounce, true);

		while (true) {
			try {
				if (!BadgeService.UserHasBadgeAsync(userId, badgeId)) {
					BadgeService.AwardBadge(userId, badgeId);
					$print(`Successfully badge ${badgeId} to ${player.Name}`);
				}

				break;
			} catch (err) {
				$warn(err);
			}
		}

		task.delay(2, () => player.SetAttribute(PlayerAttributes.BadgeDebounce, undefined));
	});
}

export function isTestingServer(): boolean {
	if (RunService.IsStudio()) return forceTestingServer.Value;
	return placeId === GameData.TestingPlaceId;
}

export function isMainServer(): boolean {
	if (RunService.IsStudio()) return !forceTestingServer.Value;
	return placeId === GameData.MainPlaceId;
}
