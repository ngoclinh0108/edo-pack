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
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- def low
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x13a) and c:IsType(TYPE_MONSTER)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if c:IsStatus(STATUS_BATTLE_DESTROYED) or ep == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not tg then
        return false
    end

    return Duel.IsChainNegatable(ev) and tg:IsContains(c) or tg:IsExists(s.e1filter, 1, c, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    Duel.NegateActivation(ev)
    Duel.ChangePosition(e:GetHandler(), POS_FACEUP_DEFENSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToBattle() or Duel.GetAttackTarget() ~= c or not c:IsDefensePos() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_DEFENSE)
    ec1:SetValue(-800)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end
