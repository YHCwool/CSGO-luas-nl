local ffi = require("ffi")

local menu = {

    -->> Override elements
    get = function(element)
        return element:get()
    end,

    tab = function(tab, element)
        return ui.create(tab, element)
    end,

    set = function(element, state)
        return element:set(state)
    end,

    override = function(element, state)
        return element:override(state)
    end,

    -->> Create elements
    group = function(element)
        return ui.create(element)
    end,

    button = function(group, element, callbacks)
        return group:button(element, callbacks)
    end,

    label = function(group, name)
        return group:label(name)
    end,

    combo = function(group, name, tbl)
        return group:combo(name, tbl)
    end,

    table = function(group, name, tbl)
        return group:selectable(name, tbl)
    end,

    color = function(group, name, color)
        return group:color_picker(name, color)
    end,

    slider = function(group, name, min, max, def, scale, tooltip)
        return group:slider(name, min, max, def, scale, tooltip)
    end,

    check = function(group, name, state)
        if state == nil then return group:switch(name, false) end
        return group:switch(name, state)
    end,

    -->> Refer elements
    refer = function(category, tab, group, tbl)
        if #tbl > 1 then return ui.find(category, tab, group, tbl[1], tbl[2]) end
        return ui.find(category, tab, group, tbl[1])
    end,

    contains = function(tbl, val)
        for i = 1, #tbl do
            if tbl[i] == val then
                return true
            end
        end
        return false
    end,

    -->> Set element visible
    visible = function(element, state)
        return element:visibility(state)
    end,

    -->> Utils
    exec = function(element)
        return utils.console_exec(element)
    end,

    delay_call = function(delay, callback, element)
        return utils.execute_after(delay, callback, element)
    end

}

local anim = {

    -->> In Air Cehck
    inair = function(entity)
        if entity == nil then entity = entity.get_local_player() end
        return bit.band(entity.m_fFlags, 1) == 0
    end,

    -->> Velocity Check
    velocity = function(entity)
        if entity == nil then entity = entity.get_local_player() end
        local velocity = entity.m_vecVelocity
        return math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    end,

    -->> Crouch Check
    crouching = function(entity)
        if entity == nil then entity = entity.get_local_player() end
        return (bit.band(entity.m_fFlags, 4)) == 0
    end,

    -->> On hit
    onhit = function(entity)
        return (bit.band(entity.m_flVelocityModifier))
    end,

    -->> Slow walk check
    slow_walk = function()
        return menu.get(reference.slowwalk)
    end

    -->> Double tap check


}


local lib = {

    is_grenade = function(entity)
        local weapon = entity:get_player_weapon()
        local wepaon_id = weapon:get_weapon_index()
        local is_grenade =
            ({
                [43] = true, [44] = true, [45] = true,
                [46] = true, [47] = true, [48] = true,
                [68] = true
            })[wepaon_id] or false
        return is_grenade
    end,

    get_state = function()
        local local_player = entity.get_local_player()
        local i = (anim.Slow_walk() and 5) or ((anim.inair(local_player) and 3)) or
            (not anim.crouching(local_player) and 2) or (anim.velocity(local_player) > 5 and 4 or 6)
        return i
    end,

    lerp = function(start, vend, time)
        return (start + (vend - start) * time * globals.frametime)
    end,

    is_key_release = function()
        local w = common.is_button_down(0x57)
        local a = common.is_button_down(0x41)
        local s = common.is_button_down(0x53)
        local d = common.is_button_down(0x44)

        if w == false and a == false and s == false and d == false then
            return true
        else
            return false
        end
    end,

    desync = function(entity)
        return (entity.m_flPoseParameter[11]) * 120 - 60
    end,

    extrapolate = function(player, ticks, x, y, z)
        local xv, yv, zv = entity.get_prop(player, "m_vecVelocity")
        local new_x = x + globals.tickinterval() * xv * ticks
        local new_y = y + globals.tickinterval() * yv * ticks
        local new_z = z + globals.tickinterval() * zv * ticks
        return new_x, new_y, new_z
    end

}

local anim = {

    -->> In Air Cehck
    inair = function(entity)
        if entity == nil then entity = entity.get_local_player() end
        return bit.band(entity.m_fFlags, 1) == 0
    end,

    -->> Velocity Check
    velocity = function(entity)
        if entity == nil then entity = entity.get_local_player() end
        local velocity = entity.m_vecVelocity
        return math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
    end,


    -->> Extrapolate
    extrapolate = function(player, ticks, x, y, z)
        local velocity = player.m_vecVelocity
        local new_x = x + globals.tickinterval * velocity.x * ticks
        local new_y = y + globals.tickinterval * velocity.y * ticks
        local new_z = z + globals.tickinterval * velocity.z * ticks
        return new_x, new_y, new_z
    end,

    -->> Crouch Check
    crouching = function(entity)
        if entity == nil then entity = entity.get_local_player() end
        return (bit.band(entity.m_fFlags, 4)) == 0
    end,


}


