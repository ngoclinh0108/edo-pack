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
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_FIRE) and
                       tc:IsRace(RACE_INSECT)
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

    -- indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(function() return Duel.IsEnvironment(42015635) end)
    c:RegisterEffect(e2)

    -- act limit
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0, 1)
    e3:SetCondition(s.e3con)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
end

function s.e1val(e)
    return Duel.GetMatchingGroupCount(Card.IsType, 0, LOCATION_ONFIELD,
                                      LOCATION_ONFIELD, nil,
                                      TYPE_SPELL + TYPE_TRAP) * 400
end

function s.e3con(e) return Duel.GetAttacker() == e:GetHandler() end

function s.e3val(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end
