-- Elemental HERO Deity Neos
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {CARD_NEOS}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMixN(c, false, false, CARD_NEOS, 1, s.fusfilter, 6)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
    c:RegisterEffect(splimit)
end

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
    return c:IsSetCard(0x1f, fc, sumtype, tp) and
               c:GetAttribute(fc, sumtype, tp) ~= 0 and
               (not sg or not sg:IsExists(
                   function(tc, attr, fc, sumtype, tp)
                return tc:IsSetCard(0x1f, fc, sumtype, tp) and
                           tc:IsAttribute(attr, fc, sumtype, tp)
            end, 1, c, c:GetAttribute(fc, sumtype, tp), fc, sumtype, tp))
end
