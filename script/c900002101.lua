-- The Supreme King of Spirit World
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 86676862)
    Utility.DeckEditAddCardToDeck(tp, 86165817)
    Utility.DeckEditAddCardToDeck(tp, 13293158)
    Utility.DeckEditAddCardToDeck(tp, 58332301)
    Utility.DeckEditAddCardToDeck(tp, 21947653)
    Utility.DeckEditAddCardToDeck(tp, 22160245)
    Utility.DeckEditAddCardToDeck(tp, 50282757)
end