-- Palladium Sacred Guardian
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, 7, 3)
end

function s.xyzfilter(c, sc, SUMMON_TYPE_XYZ, tp)
    return Duel.GetFlagEffect(c:GetControler(), id) == 0 and
               c:IsSetCard(0x13a, sc, SUMMON_TYPE_XYZ, tp)
end
