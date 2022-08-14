-- Ultimaya Cosmic Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 7841112, CARD_STARDUST_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 67030233, SignerDragon.CARD_RED_DRAGON_ARCHFIEND, true)
    Utility.DeckEditAddCardToDeck(tp, 900000302, CARD_BLACK_WINGED_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000303, CARD_BLACK_ROSE_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000304, SignerDragon.CARD_ANCIENT_FAIRY_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 900000305, SignerDragon.CARD_LIFE_STREAM_DRAGON, true)
    Utility.DeckEditAddCardToDeck(tp, 40939228, SignerDragon.CARD_SHOOTING_STAR_DRAGON, true)    
end