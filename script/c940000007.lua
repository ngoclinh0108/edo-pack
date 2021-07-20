-- Rank-Up-Magic Barian's Pride
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x48}

function s.initial_effect(c)
end

function s.deck_edit(tp)
  Utility.DeckEditAddCardToDeck(tp, 48739166) -- Number 101
  Utility.DeckEditAddCardToDeck(tp, 49678559) -- Number 102
  Utility.DeckEditAddCardToDeck(tp, 94380860) -- Number 103
  Utility.DeckEditAddCardToDeck(tp, 2061963) -- Number 104
  Utility.DeckEditAddCardToDeck(tp, 59627393) -- Number 105
  Utility.DeckEditAddCardToDeck(tp, 63746411) -- Number 106
  Utility.DeckEditAddCardToDeck(tp, 88177324) -- Number 107
end