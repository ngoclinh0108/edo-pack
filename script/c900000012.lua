-- The Protection of Sky God
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000020}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- recycle
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF + EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
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
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) and c:IsFaceup() and
                   c:IsAbleToDeck()
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    g:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then
        return
    end

    local g = Group.FromCards(c, tc)
    if Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == #g then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
