-- Palladium Kuriboh
local s, id = GetID()

function s.initial_effect(c)
    -- take card
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1bool1(c) return c:IsAbleToHand() end

function s.e1bool2(c, e, tp)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false,
                                        POS_FACEUP_DEFENSE)
end

function s.e1filter(c, e, tp)
    return c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and
               (s.e1bool1(c) or s.e1bool2(c, e, tp))
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReleasable() end

    Duel.Release(c, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                       nil, e, tp):GetFirst()
    if not tc then return end
    local b1 = s.e1bool1(tc)
    local b2 = s.e1bool2(tc, e, tp)

    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
    elseif b1 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 1))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id, 2)) + 1
    end

    if op == 0 then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    else
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end

function s.e2filter(c, ft, tp)
    return ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        return ft > -1 and
                   Duel.CheckReleaseGroupCost(tp, s.e2filter, 1, false, nil,
                                              nil, ft, tp)
    end

    local g = Duel.SelectReleaseGroupCost(tp, s.e2filter, 1, 1, false, nil, nil,
                                          ft, tp)
    Duel.Release(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false,
                                        POS_FACEUP_DEFENSE)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
