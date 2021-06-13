-- Lethal Starving Venom Fusion Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x1050, sc, sumtype, tp) and
                   c:IsType(TYPE_FUSION, sc, sumtype, tp)
    end, function(c, fc, sumtype, tp)
        return c:GetOriginalLevel() >= 7 and
                   c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp)
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
end
