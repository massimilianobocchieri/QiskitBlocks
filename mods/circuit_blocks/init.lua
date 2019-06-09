-- TODO:
-- Define Quantum control block that creates circuit, etc.
-- Right click places circuit_gate
-- Make left click drop gate entity

dofile(minetest.get_modpath("circuit_blocks").."/circuit_node_types.lua");

-- our API object
circuit_blocks = {}

function circuit_blocks:register_circuit_block(circuit_node_type, connector_up, connector_down, rotational)
    local texture_name = ""
    if circuit_node_type == CircuitNodeTypes.EMPTY then
        texture_name = "circuit_blocks_no_gate"
    elseif circuit_node_type == CircuitNodeTypes.X then
        texture_name = "circuit_blocks_x_gate"
        if connector_up and not connector_down then
            texture_name = "circuit_blocks_not_gate_up"
        elseif connector_down and not connector_up then
            texture_name = "circuit_blocks_not_gate_down"
        end
    elseif circuit_node_type == CircuitNodeTypes.H then
        texture_name = "circuit_blocks_h_gate"
    end
    minetest.register_node("circuit_blocks:"..texture_name, {
        description = texture_name,
        tiles = {texture_name..".png"},
        groups = {circuit_gate=1, oddly_breakable_by_hand=2},
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_int("node_type", circuit_node_type)
            meta:set_float("radians", 0.0)
            meta:set_int("ctrl_a", -1)
            meta:set_int("ctrl_b", -1)
            minetest.debug("circuit_node_type: " .. tostring(circuit_node_type))
        end,
        after_dig_node = function(pos, node, player)
            local meta = minetest.get_meta(pos)
            local node_type = meta:get_int("node_type")
            local radians = meta:get_float("radians")
            local ctrl_a = meta:get_int("ctrl_a")
            local ctrl_b = meta:get_int("ctrl_b")
            minetest.debug("node_type: " .. tostring(node_type) ..
                    ", radians: " .. tostring(radians) ..
                    ", ctrl_a: " .. tostring(ctrl_a) ..
                    ", ctrl_b: " .. tostring(ctrl_b))
            minetest.set_node(pos, {name = "circuit_blocks:circuit_blocks_no_gate"})
            return
        end,
        on_rightclick = function(pos, node, clicker, itemstack)
            local meta = minetest.get_meta(pos)
            local node_type = meta:get_int("node_type")
            local radians = meta:get_float("radians")
            local ctrl_a = meta:get_int("ctrl_a")
            local ctrl_b = meta:get_int("ctrl_b")

            if itemstack:get_name() == "circuit_blocks:control_tool" then
                ctrl_a = ctrl_a * -1
                meta:set_int("ctrl_a", ctrl_a)
                local player_name = clicker:get_player_name()
                minetest.chat_send_player(player_name, "ctrl_a is now: " .. tostring(ctrl_a))

                --minetest.swap_node(pos, {
                --    name = "circuit_blocks:no_gate"})
                --minetest.chat_send_player(player_name, "after swap ctrl_a is now: " .. tostring(ctrl_a))

                node = node or minetest.get_node(pos)

                -- TODO: Study door example to understand this better
                --local def = minetest.registered_nodes[node.name]
                --local name = def.door.name

                local function get_nodedef_field(nodename, fieldname)
                    if not minetest.registered_nodes[nodename] then
                        return nil
                    end
                    return minetest.registered_nodes[nodename][fieldname]
                end
                local drawtype = get_nodedef_field(node.name, "drawtype")
                minetest.chat_send_player(player_name, "drawtype: " .. drawtype)

                local tiles = get_nodedef_field(node.name, "tiles")
                minetest.chat_send_player(player_name, "tiles: " .. tostring(tiles[1]))

                local groups = get_nodedef_field(node.name, "groups")
                minetest.chat_send_player(player_name, "circuit_gate: " .. tostring(groups.circuit_gate))
            end
        end
    })
end

minetest.register_node("circuit_blocks:qubit_0", {
    description = "Qubit 0 block",
    tiles = {"circuit_blocks_qubit_0.png"},
    groups = {oddly_breakable_by_hand=2}
})

minetest.register_node("circuit_blocks:qubit_1", {
    description = "Qubit 1 block",
    tiles = {"circuit_blocks_qubit_1.png"},
    groups = {oddly_breakable_by_hand=2}
})


minetest.register_tool("circuit_blocks:control_tool", {
	description = "Control tool",
	inventory_image = "circuit_blocks_control_tool.png",
	wield_image = "circuit_blocks_control_tool.png",
	wield_scale = { x = 1, y = 1, z = 1 },
	range = 10,
	tool_capabilities = {},
})

circuit_blocks:register_circuit_block(CircuitNodeTypes.EMPTY, false, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, false, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, true, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, false, true, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.H, false, false, false)