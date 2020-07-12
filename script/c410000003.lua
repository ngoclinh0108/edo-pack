-- Ra the Sun Divine Phoenix
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineImmunity(s, c, 2, "egyptian")
    Divine.ToGraveLimit(c)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_PYRO + RACE_WINGEDBEAST)
    c:RegisterEffect(e1)
end
