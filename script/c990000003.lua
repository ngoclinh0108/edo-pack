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

    -- inflict damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdcon)
    e2:SetTarget(s.e2tg1)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetCode(EVENT_DESTROYED)
    e2b:SetCondition(s.e2con)
    e2b:SetTarget(s.e2tg2)
    c:RegisterEffect(e2b)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return (r & REASON_EFFECT) ~= 0 and re and re:GetOwner() == e:GetHandler()
end

function s.e2tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    local dmg = bc:GetBaseAttack()
    if chk == 0 then return dmg > 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local _, dmg = eg:Filter(Card.IsType, nil, TYPE_MONSTER):GetMaxGroup(Card.GetBaseAttack)
    if chk == 0 then return dmg and dmg > 0 end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
        CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ct = c:GetLinkedGroupCount()

    if chk == 0 then
        return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c) and
            ct > 0
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, ct,
        c)

    for tc in aux.Next(g) do Duel.SetChainLimit(s.e3limit(tc)) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e3limit(tc) return function(e, lp, tp) return e:GetHandler() ~= tc end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect, nil, e)
    Duel.Destroy(g, REASON_EFFECT)
end
