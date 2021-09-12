-- Dark Flare Paladin of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, function(c, fc, sumtype, tp)
        return c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER, fc, sumtype, tp)
    end, aux.FilterBoolFunctionEx(Card.IsRace, RACE_WARRIOR))

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
