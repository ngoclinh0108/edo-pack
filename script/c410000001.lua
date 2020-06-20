-- Obelisk the Giant Divine Soldier
Duel.LoadScript("c400000000.lua")
local s, id = GetID()

s.divine_hierarchy = 1

function s.initial_effect(c)
    Divine.AddProcedure(c, RACE_WARRIOR + RACE_ROCK)

    -- negate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1117)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end

    local loc, tg = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION,
                                      CHAININFO_TARGET_CARDS)
    if not tg or not tg:IsContains(c) then return false end

    return Duel.IsChainDisablable(ev) and loc ~= LOCATION_DECK
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk) Duel.NegateEffect(ev) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetAttackAnnouncedCount() == 0 and
                   Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1,
                                           nil)
    end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if Duel.Destroy(g, REASON_EFFECT) == #g then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, c:GetAttack(), REASON_EFFECT)
    end
end
