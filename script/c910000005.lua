-- Chaos Emperor Dragon - Envoy of the Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon procedure
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    sp:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- send grave & inflict damage
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id, ACTIVITY_CHAIN, function(re)
        return re:GetHandler():IsCode(id)
    end)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.spfilter(c, attr)
    return c:IsAttribute(attr) and c:IsAbleToRemoveAsCost() and
               aux.SpElimFilter(c, true)
end

function s.sprescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and
               sg:IsExists(s.spattrcheck, 1, nil, sg)
end

function s.spattrcheck(c, sg)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and
               sg:FilterCount(Card.IsAttribute, c, ATTRIBUTE_DARK) == 1
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g1 = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, c,
                                     ATTRIBUTE_LIGHT)
    local g2 = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, c,
                                     ATTRIBUTE_DARK)

    local g = g1:Clone():Merge(g2)
    return #g1 > 0 and #g2 > 0 and
               aux.SelectUnselectGroup(g, e, tp, 2, 2, s.sprescon, 0) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > -2
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local mg = Duel.GetMatchingGroup(s.spfilter, tp,
                                     LOCATION_MZONE + LOCATION_GRAVE, 0, c,
                                     ATTRIBUTE_LIGHT + ATTRIBUTE_DARK)
    local g = aux.SelectUnselectGroup(mg, e, tp, 2, 2, s.sprescon, 1, tp,
                                      HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckLPCost(tp, 1000) and
                   Duel.GetCustomActivityCount(id, tp, ACTIVITY_CHAIN) == 0
    end
    Duel.PayLPCost(tp, 1000)

    local ec0 = Effect.CreateEffect(c)
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT +
                        EFFECT_FLAG_OATH)
    ec0:SetDescription(aux.Stringid(id, 1))
    ec0:SetTargetRange(1, 0)
    ec0:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec0, tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(function(e, re) return not re:GetHandler():IsCode(id) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_OATH)
    ec2:SetCode(EFFECT_CANNOT_ATTACK)
    ec2:SetTargetRange(LOCATION_MZONE, 0)
    ec2:SetTarget(function(e, c) return not c:IsCode(id) end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    if chk == 0 then return #g > 0 end

    local ct = g:FilterCount(Card.IsAbleToGrave, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, 1 - tp, ct * 300)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    Duel.SendtoGrave(g, REASON_EFFECT)

    local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil,
                                                   LOCATION_GRAVE)
    if ct > 0 then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, ct * 300, REASON_EFFECT)
    end
end

function s.e2filter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and
               c:IsAbleToHand()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousControler(tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e2filter, tp, LOCATION_REMOVED, 0, 1,
                                         nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_REMOVED, 0, 1, 1,
                                nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, tc)
    end
end
