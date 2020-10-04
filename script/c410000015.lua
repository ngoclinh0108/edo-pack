-- Palladium Knight of Jack
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
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
    e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1b)
    local e1c = e1:Clone()
    e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1c)

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and
               c:IsFaceup()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1,
                                           nil) and
                   Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1,
                                         nil)
    end

    local ct =
        Duel.GetMatchingGroupCount(s.e1filter, tp, LOCATION_MZONE, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct,
                                nil)
    Duel.SetOperationInfo(0, HINTMSG_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_FUSION) ~= 0 end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetReasonCard()

    local ec0 = Effect.CreateEffect(tc)
    ec0:SetDescription(aux.Stringid(id, 0))
    ec0:SetType(EFFECT_TYPE_SINGLE)
    ec0:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec0, true)

    if not tc:IsType(TYPE_EFFECT) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_ADD_TYPE)
        ec1:SetValue(TYPE_EFFECT)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1, true)
    end

    local ec2 = Effect.CreateEffect(tc)
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    ec2:SetValue(1)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec2, true)
    local ec2b = ec2:Clone()
    ec2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    tc:RegisterEffect(ec2b, true)
end
