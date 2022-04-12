-- Lapis, Dracodeity of the Abyss
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_WATER)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be returned
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

    g:AddCard(c)
    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_CANNOT_TO_HAND)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetLabelObject(re)
        ec1:SetTarget(function(e, c, tp, r, re)
            return re == e:GetLabelObject()
        end)
        ec1:SetReset(RESET_CHAIN)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_CANNOT_TO_DECK)
        tc:RegisterEffect(ec2)
    end
end