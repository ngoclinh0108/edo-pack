-- The Protection of Sky God
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000020}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- recycle
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF + EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c)
    return c:IsFaceup() and (c:IsCode(CARD_RA) or c:ListsCode(CARD_RA)) and not c:IsCode(id) and c:IsAbleToDeck()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) and c:IsAbleToHand()
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, c)
        Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end

