-- Palladium Chaos Dragon - Envoy of the Dawnbreak
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {410000022}

function s.initial_effect(c)
    Duel.AddCustomActivityCounter(id, ACTIVITY_CHAIN, aux.FALSE)
    c:EnableReviveLimit()

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- send cards to the graveyard
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               not c:IsType(TYPE_RITUAL) and c:IsLevelBelow(8) and
               c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and
               c:IsRace(RACE_DRAGON)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT + REASON_BATTLE) ~= 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e1filter), tp,
                                      LOCATION_HAND + LOCATION_DECK +
                                          LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e2filter1(c, p) return c:GetOwner() == p and c:IsAbleToGrave() end

function s.e2filter2(c, p)
    return c:IsControler(p) and c:IsLocation(LOCATION_GRAVE)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_CHAIN) == 0
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(aux.TRUE)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT +
                        EFFECT_FLAG_OATH)
    ec2:SetDescription(aux.Stringid(id, 0))
    ec2:SetTargetRange(1, 0)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetFieldGroup(tp, 0, 0xe)
    local dc = g:FilterCount(s.e2filter1, nil, 1 - tp)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, 1 - tp, dc * 300)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetFieldGroup(tp, 0, 0xe)
    Duel.SendtoGrave(g, REASON_EFFECT)

    local og = Duel.GetOperatedGroup()
    local ct = og:FilterCount(s.e2filter2, nil, 1 - tp)
    if ct > 0 then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, ct * 500, REASON_EFFECT)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetLabel(c:GetFieldID())
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, c) return e:GetLabel() ~= c:GetFieldID() end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
