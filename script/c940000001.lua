-- Number Z100: Genesis Numeron Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 100

function s.initial_effect(c)
    c:EnableReviveLimit()
end
