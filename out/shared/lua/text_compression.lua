-- Module by 1waffle1 and boatbomber, optimized and fixed by iiau
-- https://devforum.roblox.com/t/text-compression/163637/37

local dictionary = {} -- key to len

do -- populate dictionary
	local length = 0
	for i = 32, 127 do
		if i ~= 34 and i ~= 92 then
			local c = string.char(i)
			dictionary[c] = length
			dictionary[length] = c
			length = length + 1
		end
	end
end

local escapemap_126, escapemap_127 = {}, {}
local unescapemap_126, unescapemap_127 = {}, {}

local blacklisted_126 = { 34, 92 }
for i = 126, 180 do
	table.insert(blacklisted_126, i)
end

do -- Populate escape map
	-- represents the numbers 0-31, 34, 92, 126, 127 (36 characters)
	-- and 128-180 (52 characters)
	-- https://devforum.roblox.com/t/text-compression/163637/5
	for i = 0, 31 + #blacklisted_126 do
		local b = blacklisted_126[i - 31]
		local s = i + 32
		
		-- Note: 126 and 127 are magic numbers
		local c = string.char(b or i)
		local e = string.char(s + (s >= 34 and 1 or 0) + (s >= 91 and 1 or 0))
		
		escapemap_126[c] = e
		unescapemap_126[e] = c
	end
	
	for i = 1, 255 - 180 do
		local c = string.char(i + 180)
		local s = i + 34
		local e = string.char(s + (s >= 92 and 1 or 0))
		
		escapemap_127[c] = e
		unescapemap_127[e] = c
	end
end

local function escape(s)
	-- escape the control characters 0-31, double quote 34, backslash 92, Tilde 126, and DEL 127 (36 chars)
	-- escape characters 128-180 (53 chars)
	return string.gsub(string.gsub(s, '[%c"\\\126-\180]', function(c)
		return "\126" .. escapemap_126[c]
	end), '[\181-\255]', function(c)
		return "\127" .. escapemap_127[c]
	end)
end
local function unescape(s)
	return string.gsub(string.gsub(s, "\127(.)", function(e)
		return unescapemap_127[e]
	end), "\126(.)", function(e)
		return unescapemap_126[e]
	end)
end

local b93Cache = {}
local function tobase93(n)
	local value = b93Cache[n]
	if value then
		return value
	end
	
	local c = n
	value = ""
	repeat
		local remainder = n % 93
		value = dictionary[remainder] .. value
		n = (n - remainder) / 93
	until n == 0
	
	b93Cache[c] = value
	return value
end

local b10Cache = {}
local function tobase10(value)
	local n = b10Cache[value]
	if n then
		return n
	end
	
	n = 0
	for i = 1, #value do
		n = n + math.pow(93, i - 1) * dictionary[string.sub(value, -i, -i)]
	end
	
	b10Cache[value] = n
	return n
end

local function compress(text)
	assert(type(text) == "string", "bad argument #1 to 'compress' (string expected, got " .. typeof(text) .. ")")
	local dictionaryCopy = table.clone(dictionary)
	local key, sequence, size = "", {}, #dictionary
	
	local width, spans, span = 1, {}, 0
	local function listkey(k)
		local value = tobase93(dictionaryCopy[k])
		local valueLength = #value
		if valueLength > width then
			width, span, spans[width] = valueLength, 0, span
		end
		table.insert(sequence, string.rep(" ", width - valueLength) .. value)
		span += 1
	end
	text = escape(text)
	for i = 1, #text do
		local c = string.sub(text, i, i)
		local new = key .. c
		if dictionaryCopy[new] then
			key = new
		else
			listkey(key)
			key = c
			size += 1
			dictionaryCopy[new] = size
			dictionaryCopy[size] = new
		end
	end
	listkey(key)
	spans[width] = span
	return table.concat(spans, ",") .. "|" .. table.concat(sequence)
end

local function decompress(text)
	assert(type(text) == "string", "bad argument #1 to 'decompress' (string expected, got " .. typeof(text) .. ")")
	local dictionaryCopy = table.clone(dictionary)
	local sequence, spans, content = {}, string.match(text, "(.-)|(.*)")
	local groups, start = {}, 1
	for span in string.gmatch(spans, "%d+") do
		local width = #groups + 1
		groups[width] = string.sub(content, start, start + span * width - 1)
		start = start + span * width
	end
	local previous
	
	for width, group in ipairs(groups) do
		for value in string.gmatch(group, string.rep(".", width)) do
			local entry = dictionaryCopy[tobase10(value)]
			if previous then
				if entry then
					table.insert(dictionaryCopy, previous .. string.sub(entry, 1, 1))
				else
					entry = previous .. string.sub(previous, 1, 1)
					table.insert(dictionaryCopy, entry)
				end
				table.insert(sequence, entry)
			else
				sequence[1] = entry
			end
			previous = entry
		end
	end
	return unescape(table.concat(sequence))
end

return { compress = compress, decompress = decompress }