local entities = {

    weapons = function(entity)
        return entity:get_player_weapon()
    end,

    origins = function(entity)
        return entity:get_origin()
    end,

    angles = function(entity)
        return entity:get_angles()
    end,

    eye_pos = function(entity)
        return entity:get_eye_position()
    end,

    hitbox_position = function(entity, index)
        return entity:get_hitbox_position(index)
    end,

    is_alive = function(entity)
        return entity:is_alive()
    end,

}


local renderer = require("neverlose/b_renderer")

local solus_render = (function()
    local solus_m = {}
    local RoundedRect = function(x, y, width, height, radius, r, g, b, a)
        renderer.rectangle(x + radius, y, width - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x, y + radius, radius, height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + height - radius, width - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x + width - radius, y + radius, radius, height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + radius, width - radius * 2, height - radius * 2, r, g, b, a)
        renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
        renderer.circle(x + width - radius, y + radius, r, g, b, a, radius, 90, 0.25)
        renderer.circle(x + radius, y + height - radius, r, g, b, a, radius, 270, 0.25)
        renderer.circle(x + width - radius, y + height - radius, r, g, b, a, radius, 0, 0.25)
    end
    local rounding = 4
    local rad = rounding + 2
    local n = 45
    local o = 20
    local OutlineGlow = function(x, y, w, h, radius, r, g, b, a)
        renderer.rectangle(x + 2, y + radius + rad, 1, h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + w - 3, y + radius + rad, 1, h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + 2, w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + h - 3, w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius + rad, y + radius + rad, r, g, b, a, radius + rounding, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + radius + rad, r, g, b, a, radius + rounding, 270, 0.25, 1)
        renderer.circle_outline(x + radius + rad, y + h - radius - rad, r, g, b, a, radius + rounding, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + h - radius - rad, r, g, b, a, radius + rounding, 0, 0.25, 1)
    end
    local FadedRoundedRect = function(x, y, w, h, radius, r, g, b, a, glow)
        local n = a / 255 * n
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, 270, 0.25, 1)
        renderer.gradient(x, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b, n, false)
        renderer.gradient(x + w - 1, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b, n, false)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, n, radius, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, n, radius, 0, 0.25, 1)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r, g, b, n)

        for radius = 4, glow do
            local radius = radius / 2
            OutlineGlow(x - radius, y - radius, w + radius * 2, h + radius * 2, radius, r, g, b, glow - radius * 2)
        end
    end
    solus_m.container = function(x, y, w, h, r, g, b, a, alpha, br, bg, bb, ba, fn)
        if alpha * 255 > 0 then
            render.blur(vector(x, y), vector(x + w, y + h), 2, 1, rounding)
        end
        RoundedRect(x, y, w, h, rounding, br, bg, bb, ba)
        FadedRoundedRect(x, y, w, h, rounding, r, g, b, alpha * 255, alpha * o)
        if not fn then
            return
        end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end
    return solus_m
end)()



