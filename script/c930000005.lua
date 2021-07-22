-- Loki, Aesir of Mischief
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0xa042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_LINK)

    -- link summon
    Link.AddProcedure(c, nil, 3, 3, function(g, lc, sumtype, tp)
        return g:IsExists(function(c, lc, sumtype, tp)
            return c:IsSetCard(0xa042, lc, sumtype, tp) and
                       c:IsType(TYPE_TUNER, lc, sumtype, tp)
        end, 1, nil, lc, sumtype, tp)
    end)
end
