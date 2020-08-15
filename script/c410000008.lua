-- Palladium Apostle of Ra
local s, id = GetID()

function s.initial_effect(c)
    -- recover summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- 3 tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e2:SetValue(aux.TargetBoolFunction(Card.IsAttribute, ATTRIBUTE_DIVINE))
    c:RegisterEffect(e2)

    -- recover tribute
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_RELEASE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- recover grave
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and
               not c:IsPublic()
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() < PHASE_END
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
    ec2:SetCondition(s.e1reccon1)
    ec2:SetOperation(s.e1recop1)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    ec3:SetCode(EVENT_CHAIN_SOLVED)
    ec3:SetCondition(s.e1reccon2)
    ec3:SetOperation(s.e1recop2)
    ec3:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec3, tp)
    ec1:SetLabelObject(ec3)
end

function s.e1recfilter(c, sp)
    if not c:IsSummonPlayer(sp) then return false end
    if c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
    else
        return c:IsPreviousPosition(POS_FACEUP) and
                   c:IsPreviousLocation(LOCATION_MZONE)
    end
end

function s.e1recsum(c)
    if c:IsLocation(LOCATION_MZONE) then
        return c:GetAttack()
    else
        return c:GetPreviousAttackOnField()
    end
end

function s.e1regcon(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    return eg:IsExists(s.e1recfilter, 1, nil, 1 - tp) and
               re:IsHasType(EFFECT_TYPE_ACTIONS) and
               not re:IsHasType(EFFECT_TYPE_CONTINUOUS) and ph >= PHASE_MAIN1 and
               ph <= PHASE_MAIN2
end

function s.e1regop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e1recfilter, nil, 1 - tp)
    Duel.RegisterFlagEffect(tp, id, RESET_CHAIN, 0, 1)
    e:GetLabelObject():SetLabel(g:GetSum(s.e1recsum) +
                                    e:GetLabelObject():GetLabel())
end

function s.e1reccon1(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    return eg:IsExists(s.e1recfilter, 1, nil, 1 - tp) and
               (not re:IsHasType(EFFECT_TYPE_ACTIONS) or
                   re:IsHasType(EFFECT_TYPE_CONTINUOUS)) and ph >= PHASE_MAIN1 and
               ph <= PHASE_MAIN2
end

function s.e1recop1(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e1recfilter, nil, 1 - tp)
    if #g > 0 then
        local sum = g:GetSum(s.e1recsum)
        if sum ~= 0 then
            Duel.Hint(HINT_CARD, 0, id)
            Duel.Recover(tp, sum, REASON_EFFECT)
        end
    end
end

function s.e1reccon2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) > 0
end

function s.e1recop2(e, tp, eg, ep, ev, re, r, rp)
    Duel.ResetFlagEffect(tp, id)
    local rec = e:GetLabel()
    e:SetLabel(0)

    if rec ~= 0 then
        Duel.Hint(HINT_CARD, 0, id)
        Duel.Recover(tp, rec, REASON_EFFECT)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_SUMMON)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 2000)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Recover(tp, 2000, REASON_EFFECT)
end

function s.e4filter(c)
    return c:IsFaceup() and c:IsOriginalAttribute(ATTRIBUTE_DIVINE) and
               c:GetAttack() > 0
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, s.e4filter, 1, false, nil, nil)
    end

    local tc =
        Duel.SelectReleaseGroupCost(tp, s.e4filter, 1, 1, false, nil, nil):GetFirst()
    local rec = tc:GetAttack()
    Duel.Release(tc, REASON_COST)

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rec)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, rec)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)
end
