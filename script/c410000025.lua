-- Palladium Guardian Release
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {98434877, 62340868, 25955164, 25833572}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, ft, e, tp)
    if not c:IsCode(98434877, 62340868, 25955164, 25833572) then return false end
    return (ft > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)) or
               c:IsAbleToHand()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_GRAVE,
                                           0, 1, nil, ft, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON, nil, 1,
                          tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil, ft, e, tp):GetFirst()
    if not tc then return end

    local b1 = tc:IsAbleToHand()
    local b2 = ft > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, true, false)

    local opt
    if b1 and b2 then
        opt = Duel.SelectOption(tp, 573, 574)
    elseif b1 then
        opt = Duel.SelectOption(player, 573)
    else
        opt = Duel.SelectOption(player, 574) + 1
    end

    if opt == 0 then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    else
        Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
    end
end

function s.e2filter1(c, e, tp, g)
    return c:IsFaceup() and c:IsCode(25833572) and c:IsAbleToDeck() and
               Duel.GetMZoneCount(tp, c, tp, LOCATION_REASON_TOFIELD) >= 3 and
               aux.SelectUnselectGroup(g, e, tp, 3, 3, s.e2spcheck, 0)
end

function s.e2filter2(c, e, tp)
    return c:IsCode(98434877, 62340868, 25955164) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2spcheck(sg, e, tp, mg) return sg:GetClassCount(Card.GetCode) == #sg end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_HAND +
                                            LOCATION_DECK + LOCATION_GRAVE, 0,
                                        nil, e, tp)
        return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0,
                                           1, nil, e, tp, g) and ft >= 2 and
                   not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 3, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft < 2 or Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        return
    end

    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e2filter2), tp,
                                    LOCATION_HAND + LOCATION_DECK +
                                        LOCATION_GRAVE, 0, nil, e, tp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local dg = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_MZONE, 0,
                                       1, 1, nil, e, tp, g)

    if #dg > 0 and Duel.SendtoDeck(dg, nil, 2, REASON_EFFECT) > 0 then
        Duel.BreakEffect()
        local sg = aux.SelectUnselectGroup(g, e, tp, 3, 3, s.e2spcheck, 1, tp,
                                           HINTMSG_SPSUMMON)
        Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end
