-- Palladium Apostle of Obelisk
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000000}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- 3 tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e2:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e2)

    -- non-tuner
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_NONTUNER)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(function(c, sc, tp) return sc and sc:IsSetCard(0x13a) end)
    c:RegisterEffect(e3)

    -- hand synchro
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e4:SetCode(EFFECT_HAND_SYNCHRO)
    e4:SetLabel(id)
    e4:SetValue(s.e4val)
    c:RegisterEffect(e4)
end

function s.e1filter(c) return c:IsAbleToHand() and c:IsCode(10000000) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        g = g:Select(tp, 1, 1, nil)
    end

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4val(e, tc, sc)
    if not sc:IsSetCard(0x13a) then return false end
    if not tc:IsLocation(LOCATION_HAND) then return false end
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
    ec1:SetLabel(id)
    ec1:SetTarget(s.e4syntg)
    tc:RegisterEffect(ec1)
    return true
end

function s.e4syntg(e, mc, sg, tg, ntg, tsg, ntsg)
    if not mc then return true end

    local res = true
    if sg:IsExists(s.e4synchk1, 1, mc) or
        (not tg:IsExists(s.e4synchk2, 1, mc) and
            not ntg:IsExists(s.e4synchk2, 1, mc) and
            not sg:IsExists(s.e4synchk2, 1, mc)) then return false end

    local trg = tg:Filter(s.e4synchk1, nil)
    local ntrg = ntg:Filter(s.e4synchk1, nil)
    return res, trg, ntrg
end

function s.e4synchk1(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then
        return false
    end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() ~= id then return false end
    end
    return true
end

function s.e4synchk2(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or
        c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then
        return false
    end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() == id then return true end
    end
    return false
end
