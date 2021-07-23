-- Idun the Nordic Young
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

function s.initial_effect(c)
    -- spirit return
    aux.EnableSpiritReturn(c, EVENT_SUMMON_SUCCESS, EVENT_FLIP)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.FALSE)
    c:RegisterEffect(splimit)
end
