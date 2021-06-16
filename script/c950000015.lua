-- Predator Starving Venom Fusion Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x1050, 0x50}
s.listed_series = {0x1050, 0x50}
s.counter_place_list = {COUNTER_PREDATOR}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x1050, sc, sumtype, tp) and
                   c:IsType(TYPE_FUSION, sc, sumtype, tp) and c:IsOnField()
    end, function(c, fc, sumtype, tp)
        return c:GetOriginalLevel() >= 7 and
                   c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) and
                   c:IsOnField()
    end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or
                   aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- counter
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_CUSTOM + id)
    c:RegisterEffect(e1b)
    local e1ev = Effect.CreateEffect(c)
    e1ev:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1ev:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1ev:SetRange(LOCATION_MZONE)
    e1ev:SetCondition(s.e1evcon)
    e1ev:SetOperation(s.e1evop)
    c:RegisterEffect(e1ev)
end

function s.e1evcon(e, tp, eg, ep, ev, re, r, rp)
    return not eg:IsContains(e:GetHandler()) and
               eg:IsExists(Card.IsControler, 1, nil, 1 - tp)
end

function s.e1evop(e, tp, eg, ep, ev, re, r, rp)
    Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM + id, re, r, rp, ep, ev)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        tc:AddCounter(COUNTER_PREDATOR, 1)
        if tc:GetLevel() > 1 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_CHANGE_LEVEL)
            ec1:SetCondition(function(e)
                return e:GetHandler():GetCounter(COUNTER_PREDATOR) > 0
            end)
            ec1:SetValue(1)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
    end
end
