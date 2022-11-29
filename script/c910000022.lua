-- Chaos-Eyes Palladium Dragoon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785, 910000012}
s.material_setcode = {0x13a, 0xcf}
s.listed_names = {71703785, 910000012}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 71703785, 910000012)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc)
        return tc == e:GetHandler()
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetValue(function(e, tc)
        if not tc then
            return false
        end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_SINGLE)
    e1c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1c:SetValue(aux.tgoval)
    c:RegisterEffect(e1c)
    local e1d = e1c:Clone()
    e1d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1d:SetValue(1)
    c:RegisterEffect(e1d)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY + CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_CHAINING)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if #eg > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(#eg * 500)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then
        return false
    end
    return rc ~= c and Duel.IsChainNegatable(ev)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil)
    end

    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, eg, 1, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT, LOCATION_REMOVED)
    end
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct1 = Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local ct2 = Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_SZONE, nil)
    if chk == 0 then
        return ct1 > 0 or ct2 > 0
    end

    if (ct1 > ct2 and ct2 ~= 0) or ct1 == 0 then
        ct1 = ct2
    end
    if ct1 ~= 0 then
        local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, ct1, 0, 0)
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, ct1, 0, 0)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g1 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local g2 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_SZONE, nil)
    if #g1 == 0 and #g2 == 0 then
        return
    end

    if #g1 == 0 then
        Duel.Destroy(g2, REASON_EFFECT, LOCATION_REMOVED)
    elseif #g2 == 0 then
        Duel.Destroy(g1, REASON_EFFECT, LOCATION_REMOVED)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        local opt = Duel.SelectOption(tp, aux.Stringid(id, 2), aux.Stringid(id, 3))
        if opt == 0 then
            Duel.Destroy(g1, REASON_EFFECT, LOCATION_REMOVED)
        else
            Duel.Destroy(g2, REASON_EFFECT, LOCATION_REMOVED)
        end
    end
end
