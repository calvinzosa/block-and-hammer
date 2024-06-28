import { $print, $warn } from 'rbxts-transform-debug';
$warn('Replays are not enabled yet');

// import {
//     ReplicatedStorage,
//     DataStoreService,
//     HttpService,
//     RunService,
//     Players,
// } from '@rbxts/services';
// import { $print, $warn } from 'rbxts-transform-debug';

// import { compressData, decompressData } from 'shared/utils';

// type ReplayListItem = [ string, number, number, number, string[], number, string ];

// const Events = {
//     'GetPlayerReplays': ReplicatedStorage.FindFirstChild('GetPlayerReplays') as RemoteFunction,
//     'RequestReplay': ReplicatedStorage.FindFirstChild('RequestReplay') as RemoteFunction,
//     'DeleteReplay': ReplicatedStorage.FindFirstChild('DeleteReplay') as RemoteFunction,
//     'UploadReplay': ReplicatedStorage.FindFirstChild('UploadReplay') as RemoteFunction,
// };

// const DataVersion = 'v7';
// const ReplaysStore = DataStoreService.GetDataStore('player_replays', DataVersion);
// const KeysStore = DataStoreService.GetDataStore('player_replay_keys', DataVersion);

// const keyCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
// const replaysCache: Record<number, ReplayListItem[]> = {  };
// const fullData: Record<number, string> = {  };

// function generateRandomKey() {
// 	let result = '';
//     for (const i of $range(1, 7)) {
//         const randomIndex = math.random(keyCharacters.size());
//         result += keyCharacters.sub(randomIndex, randomIndex);
//     }

// 	return result;
// }

// Players.PlayerRemoving.Connect((player) => {
//     if (player.UserId in fullData) delete fullData[player.UserId];
// 	if (player.UserId in replaysCache) delete replaysCache[player.UserId];
// });

// Events.UploadReplay.OnServerInvoke = (player, messageType, chunk) => {
// 	if (!typeIs(messageType, 'number')) return;

// 	const userId = player.UserId;

// 	if (messageType === 0) {
// 		fullData[userId] = '';
// 	} else if (messageType === 1) {
// 		if (!typeIs(chunk, 'string')) return false;

//         fullData[userId] += chunk;
// 	} else if (messageType === 2) {
// 		const replayId = HttpService.GenerateGUID(false);

// 		let key = '';
// 		let success = false;
// 		do {
// 			key = generateRandomKey();

// 			try {
// 				const [ existingKey ] = KeysStore.GetAsync(key);
// 				if (!existingKey) break;
// 			} catch (err) {
// 				$warn(err);
// 			}
// 			let doesExist: boolean | unknown;

// 			if (doesExist) success = false;
// 		} while (!success);

// 		KeysStore.SetAsync(key, replayId, [ player.UserId ]);

// 		const data = fullData[userId];
// 		delete fullData[userId];

// 		const decompressedData = decompressData(data, false);
// 		const newData = compressData([ key, decompressedData ], false);
// 		const chunkSize = 4194303;

// 		for (const retryAttempt of $range(1, 5)) {
// 			try {
// 				let iteration = 1;
// 				for (const i of $range(1, newData.size(), chunkSize)) {
// 					const j = i + chunkSize - 1;
// 					const chunk = newData.sub(i, j);

// 					ReplaysStore.SetAsync(`${userId}_${replayId}_${iteration}`, chunk);
// 					iteration++;
// 				}

// 				$print(`Saved replay data for player ${player.Name}!`);
// 				break;
// 			} catch (err) {
// 				$warn(`Could not save replay for player ${player.Name}! Retrying ${5 - retryAttempt} more time(s) | Error: ${err}`);
// 			}
// 		}

// 		delete replaysCache[userId];
// 	}

// 	return true;
// }

// Events.DeleteReplay.OnServerInvoke = (player, replayId) => {
// 	if (!typeIs(replayId, 'string')) return;

// 	const prefix = `${player.UserId}_${replayId}`;

// 	while (true) {
// 		try {
// 			const replayChunks = ReplaysStore.ListKeysAsync(prefix, 0, '', true);

// 			while (true) {
// 				const currentPage = replayChunks.GetCurrentPage() as DataStoreKey[];
// 				for (const key of currentPage) ReplaysStore.RemoveAsync(key.KeyName);

// 				if (replayChunks.IsFinished) break;
// 				replayChunks.AdvanceToNextPageAsync();
// 			}

// 			break;
// 		} catch (err) {
// 			$warn(err);
// 		}
// 	}

