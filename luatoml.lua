require "util"
pprint = require "pl.pretty"

debug = false

function strip(str) 
	return string.format( "%s", str:match( "^%s*(.-)%s*$" ) ) 
end
function replace_char(pos, str, r)
    return ("%s%s%s"):format(str:sub(1,pos-1), r, str:sub(pos+1))
end
function splitLineToGroupArray(line)
	local retVal = {}
	local i = 1
	for group in string.gmatch(line, "[^.]+") do
		retVal[i] = group
		i = i + 1
	end
	return retVal
end
function tableSize(table)
	local size = 0
	for i, v in pairs(table) do
		size = size + 1
	end
	return size
end
function splitLine(str)
	local openArr = 0
	local openString = false
	local beginLine = true
	local keyGroup = false
	local delNum = 1
	for i = 1, #str do
		local char = string.sub(str, i, i)
		
		if char == '"' and string.sub(str, i-1, i-1) ~= '\\' then
			openString = not openString
		end
		if keyGroup and (char == ' ' or char == '\t') then
			keyGroup = false
		end
		if char == '#' and not openString and not keyGroup then
			local j = i
			while string.sub(str, j, j) ~= '\n' do
				str = replace_char(j, str, ' ')
				j = j + 1
			end
		end
		if char == '[' and not openString and not keyGroup then
			if beginLine then 
				keyGroup = true
			else
				openArr = openArr + 1
			end
		end
		if char == ']' and not openString and not keyGroup then
			if keyGroup then
				keyGroup = false
			else
				openArr = openArr - 1
			end
		end
		if char == '\n' then
			if openString then error("Unbalanced Quotes") end
			if openArr ~= 0 then 
				str = replace_char(i, str, ' ') 
			else
				beginLine = true
			end			
		elseif beginLine and char ~= ' ' and char ~= '\t' then
			beginLine = false
			keyGroup = true
		else 
		end	
	end -- end of for loop
	return str
	-- for w in string.gmatch(str, "[^\n]+") do print(w) end
end
function splitAssignment(str)
	local retVal = {}
	local i = 1
	for group in string.gmatch(str, "[^=]+") do
		retVal[i] = group
		i = i + 1
	end
	return retVal
end

