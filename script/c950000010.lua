-- Sky Iris Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x98}
s.material_setcode = 0x98

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x98, sc, sumtype, tp) and
                   c:IsType(TYPE_PENDULUM, sc, sumtype, tp)
    end, function(c)
        return c:IsSummonLocation(LOCATION_EXTRA) and
                   c:IsLocation(LOCATION_MZONE)
    end)

    -- pendulum
    Pendulum.AddProcedure(c, false)
end
