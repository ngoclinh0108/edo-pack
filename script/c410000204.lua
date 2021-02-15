-- Blue-Eyes Savior Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xdd}
s.listed_names = {CARD_BLUEEYES_W_DRAGON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, 8, 2, s.ovfilter, aux.Stringid(id, 0), 2)
end

function s.xyzfilter(c) return c:IsSetCard(0xdd) and c:IsRace(RACE_DRAGON) end

function s.ovfilter(c, tp, lc)
    return c:IsFaceup() and c:IsCode(CARD_BLUEEYES_W_DRAGON)
end
