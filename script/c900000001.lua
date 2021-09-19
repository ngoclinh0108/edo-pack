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

    -- attack directly & destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e2:SetHintTiming(0, TIMING_MAIN_END + TIMING_BATTLE_START)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.effcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)

    -- soul energy MAX
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_BATTLE_START)
    e3:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.effcost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
    Utility.AvatarInfinity(s, c)
end

function s.effcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetAttackAnnouncedCount() == 0 and
                   Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.effblockatk(e, tc)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH +
                        EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsAttackPos() or not c:CanAttack() then return false end
    return (Duel.IsMainPhase() or Duel.IsBattlePhase())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return true end

    local dmg = c:GetAttack()
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)

    local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsAttackPos() or not c:IsRelateToEffect(e) then return end

    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    if Duel.Damage(p, c:GetAttack(), REASON_EFFECT) ~=0 then
        local g = Duel.GetFieldGroup(tp, 0, LOCATION_MZONE)
        Duel.Destroy(g, REASON_EFFECT)
    end
end

function s.e3filter(c, sc) return c:IsFaceup() and c:IsCanBeBattleTarget(sc) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsAttackPos() or not c:CanAttack() then return false end

    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE,
                                    LOCATION_MZONE, nil)
    local total = 0
    for tc in aux.Next(g) do total = total + Divine.GetDivineHierarchy(tc) end
    return Duel.IsBattlePhase() and total >= 3
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, 0, LOCATION_MZONE, 1,
                                           nil, e:GetHandler())
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc
    if c:IsAttackPos() and c:IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACKTARGET)
        tc = Duel.SelectMatchingCard(tp, s.e3filter, tp, 0, LOCATION_MZONE, 1,
                                     1, nil, c):GetFirst()
    end
    if not tc then
        s.effblockatk(e, c)
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    ec1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    ec1:SetCountLimit(1)
    ec1:SetOperation(function(e)
        local c = e:GetHandler()
        Utility.GainInfinityAtk(c, RESET_PHASE + PHASE_DAMAGE_CAL)
        s.effblockatk(e, c)
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    Divine.RegisterEffect(c, ec1)
    Duel.ForceAttack(c, tc)
end
