-- Evil HERO Bubbling Anger
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(79979666)
    c:RegisterEffect(addname)

    -- destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_DAMAGE_STEP_END)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_HANDES + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local bc = e:GetHandler():GetBattleTarget()
    if chk == 0 then
        return bc and bc:IsRelateToBattle()
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, bc, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        Duel.Destroy(bc, REASON_EFFECT)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return (r & REASON_FUSION) == REASON_FUSION and c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and c:IsFaceup()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsPlayerCanDraw(tp, 2)
    end

    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
    Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
    if Duel.Draw(tp, 2, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        Duel.ShuffleHand(tp)
        Duel.DiscardHand(tp, aux.TRUE, 1, 1, REASON_EFFECT + REASON_DISCARD)
    end
end
