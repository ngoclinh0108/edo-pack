-- Palladium Knight Faris
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(6368038)
    c:RegisterEffect(code)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- reset a monster ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- change battle position
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local rg = Duel.GetMatchingGroup(Card.IsDiscardable, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    return aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 0, c)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp)
    local rg = Duel.GetMatchingGroup(Card.IsDiscardable, tp, LOCATION_HAND, 0,
                                     e:GetHandler())
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, aux.ChkfMMZ(1), 1, tp,
                                      HINTMSG_DISCARD, nil, nil, true)

    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoGrave(g, REASON_DISCARD + REASON_COST)
    g:DeleteGroup()
end

function s.e2filter(c) return c:IsFaceup() and c:GetAttack() ~=
                                  c:GetBaseAttack() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1,
                      nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(tc:GetBaseAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
end

function s.e3filter(c) return c:IsCanChangePosition() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE,
                                           LOCATION_MZONE, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_POSITION, nil, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
    local tg = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_MZONE,
                                       LOCATION_MZONE, 1, 1, nil)
    if #tg == 0 then return end

    Duel.ChangePosition(tg, POS_FACEUP_DEFENSE, 0, POS_FACEUP_ATTACK, 0)
end
