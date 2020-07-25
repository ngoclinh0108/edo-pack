-- Millennium Ascension
local s, id = GetID()

s.listed_names = {410000013}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetValue(function(e, te)
        return te:GetOwnerPlayer() ~= e:GetOwnerPlayer()
    end)
    c:RegisterEffect(e2)

    -- protect grave
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_REMOVE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_GRAVE, 0)
    e3:SetTarget(function(e, c)
        return c:IsOriginalAttribute(ATTRIBUTE_DIVINE) or c:IsSetCard(0x13a)
    end)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3b:SetValue(aux.tgoval)
    c:RegisterEffect(e3b)

    -- extra summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e4:SetTarget(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e4)

    -- look deck
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1, id)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.echlimit(e, ep, tp) return tp == ep end

function s.e1filter(c)
    return (c:IsAttribute(ATTRIBUTE_DIVINE) or c:IsSetCard(0x13a)) and
               c:IsAbleToGrave()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK)
    Duel.SetChainLimit(s.echlimit)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp,
                                      LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                      nil)
    if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 end
    Duel.SetChainLimit(s.echlimit)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SortDecktop(tp, tp, 5)
end
