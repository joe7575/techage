local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local DAYS_VALID = (30 * 72) -- 30 real days

local storage = minetest.get_mod_storage()

local function data_maintenance()
	minetest.log("info", "[MOD] minecart maintenance")
	local day_count = minetest.get_day_count()
	local tbl = storage:to_table()
	for key,s in pairs(tbl.fields) do
		local route = minetest.deserialize(s)
		if not route.waypoints or not route.best_before or route.best_before < day_count then
			storage:set_string(key, "")
		else
			minetest.log("info", "[minecart] Route: start="..key.." length="..#(route.waypoints))
		end
	end
end
minetest.after(1, data_maintenance)


-- Store data of running carts
minecart.CartsOnRail = {}

for key,val in pairs(minetest.deserialize(storage:get_string("CartsOnRail")) or {}) do
	-- use invalid keys to force the cart spawning
	minecart.CartsOnRail[-key] = val
end

minetest.register_on_shutdown(function()
	data_maintenance()
	storage:set_string("CartsOnRail", minetest.serialize(minecart.CartsOnRail))
end)

-- All positions as "pos_to_string" string
--Routes = {
--	  start_pos = {
--        waypoints = {{spos, svel}, {spos, svel}, ...}, 
--        dest_pos = spos,
--        junctions = {
--            {spos = num}, 
--            {spos = num},
--        },
--        best_before = num
--    },
--	  start_pos = {...},
--}
local Routes = {}
local NEW_ROUTE = {waypoints = {}, junctions = {}}

function minecart.store_route(key, route)
	Routes[key] = table.copy(route)
	Routes[key].best_before = minetest.get_day_count() + DAYS_VALID
	storage:set_string(key, minetest.serialize(Routes[key]))
end

function minecart.get_route(key)
	Routes[key] = Routes[key] or minetest.deserialize(storage:get_string(key)) or NEW_ROUTE
	Routes[key].best_before = minetest.get_day_count() + DAYS_VALID
	return Routes[key]
end

function minecart.del_route(key)
	Routes[key] = nil  -- remove from memory
	storage:set_string(key, "") -- and from storage
end