local vector_origin = (function()
    local _return = {}

    local angle_forward = function(angle)
        local sin_pitch = math.sin(math.rad(angle.x))
        local cos_pitch = math.cos(math.rad(angle.x))
        local sin_yaw   = math.sin(math.rad(angle.y))
        local cos_yaw   = math.cos(math.rad(angle.y))

        return vector(cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch)
    end

    local angle_right = function(angle)
        local sin_pitch = math.sin(math.rad(angle.x));
        local cos_pitch = math.cos(math.rad(angle.x));
        local sin_yaw   = math.sin(math.rad(angle.y));
        local cos_yaw   = math.cos(math.rad(angle.y));
        local sin_roll  = math.sin(math.rad(angle.z));
        local cos_roll  = math.cos(math.rad(angle.z));

        return vector(
            -1.0 * sin_roll * sin_pitch * cos_yaw + -1.0 * cos_roll * -sin_yaw,
            -1.0 * sin_roll * sin_pitch * sin_yaw + -1.0 * cos_roll * cos_yaw,
            -1.0 * sin_roll * cos_pitch
        );
    end

    local vecotr_ma = function(start, scale, direction_x, direction_y, direction_z)
        return vector(start.x + scale * direction_x, start.y + scale * direction_y, start.z + scale * direction_z)
    end

    local pClientEntityList = utils.create_interface("client.dll", "VClientEntityList003") or
    error("invalid interface", 2)
    local fnGetClientEntity = utils.get_vfunc(3, "void*(__thiscall*)(void*, int)")

    ffi.cdef('typedef struct { float x; float y; float z; } bbvec3_t;')

    local fnGetAttachment = utils.get_vfunc(84, "bool(__thiscall*)(void*, int, bbvec3_t&)")
    local fnGetMuzzleAttachmentIndex1stPerson = utils.get_vfunc(468, "int(__thiscall*)(void*, void*)")
    local fnGetMuzzleAttachmentIndex3stPerson = utils.get_vfunc(469, "int(__thiscall*)(void*)")

    _return.thrid_person = function()
        local view_model = entity.get_entities("CPredictedViewModel")
        local camera_angles = render.camera_angles()
        local local_player = entity.get_local_player()
        local vector_origin = entities.origins(view_model[1])

        local view_punch = local_player.m_vecOrigin
        local aim_punch = local_player.m_vecOrigin


        local forward = angle_forward(camera_angles)
        local right = angle_right(view_punch + aim_punch)

        vector_origin = vecotr_ma(vector_origin, 1, right.x, right.y, right.z)
        vector_origin = vecotr_ma(vector_origin, 30, forward.x, forward.y, forward.z)
        return vector_origin
    end

    _return.first_person = function(world_model)
        local me = entity.get_local_player()
        local wpn = entities.weapons(me)[0]

        local model = world_model and
            wpn["m_hWeaponWorldModel"] or me["m_hViewModel[0]"]


        if me == nil or wpn == nil then
            return
        end

        local attachment_vector = ffi.new("bbvec3_t[1]")

        local g_model = fnGetClientEntity(pClientEntityList, model:get_index())


        local att_index = world_model and
            fnGetMuzzleAttachmentIndex3stPerson(wpn) or
            fnGetMuzzleAttachmentIndex1stPerson(wpn, g_model)

        if att_index > 0 and fnGetAttachment(g_model, att_index, attachment_vector[0]) and not nil then
            return { attachment_vector[0].x, attachment_vector[0].y, attachment_vector[0].z }
        end
    end
    return _return
end)()



local afire = 0
local time_to_shot = 0

local function tts()
    local local_player = entity.get_local_player()
    if not local_player then return end

    local weapon = entities.weapons(local_player)

    local cur = globals.curtime
    if cur < weapon.m_flNextPrimaryAttack then
        time_to_shot = weapon.m_flNextPrimaryAttack - cur
    elseif cur < local_player.m_flNextAttack then
        time_to_shot = local_player.m_flNextAttack - globals.curtime
    end

    return time_to_shot * 10
end

local function reset()
    local local_player = entity.get_local_player()
    if not entities.is_alive(local_player) then return end

    if tts() < 1 then
        afire = 0
    end

    local local_player = entity.get_local_player()
    local my_weapon = entities.weapons(local_player)
    local wepaon_id = bit.band(0xffff, my_weapon.m_iItemDefinitionIndex)
    -- local class = entity_get_classname(my_weapon) --we get enemy's weapon here
    local info = my_weapon:get_classid()
    local is_knife = (info == 107)
    local is_nade =
        ({
            [42] = true,
            [43] = true,
            [44] = true,
            [45] = true,
            [46] = true,
            [47] = true,
            [48] = true,
            [68] = true
        })[wepaon_id] or false

    local player_condition = (is_knife) or
        (tts() > 1) or
        (is_nade) or
        (anim.inair(local_player) --[[and not ((menu.get(config.key)) and is_falling())]])
    -- or ui.get(fakeduck)

    if player_condition then
        afire = 1
    end
end

local weapon_fire = function(e)
    afire = 1
end


local easing = {

    color_1 = { 0, 0, 0 },
    tts = { 0, 0, 0 },
    ind_r = { 0, 0, 0, 0 },
    ind_g = { 0, 0, 0, 0 },
    ind_b = { 0, 0, 0, 0 },
    ind_a = { 0, 0, 0, 0 },
    offset = { 0, 0 },

    ind_r_on = { 80, 255, 255, 204 },
    ind_g_on = { 255, 255, 215, 255 },
    ind_b_on = { 80, 0, 0, 153 },
    ind_a_on = { 255, 255, 255, 255 },
    ind_off = { 184, 184, 184, 150 },

}



local group = {
    color = menu.tab("Main", "Color")
}

local _color_menu = {
    upward = menu.color(group.color, "color picker #1", color(184, 187, 230, 230)),
    downard = menu.color(group.color, "color picker #2", color(134, 137, 180, 80)),
    glow = menu.slider(group.color, "Glow radius", 0, 8, 1, 1, nil)
}

