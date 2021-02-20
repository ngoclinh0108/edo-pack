-- Erupted Field of the Black Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_REDEYES_B_DRAGON}
s.listed_series = {0x3b}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)
end
