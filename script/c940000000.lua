-- The Last Hope Remain
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {94770493}
s.listed_series = {0x54, 0x59, 0x82, 0x8f, 0x7e, 0x107e, 0x207e}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                        EFFECT_FLAG_CANNOT_NEGATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- double xyz material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(511001225)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, tc)
        return tc:IsFaceup() and Utility.IsSetCard(tc, 0x54, 0x59, 0x82, 0x8f)
    end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- shuffle
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_SEARCH + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 60992364) -- ZW - Leo Arms
    Utility.DeckEditAddCardToDeck(tp, 2896663) -- ZW - Dragonic Halberd
    Utility.DeckEditAddCardToDeck(tp, 31123642) -- ZS - Utopic Sage
end

function s.e2filter1(c)
    if not c:IsAbleToDeck() then return false end
    return c:IsCode(94770493) or Utility.IsSetCard(c, 0x7e, 0x107e, 0x207e)
end

function s.e2filter2(c)
    return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and
               Utility.IsSetCard(c, 0x54, 0x59, 0x82, 0x8f)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_GRAVE
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter1, tp, loc, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, loc)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.e2filter1, tp,
                                      LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
        return
    end

    if (Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_DECK, 0, 1, nil) and
        Duel.SelectYesNo(tp, 573)) then
        Duel.Hint(HINT_SELECTMSG, tp, 573)
        local sg = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_DECK,
                                           0, 1, 1, nil)
        if #sg > 0 then
            Duel.SendtoHand(sg, tp, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end
