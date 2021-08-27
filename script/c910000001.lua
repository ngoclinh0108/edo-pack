-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, true)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e1)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(TIMING_SUMMON, TIMING_BATTLE_START)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not tg or not tg:IsContains(c) then return false end
    return Duel.IsChainDisablable(ev)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
    Utility.HintCard(e:GetHandler():GetOriginalCode())
    Duel.NegateEffect(ev)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK) and
        (c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE) or
            c:IsHasEffect(EFFECT_FORBIDDEN) or
            c:IsHasEffect(EFFECT_CANNOT_ATTACK)) then return false end

    return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
               (Duel.IsTurnPlayer(1 - tp) and Duel.IsBattlePhase())
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetAttackAnnouncedCount() == 0 and
                   Duel.CheckReleaseGroupCost(tp, nil, 2, false, nil, c)
    end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, c)
    Duel.Release(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(g, REASON_EFFECT)
end
