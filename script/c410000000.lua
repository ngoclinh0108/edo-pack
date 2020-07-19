-- Millennium Ascension
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
        if chk == 0 then return true end
        Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
    end)
    c:RegisterEffect(act)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetOwnerPlayer()
    end)
    c:RegisterEffect(e1)

    -- protect grave
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_GRAVE, 0)
    e2:SetTarget(function(e, c)
        return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DIVINE)
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2b:SetValue(aux.tgoval)
    c:RegisterEffect(e2b)

    -- extra summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e3)
end
