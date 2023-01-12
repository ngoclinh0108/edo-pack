-- Evil HERO Savage Heart
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(86188410)
    c:RegisterEffect(addname)

    -- trap immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, te)
        return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1)
end
