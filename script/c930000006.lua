-- Laufey the Nordic Giant
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_LINK)

    -- link summon
    Link.AddProcedure(c, function(c, lc, sumtype, tp)
        return c:IsSetCard(0x42, lc, sumtype, tp)
    end, 4, 4, nil)
end
