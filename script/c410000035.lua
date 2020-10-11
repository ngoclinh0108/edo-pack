-- Palladium Oracle Hassan
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x13a}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x13a), 1,
                         1, Synchro.NonTunerEx(Card.IsRace, RACE_SPELLCASTER), 1,
                         99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c:IsRace(RACE_SPELLCASTER) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)
end
