-- Mausoleum of the Signer Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- cannot disable summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonType, SUMMON_TYPE_SYNCHRO))
    c:RegisterEffect(e1)
end
