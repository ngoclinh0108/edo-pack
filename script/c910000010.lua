-- Palladium Maiden Isis
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- double tribute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e1:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1117)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND + LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
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
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp) Duel.NegateEffect(ev) end

function s.e3filter(c) return c:IsSetCard(0x13a) and c:IsSummonable(true, nil) end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
    end

    Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp,
                                           LOCATION_HAND + LOCATION_MZONE, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc = Utility.SelectMatchingCard(HINTMSG_SUMMON, tp, s.e3filter, tp,
                                          LOCATION_HAND + LOCATION_MZONE, 0, 1,
                                          1, nil):GetFirst()
    if tc then Duel.Summon(tp, tc, true, nil) end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c) return not c:IsSetCard(0x13a) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
