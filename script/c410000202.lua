-- Blue-Eyes Divinity Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}
s.listed_names = {CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Fusion.AddProcMixN(c, false, false, CARD_BLUEEYES_W_DRAGON, 1, s.fusfilter,
                       4)
end

function s.fusfilter(c) return c:IsSetCard(0xdd) and c:IsRace(RACE_DRAGON) end
