-- Number C37: Hope Buried Abyss Dragon Spider Shark
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 37

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute,
                                                 ATTRIBUTE_WATER), 5, 3)
end
