-- Number C39: Utopia Beyond the Shining
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 39
s.listed_names = {21521304}
s.listed_series = {0x95, 0x107e, 0x107f, 0x48}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se)
        local loc = e:GetHandler():GetLocation()
        if loc ~= LOCATION_EXTRA then return true end
        return se:GetHandler():IsSetCard(0x95) and
                   se:GetHandler():IsType(TYPE_SPELL)
    end)
    c:RegisterEffect(splimit)

    -- disable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e1b)

    -- equip
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, 0)
    e3:SetCondition(s.effcon)
    e3:SetTarget(s.e3tg)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)

    -- double atk
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.effcon)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4, false, REGISTER_FLAG_DETACH_XMAT)
end

s.rum_limit = function(c, e) return c:IsCode(21521304) end
s.rum_xyzsummon = function(c)
    local xyz = Effect.CreateEffect(c)
    xyz:SetDescription(1073)
    xyz:SetType(EFFECT_TYPE_FIELD)
    xyz:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    xyz:SetCode(EFFECT_SPSUMMON_PROC)
    xyz:SetRange(c:GetLocation())
    xyz:SetCondition(Xyz.Condition(nil, 8, 3, 3, false))
    xyz:SetTarget(Xyz.Target(nil, 8, 3, 3, false))
    xyz:SetOperation(Xyz.Operation(nil, 8, 3, 3, false))
    xyz:SetValue(SUMMON_TYPE_XYZ)
    xyz:SetReset(RESET_CHAIN)
    c:RegisterEffect(xyz)
    return xyz
end

function s.e1con(e)
    local c = e:GetHandler()
    return Duel.GetAttacker() == c or Duel.GetAttackTarget() == c and
               c:GetBattleTarget() and
               (Duel.GetCurrentPhase() == PHASE_DAMAGE or Duel.GetCurrentPhase() ==
                   PHASE_DAMAGE_CAL)
end

function s.e1tg(e, c) return c == e:GetHandler():GetBattleTarget() end

function s.e2filter(c, tc, tp)
    if not c:IsSetCard(0x107e) or c:IsForbidden() then return false end

    local effs = {c:GetCardEffect(75402014)}
    for _, te in ipairs(effs) do
        if te:GetValue()(tc, c, tp) then return true end
    end
    return false
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK +
                                                   LOCATION_GRAVE +
                                                   LOCATION_EXTRA, 0, 1, nil, c,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 or c:IsFacedown() or
        not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e2filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE +
                                          LOCATION_EXTRA, 0, 1, 1, nil, c, tp)
    local tc = g:GetFirst()
    if tc then
        local eff = tc:GetCardEffect(75402014)
        eff:GetOperation()(tc, eff:GetLabelObject(), tp, c)
    end
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(function(c)
        return c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ)
    end, 1, nil)
end

function s.e3tg(e, c) return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) end

function s.e3val(e, re) return re:GetOwnerPlayer() ~= e:GetHandlerPlayer() end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) and
                   c:GetFlagEffect(id) == 0
    end

    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_DAMAGE_CAL, 0, 1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(c:GetAttack() * 2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
