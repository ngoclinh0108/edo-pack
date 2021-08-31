-- Palladium Knight of Jack
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(90876561)
    c:RegisterEffect(code)

    -- destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY +
                       EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- fusion summon
    local params = {nil, Fusion.OnFieldMat, nil, nil, Fusion.ForcedHandler}
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1170)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
    e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and
               c:IsRace(RACE_WARRIOR)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                           nil) and
                   Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_ONFIELD,
                                         1, nil)
    end

    local ct =
        Duel.GetMatchingGroupCount(s.e1filter, tp, LOCATION_MZONE, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1,
                                ct, nil)
    Duel.SetOperationInfo(0, HINTMSG_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local p = e:GetHandler()
    local rc = p:GetReasonCard()
    return
        (r & REASON_FUSION) ~= 0 and p:IsPreviousLocation(LOCATION_ONFIELD) and
            rc:IsAttribute(ATTRIBUTE_LIGHT) and rc:IsRace(RACE_WARRIOR)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(rc)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec1, true)

    if not rc:IsType(TYPE_EFFECT) then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_ADD_TYPE)
        ec2:SetValue(TYPE_EFFECT)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec2, true)
    end

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_SINGLE)
    ec3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    ec3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCountLimit(1)
    ec3:SetValue(function(e, re, r, rp)
        return (r & REASON_BATTLE + REASON_EFFECT) ~= 0
    end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec3, true)
end
