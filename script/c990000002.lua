-- Obsidian, Dracodeity of the Void
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_DARK)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc)
        if tc == e:GetHandler() then return true end
        return tc:GetControler() == e:GetHandlerPlayer() and
            tc:GetMutualLinkedGroupCount() > 0
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1b:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1b)
end
