-- Dark Sorcerer of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.counter_list = {COUNTER_SPELL}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(function(e, te)
        return te:GetHandler():GetOwner() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1)

    -- special summon (destroyed)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.spfilter(c)
    return c:IsFaceup() and c:GetCounter(COUNTER_SPELL) > 0 and
               c:IsCode(71703785)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)
    return g:IsExists(s.spfilter, 1, nil, tp, g, c)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)
    local mg = aux.SelectUnselectGroup(g, e, tp, 1, 1, nil, 1, tp,
                                       HINTMSG_XMATERIAL, nil, nil, true)
    if #mg == 1 then
        mg:KeepAlive()
        e:SetLabelObject(mg)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local mg = e:GetLabelObject()
    if not mg then return end
    local mc = mg:GetFirst()

    local ct = mc:GetCounter(COUNTER_SPELL)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    ec1:SetValue(ct * 1000)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE - RESET_TOFIELD)
    c:RegisterEffect(ec1)

    Duel.Overlay(c, mc)
    mg:DeleteGroup()
end

function s.e1filter(c, e, tp)
    return c:IsCode(71703785) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
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
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp,
                                         aux.NecroValleyFilter(s.e1filter), tp,
                                         LOCATION_HAND + LOCATION_DECK +
                                             LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
