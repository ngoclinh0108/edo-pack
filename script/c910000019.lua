-- Sun Dragon's Palladium Descendant
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA, 95286165}

function s.initial_effect(c)
    -- spirit return
    aux.EnableSpiritReturn(c, EVENT_SUMMON_SUCCESS, EVENT_FLIP)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.FALSE)
    c:RegisterEffect(splimit)

    -- summon cannot be negate & act limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1b:SetCode(EVENT_SUMMON_SUCCESS)
    e1b:SetOperation(function()
        Duel.SetChainLimitTillChainEnd(function(e, rp, tp)
            return tp == rp
        end)
    end)
    c:RegisterEffect(e1b)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY +
                       EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- triple tribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e3:SetValue(aux.TargetBoolFunction(Card.IsRace, RACE_DIVINE))
    c:RegisterEffect(e3)

    -- extra summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    e4:SetTarget(aux.TargetBoolFunction(Card.IsRace, RACE_DIVINE))
    c:RegisterEffect(e4)

    -- gain effect
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BE_PRE_MATERIAL)
    e5:SetCondition(s.e5regcon)
    e5:SetOperation(s.e5regop)
    c:RegisterEffect(e5)

    aux.GlobalCheck(s, function()
        -- de-fusion
        local e5defuse = Effect.CreateEffect(c)
        e5defuse:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e5defuse:SetCode(EVENT_ADJUST)
        e5defuse:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local g = Duel.GetMatchingGroup(function(c)
                return c:IsCode(95286165) and c:GetFlagEffect(id) == 0
            end, tp, 0xff, 0xff, nil)

            for tc in aux.Next(g) do
                tc:RegisterFlagEffect(id, 0, 0, 0)
                local ec1 = Effect.CreateEffect(tc)
                ec1:SetDescription(aux.Stringid(id, 3))
                ec1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE +
                                    CATEGORY_RECOVER)
                ec1:SetType(EFFECT_TYPE_ACTIVATE)
                ec1:SetCode(tc:GetActivateEffect():GetCode())
                ec1:SetProperty(tc:GetActivateEffect():GetProperty() |
                                    EFFECT_FLAG_IGNORE_IMMUNE)
                ec1:SetTarget(s.e5defusetg)
                ec1:SetOperation(s.e5defuseop)
                tc:RegisterEffect(ec1)
            end
        end)
        Duel.RegisterEffect(e5defuse, 0)
    end)
end

function s.e2filter(c) return c:GetTextAttack() > 0 end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE,
                                     LOCATION_GRAVE, 1, nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 2,
                      nil, e, tp)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(
                   Card.IsRelateToEffect, nil, e)
    if #tg > 0 and c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    for tc in aux.Next(tg) do
        if tc:GetTextAttack() > 0 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_UPDATE_ATTACK)
            ec1:SetValue(tc:GetTextAttack())
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE +
                             PHASE_END)
            c:RegisterEffect(ec1)
        end
    end
end

function s.e5regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(CARD_RA)
end

function s.e5regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    rc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD,
                          EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))

    -- life point transfer: pay lp
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_IGNITION)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCountLimit(1)
    ec1:SetCost(s.e5lpcost)
    ec1:SetTarget(s.e5lptg)
    ec1:SetOperation(s.e5lpop)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec1)

    -- life point transfer: fusion type
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE)
    ec2:SetCode(EFFECT_ADD_TYPE)
    ec2:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    ec2:SetValue(TYPE_FUSION)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec2)

    -- life point transfer: base atk/def
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE)
    ec3:SetCode(EFFECT_SET_BASE_ATTACK)
    ec3:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
    ec3:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[1]
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec3)
    local ec3b = ec3:Clone()
    ec3b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec3b:SetValue(function(e)
        return e:GetHandler():GetCardEffect(id):GetLabelObject()[2]
    end)
    rc:RegisterEffect(ec3b)

    -- life point transfer: watch
    local ec4 = Effect.CreateEffect(c)
    ec4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    ec4:SetCode(EVENT_RECOVER)
    ec4:SetRange(LOCATION_MZONE)
    ec4:SetCondition(function(e, tp, eg, ep) return ep == tp end)
    ec4:SetOperation(s.e5lpwatchop)
    ec4:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec4)

    -- destroy
    local ec5 = Effect.CreateEffect(c)
    ec5:SetDescription(aux.Stringid(id, 4))
    ec5:SetCategory(CATEGORY_DESTROY)
    ec5:SetType(EFFECT_TYPE_IGNITION)
    ec5:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_IGNORE_IMMUNE +
                        EFFECT_FLAG_UNCOPYABLE)
    ec5:SetRange(LOCATION_MZONE)
    ec5:SetCost(s.e5descost)
    ec5:SetTarget(s.e5destg)
    ec5:SetOperation(s.e5desop)
    ec5:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec5)
end

function s.e5lpcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLP(tp) > 100 end

    local lp = Duel.GetLP(tp)
    e:SetLabel(lp - 100)
    Duel.PayLPCost(tp, lp - 100)
end

function s.e5lptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsType(TYPE_FUSION) end

    Duel.SetChainLimit(aux.FALSE)
end

function s.e5lpop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local label = {
        c:GetBaseAttack() + e:GetLabel(), c:GetBaseDefense() + e:GetLabel()
    }

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(id)
    ec1:SetLabelObject(label)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end

function s.e5lpwatchop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or
        not c:IsHasEffect(id) then return end

    local eff = c:GetCardEffect(id)
    local label = eff:GetLabelObject()
    label[1] = label[1] + ev
    label[2] = label[2] + ev
    eff:SetLabelObject(label)
    
    Duel.SetLP(tp, Duel.GetLP(tp) - ev, REASON_EFFECT)
end

function s.e5defusefilter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsCode(CARD_RA) and
               c:IsHasEffect(id)
end

function s.e5defusetg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e5defusefilter, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectTarget(tp, s.e5defusefilter, tp, LOCATION_MZONE,
                                 LOCATION_MZONE, 1, 1, nil):GetFirst()

    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tc:GetControler(),
                          tc:GetAttack())
end

function s.e5defuseop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsHasEffect(id) then
        return
    end

    local atk = tc:GetAttack()
    tc:GetCardEffect(id):Reset()
    tc:GetCardEffect(EFFECT_SET_BASE_ATTACK):Reset()
    tc:GetCardEffect(EFFECT_SET_BASE_DEFENSE):Reset()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(0)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    tc:RegisterEffect(ec1b)
    Duel.AdjustInstantly(tc)

    Duel.Recover(tc:GetControler(), atk, REASON_EFFECT)
end

function s.e5descost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e5destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_MZONE,
                                     LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE,
                                LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e5desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.Destroy(tc, REASON_EFFECT)
end
