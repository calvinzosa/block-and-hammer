local totalTags = {}
local duplicates = 0
local count = 0

for _, part in workspace.Map:GetDescendants() do
    if part:IsA('BasePart') then
        local foundTag = nil
        for _, tag in part:GetTags() do
            if tag:find('mapPart-') == 1 then
				foundTag = tag
            end
        end
        if not foundTag then
			foundTag = 'mapPart-' .. game.HttpService:GenerateGUID(false)
			
            count += 1
		end
		
		local isDuplicate = false
		while table.find(totalTags, foundTag) do
			foundTag = 'mapPart-' .. game.HttpService:GenerateGUID(false)
			isDuplicate = true
		end
		table.insert(totalTags, foundTag)
		
		if isDuplicate then
			duplicates += 1
		end
		
		for _, tag in part:GetTags() do
			if tag:find('mapPart-') == 1 then
				part:RemoveTag(tag)
			end
		end
		
		part:AddTag(foundTag)
    end
end

print(count, duplicates)