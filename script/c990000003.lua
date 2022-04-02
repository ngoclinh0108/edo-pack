-- Amber, Dracodeity of the Inferno
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 3,
                      nil, function(g, sc, sumtype, tp)
        return g:IsExists(Card.IsAttribute, 1, nil, ATTRIBUTE_FIRE, sc, sumtype,
                          tp)
    end)
end
