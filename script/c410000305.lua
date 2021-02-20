-- Red-Eyes Armored Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x3b}
s.listed_series = {0x3b}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, s.lnkfilter, 2, 2, s.lnkcheck)
end

function s.lnkfilter(c) return c:IsAttribute(ATTRIBUTE_DARK) end

function s.lnkcheck(g, lnkc)
    return g:IsExists(function(c)
        return c:IsLevelAbove(5) and c:IsSetCard(0x3b)
    end, 1, nil)
end
