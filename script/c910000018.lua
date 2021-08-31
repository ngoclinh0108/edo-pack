-- Palladium Beast Chimera
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {910000016, 910000017}
s.material_setcode = {0x13a}
s.listed_names = {910000016, 910000017}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion Material
    Fusion.AddProcMix(c, false, false, 910000016, 910000017)

    -- gain effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e)
        return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = c:GetMaterial()
        for mc in aux.Next(g) do
            c:CopyEffect(mc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1)
        end
    end)
    c:RegisterEffect(e1)

    -- extra attack
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter(c, e, tp)
    return c:IsCode(910000016, 910000017) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil,
                                               e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    local g = Utility.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter),
                                         tp, LOCATION_HAND + LOCATION_DECK +
                                             LOCATION_GRAVE, 0, 1, 1, nil,
                                         HINTMSG_SPSUMMON, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP) end
end
