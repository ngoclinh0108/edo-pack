-- Starving Venom Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon procedure
    Fusion.AddProcMixN(c, true, true,
                       aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 2)

    -- pendulum
    Pendulum.AddProcedure(c, false)
end
