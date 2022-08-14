-- Majestic Black Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")

local s, id = GetID()
s.material = {SignerDragon.CARD_MAJESTIC_DRAGON, CARD_BLACK_WINGED_DRAGON}
s.listed_names = {SignerDragon.CARD_MAJESTIC_DRAGON, CARD_BLACK_WINGED_DRAGON}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddMajesticProcedure(c, aux.FilterBoolFunction(Card.IsCode, SignerDragon.CARD_MAJESTIC_DRAGON), true,
        aux.FilterBoolFunction(Card.IsCode, CARD_BLACK_WINGED_DRAGON), true, Synchro.NonTuner(nil), false)
end
