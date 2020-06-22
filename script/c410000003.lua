-- Ra the Sun Divine Phoenix
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

s.divine_hierarchy = 2

function s.initial_effect(c)
    Divine.AddProcedure(c, '3_tribute', true, RACE_WINGEDBEAST + RACE_PYRO)

    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_DECK)
    c:RegisterEffect(splimit)
end
