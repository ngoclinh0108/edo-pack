-- Elemental HERO Celestial Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {42015635}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        54959865, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_WIND) and
                       tc:IsRace(RACE_WINGEDBEAST)
        end
    }, nil, true, true)
end
