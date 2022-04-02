-- Obsidian, Dracodeity of the Void
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_DARK)
    UtilityDracodeity.RegisterEffect(c, id)
end
