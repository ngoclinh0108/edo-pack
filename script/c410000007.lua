-- Palladium Apostle of Slifer
local s, id = GetID()

function s.initial_effect(c)
    -- draw summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- 3 tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e2:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e2)

    -- draw tribute
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_RELEASE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- draw battle
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and
               not c:IsPublic()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND, 0, 1,
                                           nil) and c:IsDiscardable()
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_HAND, 0, 1,
                                      1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    ec1:SetCode(EVENT_SPSUMMON_SUCCESS)
    ec1:SetCondition(s.e1regcon)
    ec1:SetOperation(s.e1regop)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_DELAY)
    ec2:SetCode(EVENT_SPSUMMON_SUCCESS)
    ec2:SetCondition(s.e1drcon1)
    ec2:SetOperation(s.e1drop1)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    ec3:SetCode(EVENT_CHAIN_SOLVED)
    ec3:SetCondition(s.e1drcon2)
    ec3:SetOperation(s.e1drop2)
    ec3:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec3, tp)
end

function s.e1drfilter(c, sp) return c:GetSummonPlayer() == sp end

function s.e1regcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1drfilter, 1, nil, 1 - tp) and
               re:IsHasType(EFFECT_TYPE_ACTIONS) and
               not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end

function s.e1regop(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, RESET_CHAIN, 0, 1)
end

function s.e1drcon1(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1drfilter, 1, nil, 1 - tp) and
               (not re:IsHasType(EFFECT_TYPE_ACTIONS) or
                   re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end

function s.e1drop1(e, tp, eg, ep, ev, re, r, rp) Duel.Draw(tp, 1, REASON_EFFECT) end

function s.e1drcon2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) > 0
end

function s.e1drop2(e, tp, eg, ep, ev, re, r, rp)
    local n = Duel.GetFlagEffect(tp, id)
    Duel.ResetFlagEffect(tp, id)
    Duel.Draw(tp, n, REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON) and
               re:GetHandler():IsAttribute(ATTRIBUTE_DIVINE)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    local dc = Duel.GetAttackTarget()

    if not dc or ac:GetControler() == dc:GetControler() then return false end
    local sc = ac:IsControler(tp) and ac or dc
    return sc:IsFaceup() and sc:IsOriginalAttribute(ATTRIBUTE_DIVINE)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
