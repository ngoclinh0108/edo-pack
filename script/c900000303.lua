-- Ultimaya Black-Winged Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()
s.counter_list = {COUNTER_FEATHER}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(COUNTER_FEATHER)

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_BLACK_WINGED_DRAGON)
    c:RegisterEffect(code)

    -- place counter
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, c)
        return c:GetCounter(COUNTER_FEATHER) * 100
    end)
    c:RegisterEffect(e2)

    -- atk down
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e3:SetCondition(s.e3con1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_QUICK_O)
    e3b:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e3b:SetCode(EVENT_FREE_CHAIN)
    e3b:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    e3b:SetCondition(s.e3con2)
    c:RegisterEffect(e3b)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    if ep ~= tp then
        return false
    end

    return (r & REASON_EFFECT) ~= 0 or not e:GetHandler():IsRelateToBattle()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:AddCounter(COUNTER_FEATHER, 1)
end

function s.e3con1(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetCounter(COUNTER_FEATHER) < 4
end

function s.e3con2(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetCounter(COUNTER_FEATHER) >= 4
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return e:GetHandler():GetCounter(COUNTER_FEATHER) > 0 and
                   Duel.IsExistingTarget(aux.nzatk, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, aux.nzatk, tp, 0, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local ct = c:GetCounter(COUNTER_FEATHER)
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or ct == 0 then
        return
    end

    local preatk = tc:GetAttack()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(ct * -700)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)

    c:RemoveCounter(tp, COUNTER_FEATHER, ct, REASON_EFFECT)
    Duel.Damage(1 - tp, preatk - tc:GetAttack(), REASON_EFFECT)
end
