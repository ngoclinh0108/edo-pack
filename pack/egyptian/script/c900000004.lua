-- Sun Divine Dragon of Ra - Sphere Mode
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.DivineHierarchy(s, c, 2, false, false)
end
