-- Majestic Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- add or special summon level 1 dragon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then
        ct = ct + mt.synchro_tuner_required
    end
    if mt.synchro_nt_required then
        ct = ct + mt.synchro_nt_required
    end

    return c:IsFaceup() and c:IsLevelAbove(10) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and ct > 0 and
               c:GetFlagEffect(id) == 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then
        return
    end

    Duel.HintSelection(tc)
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))

    -- prevent negation
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    tc:RegisterEffect(ec1b)

    -- indes
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCountLimit(1)
    ec2:SetValue(function(e, re, r, rp)
        return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
    end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec2)

    -- atk/def up
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 1))
    ec3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetAttacker() == e:GetHandler()
    end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local tc = e:GetHandler()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(ec1b)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec3)
end

function s.e2filter1(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end

function s.e2filter2(c, e, tp, ft)
    return c:IsLevel(1) and c:IsRace(RACE_DRAGON) and
               (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and ft > 0))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, ft)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e2filter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, ft)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then
        return
    end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    aux.ToHandOrElse(tc, tp, function(c)
        return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and ft > 0
    end, function(c)
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end, 2)
end
