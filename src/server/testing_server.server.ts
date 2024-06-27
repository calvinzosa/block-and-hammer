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

import { $print, $warn } from 'rbxts-transform-debug';

const TestingServerStore = DataStoreService.GetDataStore('testing_server');
const forceTestingServer = ReplicatedStorage.FindFirstChild('ForceTestingServer') as IntValue;
const ownerId = ReplicatedStorage.FindFirstChild('PrivateServerOwnerId') as IntValue;

if ((RunService.IsStudio() && !forceTestingServer.Value) || game.PrivateServerOwnerId === 0) ownerId.Value = -1;
else ownerId.Value = game.PrivateServerOwnerId;

if (isMainServer()) {
    $print('Server Type: Main');
    
    if (ownerId.Value === GameData.CreatorId) {
        while (task.wait(3)) {
            let savedServerId;
            while (true) {
                try {
                    [ savedServerId ] = TestingServerStore.GetAsync('ServerId');
                    break;
                } catch (err) {
                    $warn(err);
                }
            }
            
            if (!typeIs(savedServerId, 'string') || savedServerId === 'none') {
                const [ serverId ] = TeleportService.ReserveServer(GameData.TestingPlaceId);
                savedServerId = serverId;
                
                while (true) {
                    try {
                        TestingServerStore.SetAsync('ServerId', serverId);
                    } catch (err) {
                        $warn(err);
                    }
                }
            }
            
            TeleportService.TeleportToPrivateServer(GameData.TestingPlaceId, savedServerId, Players.GetPlayers());
        }
    }
} else if (isTestingServer()) {
    $print('Server Type: Testing');
    
    game.BindToClose(() => {
        while (true) {
            try {
                TestingServerStore.SetAsync('ServerId', 'none');
                break;
            } catch (err) {
                $warn(err);
            }
        }
    });
}