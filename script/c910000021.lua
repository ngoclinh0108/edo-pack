-- Palladium Oracles Light Dragoon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785}
s.material_setcode = {0x13a}
s.listed_names = {71703785}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 71703785, s.fusfilter)

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

function s.fusfilter(c, sc, sumtype, tp)
    return c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_LIGHT, sc, sumtype, tp) and
               c:IsRace(RACE_DRAGON, sc, sumtype, tp) and
               c:IsType(TYPE_NORMAL, sc, sumtype, tp)
end
