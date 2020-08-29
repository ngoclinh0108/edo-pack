-- Palladium Knight - Jack
local s, id = GetID()

function s.initial_effect(c)
    -- code
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e1:SetValue(90876561)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY +
                       EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and
               c:IsFaceup()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1,
                                           nil) and
                   Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1,
                                         nil)
    end

    local ct =
        Duel.GetMatchingGroupCount(s.e2filter, tp, LOCATION_MZONE, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct,
                                nil)
    Duel.SetOperationInfo(0, HINTMSG_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_FUSION) ~= 0 end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