// 	delete replaysCache[player.UserId];
// }

// Events.GetPlayerReplays.OnServerInvoke = (player) => {
// 	const userId = player.UserId;
// 	if (userId in replaysCache) return replaysCache[userId];

// 	if (player.GetAttribute('requestingReplays')) return -1;

// 	player.SetAttribute('requestingReplays', true);

// 	let replayList: Record<string, { dateCreated: number, frames: string[] }> = {  };

// 	while (true) {
// 		try {
// 			const allReplays = ReplaysStore.ListKeysAsync(tostring(userId), undefined, undefined, true);

// 			replayList = {  };

// 			while (true) {
// 				const currentPage = allReplays.GetCurrentPage() as DataStoreKey[];
// 				for (const key of currentPage) {
// 					const [ , replayId, iteration ] = key.KeyName.split('_');

// 					const [ data, info ] = ReplaysStore.GetAsync(key.KeyName);
// 					if (typeIs(data, 'string')) {
// 						if (!(replayId in replayList)) replayList[replayId] = { dateCreated: info.CreatedTime, frames: [  ] };

// 						replayList[replayId].frames[(tonumber(iteration) ?? 1) - 1] = data
// 					}
// 				}

// 				if (allReplays.IsFinished) break;
// 				allReplays.AdvanceToNextPageAsync();
// 			}

// 			break;
// 		} catch (err) {
// 			$warn(err);
// 		}
// 	}

// 	const newList = [  ] as ReplayListItem[];

// 	for (const [ replayId, replayData ] of pairs(replayList)) {
// 		const dateCreated = replayData.dateCreated ?? -1;
// 		const data = replayData.frames;

// 		const concattedData = data.join('');
// 		const decompressedData = decompressData(concattedData, false) as string[] | [ string, string[] ];

// 		let result, key;
// 		if (decompressedData.size() === 2) {
// 			key = decompressedData[0];
// 			result = decompressedData[1];
// 		} else {
// 			result = decompressedData;
// 			key = undefined;
// 		}

// 		newList.push([ replayId, player.UserId, data.size(), concattedData.size(), result as string[], dateCreated, key as string ]);
// 	}

// 	newList.sort((a, b) => a[5] > b[5]);
// 	replaysCache[player.UserId] = table.clone(newList);

// 	player.SetAttribute('requestingReplays', undefined);

// 	return newList;
// }

// Events.RequestReplay.OnServerInvoke = (player, key) => {
// 	if (!typeIs(key, 'string')) return;

// 	if (key.size() !== 7) return $tuple(undefined, 'key must be 7 characters long');

// 	for (const character of key.split('')) {
// 		const [ index ] = keyCharacters.find(character);
// 		if (!index) return $tuple(undefined, 'Key contains invalid character');
// 	}

// 	let replayId: string | undefined, info: DataStoreKeyInfo | undefined;
// 	while (true) {
// 		try {
// 			[ replayId, info ] = KeysStore.GetAsync(key);
// 			break;
// 		} catch (err) {
// 			$warn(err);
// 		}
// 	}

// 	if (typeIs(replayId, 'string') && info?.IsA('DataStoreKeyInfo')) {
// 		const userId = (info.GetUserIds() as number[])[0];
// 		if (!userId) return $tuple(undefined, 'Unable to fetch user id from key, try again');

// 		const prefix = `${player.UserId}_${replayId}`
// 		let chunks: string[] = [  ];

// 		while (true) {
// 			try {
// 				chunks.clear();

// 				const replayChunks = ReplaysStore.ListKeysAsync(prefix, undefined, undefined, true);
// 				while (true) {
// 					const currentPage = replayChunks.GetCurrentPage() as DataStoreKey[];
// 					for (const key of currentPage) {
// 						const [ ,, iteration ] = key.KeyName.split('_');

// 						const [ data ] = ReplaysStore.GetAsync(key.KeyName);
// 						if (typeIs(data, 'string')) chunks[tonumber(iteration) ?? 1] = data;
// 					}

// 					if (replayChunks.IsFinished) break;
// 					replayChunks.AdvanceToNextPageAsync();
// 				}
// 			} catch (err) {
// 				$warn(err);
// 			}
// 		}

// 		let decodedData = decompressData(chunks.join(''), false) as [ number, string[] ] | string[];
// 		if (decodedData.size() > 2) decodedData = [ userId, decodedData as string[] ];
// 		else decodedData[0] = userId;

// 		return $tuple(decodedData, '');
// 	} else return $tuple(undefined, 'Key does not exist');
// }
