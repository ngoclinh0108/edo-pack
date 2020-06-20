-- Ra the Sun Divine Phoenix
Duel.LoadScript("c400000000.lua")
local s, id = GetID()

s.divine_hierarchy = 2

function s.initial_effect(c)
    Divine.AddProcedure(c, RACE_WINGEDBEAST + RACE_PYRO)
end
