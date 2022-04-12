-- Amber, Dracodeity of the Inferno
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_FIRE)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be returned
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
    end)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- inflict damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdcon)
    e3:SetTarget(s.e3tg1)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetCode(EVENT_DESTROYED)
    e3b:SetCondition(s.e3con)
    e3b:SetTarget(s.e3tg2)
    c:RegisterEffect(e3b)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ct = c:GetLinkedGroupCount()

    if chk == 0 then
        return ct > 0 and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, ct, 0, LOCATION_ONFIELD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = c:GetLinkedGroupCount()
    if ct <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, ct, c)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e3filter(c, tp)
    return c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler()
end

function s.e3tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    local dmg = bc:GetBaseAttack()
    if chk == 0 then return bc:IsControler(1 - tp) and dmg > 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e3tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local _, dmg = eg:Filter(s.e3filter, nil, 1 - tp):GetMaxGroup(Card.GetBaseAttack)
    if chk == 0 then return dmg and dmg > 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
        CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
