-- Odd-Eyes Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x99}

function s.initial_effect(c)
    -- pendulum
    Pendulum.AddProcedure(c)

    -- special summon odd-eyes
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    pe1:SetCode(EVENT_DESTROYED)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1, id + 1 * 1000000)
    pe1:SetCondition(s.pe1con)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- search
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id + 2 * 1000000)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)
end

function s.pe1filter1(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               c:IsPreviousSetCard(0x99) and c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsPreviousPosition(POS_FACEUP)
end

function s.pe1filter2(c, e, tp)
    return c:IsSetCard(0x99) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.pe1filter1, 1, nil, tp)
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.pe1filter2, tp,
                                               LOCATION_HAND + LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or
        not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.pe1filter2),
                                      tp, LOCATION_HAND + LOCATION_DECK +
                                          LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.pe2filter(c, ft, e, tp)
    if not c:IsType(TYPE_PENDULUM) or not c:IsAttackBelow(1500) then
        return false
    end

    return c:IsAbleToHand() or
               (c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
                   ft > 0)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsDestructable() and
                   Duel.IsExistingMatchingCard(s.pe2filter, tp,
                                               LOCATION_DECK + LOCATION_GRAVE,
                                               0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Destroy(c, REASON_EFFECT) == 0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 1))
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.pe2filter),
                                       tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                       1, nil, ft, e, tp):GetFirst()
    if not tc then return end

    aux.ToHandOrElse(tc, tp, function(c)
        return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
                   ft > 0
    end, function(c)
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end, 2)
end
