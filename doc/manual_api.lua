--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	API to add further chapters to the manuals

]]--

function techage.add_to_manual(language, titles, texts, items, plans)
	local tbl

	if language == "DE" then
		tbl = techage.manual_DE
	elseif language == "EN" then
		tbl = techage.manual_EN
	else
		minetest.log("error", "[techage] Invalid manual language provided for 'techage.add_to_manual'!")
		return
	end

	for _, item in ipairs(titles) do
		tbl.aTitel[#tbl.aTitel + 1] = item
	end
	for _, item in ipairs(texts) do
		tbl.aText[#tbl.aText + 1] = item
	end
	for _, item in ipairs(items) do
		tbl.aItemName[#tbl.aItemName + 1] = item
	end
	for _, item in ipairs(plans) do
		tbl.aPlanTable[#tbl.aPlanTable + 1] = item
	end
end
