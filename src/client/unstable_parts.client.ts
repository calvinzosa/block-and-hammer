import {
	Workspace,
} from '@rbxts/services';

const unstableParts = new Instance('Folder');
unstableParts.Name = 'UnstableParts';

const nonBreakable = Workspace.WaitForChild('NonBreakable') as Folder;
const unstablePartsFolder = nonBreakable.WaitForChild('UnstableParts') as Folder;

task.wait(5);

for (const part of unstablePartsFolder.GetChildren()) {
	if (!part.IsA('BasePart')) continue;
	
	const clone = part.Clone();
	
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
}

unstablePartsFolder.Destroy();
unstableParts.Parent = nonBreakable;