-- Ragnarok of Palladium
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE + CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer(tp) and Duel.GetCurrentPhase() < PHASE_END and
               (Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
                   not Duel.IsDamageCalculated())
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(function(c)
        return c:IsMonster() and c:IsAbleToRemoveAsCost()
    end, tp, LOCATION_MZONE + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0,
                                    c)
    if chk == 0 then return g:IsExists(Card.IsSetCard, 1, nil, 0x13a) end

    local sg = Utility.GroupSelect({
        hintmsg = HINTMSG_REMOVE,
        g = g,
        tp = tp,
        max = #g,
        check = function(g)
            return g:IsExists(Card.IsSetCard, 1, nil, 0x13a)
        end
    })
    local divine_hierarchy = 0
    for tc in aux.Next(sg) do
        divine_hierarchy = divine_hierarchy + Divine.GetDivineHierarchy(tc)
    end
    local ct = Duel.Remove(sg, POS_FACEUP, REASON_COST)

    e:SetLabelObject({ct, divine_hierarchy})
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE,
                                           1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, nil, e:GetLabelObject()[1], 0, 0)
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetTargetRange(0, 1)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(ec1b, tp)

    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, Card.IsFaceup, tp,
                                         0, LOCATION_MZONE, 1,
                                         e:GetLabelObject()[1], nil)
    Duel.HintSelection(g)
    for tc in aux.Next(g) do
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        ec1b:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(ec1b)
    end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_PHASE + PHASE_END)
    ec2:SetCountLimit(1)
    ec2:SetLabel(e:GetLabelObject()[2])
    ec2:SetOperation(function(e, tp)
        Utility.HintCard(e)
        local g = Duel.GetMatchingGroup(function(c)
            return Divine.GetDivineHierarchy(c) <= e:GetLabel()
        end, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT + REASON_REPLACE + REASON_RULE)
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end
