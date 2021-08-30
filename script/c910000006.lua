-- Palladium Ankuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- ritual material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
    e3:SetCondition(function(e)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), 69832741)
    end)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end
