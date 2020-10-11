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

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetTargetRange(LOCATION_ONFIELD, LOCATION_ONFIELD)
    ec1:SetTarget(s.e1distg)
    ec1:SetLabel(tc:GetOriginalCodeRule())
    ec1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_CHAIN_SOLVING)
    ec2:SetCondition(s.e1discon)
    ec2:SetOperation(s.e1disop)
    ec2:SetLabel(tc:GetOriginalCodeRule())
    ec2:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec2, tp)
end

function s.e1distg(e, c)
    local code = e:GetLabel()
    local code1, code2 = c:GetOriginalCodeRule()
    return code1 == code or code2 == code
end

function s.e1discon(e, tp, eg, ep, ev, re, r, rp)
    local code = e:GetLabel()
    local code1, code2 = re:GetHandler():GetOriginalCodeRule()
    return re:IsActiveType(TYPE_MONSTER) and (code1 == code or code2 == code)
end

function s.e1disop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, 0, id)
    Duel.NegateEffect(ev)
end
