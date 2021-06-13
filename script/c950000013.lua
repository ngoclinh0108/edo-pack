-- Clear Wing Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(
                             aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM)),
                         1, 99)

    -- pendulum
    Pendulum.AddProcedure(c, false)
end
