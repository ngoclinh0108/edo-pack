-- Red-Eyes Abyss Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x3b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c)
        return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_DARK)
    end, 1, 1, aux.FilterBoolFunction(Card.IsSetCard, 0x3b), 1, 1,
                         s.syntunerfilter)

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
        return ct * 300
    end)
    c:RegisterEffect(e1)
end

function s.syntunerfilter(c, scard, sumtype, tp)
    return c:IsAttack(0) and c:IsDefense(0) and
               c:IsRace(RACE_DRAGON, scard, sumtype, tp)
end
