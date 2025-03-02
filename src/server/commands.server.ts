import { ReplicatedStorage, TeleportService, TweenService, RunService, Workspace, Players } from '@rbxts/services';

import { startsWith } from '@rbxts/string-utils';

import { isTestingServer, getPlayerRank, giveBadge, numLerp, Badge } from 'shared/utils';

import { accessoryList } from 'shared/accessory_loader';

const Events = {
	SaySystemMessage: ReplicatedStorage.FindFirstChild('SaySystemMessage') as RemoteEvent,
	StartErrorEvent: ReplicatedStorage.FindFirstChild('StartErrorEvent') as RemoteEvent,
	FlipGravity: ReplicatedStorage.FindFirstChild('FlipGravity') as RemoteEvent,

	ForceEquip: ReplicatedStorage.FindFirstChild('ForceEquip') as BindableEvent,
};

const prefixes = [';', ':', '/'];
const connections: Map<Player, RBXScriptConnection> = new Map();

interface Command {
	rank: number;
	parameters: string[];
	callback: (sender: Player, ...args: unknown[]) => void;
}

const Commands: Record<string, Command> = {
	cmds: {
		rank: 0,
		parameters: [],
		callback: (sender: Player) => {
			const rank = getPlayerRank(sender);

			let message = 'Available commands you can use:';
			for (const [name, data] of pairs(Commands)) {
				if (data.rank > rank) continue;

				message += `\n  ;${name}`;
				if (data.parameters.size() > 0) message += ` [${data.parameters.join('] [')}]`;
			}

			task.wait(0);
			Events.SaySystemMessage.FireClient(sender, message);
		},
	},
	rejoin: {
		rank: 0,
		parameters: [],
		callback: (sender: Player) => {
			const options = new Instance('TeleportOptions');
			options.ServerInstanceId = game.JobId;
			options.ShouldReserveServer = false;

			TeleportService.TeleportAsync(game.PlaceId, [sender], options);
		},
	},
	equip: {
		rank: isTestingServer() ? 0 : 2,
		parameters: ['string'],
		callback: (sender: Player, a) => {
			const accessoryName = a as string;

			const allowedEquips = ['Icy Hammer'];
			if (allowedEquips.includes(accessoryName)) {
				Events.ForceEquip.Fire(sender, accessoryName);
			} else {
				task.wait();
				if (accessoryName in accessoryList) Events.SaySystemMessage.FireClient(sender, 'You are not allowed to equip that!', Color3.fromRGB(255, 170, 0));
				else Events.SaySystemMessage.FireClient(sender, 'Not found', Color3.fromRGB(255, 128, 128));
			}
		},
	},
	flip: {
		rank: 1,
		parameters: ['players'],
		callback: (sender: Player, a) => {
			const targets = a as Player[];

			for (const target of targets) {
				Events.FlipGravity.FireClient(target);
				giveBadge(target, Badge.Flipped);
			}
		},
	},
	fequip: {
		rank: 1,
		parameters: ['players', 'string'],
		callback: (sender: Player, a, b) => {
			const targets = a as Player[];
			const accessoryName = b as string;

			for (const target of targets) Events.ForceEquip.Fire(target, accessoryName);
		},
	},
	alist: {
		rank: 1,
		parameters: [],
		callback: (sender: Player) => {
			task.wait(0);
			Events.SaySystemMessage.FireClient(sender, 'Accessory List:', Color3.fromRGB(0, 200, 255));
			for (const [name] of pairs(accessoryList)) Events.SaySystemMessage.FireClient(sender, `> ${name}`, Color3.fromRGB(0, 200, 255));
		},
	},
	goto: {
		rank: 1,
		parameters: ['players'],
		callback: (sender: Player, a) => {
			const targets = a as Player[];

			if (targets.size() !== 1) return;

			const player = targets[0];
			const targetCube = Workspace.FindFirstChild(`cube${sender.UserId}`) as BasePart;
			const teleportCube = Workspace.FindFirstChild(`cube${player.UserId}`) as BasePart;
			if (!targetCube || !teleportCube) return;

			task.spawn(() => {
				targetCube.Anchored = true;
				targetCube.AssemblyLinearVelocity = new Vector3();
				task.wait(0.1);
				targetCube.PivotTo(teleportCube.CFrame.mul(new CFrame(0, 5, 0)));
				task.wait(0.1);
				targetCube.Anchored = false;
			});
		},
	},
	bring: {
		rank: 1,
		parameters: ['players'],
		callback: (sender: Player, a) => {
			const targets = a as Player[];

			if (targets.size() !== 1) {
				return;
			}

			const player = targets[0];
			const targetCube = Workspace.FindFirstChild(`cube${player.UserId}`) as BasePart;
			const teleportCube = Workspace.FindFirstChild(`cube${sender.UserId}`) as BasePart;
			if (!targetCube || !teleportCube) {
				return;
			}

			targetCube.Anchored = true;
			targetCube.AssemblyLinearVelocity = new Vector3();
			task.wait(0.1);
			targetCube.PivotTo(teleportCube.CFrame.mul(new CFrame(0, 5, 0)));
			task.wait(0.1);
			targetCube.Anchored = false;
		},
	},
	scale: {
		rank: 2,
		parameters: ['players', 'number'],
		callback: (sender: Player, a, b) => {
			const targets = a as Player[];
			const newScale = b as number;
			if (!typeIs(newScale, 'number')) {
				Events.SaySystemMessage.FireClient(sender, 'Second parameter must be a number', Color3.fromRGB(255, 170, 0));
				return;
			}

			for (const player of targets) {
				const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as BasePart;
				if (cube && !cube.GetAttribute('isScaling')) {
					cube.SetAttribute('used_modifiers', true);

					cube.SetAttribute('isScaling', true);
					task.spawn(() => {
						const previousScale = (cube.GetAttribute('scale') as number | undefined) ?? 1;

						const model = new Instance('Model');
						model.ScaleTo(previousScale);
						model.Parent = Workspace;

						cube.Parent = model;

						let currentTime = time();
						const startTime = currentTime;
						const totalTime = 0.4;

						while (currentTime - startTime < totalTime) {
							const alpha = TweenService.GetValue((currentTime - startTime) / totalTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);

							const currentScale = numLerp(previousScale, newScale, alpha);
							model.ScaleTo(currentScale);

							currentTime = time();

							RunService.Heartbeat.Wait();
						}

						model.ScaleTo(newScale);

						cube.SetAttribute('isScaling', undefined);
						cube.SetAttribute('scale', newScale);
						cube.Parent = Workspace;
					});
				}
			}
		},
	},
};

