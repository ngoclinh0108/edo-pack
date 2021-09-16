-- Chaos-Eyes Silver Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.NOT(
                          aux.FilterBoolFunctionEx(Card.IsType, TYPE_TOKEN)), 3,
                      3)
end
