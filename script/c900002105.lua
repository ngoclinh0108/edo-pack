-- Evil HERO Bubbling Anger
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {79979666}

function s.initial_effect(c)
    -- fusion name
    local fusname = Effect.CreateEffect(c)
    fusname:SetType(EFFECT_TYPE_SINGLE)
    fusname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    fusname:SetCode(EFFECT_ADD_CODE)
    fusname:SetValue(79979666)
    fusname:SetOperation(function(sc, sumtype, tp)
        return (sumtype & MATERIAL_FUSION) ~= 0 or (sumtype & SUMMON_TYPE_FUSION) ~= 0
    end)
    c:RegisterEffect(fusname)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_HANDES + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1, {id})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, c)
    if c == nil then
        return true
    end

    local tp = e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0, nil) == 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
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
