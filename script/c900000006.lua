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

    -- return
    local spreturn = Effect.CreateEffect(c)
    spreturn:SetDescription(0)
    spreturn:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    spreturn:SetRange(LOCATION_MZONE)
    spreturn:SetCode(EVENT_PHASE + PHASE_END)
    spreturn:SetCountLimit(1)
    spreturn:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsSummonType(SUMMON_TYPE_SPECIAL) then return false end
        return (c:IsPreviousLocation(LOCATION_HAND) and c:IsAbleToHand()) or
                   (c:IsPreviousLocation(LOCATION_DECK + LOCATION_EXTRA) and
                       c:IsAbleToDeck()) or
                   (c:IsPreviousLocation(LOCATION_GRAVE) and c:IsAbleToGrave()) or
                   (c:IsPreviousLocation(LOCATION_REMOVED) and
                       c:IsAbleToRemove())
    end)
    spreturn:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsPreviousLocation(LOCATION_HAND) then
            Duel.SendtoHand(c, nil, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_DECK) then
            Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_GRAVE) then
            Duel.SendtoGrave(c, REASON_EFFECT)
        elseif c:IsPreviousLocation(LOCATION_REMOVED) then
            Duel.Remove(c, c:GetPreviousPosition(), REASON_EFFECT)
        end
    end)
    Divine.RegisterEffect(c, spreturn)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    Divine.RegisterEffect(c, e1)

    -- half atk
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_SET_ATTACK_FINAL)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e2:SetTarget(function(e, c) return c ~= e:GetHandler() end)
    e2:SetValue(function(e, c) return math.ceil(c:GetAttack() / 2) end)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e2b:SetValue(function(e, c) return math.ceil(c:GetDefense() / 2) end)
    Divine.RegisterEffect(c, e2b)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BATTLED)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
