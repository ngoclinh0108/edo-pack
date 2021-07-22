-- Asgard the Aesir Realm
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                        EFFECT_FLAG_CANNOT_NEGATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)
end
