-- Andalusite, Dracodeity of the Continent
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 3,
                      nil, function(g, sc, sumtype, tp)
        return g:IsExists(Card.IsAttribute, 1, nil, ATTRIBUTE_EARTH, sc,
                          sumtype, tp)
    end)
end
