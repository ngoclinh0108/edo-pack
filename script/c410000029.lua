-- The True Name of Palladium Ruler
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, e, tp)
    if not c:IsAttribute(ATTRIBUTE_DIVINE) then return false end
    return s.e1check1(c) or s.e1check2(c, e, tp)
end

function s.e1check1(c)
    return not c:IsLocation(LOCATION_HAND) and c:IsAbleToHand()
end

function s.e1check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanDiscardDeck(tp, 1) and
                   Duel.IsExistingMatchingCard(Card.IsAbleToHand, tp,
                                               LOCATION_DECK, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
    s.announce_filter = {TYPE_EXTRA, OPCODE_ISTYPE, OPCODE_NOT}
    local ac = Duel.AnnounceCard(tp, table.unpack(s.announce_filter))

    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD_FILTER)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.ConfirmDecktop(tp, 1)
    local tc = Duel.GetDecktopGroup(tp, 1):GetFirst()
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

    if not tc:IsCode(ac) then
        Duel.DisableShuffleCheck()
        Duel.SendtoGrave(tc, REASON_EFFECT + REASON_REVEAL)
        return
    end

    if not tc:IsAbleToHand() then return end
    Duel.SendtoHand(tc, nil, REASON_EFFECT)

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    e, tp)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        local sc = g:Select(tp, 1, 1, nil):GetFirst()

        local b1 = s.e1check1(sc)
        local b2 = s.e1check2(sc, e, tp)
        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, 573, 5)
        elseif b1 then
            op = Duel.SelectOption(tp, 573)
        else
            op = Duel.SelectOption(tp, 5) + 1
        end

        if op == 0 then
            Duel.SendtoHand(sc, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sc)
        else
            Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP)
        end
    else
        Duel.DisableShuffleCheck()
    end
    Duel.ShuffleHand(tp)
end
