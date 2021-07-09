-- The Last Hope Remain
local s, id = GetID()
Duel.LoadScript("util.lua")

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 60992364) -- ZW - Leo Arms
    Utility.DeckEditAddCardToDeck(tp, 2896663) -- ZW - Dragonic Halberd
    Utility.DeckEditAddCardToDeck(tp, 31123642) -- ZS - Utopic Sage
end