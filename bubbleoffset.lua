_addon.name = "BubbleOffset"
_addon.author = "Uwu/Darkdoom"
_addon.version = "1.0"
_addon.command= "bubble"

local packets = require('packets')
local Offset_Location = ""
local tBubbles = {
	798, 799, 800, 801, 802,
	803, 804, 805, 806, 807,
	808, 809, 810, 811, 812,
	813, 814, 815, 816, 817,
	818, 819, 820, 821, 822,
	823, 824, 825, 826, 827,
}

function HasValue(tab, val)

	for index, value in ipairs(tab) do

		if value == val then

		return true

		end

	end
 
   return false

end

windower.register_event('addon command', function(...)

	local args = {...}
	local c = args[1] or false

	if c then

		c = c:lower()

		if c == "front" then

			Offset_Location = "Front"
			windower.add_to_chat(124, "Bubbles will now be offset in front of enemies!")

		elseif c == "side" then

			Offset_Location = "Side"
			windower.add_to_chat(124, "Bubbles will now be offset to the side of enemies!")

		end

	end

end)

windower.register_event('outgoing chunk', function(id, data)

	if id == 0x01A then
		
		local action = packets.parse('outgoing', data)

		if HasValue(tBubbles, action["Param"]) then

			local new_action = OffsetBubble(action["Target"], action["Param"], action["Category"])
			windower.add_to_chat(124, "Attempting to offset bubble with offsets of " .. "X: " .. new_action["X Offset"] .. " Z: " .. new_action["Z Offset"]) 
			return packets.build(new_action)
			
		end

	end

end)
 
function GetDirection(rotation)

	if rotation >= 0 and rotation < 0.8 then
		
		return "East"

	elseif rotation > 0.8 and rotation < 1.6 then

		return "Southeast"

	elseif rotation > 1.6 and rotation < 2.4 then

		return "South"

	elseif rotation > 2.4 and rotation < 3.2 then

		return "Southwest"

	elseif rotation > 3.2 and rotation < 3.8 then

		return "West"

	elseif rotation > 3.8 and rotation < 4.6 then

		return "Northwest"

	elseif rotation > 4.6 and rotation < 5.4 then

		return "North"

	elseif rotation > 5.4 and rotation < 6.2 then

		return "Northeast"

	end

end

		--north = +z, south = -z, east = +x, west = -x
		--east = 0,  s = 60, w = 120, n = 180
function BuildSideOffset(direction)

	local offset = {["X"] = 0, ["Z"] = 0}

	if direction == "East" then
		
		offset["Z"] = 2.5
		return offset

	elseif direction == "Northeast" then

		offset["X"] = -2.5
		offset["Z"] = 2.5
		return offset

	elseif direction == "North" then

		offset["X"] = 2.5
		return offset

	elseif direction == "Northwest" then
		
		offset["Z"] = 2.5
		offset["X"] = 2.5
		return offset
	
	elseif direction == "West" then

		offset["Z"] = -2.5
		return offset

	elseif direction == "Southwest" then

		offset["X"] = 2.5
		offset["Z"] = -2.5
		return offset

	elseif direction == "South" then

		offset["X"] = -2.5
		return offset

	elseif direction == "Southeast" then

		offset["Z"] = -2.5
		offset["X"] = -2.5
		return offset

	end

end

function BuildFrontOffset(direction)

	local offset = {["X"] = 0, ["Z"] = 0}

	if direction == "East" then
		
		offset["X"] = 1
		return offset

	elseif direction == "Northeast" then

		offset["X"] = 1
		offset["Z"] = 1
		return offset

	elseif direction == "North" then

		offset["Z"] = 1
		return offset

	elseif direction == "Northwest" then
		
		offset["Z"] = 1
		offset["X"] = -1
		return offset
	
	elseif direction == "West" then

		offset["X"] = -1
		return offset

	elseif direction == "Southwest" then

		offset["X"] = -1
		offset["Z"] = -1
		return offset

	elseif direction == "South" then

		offset["Z"] = -1
		return offset

	elseif direction == "Southeast" then

		offset["Z"] = -1
		offset["X"] = 1
		return offset

	end

end

function OffsetBubble(target, param, category)

	if target and param and category then
		--north = +z, south = -z, east = +x, west = -x
		--east = 0,  s = 60, w = 120, n = 180
		local mob = windower.ffxi.get_mob_by_id(target)
		local mob_direction = GetDirection(mob.facing)

		local offset = ""
		
		if Offset_Location == "Front" then

			offset = BuildFrontOffset(mob_direction)
		
		elseif Offset_Location == "Side" then

			offset = BuildSideOffset(mob_direction)

		end

		if offset ~= "" then

			local action = packets.new('outgoing', 0x01A)
			action["Target"] = target
			action["Target Index"] = windower.ffxi.get_mob_by_id(target).index
			action["Category"] = category
			action["Param"] = param
			action["X Offset"] = offset["X"]
			action["Z Offset"] = offset["Z"]
		
			return action

		end
		
	end

end

