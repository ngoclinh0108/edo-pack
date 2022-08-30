-- Let's Rev It Up!
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}
s.counter_list = {0x1148}

function s.initial_effect(c)
    c:EnableCounterPermit(0x1148)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- chain limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- add counter
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter1(c)
    return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.e1filter2(c, tc)
    return c:HasLevel() and c:GetLevel() < tc:GetLevel()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end
    local tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter1, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if not tc then
        return
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
    Duel.ShuffleDeck(tp)

    if not tc:IsLocation(LOCATION_HAND) or not tc:HasLevel() or
        Duel.GetMatchingGroupCount(s.e1filter2, tp, LOCATION_DECK, 0, nil, tc) == 0 or not Duel.SelectYesNo(tp, 504) then
        return
    end

    Duel.BreakEffect()
    local sg = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e1filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tc)
    Duel.SendtoGrave(sg, REASON_EFFECT)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    if re:IsActiveType(TYPE_MONSTER) and rc:IsOriginalSetCard(0x1017) then
        Duel.SetChainLimit(s.e2chainlimit)
    end
end

function s.e2chainlimit(e, rp, tp)
    return tp == rp
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if eg:IsExists(aux.FilterFaceupFunction(Card.IsSummonType, SUMMON_TYPE_SYNCHRO), 1, nil) then
        e:GetHandler():AddCounter(0x1148, 1)
    end
end
