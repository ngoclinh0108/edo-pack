-- Palladium Forbidden Sacrophagus
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(aux.exccon)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsAbleToRemove() and
               (c:IsLocation(LOCATION_DECK) or aux.SpElimFilter(c, true))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK,
                                           LOCATION_GRAVE, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_DECK,
                                       LOCATION_GRAVE, 1, 1, nil):GetFirst()
    if not tc or Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) == 0 then return end

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_CHAIN_SOLVING)
    ec2:SetCondition(s.e1discon)
    ec2:SetOperation(s.e1disop)
    ec2:SetLabel(tc:GetOriginalCodeRule())
    ec2:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec2, tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetTargetRange(0, LOCATION_ONFIELD)
    ec1:SetTarget(s.e1distg)
    ec1:SetLabel(tc:GetOriginalCodeRule())
    ec1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec1, tp)
end

function s.e1discon(e, tp, eg, ep, ev, re, r, rp)
    local code = e:GetLabel()
    local code1, code2 = re:GetHandler():GetOriginalCodeRule()
    return rp ~= tp and re:IsActiveType(TYPE_MONSTER) and
               (code1 == code or code2 == code)
end

function s.e1disop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, 0, id)
    Duel.NegateEffect(ev)
end

function s.e1distg(e, c)
    local code = e:GetLabel()
    local code1, code2 = c:GetOriginalCodeRule()
    return code1 == code or code2 == code
end

function s.e2filter(c) return c:IsFaceup() and c:IsAbleToHand() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsAbleToDeck() and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_REMOVED,
                                               0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_MZONE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_REMOVED, 0, nil)

    if #g > 0 and Duel.SendtoDeck(c, nil, 2, REASON_EFFECT) > 0 then
        Duel.BreakEffect()

        if #g > 1 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            g = g:Select(tp, 1, 1, nil)
        end

        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
