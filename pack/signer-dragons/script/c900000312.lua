-- Cosmic Quasar Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.counter_list = {SignerDragon.COUNTER_COSMIC}
s.synchro_tuner_required = 1
s.synchro_nt_required = 2

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:EnableCounterPermit(SignerDragon.COUNTER_COSMIC)

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
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
    end)
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
end

function s.e1filter(c)
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = c:GetMaterial():FilterCount(s.e1filter, nil)
    c:AddCounter(SignerDragon.COUNTER_COSMIC, ct)
end
