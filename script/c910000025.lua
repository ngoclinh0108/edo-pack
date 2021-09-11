-- Chaos End Ruler - Ruler of the Beginning and the End
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0xcf}
s.listed_series = {0xcf}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    local fus = Fusion.AddProcMix(c, false, false, function(c, fc, sumtype, tp)
        return s.fusfilter(c, fc, sumtype, tp, ATTRIBUTE_LIGHT, RACE_WARRIOR)
    end, function(c, fc, sumtype, tp)
        return s.fusfilter(c, fc, sumtype, tp, ATTRIBUTE_DARK, RACE_DRAGON)
    end)
    if not c:IsStatus(STATUS_COPYING_EFFECT) then
        fus[1]:SetValue(function(c, fc, sub, sub2, mg, sg, tp, contact, sumtype)
            if sumtype & SUMMON_TYPE_FUSION ~= 0 and
                fc:IsLocation(LOCATION_EXTRA) and not contact then
                return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
            end
            return true
        end)
    end

    -- attribute
    local attribute = Effect.CreateEffect(c)
    attribute:SetType(EFFECT_TYPE_SINGLE)
    attribute:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    attribute:SetCode(EFFECT_ADD_ATTRIBUTE)
    attribute:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(attribute)
    local race = Effect.CreateEffect(c)
    race:SetType(EFFECT_TYPE_SINGLE)
    race:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    race:SetCode(EFFECT_ADD_RACE)
    race:SetValue(RACE_DRAGON)
    c:RegisterEffect(race)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or
                   aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- activation and effects cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(e1b)
    local e1c = e1b:Clone()
    e1c:SetCode(EFFECT_CANNOT_INACTIVATE)
    c:RegisterEffect(e1c)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_RELEASE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0, 1)
    e2:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2b:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e2b)
    local e2c = Effect.CreateEffect(c)
    e2c:SetType(EFFECT_TYPE_SINGLE)
    e2c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2c:SetRange(LOCATION_MZONE)
    e2c:SetValue(aux.tgoval)
    c:RegisterEffect(e2c)
    local e2d = e2c:Clone()
    e2d:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2d:SetValue(function(e, re, tp) return tp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e2d)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(function(e, c)
        return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_REMOVED,
                                       LOCATION_REMOVED) * 200
    end)
    c:RegisterEffect(e3)

    -- battle banish
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
    e4:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e4)

    -- banish & damage
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetCategory(CATEGORY_REMOVE + CATEGORY_DAMAGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.fusfilter(c, fc, sumtype, tp, attr, race)
    return (c:IsSetCard(0xcf, fc, sumtype, tp) or
               c:IsSetCard(0x1048, fc, sumtype, tp)) and
               c:IsAttribute(attr, fc, sumtype, tp) and
               c:IsRace(race, fc, sumtype, tp)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_ONFIELD
    local g = Duel.GetFieldGroup(tp, 0, loc)
    if chk == 0 then return #g > 0 end

    local dc = g:FilterCount(Card.IsAbleToRemove, nil, 1 - tp)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, 0, 0, 1 - tp, dc * 300)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND + LOCATION_ONFIELD)
    Duel.Remove(g, POS_FACEDOWN, REASON_EFFECT)

    local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil,
                                                   LOCATION_REMOVED)
    if ct > 0 then
        Duel.BreakEffect()
        Duel.Damage(1 - tp, ct * 300, REASON_EFFECT)
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT +
                        EFFECT_FLAG_OATH)
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
