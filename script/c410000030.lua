-- Departure to the Afterlife
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- block monster
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.effcost)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- block spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCost(s.effcost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.efffilter(c) return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x13a) end

function s.effcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, s.efffilter, 1, false, nil, nil)
    end

    local rg = Duel.SelectReleaseGroupCost(tp, s.efffilter, 1, 1, false, nil,
                                           nil)
    Duel.Release(rg, REASON_COST)
    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    aux.RegisterClientHint(c, nil, tp, 0, 1, aux.Stringid(id, 2), nil)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(0, 1)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_SUMMON)
    Duel.RegisterEffect(ec1b, tp)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    Duel.RegisterEffect(ec1c, tp)
    local ec1d = ec1:Clone()
    ec1d:SetCode(EFFECT_CANNOT_MSET)
    Duel.RegisterEffect(ec1d, tp)
    local ec1e = ec1:Clone()
    ec1e:SetCode(EFFECT_CANNOT_TURN_SET)
    Duel.RegisterEffect(ec1e, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec2:SetTargetRange(0, 1)
    ec2:SetValue(function(e, re, tp) return re:IsActiveType(TYPE_MONSTER) end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    aux.RegisterClientHint(c, nil, tp, 0, 1, aux.Stringid(id, 3), nil)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CANNOT_SSET)
    ec1:SetTargetRange(0, 1)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec2:SetTargetRange(0, 1)
    ec2:SetValue(function(e, re, tp)
        return re:IsHasType(EFFECT_TYPE_ACTIVATE)
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD)
    ec3:SetCode(EFFECT_DISABLE)
    ec3:SetTargetRange(0, LOCATION_SZONE)
    ec3:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec3, tp)

    local ec4 = Effect.CreateEffect(c)
    ec4:SetType(EFFECT_TYPE_FIELD)
    ec4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
    ec4:SetTargetRange(0, LOCATION_MZONE)
    ec4:SetTarget(function(e, c) return c:IsType(TYPE_SPELL + TYPE_TRAP) end)
    ec4:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec4, tp)
end
