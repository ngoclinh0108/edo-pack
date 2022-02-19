-- Palladium Binding Circle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.counter_list = {COUNTER_SPELL}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCondition(s.e1con)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- act in hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsCode, 71703785),
                   e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    c:RegisterEffect(e2)

    -- set itself
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
               not Duel.IsDamageCalculated()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:IsHasType(EFFECT_TYPE_ACTIVATE) and
                   Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0,
                                               LOCATION_MZONE, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, nil, 1, 0, LOCATION_MZONE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_EQUIP, tp, Card.IsFaceup, tp,
                                          0, LOCATION_MZONE, 1, 1, nil):GetFirst()
    if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or
        c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
    if not tc then
        c:CancelToGrave(false)
        return
    end

    Duel.HintSelection(tc)
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

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsCanRemoveCounter(tp, 1, 0, COUNTER_SPELL, 1, REASON_COST)
    end

    Duel.RemoveCounter(tp, 1, 0, COUNTER_SPELL, 1, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSSetable() end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsSSetable() then return end
    Duel.SSet(tp, c)
end