local infobox = function()

    local animation_speed = 6.5
    local eased_tts = lib.lerp(time_to_shot * 50, time_to_shot * 50, animation_speed)
    if eased_tts >= 60 then eased_tts = 60 end

    local ready = (afire == 0)

    if not ready then
        easing.color_1[1] = lib.lerp(easing.color_1[1], 230, animation_speed)
        easing.color_1[2] = lib.lerp(easing.color_1[2], 50, animation_speed)
        easing.color_1[3] = lib.lerp(easing.color_1[3], 50, animation_speed)

        easing.tts[1] = lib.lerp(easing.tts[1], 3, 12)
        easing.tts[2] = lib.lerp(easing.tts[2], 180, animation_speed)
        easing.tts[3] = lib.lerp(easing.tts[3], eased_tts > 1 and 5 or 1, 12)
    else
        easing.color_1[1] = lib.lerp(easing.color_1[1], 0, animation_speed)
        easing.color_1[2] = lib.lerp(easing.color_1[2], 255, animation_speed)
        easing.color_1[3] = lib.lerp(easing.color_1[3], 0, animation_speed)

        easing.tts[1] = lib.lerp(easing.tts[1], 0, animation_speed)
        easing.tts[2] = lib.lerp(easing.tts[2], 0, animation_speed)
        easing.tts[3] = lib.lerp(easing.tts[3], 1, 12)
    end

    -->> Keybinds sections

    local pr = false
    local bt = false
    local sp = false
    local state = false

    for i = 1, 4, 1 do
        local color = (i == 1 and state) or (i == 2 and pr) or (i == 3 and bt) or (i == 4 and sp)
        easing.ind_r[i] = lib.lerp(easing.ind_r[i], color and easing.ind_r_on[i] or easing.ind_off[1], 15)
        easing.ind_g[i] = lib.lerp(easing.ind_g[i], color and easing.ind_g_on[i] or easing.ind_off[2], 15)
        easing.ind_b[i] = lib.lerp(easing.ind_b[i], color and easing.ind_b_on[i] or easing.ind_off[3], 15)
        easing.ind_a[i] = lib.lerp(easing.ind_a[i], color and easing.ind_a_on[i] or easing.ind_off[4], 15)
    end

    -->> basic arrays
    local third = common.is_in_thirdperson()
    local screen = render.screen_size()
    local center_x, center_y = screen.x / 2, screen.y / 2

    -->> World
    local vecotr_origin = render.world_to_screen(vector_origin.thrid_person())

    -->> Muzzle
    local pos = vector_origin.first_person(false)
    local hand = pos ~= nil and vector(pos[1], pos[2], pos[3]) or nil
    local origin = hand ~= nil and render.world_to_screen(hand) or vector(center_x + 200, center_y + 15)

    -->> Convert
    easing.offset[1] = lib.lerp(easing.offset[1], third and (vecotr_origin.x - 20) or (origin.x - 50), 6)
    easing.offset[2] = lib.lerp(easing.offset[2], third and (vecotr_origin.y) or (origin.y - 50), 6)


    -->> Main container
    local color_u = menu.get(_color_menu.upward)
    local color_d = menu.get(_color_menu.downard)
    local glow_r = menu.get(_color_menu.glow)

    solus_render.container(easing.offset[1] + 50, easing.offset[2] + 30, 68, 25 + math.floor(easing.tts[3] + 0.5),
        color_u.r, color_u.g, color_u.b, color_u.a, glow_r, color_d.r, color_d.g, color_d.b, color_d.a)

    local BOT = false

    renderer.rectangle(easing.offset[1] + 54, easing.offset[2] + 40 + easing.tts[3], eased_tts, 2, 255, 255, 255,
        easing.tts[2])

    renderer.text(easing.offset[1] + 54, easing.offset[2] + 33, 255, 255, 255, 255, "-", 0, "STAT")
    renderer.text(easing.offset[1] + 74, easing.offset[2] + 33, easing.color_1[1], easing.color_1[2], easing.color_1[3],
        255, "-", 0, (ready and "ON") or "OFF")
    renderer.text(easing.offset[1] + 100, easing.offset[2] + 33, 255, 255, 255, (BOT and 180) or 150, "-", 0,
        (BOT and "BO") or "MA")

    for i = 1, 4, 1 do
        local offset = (i * 15) + 39
        local text = (i == 1 and "AP") or (i == 2 and "PR") or (i == 3 and "BT") or (i == 4 and "SP")
        renderer.text(easing.offset[1] + offset, easing.offset[2] + 43 + easing.tts[3], easing.ind_r[i], easing.ind_g[i],
            easing.ind_b[i], easing.ind_a[i], "-", 0, text)
    end
end


-->> weapon fire trigger
events.weapon_fire:set(weapon_fire)
-->> tts fire callback
events.render:set(reset)
-->> main info box paint
events.render:set(infobox)
