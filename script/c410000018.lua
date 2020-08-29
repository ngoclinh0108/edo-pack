-- Palladium Paladin - Ace Joker
local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- fusion Material
    Fusion.AddProcMix(c, false, false, 25652259, 90876561, 64788463)
end
