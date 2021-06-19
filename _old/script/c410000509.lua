-- Shooting Stardust Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.listed_series = {0xa3}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO),
                         1, 1, function(c, scard, sumtype, tp)
        return c:IsSummonCode(scard, sumtype, tp, CARD_STARDUST_DRAGON) or
                   (c:IsSetCard(0xa3) and c:IsRace(RACE_DRAGON) and
                       c:IsType(TYPE_SYNCHRO))
    end, 1, 1)

    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(24696097)
    c:RegisterEffect(code)

    -- double tuner check
    local doubletuner = Effect.CreateEffect(c)
    doubletuner:SetType(EFFECT_TYPE_SINGLE)
    doubletuner:SetCode(EFFECT_MATERIAL_CHECK)
    doubletuner:SetValue(function(e, c)
        local g = c:GetMaterial()
        if not g:IsExists(Card.IsType, 2, nil, TYPE_TUNER) then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
        ec1:SetCode(21142671)
        ec1:SetReset(
            RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE +
                PHASE_END)
        c:RegisterEffect(ec1)
    end)
    c:RegisterEffect(doubletuner)

    -- opponent's turn synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(575512, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetHintTiming(0, TIMING_END_PHASE + TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- multi attack
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCountLimit(1)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- banish
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e4:SetCondition(s.e4con1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_FIELD)
    e4b:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4b:SetCondition(s.e4con2)
    c:RegisterEffect(e4b)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSynchroSummonable(nil) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SynchroSummon(tp, c, nil)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or
        re:GetHandler() == c or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end

    if re:IsHasCategory(CATEGORY_NEGATE) and
        Duel.GetChainInfo(ev - 1, CHAININFO_TRIGGERING_EFFECT):IsHasType(
            EFFECT_TYPE_ACTIVATE) then return false end

    local ex, tg, tc = Duel.GetOperationInfo(ev, CATEGORY_DESTROY)
    return ex and tg ~= nil and tc + tg:FilterCount(Card.IsOnField, c) - #tg > 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, #eg, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end

    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD +
                                          RESET_PHASE + PHASE_END, 0, 0)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 5 and
               Duel.IsAbleToEnterBP()
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.ConfirmDecktop(tp, 5)
    local ct = Duel.GetDecktopGroup(tp, 5):FilterCount(Card.IsType, nil,
                                                       TYPE_TUNER)
    Duel.ShuffleDeck(tp)

    if ct > 1 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetValue(ct - 1)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    elseif ct == 0 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(3206)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_CANNOT_ATTACK)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec2)
    end
end

function s.e4con1(e, tp, eg, ep, ev, re, r, rp) return rp == 1 - tp end

function s.e4con2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():GetControler() ~= tp
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemove() end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, c, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsControler(tp) or
        Duel.Remove(c, nil, REASON_EFFECT + REASON_TEMPORARY) == 0 then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetLabelObject(c)
    ec1:SetCountLimit(1)
    ec1:SetOperation(s.e4retop)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    if Duel.GetAttacker() and Duel.GetAttacker():GetControler() ~= tp then
        Duel.NegateAttack()
    else
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec2:SetCode(EVENT_ATTACK_ANNOUNCE)
        ec2:SetCountLimit(1)
        ec2:SetCondition(s.e4con2)
        ec2:SetOperation(s.e4daop)
        ec2:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec2, tp)
    end
end

function s.e4retop(e, tp, eg, ep, ev, re, r, rp)
    Duel.ReturnToField(e:GetLabelObject())
end

function s.e4daop(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(id)
    Duel.NegateAttack()
end
