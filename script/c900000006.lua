-- The Wicked Dreadroot
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    Divine.RegisterEffect(c, splimit)

    -- cannot attack when special summoned from the grave
    local spnoattack = Effect.CreateEffect(c)
    spnoattack:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    spnoattack:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    spnoattack:SetCode(EVENT_SPSUMMON_SUCCESS)
    spnoattack:SetCondition(function(e)
        return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
    end)
    spnoattack:SetOperation(function(e)
        local c = e:GetHandler()
        if c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK) then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(c, ec1)
    end)
    Divine.RegisterEffect(c, spnoattack)

    -- to grave
    local togy = Effect.CreateEffect(c)
    togy:SetDescription(666003)
    togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    togy:SetRange(LOCATION_MZONE)
    togy:SetCode(EVENT_PHASE + PHASE_END)
    togy:SetCountLimit(1)
    togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                   c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()
    end)
    togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
    end)
    Divine.RegisterEffect(c, togy)

    -- half atk
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(function(e, tc)
        local c = e:GetHandler()
        return tc ~= c and Divine.GetDivineHierarchy(tc) <=
                   Divine.GetDivineHierarchy(c)
    end)
    e1:SetValue(function(e, c) return math.ceil(c:GetAttack() / 2) end)
    Divine.RegisterEffect(c, e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e1b:SetValue(function(e, c) return math.ceil(c:GetDefense() / 2) end)
    Divine.RegisterEffect(c, e1b)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLED)
    e2:SetOperation(s.e2op)
    Divine.RegisterEffect(c, e2)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if not bc or not bc:IsType(TYPE_EFFECT) or
        not bc:IsStatus(STATUS_BATTLE_DESTROYED) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
    bc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    bc:RegisterEffect(ec1b)
end
