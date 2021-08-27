-- Palladium Azure Oracle Seto
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a, 0xdd}

function s.initial_effect(c)
    -- to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id + 1000000)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c)
    return Utility.IsSetCard(c, 0x13a, 0xdd) and c:IsType(TYPE_MONSTER) and
               not c:IsCode(id) and c:IsAbleToHand()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1 - tp, e:GetHandler())
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e1filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil)
    if #g > 0 then Duel.SendtoHand(g, nil, REASON_EFFECT) end
end
