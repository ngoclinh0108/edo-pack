-- Greisen, Dracodeity of the Cosmogony
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_LIGHT)
    UtilityDracodeity.RegisterEffect(c, id)
end
