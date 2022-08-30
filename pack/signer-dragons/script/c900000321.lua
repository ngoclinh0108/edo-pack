-- Quick-Span Warrior
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {11287364}
s.material_setcode = {0x1017}
s.listed_names = {11287364}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSummonCode(sc, stype, tp, 11287364) or c:IsHasEffect(20932152) or c:IsSetCard(0x1017)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)
end
