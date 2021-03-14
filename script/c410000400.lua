-- Neo-Space Multiverse
local s, id = GetID()
Duel.LoadScript("util.lua")

function s.global_effect(c, tp)
  -- Elemental HERO Neos
  local eg1 = Effect.CreateEffect(c)
  eg1:SetType(EFFECT_TYPE_SINGLE)
  eg1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  eg1:SetCode(EFFECT_ADD_CODE)
  eg1:SetValue(CARD_NEOS)
  Utility.RegisterGlobalEffect(c, eg1, Card.IsCode, 14124483)
  Utility.RegisterGlobalEffect(c, eg1, Card.IsCode, 64655485)
end

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)
end
