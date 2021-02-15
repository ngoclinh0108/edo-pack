-- Blue-Eyes Savior Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, s.synfilter, 1, 1,
                         aux.FilterBoolFunction(Card.IsSetCard, 0xdd), 1, 1)
end

function s.synfilter(c) return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) end
