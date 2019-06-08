local function formspec(self, pos, mem)
	if not mem.tower_built then
		return formspec0
	end
	local icon = "techage_oil_inv"
	local depth = "1/480"
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;1,1;1,1;]"..
	"label[1.3,0.5;IN]"..
	"item_image[1,1;1,1;techage:oil_drillbit]"..
	"label[1,2;"..I("Drill Bit").."]"..
	"label[0.5,3;"..I("Depth")..": "..depth.."]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, mem).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
	"label[6.2,0.5;OUT]"..
	"list[context;dst;6,1;1,1;]"..
	"label[6.2,2;"..I("Oil").."]"..
	"label[5.5,3;"..I("Extract")..": "..depth.."]"..
	"item_image[6,1;1,1;techage:oil_source]"..
	"button_exit[0,3.9;3,1;destroy;"..I("Destroy Tower").."]"..
	"list[current_player;main;0,4;8,4;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4)
end
