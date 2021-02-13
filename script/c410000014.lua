-- Palladium Spirit Kuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon when attack
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- double tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e2:SetValue(function(e, c) return c:IsSetCard(0x13a) end)
    c:RegisterEffect(e2)

    -- avoid battle damage
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- no damage
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttackTarget() == nil and
               Duel.GetAttacker():IsControler(1 - tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(ec2, tp)
end
