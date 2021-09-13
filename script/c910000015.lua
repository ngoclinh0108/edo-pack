-- Palladium Ankuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {83764718}

function s.initial_effect(c)
    -- ritual material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e1:SetCondition(function(e)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741)
    end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- monster reborn
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetHintTiming(TIMING_SPSUMMON, TIMING_BATTLE_START)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter1(c) return c:IsCode(83764718) and c:IsAbleToRemoveAsCost() end

function s.e2filter2(c, e, tp)
    return not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               (Duel.IsTurnPlayer(1 - tp) and Duel.IsBattlePhase())
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsDiscardable() and
                   Duel.IsExistingMatchingCard(s.e2filter1, tp,
                                               LOCATION_DECK + LOCATION_GRAVE,
                                               0, 1, nil)
    end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
    local g = Utility.SelectMatchingCard(tp, s.e2filter1, tp,
                                         LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                         1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e2filter2, tp, LOCATION_GRAVE,
                                         LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e2filter2, tp, LOCATION_GRAVE,
                                LOCATION_GRAVE, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                              PHASE_END, 0, 1)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(574)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetCountLimit(1)
    ec1:SetLabelObject(tc)
    ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetLabelObject():GetFlagEffect(id) ~= 0
    end)
    ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e3filter1(c, tp)
    return not c:IsCode(id) and c:IsPreviousLocation(LOCATION_MZONE) and
               c:IsPreviousControler(tp)
end

function s.e3filter2(c)
    return c:IsFaceup() and c:IsCode(83764718) and
               (c:IsAbleToHand() or c:IsSSetable())
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e3filter1, 1, nil, tp)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToDeck() and
                   Duel.IsExistingMatchingCard(s.e3filter2, tp,
                                               LOCATION_REMOVED, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
        return
    end

    local g = Utility.SelectMatchingCard(tp, s.e3filter2, tp, LOCATION_REMOVED,
                                         0, 1, 1, nil)
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp, function(c)
        return c:IsSSetable() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end, function(g) Duel.SSet(tp, g) end, HINTMSG_SET)
end
