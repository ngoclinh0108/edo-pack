-- Red Archfiend Blader
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 2, 2, Synchro.NonTuner(nil), 1, 99)
end
