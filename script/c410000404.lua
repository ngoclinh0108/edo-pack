-- Elemental HERO Blazing Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {42015635}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        89621922, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_FIRE)
        end
    }, nil, true, true)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetCondition(s.e2con)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
end

function s.e1val(e)
    return Duel.GetMatchingGroupCount(Card.IsType, 0, LOCATION_ONFIELD,
                                      LOCATION_ONFIELD, nil,
                                      TYPE_SPELL + TYPE_TRAP) * 400
end

function s.e2con(e)
    return Duel.IsEnvironment(42015635) and Duel.GetAttacker() == e:GetHandler()
end

function s.e2val(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end
