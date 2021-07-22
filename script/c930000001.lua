-- Odin, Allfather of the Aesir
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x3042}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, scard, sumtype, tp)
        return c:IsSetCard(0x3042, scard, sumtype, tp) or
                   c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)
end
