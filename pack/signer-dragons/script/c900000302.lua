-- Majestic Black Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")

local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    -- Synchro.AddMajesticSynchro(c, s, CARD_BLACK_WINGED_DRAGON)
end
