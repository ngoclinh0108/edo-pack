-- Genesis Omega Dragon Z-ARC
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- pendulum
    Pendulum.AddProcedure(c)
end
