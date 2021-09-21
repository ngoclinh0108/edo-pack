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

function s.e1filter(c) return c:IsAbleToRemoveAsCost() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
               not Duel.IsDamageCalculated()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_ONFIELD + LOCATION_HAND + LOCATION_DECK +
                    LOCATION_GRAVE
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, loc, 0, 1, c)
    end

    local g = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e1filter, tp,
                                         loc, 0, 1, 999, c)
    local divine_hierarchy = 0
    for tc in aux.Next(g) do
        divine_hierarchy = divine_hierarchy + Divine.GetDivineHierarchy(tc)
    end
    local ct = Duel.Remove(g, POS_FACEUP, REASON_COST)

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

    local divine_hierarchy = e:GetLabelObject()[2]
    for tc in aux.Next(g) do
        local eff = Effect.CreateEffect(c)
        eff:SetType(EFFECT_TYPE_SINGLE)
        eff:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        if Divine.GetDivineHierarchy(tc) <= divine_hierarchy then
            eff:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        end
        
        -- local ec1 = Effect.CreateEffect(c)
        -- ec1:SetType(EFFECT_TYPE_SINGLE)
        -- ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
        -- ec1:SetCode(EFFECT_DISABLE)
        -- ec1:SetRange(LOCATION_MZONE)
        -- ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        -- tc:RegisterEffect(ec1, true)
        -- local ec1b = ec1:Clone()
        -- ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        -- tc:RegisterEffect(ec1b, true)
        -- local ec1c = ec1:Clone()
        -- ec1c:SetCode(EFFECT_IMMUNE_EFFECT)
        -- ec1c:SetValue(function(e, te)
        --     return te:GetHandler() == e:GetHandler()
        -- end)
        -- tc:RegisterEffect(ec1c, true)
        -- Duel.AdjustInstantly(tc)

        -- Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        -- local ec1 = eff:Clone()
        -- ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        -- ec1:SetValue(math.ceil(tc:GetAttack() / 2))
        -- tc:RegisterEffect(ec1)
        -- local ec2 = eff:Clone()
        -- ec2:SetProperty(eff:GetProperty() + EFFECT_FLAG_CANNOT_DISABLE)
        -- ec2:SetCode(EFFECT_DISABLE)
        -- tc:RegisterEffect(ec2)
        -- local ec2b = ec2:Clone()
        -- ec2b:SetCode(EFFECT_DISABLE_EFFECT)
        -- ec2b:SetValue(RESET_TURN_SET)
        -- tc:RegisterEffect(ec2b)

        -- local ec2 = Effect.CreateEffect(c)
        -- ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        -- ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        -- ec2:SetCode(EVENT_PHASE + PHASE_END)
        -- ec2:SetCountLimit(1)
        -- ec2:SetLabelObject(eff)
        -- ec2:SetOperation(function()            
        -- end)
        -- ec2:SetReset(RESET_PHASE + PHASE_END)
        -- Duel.RegisterEffect(ec2, 1 - tp)
    end
end
