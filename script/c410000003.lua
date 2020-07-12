-- Ra the Sun Divine Beast
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.SetHierarchy(s, 2)
    Divine.DivineImmunity(c, "egyptian")
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
