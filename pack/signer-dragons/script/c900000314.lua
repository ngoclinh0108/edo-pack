-- Stardust Armory Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.listed_series = {0x66, 0xa3}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1,
        Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 1, 99)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetDescription(2)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.sprfilter1(c)
    return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToDeckOrExtraAsCost()
end

function s.sprfilter2(c)
    return c:IsFaceup() and c:IsCode(CARD_STARDUST_DRAGON) and c:IsAbleToDeckOrExtraAsCost()
end

function s.sprescon(sg, e, tp)
    return Duel.GetLocationCountFromEx(tp, tp, sg, e:GetHandler()) > 0 and sg:FilterCount(s.sprfilter1, nil) >= 1 and
               sg:FilterCount(s.sprfilter2, nil) >= 1
end

function s.sprcon(e, c)
    if c == nil then
        return true
    end
    local tp = c:GetControler()
    local g1 = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
    local g2 = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
    local g = g1:Clone():Merge(g2)
    return #g1 > 0 and #g2 > 0 and aux.SelectUnselectGroup(g, e, tp, 2, 2, s.sprescon, 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local g1 = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, tp)
    local g2 = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil, tp)
    local rg = g1:Clone():Merge(g2)
    local g = aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.sprescon, 1, tp, HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then
        return
    end

    Duel.SendtoDeck(g, nil, 0, REASON_COST)
    g:DeleteGroup()
end

function s.e2filter(c, e, tp)
    return Utility.IsSetCard(c, 0x66, 0xa3) and c:IsLevelBelow(8) and c:IsType(TYPE_SYNCHRO) and
               Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE) or (rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
        return
    end

    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end
