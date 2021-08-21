-- Divine Hieroglyph
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(function() return Duel.IsMainPhase() end)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsMainPhase() end

function s.e1filter1(c, ec)
    if not c:IsRace(RACE_DIVINE) then return false end

    local ec1 = Effect.CreateEffect(ec)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_CHAIN)
    c:RegisterEffect(ec1, true)

    local res = c:IsSummonable(true, nil, 1) or c:IsMSetable(true, nil, 1)
    ec1:Reset()
    return res
end

function s.e1filter2(c)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DIVINE) and c:IsAbleToHand()
end

function s.e1check1(e, tp)
    return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_HAND, 0, 1,
                                       nil, e:GetHandler())
end

function s.e1check2(tp)
    return Duel.IsExistingMatchingCard(s.e1filter2, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) and
               Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil):GetClassCount(
                   Card.GetCode) >= 3
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.e1check1(e, tp) or s.e1check2(tp) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local b1 = s.e1check1(e, tp)
    local b2 = s.e1check2(tp)

    if (not b1 and b2) or (b2 and Duel.SelectYesNo(tp, aux.Stringid(id, 0))) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.e1filter2, tp,
                                          LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                          1, nil, tp)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter1, tp, LOCATION_HAND, 0, 1,
                                       1, nil, c):GetFirst()
    if not tc then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetValue(POS_FACEUP)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1, true)

    local s1 = tc:IsSummonable(true, nil, 1)
    local s2 = tc:IsMSetable(true, nil, 1)
    if (s1 and s2 and
        Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK + POS_FACEDOWN_DEFENSE) ==
        POS_FACEUP_ATTACK) or not s2 then
        Duel.Summon(tp, tc, true, nil, 1)
    else
        Duel.MSet(tp, tc, true, nil, 1)
    end
end
