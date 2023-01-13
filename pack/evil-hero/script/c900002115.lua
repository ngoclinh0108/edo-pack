-- Evil HERO Wicked Neptucius
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION, 58932615, 79979666}
s.material_setcode = {0x8, 0x3008}
s.dark_calling = true

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- fusion summon
    Fusion.AddProcMix(c, true, true, 58932615, 79979666)

    -- lizard check
    local lizcheck = Effect.CreateEffect(c)
    lizcheck:SetType(EFFECT_TYPE_SINGLE)
    lizcheck:SetCode(CARD_CLOCK_LIZARD)
    lizcheck:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    lizcheck:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), EFFECT_SUPREME_CASTLE)
    end)
    lizcheck:SetValue(1)
    c:RegisterEffect(lizcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.EvilHeroLimit)
    c:RegisterEffect(splimit)
end
