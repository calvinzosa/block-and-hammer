import {
    ReplicatedStorage,
    DataStoreService,
    BadgeService,
    HttpService,
    RunService,
    Players,
    Workspace,
} from '@rbxts/services';

import { $print, $warn } from 'rbxts-transform-debug';

import {
    PlayerAttributes,
    decodeJSONObject,
    encodeObjectToJSON,
    getCubeTime,
    getTime,
    isTestingServer
} from 'shared/utils';

import { accessoryList } from 'shared/accessory_loader';

const Events = {
    'LoadSettingsJSON': ReplicatedStorage.FindFirstChild('LoadSettingsJSON') as RemoteEvent,
    'SaveSettingsJSON': ReplicatedStorage.FindFirstChild('SaveSettingsJSON') as RemoteEvent,
    'SaySystemMessage': ReplicatedStorage.FindFirstChild('SaySystemMessage') as RemoteEvent,
    
    'LoadPlayerAccessories': ReplicatedStorage.FindFirstChild('LoadPlayerAccessories') as BindableEvent,
    'ForceEquip': ReplicatedStorage.FindFirstChild('ForceEquip') as BindableEvent,
    
    'EquipAccessory': ReplicatedStorage.FindFirstChild('EquipAccessory') as RemoteFunction,
};

type PlayerData = {
    position: Vector3 | undefined,
    velocity: Vector3 | undefined,
    accessories: Record<string, string> | undefined,
    destroyed_counter: number | undefined,
    cube_color: Color3 | undefined,
    time_data: {
        extra_time: number,
        finished: boolean | undefined,
        finish_total_time: number | undefined,
        modded: boolean | undefined,
    } | undefined,
    settings_json: string | undefined,
    active_quest: string | undefined,
    stats: {
        total_time_played: number | undefined,
        total_restarts: number | undefined,
        total_ragdolls: number | undefined,
        times_joined: number | undefined,
        total_wins: number | undefined,
        total_modded_wins: number | undefined,
    } | undefined
};

const QuestData = require(ReplicatedStorage.WaitForChild('Modules').WaitForChild('QuestData') as ModuleScript) as Record<string, unknown>;

const PlayerData = DataStoreService.GetDataStore('player_data');

const accessoryData: Record<string, Record<string, string>> = {  };

