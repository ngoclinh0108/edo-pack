-- Odd-Eyes Raging Dragon - Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x99}
s.listed_series = {0x99}
s.pendulum_level = 7

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, nil, 7, 2, nil, 0, nil, nil, false, function(g, tp, sc)
        return g:IsExists(function(tc)
            return tc:IsSetCard(0x99, sc, SUMMON_TYPE_XYZ, tp) and
                       tc:IsRace(RACE_DRAGON, sc, SUMMON_TYPE_XYZ, tp) and
                       c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_XYZ, tp)
        end, 1, nil)
    end)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_XYZ) == SUMMON_TYPE_XYZ or
                   (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- chain attack
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe1:SetCode(EVENT_DAMAGE_STEP_END)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetCondition(s.pe1con)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- place pendulum
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_DESTROYED)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- negate & gain atk
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DISABLE)
    me2:SetType(EFFECT_TYPE_QUICK_O)
    me2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    me2:SetCode(EVENT_FREE_CHAIN)
    me2:SetRange(LOCATION_MZONE)
    me2:SetHintTiming(TIMING_DAMAGE_STEP,
                      TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER)
    me2:SetCountLimit(1)
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- second attack
    local me3 = Effect.CreateEffect(c)
    me3:SetType(EFFECT_TYPE_SINGLE)
    me3:SetCode(EFFECT_EXTRA_ATTACK)
    me3:SetValue(1)
    me3:SetCondition(s.meffcon)
    c:RegisterEffect(me3)

    -- destroy
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(aux.Stringid(id, 2))
    me4:SetCategory(CATEGORY_DESTROY)
    me4:SetType(EFFECT_TYPE_IGNITION)
    me4:SetRange(LOCATION_MZONE)
    me4:SetCountLimit(1)
    me4:SetCondition(s.meffcon)
    me4:SetCost(s.me4cost)
    me4:SetTarget(s.me4tg)
    me4:SetOperation(s.me4op)
    c:RegisterEffect(me4, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    return ac and ac:IsFaceup() and ac:IsControler(tp) and
               Duel.GetAttackTarget() ~= nil
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local ac = Duel.GetAttacker()
    if ac and ac:IsRelateToBattle() and ac:IsControler(tp) then
        Duel.ChainAttack()
    end
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ac = Duel.GetAttacker()
    if chk == 0 then return ac and ac:CanChainAttack() end
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                   Duel.CheckLocation(tp, LOCATION_PZONE, 1)
    end
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.CheckLocation(tp, LOCATION_PZONE, 0) and
        not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then return false end
    if not c:IsRelateToEffect(e) then return end

    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or
               not Duel.IsDamageCalculated()
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1,
                                     nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    Duel.NegateRelatedChain(tc, RESET_TURN_SET)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_DISABLE_EFFECT)
    ec2:SetValue(RESET_TURN_SET)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec2)

    if not tc:IsImmuneToEffect(e) then
        Duel.AdjustInstantly(tc)

        local atk = tc:GetAttack()
        local ec3 = Effect.CreateEffect(c)
        ec3:SetType(EFFECT_TYPE_SINGLE)
        ec3:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        ec3:SetValue(math.ceil(atk / 2))
        tc:RegisterEffect(ec3)

        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local ec4 = Effect.CreateEffect(c)
            ec4:SetType(EFFECT_TYPE_SINGLE)
            ec4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            ec4:SetCode(EFFECT_UPDATE_ATTACK)
            ec4:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            ec4:SetValue(math.ceil(atk / 2))
            c:RegisterEffect(ec4)
        end
    end
end

function s.mefffilter(c) return c:IsType(TYPE_XYZ) and c:IsRace(RACE_DRAGON) end

function s.meffcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(s.mefffilter, 1, nil)
end

function s.me4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    if chk == 0 then
        return #g > 0 and c:CheckRemoveOverlayCard(tp, 1, REASON_COST)
    end

    local rt = math.min(#g, c:GetOverlayCount())
    c:RemoveOverlayCard(tp, 1, rt, REASON_COST)
    e:SetLabel(Duel.GetOperatedGroup():GetCount())
end

function s.me4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.me4op(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetLabel()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1,
                                      ct, nil)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end
