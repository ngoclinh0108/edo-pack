-- Cosmic Quasar Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.counter_list = {SignerDragon.COUNTER_SIGNER}
s.synchro_tuner_required = 1
s.synchro_nt_required = 2

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(SignerDragon.COUNTER_SIGNER)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and c:IsType(TYPE_SYNCHRO, sc, sumtype, tp)
    end, 1, 1, Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 2, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- summon & effect cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    spsafe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_SYNCHRO
    end)
    c:RegisterEffect(spsafe)
    local nodis1 = Effect.CreateEffect(c)
    nodis1:SetType(EFFECT_TYPE_SINGLE)
    nodis1:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis1)
    local nodis2 = Effect.CreateEffect(c)
    nodis2:SetType(EFFECT_TYPE_FIELD)
    nodis2:SetCode(EFFECT_CANNOT_DISEFFECT)
    nodis2:SetRange(LOCATION_MZONE)
    nodis2:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nodis2)

    -- counter (synchro summoned)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, re)
        return re:IsActiveType(TYPE_MONSTER) and re:GetOwner() ~= e:GetOwner()
    end)
    c:RegisterEffect(e2)

    -- negate effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- act limit & negate effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0, 1)
    e4:SetCondition(function(e)
        return Duel.GetAttacker() == e:GetHandler()
    end)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    local e4dis = Effect.CreateEffect(c)
    e4dis:SetType(EFFECT_TYPE_FIELD)
    e4dis:SetCode(EFFECT_DISABLE)
    e4dis:SetRange(LOCATION_MZONE)
    e4dis:SetTargetRange(0, LOCATION_MZONE)
    e4dis:SetCondition(s.e4discon)
    e4dis:SetTarget(s.e4distg)
    c:RegisterEffect(e4dis)
    local e4dis2 = e4dis:Clone()
    e4dis2:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e4dis2)

    -- chain attack
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_DAMAGE_STEP_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.e5con)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.max_counter(e)
    return e:GetHandler():GetMaterial():FilterCount(function(c)
        return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
    end, nil)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:AddCounter(SignerDragon.COUNTER_SIGNER, s.max_counter(e))
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanRemoveCounter(tp, SignerDragon.COUNTER_SIGNER, 1, REASON_COST)
    end

    c:RemoveCounter(tp, SignerDragon.COUNTER_SIGNER, 1, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
    if rc:IsRelateToEffect(re) and rc:IsDestructable() then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end

function s.e4discon(e)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c and c:GetBattleTarget() and
               (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
end

function s.e4distg(e, c)
    return c == e:GetHandler():GetBattleTarget()
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker() == e:GetHandler()
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsCanRemoveCounter(tp, SignerDragon.COUNTER_SIGNER, 1, REASON_EFFECT) or
        not c:CanChainAttack(0) or not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        return
    end

    c:RemoveCounter(tp, SignerDragon.COUNTER_SIGNER, 1, REASON_EFFECT)
    Duel.ChainAttack()
end
