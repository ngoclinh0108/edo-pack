-- The Wicked Deity Dreadroot
Duel.LoadScript("util.lua")
Duel.LoadScript("util_egyptian.lua")
local s, id = GetID()

function s.initial_effect(c)
    Utility.AvatarInfinity(s, c)
    Divine.DivineHierarchy(s, c, 1)

    -- cannot special summon
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)
end
