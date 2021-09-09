-- The Palladium Oracles
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {71703785, 42006475}
s.material_setcode = {0x13a}
s.listed_names = {71703785, 42006475}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- fusion summon
    Fusion.AddProcMix(c, true, true, {71703785, 42006475},
                      aux.FilterBoolFunctionEx(Card.IsRace, RACE_SPELLCASTER))
    Fusion.AddContactProc(c, s.contactfilter, s.contactop, s.splimit, nil, nil,
                          nil, false)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c)
        return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(6)
    end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.splimit(e, se, sp, st)
    return (st & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION or
               e:GetHandler():GetLocation() ~= LOCATION_EXTRA
end

function s.contactfilter(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost, tp, LOCATION_MZONE,
                                 0, nil)
end

function s.contactop(g) Duel.SendtoGrave(g, REASON_COST + REASON_MATERIAL) end

function s.e3filter(c, e, tp, code)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToExtraAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil,
                                               e, tp, 71703785) and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil,
                                               e, tp, 42006475)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or
        Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return end

    local g1 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp, loc,
                                     0, nil, e, tp, 71703785)
    local g2 = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3filter), tp, loc,
                                     0, nil, e, tp, 42006475)
    if #g1 == 0 or #g2 == 0 then return end

    g1 = Utility.GroupSelect(g1, tp, 1, 1, nil)
    g2 = Utility.GroupSelect(g2, tp, 1, 1, nil)
    Duel.SpecialSummon(g1:Merge(g2), 0, tp, tp, true, false, POS_FACEUP)
end
