-- Hela, Ruler of the Nordic Underworld
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0x42}
s.material_setcode = {0x42}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.NordicGodEffect(c, SUMMON_TYPE_FUSION)

    -- fusion material
    Fusion.AddProcMixN(c, true, true, s.fusfilter, 3)
end

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
    return (not sg or
               not sg:IsExists(Card.IsRace, 1, c, c:GetRace(), fc, sumtype, tp)) and
               c:IsSetCard(0x42, fc, sumtype, tp)
end
