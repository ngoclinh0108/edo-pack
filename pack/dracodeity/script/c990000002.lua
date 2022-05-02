-- Obsidian, Dracodeity of the Void
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_DARK)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot to GY or banish
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if rp == tp then return end
        local g = Duel.GetMatchingGroup(function(tc) return tc:GetMutualLinkedGroupCount() > 0 end, tp, LOCATION_ONFIELD, 0, nil)
        if #g == 0 then return end

        g:AddCard(c)
        for tc in aux.Next(g) do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_CANNOT_TO_GRAVE)
            ec1:SetRange(LOCATION_ONFIELD)
            ec1:SetLabelObject(re)
            ec1:SetTarget(function(e, c, tp, r, re) return re == e:GetLabelObject() end)
            ec1:SetReset(RESET_CHAIN)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_CANNOT_REMOVE)
            tc:RegisterEffect(ec2)
        end
    end)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy & gain ATK
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_REMOVE + CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- lower atk
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2filter(c, tp)
    local rc = c:GetReasonEffect() and c:GetReasonEffect():GetHandler() or c:GetReasonCard()
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsControler(1 - tp)
        and rc and rc:IsType(TYPE_MONSTER) and rc:IsControler(tp)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = eg:Filter(s.e2filter, nil, tp)
    if #g == 0 then return end

    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
    end
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsAttack(0)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, 0, LOCATION_MZONE, 1, nil) end
    local g = Duel.GetMatchingGroup(s.e3filter, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(s.e3filter, tp, 0, LOCATION_MZONE, nil)
    local ct = Duel.Destroy(g, REASON_EFFECT, LOCATION_REMOVED)

    if ct > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetMutualLinkedGroupCount() > 0 and Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = c:GetMutualLinkedGroupCount()
    if ct <= 0 then return end

    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    local ng = Group.CreateGroup()
    for tc in aux.Next(g) do
        local preatk = tc:GetAttack()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * -1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        if preatk ~= 0 and tc:GetAttack() == 0 then ng:AddCard(tc) end
    end

    if #ng == 0 then return end
    Duel.BreakEffect()
    for tc in aux.Next(ng) do
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(3302)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_CANNOT_TRIGGER)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end
