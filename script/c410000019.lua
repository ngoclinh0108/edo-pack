-- Palladium Guardian Suijin
local s, id = GetID()

s.listed_names = {98434877}

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(98434877)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_XMATERIAL + EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsReleasableByEffect() and c:IsType(TYPE_MONSTER)
        and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_HAND + LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, nil)

    return aux.SelectUnselectGroup(g, e, tp, 1, 1, aux.ChkfMMZ(1), 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_HAND + LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, c)
    local rg = aux.SelectUnselectGroup(g, e, tp, 1, 1, aux.ChkfMMZ(1), 1, tp,
                                       HINTMSG_RELEASE)

    if #rg > 0 then
        rg:KeepAlive()
        e:SetLabelObject(rg)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttackTarget() == e:GetHandler()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
end

function s.e3filter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_ONFIELD,
                                LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
