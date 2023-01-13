-- Chaos End Ruler - Ruler of the Beginning and the End
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xcf}
s.listed_series = {0xcf}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0xcf), 8, 2)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st & SUMMON_TYPE_XYZ) == SUMMON_TYPE_XYZ and not se)
    end)
    c:RegisterEffect(splimit)

    -- activation and effects cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1b:SetTargetRange(1, 0)
    e1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e1c)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_RELEASE)
    e2:SetTargetRange(0, 1)
    e2:SetCondition(s.con1)
    e2:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2b:SetCondition(s.con1)
    e2b:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e2b)
    local e2c = Effect.CreateEffect(c)
    e2c:SetType(EFFECT_TYPE_SINGLE)
    e2c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2c:SetRange(LOCATION_MZONE)
    e2c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2c:SetCondition(s.con1)
    e2c:SetValue(aux.tgoval)
    c:RegisterEffect(e2c)
    local e2d = e2c:Clone()
    e2d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2d:SetValue(1)
    c:RegisterEffect(e2d)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.con1)
    e3:SetValue(function(e, c) return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_GRAVE, LOCATION_GRAVE) * 100 end)
    c:RegisterEffect(e3)

    -- disable
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_DISABLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0, LOCATION_MZONE)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return s.con1(e, tp, eg, ep, ev, re, r, rp) and Duel.GetAttacker() == c and c:GetBattleTarget() and
                   (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL)
    end)
    e4:SetTarget(function(e, c) return c == e:GetHandler():GetBattleTarget() end)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e4b)

    -- send card to gy & damage
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DAMAGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id)
    e5:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and s.con2(e, tp, eg, ep, ev, re, r, rp)
    end)
    e5:SetCost(s.e5cost)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    c:RegisterEffect(e5, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.con1(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
    end, 1, nil)
end

function s.con2(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(
        function(c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) end, 1, nil)
end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_ONFIELD
    local g = Duel.GetFieldGroup(tp, 0, loc)
    if chk == 0 then return #g > 0 end

    local dc = g:FilterCount(Card.IsAbleToGrave, nil, 1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, 1 - tp, dc * 500)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND + LOCATION_ONFIELD)
    Duel.SendtoGrave(g, REASON_EFFECT)

    local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil, LOCATION_GRAVE)
    if ct > 0 then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, ct * 500, REASON_EFFECT)
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT + EFFECT_FLAG_OATH)
    ec0:SetDescription(aux.Stringid(id, 1))
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
