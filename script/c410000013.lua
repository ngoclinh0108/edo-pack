-- Freyja the Mother of the Aesir
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 2

function s.initial_effect(c)
    Divine.AddProcedure(c, "aesir", nil, false)
end
