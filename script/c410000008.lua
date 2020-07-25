-- Ra's Apostle
local s, id = GetID()

function s.initial_effect(c)
    -- 3 tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e1:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e1)

    -- return spell
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id + 1000000)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain lp
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_RECOVER)
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
    return c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
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
        return Duel.IsExistingTarget(s.e2filter2, tp, LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e2filter2, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 3000)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Recover(tp, 3000, REASON_EFFECT)
end