function playerAdded(player: Player) {
	player.SetAttribute('serverJoinTime', getTime());
	
    const playerId = tostring(player.UserId);
    
    let totalDataChunks = 0;
    let data = '';
    
    let [ success, errorMessage ] = pcall(() => {
        const pages = PlayerData.ListKeysAsync(playerId, 255);
        
        while (true) {
            totalDataChunks++;
            
            const currentPage = pages.GetCurrentPage() as DataStoreKey[];
            currentPage.sort((a, b) => a.KeyName < b.KeyName);
            
            if (currentPage.size() > 0) {
                for (const key of currentPage) {
                    const [ chunk ] = PlayerData.GetAsync(key.KeyName);
                    if (typeIs(chunk, 'string')) data += chunk;
                    else error(`Data of player ${player.Name} is invalid.`);
                }
            } else break;
            
            if (pages.IsFinished) break;
            pages.AdvanceToNextPageAsync();
        }
    });
	
    if (success) {
		if (data.size() > 0) {
            const [ success, jsonData ] = pcall(() => HttpService.JSONDecode(data));
            if (!success) {
                player.Kick('Your data is most likely corrupted! Please go to the discord server and tell the developer of this message and your username');
                return;
            }
            
            const decodedData = decodeJSONObject(jsonData) as PlayerData;
            
            const position = decodedData.position;
            const velocity = decodedData.velocity;
            const destroyedCounter = decodedData.destroyed_counter;
            
            const cube = Workspace.WaitForChild(`cube${player.UserId}`) as BasePart;
            
            if (typeIs(destroyedCounter, 'number')) cube.SetAttribute('destroyed_counter', destroyedCounter);
            if (typeIs(decodedData.settings_json, 'string')) Events.LoadSettingsJSON.FireClient(player, decodedData.settings_json);
            
            if (typeIs(decodedData.accessories, 'table')) {
                accessoryData[playerId] = decodedData.accessories;
                
                for (const [ _, name ] of pairs(decodedData.accessories)) {
                    const targetAccessory = accessoryList[name];
                    if (targetAccessory && (targetAccessory.badge_id === 0 || BadgeService.UserHasBadgeAsync(player.UserId, targetAccessory.badge_id))) {
                        player.SetAttribute(targetAccessory.acc_type as string, name);
                    }
                }
                
                Events.LoadPlayerAccessories.Fire(player, cube);
            } else accessoryData[playerId] = {  };
            
            if (typeIs(decodedData.cube_color, 'Color3')) player.SetAttribute('CUBE_COLOR', decodedData.cube_color);
            
            if (decodedData.time_data) {
                if (decodedData.time_data.modded) {
                    player.SetAttribute('modifiers', true);
                    cube.SetAttribute('used_modifiers', true);
                }
                
                player.SetAttribute('finished', decodedData.time_data.finished);
                cube.SetAttribute('extra_time', decodedData.time_data.extra_time);
                
                cube.SetAttribute('finishTotalTime', decodedData.time_data.finish_total_time)
            }
            
            if (decodedData.active_quest && decodedData.active_quest in QuestData) player.SetAttribute('activeQuest', decodedData.active_quest);
            
            if (decodedData.stats) {
                const serverJoinTime = player.GetAttribute('serverJoinTime') as number;
                player.SetAttribute('serverJoinTime', serverJoinTime - (decodedData.stats.total_time_played ?? 0));
                player.SetAttribute('totalRestarts', decodedData.stats.total_restarts ?? 0);
                player.SetAttribute('totalRagdolls', decodedData.stats.total_ragdolls ?? 0);
                player.SetAttribute('timesJoined', (decodedData.stats.times_joined ?? 0) + 1);
                player.SetAttribute('totalWins', (decodedData.stats.total_wins ?? 0));
                player.SetAttribute('totalModdedWins', (decodedData.stats.total_modded_wins ?? 0));
            }
            
            if (typeIs(position, 'Vector3')) {
                cube.Anchored = true;
                
                cube.PivotTo(new CFrame(position));
                if (typeIs(velocity, 'Vector3')) cube.AssemblyLinearVelocity = velocity;
                
                task.delay(1, () => cube.Anchored = false);
            }
            
            $print(`Loaded data for player ${player.Name} (${player.UserId}) | Total Data Chunks: ${totalDataChunks}`);
        } else $print(`No data was found for player ${player.Name} (${player.UserId})`);
    } else {
        $warn(`Unable to load data for player ${player.Name}`);
        player.Kick(`Unable to load data, please try again later | Error Message: ${errorMessage}`);
        return;
    }
    
    player.SetAttribute(PlayerAttributes.HasDataLoaded, true);
}

