-- Chaos Eyes Palladium Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:AddSetcodesRule(id, true, 0xdd, 0x3b)
end
