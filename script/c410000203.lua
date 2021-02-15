-- Blue-Eyes Savior Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, s.synfilter1, 1, 1,
                         Synchro.NonTunerEx(s.synfilter2), 1, 1)
end

function s.synfilter1(c) return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) end

function s.synfilter2(c) return c:IsSetCard(0xdd) and c:IsRace(RACE_DRAGON) end
