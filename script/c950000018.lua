-- Supreme King Dragon Goldwurm
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)
end
