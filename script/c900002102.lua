-- Evil HERO Aero Scout
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(21844576)
    c:RegisterEffect(addname)
end
