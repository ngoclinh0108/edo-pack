-- The Palladium Name
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000000, 10000020, CARD_RA, 10000040}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_INACTIVATE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- see future
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(function(e, tp)
        return Duel.IsTurnPlayer(tp) and not e:GetHandler():IsPublic() and
                   Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0
    end)
    e2:SetOperation(function(e, tp)
        Duel.ConfirmCards(1 - tp, e:GetHandler())
        Duel.SortDecktop(tp, tp, 1)
    end)
    c:RegisterEffect(e2)

    -- call holactie
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 3}, EFFECT_COUNT_CODE_DUEL)
    e3:SetCost(aux.bfgcost)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, e, tp)
    return c:IsMonster() and
               (c:IsAttribute(ATTRIBUTE_DIVINE) or c:IsSetCard(0x13a)) and
               (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or
                   c:IsAbleToHand())
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsPlayerCanDiscardDeck(tp, 1) and
                   Duel.IsExistingMatchingCard(Card.IsAbleToHand, tp,
                                               LOCATION_DECK, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CODE)
    local ac = Duel.AnnounceCard(tp, table.unpack(
                                     {TYPE_EXTRA, OPCODE_ISTYPE, OPCODE_NOT}))

    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD_FILTER)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

    Duel.ConfirmDecktop(tp, 1)
    local tc = Duel.GetDecktopGroup(tp, 1):GetFirst()
    if not tc:IsCode(ac) or not tc:IsAbleToHand() then
        Duel.DisableShuffleCheck()
        Duel.SendtoGrave(tc, REASON_EFFECT + REASON_REVEAL)
    end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    local g =
        Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil, e, tp)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()

        g = Utility.GroupSelect(g, tp, 1, 1, nil)
        aux.ToHandOrElse(g, tp, function(c)
            return
                c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
                    Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        end, function(g)
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        end, 2)
    else
        Duel.DisableShuffleCheck()
    end
    Duel.ShuffleHand(tp)
end

function s.e3filter(c, code)
    local code1, code2 = c:GetOriginalCodeRule()
    return code1 == code or code2 == code
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    return g:FilterCount(s.e3filter, nil, 10000000) >= 1 and
               g:FilterCount(s.e3filter, nil, 10000020) >= 1 and
               g:FilterCount(s.e3filter, nil, CARD_RA) >= 1
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local g = Duel.GetMatchingGroup(Card.IsCode, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    10000040)
    if chk == 0 then return #g == 0 or g:IsExists(Card.IsAbleToHand, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsCode, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, nil,
                                    10000040)
    local sc
    if #g == 0 then
        sc = Duel.CreateToken(tp, 10000040)
    else
        sc = Utility.GroupSelect(g, tp, 1, 1, nil):GetFirst()
    end
    if not sc then return end

    Duel.SendtoHand(sc, nil, REASON_EFFECT)
end
