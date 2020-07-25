-- Slifer's Apostle
local s, id = GetID()

function s.initial_effect(c)
    -- 3 tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e1:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1000000)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_RELEASE)
    e3:SetCountLimit(1, id + 2000000)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter1(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and not c:IsPublic()
end

function s.e2filter2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e2filter1, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) >= 1 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or
        not c:IsRelateToEffect(e) then return end

    if Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP_DEFENSE) <= 0 then
        return
    end

    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or
        not Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_GRAVE,
                                        LOCATION_GRAVE, 2, nil, e, tp) then
        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_GRAVE,
                                      LOCATION_GRAVE, 2, 2, nil, e, tp)
    for tc in aux.Next(g) do
        Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_DISABLE_EFFECT)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
        local ec3 = Effect.CreateEffect(c)
        ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec3:SetCode(EVENT_PHASE + PHASE_END)
        ec3:SetRange(LOCATION_MZONE)
        ec3:SetCountLimit(1)
        ec3:SetOperation(s.e2gyop)
        ec3:SetReset(RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec3)
    end
    Duel.SpecialSummonComplete()
end

function s.e2gyop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON) and
               re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Draw(p, 2, REASON_EFFECT)
end
