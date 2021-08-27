-- Palladium Chaos Soldier Faris
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)
end
