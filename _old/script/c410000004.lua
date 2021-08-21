function s.initial_effect(c)
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
