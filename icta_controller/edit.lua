--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Formspec edit command

]]--

function techage.edit_command(fs_data, text)
	local cmnd, pos1, pos2 = text:match('^(%S)%s(%d+)%s(%d+)$')
	if pos2 == nil then
		cmnd, pos1 = text:match('^(%S)%s(%d+)$')
	end
	if cmnd and pos1 and pos2 then
		pos1 = math.max(1, math.min(pos1, techage.NUM_RULES))
		pos2 = math.max(1, math.min(pos2, techage.NUM_RULES))

		if cmnd == "x" then
			local temp = fs_data[pos1]
			fs_data[pos1] = fs_data[pos2]
			fs_data[pos2] = temp
			return "rows "..pos1.." and "..pos2.." exchanged"
		end
		if cmnd == "c" then
			fs_data[pos2] = table.copy(fs_data[pos1])
			return "row "..pos1.." copied to "..pos2
		end
	elseif cmnd == "d" and pos1 then
		pos1 = math.max(1, math.min(pos1, techage.NUM_RULES))
		fs_data[pos1] = {}
		return "row "..pos1.." deleted"
	end
	return "Invalid command '"..text.."'"
end
