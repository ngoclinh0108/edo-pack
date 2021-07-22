-- Tyr of the Nordic Champions
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- self destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- battle target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    e2:SetValue(s.e1val)
    c:RegisterEffect(e2)
end

s.listed_series = {0x42}

function s.e1con(e)
    return not Duel.IsExistingMatchingCard(
               aux.FilterFaceupFunction(Card.IsSetCard, 0x42), 0,
               LOCATION_MZONE, LOCATION_MZONE, 1, e:GetHandler())
end

function s.e1val(e, c)
    return c:IsFaceup() and c:GetCode() ~= id and c:IsSetCard(0x42)
end
