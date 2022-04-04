-- Obsidian, Dracodeity of the Void
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_DARK)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot leave
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if rp == tp then return end
    local g = Duel.GetMatchingGroup(function(tc)
        return tc:GetMutualLinkedGroupCount() > 0
    end, tp, LOCATION_MZONE, 0, nil)
    if #g == 0 then return end

    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_TO_HAND)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetTargetRange(0, 1)
        ec1:SetReset(RESET_CHAIN)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_CANNOT_TO_DECK)
        tc:RegisterEffect(ec2)
        local ec3 = ec1:Clone()
        ec3:SetCode(EFFECT_CANNOT_TO_GRAVE)
        tc:RegisterEffect(ec3)
        local ec4 = ec1:Clone()
        ec4:SetCode(EFFECT_CANNOT_REMOVE)
        tc:RegisterEffect(ec4)
    end
end
