-- Palladium Apostle of Slifer
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000020}

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

    -- infinite hand
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_HAND_LIMIT)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(1, 0)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsOriginalAttribute,
                                            ATTRIBUTE_DIVINE), tp,
                   LOCATION_ONFIELD, 0, 1, nil)
    end)
    e3:SetValue(999)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:IsAbleToHand() and c:IsCode(10000020) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        g = g:Select(tp, 1, 1, nil)
    end

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
