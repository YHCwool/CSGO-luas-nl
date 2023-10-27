
local mat_molly = {
    "particle/particle_flares/particle_flare_gray",
    "particle/smoke1/smoke1_nearcull2",
    "particle/vistasmokev1/vistasmokev1_nearcull",
    "particle/smoke1/smoke1_nearcull",
    "particle/vistasmokev1/vistasmokev1_nearcull_nodepth",
    "particle/vistasmokev1/vistasmokev1_nearcull_fog",
    "particle/vistasmokev1/vistasmokev4_nearcull",
    "particle/smoke1/smoke1_nearcull3",

    "particle/fire_burning_character/fire_env_fire_depthblend_oriented",
    "particle/fire_burning_character/fire_burning_character",

    -- "particle/fire_burning_character/fire_env_fire",

    "particle/fire_explosion_1/fire_explosion_1_oriented",
    "particle/fire_explosion_1/fire_explosion_1_bright",

    "particle/fire_burning_character/fire_burning_character_depthblend",
    "particle/fire_burning_character/fire_env_fire_depthblend",

}



local delay_call = function(delay, callback, element)
    return utils.execute_after(delay, callback, element)
end

local find_mat = nil
local find_material = materials.get

local smoke_count_address = utils.opcode_scan("client.dll", "8B 15 ? ? ? ? 0F 57 C0 56")
smoke_count_address = ffi.cast("uintptr_t*",  ffi.cast("uintptr_t", smoke_count_address) + 2)
local smoke_count = ffi.cast("int*",smoke_count_address[0])

local ignore_smoke = function()
    smoke_count[0] = 0
end

local mat_smoke = {
    "particle/vistasmokev1/vistasmokev1_fire",
    "particle/vistasmokev1/vistasmokev1_smokegrenade",
    "particle/vistasmokev1/vistasmokev1_emods",
    "particle/vistasmokev1/vistasmokev1_emods_impactdust"
}

find_mat = function()
    for _, v in pairs(mat_molly) do

        --[[if material ~= nil then
          material:var_flag()
        end]]

        local material = find_material(v)

        if material ~= nil then
            local is_fire = v:match('fire') ~= nil
            material:var_flag(2, not is_fire)

            material:var_flag(7, is_fire)
            material:var_flag(13, is_fire)
            material:var_flag(28, is_fire)
        end

    end

    for _, v in pairs(mat_smoke) do
        
        local material = find_material(v)

        if material ~= nil then
            local is_smoke = v:match("smoke") ~= nil
            
            material:var_flag(2, not is_smoke)

            material:var_flag(7, is_smoke)
            material:var_flag(13, is_smoke)
            material:var_flag(28, is_smoke)
        end

    end

    delay_call(3, find_mat)
end

events.net_update_end:set(ignore_smoke)
find_mat()
