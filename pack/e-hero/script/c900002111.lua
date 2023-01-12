-- Evil HERO Cosmos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x8, 0x6008}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, tp)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION + TYPE_LINK) and c:IsAbleToRemoveAsCost() and not c:IsCode(id) and
               (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence() < 5)) and
               aux.SpElimFilter(c, true)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = e:GetHandlerPlayer()
    local eff = {c:GetCardEffect(EFFECT_NECRO_VALLEY)}
    for _, te in ipairs(eff) do
        local op = te:GetOperation()
        if not op or op(e, c) then return false end
    end

    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    return ft > -1 and #rg > 0 and aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g = nil
    local rg = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil, tp)
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 1, tp, HINTMSG_REMOVE, nil, nil, true)
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
    Duel.Remove(g, POS_FACEUP, REASON_COST)
    g:DeleteGroup()
end
