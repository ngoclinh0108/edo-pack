-- Palladium Chaos Oracle Aknamkanon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {59514116}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- code & attribute
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(30208479)
    c:RegisterEffect(code)
    local attribute = code:Clone()
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)
end
