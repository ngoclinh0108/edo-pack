-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, true)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_WARRIOR)
    Divine.RegisterEffect(c, e1)

    -- destroy & damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(TIMING_SPSUMMON, TIMING_BATTLE_START)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)

    -- soul energy MAX
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
    Utility.AvatarInfinity(s, c)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return (c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK) or
               (not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE) and
                   not c:IsHasEffect(EFFECT_FORBIDDEN) and
                   not c:IsHasEffect(EFFECT_CANNOT_ATTACK))) and
               (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               (Duel.IsTurnPlayer(1 - tp) and Duel.IsBattlePhase())
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetAttackAnnouncedCount() == 0 and
                   Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if chk == 0 then return #g > 0 end

    local dmg = c:GetAttack()
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)

    Duel.Destroy(g, REASON_EFFECT)
    Duel.Damage(p, c:GetAttack(), REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE,
                                    LOCATION_MZONE, nil)
    local total_divine_hierarchy = 0
    for tc in aux.Next(g) do
        total_divine_hierarchy = total_divine_hierarchy +
                                     Divine.GetDivineHierarchy(tc)
    end

    return total_divine_hierarchy >= 3
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    ec1:SetOperation(function(e)
        Utility.GainInfinityAtk(e:GetHandler(), RESET_PHASE + PHASE_DAMAGE_CAL)
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(c, ec1)
end
