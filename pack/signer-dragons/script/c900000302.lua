-- Majestic Black Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()
s.counter_list = {COUNTER_FEATHER}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(COUNTER_FEATHER)

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, CARD_BLACK_WINGED_DRAGON)
    SignerDragon.AddMajesticReturn(c, CARD_BLACK_WINGED_DRAGON)

    -- place counter
    local e1reg = Effect.CreateEffect(c)
    e1reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1reg:SetCode(EVENT_CHAINING)
    e1reg:SetRange(LOCATION_MZONE)
    e1reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e1reg)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return re:IsActiveType(TYPE_MONSTER) and re:GetHandler() ~= c and c:GetFlagEffect(1) ~= 0
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        e:GetHandler():AddCounter(COUNTER_FEATHER, 1)
    end)
    c:RegisterEffect(e1)

    -- damage reduce
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0)
    e2:SetValue(function(e, re, val, r, rp, rc)
        if (r & REASON_EFFECT) ~= 0 then
            e:GetHandler():AddCounter(COUNTER_FEATHER, 1)
            return 0
        end
        return val
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e2b)

    -- banish
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER_E)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- negate & damage
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetCounter(COUNTER_FEATHER) >= 4 and c:IsReleasable()
    end
    Duel.Release(c, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_ONFIELD, 1, nil)
    end

    local g = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
end

function s.e4filter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e4filter, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    local tc = Duel.SelectTarget(tp, s.e4filter, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, tc, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, tc:GetAttack())
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsDisabled() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) then
        return
    end
    Duel.AdjustInstantly(tc)
    Duel.Damage(1 - tp, tc:GetAttack(), REASON_EFFECT)
end
