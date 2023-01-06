-- Devotee of Obelisk
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10000000}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 3, 3, function(g, lc, sumtype, tp)
        return g:IsExists(Card.IsSummonType, 1, nil, SUMMON_TYPE_NORMAL)
    end)

    -- add divine beast
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(function(e)
        return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
    end)
    e1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
        end

        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    end)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e1filter), tp,
            LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end)
    c:RegisterEffect(e1)

    -- triple tribute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_TRIPLE_TRIBUTE)
    e2:SetValue(function(e, c)
        return c:IsAttribute(ATTRIBUTE_DIVINE)
    end)
    c:RegisterEffect(e2)

    -- additional tribute summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_HAND, 0)
    e3:SetCondition(function(e)
        return Duel.IsMainPhase()
    end)
    e3:SetTarget(function(e, c)
        return c:IsLevelAbove(10) and c:IsAttribute(ATTRIBUTE_DIVINE)
    end)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- effect gain
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_PRE_MATERIAL)
    e4:SetCondition(s.e4regcon)
    e4:SetOperation(s.e4regop)
    c:RegisterEffect(e4)
end

function s.e1filter(c)
    return (c:IsCode(10000000) or c:ListsCode(10000000)) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.e4regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(10000000)
end

function s.e4regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local eff = Effect.CreateEffect(c)
    eff:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    eff:SetCode(EVENT_SUMMON_SUCCESS)
    eff:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil):Filter(s.e4disfilter, nil)
        for tc in aux.Next(g) do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_DISABLE)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(ec2)

            if tc:IsType(TYPE_TRAPMONSTER) then
                local ec3 = ec1:Clone()
                ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                tc:RegisterEffect(ec3)
            end
        end
    end)
    eff:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(eff, true)
end

function s.e4disfilter(c)
    return (c:IsFaceup() or c:IsType(TYPE_TRAPMONSTER)) and
               not (c:IsType(TYPE_NORMAL) and c:GetOriginalType() & TYPE_NORMAL > 0)
end
