-- Ratatoskr of the Nordic Beasts
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {UtilNordic.BEAST_TOKEN}
s.listed_series = {0x42}

function s.initial_effect(c)
    -- token
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- shuffle
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 2000000)
    e2:SetCondition(aux.exccon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               c:IsPreviousControler(tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp,
                                                        UtilNordic.BEAST_TOKEN,
                                                        0x6042, TYPES_TOKEN, 0,
                                                        0, 3, RACE_BEAST,
                                                        ATTRIBUTE_EARTH)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 2, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, UtilNordic.BEAST_TOKEN,
                                                 0x6042, TYPES_TOKEN, 0, 0, 3,
                                                 RACE_BEAST, ATTRIBUTE_EARTH) then
        return
    end

    for i = 1, 2 do
        local token = Duel.CreateToken(tp, UtilNordic.BEAST_TOKEN)
        Duel.SpecialSummonStep(token, 0, tp, tp, false, false, POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
end

function s.e2filter(c) return c:IsSetCard(0x42) and c:IsAbleToDeck() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsPlayerCanDraw(tp, 1) and c:IsAbleToDeck() and
                   Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, 0, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 5, c)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    tg = tg:Filter(Card.IsRelateToEffect, nil, e)
    if not c:IsRelateToEffect(e) or not tg or #tg == 0 then return end

    tg:AddCard(c)
    Duel.SendtoDeck(tg, nil, 0, REASON_EFFECT)
    local g = Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end

    local ct = g:FilterCount(Card.IsLocation, nil,
                             LOCATION_DECK + LOCATION_EXTRA)
    if ct == #tg then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
