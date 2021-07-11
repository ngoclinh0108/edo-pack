-- Number C38: Hope Heralder Dragon Tyrant Galaxy
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 37
s.listed_series = {0x7b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute,
                                                 ATTRIBUTE_WATER), 5, 3,
                     s.xyzovfilter, aux.Stringid(id, 0))
end

function s.xyzovfilter(c, tp, xyzc)
    return c:IsFaceup() and c:GetRank() == 4 and
               c:IsAttribute(ATTRIBUTE_WATER, xyzc, SUMMON_TYPE_XYZ, tp)
end
