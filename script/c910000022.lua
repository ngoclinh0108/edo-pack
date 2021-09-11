-- Palladium Paladin of Chaos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785}
s.material_setcode = {0xcf}
s.listed_names = {71703785}
s.listed_series = {0xcf}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials
    Fusion.AddProcMix(c, true, true, 71703785, function(c, fc, sumtype, tp)
        return c:IsType(TYPE_RITUAL, fc, sumtype, tp) and
                   (c:IsSetCard(0xcf, fc, sumtype, tp) or
                       c:IsSetCard(0x1048, fc, sumtype, tp))
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
