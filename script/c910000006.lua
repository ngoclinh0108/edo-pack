-- Palladium Knight Gaia
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- double tributes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e2:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e2)

    -- extra material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e3:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
    e3b:SetOperation(Fusion.BanishMaterial)
    c:RegisterEffect(e3b)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 or
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsAttackAbove, 2000), tp, 0,
                   LOCATION_MZONE, 1, nil)
end
