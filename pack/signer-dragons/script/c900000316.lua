-- Salvation Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x3f}

function s.initial_effect(c)
    -- synchro limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    e1:SetValue(function(e, c)
        if not c then
            return false
        end
        return not c:IsSetCard(0x3f)
    end)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter1(c)
    return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end

function s.e2filter2(c, e, tp)
    return not c:IsCode(id) and c:IsRace(RACE_DRAGON) and c:IsLevel(1) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return not c:IsPublic()
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c, sump, sumtype, sumpos, targetp, se)
        return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON))
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, LOCATION_HAND)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) == 0 then
        return
    end

    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
        Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil) and
        Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp) and
        Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end
