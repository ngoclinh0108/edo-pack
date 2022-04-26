-- Amber, Dracodeity of the Inferno
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dracodeity.lua")
local s, id = GetID()

function s.initial_effect(c)
    UtilityDracodeity.RegisterSummon(c, ATTRIBUTE_FIRE)
    UtilityDracodeity.RegisterEffect(c, id)

    -- cannot be tributed, or be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc)
        if tc == e:GetHandler() then return true end
        return tc:GetControler() == e:GetHandlerPlayer() and
            tc:GetMutualLinkedGroupCount() > 0
    end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetTargetRange(LOCATION_MZONE, 0)
    e1b:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1b:SetValue(function(e, tc)
        return tc and tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e1b)

    -- negate & destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- destroy & damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_CONFIRM)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- gain atk
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct = c:GetMutualLinkedGroupCount()
    if chk == 0 then
        return ct > 0 and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, nil, ct, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, ct, 0, LOCATION_ONFIELD)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ct = c:GetMutualLinkedGroupCount()
    if ct <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, ct, c)
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

    Duel.BreakEffect()
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    return Duel.GetAttacker() == c and tc and tc:IsRelateToBattle()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    local dmg = tc:GetBaseAttack() > tc:GetBaseDefense() and tc:GetBaseAttack() or tc:GetBaseDefense()

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)

    if c:IsRelateToBattle() and tc:IsRelateToBattle() and Duel.Destroy(tc, REASON_EFFECT) > 0 then
        local dmg = tc:GetBaseAttack() > tc:GetBaseDefense() and tc:GetBaseAttack() or tc:GetBaseDefense()
        if dmg > 0 then Duel.Damage(p, dmg, REASON_EFFECT) end
    end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler() and eg:IsExists(Card.IsType, 1, nil, TYPE_MONSTER)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local atk = 0
    local g = eg:Filter(Card.IsType, nil, TYPE_MONSTER)
    for tc in aux.Next(g) do
        if tc:GetTextAttack() > 0 then
            atk = atk + tc:GetTextAttack()
        end
    end

    if atk > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end
