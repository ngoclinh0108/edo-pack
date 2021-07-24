-- Surtr, Bringer of the Nordic Ragnarok
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_XYZ)

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 3, nil, nil, nil, nil, false,
                     s.xyzcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE +
                            EFFECT_FLAG_SINGLE_RANGE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetRange(LOCATION_EXTRA)
    splimit:SetValue(aux.xyzlimit)
    c:RegisterEffect(splimit)
end

function s.xyzfilter(c, sc, sumtype, tp)
    return c:GetOriginalLevel() >= 8 and
               c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and
               c:IsSetCard(0x42, sc, sumtype, tp)
end

function s.xyzcheck(g, tp, sc)
    return g:CheckDifferentProperty(Card.GetCode, sc, SUMMON_TYPE_XYZ, tp)
end
