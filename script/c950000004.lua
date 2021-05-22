-- Odd-Eyes Raging Dragon - Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x99}
s.listed_series = {0x99}
s.pendulum_level = 7

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, nil, 7, 2, nil, 0, nil, nil, false, function(g, tp, sc)
        return g:IsExists(function(tc)
            return tc:IsSetCard(0x99) and tc:IsRace(RACE_DRAGON)
        end, 1, nil)
    end)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_XYZ) == SUMMON_TYPE_XYZ or
                   (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- place pendulum
    local me9 = Effect.CreateEffect(c)
    me9:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me9:SetProperty(EFFECT_FLAG_DELAY)
    me9:SetCode(EVENT_DESTROYED)
    me9:SetCondition(s.me9con)
    me9:SetTarget(s.me9tg)
    me9:SetOperation(s.me9op)
    c:RegisterEffect(me9)
end

function s.me9con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.me9tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or
                   Duel.CheckLocation(tp, LOCATION_PZONE, 1)
    end
end

function s.me9op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.CheckLocation(tp, LOCATION_PZONE, 0) and
        not Duel.CheckLocation(tp, LOCATION_PZONE, 1) then return false end
    if not c:IsRelateToEffect(e) then return end

    Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
end
