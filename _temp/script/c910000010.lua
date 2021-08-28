-- Palladium Magic
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_MAGICIAN}
s.listed_series = {0xcf, 0x30a2}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c)
    return c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_DARK) and
               c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0xcf) and
               c:IsType(TYPE_RITUAL)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local b1 = g:IsExists(s.e1filter1, 1, nil)
    local b2 = g:IsExists(Card.IsCode, 1, nil, CARD_DARK_MAGICIAN)
    local b3 = g:IsExists(Card.IsSetCard, 1, nil, 0x30a2)
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
    local b1 = g:IsExists(s.e1filter1, 1, nil)
    local b2 = g:IsExists(Card.IsCode, 1, nil, CARD_DARK_MAGICIAN)
    local b3 = g:IsExists(Card.IsSetCard, 1, nil, 0x30a2)

    if b1 then
        Duel.BreakEffect()
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
        Duel.RegisterFlagEffect(1 - tp, id, RESET_PHASE + PHASE_END, 1, 0,
                                aux.Stringid(id, 0))
    end

    if b2 then
        Duel.BreakEffect()
        local sg = Duel.GetMatchingGroup(Card.IsType, tp, 0, LOCATION_ONFIELD,
                                         c, TYPE_SPELL + TYPE_TRAP)
        Duel.Destroy(sg, REASON_EFFECT)
    end

    if b3 then
        Duel.BreakEffect()
        local sg = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        Duel.Destroy(sg, REASON_EFFECT)
    end
end
