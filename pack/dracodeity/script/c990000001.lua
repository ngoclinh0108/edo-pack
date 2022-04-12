-- Greisen, Dracodeity of the Cosmogony
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_LIGHT)
    UtilityDracodeity.RegisterEffect(c, id)

    -- inactivatable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetValue(s.e1filter)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD)
    e1c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetCode(EFFECT_CANNOT_DISABLE)
    e1c:SetTargetRange(LOCATION_MZONE, 0)
    e1c:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1c:SetValue(1)
    c:RegisterEffect(e1c)
end

function s.e1filter(e, ct)
    local p = e:GetHandler():GetControler()
    local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,
        CHAININFO_TRIGGERING_PLAYER,
        CHAININFO_TRIGGERING_LOCATION)
    local tc = te:GetHandler()
    if tc == e:GetHandler() then return true end
    return p == tp and (loc & LOCATION_ONFIELD) ~= 0 and
        tc:GetMutualLinkedGroupCount() > 0
end
