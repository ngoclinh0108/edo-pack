function s.granteffect(e, tp, tc)
    local c = e:GetHandler()
    Utility.HintCard(tc)

    -- life point transfer
    Divine.RegisterRaFuse(c, tc, true)
    local paidlp = Duel.GetLP(tp) - 100
    Duel.PayLPCost(tp, paidlp)
    local label = {paidlp, paidlp}
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(label)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec1, true)

    -- unstoppable attack
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec2:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    Divine.RegisterRaEffect(tc, ec2, true)
    local spnoattack = tc:GetCardEffect(EFFECT_CANNOT_ATTACK)
    if spnoattack then spnoattack:Reset() end

    -- tribute monsters to up atk
    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 3))
    ec3:SetCategory(CATEGORY_ATKCHANGE)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec3:SetCode(EVENT_ATTACK_ANNOUNCE)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCountLimit(1)
    ec3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return Duel.GetAttacker() == c or
                   (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c) and
                   e:GetHandler():IsHasEffect(id)
    end)
    ec3:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil,
                                              c)
        end

        local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false,
                                              nil, c)
        e:SetLabel(g:GetSum(Card.GetBaseAttack))
        Duel.Release(g, REASON_COST)
    end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsHasEffect(id) then
            return
        end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(e:GetLabel())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterRaEffect(c, ec1)
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec3, true)

    -- after damage calculation
    local ec4 = Effect.CreateEffect(c)
    ec4:SetCategory(CATEGORY_TOGRAVE)
    ec4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec4:SetCode(EVENT_BATTLED)
    ec4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.GetAttacker() == e:GetHandler() and
                   e:GetHandler():IsHasEffect(id)
    end)
    ec4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsHasEffect(id) then return end

        Utility.HintCard(c)
        local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        Duel.SendtoGrave(g, REASON_EFFECT)
    end)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
    Divine.RegisterRaEffect(tc, ec4, true)
end