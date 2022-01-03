--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg
	Copyright (C) 2020 Thomas S.

	AGPL v3
	See LICENSE.txt for more information

	Fake Player

]]--

-- Map method names to their return values
local methods = {
	get_pos = { x = 0, y = 0, z = 0 },
	set_pos = nil,
	moveto = nil,
	punch = nil,
	right_click = nil,
	get_hp = 20,
	set_hp = nil,
	get_inventory = nil,
	get_wield_list = "",
	get_wield_index = 0,
	get_wielded_item = ItemStack(),
	set_wielded_item = true,
	set_armor_groups = nil,
	get_armor_groups = {},
	set_animation = nil,
	get_animation = {},
	set_animation_frame_speed = nil,
	set_attach = nil,
	get_attach = nil,
	set_detach = nil,
	get_bone_position = {},
	set_properties = nil,
	get_properties = {},
	is_player = false,
	get_nametag_attributes = {},
	set_nametag_attributes = nil,
	get_player_name = "",
	get_player_velocity = nil,
	add_player_velocity = nil,
	get_look_dir = vector.new(0, 0, 1),
	get_look_vertical = 0,
	get_look_horizontal = 0,
	set_look_vertical = nil,
	set_look_horizontal = nil,
	get_look_pitch = 0,
	get_look_yaw = 0,
	set_look_pitch = nil,
	set_look_yaw = nil,
	get_breath = 10,
	set_breath = nil,
	set_fov = nil,
	get_fov = 0,
	set_attribute = nil,
	get_attribute = nil,
	get_meta = nil,
	set_inventory_formspec = nil,
	get_inventory_formspec = "",
	set_formspec_prepend = nil,
	get_formspec_prepend = "",
	get_player_control = {},
	get_player_control_bits = 0,
	set_physics_override = nil,
	get_physics_override = {},
	hud_add = 0,
	hud_remove = nil,
	hud_change = nil,
	hud_get = {},
	hud_set_flags = nil,
	hud_get_flags = {},
	hud_set_hotbar_itemcount = nil,
	hud_get_hotbar_itemcount = 8,
	hud_set_hotbar_image = nil,
	hud_get_hotbar_image = "",
	hud_set_hotbar_selected_image = nil,
	hud_get_hotbar_selected_image = "",
	set_sky = nil,
	get_sky = {},
	get_sky_color = {},
	set_sun = nil,
	get_sun = {},
	set_moon = nil,
	get_moon = {},
	set_stars = nil,
	get_stars = {},
	set_clouds = nil,
	get_clouds = {},
	override_day_night_ratio = nil,
	get_day_night_ratio = nil,
	set_local_animation = nil,
	get_local_animation = {},
	set_eye_offset = nil,
	get_eye_offset = {},
	send_mapblock = nil,
}

techage.Fake_player = {}
techage.Fake_player.__index = techage.Fake_player

function techage.Fake_player:new()
	local fake_player = {}
	setmetatable(fake_player, techage.Fake_player)
	return fake_player
end


for method_name, return_value in pairs(methods) do
	techage.Fake_player[method_name] = function(self, ...)
		return return_value
	end
end
