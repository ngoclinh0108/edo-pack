-- Red Archfiend Dragon Calamity Emperor
Duel.LoadScript("util.lua")
local s, id = GetID()

s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 3, 3, Synchro.NonTunerEx(function(c, val, sc, sumtype, tp)
        return c:IsRace(RACE_DRAGON, sc, sumtype, tp) and c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp) and
                   c:IsType(TYPE_SYNCHRO, sc, sumtype, tp)
    end), 1, 1)
end
