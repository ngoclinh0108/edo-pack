-- Yubel - The Ultimate Phantasmal Nightmare
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {78371393}
s.material_setcode = {0x145}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, 78371393, s.fusfilter)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
    c:RegisterEffect(splimit)
end

function s.fusfilter(c, fc, sumtype, tp)
    return c:IsType(TYPE_FUSION, fc, sumtype, tp) and c:IsSetCard(0x145, fc, sumtype, tp)
end
