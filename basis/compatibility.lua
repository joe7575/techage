-- Smartshop pulling and pushing support
minetest.register_on_mods_loaded(function()
    if minetest.get_modpath("smartshop") then
        techage.register_node({
            "smartshop:shop",
            "smartshop:shop_full",
            "smartshop:shop_empty",
            "smartshop:shop_used",
            "smartshop:storage",
            "smartshop:storage_lacks_refill",
            "smartshop:storage_has_send"
        }, {
            on_inv_request = function(pos, in_dir, access_type)
                local meta = minetest.get_meta(pos)
                if is_owner(pos, meta) then
                    return meta:get_inventory(), "main"
                end
            end,
            on_pull_item = function(pos, in_dir, num)
                local meta = minetest.get_meta(pos)
                if is_owner(pos, meta) then
                    local inv = meta:get_inventory()
                    return techage.get_items(pos, inv, "main", num)
                end
            end,
            on_push_item = function(pos, in_dir, stack)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                return techage.put_items(inv, "main", stack)
            end,
            on_unpull_item = function(pos, in_dir, stack)
                local meta = minetest.get_meta(pos)
                local inv = meta:get_inventory()
                return techage.put_items(inv, "main", stack)
            end,
        })
    end
end)
