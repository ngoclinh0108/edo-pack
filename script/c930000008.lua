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
end

function s.xyzfilter(c, sc, sumtype, tp)
    return c:IsLevelAbove(8, sc, sumtype, tp) and
               c:IsSetCard(0x42, sc, sumtype, tp) and
               c:IsAttribute(ATTRIBUTE_DARK, sc, sumtype, tp)
end

function s.xyzcheck(g, tp, sc)
    return not g:IsExists(function(c)
        return not c:IsAttackAbove(0) or not c:IsDefenseAbove(0) or
                   not c:IsDefense(c:GetAttack())
    end, 1, nil)
end
