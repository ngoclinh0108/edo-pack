-- Clear Wing Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(
                             aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM)),
                         1, 99)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- place pendulum
    local me9 = Effect.CreateEffect(c)
    me9:SetDescription(1160)
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
