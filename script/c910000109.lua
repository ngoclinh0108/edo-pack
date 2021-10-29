-- Tablet of Lost Memories
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(1, 0)
    e2:SetTarget(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e2c)

    -- destroy when leaving
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToHand()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        local sg = Utility.GroupSelect(HINT_SELECTMSG, g, tp, 1, 1)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousPosition(POS_FACEUP) and
               not e:GetHandler():IsLocation(LOCATION_DECK)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    Duel.Destroy(g, REASON_EFFECT)
end
