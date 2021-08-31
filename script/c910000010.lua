-- Palladium Guardian Shada
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- special summon & draw
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- battle indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetValue(function(e, re, r, rp) return (r & REASON_BATTLE) ~= 0 end)
    c:RegisterEffect(e2)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_START)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    if ph ~= PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end

    local tc = Duel.GetAttacker()
    if tc:IsControler(1 - tp) then tc = Duel.GetAttackTarget() end
    return tc and tc:IsSetCard(0x13a) and tc:IsRelateToBattle() and
               Duel.GetAttackTarget() ~= nil
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) ==
        0 then return end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local bc = Duel.GetAttackTarget()
    if chk == 0 then
        return Duel.GetAttacker() == c and bc and
                   bc:IsPosition(POS_FACEDOWN_DEFENSE)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, bc, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local bc = Duel.GetAttackTarget()
    if not bc:IsRelateToBattle() or not bc:IsPosition(POS_FACEDOWN_DEFENSE) then
        return
    end

    Duel.Destroy(bc, REASON_EFFECT)
end
