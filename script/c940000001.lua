-- Rank-Change-Magic Emperor Force
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x48}

function s.initial_effect(c)
    -- rank-change
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 43490025, 65305468) -- Number F0: Utopic Future Slash
    Utility.DeckEditAddCardToDeck(tp, 26973555, 65305468) -- Number F0: Utopic Future Dragon
    Utility.DeckEditAddCardToDeck(tp, 79747096, 15232745) -- Number C1
    Utility.DeckEditAddCardToDeck(tp, 69757518, 90126061) -- Number C5
    Utility.DeckEditAddCardToDeck(tp, 6387204, 9161357) -- Number C6
    Utility.DeckEditAddCardToDeck(tp, 32559361, 1992816) -- Number C9
    Utility.DeckEditAddCardToDeck(tp, 33776843, 88120966) -- Number C15
    Utility.DeckEditAddCardToDeck(tp, 49221191, 65676461) -- Number C32
    Utility.DeckEditAddCardToDeck(tp, 84124261, 84013237) -- Number 39: Utopia Roots
    Utility.DeckEditAddCardToDeck(tp, 62517849, 84013237) -- Number 39: Utopia Double
    Utility.DeckEditAddCardToDeck(tp, 86532744, 84013237) -- Number S39: Utopia Prime
    Utility.DeckEditAddCardToDeck(tp, 56832966, 84013237) -- Number S39: Utopia the Lightning    
    Utility.DeckEditAddCardToDeck(tp, 56840427, 84013237) -- Number C39: Utopia Ray
    Utility.DeckEditAddCardToDeck(tp, 66970002, 84013237) -- Number C39: Utopia Ray V
    Utility.DeckEditAddCardToDeck(tp, 87911394, 84013237) -- Number C39: Utopia Ray Victory
    Utility.DeckEditAddCardToDeck(tp, 68679595, 84013237) -- Leo Utopia Ray
    Utility.DeckEditAddCardToDeck(tp, 75402014, 84013237) -- Dragonic Utopia Ray
    Utility.DeckEditAddCardToDeck(tp, 21521304, 84013237) -- Number 39: Utopia Beyond
    Utility.DeckEditAddCardToDeck(tp, 69170557, 75433814) -- Number C40
    Utility.DeckEditAddCardToDeck(tp, 32446630, 56051086) -- Number C43
    Utility.DeckEditAddCardToDeck(tp, 96864105, 36076683) -- Number C73
    Utility.DeckEditAddCardToDeck(tp, 20563387, 93568288) -- Number C80
    Utility.DeckEditAddCardToDeck(tp, 6165656, 48995978) -- Number C88
    Utility.DeckEditAddCardToDeck(tp, 47017574, 97403510) -- Number C92
    Utility.DeckEditAddCardToDeck(tp, 77205367, 55727845) -- Number C96
    Utility.DeckEditAddCardToDeck(tp, 940000002, 57314798) -- Number Z100
    Utility.DeckEditAddCardToDeck(tp, 12744567, 48739166) -- Number C101
    Utility.DeckEditAddCardToDeck(tp, 67173574, 49678559) -- Number C102
    Utility.DeckEditAddCardToDeck(tp, 20785975, 94380860) -- Number C103
    Utility.DeckEditAddCardToDeck(tp, 49456901, 2061963) -- Number C104
    Utility.DeckEditAddCardToDeck(tp, 85121942, 59627393) -- Number C105
    Utility.DeckEditAddCardToDeck(tp, 55888045, 63746411) -- Number C106
    Utility.DeckEditAddCardToDeck(tp, 68396121, 88177324) -- Number C107
    Utility.DeckEditAddCardToDeck(tp, 15862758, 89477759) -- Number iC1000
end

function s.e1filter1(c, e, tp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(c), tp, nil, nil,
                                          REASON_XYZ)
    return (#pg <= 0 or (#pg == 1 and pg:IsContains(c))) and c:IsFaceup() and
               (c:GetRank() > 0 or c:IsStatus(STATUS_NO_LEVEL)) and
               Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, c)
end

function s.e1filter2(c, e, tp, mc)
    if c.rum_limit and not c.rum_limit(mc, e) then return false end
    local rk = mc:GetRank()
    return mc:IsType(TYPE_XYZ, c, SUMMON_TYPE_XYZ, tp) and
               mc:IsCanBeXyzMaterial(c, tp) and
               Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false) and
               c:IsSetCard(0x48) and c.xyz_number and c.xyz_number >= 1 and
               c.xyz_number <= 99 and
               (c:IsRank(rk + 1) or c:IsRank(rk + 2) or c:IsRank(rk + 3) or
                   c:IsRank(rk - 1) or c:IsRank(rk - 2) or c:IsRank(rk - 3))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE, 0, 1, nil,
                                     e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(tc), tp, nil, nil,
                                          REASON_XYZ)
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or
        tc:IsControler(1 - tp) or tc:IsImmuneToEffect(e) or #pg > 1 or
        (#pg == 1 and not pg:IsContains(tc)) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e1filter2, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp, tc):GetFirst()
    if not sc then return end

    local mg = tc:GetOverlayGroup()
    if #mg ~= 0 then Duel.Overlay(sc, mg) end
    sc:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(sc, Group.FromCards(tc))
    Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end
