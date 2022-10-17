-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Utility.AvatarInfinity(s, c)
    Divine.DivineHierarchy(s, c, 1, false)

    -- destroy & damage
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- soul energy MAX
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_DAMAGE_STEP)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():CanAttack() and Duel.GetCurrentChain(true) == 0
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetAttackAnnouncedCount() == 0 and Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
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

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return true
    end

    local dmg = c:GetAttack()
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end

    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    Duel.Destroy(g, REASON_EFFECT)

    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Damage(p, c:GetAttack(), REASON_EFFECT)
end

function s.e2filter(c)
    return c:IsFaceup() and Divine.GetDivineHierarchy(c) >= 2
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(function(tc)
        return tc:IsFaceup() and Divine.GetDivineHierarchy(tc) >= 2
    end, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
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
