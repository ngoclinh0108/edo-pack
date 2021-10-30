-- Palladium Sacrophagus
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- act in hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e1:SetCondition(function(e)
        local tp = e:GetHandlerPlayer()
        return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
    end)
    c:RegisterEffect(e1)

    -- activate
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCondition(aux.exccon)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c)
    return c:IsAbleToRemove() and
               (c:IsLocation(LOCATION_DECK) or aux.SpElimFilter(c, true))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE,
                                           LOCATION_GRAVE, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e2filter, tp,
                                          LOCATION_DECK + LOCATION_GRAVE,
                                          LOCATION_GRAVE, 1, 1, nil):GetFirst()
    if not tc or Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) == 0 then return end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_CHAIN_SOLVING)
    ec2:SetCondition(s.e2discon)
    ec2:SetOperation(s.e2disop)
    ec2:SetLabel(tc:GetOriginalCodeRule())
    ec2:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec2, tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetTargetRange(0, LOCATION_ONFIELD)
    ec1:SetTarget(s.e2distg)
    ec1:SetLabel(tc:GetOriginalCodeRule())
    ec1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2discon(e, tp, eg, ep, ev, re, r, rp)
    local code = e:GetLabel()
    local code2, code3 = re:GetHandler():GetOriginalCodeRule()
    return rp ~= tp and (code2 == code or code3 == code)
end

function s.e2disop(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(id)
    Duel.NegateEffect(ev)
end

function s.e2distg(e, c)
    local code = e:GetLabel()
    local code2, code3 = c:GetOriginalCodeRule()
    return code2 == code or code3 == code
end

function s.e3filter(c) return c:IsFaceup() and c:IsAbleToHand() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToDeck() and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_REMOVED,
                                               0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_REMOVED, 0, nil)

    if #g > 0 and Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        g = Utility.GroupSelect(HINTMSG_RTOHAND, g, tp)
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
