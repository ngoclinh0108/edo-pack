-- Majestic Life Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    SignerDragon.AddMajesticProcedure(c, s, SignerDragon.CARD_LIFE_STREAM_DRAGON)
    SignerDragon.AddMajesticReturn(c, SignerDragon.CARD_LIFE_STREAM_DRAGON)
end
