-- Chrysoprase, Dracodeity of the Air
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_WIND)
    UtilityDracodeity.RegisterEffect(c, id)

    -- effect indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1:SetValue(1)
    c:RegisterEffect(e1)
end
