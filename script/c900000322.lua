-- Steam Warrior
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

s.material = {83295594}
s.material_setcode = {0x1017}
s.listed_names = {83295594}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSummonCode(sc, stype, tp, 83295594) or c:IsHasEffect(83295594)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)
end
