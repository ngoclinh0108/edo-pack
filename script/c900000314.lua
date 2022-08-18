-- Stardust Armory Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1,
        Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 1, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)
end

function s.sprfilter1(c, tp)
    return c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup() and c:IsAbleToDeckAsCost()
end

function s.sprfilter2(c, tp)
    return c:IsCode(CARD_STARDUST_DRAGON) and c:IsFaceup() and c:IsAbleToDeckAsCost()
end

function s.sprescon(sg, e, tp)
    return
        Duel.GetLocationCountFromEx(tp, tp, sg, e:GetHandler()) > 0 and sg:FilterCount(s.sprfilter1, nil, tp) == 1 and
            sg:FilterCount(s.sprfilter2, nil, tp) == 1
end

function s.sprcon(e, c)
    if c == nil then
        return true
    end
    local tp = c:GetControler()
    local g1 = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, tp)
    local g2 = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil, tp)
    local g = g1:Clone():Merge(g2)
    return #g1 > 0 and #g2 > 0 and aux.SelectUnselectGroup(g, e, tp, 2, 2, s.sprescon, 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local g1 = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, tp)
    local g2 = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil, tp)
    local rg = g1:Clone():Merge(g2)
    local g = aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.rescon, 1, tp, HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then
        return
    end

    Duel.SendtoDeck(g, nil, 0, REASON_COST)
    g:DeleteGroup()
end
