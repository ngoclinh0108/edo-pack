-- Nova Rising Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1045}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- special summon a dragon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- synchro summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    return c:IsLevelBelow(8) and c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
               Duel.GetLocationCountFromEx(tp, tp, e:GetHandler(), c) > 0
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsReleasable()
    end

    Duel.Release(c, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then
        Duel.SpecialSummonComplete()
    end
end

function s.e2filter1(c, e, tp)
    local mg = Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial, tp, LOCATION_GRAVE, 0, e:GetHandler())
    return c:IsLevelBelow(8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and
               c:IsFaceup() and Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_EXTRA, 0, 1, nil, tp, c, mg)
end

function s.e2filter2(c, tp, mc, mg)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(mc, mg) and
               Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and aux.exccon(e, tp, eg, ep, ev, re, r, rp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc =
        Utility.SelectMatchingCard(HINTMSG_SMATERIAL, tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp):GetFirst()
    if not tc then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local mg = Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial, tp, LOCATION_GRAVE, 0, c)
    local sc = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, tp, tc, mg):GetFirst()
    if not sc then
        return
    end

    Synchro.Send = 2
    Duel.SynchroSummon(tp, sc, tc, mg)
end
