-- Elemental HERO Colossal Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {42015635}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, {
        80344569, function(tc)
            return tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_EARTH) and
                       tc:IsRace(RACE_ROCK)
        end
    }, nil, true, true)
end
