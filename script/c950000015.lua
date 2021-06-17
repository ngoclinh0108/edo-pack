-- Predator Starving Venom Fusion Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x1050, 0x50}
s.listed_series = {0x1050, 0x50}
s.counter_place_list = {COUNTER_PREDATOR}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x1050, sc, sumtype, tp) and
                   c:IsType(TYPE_FUSION, sc, sumtype, tp) and c:IsOnField()
    end, function(c, fc, sumtype, tp)
        return c:GetOriginalLevel() >= 7 and
                   c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) and
                   c:IsOnField()
    end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or
                   aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- counter
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_CUSTOM + id)
    c:RegisterEffect(e1b)
    local e1ev = Effect.CreateEffect(c)
    e1ev:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1ev:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1ev:SetRange(LOCATION_MZONE)
    e1ev:SetCondition(s.e1evcon)
    e1ev:SetOperation(s.e1evop)
    c:RegisterEffect(e1ev)

    -- drain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon & destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1evcon(e, tp, eg, ep, ev, re, r, rp)
    return not eg:IsContains(e:GetHandler()) and
               eg:IsExists(Card.IsControler, 1, nil, 1 - tp)
end

function s.e1evop(e, tp, eg, ep, ev, re, r, rp)
    Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM + id, re, r, rp, ep, ev)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        tc:AddCounter(COUNTER_PREDATOR, 1)
        if tc:GetLevel() > 1 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_CHANGE_LEVEL)
            ec1:SetCondition(function(e)
                return e:GetHandler():GetCounter(COUNTER_PREDATOR) > 0
            end)
            ec1:SetValue(1)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
    end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.disfilter1, tp, 0, LOCATION_MZONE, 1,
                                     nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, aux.disfilter1, tp, 0, LOCATION_MZONE, 1, 1,
                                nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not c:IsRelateToEffect(e) or c:IsFacedown() or
        not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsType(TYPE_TOKEN) then
        return
    end

    local code = tc:GetOriginalCodeRule()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_CHANGE_CODE)
    ec1:SetValue(code)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
    if c:CopyEffect(code,
                    RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1) >
        0 then
        Duel.BreakEffect()

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec2:SetValue(0)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec2)

        local ec3 = Effect.CreateEffect(c)
        ec3:SetType(EFFECT_TYPE_SINGLE)
        ec3:SetCode(EFFECT_DISABLE)
        ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec3)
        local ec3b = ec3:Clone()
        ec3b:SetCode(EFFECT_DISABLE_EFFECT)
        ec3b:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(ec3b)
    end
end

function s.e3filter(c, tp)
    return c:GetCounter(COUNTER_PREDATOR) > 0 and c:IsControler(1 - tp)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroup(tp, s.e3filter, 1, false, 1, true, c, tp,
                                      nil, true, nil, tp)
    end

    local g = Duel.SelectReleaseGroup(tp, s.e3filter, 1, 1, false, true, true,
                                      c, nil, nil, true, nil, tp)
    Duel.Release(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    local dg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        Duel.BreakEffect()
        local dg = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
        Duel.Destroy(dg, REASON_EFFECT)
    end
end
