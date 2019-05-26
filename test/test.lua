local function bubble(pos1, pos2, posc, amount)
	local radius = math.floor(math.pow(amount, 0.333))
	local xc = pos2.x - pos1.x
	for x = posc.x - radius, posc.x + radius do
		for y = posc.y - radius, posc.y + radius do
			for z = posc.z - radius, posc.z + radius do
				local idx = x - pos1.x +
					(y - pos1.y) * 16 +
					(z - pos1.z) * 16 * 16
print()
