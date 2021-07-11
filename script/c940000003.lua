-- Number C39: Utopia Beyond the Shining
Duel.LoadScript("util.lua")
local s, id = GetID()

s.xyz_number = 39
s.listed_names = {21521304}
s.listed_series = {0x107e, 0x48}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute,
                                                 ATTRIBUTE_LIGHT), 8, 3)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.xyzlimit)
    c:RegisterEffect(splimit)

    -- xyz summon cannot be negated
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_XYZ
    end)
    c:RegisterEffect(e1)

    -- summon success
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_XYZ
    end)
    e2:SetOperation(function()
        Duel.SetChainLimitTillChainEnd(function(e, ep, tp)
            return tp == ep
        end)
    end)
    c:RegisterEffect(e2)

    -- equip
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_NEGATE +
                       EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- immune
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_ONFIELD, 0)
    e4:SetCondition(s.effcon)
    e4:SetTarget(s.e4tg)
    e4:SetValue(s.e4val)
    c:RegisterEffect(e4)

    -- double atk
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.effcon)
    e5:SetCost(s.e5cost)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.e3filter(c, tc, tp)
    if not c:IsSetCard(0x107e) or c:IsForbidden() then return false end

    local effs = {c:GetCardEffect(75402014)}
    for _, te in ipairs(effs) do
        if te:GetValue()(tc, c, tp) then return true end
    end
    return false
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK +
                                                   LOCATION_GRAVE +
                                                   LOCATION_EXTRA, 0, 1, nil, c,
                                               tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp,
                          LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 or c:IsFacedown() or
        not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter), tp,
                                      LOCATION_DECK + LOCATION_GRAVE +
                                          LOCATION_EXTRA, 0, 1, 1, nil, c, tp)
    local tc = g:GetFirst()
    if tc then
        local eff = tc:GetCardEffect(75402014)
        eff:GetOperation()(tc, eff:GetLabelObject(), tp, c)
    end
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil,
                                                     21521304)
end

function s.e4tg(e, c) return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) end

function s.e4val(e, re) return re:GetOwnerPlayer() ~= e:GetHandlerPlayer() end

function s.e5cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return c:CheckRemoveOverlayCard(tp, 1, REASON_COST) and
                   c:GetFlagEffect(id) == 0
    end

    c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_DAMAGE_CAL, 0, 1)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(c:GetAttack() * 2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
