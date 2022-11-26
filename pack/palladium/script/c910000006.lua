-- Palladium Vizier Shimon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_MONSTER_REBORN}
s.listed_series = {0x13a, 0x40, 0xde}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- shuffle & draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(aux.exccon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return not c:IsCode(id) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and
               (c:IsSetCard(0x13a) or c:IsSetCard(0xde) or c:IsSetCard(0x40))
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, nil) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, tp, LOCATION_HAND + LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local dg = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, 1,
        nil)
    if #dg == 0 or Duel.Destroy(dg, REASON_EFFECT) == 0 then
        return
    end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e2filter(c)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then
        return false
    end

    return (c:IsSetCard(0x13a) or c:IsSetCard(0xde) or c:IsSetCard(0x40)) and c:IsMonster() and not c:IsCode(id) and
               c:IsAbleToDeck()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
    if chk == 0 then
        return c:IsAbleToDeck() and #g >= 5
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tg = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 5, 5, nil)
    tg:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, tg, #tg, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if not tg or not c:IsRelateToEffect(e) or tg:FilterCount(Card.IsRelateToEffect, nil, e) ~= tg:GetCount() then
        return
    end

    local sg = tg:Clone():AddCard(c)
    Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)

    local g = Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    end

    if g:FilterCount(Card.IsLocation, nil, LOCATION_DECK + LOCATION_EXTRA) == sg:GetCount() then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
