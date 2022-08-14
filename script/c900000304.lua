-- Majestic Fairy Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, SignerDragon.CARD_ANCIENT_FAIRY_DRAGON)
    SignerDragon.AddMajesticReturn(c, SignerDragon.CARD_ANCIENT_FAIRY_DRAGON)
end
