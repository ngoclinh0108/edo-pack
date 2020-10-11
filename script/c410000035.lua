-- Palladium Oracle Hassan
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x13a}
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x13a), 1,
                         1, Synchro.NonTunerEx(Card.IsRace, RACE_SPELLCASTER),
                         1, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, c) return c:IsRace(RACE_SPELLCASTER) end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e4filter(c, e, tp)
    return not c:IsCode(id) and c:IsRace(RACE_SPELLCASTER) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and
               c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND +
                                                   LOCATION_DECK +
                                                   LOCATION_GRAVE, 0, 1, nil, e,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter), tp,
                                      LOCATION_HAND + LOCATION_DECK +
                                          LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
