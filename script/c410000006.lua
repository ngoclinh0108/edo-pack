-- Obelisk's Apostle
local s, id = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- cannot be tributed
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsAttribute),
                                       ATTRIBUTE_DIVINE))
    c:RegisterEffect(e1)
end
