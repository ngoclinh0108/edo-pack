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
end
