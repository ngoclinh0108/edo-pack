-- Palladium Blast Nova Magic
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785, 42006475, 910000020}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x13a) and
               c:IsType(TYPE_RITUAL)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local b1 = g:IsExists(s.e1filter, 1, nil)
    local b2 = g:IsExists(Card.IsCode, 1, nil, 71703785, 910000020)
    local b3 = g:IsExists(Card.IsCode, 1, nil, 42006475, 910000020)
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
    local n = 0
    if b1 then n = n + 1 end
    if b2 then loc, ct, n = loc + LOCATION_SZONE, ct + 1, n + 1 end
    if b3 then loc, ct, n = loc + LOCATION_MZONE, ct + 1, n + 1 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, ct, 1 - tp, loc)
    if n >= 2 then
        Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local b1 = g:IsExists(s.e1filter, 1, nil)
    local b2 = g:IsExists(Card.IsCode, 1, nil, 71703785, 910000020)
    local b3 = g:IsExists(Card.IsCode, 1, nil, 42006475, 910000020)

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

        local ng = Duel.GetMatchingGroup(
                       aux.FilterFaceupFunction(Card.IsType,
                                                TYPE_SPELL + TYPE_TRAP), tp, 0,
                       LOCATION_ONFIELD, c)
        for nc in aux.Next(ng) do s.e1disable(c, nc) end

        local dg = Duel.GetMatchingGroup(Card.IsType, tp, 0, LOCATION_ONFIELD,
                                         c, TYPE_SPELL + TYPE_TRAP)
        Duel.Destroy(dg, REASON_EFFECT)
    end

    if b3 then
        Duel.BreakEffect()

        local ng =
            Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, c)
        for nc in aux.Next(ng) do s.e1disable(c, nc) end

        local dg = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        Duel.Destroy(dg, REASON_EFFECT)
    end
end

function s.e1disable(c, nc)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    nc:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_DISABLE_EFFECT)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    nc:RegisterEffect(ec2)

    if nc:IsType(TYPE_TRAPMONSTER) then
        local ec3 = Effect.CreateEffect(c)
        ec3:SetType(EFFECT_TYPE_SINGLE)
        ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
        nc:RegisterEffect(ec3)
    end

    Duel.AdjustInstantly(nc)
end
