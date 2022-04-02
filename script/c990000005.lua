-- Andalusite, Dracodeity of the Continent
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_EARTH)
    UtilityDracodeity.RegisterEffect(c, id)
end
