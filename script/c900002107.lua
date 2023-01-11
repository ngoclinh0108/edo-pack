-- Evil HERO Savage Heart
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {86188410}

function s.initial_effect(c)
    -- fusion name
    local fusname = Effect.CreateEffect(c)
    fusname:SetType(EFFECT_TYPE_SINGLE)
    fusname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    fusname:SetCode(EFFECT_ADD_CODE)
    fusname:SetValue(86188410)
    fusname:SetOperation(function(sc, sumtype, tp)
        return (sumtype & MATERIAL_FUSION) ~= 0 or (sumtype & SUMMON_TYPE_FUSION) ~= 0
    end)
    c:RegisterEffect(fusname)

    -- unaffected by opponent's traps
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
