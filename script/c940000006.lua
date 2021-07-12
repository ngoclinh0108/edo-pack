-- Astral Onomatopoeia
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series={0x54,0x59,0x82,0x8f}

function s.initial_effect(c)
    c:AddSetcodesRule(0x54,0x59,0x82,0x8f)
end
