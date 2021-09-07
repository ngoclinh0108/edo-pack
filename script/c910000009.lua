-- Palladium Maiden Isis
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- to defense & extra summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1155)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1117)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e2:SetCountLimit(1, id + 100000)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- draw
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_RELEASE)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    if c:IsFaceup() and c:IsAttackPos() then
        Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
    end

    if Duel.GetFlagEffect(tp, id) == 0 then
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 0))
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        ec1:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
        ec1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x13a))
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local ch = Duel.GetCurrentChain(true) - 1
    if ch <= 0 then return false end
    local cp = Duel.GetChainInfo(ch, CHAININFO_TRIGGERING_CONTROLER)
    local ceff = Duel.GetChainInfo(ch, CHAININFO_TRIGGERING_EFFECT)
    if re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then
        return false
    end

    local cec = ceff:GetHandler()
    return ep == 1 - tp and cp == tp and cec:IsSetCard(0x13a) and
               cec:IsType(TYPE_MONSTER)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) Duel.NegateEffect(ev) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1000)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 1000)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)
end
