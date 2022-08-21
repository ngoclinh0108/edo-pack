-- Quickdraw Warrior
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.material = {20932152}
s.material_setcode = {0x1017}
s.listed_names = {20932152}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSummonCode(sc, stype, tp, 20932152) or c:IsHasEffect(20932152) or c:IsSetCard(0x1017)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- to hand (synchro summoned)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1matcheck = Effect.CreateEffect(c)
    e1matcheck:SetType(EFFECT_TYPE_SINGLE)
    e1matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    e1matcheck:SetValue(s.e1matcheck)
    e1matcheck:SetLabelObject(e1)
    c:RegisterEffect(e1matcheck)

    -- special summon a synchro monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon from banished
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1matcheck(e, c)
    local g = c:GetMaterial()
    if g:IsExists(Card.IsCode, 1, nil, 20932152) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel() == 1
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsAbleToHand, tp, LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, Card.IsAbleToHand, tp, LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    end
end

function s.e2filter(c, e, tp, mg)
    return
        c:IsLevelBelow(8) and c:IsType(TYPE_SYNCHRO) and aux.IsMaterialListSetCard(c, 0x1017) and not c:IsCode(id) and
            Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0 and
            c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsTurnPlayer(1 - tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, c):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end

function s.e3filter(c)
    return c:IsType(TYPE_SYNCHRO) and c:IsAbleToDeck()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, 0, 1, nil) and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e3filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc or Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) == 0 then
        return
    end

    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
