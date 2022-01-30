--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-------------------------------------------------------------------
-- Marshaling: Returns serialize, deserialize functions
-------------------------------------------------------------------
local use_marshal = minetest.settings:get_bool('techage_use_marshal', false)
local MAR_MAGIC = 0x8e
local marshal = techage.IE.require("marshal")

if use_marshal then
	if not techage.IE then
		error("Please add 'secure.trusted_mods = techage' to minetest.conf!")
	end
	marshal = techage.IE.require("marshal")
	if not marshal then
		error("Please install marshal via 'luarocks install lua-marshal'")
	end
elseif techage.IE then
	marshal = techage.IE.require("marshal")
end

if marshal then
	return marshal.encode, 
		function(s)
			if s ~= "" then
				if s:byte(1) == MAR_MAGIC then
					return marshal.decode(s)
				else
					return minetest.deserialize(s)
				end
			end
		end
else
	return minetest.serialize,
		function(s)
			if s ~= "" then
				if s:byte(1) == MAR_MAGIC then
					error("'lua-marshal' is required to deserialize this string")
				else
					return minetest.deserialize(s)
				end
			end
		end
end