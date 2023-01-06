-- Raviel, Ruler of Phantasms
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    spr:SetCondition(s.sprcon)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)
end

function s.sprfilter(c, tp)
    return c:IsControler(tp) and c:GetSequence() < 5
end

function s.sprcon(e, c)
    if c == nil then
        return true
    end
    local tp = c:GetControler()
    local rg = Duel.GetReleaseGroup(tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ct = -ft + 1
    return ft > -3 and #rg > 2 and (ft > 0 or rg:IsExists(s.sprfilter, ct, nil, tp))
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetReleaseGroup(tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local g = nil

    if ft > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        g = rg:Select(tp, 3, 3, nil)
    elseif ft > -2 then
        local ct = -ft + 1
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        g = rg:FilterSelect(tp, s.mzfilter, ct, ct, nil, tp)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        local g2 = rg:Select(tp, 3 - ct, 3 - ct, g)
        g:Merge(g2)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        g = rg:FilterSelect(tp, s.mzfilter, 3, 3, nil, tp)
    end

    Duel.Release(g, REASON_COST)
end
