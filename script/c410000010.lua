-- Odin the Allfather of Aesir
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 3

function s.initial_effect(c)
    Divine.AddProcedure(c, "nomi", nil, false)
end
