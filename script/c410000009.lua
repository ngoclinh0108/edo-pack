-- Zorc Necrophades the Creator of Shadow Realm
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 3

function s.initial_effect(c)
    Divine.AddProcedure(c, "nomi")
end
