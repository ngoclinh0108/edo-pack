-- Evil HERO Savage Heart
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- add name
    local addname = Effect.CreateEffect(c)
    addname:SetType(EFFECT_TYPE_SINGLE)
    addname:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    addname:SetCode(EFFECT_ADD_CODE)
    addname:SetValue(86188410)
    c:RegisterEffect(addname)

    -- trap immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, te)
        return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1)

    -- disable trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return (r & REASON_FUSION) == REASON_FUSION and c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and c:IsFaceup()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()

    -- disable
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetTargetRange(0, LOCATION_SZONE)
    ec1:SetTarget(s.e2distg)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_TRAPMONSTER)
    ec1b:SetTargetRange(0, LOCATION_MZONE)
    Duel.RegisterEffect(ec1b, tp)
    local ec1c = Effect.CreateEffect(c)
    ec1c:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1c:SetCode(EVENT_CHAIN_SOLVING)
    ec1c:SetOperation(s.e2disop)
    ec1c:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1c, tp)
end

function s.e2distg(e, c)
    return c:IsTrap()
end

function s.e2disop(e, tp, eg, ep, ev, re, r, rp)
    local loc, tgp = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION, CHAININFO_TRIGGERING_PLAYER)
    if tgp ~= tp and loc == LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
        Duel.NegateEffect(ev)
    end
end
