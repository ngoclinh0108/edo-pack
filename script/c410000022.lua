-- Palladium Magic
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000000}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(573)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE + PHASE_DRAW)
    e1:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e, tp)
        return Duel.GetTurnPlayer() == tp and Duel.IsMainPhase() and
                   Duel.IsEnvironment(410000000, tp)
    end)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsAbleToHand() end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end)
    c:RegisterEffect(e1)

    -- ritual
    local e2 = Ritual.CreateProc({
        handler = c,
        filter = aux.FilterBoolFunction(Card.IsSetCard, 0x13a),
        lvtype = RITPROC_GREATER,
        location = LOCATION_HAND + LOCATION_GRAVE + LOCATION_EXTRA,
        stage3 = s.e2sumop,
        desc = aux.Stringid(id, 1)
    })
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    c:RegisterEffect(e2)

    -- search fusion spell
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- search ritual monster
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCondition(function() return Duel.IsMainPhase() end)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2sumop(mat, e, tp, eg, ep, ev, re, r, rp, tc)
    local c = e:GetHandler()
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD,
                          EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(function(e, re, rp) return rp == 1 - e:GetHandlerPlayer() end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec2:SetValue(aux.tgoval)
    tc:RegisterEffect(ec2)
end

function s.e3filter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter(c)
    return c:IsAbleToHand() and c:IsSetCard(0x13a) and c:IsType(TYPE_RITUAL) and
               c:IsType(TYPE_MONSTER)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
