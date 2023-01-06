-- Palladium Devotee of Ra
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x13a}
s.listed_names = {CARD_RA}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x13a), 3, 3, function(g, lc, sumtype, tp)
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

    -- atk
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- cannot attack
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- effect gain
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_BE_PRE_MATERIAL)
    e6:SetCondition(s.e6regcon)
    e6:SetOperation(s.e6regop)
    c:RegisterEffect(e6)
end

function s.e1filter(c)
    return (c:IsCode(CARD_RA) or c:ListsCode(CARD_RA)) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetMaterial()

    local atk = 0
    for tc in aux.Next(g) do
        atk = atk + tc:GetBaseAttack()
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(atk)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e6regcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return r == REASON_SUMMON and rc:IsFaceup() and rc:IsCode(CARD_RA)
end

function s.e6regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local eff = Effect.CreateEffect(c)
    eff:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    eff:SetCode(EVENT_SUMMON_SUCCESS)
    eff:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()

        local ec0 = Effect.CreateEffect(c)
        ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
        ec0:SetDescription(aux.Stringid(id, 1))
        ec0:SetTargetRange(1, 0)
        ec0:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec0, tp)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_REVERSE_DAMAGE)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetTargetRange(1, 0)
        ec1:SetValue(function(e, re, r, rp, rc)
            return (r & REASON_EFFECT) ~= 0
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end)
    eff:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(eff, true)
end
