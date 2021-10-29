-- Palladium Ragnarok
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- banish
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsSetCard(0x13a) end

function s.e1check(sg) return sg:IsExists(s.e1filter, 1, nil) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
               not Duel.IsDamageCalculated()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost, tp,
                                    LOCATION_HAND + LOCATION_ONFIELD, 0, c)
    if chk == 0 then return #g > 0 and g:IsExists(s.e1filter, 1, nil) end

    local ct = Duel.GetMatchingGroupCount(Card.IsFaceup, tp, 0,
                                          LOCATION_ONFIELD, nil)
    local sg = Utility.GroupSelect(HINTMSG_TOGRAVE, g, tp, 1, ct, nil, nil,
                                   s.e1check)
    Duel.SendtoGrave(sg, REASON_COST)
    e:SetLabelObject(sg)
    sg:KeepAlive()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0,
                                           LOCATION_ONFIELD, 1, nil)
    end

    local typ = 0
    local g = e:GetLabelObject()
    for tc in aux.Next(g) do typ = typ | tc:GetOriginalType() end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, nil, #g, 0, 0)
    Duel.SetChainLimit(s.e1chainlimit(typ & 0x7))
end

function s.e1chainlimit(typ)
    return function(e, rp, tp)
        return tp == rp or e:GetHandler():GetOriginalType() & typ == 0
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = #e:GetLabelObject()
    e:GetLabelObject():DeleteGroup()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_ONFIELD, nil)
    if #g < ct then return end

    local tg = Utility.GroupSelect(HINTMSG_NEGATE, g, tp, ct, ct)
    for tc in aux.Next(tg) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetValue(math.ceil(tc:GetAttack() / 2))
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)

        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec2:SetCode(EFFECT_DISABLE)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_DISABLE_EFFECT)
        ec2b:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(ec2b)
    end
end

function s.e2filter1(c)
    return c:IsLevel(6, 7) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x13a)
end

function s.e2filter2(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and
               (c:IsLocation(LOCATION_DECK) or aux.SpElimFilter(c))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter1, tp, LOCATION_MZONE, 0, nil)
    return
        (Duel.GetTurnCount() ~= c:GetTurnID() or c:IsReason(REASON_RETURN)) and
            Duel.IsTurnPlayer(tp) and Duel.GetCurrentPhase() == PHASE_MAIN2 and
            #g == 2 and g:GetClassCount(Card.GetCode) == 2
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if chk == 0 then return c:IsAbleToRemoveAsCost() and #g > 0 end

    local divine_hierarchy = 0
    for tc in aux.Next(g) do
        divine_hierarchy = divine_hierarchy + Divine.GetDivineHierarchy(tc)
    end

    g:AddCard(c)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
    e:SetLabel(divine_hierarchy)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c)
        return Divine.GetDivineHierarchy(c) <= e:GetLabel()
    end, tp, 0, LOCATION_MZONE, nil)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT + REASON_RULE)
end
