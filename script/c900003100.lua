-- Void-Eyes Infernity Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK), 1, 1,
        Synchro.NonTunerEx(Card.IsRace, RACE_FIEND), 1, 99)
end
