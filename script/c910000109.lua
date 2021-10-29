-- Palladium Binding Circle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.counter_list = {COUNTER_SPELL}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCondition(s.e1con)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- set itself
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
               not Duel.IsDamageCalculated()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:IsHasType(EFFECT_TYPE_ACTIVATE) and
                   Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                         1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local tc = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1,
                                 nil)

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, tc, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or
        c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then
        c:CancelToGrave(false)
        return
    end

    Duel.Equip(tp, c, tc)
    local ec0 = Effect.CreateEffect(c)
    ec0:SetType(EFFECT_TYPE_SINGLE)
    ec0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec0:SetCode(EFFECT_EQUIP_LIMIT)
    ec0:SetValue(1)
    ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec0)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_EQUIP)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_CANNOT_TRIGGER)
    c:RegisterEffect(ec2)
    local ec3 = ec1:Clone()
    ec3:SetCode(EFFECT_UPDATE_ATTACK)
    ec3:SetValue(-1000)
    c:RegisterEffect(ec3)
    local ec4 = ec3:Clone()
    ec4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(ec4)
    local ec5 = ec1:Clone()
    ec5:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(ec5)
    local ec6 = ec1:Clone()
    ec6:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(ec6)
    local ec7 = ec1:Clone()
    ec7:SetCode(EFFECT_EXTRA_RELEASE_SUM)
    c:RegisterEffect(ec7)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsCanRemoveCounter(tp, 1, 0, COUNTER_SPELL, 1, REASON_COST)
    end

    Duel.RemoveCounter(tp, 1, 0, COUNTER_SPELL, 1, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsSSetable() then return end
    Duel.SSet(tp, c)
end
