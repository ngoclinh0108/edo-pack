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
    Utility.PlaceToPZoneWhenDestroyed(c)

    -- fusion summon
    local pe1params = {
        nil, Fusion.CheckWithHandler(function(c)
            return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) and
                       c:IsOnField() and c:IsAbleToGrave()
        end), function(e) return Group.FromCards(e:GetHandler()) end, nil,
        Fusion.ForcedHandler
    }
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(1170)
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(Fusion.SummonEffTG(table.unpack(pe1params)))
    pe1:SetOperation(Fusion.SummonEffOP(table.unpack(pe1params)))
    c:RegisterEffect(pe1)

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
