-- Arcana Royal Joker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {25652259, 90876561, 64788463}

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.DoubleSnareValidity(c, LOCATION_MZONE)

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 25652259, 90876561, 64788463)

    -- disable
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SINGLE_RANGE)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(3682106)
    c:RegisterEffect(e1b)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- add hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if c:IsStatus(STATUS_BATTLE_DESTROYED) or ep == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not tg then
        return false
    end

    return Duel.IsChainDisablable(ev) and tg:IsExists(Card.IsControler, 1, nil, tp)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil)
    end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateEffect(ev)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler())
    end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then
        return
    end
    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e3filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(RACE_WARRIOR) and not c:IsType(TYPE_FUSION) and c:IsAbleToHand()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION) and
               c:IsReason(REASON_BATTLE + REASON_EFFECT)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then
        return
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
