-- Deity Evolution
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- set
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsFaceup() and Divine.GetDivineHierarchy(c) > 0 and not Divine.IsDivineEvolution(c)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        Divine.DivineEvolution(tc)

        -- atk/def
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(ec1b)

        -- prevent negation
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD)
        ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec2:SetCode(EFFECT_CANNOT_INACTIVATE)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetTargetRange(1, 0)
        ec2:SetValue(function(e, ct)
            local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
            return te:GetHandler() == e:GetHandler()
        end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end

function s.e2filter1(c)
    return c:IsFaceup() and c:IsOriginalRace(RACE_DIVINE)
end

function s.e2filter2(c)
    return c:IsSpell() and c:IsDiscardable()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_HAND, 0, 1, nil)
    end

    Duel.DiscardHand(tp, s.e2filter2, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsSSetable()
    end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp, c)
    end
end
