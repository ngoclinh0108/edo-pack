-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Utility.AvatarInfinity(s, c)
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
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
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
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP)
    e3:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():CanAttack() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetAttackAnnouncedCount() == 0 and
                   Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return true end

    local dmg = c:GetAttack()
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsAttackPos() or not c:IsRelateToEffect(e) then return end

    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    Duel.Destroy(g, REASON_EFFECT)

    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Damage(p, c:GetAttack(), REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE,
                                    LOCATION_MZONE, nil)
    local total = 0
    for tc in aux.Next(g) do total = total + Divine.GetDivineHierarchy(tc) end
    return total >= 3
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
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                         aux.Stringid(id, 0))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    ec1:SetCountLimit(1)
    ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local bc = c:GetBattleTarget()
        return bc and bc:IsControler(1 - tp) and c:GetFlagEffect(id) ~= 0
    end)
    ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Utility.GainInfinityAtk(e:GetHandler(), RESET_PHASE + PHASE_DAMAGE_CAL)
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
