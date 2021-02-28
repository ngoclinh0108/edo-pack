-- Chaos End Ruler - Envoy of Palladium
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, 8, 2, nil, nil, 2, nil)

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(function(e, c)
        return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_REMOVED,
                                       LOCATION_REMOVED) * 100
    end)
    c:RegisterEffect(e1)

    -- battle banish
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
    e2:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e2)

    -- immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetLabel(ATTRIBUTE_LIGHT)
    e3:SetCondition(s.effcon)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3b:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e3b)

    -- disable
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_DISABLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0, LOCATION_MZONE)
    e4:SetLabel(ATTRIBUTE_LIGHT)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e4b)

    -- banish & damage
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_REMOVE + CATEGORY_DAMAGE)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    c:RegisterEffect(e5, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.xyzfilter(c)
    return c:IsSetCard(0x13a) and c:IsType(TYPE_RITUAL) and
               c:IsType(TYPE_PENDULUM)
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(
               function(c) return c:IsAttribute(e:GetLabel()) end, 1, nil)
end

function s.e4con(e)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c and c:GetBattleTarget() and
               (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() ==
                   PHASE_DAMAGE_CAL) and s.effcon(e)
end

function s.e4tg(e, c) return c == e:GetHandler():GetBattleTarget() end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST)
    end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local loc = LOCATION_HAND + LOCATION_ONFIELD
    local g = Duel.GetFieldGroup(tp, 0, loc)
    local dc = g:FilterCount(Card.IsAbleToRemove, nil, 1 - tp)

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, 1 - tp, dc * 500)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local loc = LOCATION_HAND + LOCATION_ONFIELD
    local g = Duel.GetFieldGroup(tp, 0, loc)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)

    local og = Duel.GetOperatedGroup()
    local ct = og:FilterCount(Card.IsLocation, nil, LOCATION_REMOVED)
    if ct > 0 then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, ct * 500, REASON_EFFECT)
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT +
                        EFFECT_FLAG_OATH)
    ec0:SetDescription(aux.Stringid(id, 0))
    ec0:SetTargetRange(1, 0)
    ec0:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec0, tp)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, c) return e:GetLabel() ~= c:GetFieldID() end)
    ec1:SetLabel(c:GetFieldID())
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
