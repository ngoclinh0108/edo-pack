-- Core Warrior
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}

function s.initial_effect(c)
    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsDiscardable()
    end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
        nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end

    if Duel.GetFlagEffect(tp, id) == 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 0))
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        ec1:SetTargetRange(LOCATION_HAND, 0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x1017))
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end
