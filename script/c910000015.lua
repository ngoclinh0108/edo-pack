-- Palladium Beast Berfomet
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_POLYMERIZATION}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsSetCard(0x13a) and not c:IsCode(id)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
end

function s.e2filter(c)
    if not c:IsAbleToHand() then return false end
    return c:IsCode(CARD_POLYMERIZATION) or
               (c:IsLevelBelow(4) and c:IsSetCard(0x13a))
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter),
                                         tp, LOCATION_DECK + LOCATION_GRAVE, 0,
                                         1, 1, nil, HINTMSG_ATOHAND)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
