import {
	UserInputService,
	Players,
} from '@rbxts/services';

import { MouseImageIcon } from 'shared/utils';

const player = Players.LocalPlayer;

const GUI = player.WaitForChild('PlayerGui');
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const mouseIcon = screenGui.WaitForChild('MouseIcon') as ImageLabel;

const draggableObjects = [  ] as GuiObject[];

let draggedObject = undefined as (GuiObject | undefined);
let isHolding = false;

function newObject(object: Instance) {
	if (!object.IsA('GuiObject')) return;
	
	if (object.GetAttribute('draggable')) draggableObjects.push(object);
}

function mouseMoved(position: Vector2, isTouch: boolean) {
	if (mouseIcon.Visible && (mouseIcon.Image === MouseImageIcon.DragActive || mouseIcon.Image === MouseImageIcon.DragHover)) {
		mouseIcon.Visible = false;
		mouseIcon.Rotation = 0;
	}
	
	let didFindHoveredObject = false;
	for (const object of draggableObjects) {
		let isVisible = true;
		
		let parent = object as (Instance | undefined);
		while (parent && parent !== GUI) {
			if (parent.IsA('GuiObject') && !parent.Visible) {
				isVisible = false;
				break;
			}
			
			parent = parent.Parent;
		}
		
		if (!isVisible) {
			if (object.GetAttribute('isDragging')) object.SetAttribute('isDragging', undefined);
			break;
		}
		
		const absolutePosition = object.AbsolutePosition;
		const absoluteSize = object.AbsoluteSize;
		
		if (!didFindHoveredObject && (draggedObject === object || (!draggedObject && position.Max(absolutePosition).Min(absolutePosition.add(absoluteSize)) === position))) {
			didFindHoveredObject = true;
			
			if (isHolding) {
				draggedObject = object;
				if (!object.GetAttribute('isDragging')) object.SetAttribute('isDragging', true);
			} else {
				draggedObject = undefined;
				if (object.GetAttribute('isDragging')) object.SetAttribute('isDragging', undefined);
			}
			
			if (!isTouch && !mouseIcon.Visible) {
				mouseIcon.Visible = true;
				mouseIcon.AnchorPoint = new Vector2(0.5, 0.5);
				mouseIcon.Image = isHolding ? MouseImageIcon.DragActive : MouseImageIcon.DragHover;
				mouseIcon.Rotation = -35;
				mouseIcon.Size = UDim2.fromOffset(23, 25);
			}
		} else {
			if (object.GetAttribute('isDragging')) object.SetAttribute('isDragging', undefined);
		}
	}
}

for (const descendant of GUI.GetDescendants()) newObject(descendant);
GUI.DescendantAdded.Connect(newObject);

UserInputService.InputBegan.Connect((input) => {
	if (input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
		isHolding = true;
		mouseMoved(new Vector2(input.Position.X, input.Position.Y), input.UserInputType === Enum.UserInputType.Touch);
	}
});

UserInputService.InputEnded.Connect((input) => {
	if (input.UserInputType === Enum.UserInputType.MouseButton1 || input.UserInputType === Enum.UserInputType.Touch) {
		isHolding = false;
		draggedObject = undefined;
		mouseMoved(new Vector2(input.Position.X, input.Position.Y), input.UserInputType === Enum.UserInputType.Touch);
	}
});

UserInputService.TouchMoved.Connect((touch) => {
	mouseMoved(new Vector2(touch.Position.X, touch.Position.Y), true);
});

UserInputService.InputChanged.Connect((input) => {
	if (input.UserInputType === Enum.UserInputType.MouseMovement) {
		mouseMoved(new Vector2(input.Position.X, input.Position.Y), false);
	}
});