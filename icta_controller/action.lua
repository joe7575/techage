--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Action Registration

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic




-- tables with all data from action registrations
local kvRegisteredActn = {}

-- list of keys for actions
local aActnTypes = {}

-- list of titles for actions
local aActnTitles = {}

--
-- API function for action registrations
--
function techage.icta_register_action(key, tData)
	table.insert(aActnTypes, key)
	table.insert(aActnTitles, tData.title)
	tData.__idx__ = #aActnTypes
	if kvRegisteredActn[key] ~= nil then
		print("[Techage] Action registration error "..key)
		return
	end
	kvRegisteredActn[key] = tData
	for _,item in ipairs(tData.formspec) do
		if item.type == "textlist" then
			item.tChoices = string.split(item.choices, ",")
			item.num_choices = #item.tChoices
		end
	end
end

-- return formspec string
function techage.actn_formspec(row, kvSelect)
	return techage.submenu_generate_formspec(
		row, "actn", "Action type", aActnTypes, aActnTitles, kvRegisteredActn, kvSelect)
end

-- evaluate the row action input
-- and return new data
function techage.actn_eval_input(kvSelect, fields)
	kvSelect = techage.submenu_eval_input(kvRegisteredActn, aActnTypes, aActnTitles, kvSelect, fields)
	return kvSelect
end


-- return the Lua code
function techage.code_action(kvSelect, environ)
	if kvSelect and kvRegisteredActn[kvSelect.choice] then
		if techage.submenu_verify(environ.owner, kvRegisteredActn, kvSelect) then
			return kvRegisteredActn[kvSelect.choice].code(kvSelect, environ)
		end
	end
	return nil
end

techage.icta_register_action("default", {
	title = "",
	formspec = {},
	code = function(data, environ) return false, false end,
	button = function(data, environ) return "..." end,
})

techage.icta_register_action("print", {
	title = "print to output window",
	formspec = {
		{
			type = "ascii",
			name = "text",
			label = "Output the following text",
			default = "",
		},
		{
			type = "label",
			name = "lbl",
			label = "Use a '*' character as reference to any\ncondition state",
		},
	},
	button = function(data, environ)
		return 'print("'..data.text:sub(1,12)..'")'
	end,
	code = function(data, environ)
		return function(env, output, idx)
			local text = string.gsub(data.text, "*", tostring(env.result[idx]))
			output(env.pos, text)
		end
	end,
})
