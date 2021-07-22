-- Sif, Lady of the Aesir
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.AesirGodEffect(c)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, scard, sumtype, tp)
        return c:IsSetCard(0x42, scard, sumtype, tp)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)
end
