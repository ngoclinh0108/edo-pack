-- Palladium Beast Gazelle
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- piercing damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)
end
