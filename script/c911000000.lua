-- Blue-Eyes Light Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1100)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_START)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsType(TYPE_TUNER) and not c:IsPublic()
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0, nil)
    return #g > 0 and aux.SelectUnselectGroup(g, e, tp, 1, 1, aux.ChkfMMZ(1), 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND, 0, nil)
    local sg = aux.SelectUnselectGroup(g, e, tp, 1, 1, aux.ChkfMMZ(1), 1, tp,
                                       HINTMSG_CONFIRM, nil, nil, true)
    if #sg > 0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    g:DeleteGroup()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler() == Duel.GetAttacker() and Duel.GetAttackTarget()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, Duel.GetAttackTarget(), 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttackTarget()
    if not tc:IsRelateToBattle() then return end
    Duel.Destroy(tc, REASON_EFFECT)
end
