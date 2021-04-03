-- Elemental HERO Twilight Neos
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_neos.lua")

s.listed_names = {CARD_NEOS, 43237273, 17732278, 42015635}
s.material_setcode = {0x8, 0x3008, 0x9, 0x1f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion material
    Neos.AddProc(c, 43237273, 17732278, nil, true, false)

    -- indes & untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- disable & destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(function() return not Duel.IsEnvironment(42015635) end)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_QUICK_O)
    e3b:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3b:SetCode(EVENT_FREE_CHAIN)
    e3b:SetCondition(function() return Duel.IsEnvironment(42015635) end)
    c:RegisterEffect(e3b)

    -- neos return
    aux.EnableNeosReturn(c, CATEGORY_REMOVE, s.retinfo, s.retop)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler()
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(#eg * 500)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:GetFlagEffect(id) == 0 and
                   Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE,
                                               1, nil)
    end

    local ng = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    local dg = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, ng, #ng, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ng = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(ng) do
        Duel.NegateRelatedChain(tc, RESET_TURN_SET)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)

        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_DISABLE_EFFECT)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)

        if tc:IsType(TYPE_TRAPMONSTER) then
            local ec3 = Effect.CreateEffect(c)
            ec3:SetType(EFFECT_TYPE_SINGLE)
            ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec3)
        end
    end

    Duel.AdjustInstantly()
    local dg = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(dg, REASON_EFFECT)
end

function s.retinfo(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, 1, 1, c, tp)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_ONFIELD,
                                    LOCATION_ONFIELD, 1, 1, nil, tp)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
end
