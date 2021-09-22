-- Wicked God Eraser
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
    c:RegisterEffect(splimit)

    -- race
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    Divine.RegisterEffect(c, e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_ADD_RACE)
    e1b:SetValue(RACE_FIEND)
    Divine.RegisterEffect(c, e1b)

    -- atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetValue(s.e2val)
    Divine.RegisterEffect(c, e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_BASE_DEFENSE)
    Divine.RegisterEffect(c, e2b)

    -- suicide
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- to grave
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DISABLE + CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2val(e, c)
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, 0, LOCATION_ONFIELD) * 1000 *
               Divine.GetDivineHierarchy(c)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDestructable() end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Destroy(e:GetHandler(), REASON_EFFECT)
end

function s.e4con(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
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
