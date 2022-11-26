-- Palladium Oracle Shimon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_MONSTER_REBORN}
s.listed_series = {0x13a, 0x40, 0xde}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- set
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- shuffle & draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return not c:IsCode(id) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and
               (c:IsSetCard(0x13a) or c:IsSetCard(0xde) or c:IsSetCard(0x40))
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
    if not c:IsSSetable() then
        return
    end

    return c:IsCode(CARD_MONSTER_REBORN) or (c:ListsCode(CARD_MONSTER_REBORN) and c:IsType(TYPE_SPELL + TYPE_TRAP))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    if tc and Duel.SSet(tp, tc) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        if tc:IsType(TYPE_QUICKPLAY) then
            ec1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        elseif tc:IsType(TYPE_TRAP) then
            ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        end
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end

function s.e3filter(c)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then
        return false
    end

    return (c:IsSetCard(0x13a) or c:IsSetCard(0xde) or c:IsSetCard(0x40)) and c:IsMonster() and not c:IsCode(id) and
               c:IsAbleToDeck()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
    if chk == 0 then
        return c:IsAbleToDeck() and #g >= 5
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tg = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 5, 5, nil)
    tg:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, tg, #tg, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
