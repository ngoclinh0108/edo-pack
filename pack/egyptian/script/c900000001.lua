-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Utility.AvatarInfinity(s, c)
    Divine.DivineHierarchy(s, c, 1, true, true)

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
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():CanAttack()
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
