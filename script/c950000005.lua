-- Supreme Dragonlord Z-ARC
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 4,
                      4, s.lnkcheck)

    -- pendulum
    Pendulum.AddProcedure(c, false)
end

function s.lnkcheck(g, sc, sumtype, tp)
    local mg =g:Clone()    
    if not g:IsExists(Card.IsType, 1, nil, TYPE_FUSION, sc, sumtype, tp) then return false end
    mg:Remove(Card.IsType, nil, TYPE_FUSION, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_SYNCHRO, sc, sumtype, tp) then return false end
    mg:Remove(Card.IsType, nil, TYPE_SYNCHRO, sc, sumtype, tp)
    if not g:IsExists(Card.IsType, 1, nil, TYPE_XYZ, sc, sumtype, tp) then return false end
    mg:Remove(Card.IsType, nil, TYPE_XYZ, sc, sumtype, tp)
    return mg:IsExists(Card.IsType, 1, nil, TYPE_PENDULUM, sc, sumtype, tp)
end
