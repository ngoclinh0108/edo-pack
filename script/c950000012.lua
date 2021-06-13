-- Starving Venom Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon procedure
    Fusion.AddProcMixN(c, true, true,
                       aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 2)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- fusion substitute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    me1:SetCondition(function(e)
        local c = e:GetHandler()
        if c:IsLocation(LOCATION_REMOVED + LOCATION_EXTRA) and c:IsFacedown() then
            return false
        end
        return c:IsLocation(
                   LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED +
                       LOCATION_EXTRA)
    end)
    c:RegisterEffect(me1)
end
