--==> Neverlose base
--==> Basic elemento
local anti_aim = require("neverlose/anti_aim")
local renderer = require("neverlose/b_renderer")
local clipboard = require("neverlose/clipboard")
local json = require("neverlose/nl_json")
local vmt_hook = require("neverlose/vmt_hook")
local ffi = require "ffi"
--_DEBUG = true
local menu = {

    -->> Override elements
    get = function(element)
        return element:get()
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

    tab = function(tab, element)
        return ui.create(tab, element)
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

    slider = function(group, name, min, max, def, scale, tooltip)
        return group:slider(name, min, max, def, scale, tooltip)
    end,

    check = function(group, name, state)
        if state == nil then return group:switch(name, false) end
        return group:switch(name, state)
    end,

    hotkey = function(group, name, state)
        return group:hotkey(name)
    end,

    color = function(group, name, color)
        return group:color_picker(name, color)
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
        return element:set_visible(state)
    end,

    -->> Utils
    exec = function(element)
        return utils.console_exec(element)
    end,

    delay_call = function(delay, callback, element)
        return utils.execute_after(delay, callback, element)
    end

}

local reference = {

    strafe = menu.refer("Miscellaneous", "Main", "Movement", {"Air Strafe"}),
    onshot = menu.refer('Aimbot', 'Anti Aim', "Angles", {"Body Yaw", "On Shot"}),

    slowwalk = menu.refer("Aimbot", "Anti Aim", "Misc", {"Slow Walk"}),

    hideshot = menu.refer('Aimbot', "Ragebot", 'Main', {'Hide Shots'}),
    doubletap = menu.refer('Aimbot', 'Ragebot', 'Main', {'Double Tap'}),

    yaw_base = menu.refer('Aimbot', 'Anti Aim', 'Angles', {'Yaw'}),
    yaw = menu.refer('Aimbot', 'Anti Aim', 'Angles', {'Yaw', 'Offset'}),
    pitch = menu.refer('Aimbot', 'Anti Aim', 'Angles', {'Pitch'}),
    yaw_jitter = menu.refer('Aimbot', 'Anti Aim', 'Angles', {'Yaw Modifier'}),
    yaw_jitter_range = menu.refer('Aimbot', 'Anti Aim', 'Angles', {'Yaw Modifier', "Offset"}),
    body_yaw = menu.refer('Aimbot', 'Anti Aim', 'Angles', {'Body Yaw', 'Options'}),
    fakeduck = menu.refer('Aimbot', 'Anti Aim', 'Misc', {'Fake Duck'}),
    fakelag = menu.refer('Aimbot', 'Anti Aim', 'Fake Lag', {"Enabled"}),

    yawbase = ui.find('Aimbot','Anti Aim',"Angles","Yaw",'Base'),
    yawadd = ui.find('Aimbot','Anti Aim',"Angles","Yaw",'Offset'),
    fake_lag_limit = ui.find('Aimbot','Anti Aim',"Fake Lag","Limit"),
    yawjitter = ui.find('Aimbot','Anti Aim',"Angles","Yaw Modifier"),
    yawjitter_offset = ui.find('Aimbot','Anti Aim',"Angles","Yaw Modifier",'Offset'),
    fakeangle = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw"),
    inverter = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw","Inverter"),
    left_limit = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw","Left Limit"),
    right_limit = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw","Right Limit"),
    fakeoption = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw","Options"),
    fsbodyyaw = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw","Freestanding"),
    lby_mode = ui.find('Aimbot','Anti Aim',"Angles","Body Yaw","LBY Mode"),
    freestanding = ui.find('Aimbot','Anti Aim',"Angles","Freestanding"),
    disableyaw_modifier = ui.find('Aimbot','AntiAim',"Angles","Freestanding","Disable Yaw Modifiers"),
    body_freestanding = ui.find('Aimbot','Anti Aim',"Angles","Freestanding","Body Freestanding"),
    roll = ui.find('Aimbot','Anti Aim',"Angles","Extended Angles"),
    roll_pitch = ui.find('Aimbot','Anti Aim',"Angles","Extended Angles","Extended Pitch"),
    roll_roll = ui.find('Aimbot','Anti Aim',"Angles","Extended Angles","Extended Roll"),
    leg_movement = ui.find('Aimbot','Anti Aim',"Misc","Leg Movement"),
    hitchance = ui.find('Aimbot','Ragebot',"Selection","Hit Chance"),
    air_strafe = ui.find('Miscellaneous',"Main","Movement",'Air Strafe'),
    


    autopeek = ui.find('Aimbot','Ragebot','Main','Peek Assist'),
    dt = ui.find('Aimbot','Ragebot','Main','Double Tap'),
    bodyaim = ui.find('Aimbot','Ragebot','Safety','Body Aim'),
    safepoint = ui.find('Aimbot','Ragebot','Safety','Safe Points'),
    
}


local anim = {

    -->> In Air Cehck
    inair = function (entity)
        if entity == nil then entity = entity.get_local_player() end
        return bit.band(entity.m_fFlags,1) == 0
    end,

    -->> Velocity Check
    velocity = function(entity)
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
        local i = (anim.slow_walk() and 1) or 
        (((anim.inair(local_player) and not anim.crouching(local_player) and 6) or 
        anim.inair(local_player) and anim.crouching(local_player) and 5)) or 
        (not anim.crouching(local_player) and 4) or
        (anim.velocity(local_player) > 5 and 2 or 3)
    
        return i
    end,    

    lerp = function(start, vend, time)
        return(start + (vend - start) * time * globals.frametime)
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

    desync = function()
        return anti_aim.get_desync_delta()
    end

}



local index = {
    state = {"Slow-Walk", "Moving", "Stand", "Crouch", "In-Air", "Air-Crouch"},
    body_yaw = {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"},
    fl_state = {"On Peek", "Moving", "In Air"},
    lby_state = {"Disabled", "Opposite", "Sway"},
    freestand = {"Off", "Peek Fake", "Peek Real"},
    view_model = {680, 25, 0, -15}
}

local groups = {
    antiaim = menu.tab("Antiaim", "Main"),
    conditions = menu.tab("Antiaim", "Conditions"),
    roll = menu.tab("Antiaim", "Roll"),
    fakelag = menu.tab("Antiaim", "Fake Lag"),
    extra = menu.tab("Antiaim", "Extra Conditions"),

    visuals = menu.tab("Visuals", "Main"),
    bullet = menu.tab("Visuals", "Bullet tracer")
}

local shot_data = {}

local tracer = {
    
    enable = menu.check(groups.bullet, "Bullet tracer", false),

    duration = menu.slider(groups.bullet, "Tracer duration", 1, 10000, 3000, 0.001)
}


local record_bullet = function(events)
    if events.entity ~= entity.get_local_player() then return end
    print(entity.get_local_player())
end


--events.createmove:set(record_bullet)
--events.bullet_fire:set(record_bullet)