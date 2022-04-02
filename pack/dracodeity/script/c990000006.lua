-- Chrysoprase, Dracodeity of the Air
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_WIND)
    UtilityDracodeity.RegisterEffect(c, id)
end
