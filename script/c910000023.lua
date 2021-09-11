-- Archfiend Palladium Oracle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785}
s.material_setcode = {0x13a, 0x45}
s.listed_names = {71703785}
s.listed_series = {0x45}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials
    Fusion.AddProcMix(c, true, true, 71703785,
                      aux.FilterBoolFunctionEx(Card.IsSetCard, 0x45))

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
