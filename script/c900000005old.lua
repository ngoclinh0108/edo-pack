-- Sun Divine Beast of Ra - Immortal Phoenix
function s.initial_effect(c)
    -- attack limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetValue(aux.TRUE)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_ATTACK_COST)
    e2b:SetCost(function(e, c, tp) return Duel.CheckLPCost(tp, 1000) end)
    e2b:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.PayLPCost(tp, 1000)
        Duel.AttackCostPaid()
    end)
    Divine.RegisterEffect(c, e2b)

    -- unstoppable attack
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    Divine.RegisterEffect(c, e5)

    -- to grave
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 4))
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_MZONE)
    e6:SetHintTiming(TIMING_END_PHASE)
    e6:SetCost(s.e6cost)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    Divine.RegisterEffect(c, e6)
end

function s.e6cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE,
                                               LOCATION_MZONE, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_MZONE,
                                      LOCATION_MZONE, 1, 1, c)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_CHAIN)
    tc:RegisterEffect(ec1, true)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1b, true)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1c:SetValue(function(e, te) return te:GetHandler() == e:GetHandler() end)
    tc:RegisterEffect(ec1c, true)
    Duel.AdjustInstantly(tc)
    Duel.SendtoGrave(tc, REASON_EFFECT)
end
