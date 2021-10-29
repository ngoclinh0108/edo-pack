-- Evolution of Divine-Beast
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsOriginalAttribute(ATTRIBUTE_DIVINE) and
               Divine.GetDivineHierarchy(c) > 0 and
               not Divine.IsDivineEvolution(c)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                           nil)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e1filter, tp,
                                          LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then return end

    Duel.HintSelection(Group.FromCards(tc))
    Divine.DivineEvolution(tc)
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD,
                          EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_CANNOT_DISABLE)
    Divine.RegisterGrantEffect(tc, ec1)
    local ec1b = Effect.CreateEffect(c)
    ec1b:SetType(EFFECT_TYPE_FIELD)
    ec1b:SetRange(LOCATION_MZONE)
    ec1b:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1b:SetTargetRange(1, 0)
    ec1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    Divine.RegisterGrantEffect(tc, ec1b)
    local ec1c = ec1b:Clone()
    ec1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    Divine.RegisterGrantEffect(tc, ec1c)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_UPDATE_ATTACK)
    ec2:SetValue(1000)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterGrantEffect(tc, ec2)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_UPDATE_DEFENSE)
    Divine.RegisterGrantEffect(tc, ec2b)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 1))
    ec3:SetCategory(CATEGORY_TOGRAVE)
    ec3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec3:SetTarget(s.e1gytg)
    ec3:SetOperation(s.e1gyop)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterGrantEffect(tc, ec3)
end

function s.e1gyfilter(c, p)
    return Duel.IsPlayerCanSendtoGrave(p, c) and not c:IsType(TYPE_TOKEN)
end

function s.e1gytg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1gyfilter, 1 - tp, LOCATION_MZONE,
                                           0, 1, nil, 1 - tp)
    end
end
function s.e1gyop(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, 1 - tp, s.e1gyfilter,
                                         1 - tp, LOCATION_MZONE, 0, 1, 1, nil,
                                         1 - tp)
    if #g > 0 then Duel.SendtoGrave(g, REASON_RULE) end
end

function s.e2filter(c)
    return c:IsLevel(10) and c:IsSummonableCard() and c:IsAbleToHand()
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKBOTTOM, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local tg = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                 nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, tg, #tg, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    if Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 then
        if Duel.GetFlagEffect(tp, id) ~= 0 then return end
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 2))
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        ec1:SetTargetRange(LOCATION_HAND, 0)
        ec1:SetTarget(aux.TargetBoolFunction(Card.IsLevel, 10))
        ec1:SetValue(0x1)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_EXTRA_SET_COUNT)
        Duel.RegisterEffect(ec1b, tp)
    end
end
