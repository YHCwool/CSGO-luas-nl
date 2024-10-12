local beams = require("neverlose/beams")

local render_beam = function(origin, dest, r, g, b, a)
    beams.m_nType = 0
    beams.m_nModelIndex = -1
    beams.m_flHaloScale = 0
    beams.m_flLife = 0.05
    beams.m_flFadeLength = 0
    beams.m_flWidth = 2
    beams.m_flEndWidth = 1
    beams.m_pszModelName = "sprites/physbeam.vmt"
    beams.m_flAmplitude = 2.3
    beams.m_flSpeed = 0
    beams.m_nStartFrame = 0
    beams.m_flFrameRate = 0
    beams.m_color = color(r, g, b, a)
    beams.m_nSegments = 2
    beams.m_bRenderable = true
    beams.m_nFlags = bit.bor(33544)
    beams.m_vecStart = origin
    beams.m_vecEnd = dest

    beams.create_beam_points()
end

local BBoxSize = {
    { -10.0, 10.0,  2.0 },
    { 10.0,  10.0,  2.0 },
    { -10.0, -10.0, 2.0 },
    { 10.0,  -10.0, 2.0 },
}

local function beam_creator(o_pos, r, g, b, a)
    local tl = vector(o_pos.x + BBoxSize[1][1], o_pos.y + BBoxSize[1][2], o_pos.z + BBoxSize[1][3])
    local tr = vector(o_pos.x + BBoxSize[2][1], o_pos.y + BBoxSize[2][2], o_pos.z + BBoxSize[2][3])
    local bl = vector(o_pos.x + BBoxSize[3][1], o_pos.y + BBoxSize[3][2], o_pos.z + BBoxSize[3][3])
    local br = vector(o_pos.x + BBoxSize[4][1], o_pos.y + BBoxSize[4][2], o_pos.z + BBoxSize[4][3])

    render_beam(tl, tr, r, g, b, a)
    render_beam(tl, bl, r, g, b, a)
    render_beam(bl, br, r, g, b, a)
    render_beam(tr, br, r, g, b, a)
end

local rendering_test = function()
    local local_player = entity.get_local_player()

    local origin_pos = local_player:get_origin()

    beam_creator(origin_pos, 255, 255, 255, 255)
end

events.render:set(rendering_test)
