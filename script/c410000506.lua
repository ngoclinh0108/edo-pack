-- Signer Overdrive
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000500}
s.listed_series = {0xc2}

function s.initial_effect(c)
    -- add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(573)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return e:GetHandler():IsAbleToHand() end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end)
    c:RegisterEffect(e1)

    -- place dragon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search tuner
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON +
                       CATEGORY_TOGRAVE + CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCondition(function() return Duel.IsMainPhase() end)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- synchro summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 4))
    e5:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_ACTIVATE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetCondition(function() return Duel.IsMainPhase() end)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1filter(c, tp)
    local rc = c:GetReasonEffect():GetHandler()
    if rc and rc:IsCode(id) then return false end

    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
    if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end

    return c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and
               c:IsSummonType(SUMMON_TYPE_SYNCHRO) and ct > 0

end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsEnvironment(410000500, tp) and
               eg:IsExists(s.e1filter, 1, nil, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SendtoHand(c, nil, REASON_EFFECT) end
end

function s.e2filter(c)
    return c:IsLevel(1) and c:IsRace(RACE_DRAGON) and
               (c:IsLocation(LOCATION_DECK) or c:IsAbleToDeck())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND +
                                               LOCATION_DECK + LOCATION_GRAVE,
                                           0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_HAND +
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil):GetFirst()
    if not tc then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    if tc:IsLocation(LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
        Duel.MoveSequence(tc, SEQ_DECKTOP)
    else
        Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT)
    end
    Duel.ConfirmDecktop(tp, 1)
end

function s.e3check1(c) return c:IsAbleToHand() end

function s.e3check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e3filter1(c, e, tp)
    return (s.e3check1(c) or s.e3check2(c, e, tp)) and c:IsType(TYPE_TUNER)
end

function s.e3filter2(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_DECK, 0, 1,
                                           nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetValue(aux.indoval)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    aux.RegisterClientHint(c, nil, 1 - tp, 1, 0, aux.Stringid(id, 0), nil)

    local g = Duel.GetMatchingGroup(s.e3filter1, tp, LOCATION_DECK, 0, nil, e,
                                    tp)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()

    local b1 = s.e3check1(sc)
    local b2 = s.e3check2(sc, e, tp)
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, 573, 2)
    elseif b1 then
        op = Duel.SelectOption(tp, 573)
    else
        op = Duel.SelectOption(tp, 2) + 1
    end

    if op == 0 then
        Duel.SendtoHand(sc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sc)
    else
        Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP)
    end

    if Duel.IsExistingMatchingCard(s.e3filter2, tp,
                                   LOCATION_HAND + LOCATION_DECK, 0, 1, nil) and
        Duel.SelectYesNo(tp, 504) then
        local sg = Duel.SelectMatchingCard(tp, s.e3filter2, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           1, nil)
        if #sg > 0 then Duel.SendtoGrave(sg, REASON_EFFECT) end
    end
end

function s.e4filter(c, e, tp)
    return c:IsType(TYPE_TUNER) and c:IsRace(RACE_DRAGON) and
               c:IsType(TYPE_SYNCHRO) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp,
                                           LOCATION_EXTRA + LOCATION_GRAVE, 0,
                                           1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0,
                          LOCATION_EXTRA + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp,
                                      LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, 1,
                                      nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, SUMMON_TYPE_SYNCHRO, tp, tp, false, false,
                           POS_FACEUP)
    end
end

function s.e5rescon(tuner, scard)
    return function(sg, e, tp, mg)
        sg:AddCard(tuner)
        local res = Duel.GetLocationCountFromEx(tp, tp, sg, scard) > 0 and
                        sg:CheckWithSumEqual(Card.GetLevel, scard:GetLevel(),
                                             #sg, #sg)
        sg:RemoveCard(tuner)
        return res
    end
end

function s.e5filter1(c, e, tp)
    return c:IsType(TYPE_SYNCHRO) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
               Duel.IsExistingMatchingCard(s.e5filter2, tp,
                                           LOCATION_MZONE + LOCATION_GRAVE, 0,
                                           1, nil, e, tp, c)
end

function s.e5filter2(c, e, tp, sc)
    local g = Duel.GetMatchingGroup(s.e5filter3, tp,
                                    LOCATION_MZONE + LOCATION_GRAVE, 0, c)
    return aux.SelectUnselectGroup(g, e, tp, nil, 2, s.e5rescon(c, sc), 0) and
               c:IsType(TYPE_TUNER) and c:IsAbleToRemove()

end

function s.e5filter3(c)
    return not c:IsType(TYPE_TUNER) and c:IsAbleToRemove() and c:HasLevel()
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil,
                                              nil, REASON_SYNCHRO)
        return Duel.IsExistingMatchingCard(s.e5filter1, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp) and #pg <= 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil, nil,
                                          REASON_SYNCHRO)
    if #pg > 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e5filter1, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp):GetFirst()
    if sc then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local tuner = Duel.SelectMatchingCard(tp, s.e5filter2, tp,
                                              LOCATION_MZONE + LOCATION_GRAVE,
                                              0, 1, 1, nil, e, tp, sc):GetFirst()
        local nontuners = Duel.GetMatchingGroup(s.e5filter3, tp,
                                                LOCATION_MZONE + LOCATION_GRAVE,
                                                0, tuner)

        local sg = aux.SelectUnselectGroup(nontuners, e, tp, 1, 2,
                                           s.e5rescon(tuner, sc), 1, tp,
                                           HINTMSG_REMOVE, s.e5rescon(tuner, sc))
        sg:AddCard(tuner)
        Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)

        Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false,
                           POS_FACEUP)
        sc:CompleteProcedure()
    end
end
