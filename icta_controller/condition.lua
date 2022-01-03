--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Condition Registration

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic

-- tables with all data from condition registrations
local kvRegisteredCond = {}

-- list of keys for conditions
local aCondTypes = {}

-- list of titles for conditions
local aCondTitles = {}

--
-- API functions for condition registrations
--
function techage.icta_register_condition(key, tData)
	table.insert(aCondTypes, key)
	table.insert(aCondTitles, tData.title)
	if kvRegisteredCond[key] ~= nil then
		print("[Techage] Condition registration error "..key)
		return
	end
	kvRegisteredCond[key] = tData
	for _,item in ipairs(tData.formspec) do
		if item.type == "textlist" then
			item.tChoices = string.split(item.choices, ",")
			item.num_choices = #item.tChoices
		end
	end
end

-- return formspec string
function techage.cond_formspec(row, kvSelect)
	return techage.submenu_generate_formspec(
		row, "cond", "Condition type", aCondTypes, aCondTitles, kvRegisteredCond, kvSelect)
end

-- evaluate the row condition input
-- and return new data
function techage.cond_eval_input(kvSelect, fields)
	kvSelect = techage.submenu_eval_input(kvRegisteredCond, aCondTypes, aCondTitles, kvSelect, fields)
	return kvSelect
end

-- return the Lua code
function techage.code_condition(kvSelect, environ)
	if kvSelect and kvRegisteredCond[kvSelect.choice] then
		if techage.submenu_verify(environ.owner, kvRegisteredCond, kvSelect) then
			return kvRegisteredCond[kvSelect.choice].code(kvSelect, environ)
		end
	end
	return nil, nil
end

techage.icta_register_condition("default", {
	title = "",
	formspec = {},
	code = function(data, environ)
		local condition = function(env, idx)
			return false
		end
		local result = function(val)
			return false
		end
		return condition, result
	end,
	button = function(data, environ) return "..." end,
})
