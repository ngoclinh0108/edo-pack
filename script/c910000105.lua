-- Palladium Swords of Revealing Light
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0, LOCATION_MZONE)
    c:RegisterEffect(e2)

    -- remain field
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_REMAIN_FIELD)
    c:RegisterEffect(e3)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return true end

    c:SetTurnCounter(0)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e, tp) return tp ~= Duel.GetTurnPlayer() end)
    e1:SetOperation(s.e1desop)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END +
                    RESET_OPPO_TURN, 3)
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                       EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(1082946)
    e2:SetLabelObject(e1)
    e2:SetOwnerPlayer(tp)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        s.e1desop(e:GetLabelObject(), tp, eg, ep, ev, e, r, rp)
    end)
    e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END +
                    RESET_OPPO_TURN, 3)
    c:RegisterEffect(e2)

    local g = Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_MZONE, nil)
    if #g > 0 then
        Duel.ChangePosition(sg, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK,
                            POS_FACEUP_DEFENSE, POS_FACEUP_DEFENSE)
    end
end

function s.e1desop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = c:GetTurnCounter()
    ct = ct + 1

    c:SetTurnCounter(ct)
    if ct == 3 then
        Duel.Destroy(c, REASON_RULE)
        if re then re:Reset() end
    end
end
