-- Palladium Azure Oracle Seto
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.listed_series = {0xdd}

function s.initial_effect(c)
    -- to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK +
                       CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- fusion summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1170)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SUMMON, s.e3counterfilter)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.e3counterfilter)
end

function s.e1filter1(c)
    return Utility.IsSetCard(c, 0xdd) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToHand()
end

function s.e1filter2(c, e, tp)
    return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsType(TYPE_TUNER) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return not c:IsPublic() and
                   Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost, tp,
                                               LOCATION_HAND, 0, 1, c)
    end

    Duel.ConfirmCards(1 - tp, c)

    local g = Utility.SelectMatchingCard(tp, Card.IsAbleToDeck, tp,
                                         LOCATION_HAND, 0, 1, 1, c,
                                         HINTMSG_TODECK)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter1, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc = Utility.SelectMatchingCard(tp,
                                          aux.NecroValleyFilter(s.e1filter1),
                                          tp, LOCATION_DECK + LOCATION_GRAVE, 0,
                                          1, 1, nil, HINTMSG_ATOHAND):GetFirst()
    if not tc or Duel.SendtoHand(tc, nil, REASON_EFFECT) == 0 or
        not tc:IsLocation(LOCATION_HAND) then return end
    Duel.ConfirmCards(1 - tp, tc)
    Duel.ShuffleHand(tp)
    Duel.ShuffleDeck(tp)

    local g = Duel.GetMatchingGroup(s.e1filter2, tp, LOCATION_DECK, 0, nil, e,
                                    tp)
    if tc:IsType(TYPE_NORMAL) and #g > 0 and
        Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
        Duel.SelectYesNo(tp, 509) then
        Duel.BreakEffect()

        g = Utility.GroupSelect(g, tp, 1, 1, nil, HINTMSG_SPSUMMON)
        if #g == 0 then return end
        if Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_FIELD)
            ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
            ec1:SetCode(EFFECT_CANNOT_SUMMON)
            ec1:SetTargetRange(1, 0)
            ec1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(ec1, tp)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_CANNOT_MSET)
            Duel.RegisterEffect(ec1b, tp)
            aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 1), nil)
        end
    end
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e2filter1(c, e, tp)
    return c:IsFaceup() and c:IsCode(CARD_BLUEEYES_W_DRAGON) and
               c:IsCanBeFusionMaterial() and
               Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, c)
end

function s.e2filter2(c, e, tp, mc)
    if Duel.GetLocationCountFromEx(tp, tp, mc, c) <= 0 then return false end
    local mustg = aux.GetMustBeMaterialGroup(tp, nil, tp, c, nil, REASON_FUSION)
    return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c, mc:GetCode()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and
               (#mustg == 0 or (#mustg == 1 and mustg:IsContains(mc)))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil,
                                     e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or
        not tc:IsCanBeFusionMaterial() or tc:IsImmuneToEffect(e) then return end

    local sc = Utility.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_EXTRA,
                                          0, 1, 1, nil, HINTMSG_SPSUMMON, e, tp,
                                          tc):GetFirst()
    if sc then
        sc:SetMaterial(Group.FromCards(tc))
        Duel.SendtoGrave(tc, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
        Duel.BreakEffect()

        Duel.SpecialSummon(sc, SUMMON_TYPE_FUSION, tp, tp, false, false,
                           POS_FACEUP)
        sc:CompleteProcedure()
    end
end

function s.e3filter(c, e, tp)
    return c:IsCode(CARD_BLUEEYES_W_DRAGON) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsReleasable() and
                   Duel.GetCustomActivityCount(id, tp, ACTIVITY_SUMMON) == 0 and
                   Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0
    end

    Duel.Release(c, REASON_COST)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c)
        return not (c:IsCode(id) or c:IsCode(CARD_BLUEEYES_W_DRAGON))
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    Duel.RegisterEffect(ec1b, tp)
    aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 3), nil)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return
            Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil, e, tp) and
                Duel.GetLocationCount(tp, LOCATION_MZONE) > -1
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft > 3 then ft = 3 end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    if ft <= 0 then return end

    local g = Utility.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter),
                                         tp, LOCATION_HAND + LOCATION_DECK +
                                             LOCATION_GRAVE, 0, 1, ft, nil,
                                         HINTMSG_SPSUMMON, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e3counterfilter(c)
    return c:IsCode(id) or c:IsCode(CARD_BLUEEYES_W_DRAGON)
end
