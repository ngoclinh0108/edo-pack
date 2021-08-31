-- The Palladium Oracles
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785, 42006475}
s.material_setcode = {0x13a}
s.listed_names = {71703785, 42006475}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMix(c, true, true, {71703785, 42006475},
                      aux.FilterBoolFunctionEx(Card.IsRace, RACE_SPELLCASTER))
end
