-- Obelisk's Apostle
local s, id = GetID()

function s.initial_effect(c)
    -- 3 tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e1:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e1)

    -- summon DIVINE
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1, id + 1000000)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- token
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
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

function s.e2filter2(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsSummonable(true, nil, 1) or
               c:IsMSetable(true, nil, 1)
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
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_HAND, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    ec1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
    ec1:SetTargetRange(0, LOCATION_MZONE)
    ec1:SetCountLimit(1)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_HAND, 0, 1,
                                       1, nil):GetFirst()
    if not tc then return end

    local b1 = tc:IsSummonable(true, nil, 1)
    local b2 = tc:IsMSetable(true, nil, 1)
    if (b1 and b2 and
        Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK + POS_FACEDOWN_DEFENSE) ==
        POS_FACEUP_ATTACK) or not b2 then
        Duel.Summon(tp, tc, true, nil, 1)
    else
        Duel.MSet(tp, tc, true, nil, 1)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON) and
               re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp, 410000000, 0x54b,
                                                        TYPES_TOKEN, 0, 0, 1,
                                                        RACE_SPELLCASTER,
                                                        ATTRIBUTE_EARTH)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 2, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, 410000000, 0x54b,
                                                 TYPES_TOKEN, 0, 0, 1,
                                                 RACE_SPELLCASTER,
                                                 ATTRIBUTE_EARTH) then return end

    for i = 1, 2 do
        local token = Duel.CreateToken(tp, 410000000)
        Duel.SpecialSummonStep(token, 0, tp, tp, false, false,
                               POS_FACEUP_DEFENSE)
    end
    Duel.SpecialSummonComplete()
end
