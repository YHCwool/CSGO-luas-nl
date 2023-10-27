local beams = require("neverlose/beams")

local render_beam = function(origin, dest, r, g, b, a)
    local beamInfo = beams.new()

    beamInfo.m_nType = 0
    beamInfo.m_nModelIndex = -1
    beamInfo.m_flHaloScale = 0
    beamInfo.m_flLife = 0.05
    beamInfo.m_flFadeLength = 0.0
    beamInfo.m_flWidth = 2
    beamInfo.m_flEndWidth = 1.0
    beamInfo.m_pszModelName = "sprites/defuser.vmt"
    beamInfo.m_flAmplitude = 2.3
    beamInfo.m_flSpeed = 0
    beamInfo.m_nStartFrame = 0
    beamInfo.m_flFrameRate = 0
    beamInfo.m_flRed = r 
    beamInfo.m_flGreen = g
    beamInfo.m_flBlue = b
    beamInfo.m_flBrightness = a
    beamInfo.m_nSegments = 2
    beamInfo.m_bRenderable = true
    beamInfo.m_nFlags = bit.bor(0x00000100 + 0x00000008 + 0x00000200 + 0x00008000) --bit.bor(0x100 + 0x200 + 0x8000)
    beamInfo.m_vecStart = origin
    beamInfo.m_vecEnd = dest

    beams.create_beam_points(beamInfo)
end

local BBoxSize = {
    {-10.0, 10.0, 2.0},
    {10.0, 10.0, 2.0},
    {-10.0, -10.0, 2.0},
    {10.0, -10.0, 2.0},
}

local function beam_creator(o_pos, r, g, b, a)
    local pos = o_pos
    local tl = {pos[1] + BBoxSize[1][1], pos[2] + BBoxSize[1][2], pos[3] + BBoxSize[1][3]}
    local tr = {pos[1] + BBoxSize[2][1], pos[2] + BBoxSize[2][2], pos[3] + BBoxSize[2][3]}
    local bl = {pos[1] + BBoxSize[3][1], pos[2] + BBoxSize[3][2], pos[3] + BBoxSize[3][3]}
    local br = {pos[1] + BBoxSize[4][1], pos[2] + BBoxSize[4][2], pos[3] + BBoxSize[4][3]}

    render_beam(tl, tr, r, g, b, a)
    render_beam(tl, bl, r, g, b, a)
    render_beam(bl, br, r, g, b, a)
    render_beam(tr, br, r, g, b, a)
end

local rendering_test = function()
    local local_player = entity.get_local_player()

    local origin_pos = local_player:get_origin()
    local unpack = {origin_pos.x, origin_pos.y, origin_pos.z}

    beam_creator(unpack, 255, 255, 255, 255)
end

events.render:set(rendering_test)