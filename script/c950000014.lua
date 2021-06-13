-- Dark Rebellion Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 4,
                     2)

    -- pendulum
    Pendulum.AddProcedure(c, false)
end
