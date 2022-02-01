-- Palladium Blast Magic
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785, 42006475, 910000022}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(aux.exccon)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x13a) and
               c:IsType(TYPE_RITUAL)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local b1 = g:IsExists(s.e1filter, 1, nil)
    local b2 = g:IsExists(Card.IsCode, 1, nil, 71703785, 910000022)
    local b3 = g:IsExists(Card.IsCode, 1, nil, 42006475, 910000022)
    if chk == 0 then
        return b1 or
                   (b2 and
                       Duel.IsExistingMatchingCard(Card.IsType, tp, 0,
                                                   LOCATION_ONFIELD, 1, c,
                                                   TYPE_SPELL + TYPE_TRAP)) or
                   (b3 and
                       Duel.IsExistingMatchingCard(aux.TRUE, tp, 0,
                                                   LOCATION_MZONE, 1, nil))
    end

    local loc = 0
    local ct = 0
    if b2 then loc, ct = loc + LOCATION_SZONE, ct + 1 end
    if b3 then loc, ct = loc + LOCATION_MZONE, ct + 1 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, ct, 1 - tp, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local b1 = g:IsExists(s.e1filter, 1, nil)
    local b2 = g:IsExists(Card.IsCode, 1, nil, 71703785, 910000022)
    local b3 = g:IsExists(Card.IsCode, 1, nil, 42006475, 910000022)

    if b1 then
        Duel.BreakEffect()

        local ec0 = Effect.CreateEffect(c)
        ec0:SetDescription(aux.Stringid(id, 0))
        ec0:SetType(EFFECT_TYPE_FIELD)
        ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
        ec0:SetCode(id)
        ec0:SetTargetRange(0, 1)
        ec0:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec0, tp)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_IGNORE_RANGE +
                            EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
        ec1:SetTargetRange(0, 0xff)
        ec1:SetValue(LOCATION_REMOVED)
        ec1:SetTarget(function(e, c)
            local tp = e:GetHandlerPlayer()
            return c:GetOwner() ~= tp and Duel.IsPlayerCanRemove(tp, c)
        end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end

    if b2 then
        Duel.BreakEffect()
        local dg = Duel.GetMatchingGroup(Card.IsType, tp, 0, LOCATION_ONFIELD,
                                         c, TYPE_SPELL + TYPE_TRAP)
        Duel.Destroy(dg, REASON_EFFECT)
    end

    if b3 then
        Duel.BreakEffect()
        local dg = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        Duel.Destroy(dg, REASON_EFFECT)
    end
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsCanRemoveCounter(tp, 1, 0, COUNTER_SPELL, 2, REASON_COST)
    end

    Duel.RemoveCounter(tp, 1, 0, COUNTER_SPELL, 2, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
end
