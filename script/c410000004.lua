-- Obelisk the Giant Divine Soldier - Soul Energy MAX
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
Duel.LoadScript("proc_dimension.lua")
local s, id = GetID()

function s.initial_effect(c)
    Dimension.AddProcedure(c)
    Divine.SetHierarchy(s, 1)
    Divine.DivineImmunity(c, "egyptian")

    -- dimension change
    Dimension.RegisterEffect(c, function(e, tp)
        local dms = Effect.CreateEffect(c)
        dms:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        dms:SetCode(EVENT_FREE_CHAIN)
        dms:SetCondition(s.dmscon)
        dms:SetOperation(s.dmsop)
        Duel.RegisterEffect(dms, tp)
    end)

    -- return to original at end battle
    local rb = Effect.CreateEffect(c)
    rb:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    rb:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    rb:SetCode(EVENT_PHASE + PHASE_BATTLE)
    rb:SetRange(LOCATION_MZONE)
    rb:SetOperation(s.rbop)
    c:RegisterEffect(rb)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(RACE_WARRIOR + RACE_ROCK)
    c:RegisterEffect(e1)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- infinite atk
    Utility.GainInfinityAtk(s, c)
end

function s.dmsfilter(c)
    return
        Duel.CheckReleaseGroupCost(c:GetControler(), nil, 2, false, nil, c) and
            c:IsCode(10000000) and c:GetOriginalCode() ~= id and
            c:GetAttackAnnouncedCount() == 0

end

function s.dmscon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.IsExistingMatchingCard(s.dmsfilter, tp, LOCATION_MZONE, 0, 1, c) then
        return false
    end

    local ph = Duel.GetCurrentPhase()
    return ph >= PHASE_BATTLE_START and ph <= PHASE_BATTLE and
               (ph ~= PHASE_DAMAGE or not Duel.IsDamageCalculated())
end

function s.dmsop(e, tp, eg, ep, ev, re, r, rp)
    Duel.BreakEffect()
    local c = e:GetHandler()

    local mc
    local mg = Duel.GetMatchingGroup(s.dmsfilter, tp, LOCATION_MZONE, 0, 1, c)
    if #mg <= 0 then
        return
    elseif #mg == 1 then
        mc = mg:GetFirst()
    else
        mc = mg:Select(c:GetOwner(), 1, 1):GetFirst()
    end
    if not mc then return end

    local g = Duel.SelectReleaseGroupCost(tp, nil, 2, 2, false, nil, mc)
    Duel.Release(g, REASON_COST)

    Dimension.Change(c, mc, mc:GetControler(), mc:GetControler(),
                     mc:GetPosition())
end

function s.rbop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetMaterial():GetFirst()

    Dimension.Change(tc, c, c:GetControler(), c:GetControler(), c:GetPosition())
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not tg or not tg:IsContains(c) then return false end

    return Duel.IsChainDisablable(ev)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk) Duel.NegateEffect(ev) end