function playerRemoved(player:Player) {
    if (!player.GetAttribute(PlayerAttributes.HasDataLoaded) || (RunService.IsStudio() && time() < 5) || isTestingServer()) return;
	
    const playerId = tostring(player.UserId);
    
    const cube = Workspace.FindFirstChild(`cube${playerId}`) as (BasePart | undefined);
	if (!cube || player.UserId <= 0 || player.GetAttribute('in_tutorial')) return;
	
	const currentTime = getTime();
    const serverJoinTime = player.GetAttribute('serverJoinTime') as number ?? currentTime;
	const cubeColor = player.GetAttribute('CUBE_COLOR') as (Color3 | undefined);
    const destroyedCounter = cube.GetAttribute('destroyed_counter') as (number | undefined);
    const [ extraTime ] = getCubeTime(cube);
    const settingsJSON = player.GetAttribute('settings_json') as (string | undefined);
    const activeQuest = player.GetAttribute('activeQuest') as (string | undefined);
	
	const dataToSave = encodeObjectToJSON({
		position: cube.Position,
		velocity: cube.AssemblyLinearVelocity,
		accessories: accessoryData[playerId],
		destroyed_counter: destroyedCounter,
		cube_color: cubeColor,
		time_data: {
			extra_time: extraTime,
			finished: player.GetAttribute('finished'),
			finish_total_time: cube.GetAttribute('finishTotalTime'),
			modded: player.GetAttribute('modifiers') || cube.GetAttribute('used_modifiers')
		},
		settings_json: settingsJSON,
		active_quest: activeQuest,
		stats: {
			total_time_played: (currentTime - serverJoinTime),
			total_restarts: player.GetAttribute('totalRestarts') as (number | undefined),
			total_ragdolls: player.GetAttribute('totalRagdolls') as (number | undefined),
			times_joined: player.GetAttribute('times_joined') as (number | undefined),
			total_wins: player.GetAttribute('totalWins') as (number | undefined),
			total_modded_wins: player.GetAttribute('totalModdedWins') as (number | undefined),
		}
	} as PlayerData);
	
	cube.Destroy();
	
	const encodedData = HttpService.JSONEncode(dataToSave);
	
    for (const retryAttempt of $range(1, 5)) {
        const [ success, errorMessage ] = pcall(() => {
            let currentData = encodedData.sub(1, encodedData.size());
            
            let iteration = 0;
            const chunkSize = 4194303;
            while (currentData.size() > 0) {
                const chunk = currentData.sub(1, chunkSize);
                const key = playerId + (iteration > 1 ? `_${iteration}` : '');
                
                PlayerData.SetAsync(key, chunk);
                currentData = currentData.sub(chunkSize + 1);
                
                iteration++;
            }
        });
        
        if (success) {
            $print(`Saved data for player ${player.Name} (${player.UserId}) succesfully.`);
            break;
        } else $warn(`Could not save data for player ${player.Name} (${player.UserId})! | Retrying ${5 - retryAttempt} more time(s) | Error: ${errorMessage}`);
    }
}

Players.PlayerAdded.Connect(playerAdded);
Players.PlayerRemoving.Connect(playerRemoved);

Events.EquipAccessory.OnServerInvoke = (player, name) => {
    if (!typeIs(name, 'string')) return false;
	
	const targetAccessory = accessoryList[name];
    if (targetAccessory && (targetAccessory.badge_id === 0 || BadgeService.UserHasBadgeAsync(player.UserId, targetAccessory.badge_id))) {
        if (targetAccessory.never) return false;
        
        const playerId = tostring(player.UserId);
        
        const accessoryType = targetAccessory.acc_type;
        player.SetAttribute(accessoryType, name);
        accessoryData[playerId][accessoryType] = name;
        
        const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as (BasePart | undefined);
        if (cube) Events.LoadPlayerAccessories.Fire(player, cube);
        
        return true;
    }
    
	return false;
}

Events.SaveSettingsJSON.OnServerEvent.Connect((player, settingsJSON) => {
    if (!typeIs(settingsJSON, 'table')) return;
    
    const [ success, encodedData ] = pcall(() => HttpService.JSONEncode(settingsJSON));
	
    if (success) {
        player.SetAttribute('settings_json', encodedData);
        $print(`Updated setting data for player ${player.Name}`);
    } else $warn(`Unable to convert setting data for player ${player.Name} into JSON`);
});

Events.ForceEquip.Event.Connect((player, name) => {
    if (!typeIs(name, 'string') || !typeIs(player, 'Instance') || !player.IsA('Player')) return;
	
    const playerId = tostring(player.UserId);
    
    const targetAccessory = accessoryList[name];
    if (targetAccessory) {
        const accessoryType = targetAccessory.acc_type as string;
        player.SetAttribute(accessoryType, name);
        accessoryData[playerId][accessoryType] = name;
        
        const cube = Workspace.FindFirstChild(`cube${playerId}`) as (BasePart | undefined);
        if (cube) {
            Events.LoadPlayerAccessories.Fire(player, cube);
            if (targetAccessory.never) cube.SetAttribute('used_admin_hammer', true);
        }
    } else task.delay(0, () => Events.SaySystemMessage.FireClient(player, `Accessory "${name}" does not exist!`));
});