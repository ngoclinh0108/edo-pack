-- Illusory Palladium Oracle Mana
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.counter_place_list = {COUNTER_SPELL}

function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_SPELL)
    c:SetCounterLimit(COUNTER_SPELL, 1)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP +
                       EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con1)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetType(EFFECT_TYPE_QUICK_O)
    e1c:SetProperty(0)
    e1c:SetCode(EVENT_CHAINING)
    e1c:SetCondition(s.e1con2)
    c:RegisterEffect(e1c)

    -- add counter
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetCode(EVENT_CHAINING)
    e2reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and
            e:GetHandler():GetFlagEffect(1) > 0 then
            e:GetHandler():AddCounter(COUNTER_SPELL, 1)
        end
    end)
    c:RegisterEffect(e2)

    -- indes
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetCondition(function(e)
        return e:GetHandler():GetCounter(COUNTER_SPELL) >= 2
    end)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- atk/def up
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter1(c, tp)
    return c:IsFaceup() and c:IsCode(71703785) and c:IsSummonPlayer(tp) and
               c:IsLocation(LOCATION_MZONE)
end

function s.e1filter2(c, tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp)
end

function s.e1con1(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1filter1, 1, nil, tp)
end

function s.e1con2(e, tp, eg, ep, ev, re, r, rp)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not tg then return false end

    return tg:IsExists(s.e1filter2, 1, nil, tp)
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
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) ==
        0 then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttackTarget()
    if tc and tc:IsControler(1 - tp) then tc = Duel.GetAttacker() end
    if not tc then return false end

    e:SetLabelObject(tc)
    return tc ~= e:GetHandler() and tc:IsRelateToBattle() and c:IsFaceup() and
               c:GetAttack() > 0 and tc:IsRace(RACE_SPELLCASTER)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToBattle() then
        return
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(c:GetAttack())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(ec1b)
end
