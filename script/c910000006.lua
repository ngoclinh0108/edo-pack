-- Giant Divine Soldier of Obelisk - Soul Energy MAX
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("util_dimension.lua")
local s, id = GetID()

s.listed_names = {10000000}

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, false, false)
    Dimension.AddProcedure(c)

    -- startup
    Dimension.RegisterChange(c, function(e, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_FREE_CHAIN)
        dms:SetCondition(Dimension.Condition(s.dmscon))
        dms:SetOperation(s.dmsop)
        Duel.RegisterEffect(dms, tp)
    end)

    -- return to original at end battle
    local reset = Effect.CreateEffect(c)
    reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    reset:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    reset:SetCode(EVENT_PHASE + PHASE_BATTLE)
    reset:SetRange(LOCATION_MZONE)
    reset:SetOperation(s.resetop)
    c:RegisterEffect(reset)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e1)

    -- infinite atk
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    Utility.AvatarInfinity(s, c)
end

function s.dmsfilter(c, tp)
    return Dimension.CanBeDimensionMaterial(c) and
               Duel.CheckReleaseGroupCost(tp, Card.IsFaceup, 2, false, nil, c) and
               c:IsCode(10000000) and c:GetOriginalCode() ~= id
end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.IsExistingMatchingCard(s.dmsfilter, tp, LOCATION_MZONE, 0, 1,
                                       nil, tp) then return false end
    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               (Duel.IsTurnPlayer(1 - tp) and Duel.IsBattlePhase())
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    Duel.BreakEffect()
    Utility.HintCard(id)

    local c = e:GetHandler()
    local mc = Utility.GroupSelect(Duel.GetMatchingGroup(s.dmsfilter, tp,
                                                         LOCATION_MZONE, 0, nil,
                                                         tp), tp, 1, 1, 666100):GetFirst()
    if not mc then return end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, mc)
    Duel.Release(g, REASON_COST)

    local atk = mc:GetBaseAttack()
    local def = mc:GetBaseDefense()
    local divine_evolution = mc:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0

    Dimension.Change(c, mc, tp, tp, mc:GetPosition())

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2:SetValue(def)
    c:RegisterEffect(ec2)

    if divine_evolution then
        c:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                             RESET_EVENT + RESETS_STANDARD,
                             EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
    end
end

function s.resetop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()

    local atk = c:GetBaseAttack()
    local def = c:GetBaseDefense()
    local divine_evolution = c:GetFlagEffect(Divine.DIVINE_EVOLUTION) > 0

    Dimension.Change(tc, c, tp, tp, c:GetPosition())

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec2:SetValue(def)
    tc:RegisterEffect(ec2)

    if divine_evolution then
        tc:RegisterFlagEffect(Divine.DIVINE_EVOLUTION,
                              RESET_EVENT + RESETS_STANDARD,
                              EFFECT_FLAG_CLIENT_HINT, 1, 0, 666002)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToBattle() or c:IsFacedown() then return end
    Utility.GainInfinityAtk(c, RESET_PHASE + PHASE_DAMAGE_CAL)
end
