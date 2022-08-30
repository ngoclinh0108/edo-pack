-- Let's Rev It Up!
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
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
