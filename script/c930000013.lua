-- Beyla of the Nordic Champions
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42, 0x5042}

function s.initial_effect(c)
    -- to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c)
    if c:IsFacedown() then return false end
    return (c:IsSetCard(0x4b) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0x5042)
end

function s.e1filter2(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and
               c:IsAbleToHand()
end

function s.e1filter3(c)
    return c:IsFaceup() and c:IsSetCard(0x42) and c:IsType(TYPE_TUNER)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
        if ft < -1 then return false end
        local loc = LOCATION_ONFIELD
        if ft == 0 then loc = LOCATION_MZONE end
        e:SetLabel(loc)

        return Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_ONFIELD, 0, 1,
                                     nil) and
                   Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_GRAVE,
                                               0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e1filter1, tp, e:GetLabel(), 0, 1, 1, nil)
    
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or Duel.Destroy(tc, REASON_EFFECT) == 0 then
        return
    end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e1filter2),
                                       tp, LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    if not tc or Duel.SendtoHand(tc, nil, REASON_EFFECT) == 0 then return end
    Duel.ConfirmCards(1 - tp, tc)

    if not Duel.IsExistingMatchingCard(s.e1filter3, tp, LOCATION_MZONE, 0, 1,
                                       nil) or not tc:IsSummonable(true, nil) or
        not Duel.SelectYesNo(tp, 1) then return end
    Duel.Summon(tp, tc, true, nil)
end
