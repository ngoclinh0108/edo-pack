-- Signer Overdrive
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000500}

function s.initial_effect(c)
    -- add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(573)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE + PHASE_DRAW)
    e1:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e, tp) return Duel.IsEnvironment(410000500, tp) end)
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

    -- search tuner
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON +
                       CATEGORY_TOGRAVE + CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- synchro
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2check1(c) return c:IsAbleToHand() end

function s.e2check2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e2filter1(c, e, tp)
    return (s.e2check1(c) or s.e2check2(c, e, tp)) and c:IsType(TYPE_TUNER)
end

function s.e2filter2(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFlagEffect(tp, id + 1 * 1000000) == 0 and
                   Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_DECK,
                                               0, 1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id + 1 * 1000000, RESET_PHASE + PHASE_END, 0, 1)
    local g = Duel.GetMatchingGroup(s.e2filter1, tp, LOCATION_DECK, 0, nil, e,
                                    tp)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()

    local b1 = s.e2check1(sc)
    local b2 = s.e2check2(sc, e, tp)
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

    if Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_DECK, 0, 1, nil) and
        Duel.SelectYesNo(tp, 504) then
        local sg = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_DECK,
                                           0, 1, 1, nil)
        if #sg > 0 then Duel.SendtoGrave(sg, REASON_EFFECT) end
    end
end

function s.e3rescon(tuner, scard)
    return function(sg, e, tp, mg)
        sg:AddCard(tuner)
        local res = Duel.GetLocationCountFromEx(tp, tp, sg, scard) > 0 and
                        sg:CheckWithSumEqual(Card.GetLevel, scard:GetLevel(),
                                             #sg, #sg)
        sg:RemoveCard(tuner)
        return res
    end
end

function s.e3filter1(c, e, tp)
    return c:IsType(TYPE_SYNCHRO) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false) and
               Duel.IsExistingMatchingCard(s.e3filter2, tp,
                                           LOCATION_MZONE + LOCATION_GRAVE, 0,
                                           1, nil, e, tp, c)
end

function s.e3filter2(c, e, tp, sc)
    local g = Duel.GetMatchingGroup(s.e3filter3, tp,
                                    LOCATION_MZONE + LOCATION_GRAVE, 0, c)
    return aux.SelectUnselectGroup(g, e, tp, nil, 2, s.e3rescon(c, sc), 0) and
               c:IsType(TYPE_TUNER) and c:IsAbleToRemove()

end

function s.e3filter3(c)
    return not c:IsType(TYPE_TUNER) and c:IsAbleToRemove() and c:HasLevel()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil,
                                              nil, REASON_SYNCHRO)
        return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp) and #pg <= 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.CreateGroup(), tp, nil, nil,
                                          REASON_SYNCHRO)
    if #pg > 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp):GetFirst()
    if sc then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local tuner = Duel.SelectMatchingCard(tp, s.e3filter2, tp,
                                              LOCATION_MZONE + LOCATION_GRAVE,
                                              0, 1, 1, nil, e, tp, sc):GetFirst()
        local nontuners = Duel.GetMatchingGroup(s.e3filter3, tp,
                                                LOCATION_MZONE + LOCATION_GRAVE,
                                                0, tuner)

        local sg = aux.SelectUnselectGroup(nontuners, e, tp, 1, 2,
                                           s.e3rescon(tuner, sc), 1, tp,
                                           HINTMSG_REMOVE, s.e3rescon(tuner, sc))
        sg:AddCard(tuner)
        Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)

        Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false,
                           POS_FACEUP)
        sc:CompleteProcedure()
    end
end
