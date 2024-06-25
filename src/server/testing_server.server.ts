import {
    ReplicatedStorage,
    DataStoreService,
    TeleportService,
    RunService,
    Players,
} from '@rbxts/services';

import {
    isTestingServer,
    isMainServer,
    GameData,
} from 'shared/utils';

import { $print } from 'rbxts-transform-debug';

const TestingServerStore = DataStoreService.GetDataStore('testing_server');
const forceTestingServer = ReplicatedStorage.FindFirstChild('ForceTestingServer') as IntValue;
const ownerId = ReplicatedStorage.FindFirstChild('PrivateServerOwnerId') as IntValue;

if (RunService.IsStudio() && !forceTestingServer.Value) ownerId.Value = -1;
else ownerId.Value = game.PrivateServerOwnerId;

if (isMainServer()) {
    $print('Server Type: Main');
    
    if (ownerId.Value === GameData.CreatorId) {
        while (task.wait(3)) {
            let savedServerId = undefined;
            do {
                const [ success, serverId ] = pcall(() => TestingServerStore.GetAsync('ServerId'));
                if (success) {
                    savedServerId = serverId as (string | undefined);
                    break;
                }
            } while (task.wait(0.5));
            
            if (!savedServerId || savedServerId === 'none') {
                const [ serverId ] = TeleportService.ReserveServer(GameData.TestingPlaceId);
                savedServerId = serverId;
                
                do {
                    const [ success ] = pcall(() => TestingServerStore.SetAsync('ServerId', serverId));
                    if (success) break;
                } while (task.wait(0.5));
            }
            
            TeleportService.TeleportToPrivateServer(GameData.TestingPlaceId, savedServerId, Players.GetPlayers());
        }
    }
} else if (isTestingServer()) {
    $print('Server Type: Testing');
    
    game.BindToClose(() => {
        do {
            const [ success ] = pcall(() => TestingServerStore.SetAsync('ServerId', 'none'));
            if (success) break;
        } while (task.wait(0.5));
    });
}