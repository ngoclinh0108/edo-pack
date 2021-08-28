-- Black Luster Soldier - Palladium Soldier
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {910000000}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_LIGHT)
    c:RegisterEffect(attribute)
    local attribute2 = attribute:Clone()
    attribute2:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute2)
end
