-- Dreadroot the Wicked God
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 1

function s.initial_effect(c)
    Divine.AddProcedure(c, 'wicked', nil, true)
end
