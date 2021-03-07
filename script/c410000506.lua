-- Spark Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}

function s.initial_effect(c)
    -- synchron substitute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(20932152)
    c:RegisterEffect(e1)

    -- summon success
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2c)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_END_PHASE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c, e, tp)
    return c:IsLevelBelow(2) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false,
                                        POS_FACEUP_DEFENSE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp,
                                               LOCATION_HAND + LOCATION_GRAVE,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                       LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1,
                                       nil, e, tp):GetFirst()
    if tc and
        Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3302)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_TRIGGER)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end
    Duel.SpecialSummonComplete()

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec2:SetTargetRange(1, 0)
    ec2:SetTarget(function(e, c)
        return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
    aux.RegisterClientHint(c, nil, tp, 1, 0, 666004, nil)
end

function s.e3filter(c, e, tp)
    return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if c:GetSequence() < 5 then ft = ft + 1 end

    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil, e, tp) and ft > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp,
                                      LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                      nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end
