-- NEXT Contact
local s, id = GetID()
Duel.LoadScript("util.lua")

s.listed_names = {42015635, CARD_NEOS}
s.listed_series = {0x1f, 0x8}

function s.initial_effect(c)
    -- send to GY & draw
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetLabel(1)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()
    end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon neo-spacian & neos
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetLabel(2)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon HERO fustion monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetLabel(3)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.efftgcheck(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id + e:GetLabel() * 1000000) == 0
end

function s.effop(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id + e:GetLabel() * 1000000,
                            RESET_PHASE + PHASE_END, 0, 1)

    if (Duel.IsEnvironment(42015635)) then
        local c = e:GetHandler()
        c:CancelToGrave()
        Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end

function s.e1filter(c) return c:IsSetCard(0x1f) and c:IsAbleToGrave() end

function s.e1check(g, e, tp) return g:GetClassCount(Card.GetLocation) == #g end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_HAND + LOCATION_DECK, 0, nil)

    if chk == 0 then
        return s.efftgcheck(e, tp, eg, ep, ev, re, r, rp) and
                   Duel.IsPlayerCanDraw(tp, 2) and
                   Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 3 and
                   aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 0)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())

    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e1filter, tp,
                                    LOCATION_HAND + LOCATION_DECK, 0, nil)
    g = aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 1, tp,
                                HINTMSG_TOGRAVE)

    if Duel.SendtoGrave(g, REASON_EFFECT) == 2 and
        Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil, LOCATION_GRAVE) ==
        2 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp, 2, REASON_EFFECT)
    end

    s.effop(e, tp, eg, ep, ev, re, r, rp)
end

function s.e2filter(c, e, tp)
    return (c:IsSetCard(0x1f) or c:IsCode(CARD_NEOS)) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.efftgcheck(e, tp, eg, ep, ev, re, r, rp) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND +
                                                   LOCATION_GRAVE +
                                                   LOCATION_REMOVED, 0, 1, nil,
                                               e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if ft <= 0 then
        s.effop(e, tp, eg, ep, ev, re, r, rp)
        return
    end

    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    if ft > 5 then ft = 5 end

    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e2filter), tp,
                                    LOCATION_HAND + LOCATION_GRAVE +
                                        LOCATION_REMOVED, 0, nil, e, tp)
    g = aux.SelectUnselectGroup(g, e, tp, 1, ft, aux.dncheck, 1, tp,
                                HINTMSG_SPSUMMON)
    if #g > 0 then
        for tc in aux.Next(g) do
            Duel.SpecialSummonStep(tc, 0, tp, tp, false, false,
                                   POS_FACEUP_DEFENSE)

            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3302)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_TRIGGER)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
            local ec2 = Effect.CreateEffect(c)
            ec2:SetDescription(aux.Stringid(id, 0))
            ec2:SetType(EFFECT_TYPE_FIELD)
            ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
            ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            ec2:SetRange(LOCATION_MZONE)
            ec2:SetAbsoluteRange(tp, 1, 0)
            ec2:SetTarget(function(e, c)
                return c:IsLocation(LOCATION_EXTRA) and
                           not c:IsType(TYPE_FUSION)
            end)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec2, true)
        end
        Duel.SpecialSummonComplete()
    end

    s.effop(e, tp, eg, ep, ev, re, r, rp)
end

function s.e3filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and
               aux.IsMaterialListCode(c, CARD_NEOS)
end

function s.e3filter2(c, e, tp)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and
               c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_MZONE, 0, 1,
                                       nil)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return s.efftgcheck(e, tp, eg, ep, ev, re, r, rp) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e3filter2, tp,
                                         LOCATION_GRAVE + LOCATION_REMOVED, 0,
                                         1, nil, e, tp)
    end

    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e3filter2, tp,
                                LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil,
                                e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0,
                          LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
    end

    s.effop(e, tp, eg, ep, ev, re, r, rp)
end
