import {
    RunService,
    Workspace,
    Players,
} from '@rbxts/services';

import { $dbg, $print, $warn } from 'rbxts-transform-debug';

const player = Players.LocalPlayer;

const mapFolder = Workspace.WaitForChild('Map') as Folder;
const mudParts = mapFolder.WaitForChild('MudParts') as Folder;

const propellers = mapFolder.WaitForChild('Propellers').Clone() as Folder;
mapFolder.FindFirstChild('Propellers')?.Destroy();
propellers.Parent = mapFolder;

const cachedPropellers: Model[] = [  ];

function newPropeller(propeller: Instance) {
    if (!propeller.IsA('Model')) return;
    
	const hitbox = propeller.WaitForChild('Hitbox');
	if (!hitbox || !typeIs(propeller.GetAttribute('windVelocity'), 'number')) {
        $warn('An invalid propeller was created.');
        return;
    }
	
    cachedPropellers.push(propeller);
}

for (const propeller of propellers.GetChildren()) task.spawn(newPropeller, propeller);
propellers.ChildAdded.Connect(newPropeller);

RunService.Heartbeat.Connect((dt) => {
    const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
    if (!cube?.IsA('BasePart')) return;
    
    for (const [ i, propeller ] of pairs(cachedPropellers)) {
        const blades = propeller.FindFirstChild('Blades');
        if (!blades?.IsA('BasePart')) {
            $warn('A propeller has broke.');
            cachedPropellers.remove(i);
            break;
        }
        
        for (const descendant of propeller.GetDescendants()) {
            if (descendant.IsA('ParticleEmitter')) descendant.Enabled = (blades.AssemblyAngularVelocity.Magnitude >= 5);
        }
    }
    
    const params = new OverlapParams();
    params.FilterType = Enum.RaycastFilterType.Include;
    params.FilterDescendantsInstances = cachedPropellers;
    
    const usedPropellers: Model[] = [  ];
    
    let totalCubeForce = Vector3.zero;
    let totalHeadForce = Vector3.zero;
    
    for (const [ i, part ] of pairs([ cube, cube.FindFirstChild('Head') ])) {
        if (!part?.IsA('BasePart')) return;
        
        for (const touching of Workspace.GetPartsInPart(part, params)) {
            const propeller = touching.FindFirstAncestorWhichIsA('Model');
            if (!propeller || usedPropellers.findIndex((otherPropeller) => otherPropeller === propeller) >= 0 || propeller.GetAttribute('jammed')) continue;
            
            if (propeller.GetAttribute('noStack') && usedPropellers.size() !== 0) continue;
            
            const hitbox = propeller.FindFirstChild('Hitbox') as BasePart;
            const blades = propeller.FindFirstChild('Blades') as BasePart;
            if (blades.AssemblyAngularVelocity.Magnitude < 5) {
                propeller.SetAttribute('jammed', true);
                blades.Anchored = true;
                task.delay(5, () => {
                    blades.Anchored = false;
                    task.delay(0.5, () => propeller.SetAttribute('jammed', undefined));
                });
                
                continue;
            }
            
            const velocity = propeller.GetAttribute('windVelocity') as number;
            const result = hitbox.CFrame.RightVector.mul(velocity);
            
            if (i === 1) totalCubeForce = totalCubeForce.sub(result);
            else if (i === 2) totalHeadForce = totalHeadForce.sub(result);
            
            usedPropellers.push(propeller);
        }
    }
    
    const gravity = Workspace.GetAttribute('default_gravity') as (number | undefined) ?? 196.2;
    
    let cubeMultiplier = 1;
    let headMultiplier = 1;
    
	params.FilterDescendantsInstances = [ mudParts ];
	
	for (const [ i, part ] of pairs([ cube, cube.FindFirstChild('Head') ])) {
		if (part?.IsA('BasePart') && Workspace.GetPartsInPart(part, params).size() > 0) {
            if (i === 1) cubeMultiplier = 2;
            else headMultiplier = 2;
        }
	}
    
    const propellerForce = cube.FindFirstChild('PropellerForce');
    if (propellerForce?.IsA('VectorForce')) propellerForce.Force = totalCubeForce.mul(gravity).mul(dt * 40 * cubeMultiplier);
    
    const headPropeller = cube.FindFirstChild('Head')?.FindFirstChild('PropellerForce');
    if (headPropeller?.IsA('VectorForce')) headPropeller.Force = totalHeadForce.mul(gravity).mul(dt * 10 * headMultiplier);
});