-- Sun Divine Dragon of Ra
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

s.listed_names = {95286165}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 2, true, true)

    -- destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- life point transfer
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2b:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2b:Clone()
    e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2c)
    local e2d = e2b:Clone()
    e2d:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2d)

    -- unstoppable attack
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsHasEffect(id) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE)
    end)
    c:RegisterEffect(e3)

    -- tribute monsters to up atk
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- after damage calculation
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BATTLED)
    e5:SetCondition(s.e5con)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- de-fuse
    aux.GlobalCheck(s, function()
        local defuse = Effect.CreateEffect(c)
        defuse:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        defuse:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        defuse:SetCode(EVENT_ADJUST)
        defuse:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            return Duel.IsExistingMatchingCard(s.defusefilter1, tp, 0xff, 0xff, 1, nil)
        end)
        defuse:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(s.defusefilter1, tp, 0xff, 0xff, nil)
            for tc in aux.Next(g) do
                local eff = Effect.CreateEffect(tc)
                eff:SetType(EFFECT_TYPE_SINGLE)
                eff:SetCode(id)
                tc:RegisterEffect(eff)

                local ec1 = Effect.CreateEffect(tc)
                ec1:SetDescription(aux.Stringid(id, 0))
                ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE + CATEGORY_RECOVER)
                ec1:SetType(EFFECT_TYPE_ACTIVATE)
                ec1:SetCode(tc:GetActivateEffect():GetCode())
                ec1:SetProperty(tc:GetActivateEffect():GetProperty() + EFFECT_FLAG_DAMAGE_STEP +
                                    EFFECT_FLAG_IGNORE_IMMUNE)
                ec1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
                ec1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
                    if chk == 0 then
                        return Duel.IsExistingTarget(s.defusefilter2, tp, LOCATION_MZONE, 0, 1, nil, id)
                    end

                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
                    local tc = Duel.SelectTarget(tp, s.defusefilter2, tp, LOCATION_MZONE, 0, 1, 1, nil, id):GetFirst()

                    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tc:GetControler(), tc:GetAttack())
                    Duel.SetChainLimit(aux.FALSE)
                end)
                ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                    local c = e:GetHandler()
                    local tc = Duel.GetFirstTarget()
                    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsHasEffect(id) then
                        return
                    end

                    tc:RegisterFlagEffect(95286165, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)

                    local atk = tc:GetAttack()
                    tc:GetCardEffect(id):Reset()
                    if tc:GetCardEffect(EFFECT_SET_BASE_ATTACK) then
                        tc:GetCardEffect(EFFECT_SET_BASE_ATTACK):Reset()
                    end
                    if tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE) then
                        tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE):Reset()
                    end

                    local ec1 = Effect.CreateEffect(c)
                    ec1:SetType(EFFECT_TYPE_SINGLE)
                    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
                    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
                    ec1:SetValue(0)
                    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    tc:RegisterEffect(ec1)
                    local ec1b = ec1:Clone()
                    ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
                    tc:RegisterEffect(ec1b)
                    Duel.AdjustInstantly(tc)
                    Duel.Recover(tc:GetControler(), atk, REASON_EFFECT)

                    local ec2 = Effect.CreateEffect(c)
                    ec2:SetType(EFFECT_TYPE_SINGLE)
                    ec2:SetCode(EFFECT_CANNOT_TRIGGER)
                    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
                    tc:RegisterEffect(ec2)
                end)
                tc:RegisterEffect(ec1)
            end
        end)
        Duel.RegisterEffect(defuse, 0)
    end)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLPCost(tp, 1000)
    end

    Duel.PayLPCost(tp, 1000)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    Duel.SetTargetCard(g)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then
        return
    end

    Duel.Destroy(tc, REASON_EFFECT)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLP(tp) > 100
    end

    local lp = Duel.GetLP(tp) - 100
    Duel.PayLPCost(tp, lp)

    e:SetLabelObject({c:GetBaseAttack() + lp, c:GetBaseDefense() + lp})
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end

    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then
        return
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetDescription(aux.Stringid(id, 2))
    ec0:SetType(EFFECT_TYPE_SINGLE)
    ec0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec0:SetCode(id)
    ec0:SetLabelObject(e:GetLabelObject())
    ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec0)
    if c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE) then
        Utility.ResetListEffect(c, nil, EFFECT_CANNOT_ATTACK)
    end

    -- fusion type
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec1:SetCode(EFFECT_ADD_TYPE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCondition(function(e)
        return e:GetHandler():IsHasEffect(id)
    end)
    ec1:SetValue(TYPE_FUSION)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)

    -- atk/def
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_SET_BASE_ATTACK)
    ec2:SetCondition(function(e)
        return e:GetHandler():IsHasEffect(id)
    end)
    ec2:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[1]
    end)
    c:RegisterEffect(ec2)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2b:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[2]
    end)
    c:RegisterEffect(ec2b)

    -- life point transfer (lp convert)
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetCode(EVENT_RECOVER)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCondition(function(e, tp, eg, ep)
        return ep == tp
    end)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or not c:IsHasEffect(id) then
            return
        end

        local eff = c:GetCardEffect(id)
        local label = eff:GetLabelObject()
        label[1] = label[1] + ev
        label[2] = label[2] + ev
        eff:SetLabelObject(label)

        Duel.SetLP(tp, Duel.GetLP(tp) - ev, REASON_EFFECT)
    end)
    c:RegisterEffect(ec3)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsHasEffect(id) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_GRAVE) and
               (Duel.GetAttacker() == c or (Duel.GetAttackTarget() and Duel.GetAttackTarget() == c))
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 1, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, Card.IsFaceup, 1, 99, false, nil, c)
    e:SetLabel(g:GetSum(Card.GetBaseAttack))
    Duel.Release(g, REASON_COST)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsHasEffect(id) then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return
        Duel.GetAttacker() == c and c:IsHasEffect(id) and c:IsHasEffect(id) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and
            c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if not c:IsHasEffect(id) or #g == 0 then
        return
    end

    Utility.HintCard(c)
    Duel.SendtoGrave(g, REASON_EFFECT)
end

function s.defusefilter1(c)
    return c:IsCode(95286165) and not c:IsHasEffect(id)
end

function s.defusefilter2(c, id)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(CARD_RA) and c:IsHasEffect(id)
end
