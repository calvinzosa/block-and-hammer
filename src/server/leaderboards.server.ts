import {
    ReplicatedStorage,
    DataStoreService,
    HttpService,
    RunService,
    Players,
} from '@rbxts/services';

import { $print, $warn } from 'rbxts-transform-debug';

import {
    isTestingServer,
} from 'shared/utils';

if (isTestingServer()) {
    $warn('Leaderboards are not enabled in the testing server');
} else {
    const Events = {
        'UpdateLeaderboard': ReplicatedStorage.FindFirstChild('UpdateLeaderboard') as RemoteEvent,
        
        'UpdatePlayerTime': ReplicatedStorage.FindFirstChild('UpdatePlayerTime') as BindableEvent,
    };
    
    const leaderboardVersion = 'LEADERBOARD_V6';
    
    const GlobalLeaderboard = DataStoreService.GetOrderedDataStore('GlobalLeaderboard', leaderboardVersion);
    const ModdedLeaderboard = DataStoreService.GetOrderedDataStore('ModdedLeaderboard', leaderboardVersion);
    
    const leaderboardsCache: Record<string, Record<string, number>> = { GlobalLeaderboard: {  }, ModdedLeaderboard: {  } };
    let dataCache: Record<string, Record<number, [ number, number ]>> = { GlobalLeaderboard: {  }, ModdedLeaderboard: {  } };
    
    function updateLeaderboardsCache() {
        if (!RunService.IsStudio() || true) {
            for (const [ userId, totalTime ] of pairs(leaderboardsCache.GlobalLeaderboard)) {
                while (true) {
                    try {
                        GlobalLeaderboard.UpdateAsync(userId, (prevValue) => {
                            const newValue = math.min(totalTime, prevValue ?? totalTime);
                            $print(`Updated global leaderboard value of ${userId} | Previous Value: ${prevValue} | New Value: ${newValue}`);
                            return newValue;
                        });
                        break;
                    } catch (err) {
                        $warn(err);
                    }
                }
                
                delete leaderboardsCache.GlobalLeaderboard[userId];
            }
            
            for (const [ userId, totalTime ] of pairs(leaderboardsCache.ModdedLeaderboard)) {
                while (true) {
                    try {
                        ModdedLeaderboard.UpdateAsync(userId, (prevValue) => {
                            const newValue = math.min(totalTime, prevValue ?? totalTime);
                            $print(`Updated modded leaderboard value of ${userId} | Previous Value: ${prevValue} | New Value: ${newValue}`);
                            return newValue;
                        });
                        break;
                    } catch (err) {
                        $warn(err);
                    }
                }
                
                delete leaderboardsCache.ModdedLeaderboard[userId];
            }
        }
        
        dataCache = { GlobalLeaderboard: {  }, ModdedLeaderboard: {  } };
        
        while (true) {
            try {
                processLeaderboardData(GlobalLeaderboard.GetSortedAsync(true, 100, 1).GetCurrentPage() as { key: string, value: number }[], 'GlobalLeaderboard');
                processLeaderboardData(ModdedLeaderboard.GetSortedAsync(true, 100, 1).GetCurrentPage() as { key: string, value: number }[], 'ModdedLeaderboard');
                break;
            } catch (err) {
                $warn(err);
            }
        }
        
        Events.UpdateLeaderboard.FireAllClients(HttpService.JSONEncode(dataCache));
        
        $print('Updated all leaderboard info');
    }
    
    function processLeaderboardData(page: { key: string, value: number }[], leaderboardName: string) {
        for (const [ number, value ] of pairs(page)) {
            const userId = value.key;
            const totalTimeMilliseconds = value.value;
            dataCache[leaderboardName][number] = [ tonumber(userId) ?? -1, totalTimeMilliseconds ];
        }
    }
    
    function playerAdded(player: Player) {
        task.wait(5)
        Events.UpdateLeaderboard.FireClient(player, HttpService.JSONEncode(dataCache));
    }
    
    Events.UpdatePlayerTime.Event.Connect((userId: number, totalTime: number, leaderboardType: number) => {
        if (userId <= 0) return;
        
        const milliseconds = math.floor(totalTime * 1000);
        const id = tostring(userId);
        
        if (leaderboardType === 0) leaderboardsCache.GlobalLeaderboard[id] = milliseconds;
        else if (leaderboardType === 1) leaderboardsCache.ModdedLeaderboard[id] = milliseconds;
    });
    
    for (const player of Players.GetPlayers()) playerAdded(player);
    Players.PlayerAdded.Connect(playerAdded);
    
    task.wait(5);
    
    while (true) {
        try {
            updateLeaderboardsCache();
        } catch (err) {
            $warn(err);
        }
        
        task.wait(60);
    }
}