-- Red-Eyes Ultimate Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x3b}
s.listed_names = {CARD_REDEYES_B_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMixN(c, false, false, CARD_REDEYES_B_DRAGON, 1,
                       aux.FilterBoolFunctionEx(Card.IsSetCard, 0x3b), 2)
end
