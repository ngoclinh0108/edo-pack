-- Obsidian, Dracodeity of the Void
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_DARK)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot to GY or banish
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
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
            ec1:SetCode(EFFECT_CANNOT_TO_GRAVE)
            ec1:SetRange(LOCATION_MZONE)
            ec1:SetLabelObject(re)
            ec1:SetTarget(function(e, c, tp, r, re)
                return re == e:GetLabelObject()
            end)
            ec1:SetReset(RESET_CHAIN)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_CANNOT_REMOVE)
            tc:RegisterEffect(ec2)
        end
    end)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT)
        and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = eg:Filter(s.e2filter, nil, 1 - tp)
    if #g == 0 then return end

    for tc in aux.Next(g) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
    end
end
