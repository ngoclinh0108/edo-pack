-- Majestic Rose Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, CARD_BLACK_ROSE_DRAGON)
    SignerDragon.AddMajesticReturn(c, CARD_BLACK_ROSE_DRAGON)
end
