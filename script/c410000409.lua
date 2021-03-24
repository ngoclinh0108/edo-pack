-- Elemental HERO Void Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {42015635}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        43237273, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_DARK) and
                       tc:IsRace(RACE_BEAST)
        end
    }, nil, true, true)
end
