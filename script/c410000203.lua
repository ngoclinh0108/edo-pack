-- Blue-Eyes Savior Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, s.synfilter, 1, 1,
                         aux.FilterBoolFunction(Card.IsSetCard, 0xdd), 1, 1)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c)
        local ct = Duel.GetMatchingGroupCount(Card.IsRace, c:GetControler(),
                                              LOCATION_GRAVE, 0, nil,
                                              RACE_DRAGON)
        return ct * 800
    end)
    c:RegisterEffect(e1)
end

function s.synfilter(c) return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) end
