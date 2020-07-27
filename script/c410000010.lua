-- Palladium Kuriboh
local s, id = GetID()

function s.initial_effect(c)
    -- damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- take card
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(1)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_CHANGE_DAMAGE)
    ec2:SetValue(0)
    Duel.RegisterEffect(ec2, tp)
    local ec3 = ec1:Clone()
    ec3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(ec3, tp)
end

function s.e2bool1(c) return c:IsAbleToHand() end

function s.e2bool2(c, e, tp)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false,
                                        POS_FACEUP_DEFENSE)
end

function s.e2filter(c, e, tp)
    return c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and
               (s.e2bool1(c) or s.e2bool2(c, e, tp))
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsReleasable() end

    Duel.Release(c, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_DECK + LOCATION_GRAVE, 0, 1,
                                           nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp,
                                       LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1,
                                       nil, e, tp):GetFirst()
    if not tc then return end
    local b1 = s.e2bool1(tc)
    local b2 = s.e2bool2(tc, e, tp)

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

function s.e3filter(c, ft, tp)
    return ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        return ft > -1 and
                   Duel.CheckReleaseGroupCost(tp, s.e3filter, 1, false, nil,
                                              nil, ft, tp)
    end

    local g = Duel.SelectReleaseGroupCost(tp, s.e3filter, 1, 1, false, nil, nil,
                                          ft, tp)
    Duel.Release(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false,
                                        POS_FACEUP_DEFENSE)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