function parseCommand(message: string) {
	let prefix: string | undefined;
	for (const p of prefixes) {
		if (message.sub(1, 1) === p) {
			prefix = p;
			break;
		}
	}

	if (!prefix) {
		return $tuple(undefined, []);
	}

	message = message.sub(2);

	const [command, argsString] = message.match('^(%S+)%s*(.*)') ?? [];
	if (!command) {
		return $tuple(undefined, []);
	}

	function splitArgs(args: string): string[] {
		const results: string[] = [];
		let currentArg = '';
		let inSingleQuote = false;
		let inDoubleQuote = false;
		let escaping = false;

		for (const i of $range(1, args.size())) {
			const char = args.sub(i, i);

			if (escaping) {
				currentArg += char;
				escaping = false;
			} else if (char === '\\') {
				escaping = true;
			} else if (char === "'" && !inDoubleQuote) {
				if (inSingleQuote) {
					results.push(currentArg);
					currentArg = '';
					inSingleQuote = false;
				} else {
					inSingleQuote = true;
				}
			} else if (char === '"' && !inSingleQuote) {
				if (inDoubleQuote) {
					results.push(currentArg);
					currentArg = '';
					inDoubleQuote = false;
				} else {
					inDoubleQuote = true;
				}
			} else if (char === ' ' && !inSingleQuote && !inDoubleQuote) {
				if (currentArg.size() > 0) {
					results.push(currentArg);
					currentArg = '';
				}
			} else {
				currentArg += char;
			}
		}

		if (currentArg.size() > 0) {
			results.push(currentArg);
		}

		return results;
	}

	return $tuple(command, splitArgs((argsString as string | undefined) ?? ''));
}

function getPlayers(name: string, sender: Player): Player[] {
	const players: Player[] = [];
	if (name === 'all' || name === 'others') {
		for (const otherPlayer of Players.GetPlayers()) {
			if (name === 'all' || otherPlayer !== sender) players.push(otherPlayer);
		}
	} else if (name === 'me') {
		players.push(sender);
	} else {
		const validPlayerNames: string[] = [];
		for (const otherPlayer of Players.GetPlayers()) {
			if (startsWith(otherPlayer.Name.lower(), name.lower())) validPlayerNames.push(otherPlayer.Name);
		}

		if (validPlayerNames.size() > 0) {
			validPlayerNames.sort();
			players.push(Players.FindFirstChild(validPlayerNames[0]) as Player);
		}
	}

	return players;
}

function chatted(player: Player, message: string) {
	const [commandName, args] = parseCommand(message);
	if (!commandName) {
		return;
	}

	const rank = getPlayerRank(player);

	const command = Commands[commandName];
	if (!command) {
		return;
	}

	if (rank < command.rank) {
		task.wait(0);
		Events.SaySystemMessage.FireClient(player, 'You are not allowed to use this command!', Color3.fromRGB(255, 170, 0));
		return;
	}

	if (args.size() !== command.parameters.size()) {
		task.wait(0);
		Events.SaySystemMessage.FireClient(player, 'Invalid command syntax, use ;cmds to see how to use this command', Color3.fromRGB(0, 0, 255));
		return;
	}

	const parsedParameters: (string | number | Player[])[] = [];
	for (const [i, parameterType] of pairs(command.parameters)) {
		if (parameterType === 'players') parsedParameters.push(getPlayers(args[i - 1], player));
		else if (parameterType === 'string') parsedParameters.push(args[i - 1]);
		else if (parameterType === 'number') parsedParameters.push(tonumber(args[i - 1]) ?? args[i - 1]);
	}

	command.callback(player, ...parsedParameters);
}

Players.PlayerAdded.Connect((player) => {
	connections.set(
		player,
		player.Chatted.Connect((message) => chatted(player, message)),
	);
});

Players.PlayerRemoving.Connect((player) => {
	connections.get(player)?.Disconnect();
});
