-- Loki, Aesir of Mischief
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0xa042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_LINK, true)

    -- link summon
    Link.AddProcedure(c, s.lnkfilter1, 3, 3, s.lnkcheck)
end

function s.lnkfilter1(c) return c:HasLevel() end

function s.lnkfilter2(c, lc, sumtype, tp)
    return c:IsSetCard(0xa042, lc, sumtype, tp) and
               c:IsType(TYPE_TUNER, lc, sumtype, tp)
end

function s.lnkcheck(g, lc, sumtype, tp)
    local mg = g:Filter(s.lnkfilter1, nil, lc, sumtype, tp)
    return mg:CheckWithSumEqual(Card.GetLevel, 10, 3, 3) and
               mg:IsExists(s.lnkfilter2, 1, nil, lc, sumtype, tp)
end
