-- Elemental HERO Steam Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 89621922, 17955766, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, 89621922, 17955766, nil, true, false)

    -- neos return
    aux.EnableNeosReturn(c, 0, nil, nil)
end
