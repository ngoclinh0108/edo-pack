-- Brunhild of the Nordic Ascendant
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- act limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if ep == tp and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and
        re:GetHandler():IsSetCard(0x42) then
        Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
    end
end

function s.e2filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsLevelBelow(4) and c:IsSetCard(0x42) and
               not c:IsType(TYPE_TUNER)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp,
                                           LOCATION_HAND, 0, 1, e:GetHandler())
    end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0,
                                               1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                          LOCATION_HAND + LOCATION_DECK, 0, 1,
                                          1, nil, e, tp)
        if #g > 0 then
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
        end
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c)
        return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x4b)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
