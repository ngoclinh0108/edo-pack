-- Sacred Palladium Oracle Mahad
Duel.LoadScript("util.lua")
local s, id = GetID()

s.counter_place_list = {COUNTER_SPELL}

function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_SPELL)
    c:SetCounterLimit(COUNTER_SPELL, 5)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- add counter
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_CHAINING)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(1) > 0 then
            e:GetHandler():AddCounter(COUNTER_SPELL, 1)
        end
    end)
    c:RegisterEffect(e2)

    -- immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e)
        return e:GetHandler():GetCounter(COUNTER_SPELL) > 0
    end)
    e3:SetValue(function(e, te)
        return te:GetHandler():GetOwner() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e3)

    -- atk up
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_SET_ATTACK_FINAL)
    e4:SetCondition(s.e4con)
    e4:SetValue(s.e4val)
    c:RegisterEffect(e4)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    local bc = e:GetHandler():GetBattleTarget()
    return (ph == PHASE_DAMAGE or ph == PHASE_DAMAGE_CAL) and bc and bc:IsAttribute(ATTRIBUTE_DARK)
end

function s.e4val(e, c)
    return e:GetHandler():GetAttack() * 2
end
