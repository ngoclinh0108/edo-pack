-- The True Name of Palladium Ruler
local s, id = GetID()

function s.initial_effect(c)
    -- look deck
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1bool1(c)
    return c:IsLocation(LOCATION_DECK + LOCATION_GRAVE) and c:IsAbleToHand()
end

function s.e1bool2(c, e, tp)
    return c:IsLocation(LOCATION_HAND + LOCATION_DECK) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1filter(c, e, tp)
    return c:IsOriginalAttribute(ATTRIBUTE_DIVINE) and
               (s.e1bool1(c) or s.e1bool2(c, e, tp))
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
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.ConfirmDecktop(tp, 1)
    local tc = Duel.GetDecktopGroup(tp, 1):GetFirst()
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

    if not tc:IsCode(ac) or not tc:IsAbleToHand() then
        Duel.DisableShuffleCheck()
        Duel.SendtoGrave(tc, REASON_EFFECT + REASON_REVEAL)
        return
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND +
                                        LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    e, tp)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()

        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
        local sc = g:Select(tp, 1, 1, nil):GetFirst()
        local b1 = s.e1bool1(sc)
        local b2 = s.e1bool2(sc, e, tp)

        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
        elseif b1 then
            op = Duel.SelectOption(tp, aux.Stringid(id, 1))
        else
            op = Duel.SelectOption(tp, aux.Stringid(id, 2)) + 1
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
