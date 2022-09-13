-- Giant Divine Soldier of Obelisk
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Utility.AvatarInfinity(s, c)
    Divine.DivineHierarchy(s, c, 1, true, true)
end
