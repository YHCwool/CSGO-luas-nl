local ffi = require "ffi"

local vmt_hook = require("neverlose/vmt_hook")


local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local original_InitNewParticlesScalar

local fireMaterialNames = {
    "particle\\fire_burning_character\\fire_env_fire.vmt",
	"particle\\fire_burning_character\\fire_env_fire_depthblend.vmt",
	"particle\\fire_burning_character\\fire_burning_character_depthblend.vmt",
	"particle\\fire_burning_character\\fire_burning_character.vmt",
	"particle\\fire_burning_character\\fire_burning_character_nodepth.vmt",
	"particle\\particle_flares\\particle_flare_001.vmt",
	"particle\\particle_flares\\particle_flare_004.vmt",
	"particle\\particle_flares\\particle_flare_004b_mod_ob.vmt",
	"particle\\particle_flares\\particle_flare_004b_mod_z.vmt",
	"particle\\fire_explosion_1\\fire_explosion_1_bright.vmt",
	"particle\\fire_explosion_1\\fire_explosion_1b.vmt",
	"particle\\fire_particle_4\\fire_particle_4.vmt",
	"particle\\fire_explosion_1\\fire_explosion_1_oriented.vmt",
}

local Hooked_InitNewParticlesScalar = function(thisptr, particles, start_p, particle_count, attribute_write_mask, context)
    original_InitNewParticlesScalar(thisptr, particles, start_p, particle_count, attribute_write_mask, context)
    --[[
    local particles_address = ffi.cast("uintptr_t", particles)
    local normColorMin = ffi.cast("float*", particles_address + 92)
    local normColorMax = ffi.cast("float*", particles_address + 92 + 12)

    local originalMin_R, originalMin_G, originalMin_B = normColorMin[0], normColorMin[1], normColorMin[2]
    local originalMax_R, originalMax_G, originalMax_B = normColorMax[0], normColorMax[1], normColorMax[2]

    local particleMaterialName = ffi.string(ffi.cast("char**", (ffi.cast("uintptr_t*", particles_address + 0x48)[0] + 0x40))[0])
    
    if has_value(fireMaterialNames, particleMaterialName) then
        normColorMax[0] = 128 / 255
        normColorMin[0] = normColorMax[0]

        normColorMax[1] = 255 / 255
        normColorMin[1] = normColorMax[1]

        normColorMax[2] = 0
        normColorMin[2] = normColorMax[2]
    end

    original_InitNewParticlesScalar(thisptr, particles, start_p, particle_count, attribute_write_mask, context)

    normColorMin[0] = originalMin_R
    normColorMin[1] = originalMin_G
    normColorMin[2] = originalMin_B

    normColorMax[0] = originalMax_R
    normColorMax[1] = originalMax_G
    normColorMax[2] = originalMax_B
    ]]
end

local CInitRandomColorVtableAddress = utils.opcode_scan("client.dll", "C7 85 ? ? ? ? ? ? ? ? 8D 8D ? ? ? ? 0F 11 45 D8")
CInitRandomColorVtableAddress = ffi.cast("void*", (ffi.cast("uintptr_t", CInitRandomColorVtableAddress) + 6))

local CInitRandomColor = vmt_hook.new(CInitRandomColorVtableAddress)
original_InitNewParticlesScalar = CInitRandomColor.hook("void(__fastcall*)(void* thisptr,void* particles, int start_p, int particle_count, int attribute_write_mask, void* context)", Hooked_InitNewParticlesScalar, 29)

local shutdown = function()
    CInitRandomColor.unHookAll()
end

events.shutdown:set(shutdown)