-- The Chosen Pharaoh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {39913299}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- act in set turn
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e1:SetCondition(function(e)
        return not Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, 39913299)
    end)
    c:RegisterEffect(e1)
end
