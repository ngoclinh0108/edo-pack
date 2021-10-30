-- The Wicked Eraser
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.DivineHierarchy(s, c, 1, true, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    Divine.RegisterEffect(c, splimit)

    -- cannot attack when special summoned from the grave
    local spnoattack = Effect.CreateEffect(c)
    spnoattack:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    spnoattack:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    spnoattack:SetCode(EVENT_SPSUMMON_SUCCESS)
    spnoattack:SetCondition(function(e)
        return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
    end)
    spnoattack:SetOperation(function(e)
        local c = e:GetHandler()
        if c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK) then return end

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        Divine.RegisterEffect(c, ec1)
    end)
    Divine.RegisterEffect(c, spnoattack)

    -- to grave
    local togy = Effect.CreateEffect(c)
    togy:SetDescription(666003)
    togy:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    togy:SetRange(LOCATION_MZONE)
    togy:SetCode(EVENT_PHASE + PHASE_END)
    togy:SetCountLimit(1)
    togy:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsSummonType(SUMMON_TYPE_SPECIAL) and
                   c:IsPreviousLocation(LOCATION_GRAVE) and
                   c:IsAbleToGrave()
    end)
    togy:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
    end)
    Divine.RegisterEffect(c, togy)

    -- atk/def
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(s.e1val)
    Divine.RegisterEffect(c, e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    Divine.RegisterEffect(c, e1b)

    -- suicide
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- to grave
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    Divine.RegisterEffect(c, e3)
end

function s.e1val(e, c)
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, 0, LOCATION_ONFIELD) * 1000 *
               Divine.GetDivineHierarchy(c)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDestructable() end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Destroy(e:GetHandler(), REASON_EFFECT)
end

function s.e3con(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ex = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, Card.IsFaceup,
                                          tp, LOCATION_MZONE, 0, 1, 1, nil)

    local ng = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, ex)
    for tc in aux.Next(ng) do
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec2 = ec1:Clone()
        ec2:SetCode(EFFECT_DISABLE_EFFECT)
        ec2:SetValue(RESET_TURN_SET)
        tc:RegisterEffect(ec2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local ec3 = ec1:Clone()
            ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            tc:RegisterEffect(ec3)
        end
        Duel.AdjustInstantly(tc)
    end

    local dg = Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD,
                                     LOCATION_ONFIELD, ex)
    Duel.SendtoGrave(dg, REASON_EFFECT)
end