function load(str)
	--[[--
	Load a TOML string into Lua object (deserialization)
	
	@Parameter: str
		The str which is parsed in as TOML
	
	@Returns: A table of nested components of TOML string
	--]]--
	local implicitGroups = {}
	local retVal = {}
	local currentLevel = retVal
	str = splitLine(str)
	for line in string.gmatch(str, "[^\n]+") do
		line = strip(line)
		if string.sub(line, 1, 1) == '[' then
			line = string.sub(line, 2, #line-1) -- key group name
			currentLevel = retVal
			-- for group in string.gmatch(line, "[^.]+") do
			-- 	if group == "" then error("Can't have keygroup with empty name") end
			-- 	if currentLevel[group] ~= nil then
			-- 		if i == 
			-- 	else
			-- 		
			-- 	end
			-- end
			groups = splitLineToGroupArray(line)
			for i, group in ipairs(groups) do
				if group == "" then error("Can't have keygroup with empty name") end
				if currentLevel[group] ~= nil then
					if i == tableSize(groups) then
						if implicitGroups[group] ~= nil then
							implicitGroups[group] = nil
						else
							error("Group existed")
						end
					end
				else
					if i ~= tableSize(groups) then
						implicitGroups[group] = true
					end
					currentLevel[group] = {}
				end
				currentLevel = currentLevel[group]
			end -- end of for loop
		
		elseif line:match("=") ~= nil then
			assignment = splitAssignment(line)
			variable = strip(assignment[1])
			value = strip(assignment[2])
			loadedVal = load_value(value)
			value = loadedVal["value"]
			if currentLevel[variable] ~= nil then
				error("Duplicated key")
			else
				currentLevel[variable] = value
			end
		end
	end
	-- pprint.dump(retVal)
	return retVal
end

function load_value(v)
	-- boolean
	if v == "true" then 
		return { value=true, type="boolean" }
	-- boolean
	elseif v == "false" then
		return { value=false, type="boolean" }
	-- string, handle simple string for now
	elseif string.sub(v, 1, 1) == '"' then
		local lengthV = string.len(v)
		local str = string.sub(v, 2, lengthV-1)
		return { value=str, type="string" }
	-- array
	elseif string.sub(v, 1, 1) == '[' then
		return { value=load_array(v), type="table" }
	-- datetime, handle as string for now
	elseif string.len(v) == 20 and string.sub(v, 20, 20) == 'Z' then
		local lengthV = string.len(v)
		local str = string.sub(v, 1, lengthV-1)
		return { value=str, type="string" }
	-- number
	else
		local negative = false
		if string.sub(v, 1, 1) == '-' then
			negative = true
			local lengthV = string.len(v)
			v = string.sub(v, 2, lengthV)
		end
		v = tonumber(v)
		if negative then v = 0 - v end		
		return { value=v, type="number" }			
	end
end	

function load_array(a)
	local retVal = {}
	-- strip beginning/trailing whitespace
	a = string.format( "%s", a:match( "^%s*(.-)%s*$" ) ) 
	a = string.sub(a, 2, #a - 1)
	local newArr = {}
	local openArr = 0
	local j = 1
	local index = 1
	for i = 1, #a do
		local char = string.sub(a, i, i)
		-- print(char)
		if char == "[" then
			openArr = openArr + 1
		elseif char == "]" then
			openArr = openArr - 1
		elseif char == "," and openArr == 0 then
			-- print(string.sub(a, j, i-1))
			local subStr = string.sub(a, j, i-1)
			subStr = string.format( "%s", subStr:match( "^%s*(.-)%s*$" ) ) 
			newArr[index] = subStr
			j = i + 1
			index = index + 1
		end
	end
	local subStr = string.sub(a, j, #a)
	subStr = string.format( "%s", subStr:match( "^%s*(.-)%s*$" ) ) 
	newArr[index] = subStr
	
	local aType = nil
	local index = 1
	for i, v in ipairs(newArr) do
		if v ~= '' then
			-- print(v)
			local loadedVal = load_value(v)
			-- pprint.dump(loadedVal)
			local nVal = loadedVal["value"]
			local nType = loadedVal["type"]
			-- print(nVal)
			-- print(nType)
			if aType then
				if aType ~= nType then
					error("Not homogeneous array")
				end
			else
				aType = nType
			end
			retVal[index] = nVal
			index = index + 1
		end
	end
	return retVal
end	

function dump(obj)
	--[[--
	Dump Lua object into TOML string (serialization)
	
	@Parameter: obj
		The Lua table
	
	@Returns: A TOML string
	--]]--
	local addToSections
	local retVal = ""
	local dumpedSection = dump_section(obj)
	local addToRetVal = dumpedSection["retStr"]
	local sections = dumpedSection["retDict"]
	retVal = retVal .. addToRetVal
	
	while tableSize(sections) ~= 0 do
		local newSections = {}
		for section, value in pairs(sections) do
			dumpedSection = dump_section(sections[section])
			addToRetVal = dumpedSection["retStr"]
			addToSections = dumpedSection["retDict"]
			if addToRetVal ~= nil then
				retVal = retVal .. "[" .. section .. "]\n"
				retVal = retVal .. addToRetVal
			end
			for s, value in pairs(addToSections) do
				newSections[section .. "." .. s] = addToSections[s]
			end
		end
		sections = newSections
	end
	return retVal
end	

function dump_section(obj)
	local retStr = ""
	local retDict = {}
	for i, section in pairs(obj) do
		if type(obj[i]) ~= "table" then
			retStr = retStr .. i .. " = " 
			retStr = retStr .. dump_value(obj[i]) .. '\n'
		else
			retDict[i] = obj[i]
		end
	end
	return { retStr=retStr, retDict=retDict }
end

function dump_value(v)
	if type(v) == "string" then
		local retStr = '"' .. v .. '"'
		return retStr
	elseif type(v) == "boolean" then
		return tostring(v)
	else
		return v
	end
end
