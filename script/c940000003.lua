-- Number S39: Utopia Beyond the Shining
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 39
s.listed_names = {21521304}
s.listed_series = {0x48}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute,
                                                 ATTRIBUTE_LIGHT), 8, 3)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.xyzlimit)
    c:RegisterEffect(splimit)

    -- xyz summon cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_XYZ
    end)
    c:RegisterEffect(e1)

    -- summon success
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_XYZ
    end)
    e2:SetOperation(function()
        Duel.SetChainLimitTillChainEnd(function(e, ep, tp)
            return tp == ep
        end)
    end)
    c:RegisterEffect(e2)

    -- immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, 0)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil,
                                                     21521304)
end

function s.e3tg(e, c) return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) end

function s.e3val(e, re) return re:GetOwnerPlayer() ~= e:GetHandlerPlayer() end
