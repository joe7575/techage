function techage.range(val, min, max)
	val = tonumber(val)
	if val < min then return min end
	if val > max then return max end
	return val
end

function techage.one_of(val, selection)
	for _,v in ipairs(selection) do
		if val == v then return val end
	end
	return selection[1]
end

