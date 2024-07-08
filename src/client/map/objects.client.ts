import {
	ReplicatedStorage,
	Workspace,
} from '@rbxts/services';

const Events = {
	ClientReset: ReplicatedStorage.WaitForChild('ClientReset') as BindableEvent,
};

const mapFolder = Workspace.WaitForChild('Map') as Folder;
const nonBreakable = Workspace.WaitForChild('NonBreakable') as Folder;
const unstablePartsFolder = nonBreakable.WaitForChild('UnstableParts') as Folder;
const unanchoredPartsFolder = mapFolder.WaitForChild('Unanchored') as Folder;

const unstableParts = new Instance('Folder');
const unanchoredParts = new Instance('Folder');

unstablePartsFolder.Name = `server-${unstablePartsFolder.Name}`;
unstableParts.Name = 'UnstableParts';
unstableParts.Parent = nonBreakable;

unanchoredPartsFolder.Name = `server-${unanchoredPartsFolder.Name}`;
unanchoredParts.Name = 'UnanchoredParts'
unanchoredParts.Parent = mapFolder;

function newPart(part: Instance) {
	if (part.Parent === unstablePartsFolder) {
		if (!part.IsA('BasePart')) return;
		
		const clone = part.Clone();
		clone.CollisionGroup = 'objects';
		
		const attachment = new Instance('Attachment', clone);
		
		const alignOrientation = new Instance('AlignOrientation');
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment;
		alignOrientation.Attachment0 = attachment;
		alignOrientation.CFrame = part.CFrame.Rotation;
		alignOrientation.RigidityEnabled = true;
		alignOrientation.Parent = attachment;
		
		const alignPosition = new Instance('AlignPosition');
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment;
		alignPosition.Attachment0 = attachment;
		alignPosition.Position = part.Position;
		alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis;
		alignPosition.MaxAxesForce = new Vector3(math.huge, 495000, math.huge);
		alignPosition.MaxVelocity = 300;
		alignPosition.Responsiveness = 35;
		alignPosition.Enabled = false;
		alignPosition.Parent = attachment;
		
		task.delay(0.5, () => {
			clone.Position = part.Position;
			clone.AssemblyLinearVelocity = Vector3.zero;
			alignPosition.Enabled = true;
		});
		
		clone.Anchored = false;
		clone.Parent = unstableParts;
	} else if (part.Parent === unanchoredPartsFolder) {
		const clone = part.Clone();
		clone.Parent = unanchoredParts;
		
		if (clone.IsA('PVInstance')) {
			clone.SetAttribute('_pivot', clone.GetPivot());
			if (clone.IsA('BasePart')) {
				clone.CollisionGroup = 'objects';
				clone.SetAttribute('_linearvelocity', clone.AssemblyLinearVelocity);
				clone.SetAttribute('_angularvelocity', clone.AssemblyAngularVelocity);
			}
		}
		
		for (const descendant of clone.GetDescendants()) {
			if (descendant.IsA('BasePart')) {
				descendant.CollisionGroup = 'objects';
				descendant.SetAttribute('_linearvelocity', descendant.AssemblyLinearVelocity);
				descendant.SetAttribute('_angularvelocity', descendant.AssemblyAngularVelocity);
			}
		}
	}
	
	part.Destroy();
}

Events.ClientReset.Event.Connect(() => {
	for (const part of unanchoredPartsFolder.GetChildren()) {
		if (part.IsA('PVInstance')) {
			const pivot = part.GetAttribute('_pivot');
			if (typeIs(pivot, 'CFrame')) {
				part.PivotTo(pivot);
				
				if (part.IsA('BasePart')) {
					const linearVelocity = part.GetAttribute('_linearvelocity');
					if (typeIs(linearVelocity, 'Vector3')) part.AssemblyLinearVelocity = linearVelocity;
					
					const angularVelocity = part.GetAttribute('_angularvelocity');
					if (typeIs(angularVelocity, 'Vector3')) part.AssemblyAngularVelocity = angularVelocity;
				}
			}
		}
	}
});

for (const part of unstablePartsFolder.GetChildren()) newPart(part);
for (const part of unanchoredPartsFolder.GetChildren()) newPart(part);

unstablePartsFolder.ChildAdded.Connect(newPart);
unanchoredPartsFolder.ChildAdded.Connect(newPart);