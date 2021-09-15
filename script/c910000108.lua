-- Palladium Binding Circle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.counter_list = {COUNTER_SPELL}

function s.initial_effect(c)
    -- disable
    aux.AddPersistentProcedure(c, 1, aux.FilterBoolFunction(Card.IsFaceup),
                               CATEGORY_DISABLE + CATEGORY_POSITION,
                               EFFECT_FLAG_DAMAGE_STEP, TIMING_DAMAGE_STEP,
                               TIMING_DAMAGE_STEP, s.e1con, nil, s.e1tg)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TRIGGER)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(aux.PersistentTargetFilter)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_UPDATE_ATTACK)
    e1b:SetValue(-1000)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e1c)
    local e1d = e1:Clone()
    e1d:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(e1d)
    local e1e = e1:Clone()
    e1e:SetCode(EFFECT_EXTRA_RELEASE_SUM)
    c:RegisterEffect(e1e)
    local e1f = Effect.CreateEffect(c)
    e1f:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e1f:SetRange(LOCATION_SZONE)
    e1f:SetCode(EVENT_LEAVE_FIELD)
    e1f:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
        local tc = c:GetFirstCardTarget()
        return tc and eg:IsContains(tc)
    end)
    e1f:SetOperation(function(e) Duel.Destroy(e:GetHandler(), REASON_EFFECT) end)
    c:RegisterEffect(e1f)

    -- set itself
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
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

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, tc, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, tc, 1, 0, 0)
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
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end
