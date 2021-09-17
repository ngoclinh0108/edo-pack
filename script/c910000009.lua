-- Palladium Gardna Karim
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- negate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1116)
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_DAMAGE_STEP +
                       EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(575)
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_NO_TURN_RESET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- def low
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if c:IsStatus(STATUS_BATTLE_DESTROYED) or ep == tp or
        not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not tg then
        return false
    end

    return Duel.IsChainNegatable(ev) and tg:IsContains(c) or
               tg:IsExists(aux.FilterFaceupFunction(Card.IsSetCard, 0x13a), 1, c)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    Duel.NegateActivation(ev)
    Duel.ChangePosition(e:GetHandler(), POS_FACEUP_DEFENSE)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAttackPos() end
    Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(aux.disfilter3, tp, 0, LOCATION_ONFIELD, 1,
                                     nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, aux.disfilter3, tp, 0, LOCATION_ONFIELD, 1,
                                1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or c:IsFacedown() or tc:IsFacedown() or not c:IsRelateToEffect(e) or
        not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end

    c:SetCardTarget(tc)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetCondition(function(e)
        return e:GetOwner():IsHasCardTarget(e:GetHandler())
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    ec1b:SetValue(RESET_TURN_SET)
    tc:RegisterEffect(ec1b)
    if tc:IsType(TYPE_TRAPMONSTER) then
        local ec1c = ec1:Clone()
        ec1c:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        tc:RegisterEffect(ec1c)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToBattle() or Duel.GetAttackTarget() ~= c or
        not c:IsDefensePos() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_DEFENSE)
    ec1:SetValue(-800)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end
